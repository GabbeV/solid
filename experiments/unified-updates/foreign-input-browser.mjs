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
import { createSignal, createMemo, createRoot, createRenderEffect, action, pending } from '/bundle.mjs';
const suspended = new URLSearchParams(location.search).has('async');
const [x, setX] = createSignal(0), [y, setY] = createSignal(0);
let finishX, finishY;
const xEnd = new Promise(resolve => { finishX = resolve; });
const yEnd = new Promise(resolve => { finishY = resolve; });
const answers = new Map();
createRoot(() => {
  const status = pending(x);
  const label = createMemo(() => {
    const p = status(), n = y();
    if (!p || !suspended) return p + ':' + n;
    return new Promise(resolve => answers.set(n, () => resolve(p + ':' + n)));
  });
  for (const [id, read] of [['status', status], ['y', y], ['label', label]]) {
    createRenderEffect(read, value => { document.getElementById(id).textContent = String(value); });
  }
  document.getElementById('inspect').onclick = () => { window.observed = [String(status()), String(y()), label()]; };
});
const changeY = action(function* () { setY(10); yield yEnd; });
const changeX = action(function* () { setX(1); yield xEnd; });
document.getElementById('start-y').onclick = () => { changeY(); };
document.getElementById('start-x').onclick = () => { changeX(); };
document.getElementById('finish-y').onclick = () => { finishY(); };
document.getElementById('finish-x').onclick = () => { finishX(); };
document.getElementById('old-answer').onclick = () => { answers.get(0)(); };
document.getElementById('new-answer').onclick = () => { answers.get(10)(); };
`;
const server = createServer(async (req, res) => {
  if (req.url === "/bundle.mjs") {
    res.setHeader("Content-Type", "text/javascript");
    res.end(await readFile(resolve(out, "candidate-pending.mjs")));
  } else if (req.url === "/program.mjs") {
    res.setHeader("Content-Type", "text/javascript");
    res.end(program);
  } else {
    res.setHeader("Content-Type", "text/html");
    res.end(`${["status", "y", "label"].map(id => `<p>${id}: <span id="${id}"></span></p>`).join("")}
      ${["start-y", "start-x", "finish-y", "finish-x", "old-answer", "new-answer", "inspect"].map(id => `<button id="${id}">${id}</button>`).join("")}
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
  for (const suspended of [false, true]) {
    const page = await browser.newPage();
    const errors = [];
    page.on("pageerror", error => errors.push(error.message));
    await page.goto(`http://127.0.0.1:${server.address().port}/${suspended ? "?async" : ""}`);
    await page.waitForFunction(() => document.querySelector("#label").textContent === "false:0");
    const frames = [];
    const capture = async (step, expected) => {
      await page.locator("#inspect").click();
      const values = await page.locator("span").allTextContents();
      const observed = await page.evaluate(() => window.observed);
      assert.deepEqual(values, expected, step);
      assert.deepEqual(observed, values, `${step}: imperative reads disagree with DOM`);
      frames.push({ step, values, observed });
    };
    await capture("initial", ["false", "0", "false:0"]);
    const steps = suspended
      ? [
          ["start-y", ["false", "0", "false:0"]],
          ["start-x", ["false", "0", "false:0"]],
          ["finish-y", ["false", "0", "false:0"]],
          ["old-answer", ["false", "0", "false:0"]],
          ["new-answer", ["true", "10", "true:10"]],
          ["finish-x", ["false", "10", "false:10"]]
        ]
      : [
          ["start-y", ["false", "0", "false:0"]],
          ["start-x", ["true", "0", "true:0"]],
          ["finish-y", ["true", "10", "true:10"]],
          ["finish-x", ["false", "10", "false:10"]]
        ];
    for (const [step, expected] of steps) {
      await page.locator(`#${step}`).click();
      await page.evaluate(() => new Promise(resolve => requestAnimationFrame(resolve)));
      await capture(step, expected);
    }
    assert.deepEqual(errors, []);
    results.push({ suspended, frames, errors });
    await page.close();
  }
} finally {
  await browser.close();
  server.close();
}
await writeFile(resolve(out, "foreign-input-browser.json"), JSON.stringify(results, null, 2));
console.log(JSON.stringify(results, null, 2));
