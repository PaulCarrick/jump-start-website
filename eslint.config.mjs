import globals from "globals";
import pluginReact from "eslint-plugin-react";

/** @type {import('eslint').Linter.Config[]} */
export default [
  {files: ["**/*.{js,mjs,cjs,jsx}"]},
  {files: ["**/*.js"], languageOptions: {sourceType: "module"}},
  {languageOptions: {globals: globals.browser}},
  pluginReact.configs.flat.recommended,
  {settings: {react: {version: "detect"}}},
];