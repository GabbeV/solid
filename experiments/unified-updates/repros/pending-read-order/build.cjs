// Compile ordinary JSX with the checked-out next compiler and renderer.
// The archived renderer sources are byte-identical to the pinned baseline.
const fs = require("node:fs");
const path = require("node:path");
const archive = "/workspace/pr3886/next";
const baseline = "/workspace/layered-baseline";
const babel = require(`${archive}/node_modules/@babel/core`);
const esbuild = require(`${archive}/node_modules/esbuild`);
const plugin = require(`${archive}/node_modules/@solidjs/babel-plugin`);
const tier = process.argv.includes("--dev") ? "dev" : "prod";
const source = fs.readFileSync(path.join(__dirname, "App.tsx"), "utf8");
const entry = `${source}\nimport { render } from '@solidjs/web';\nrender(() => <App />, document.getElementById('root'));`;
const { code } = babel.transformSync(entry, {
  filename: "App.tsx",
  babelrc: false,
  configFile: false,
  presets: [require(`${archive}/node_modules/@babel/preset-typescript`)],
  plugins: [[plugin, { generate: "dom", moduleName: "@solidjs/web" }]]
});
(async () => {
  await esbuild.build({
    stdin: { contents: code, resolveDir: archive, sourcefile: "App.tsx" },
    bundle: true,
    format: "esm",
    platform: "browser",
    conditions: tier === "dev" ? ["browser", "development"] : ["browser"],
    alias: {
      "solid-js/internal": `${archive}/packages/solid/dist/internal.js`,
      "solid-js": `${archive}/packages/solid/dist/solid${tier === "dev" ? ".dev" : ""}.js`,
      "@solidjs/web": `${archive}/packages/web/dist/web${tier === "dev" ? ".dev" : ""}.js`,
      "@solidjs/signals": `${baseline}/packages/signals/dist/${tier === "dev" ? "dev.js" : "prod/index.js"}`
    },
    outfile: path.join(__dirname, `${tier}.js`),
    logLevel: "error"
  });
  fs.writeFileSync(path.join(__dirname, `${tier}.html`),
    `<!doctype html><html><head><meta charset="utf-8"><title>Pending read order</title></head><body><div id="root"></div><script type="module" src="${tier}.js"></script></body></html>`);
})();
