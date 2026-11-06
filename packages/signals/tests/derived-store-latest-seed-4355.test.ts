import { describe, expect, it } from "vitest";
import {
  createMemo,
  createRenderEffect,
  createRoot,
  createStore,
  flush,
  latest
} from "../src/index.js";

// #4355 (D-30, D-22, D-3): a derived store whose derive reads an async memo
// through `latest()` resolves; its first downstream reader must see what the
// derive wrote, never the seed. A render effect commits only the real value.
describe("#4355 derived store over latest() of an async memo", () => {
  const settle = async () => {
    for (let i = 0; i < 4; i++) {
      await new Promise(r => setTimeout(r, 0));
      flush();
    }
  };

  async function run(
    form: "latest" | "plain",
    reader: "memo" | "store" | "direct",
    holdSibling = false,
    asyncDerive = false
  ) {
    let resolve!: (v: { name: string }) => void;
    const seen: unknown[] = [];
    const sibling = Promise.withResolvers<void>();
    let dispose!: () => void;
    createRoot(d => {
      dispose = d;
      const record = createMemo(() => new Promise<{ name: string }>(r => (resolve = r)));
      if (holdSibling) {
        const details = createMemo(() => {
          record();
          return sibling.promise;
        });
        createRenderEffect(details, () => {});
      }
      const [state] = createStore<any>((draft: any) => {
        draft.value = {
          name: form === "latest" ? latest(() => record().name) : record().name
        };
        if (asyncDerive) return Promise.resolve();
      }, {});
      if (reader === "memo") {
        const view = createMemo(() => state.value?.name);
        createRenderEffect(view, v => {
          seen.push(v);
        });
      } else if (reader === "store") {
        // The report's display store: a second derived store copying the first.
        const [display] = createStore<any>((draft: any) => {
          draft.value = state.value;
        }, {});
        createRenderEffect(
          () => display.value?.name,
          v => {
            seen.push(v);
          }
        );
      } else {
        createRenderEffect(
          () => state.value?.name,
          v => {
            seen.push(v);
          }
        );
      }
    });
    flush();
    expect(seen).toEqual([]);
    resolve({ name: "Hartford" });
    await settle();
    // A sibling can keep the input update open after its first answer.
    // That must never turn the store's uninitialized seed into a value.
    expect(seen).not.toContain(undefined);
    sibling.resolve();
    await settle();
    dispose();
    return seen;
  }

  for (const form of ["latest", "plain"] as const)
    for (const reader of ["memo", "store", "direct"] as const)
      for (const holdSibling of [false, true])
        for (const asyncDerive of [false, true])
          it(`${form} derive, ${reader} reader, held sibling ${holdSibling}, async derive ${asyncDerive}: the effect commits only the value`, async () => {
            expect(await run(form, reader, holdSibling, asyncDerive)).toEqual(["Hartford"]);
          });
});
