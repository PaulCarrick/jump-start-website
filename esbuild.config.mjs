// Builds app/javascript/application.js into app/assets/builds.
// `rails assets:precompile` runs this through `npm run build` with RAILS_ENV=production,
// which gives a minified bundle with React's production build.
// Anything else (bin/dev, the tests) gets the readable development build.
// Pass --watch to rebuild on every change.

import * as esbuild from "esbuild"

const environment = process.env.NODE_ENV || process.env.RAILS_ENV || "development"
const isProduction = environment === "production"
const isWatching = process.argv.includes("--watch")

const options = {
  entryPoints: ["app/javascript/application.js"],
  bundle: true,
  sourcemap: true,
  format: "esm",
  outdir: "app/assets/builds",
  publicPath: "/assets",
  loader: { ".js": "jsx" },
  minify: isProduction,
  define: { "process.env.NODE_ENV": JSON.stringify(isProduction ? "production" : "development") },
  logLevel: "info",
}

if (isWatching) {
  const context = await esbuild.context(options)
  await context.watch()
} else {
  await esbuild.build(options)
}
