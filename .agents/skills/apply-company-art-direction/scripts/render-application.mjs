import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import crypto from "node:crypto";
import { spawn, spawnSync } from "node:child_process";
import { fileURLToPath, pathToFileURL } from "node:url";

const args = process.argv.slice(2);
const option = (name) => {
  const index = args.indexOf(name);
  return index >= 0 ? args[index + 1] : undefined;
};
const has = (name) => args.includes(name);
const repoRoot = path.resolve(option("--repo-root") ?? ".");
const companySlug = option("--company-slug");
const buildId = option("--build-id") ?? new Date().toISOString().replace(/[-:TZ.]/g, "").slice(0, 14);
const requirePdfTools = has("--require-pdf-tools");
if (!companySlug || !/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(companySlug)) throw new Error("--company-slug is required and must be kebab-case");
if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(buildId)) throw new Error("--build-id must be lowercase kebab-case");

const sha = (value) => crypto.createHash("sha256").update(value).digest("hex");
const fileSha = (file) => sha(fs.readFileSync(file));
const rel = (file) => path.relative(repoRoot, file).replaceAll(path.sep, "/");
const stable = (value) => {
  if (Array.isArray(value)) return `[${value.map(stable).join(",")}]`;
  if (value && typeof value === "object") return `{${Object.keys(value).sort().map((key) => `${JSON.stringify(key)}:${stable(value[key])}`).join(",")}}`;
  return JSON.stringify(value);
};
const combinedDirectory = (root, extension) => {
  if (!fs.existsSync(root)) return { sha256: null, fileCount: 0, files: [] };
  const walk = (dir) => fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => entry.isDirectory() ? walk(path.join(dir, entry.name)) : [path.join(dir, entry.name)]);
  const files = walk(root).filter((file) => !extension || file.endsWith(extension)).sort((a, b) => a.localeCompare(b));
  const records = files.map((file) => `${rel(file)}:${fileSha(file)}`);
  return { sha256: sha(records.join("\n")), fileCount: files.length, files };
};
const fileRecord = (relativePath) => ({ path: relativePath, sha256: fileSha(path.join(repoRoot, relativePath)) });

const applicationRoot = path.join(repoRoot, "designs", companySlug, "application");
const manifestPath = path.join(applicationRoot, "theme-manifest.json");
const adapterPath = path.join(applicationRoot, "adapter.css");
const fontManifestPath = path.join(applicationRoot, "font-license.json");
const rendererRelative = rel(fileURLToPath(import.meta.url));

const validator = path.join(repoRoot, ".agents", "skills", "apply-company-art-direction", "scripts", "validate-application.ps1");
const validation = spawnSync("powershell.exe", ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", validator, "-RepoRoot", repoRoot, "-CompanySlug", companySlug], { encoding: "utf8", windowsHide: true });
if (validation.status !== 0) throw new Error(`Application source validation failed:\n${validation.stdout}${validation.stderr}`);

const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
const fontManifest = JSON.parse(fs.readFileSync(fontManifestPath, "utf8"));
const mode = manifest.mode;
const stagingRoot = path.join(repoRoot, "result", "design", companySlug, ".staging", buildId);
const buildRoot = path.join(repoRoot, "result", "design", companySlug, "builds", buildId);
if (fs.existsSync(stagingRoot) || fs.existsSync(buildRoot)) throw new Error(`Build ID already exists and is immutable: ${buildId}`);
fs.mkdirSync(path.dirname(stagingRoot), { recursive: true });
fs.mkdirSync(stagingRoot);
const relBuild = (file) => path.relative(stagingRoot, file).replaceAll(path.sep, "/");

const contentRoot = path.join(repoRoot, "result", "content");
const layoutRoot = path.join(repoRoot, "result", "layout");
const pageMap = JSON.parse(fs.readFileSync(path.join(repoRoot, "portfolio-system", "page-map.json"), "utf8"));
const contentSnapshot = combinedDirectory(contentRoot, ".md");
const layoutSnapshot = combinedDirectory(layoutRoot, ".html");

function getProbes(html) {
  return [...html.matchAll(/<meta\s+name=["']pdf-text-probe["']\s+content=["']([^"']+)["']/gi)].map((match) => match[1]);
}

function buildInputLock(capturedAt) {
  const pages = [];
  if (mode === "portfolio-render") {
    for (const contentFile of contentSnapshot.files) {
      const stem = path.basename(contentFile, ".md");
      const layoutFile = path.join(layoutRoot, `${stem}.html`);
      if (!fs.existsSync(layoutFile)) throw new Error(`Missing neutral layout: result/layout/${stem}.html`);
      const entry = pageMap.pages[`${stem}.md`];
      if (!entry) throw new Error(`Missing page-map entry: ${stem}.md`);
      const html = fs.readFileSync(layoutFile, "utf8");
      const probes = getProbes(html);
      if (!probes.length) throw new Error(`Missing pdf-text-probe: result/layout/${stem}.html`);
      pages.push({ name: stem, contentSha256: fileSha(contentFile), layoutSha256: fileSha(layoutFile), type: entry.type, density: entry.density, textProbes: probes });
    }
  }
  const inputs = {
    artDirection: fileRecord(`designs/${companySlug}/research/art-direction/art-direction.json`),
    extractionAcceptance: fileRecord(`designs/${companySlug}/research/art-direction/acceptance.json`),
    systemManifest: fileRecord("portfolio-system/system.manifest.json"),
    core: fileRecord("portfolio-system/core.css"),
    themeContract: fileRecord("portfolio-system/THEME_CONTRACT.md"),
    pageMap: fileRecord("portfolio-system/page-map.json"),
    content: { path: "result/content", sha256: contentSnapshot.sha256 },
    adapter: fileRecord(`designs/${companySlug}/application/adapter.css`),
    fontLicense: fileRecord(`designs/${companySlug}/application/font-license.json`),
    renderer: fileRecord(rendererRelative)
  };
  return { schemaVersion: "1.0.0", companySlug, mode, buildId, capturedAt, inputs, pages, combinedSha256: sha(stable({ companySlug, mode, buildId, inputs, pages })) };
}

const inputLock = buildInputLock(new Date().toISOString());
fs.writeFileSync(path.join(stagingRoot, "inputs.lock.json"), `${JSON.stringify(inputLock, null, 2)}\n`, "utf8");

const pagesRoot = path.join(stagingRoot, "pages");
const fixturesRoot = path.join(stagingRoot, "fixtures");
fs.mkdirSync(path.join(pagesRoot, "fonts"), { recursive: true });
fs.mkdirSync(fixturesRoot, { recursive: true });
for (const font of fontManifest.fonts) {
  const source = path.join(applicationRoot, font.file);
  const destination = path.join(pagesRoot, "fonts", path.basename(font.file));
  fs.copyFileSync(source, destination, fs.constants.COPYFILE_EXCL);
  if (fileSha(destination) !== font.sha256) throw new Error(`Copied font hash mismatch: ${font.file}`);
}

const coreCss = fs.readFileSync(path.join(repoRoot, "portfolio-system", "core.css"), "utf8");
const adapterCss = fs.readFileSync(adapterPath, "utf8");
const neutralCss = fs.readFileSync(path.join(repoRoot, "portfolio-system", "themes", "neutral.css"), "utf8");
fs.writeFileSync(path.join(pagesRoot, "theme.css"), `${coreCss}\n/* --- COMPANY ADAPTER SOURCE BOUNDARY --- */\n${adapterCss}`, "utf8");
fs.writeFileSync(path.join(fixturesRoot, "neutral-theme.css"), `${coreCss}\n/* --- SYNTHETIC NEUTRAL THEME --- */\n${neutralCss}`, "utf8");
fs.writeFileSync(path.join(fixturesRoot, "empty.css"), "/* intentionally empty: compiled theme is loaded by the first link */\n", "utf8");

const browserCandidates = [
  "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe",
  "C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe",
  "C:\\Program Files\\Microsoft\\Edge\\Application\\msedge.exe",
  "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe"
];
const browser = browserCandidates.find(fs.existsSync);
if (!browser) throw new Error("Chrome or Edge was not found in a standard Windows install path");
const profile = path.join(os.tmpdir(), `portfolio-application-${crypto.randomUUID()}`);
fs.mkdirSync(profile);
const browserProcess = spawn(browser, ["--headless", "--disable-gpu", "--hide-scrollbars", "--allow-file-access-from-files", "--no-first-run", "--no-default-browser-check", "--window-size=1280,720", "--force-device-scale-factor=1", "--remote-debugging-port=0", `--user-data-dir=${profile}`], { stdio: "ignore", windowsHide: true });

const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
async function getPort() {
  const portFile = path.join(profile, "DevToolsActivePort");
  for (let i = 0; i < 100; i += 1) {
    if (fs.existsSync(portFile)) return Number(fs.readFileSync(portFile, "utf8").split(/\r?\n/)[0]);
    if (browserProcess.exitCode !== null) throw new Error("Browser exited before opening DevTools");
    await delay(100);
  }
  throw new Error("Timed out waiting for Chrome DevTools port");
}

class Cdp {
  constructor(url) {
    this.ws = new WebSocket(url);
    this.nextId = 1;
    this.pending = new Map();
    this.events = new Map();
    this.opened = new Promise((resolve, reject) => { this.ws.onopen = resolve; this.ws.onerror = reject; });
    this.ws.onmessage = (event) => {
      const message = JSON.parse(event.data);
      if (message.id && this.pending.has(message.id)) {
        const { resolve, reject } = this.pending.get(message.id); this.pending.delete(message.id);
        if (message.error) reject(new Error(message.error.message)); else resolve(message.result);
      } else if (message.method && this.events.has(message.method)) {
        for (const handler of this.events.get(message.method)) handler(message.params);
      }
    };
  }
  async send(method, params = {}) {
    await this.opened; const id = this.nextId++;
    return new Promise((resolve, reject) => { this.pending.set(id, { resolve, reject }); this.ws.send(JSON.stringify({ id, method, params })); });
  }
  waitFor(method, timeout = 15000) {
    return new Promise((resolve, reject) => {
      const handler = (params) => { clearTimeout(timer); this.events.set(method, (this.events.get(method) ?? []).filter((item) => item !== handler)); resolve(params); };
      this.events.set(method, [...(this.events.get(method) ?? []), handler]);
      const timer = setTimeout(() => reject(new Error(`Timed out waiting for ${method}`)), timeout);
    });
  }
  close() { this.ws.close(); }
}

const toolPath = (name) => {
  const result = spawnSync("where.exe", [name], { encoding: "utf8", windowsHide: true });
  return result.status === 0 ? result.stdout.split(/\r?\n/).find(Boolean) : null;
};
const pdfTools = { pdftotext: toolPath("pdftotext"), pdfinfo: toolPath("pdfinfo"), pdffonts: toolPath("pdffonts") };
const pdfToolsAvailable = Object.values(pdfTools).every(Boolean);

async function renderOne(port, htmlFile, targetBase, fontChecks, probes) {
  const response = await fetch(`http://127.0.0.1:${port}/json/new?${encodeURIComponent(pathToFileURL(htmlFile).href)}`, { method: "PUT" });
  if (!response.ok) throw new Error(`Could not create browser target: ${response.status}`);
  const target = await response.json();
  const cdp = new Cdp(target.webSocketDebuggerUrl);
  await Promise.all([cdp.send("Page.enable"), cdp.send("Runtime.enable"), cdp.send("Network.enable")]);
  await cdp.send("Emulation.setDeviceMetricsOverride", { width: 1280, height: 720, deviceScaleFactor: 1, mobile: false });
  const loaded = cdp.waitFor("Page.loadEventFired");
  await cdp.send("Page.navigate", { url: pathToFileURL(htmlFile).href });
  await loaded;
  const audit = await cdp.send("Runtime.evaluate", {
    awaitPromise: true,
    returnByValue: true,
    expression: `(async () => {
      await document.fonts.ready;
      await Promise.all(${JSON.stringify(fontChecks)}.map(f => document.fonts.load(f.weight + ' 16px "' + f.family.replaceAll('"','\\"') + '"', '한글ABC123')));
      await new Promise(r => requestAnimationFrame(() => requestAnimationFrame(r)));
      const page = document.querySelector('.page');
      const rect = page?.getBoundingClientRect();
      const visible = [...document.querySelectorAll('body *')].filter(el => {
        const s = getComputedStyle(el); const r = el.getBoundingClientRect();
        return s.display !== 'none' && s.visibility !== 'hidden' && r.width > 0 && r.height > 0 && !el.closest('[data-allow-bleed]');
      });
      const outside = visible.filter(el => { const r = el.getBoundingClientRect(); return r.left < -0.5 || r.top < -0.5 || r.right > 1280.5 || r.bottom > 720.5; }).length;
      return {
        dom: page?.outerHTML || '',
        overflowFree: !!page && Math.abs(rect.width - 1280) < 1 && Math.abs(rect.height - 720) < 1 && document.documentElement.scrollWidth <= 1280 && document.documentElement.scrollHeight <= 720 && document.body.scrollWidth <= 1280 && document.body.scrollHeight <= 720 && outside === 0,
        remoteResources: performance.getEntriesByType('resource').map(x => x.name).filter(x => /^https?:/i.test(x)),
        fonts: ${JSON.stringify(fontChecks)}.map(f => ({ ...f, loaded: document.fonts.check(f.weight + ' 16px "' + f.family.replaceAll('"','\\"') + '"', '한글ABC123') }))
      };
    })()`
  });
  const value = audit.result.value;
  const screenshot = await cdp.send("Page.captureScreenshot", { format: "png", captureBeyondViewport: false });
  const pdf = await cdp.send("Page.printToPDF", { printBackground: true, preferCSSPageSize: true, paperWidth: 13.333333, paperHeight: 7.5, marginTop: 0, marginBottom: 0, marginLeft: 0, marginRight: 0 });
  fs.writeFileSync(`${targetBase}.png`, Buffer.from(screenshot.data, "base64"));
  fs.writeFileSync(`${targetBase}.pdf`, Buffer.from(pdf.data, "base64"));
  cdp.close();
  await fetch(`http://127.0.0.1:${port}/json/close/${target.id}`).catch(() => {});

  const dimensions = fs.readFileSync(`${targetBase}.png`).subarray(16, 24);
  const width = dimensions.readUInt32BE(0); const height = dimensions.readUInt32BE(4);
  let textProbesPassed = null;
  let pdfGeometryPassed = null;
  let pdfFontsPassed = null;
  if (pdfToolsAvailable) {
    const textResult = spawnSync(pdfTools.pdftotext, ["-enc", "UTF-8", `${targetBase}.pdf`, "-"], { encoding: "utf8", windowsHide: true });
    textProbesPassed = textResult.status === 0 && probes.every((probe) => textResult.stdout.includes(probe)) && !textResult.stdout.includes("�");
    const info = spawnSync(pdfTools.pdfinfo, [`${targetBase}.pdf`], { encoding: "utf8", windowsHide: true });
    pdfGeometryPassed = info.status === 0 && /Pages:\s+1\b/.test(info.stdout) && /Page size:\s+960(?:\.\d+)? x 540(?:\.\d+)? pts/.test(info.stdout);
    const fontResult = spawnSync(pdfTools.pdffonts, [`${targetBase}.pdf`], { encoding: "utf8", windowsHide: true });
    pdfFontsPassed = fontResult.status === 0 && !/Type 3/i.test(fontResult.stdout);
  }
  return { domSha256: sha(value.dom), overflowFree: value.overflowFree, remoteResources: value.remoteResources, fontsLoaded: value.fonts.every((font) => font.loaded), png1280x720: width === 1280 && height === 720, pdfNonEmpty: fs.statSync(`${targetBase}.pdf`).size > 1024, textProbesPassed, pdfGeometryPassed, pdfFontsPassed };
}

const outputs = [];
const blockers = [];
let port;
try {
  port = await getPort();
  const fontChecks = fontManifest.fonts.map((font) => ({ family: font.family, weight: font.weight }));
  const fixturePairs = [];
  for (const fixtureName of ["sparse", "dense"]) {
    const template = fs.readFileSync(path.join(repoRoot, "portfolio-system", "fixtures", `${fixtureName}.html`), "utf8");
    const variants = [
      { name: `neutral-${fixtureName}`, theme: pathToFileURL(path.join(fixturesRoot, "neutral-theme.css")).href, fonts: [] },
      { name: `company-${fixtureName}`, theme: pathToFileURL(path.join(pagesRoot, "theme.css")).href, fonts: fontChecks }
    ];
    const pair = {};
    for (const variant of variants) {
      const dir = path.join(fixturesRoot, variant.name); fs.mkdirSync(dir);
      const htmlFile = path.join(dir, `${fixtureName}.html`);
      const html = template.replace("__CORE_URI__", variant.theme).replace("__THEME_URI__", pathToFileURL(path.join(fixturesRoot, "empty.css")).href);
      fs.writeFileSync(htmlFile, html, "utf8");
      const base = path.join(dir, fixtureName);
      const result = await renderOne(port, htmlFile, base, variant.fonts, ["PORTFOLIO SYSTEM"]);
      pair[variant.name.startsWith("neutral") ? "neutral" : "company"] = result.domSha256;
      outputs.push({ kind: "fixture", name: variant.name, html: relBuild(htmlFile), htmlSha256: fileSha(htmlFile), png: relBuild(`${base}.png`), pngSha256: fileSha(`${base}.png`), pdf: relBuild(`${base}.pdf`), pdfSha256: fileSha(`${base}.pdf`), png1280x720: result.png1280x720, pdfNonEmpty: result.pdfNonEmpty, overflowFree: result.overflowFree, textProbesPassed: result.textProbesPassed, _audit: result });
    }
    fixturePairs.push(pair);
  }

  if (mode === "portfolio-render") {
    for (const page of inputLock.pages) {
      const source = path.join(layoutRoot, `${page.name}.html`);
      const htmlFile = path.join(pagesRoot, `${page.name}.html`);
      fs.copyFileSync(source, htmlFile, fs.constants.COPYFILE_EXCL);
      const base = path.join(pagesRoot, page.name);
      const result = await renderOne(port, htmlFile, base, fontChecks, page.textProbes);
      fs.copyFileSync(`${base}.pdf`, path.join(stagingRoot, `portfolio-${Number(page.name.slice(0, 2))}.pdf`), fs.constants.COPYFILE_EXCL);
      outputs.push({ kind: "page", name: page.name, html: `pages/${page.name}.html`, htmlSha256: fileSha(htmlFile), png: `pages/${page.name}.png`, pngSha256: fileSha(`${base}.png`), pdf: `pages/${page.name}.pdf`, pdfSha256: fileSha(`${base}.pdf`), png1280x720: result.png1280x720, pdfNonEmpty: result.pdfNonEmpty, overflowFree: result.overflowFree, textProbesPassed: result.textProbesPassed, _audit: result });
    }
  }

  const stableLock = buildInputLock(inputLock.capturedAt);
  const inputLockStable = stableLock.combinedSha256 === inputLock.combinedSha256;
  const fixtureDomStable = fixturePairs.every((pair) => pair.neutral === pair.company);
  const fontsVerified = outputs.filter((output) => output.name.startsWith("company-") || output.kind === "page").every((output) => output._audit.fontsLoaded);
  const allRendersValid = outputs.every((output) => output.png1280x720 && output.pdfNonEmpty && !output._audit.remoteResources.length);
  const overflowFree = outputs.every((output) => output.overflowFree);
  const textExtractionVerified = pdfToolsAvailable && outputs.every((output) => output.textProbesPassed === true && output._audit.pdfGeometryPassed === true && output._audit.pdfFontsPassed === true);
  const expectedOutputCount = mode === "portfolio-render" ? 4 + inputLock.pages.length : 4;
  const pageInventoryComplete = outputs.length === expectedOutputCount;
  if (!inputLockStable) blockers.push("Application inputs changed during rendering");
  if (!fixtureDomStable) blockers.push("Neutral and company fixture DOM hashes differ");
  if (!fontsVerified) blockers.push("One or more declared fonts did not load");
  if (!allRendersValid) blockers.push("One or more renders or local-resource checks failed");
  if (!overflowFree) blockers.push("One or more renders overflow the 1280x720 canvas");
  if (!pageInventoryComplete) blockers.push("Rendered inventory is incomplete");
  if (!pdfToolsAvailable) blockers.push("pdftotext, pdfinfo, and pdffonts are all required for production eligibility");
  else if (!textExtractionVerified) blockers.push("PDF text, geometry, or font inspection failed");
  for (const output of outputs) delete output._audit;
  const walk = (dir) => fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => entry.isDirectory() ? walk(path.join(dir, entry.name)) : [path.join(dir, entry.name)]);
  const outputRecords = walk(stagingRoot)
    .filter((file) => relBuild(file) !== "inputs.lock.json" && relBuild(file) !== "preflight.json" && relBuild(file) !== "acceptance.json" && !relBuild(file).startsWith("reviews/"))
    .sort((a, b) => a.localeCompare(b))
    .map((file) => `${relBuild(file)}:${fileSha(file)}`);
  const preflight = {
    schemaVersion: "1.0.0", companySlug, mode, buildId, generatedAt: new Date().toISOString(), browser,
    inputLockSha256: fileSha(path.join(stagingRoot, "inputs.lock.json")), sourceManifestSha256: fileSha(manifestPath),
    outputs,
    checks: { inputLockStable, fixtureDomStable, pageInventoryComplete, fontsVerified, allRendersValid, overflowFree, textExtractionVerified },
    blockers, outputSetSha256: sha(outputRecords.join("\n")), productionGateEligible: blockers.length === 0
  };
  fs.writeFileSync(path.join(stagingRoot, "preflight.json"), `${JSON.stringify(preflight, null, 2)}\n`, "utf8");
  fs.mkdirSync(path.dirname(buildRoot), { recursive: true });
  fs.renameSync(stagingRoot, buildRoot);
  process.stdout.write(`Application render complete: ${rel(buildRoot)}\nProduction gate eligible: ${preflight.productionGateEligible}\n`);
  if (requirePdfTools && !preflight.productionGateEligible) process.exitCode = 2;
} finally {
  browserProcess.kill();
  await delay(200);
  const resolved = path.resolve(profile);
  if (resolved.startsWith(path.resolve(os.tmpdir()) + path.sep) && path.basename(resolved).startsWith("portfolio-application-")) fs.rmSync(resolved, { recursive: true, force: true });
}
