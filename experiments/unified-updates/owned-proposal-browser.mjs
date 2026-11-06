import assert from "node:assert/strict";
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
import {createSignal, createMemo, createRenderEffect, createRoot, action} from '/bundle.mjs';
let finish;
const end = new Promise(resolve => {finish = resolve;});
const [generation, setGeneration] = createSignal(0);
createRoot(() => {
  const owner = createMemo(() => {
    const value = generation();
    createRenderEffect(() => value, next => {
      document.getElementById('child').textContent = String(next);
    });
    return 0;
  });
  createRenderEffect(owner, () => {});
  createRenderEffect(generation, value => {
    document.getElementById('input').textContent = String(value);
  });
});
const change = action(function* () {setGeneration(1); yield end;});
document.getElementById('change').onclick = () => {change();};
document.getElementById('finish').onclick = () => {finish();};
`;
let name;
const server = createServer(async (req, res) => {
  if (req.url === "/bundle.mjs") {
    res.setHeader("Content-Type", "text/javascript");
    res.end(await readFile(resolve(out, `${name}-ordinary.mjs`)));
  } else if (req.url === "/program.mjs") {
    res.setHeader("Content-Type", "text/javascript");
    res.end(program);
  } else {
    res.setHeader("Content-Type", "text/html");
    res.end(`<p>Input: <span id="input"></span></p><p>Owned child: <span id="child"></span></p>
      <button id="change">Change</button><button id="finish">Finish</button>
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
  for (name of ["baseline", "candidate"]) {
    const page = await browser.newPage();
    const errors = [];
    page.on("pageerror", error => errors.push(error.message));
    await page.goto(`http://127.0.0.1:${server.address().port}`);
    await page.waitForFunction(() => document.getElementById("input").textContent === "0");
    const frames = [];
    const capture = async step => {
      const values = await page.locator("span").allTextContents();
      frames.push({ step, values });
      if (name === "candidate") assert.equal(values[0], values[1], step);
    };
    await capture("initial");
    for (const button of ["change", "finish"]) {
      await page.locator(`#${button}`).click();
      await page.evaluate(() => new Promise(resolve => requestAnimationFrame(resolve)));
      await capture(button);
    }
    assert.deepEqual(errors, []);
    assert.deepEqual(frames[1].values, name === "candidate" ? ["0", "0"] : ["0", "1"]);
    assert.deepEqual(frames[2].values, ["1", "1"]);
    results.push({ name, frames, errors });
    await page.close();
  }
} finally {
  await browser.close();
  server.close();
}
await writeFile(resolve(out, "owned-proposal-browser.json"), JSON.stringify(results, null, 2));
console.log(
  "Ordinary owned-child DOM: baseline exposes 0/1; candidate retains 0/0 until 1/1 is ready."
);
