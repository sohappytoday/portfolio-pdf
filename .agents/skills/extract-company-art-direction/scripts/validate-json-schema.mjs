import fs from "node:fs";

const [schemaPath, dataPath] = process.argv.slice(2);
if (!schemaPath || !dataPath) {
  process.stderr.write("Usage: node validate-json-schema.mjs <schema.json> <data.json>\n");
  process.exit(2);
}

let rootSchema;
let data;
try {
  rootSchema = JSON.parse(fs.readFileSync(schemaPath, "utf8"));
  data = JSON.parse(fs.readFileSync(dataPath, "utf8"));
} catch (error) {
  process.stderr.write(`JSON read failure: ${error.message}\n`);
  process.exit(1);
}

const failures = [];
const typeOf = (value) => {
  if (value === null) return "null";
  if (Array.isArray(value)) return "array";
  if (Number.isInteger(value)) return "integer";
  return typeof value === "object" ? "object" : typeof value;
};

const resolveRef = (ref) => {
  if (!ref.startsWith("#/")) throw new Error(`Only local schema refs are supported: ${ref}`);
  return ref.slice(2).split("/").reduce((node, segment) => node[segment.replaceAll("~1", "/").replaceAll("~0", "~")], rootSchema);
};

const same = (left, right) => JSON.stringify(left) === JSON.stringify(right);

function validate(schema, value, path) {
  if (!schema || Object.keys(schema).length === 0) return;
  if (schema.$ref) return validate(resolveRef(schema.$ref), value, path);

  if (Object.hasOwn(schema, "const") && !same(value, schema.const)) {
    failures.push(`${path}: must equal ${JSON.stringify(schema.const)}`);
  }
  if (schema.enum && !schema.enum.some((candidate) => same(value, candidate))) {
    failures.push(`${path}: must be one of ${schema.enum.map(JSON.stringify).join(", ")}`);
  }

  if (schema.type) {
    const accepted = Array.isArray(schema.type) ? schema.type : [schema.type];
    const actual = typeOf(value);
    const typeMatches = accepted.some((expected) => expected === actual || (expected === "number" && actual === "integer"));
    if (!typeMatches) {
      failures.push(`${path}: expected ${accepted.join("|")}, got ${actual}`);
      return;
    }
  }

  if (typeof value === "string") {
    if (schema.minLength !== undefined && value.length < schema.minLength) failures.push(`${path}: shorter than minLength ${schema.minLength}`);
    if (schema.pattern && !(new RegExp(schema.pattern).test(value))) failures.push(`${path}: does not match ${schema.pattern}`);
    if (schema.format === "date") {
      const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value);
      const parsed = match ? new Date(`${value}T00:00:00Z`) : null;
      if (!match || Number.isNaN(parsed.valueOf()) || parsed.toISOString().slice(0, 10) !== value) failures.push(`${path}: invalid date`);
    }
    if (schema.format === "uri") {
      try {
        const url = new URL(value);
        if (!url.protocol) throw new Error("missing protocol");
      } catch { failures.push(`${path}: invalid URI`); }
    }
  }

  if (typeof value === "number") {
    if (schema.minimum !== undefined && value < schema.minimum) failures.push(`${path}: below minimum ${schema.minimum}`);
    if (schema.maximum !== undefined && value > schema.maximum) failures.push(`${path}: above maximum ${schema.maximum}`);
    if (schema.multipleOf !== undefined && Math.abs(value / schema.multipleOf - Math.round(value / schema.multipleOf)) > 1e-10) {
      failures.push(`${path}: not a multiple of ${schema.multipleOf}`);
    }
  }

  if (Array.isArray(value)) {
    if (schema.minItems !== undefined && value.length < schema.minItems) failures.push(`${path}: fewer than ${schema.minItems} items`);
    if (schema.maxItems !== undefined && value.length > schema.maxItems) failures.push(`${path}: more than ${schema.maxItems} items`);
    if (schema.uniqueItems && new Set(value.map(JSON.stringify)).size !== value.length) failures.push(`${path}: items must be unique`);
    if (schema.items) value.forEach((item, index) => validate(schema.items, item, `${path}[${index}]`));
  }

  if (value && typeOf(value) === "object") {
    const keys = Object.keys(value);
    if (schema.minProperties !== undefined && keys.length < schema.minProperties) failures.push(`${path}: fewer than ${schema.minProperties} properties`);
    for (const required of schema.required ?? []) {
      if (!Object.hasOwn(value, required)) failures.push(`${path}: missing required property ${required}`);
    }
    for (const key of keys) {
      if (schema.properties && Object.hasOwn(schema.properties, key)) {
        validate(schema.properties[key], value[key], `${path}.${key}`);
      } else if (schema.additionalProperties === false) {
        failures.push(`${path}: unexpected property ${key}`);
      } else if (schema.additionalProperties && typeof schema.additionalProperties === "object") {
        validate(schema.additionalProperties, value[key], `${path}.${key}`);
      }
    }
  }
}

try {
  validate(rootSchema, data, "$");
} catch (error) {
  failures.push(`Schema evaluator error: ${error.message}`);
}

if (failures.length) {
  process.stderr.write(`Schema validation FAIL: ${dataPath}\n${failures.map((item) => `- ${item}`).join("\n")}\n`);
  process.exit(1);
}

process.stdout.write(`Schema validation PASS: ${dataPath}\n`);

