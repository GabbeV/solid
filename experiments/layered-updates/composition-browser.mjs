import assert from "node:assert/strict";
import { createRequire } from "node:module";
import { createServer } from "node:http";
import { readFile, writeFile } from "node:fs/promises";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
const { chromium } = createRequire(import.meta.url)(
  process.env.LAYER_PLAYWRIGHT || "/workspace/pr3886/browser/node_modules/playwright"
);
const here = dirname(fileURLToPath(import.meta.url));
const out = resolve(process.argv[2] || resolve(here, "results/composition-stage18"));
const program = `
import { createSignal, createMemo, createRoot, createRenderEffect, action, optimistic } from '/bundle.mjs';
const gate = () => { let resolve; const promise = new Promise(yes => { resolve = yes; }); return { promise, resolve }; };
const first = gate(), final = gate(), lower = gate(), ending = gate();
const [y, setY] = createSignal(0);
let view, guess;
createRoot(() => {
  [view, guess] = optimistic(() => 0);
  let input = y;
  for (let i = 1; i < 8; i++) { const previous = input; input = createMemo(() => previous()); }
  const lowerResult = createMemo(() => input() ? lower.promise : 0);
  createRenderEffect(lowerResult, () => {});
  const pair = createMemo(() => view() + ':' + y());
  const label = createMemo(() => pair() === '1:0' ? first.promise : pair() === '1:10' ? final.promise : pair());
  for (const [id, read] of [['view', view], ['y', y], ['label', label]]) {
    createRenderEffect(read, value => { document.getElementById(id).textContent = String(value); });
  }
});
document.getElementById('start').onclick = action(function* () { guess(1); yield ending.promise; });
document.getElementById('lower').onclick = () => { setY(10); };
document.getElementById('first').onclick = () => { first.resolve('1:0'); };
document.getElementById('release').onclick = () => { lower.resolve(10); };
document.getElementById('final').onclick = () => { final.resolve('1:10'); };
document.getElementById('finish').onclick = () => { ending.resolve(); };
document.getElementById('mount').onclick = () => {
  createRoot(() => createRenderEffect(view, value => { document.getElementById('late').textContent = String(value); }));
};
`;
let runtime = "baseline";
const server = createServer(async (request, response) => {
  if (request.url === "/bundle.mjs") {
    response.setHeader("Content-Type", "text/javascript");
    response.end(await readFile(resolve(out, `${runtime}-optimistic.mjs`)));
  } else if (request.url === "/program.mjs") {
    response.setHeader("Content-Type", "text/javascript");
    response.end(program);
  } else {
    response.setHeader("Content-Type", "text/html");
    response.end(`${["view", "y", "label", "late"].map(id => `<p>${id}: <span id="${id}"></span></p>`).join("")}
      ${["start", "lower", "first", "release", "final", "finish", "mount"].map(id => `<button id="${id}">${id}</button>`).join("")}
      <script type="module" src="/program.mjs"></script>`);
  }
});
await new Promise(resolve => server.listen(0, "127.0.0.1", resolve));
const browser = await chromium.launch({
  executablePath: "/usr/bin/chromium",
  headless: true,
  args: ["--no-sandbox"]
});
const results = [];
try {
  for (runtime of ["baseline", "candidate"]) {
    const page = await browser.newPage();
    const errors = [],
      frames = [];
    page.on("pageerror", error => errors.push(error.message));
    await page.goto(`http://127.0.0.1:${server.address().port}`);
    await page.waitForFunction(() => document.getElementById("label").textContent === "0:0");
    for (const [step, expected] of [
      ["initial", ["0", "0", "0:0", ""]],
      ["start", ["0", "0", "0:0", ""]],
      ["lower", ["0", "0", "0:0", ""]],
      ["mount", ["0", "0", "0:0", "0"]],
      ["first", ["1", "0", "1:0", "1"]],
      ["release", ["1", "0", "1:0", "1"]],
      ["final", ["1", "10", "1:10", "1"]],
      ["finish", ["0", "10", "0:10", "0"]]
    ]) {
      if (step !== "initial") await page.click(`#${step}`);
      await page.evaluate(
        () => new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve)))
      );
      const actual = await page.evaluate(() =>
        ["view", "y", "label", "late"].map(id => document.getElementById(id).textContent)
      );
      frames.push({ step, actual });
      if (runtime === "candidate") assert.deepEqual(actual, expected, step);
    }
    assert.deepEqual(errors, []);
    results.push({ runtime, frames, errors });
    await page.close();
  }
  await writeFile(resolve(out, "composition-browser.json"), JSON.stringify(results, null, 2));
  console.log(JSON.stringify(results));
} finally {
  await browser.close();
  await new Promise(resolve => server.close(resolve));
}
