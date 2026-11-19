// Verify the accepted rule: a published guess retains pending input work.
import assert from "node:assert/strict";
import { build } from "esbuild";
import { dirname, resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
const here = dirname(fileURLToPath(import.meta.url));
const scalar = process.argv.includes("--scalar");
const out = resolve(here, "results", scalar ? "scalar" : "");
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
for (const [implementation, root] of [
  ["baseline", "/workspace/layered-baseline"],
  ["candidate", resolve(here, "../..")]
]) {
  const tree = resolve(
    root,
    `packages/signals/dist/${implementation === "candidate" && scalar ? "scalar" : "prod"}`
  );
  const entry = resolve(tree, "index.js");
  let contents = `export {createSignal, createMemo, createRenderEffect, createRoot, action, flush} from ${JSON.stringify(entry)};`;
  contents +=
    implementation === "baseline"
      ? `export {createOptimistic as optimistic, isPending} from ${JSON.stringify(entry)};`
      : `import {createLayer} from ${JSON.stringify(resolve(tree, "experimental/layer.js"))};
       export const optimistic = input => createLayer(input, {lifetime:"action"});
       export {isPending} from ${JSON.stringify(resolve(tree, "experimental/pending.js"))};`;
  const outfile = resolve(out, `${implementation}-optimistic-pending-question.mjs`);
  await build({
    stdin: { contents, resolveDir: root },
    outfile,
    bundle: true,
    format: "esm",
    platform: "node",
    minify: true,
    logLevel: "error"
  });
  const {
    createSignal,
    createMemo,
    createRenderEffect,
    createRoot,
    action,
    flush,
    optimistic,
    isPending
  } = await import(pathToFileURL(outfile));
  for (const answer of [0, 1, 2]) {
    let finish, reply, dispose, guess;
    const end = new Promise(resolve => {
      finish = resolve;
    });
    const result = new Promise(resolve => {
      reply = resolve;
    });
    const [id, setId] = createSignal(0);
    const shown = { input: 0, view: 0, inputPending: false, viewPending: false };
    createRoot(d => {
      dispose = d;
      const input = createMemo(() => (id() ? result : 0));
      const [view, write] = optimistic(input);
      guess = write;
      createRenderEffect(input, v => {
        shown.input = v;
      });
      createRenderEffect(view, v => {
        shown.view = v;
      });
      createRenderEffect(
        () => isPending(input),
        v => {
          shown.inputPending = v;
        }
      );
      createRenderEffect(
        () => isPending(view),
        v => {
          shown.viewPending = v;
        }
      );
    });
    flush();
    const running = action(function* () {
      setId(1);
      guess(1);
      yield end;
    })();
    flush();
    console.log(
      JSON.stringify({
        implementation,
        answer,
        step: "guess published; input request pending",
        ...shown
      })
    );
    assert.deepEqual(shown, { input: 0, view: 1, inputPending: true, viewPending: true });
    reply(answer);
    await turn();
    console.log(
      JSON.stringify({
        implementation,
        answer,
        step: "request answered; action remains open",
        ...shown
      })
    );
    assert.deepEqual(shown, {
      input: 0,
      view: 1,
      inputPending: answer !== 0,
      viewPending: answer === 2
    });
    finish();
    await running;
    await turn();
    console.log(JSON.stringify({ implementation, answer, step: "action ends", ...shown }));
    assert.deepEqual(shown, {
      input: answer,
      view: answer,
      inputPending: false,
      viewPending: false
    });
    dispose();
  }
}
