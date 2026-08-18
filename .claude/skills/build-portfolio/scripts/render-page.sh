#!/usr/bin/env bash
# render-page.sh — render one HTML page to a PDF and a PNG screenshot using whatever
# Chromium-based browser is installed (headless, no node/npm needed).
#
# Usage: render-page.sh <html-file> <out-basename> [window-size]
#   <html-file>     path to the HTML file to render (must have a <style> @page rule
#                    controlling PDF page size — the PNG uses window-size instead)
#   <out-basename>  output path without extension -> <out-basename>.pdf / .png
#   [window-size]   WxH for the PNG screenshot, default 1280x720 (match your page's
#                    visual aspect ratio so the PNG preview looks like the PDF page)
#
# Requires an absolute Windows path for the HTML file's file:// URL — this script
# resolves it from a POSIX (git-bash) path automatically.

set -uo pipefail

HTML="${1:?usage: render-page.sh <html-file> <out-basename> [window-size]}"
OUT="${2:?usage: render-page.sh <html-file> <out-basename> [window-size]}"
WINSIZE="${3:-1280,720}"

if [ ! -f "$HTML" ]; then
  echo "!! HTML file not found: $HTML" >&2
  exit 1
fi

# Find a Chromium-based browser (Chrome preferred, then Edge) at standard install paths.
BROWSER=""
for candidate in \
  "/c/Program Files/Google/Chrome/Application/chrome.exe" \
  "/c/Program Files (x86)/Google/Chrome/Application/chrome.exe" \
  "/c/Program Files/Microsoft/Edge/Application/msedge.exe" \
  "/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
do
  if [ -f "$candidate" ]; then
    BROWSER="$candidate"
    break
  fi
done

if [ -z "$BROWSER" ]; then
  echo "!! No Chrome/Edge found at standard install paths. Checked:" >&2
  echo "   Program Files/Google/Chrome, Program Files (x86)/Google/Chrome," >&2
  echo "   Program Files/Microsoft/Edge, Program Files (x86)/Microsoft/Edge" >&2
  exit 1
fi

# Resolve to an absolute Windows-style file:// URL.
WIN_PATH=$(cd "$(dirname "$HTML")" && pwd -W)/$(basename "$HTML")
FILE_URL="file:///${WIN_PATH}"

mkdir -p "$(dirname "$OUT")"

# Resolve OUT to an absolute Windows-style path too — chrome.exe is a native
# Windows binary and has been observed to fail to resolve a relative
# --print-to-pdf/--screenshot path ("지정된 경로를 찾을 수 없습니다.") even
# though its CWD looks correct from bash's point of view. Absolute sidesteps
# it entirely.
OUT_DIR_WIN=$(cd "$(dirname "$OUT")" && pwd -W)
OUT="${OUT_DIR_WIN}/$(basename "$OUT")"

# A regular (GUI) Chrome/Edge instance is very likely already running for this
# user. Launching headless Chrome with the default profile in that situation
# just forwards the request to the already-running instance and exits
# immediately WITHOUT rendering anything — --print-to-pdf/--screenshot become
# silent no-ops, but exit 0, so the stale output file is left in place and
# looks "successful". Force a private, disposable profile dir per invocation
# so headless Chrome always starts its own instance and actually renders.
USER_DATA_DIR="$(mktemp -d)"
trap 'rm -rf "$USER_DATA_DIR"' EXIT

# Re-rendering the SAME output path repeatedly (e.g. while iterating on a page's
# CSS/fonts) has been observed to reproduce a STALE result even with a fresh
# --user-data-dir above — some cache keyed by file path (GPU shader cache or a
# Windows-level font-substitution cache, outside the profile dir) appears to
# persist a "this stylesheet's font failed to load, use the fallback" decision
# across otherwise-independent invocations. Rendering to a throwaway,
# never-before-used temp path first and moving the result into place sidesteps
# this entirely and costs nothing.
TMP_BASENAME="$(mktemp -u "$(dirname "$OUT")/.render-XXXXXXXX")"
TMP_HTML="${TMP_BASENAME}$(basename "$HTML")"
cp "$HTML" "$TMP_HTML"
TMP_FILE_URL="file:///$(cd "$(dirname "$TMP_HTML")" && pwd -W)/$(basename "$TMP_HTML")"
trap 'rm -rf "$USER_DATA_DIR"; rm -f "$TMP_HTML" "${TMP_BASENAME}.pdf" "${TMP_BASENAME}.png"' EXIT

# Remove stale outputs first so a silent no-op can't masquerade as success.
rm -f "${OUT}.pdf" "${OUT}.png"

echo "==> Rendering $HTML"
echo "    browser: $BROWSER"

"$BROWSER" --headless --disable-gpu --no-pdf-header-footer \
  --user-data-dir="$USER_DATA_DIR" --no-first-run --no-default-browser-check \
  --print-to-pdf="${TMP_BASENAME}.pdf" "$TMP_FILE_URL" 2>&1 | grep -v "^\[" || true

"$BROWSER" --headless --disable-gpu --window-size="$WINSIZE" \
  --user-data-dir="$USER_DATA_DIR" --no-first-run --no-default-browser-check \
  --screenshot="${TMP_BASENAME}.png" "$TMP_FILE_URL" 2>&1 | grep -v "^\[" || true

mv -f "${TMP_BASENAME}.pdf" "${OUT}.pdf" 2>/dev/null || true
mv -f "${TMP_BASENAME}.png" "${OUT}.png" 2>/dev/null || true

if [ -s "${OUT}.pdf" ] && [ -s "${OUT}.png" ]; then
  echo "==> Done: ${OUT}.pdf, ${OUT}.png"
else
  echo "!! One or both outputs missing/empty — check the browser output above." >&2
  exit 1
fi
