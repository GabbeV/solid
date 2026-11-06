import { createRequire } from "node:module";
import { createServer } from "node:http";
import { readFile, writeFile } from "node:fs/promises";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
const require = createRequire(import.meta.url);
const { chromium } = require(
  process.env.LAYER_PLAYWRIGHT || "/workspace/pr3886/browser/node_modules/playwright"
);
const here = dirname(fileURLToPath(import.meta.url));
const scalar = process.argv.includes("--scalar");
const out = resolve(here, "results", scalar ? "scalar" : "");
const program = `
import { createSignal, createMemo, createRenderEffect, createRoot, action, optimistic } from '/bundle.mjs';
const gates = new Map();
let next, finish;
const step = () => new Promise(resolve => { next = resolve; });
const end = new Promise(resolve => { finish = resolve; });
const [source, setSource] = createSignal(0);
const [tick, setTick] = createSignal(0);
let view, guess, clear;
const left = document.querySelector('#left'), right = document.querySelector('#right');
createRoot(() => {
  [view, guess, clear] = optimistic(source);
  const derived = createMemo(() => {
    const value = view();
    if (!value) return value;
    return new Promise(resolve => gates.set(value, () => resolve(value)));
  });
  createRenderEffect(() => [tick(), view()], v => { left.textContent = v.join(' / '); });
  createRenderEffect(() => [view(), derived()], v => { right.textContent = v.join(' / '); });
  document.querySelector('#inspect').onclick = () => {
    window.eventRead = [view(), derived()];
  };
});
const run = action(function* () {
  guess(1); yield step(); guess(2); yield end; setSource(0); clear?.();
});
document.querySelector('#start').onclick = () => { run(); };
document.querySelector('#one').onclick = () => { gates.get(1)(); };
document.querySelector('#next').onclick = () => { next(); };
document.querySelector('#tick').onclick = () => { setTick(1); };
document.querySelector('#two').onclick = () => { gates.get(2)(); };
document.querySelector('#finish').onclick = () => { finish(); };
document.querySelector('#mount').onclick = () => {
  createRoot(() => createRenderEffect(view, v => { document.querySelector('#late').textContent = String(v); }));
};
`;
let name = "baseline";
const server = createServer(async (req, res) => {
  if (req.url === "/bundle.mjs") {
    res.setHeader("Content-Type", "text/javascript");
    res.end(await readFile(resolve(out, `${name}-optimistic.mjs`)));
  } else if (req.url === "/program.mjs") {
    res.setHeader("Content-Type", "text/javascript");
    res.end(program);
  } else {
    res.setHeader("Content-Type", "text/html");
    res.end(`<p>Independent reader: <span id="left"></span></p>
      <p>Coupled reader: <span id="right"></span></p><p>Late reader: <span id="late"></span></p>
      ${["start", "one", "next", "tick", "mount", "two", "finish", "inspect"].map(x => `<button id="${x}">${x}</button>`).join("")}
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
    page.on("pageerror", e => errors.push(e.message));
    await page.goto(`http://127.0.0.1:${server.address().port}`);
    await page.waitForFunction(() => document.querySelector("#right").textContent === "0 / 0");
    const frames = [];
    const capture = async label => {
      await page.locator("#inspect").click();
      frames.push({
        label,
        values: await page.locator("span").allTextContents(),
        eventRead: await page.evaluate(() => window.eventRead)
      });
    };
    await capture("initial");
    for (const button of ["start", "one", "next", "tick", "mount", "two", "finish"]) {
      await page.locator(`#${button}`).click();
      // Browser events flush via the runtime's normal microtask scheduler.
      await page.evaluate(() => new Promise(resolve => requestAnimationFrame(() => resolve())));
      await capture(button);
    }
    results.push({ name, frames, errors });
    await page.screenshot({ path: resolve(out, `${name}.png`) });
    await page.close();
  }
} finally {
  await browser.close();
  server.close();
}
await writeFile(resolve(out, "browser.json"), JSON.stringify(results, null, 2));
console.log(JSON.stringify(results, null, 2));
const candidate = results.find(r => r.name === "candidate");
for (const frame of candidate.frames) {
  if (
    frame.values[1] !== frame.eventRead.join(" / ") ||
    frame.values[0].split(" / ")[1] !== String(frame.eventRead[0]) ||
    (frame.values[2] && frame.values[2] !== String(frame.eventRead[0]))
  ) {
    throw new Error(`Event-handler reads disagree with rendered publication at ${frame.label}`);
  }
}
if (
  candidate.errors.length ||
  candidate.frames.find(f => f.label === "mount").values.join("|") !== "1 / 1|1 / 1|1"
)
  throw new Error("Candidate DOM publication is inconsistent");
