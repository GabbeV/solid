import { expect, it } from "vitest";
import { createOptimisticStore, createRenderEffect, createRoot, flush } from "../src/index.js";
const settle = async () => {
  for (let i = 0; i < 4; i++) {
    await new Promise(r => setTimeout(r, 0));
    flush();
  }
};
for (const surface of ["field", "length", "presence", "keys", "descriptor"] as const)
  it(`initialized outer producer does not publish unknown inner ${surface}`, async () => {
    const first = Promise.withResolvers<{
      field: number;
      items: string[];
      obj: Record<string, number>;
    }>();
    const frames: unknown[] = [];
    let dispose!: () => void;
    createRoot(d => {
      dispose = d;
      const [inner] = createOptimisticStore(() => first.promise, {
        field: -111,
        items: ["RAW"],
        obj: { raw: 1 }
      });
      const [outer] = createOptimisticStore(() => ({ child: inner }), {
        child: { field: -222, items: ["OUT"], obj: { out: 1 } }
      });
      createRenderEffect(
        () => {
          const c = outer.child;
          return surface === "field"
            ? c.field
            : surface === "length"
              ? c.items.length
              : surface === "presence"
                ? "field" in c
                : surface === "keys"
                  ? Object.keys(c.obj).join(",")
                  : Object.getOwnPropertyDescriptor(c, "field")?.value;
        },
        v => {
          frames.push(v);
        }
      );
    });
    try {
      flush();
      const initial = [...frames];
      first.resolve({ field: 2, items: ["a", "b"], obj: { real: 1 } });
      await settle();
      expect(initial).toEqual([]);
      expect(frames.at(-1)).toEqual(
        surface === "keys" ? "real" : surface === "presence" ? true : 2
      );
    } finally {
      first.resolve({ field: 2, items: ["a", "b"], obj: { real: 1 } });
      dispose();
      flush();
    }
  });
for (const form of ["draft", "return"] as const)
  it(`a ${form} projection cannot materialize an unknown sibling seed`, async () => {
    const first = Promise.withResolvers<{ field: number }>();
    const frames: number[] = [];
    let dispose!: () => void;
    createRoot(d => {
      dispose = d;
      const [inner] = createOptimisticStore(() => first.promise, { field: -111 });
      const [outer] = createOptimisticStore(
        form === "draft"
          ? (draft: any) => {
              draft.value = inner.field;
            }
          : () => ({ value: inner.field }),
        { value: -222 }
      );
      createRenderEffect(
        () => outer.value,
        v => {
          frames.push(v);
        }
      );
    });
    try {
      flush();
      expect(frames).toEqual([]);
      first.resolve({ field: 2 });
      await settle();
      expect(frames).toEqual([2]);
    } finally {
      first.resolve({ field: 2 });
      dispose();
      flush();
    }
  });
