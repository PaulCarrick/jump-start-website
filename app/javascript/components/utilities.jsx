// /app/javascript/components/utilities.jsx

// Utility functions

export function isPresent(variable) {
  if (variable === undefined || variable === null) return false;
  if (typeof variable === "boolean") return true;
  if (typeof variable === "number") return !isNaN(variable);
  if (typeof variable === "string") return variable.trim().length > 0;
  if (typeof variable === "function") return true;
  if (Array.isArray(variable)) return variable.length > 0;
  if (variable instanceof Set || variable instanceof Map) return variable.size > 0;
  if (typeof variable === "object") return Object.keys(variable).length > 0;

  return true;
}

export function dupObject(existingObject) {
  if (!isPresent(existingObject)) return {};
  return structuredClone(existingObject);
}

export function arrayToHash(stringArray) {
  let options = []

  for (const text of stringArray) {
    options.push({
                   label: text,
                   value: text,
                 });
  }

  return options;
}

export function stringOrValue(value) {
  if (typeof value === "string")
    return value;
  else
    return value.value;
}

