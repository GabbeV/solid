// Build the combined runtimes with optimistic-pending-question.mjs first.
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
import { createSignal, createMemo, createRenderEffect, createRoot, action, optimistic, isPending } from '/bundle.mjs';
let finish, reply, start, view;
const end = new Promise(resolve => { finish = resolve; });
const result = new Promise(resolve => { reply = resolve; });
const request = new Promise(resolve => { start = resolve; });
const [id, setId] = createSignal(0);
const bind = (id, read) => createRenderEffect(read, value => {
  document.getElementById(id).textContent = String(value);
});
createRoot(() => {
  const input = createMemo(() => id() ? result : 0);
  const [output, guess] = optimistic(input);
  view = output;
  const twice = createMemo(() => view() * 2);
  bind('input', input);
  bind('view', view);
  bind('twice', twice);
  bind('status', () => isPending(view));
  const run = action(function* () { guess(1); yield request; setId(1); yield end; });
  document.getElementById('guess').onclick = () => { run(); };
});
document.getElementById('request').onclick = () => start();
document.getElementById('late').onclick = () => createRoot(() => bind('lateStatus', () => isPending(view)));
document.getElementById('answer').onclick = () => reply(Number(new URL(location.href).searchParams.get('answer')));
document.getElementById('finish').onclick = () => finish();
`;
const server = createServer(async (req, res) => {
  if (req.url === "/bundle.mjs") {
    res.setHeader("Content-Type", "text/javascript");
    res.end(await readFile(resolve(out, "candidate-optimistic-pending-question.mjs")));
  } else if (req.url === "/program.mjs") {
    res.setHeader("Content-Type", "text/javascript");
    res.end(program);
  } else {
    res.setHeader("Content-Type", "text/html");
    res.end(`${["input", "view", "twice", "status", "lateStatus"].map(id => `<p>${id}: <span id="${id}"></span></p>`).join("")}
      ${["guess", "request", "late", "answer", "finish"].map(id => `<button id="${id}">${id}</button>`).join("")}
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
  for (const answer of [0, 1, 2]) {
    const page = await browser.newPage();
    const errors = [];
    page.on("pageerror", error => errors.push(error.message));
    await page.goto(`http://127.0.0.1:${server.address().port}/?answer=${answer}`);
    await page.waitForFunction(() => document.getElementById("status").textContent === "false");
    const frames = [];
    const check = async (step, expected) => {
      const values = await page.locator("span").allTextContents();
      frames.push({ step, values });
      assert.deepEqual(values, expected.map(String), step);
    };
    await check("initial", [0, 0, 0, false, ""]);
    for (const [button, expected] of [
      ["guess", [0, 1, 2, false, ""]],
      ["request", [0, 1, 2, true, ""]],
      ["late", [0, 1, 2, true, true]],
      ["answer", [0, 1, 2, answer === 2, answer === 2]],
      ["finish", [answer, answer, answer * 2, false, false]]
    ]) {
      await page.locator(`#${button}`).click();
      await page.evaluate(() => new Promise(resolve => requestAnimationFrame(resolve)));
      await check(button, expected);
    }
    assert.deepEqual(errors, []);
    results.push({ answer, frames, errors });
    await page.close();
  }
} finally {
  await browser.close();
  server.close();
}
await writeFile(resolve(out, "optimistic-pending-browser.json"), JSON.stringify(results, null, 2));
console.log("Optimistic input pending: equal, matching and differing DOM timelines passed.");
