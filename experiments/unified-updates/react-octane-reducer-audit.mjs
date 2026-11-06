// Dependencies are isolated from the Solid checkout. Pass the directory containing
// react@19.3.1, react-test-renderer@19.3.1, octane@0.16.6 and jsdom installations.
import { pathToFileURL } from "node:url";
import { createRequire } from "node:module";
import assert from "node:assert/strict";
const dependencyRoot = process.argv[2];
const suspend = process.argv.includes("--suspend");
const require = createRequire(`${dependencyRoot}/package.json`);
const { JSDOM } = require("jsdom");
const dom = new JSDOM("<!doctype html><html><body></body></html>");
for (const key of ["window", "document", "Node", "Element", "HTMLElement", "MutationObserver"])
  globalThis[key] = dom.window[key];
globalThis.IS_REACT_ACT_ENVIRONMENT = true;
const React = require("react");
const TestRenderer = require("react-test-renderer");
const Octane = await import(pathToFileURL(require.resolve("octane")));
const reports = {};

for (const framework of ["react", "octane"]) {
  const api = framework === "react" ? React : Octane;
  for (const mode of ["downstream-accumulator", "optimistic-reducer"]) {
    const end = Promise.withResolvers();
    const stale = Promise.withResolvers();
    let staleReady = false, suspendedAttempts = 0;
    const optimisticSlot = Symbol("optimism"), linkedSlot = Symbol("linked");
    let guess, root;
    function Tail({ value, sum }) {
      if (suspend && !staleReady && value === (mode === "optimistic-reducer" ? 6 : 1)) {
        suspendedAttempts++;
        throw stale.promise;
      }
      return `${value}/${sum}`;
    }
    function App() {
      const reducer = mode === "optimistic-reducer" ? (sum, delta) => sum + delta : (_, next) => next;
      const pair = framework === "react"
        ? api.useOptimistic(5, reducer)
        : api.useOptimistic(5, reducer, optimisticSlot);
      const value = pair[0];
      guess = pair[1];
      let sum = value;
      if (mode === "downstream-accumulator") {
        if (framework === "react") {
          const [history, setHistory] = api.useState(() => ({ input: value, sum: value }));
          if (history.input !== value) setHistory({ input: value, sum: history.sum + value });
          sum = history.sum;
        } else {
          [sum] = api.useLinkedState(value, (input, previous) => (previous?.value ?? 0) + input, undefined, linkedSlot);
        }
      }
      return api.createElement(Tail, { value, sum });
    }
    const container = document.createElement("div");
    document.body.append(container);
    const act = framework === "react" ? TestRenderer.act : Octane.act;
    await act(async () => {
      const element = api.createElement(api.Suspense, { fallback: "loading" }, api.createElement(App));
      if (framework === "react") root = TestRenderer.create(element);
      else { root = Octane.createRoot(container); root.render(element); }
    });
    const values = [];
    const snapshot = phase => values.push({ phase, shown: framework === "react" ? root.toJSON() : container.textContent });
    snapshot("initial");
    for (const delta of [1, 2]) {
      await act(async () => {
        api.startTransition(async () => { guess(delta); await end.promise; });
      });
      snapshot(`after ${delta}`);
    }
    if (suspend) {
      assert.ok(suspendedAttempts > 0);
      await act(async () => { staleReady = true; stale.resolve(); await stale.promise; });
      snapshot("stale work resolves");
    }
    await act(async () => { end.resolve(); await end.promise; });
    snapshot("reverted");
    assert.deepEqual(values.map(value => value.shown), suspend
      ? mode === "downstream-accumulator"
        ? ["5/5", "loading", "2/7", "2/7", "5/12"]
        : ["5/5", "loading", "8/8", "8/8", "5/5"]
      : mode === "downstream-accumulator"
        ? ["5/5", "1/6", "2/8", "5/13"]
        : ["5/5", "6/6", "8/8", "5/5"]);
    await act(async () => root.unmount());
    container.remove();
    reports[`${framework}/${mode}`] = values;
  }
}
console.log(JSON.stringify(reports, null, 2));
dom.window.close();
