import { createRequire } from "node:module";
import { createServer } from "node:http";
import { readFile, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
const require = createRequire(import.meta.url);
const { chromium } = require(
  process.env.LAYER_PLAYWRIGHT || "/workspace/pr3886/browser/node_modules/playwright"
);
const here = dirname(fileURLToPath(import.meta.url));
const scalar = process.argv.includes("--scalar");
const out = resolve(here, "results", scalar ? "scalar" : "");
const program = `
import { createSignal, createMemo, createRenderEffect, createRoot, pending, action } from '/bundle.mjs';
let finish, resolveTrue, resolveFalse;
const end = new Promise(r => { finish = r; });
const on = new Promise(r => { resolveTrue = r; });
const off = new Promise(r => { resolveFalse = r; });
const [x, setX] = createSignal(0);
createRoot(() => {
  const p = pending(x);
  const status = createMemo(p);
  const derived = createMemo(() => status() ? on : x() ? off : 'initial');
  const pair = createMemo(() => { const value = x(); return [status(), value, derived()]; });
  createRenderEffect(x, v => { document.querySelector('#value').textContent = String(v); });
  createRenderEffect(status, v => { document.querySelector('#status').textContent = String(v); });
  createRenderEffect(pair, v => { document.querySelector('#pair').textContent = JSON.stringify(v); });
  document.querySelector('#inspect').onclick = () => { window.observed = [x(), p(), pair()]; };
});
const run = action(function* () { setX(1); yield end; });
document.querySelector('#start').onclick = () => { run(); };
document.querySelector('#true').onclick = () => { resolveTrue('pending'); };
document.querySelector('#false').onclick = () => { resolveFalse('settled'); };
document.querySelector('#finish').onclick = () => { finish(); };
`;
let name = "baseline";
const server = createServer(async (req, res) => {
  if (req.url === "/bundle.mjs") {
    res.setHeader("Content-Type", "text/javascript");
    res.end(await readFile(resolve(out, `${name}-pending.mjs`)));
  } else if (req.url === "/program.mjs") {
    res.setHeader("Content-Type", "text/javascript");
    res.end(program);
  } else {
    res.setHeader("Content-Type", "text/html");
    res.end(`<p>Value: <span id="value"></span></p><p>Pending: <span id="status"></span></p>
      <p>Combined: <span id="pair"></span></p>
      ${["start", "true", "finish", "false", "inspect"].map(x => `<button id="${x}">${x}</button>`).join("")}
      <script type="module" src="/program.mjs"></script>`);
  }
});
await new Promise(resolve => server.listen(0, "127.0.0.1", resolve));
const browser = await chromium.launch({
  executablePath: process.env.CHROMIUM || "/usr/bin/chromium",
  headless: true,
  args: ["--no-sandbox"]
});
const results = [];
try {
  for (name of ["baseline", "candidate"])
    for (const supersede of [false, true]) {
      const page = await browser.newPage();
      const errors = [];
      page.on("pageerror", error => errors.push(error.message));
      await page.goto(`http://127.0.0.1:${server.address().port}`);
      await page.waitForFunction(
        () => document.querySelector("#pair").textContent === '[false,0,"initial"]'
      );
      const frames = [];
      const capture = async label => {
        await page.locator("#inspect").click();
        frames.push({
          label,
          values: await page.locator("span").allTextContents(),
          observed: await page.evaluate(() => window.observed)
        });
      };
      await capture("initial");
      for (const button of supersede
        ? ["start", "finish", "true", "false"]
        : ["start", "true", "finish", "false"]) {
        await page.locator(`#${button}`).click();
        await page.evaluate(() => new Promise(resolve => requestAnimationFrame(resolve)));
        await capture(button);
      }
      results.push({ name, supersede, frames, errors });
      await page.close();
    }
} finally {
  await browser.close();
  server.close();
}
await writeFile(resolve(out, "pending-browser.json"), JSON.stringify(results, null, 2));
for (const result of results.filter(r => r.name === "candidate")) {
  if (result.errors.length) throw new Error(result.errors.join("\n"));
  for (const frame of result.frames) {
    const pair = JSON.parse(frame.values[2]);
    if (
      frame.values[0] !== String(pair[1]) ||
      frame.values[1] !== String(pair[0]) ||
      JSON.stringify(frame.observed) !== JSON.stringify([pair[1], pair[0], pair])
    ) {
      throw new Error(`Pending publication disagrees at ${frame.label}: ${JSON.stringify(frame)}`);
    }
  }
  const expected = result.supersede
    ? ["0", "false", '[false,0,"initial"]']
    : ["0", "true", '[true,0,"pending"]'];
  if (
    JSON.stringify(result.frames.find(f => f.label === "finish").values) !==
    JSON.stringify(expected)
  )
    throw new Error("Input completion escaped its required consequence");
  if (result.frames.at(-1).values[2] !== '[false,1,"settled"]')
    throw new Error("The final update did not publish");
}
console.log(JSON.stringify(results, null, 2));
