import { afterEach, expect, it } from "vitest";
import {
  createLoadingBoundary,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  resetErrorHalt
} from "../src/index.js";
import { createLayer } from "../src/layers/layer.js";
import { isPending } from "../src/layers/pending.js";
import { $REFRESH } from "../src/core/constants.js";

function gate<T>() {
  let resolve!: (value: T) => void;
  const promise = new Promise<T>(yes => {
    resolve = yes;
  });
  return { promise, resolve };
}
const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
const disposals: (() => void)[] = [];
afterEach(() => {
  for (const dispose of disposals.splice(0)) dispose();
  flush();
  resetErrorHalt();
});

it("repeated Loading/pending mounts release subscriptions to a surviving source", async () => {
  const [source, setSource] = createSignal(0);
  for (let cycle = 0; cycle < 100; cycle++) {
    const answer = gate<string>();
    let shown = "";
    const dispose = createRoot(dispose => {
      const content = createMemo(() => (source() === cycle ? String(cycle) : answer.promise));
      const boundary = createLoadingBoundary(content, () => "loading", {
        on: () => isPending(content)
      });
      createRenderEffect(boundary, next => {
        shown = next;
      });
      return dispose;
    });
    disposals.push(dispose);
    flush();
    expect(shown).toBe(String(cycle));
    setSource(cycle + 1);
    flush();
    expect(shown).toBe("loading");
    answer.resolve(String(cycle + 1));
    await turn();
    expect(shown).toBe(String(cycle + 1));
    dispose();
    disposals.pop();
    flush();
    expect((source as any)[$REFRESH]._subs).toBeNull();
  }
});

// D-16/D-17: rearming from the proposed input follows that update; rearming
// from an explicitly published observation can show the fallback ahead of it.
// Pending-only observation does not retain content demand after fallback.
// This restores next's hold policy without restoring its reader posture.
for (const optimistic of [false, true])
  for (const rearm of ["none", "value", "pending", "pending-memo"] as const)
    for (const contentFirst of [false, true]) {
      it(`Loading follows its rearm publication (optimistic=${optimistic}, on=${rearm}, contentFirst=${contentFirst})`, async () => {
        const shellAnswer = gate<string>(),
          contentAnswer = gate<string>();
        let set!: (value: number) => unknown;
        const shown = { value: 0, shell: "shell0", content: "content0" };
        createRoot(dispose => {
          disposals.push(dispose);
          const [value, write] = optimistic ? createLayer(() => 0) : createSignal(0);
          set = write;
          const shell = createMemo(() => (value() ? shellAnswer.promise : "shell0"));
          const content = createMemo(() => (value() ? contentAnswer.promise : "content0"));
          const pendingMemo =
            rearm === "pending-memo" ? createMemo(() => isPending(content)) : undefined;
          const boundary = createLoadingBoundary(content, () => "loading", {
            on:
              rearm === "value"
                ? value
                : rearm === "pending"
                  ? () => isPending(content)
                  : pendingMemo
          });
          createRenderEffect(value, next => {
            shown.value = next;
          });
          createRenderEffect(shell, next => {
            shown.shell = next;
          });
          createRenderEffect(boundary, next => {
            shown.content = next;
          });
        });
        flush();
        set(1);
        flush();
        expect(shown).toEqual({
          value: 0,
          shell: "shell0",
          content: rearm.startsWith("pending") ? "loading" : "content0"
        });
        if (contentFirst) {
          contentAnswer.resolve("content1");
          await turn();
          expect(shown).toEqual({
            value: 0,
            shell: "shell0",
            content: rearm.startsWith("pending") ? "loading" : "content0"
          });
          shellAnswer.resolve("shell1");
        } else {
          shellAnswer.resolve("shell1");
          await turn();
          expect(shown).toEqual(
            rearm === "none"
              ? { value: 0, shell: "shell0", content: "content0" }
              : { value: 1, shell: "shell1", content: "loading" }
          );
          contentAnswer.resolve("content1");
        }
        await turn();
        expect(shown).toEqual({ value: 1, shell: "shell1", content: "content1" });
      });
    }

for (const optimistic of [false, true])
  for (const contentFirst of [false, true]) {
    it(`an async fallback participates in pending-output publication (optimistic=${optimistic}, contentFirst=${contentFirst})`, async () => {
      const contentAnswer = gate<string>(),
        fallbackAnswer = gate<string>();
      let set!: (value: number) => unknown;
      const shown = { value: 0, content: "content0", pending: false };
      createRoot(dispose => {
        disposals.push(dispose);
        const [value, write] = optimistic ? createLayer(() => 0) : createSignal(0);
        set = write;
        const content = createMemo(() => (value() ? contentAnswer.promise : "content0"));
        const boundary = createLoadingBoundary(content, () => fallbackAnswer.promise, {
          on: () => isPending(content)
        });
        createRenderEffect(value, next => {
          shown.value = next;
        });
        createRenderEffect(boundary, next => {
          shown.content = next as string;
        });
        createRenderEffect(
          () => isPending(content),
          next => {
            shown.pending = next;
          }
        );
      });
      flush();
      set(1);
      flush();
      // The fallback is a consequence of the pending output. Its own async
      // work must not leave ordinary consumers seeing different publications.
      expect(shown).toEqual({ value: 0, content: "content0", pending: false });
      if (contentFirst) {
        contentAnswer.resolve("content1");
        await turn();
        expect(shown).toEqual({ value: 1, content: "content1", pending: false });
        fallbackAnswer.resolve("loading");
      } else {
        fallbackAnswer.resolve("loading");
        await turn();
        // Pending reports the remaining work without reinstating the hold
        // released by the content fallback.
        expect(shown).toEqual({ value: 1, content: "loading", pending: true });
        contentAnswer.resolve("content1");
      }
      await turn();
      expect(shown).toEqual({ value: 1, content: "content1", pending: false });
    });
  }
