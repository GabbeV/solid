import { expect, it } from "vitest";
import {
  action,
  createRoot,
  createSignal,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createLoadingBoundary,
  isPending,
  flush
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

async function publications(explicit: boolean, loading: boolean, outsideGuard: boolean) {
  const answer = Promise.withResolvers<number>();
  const shown = { id: 0, content: "", disabled: false, combined: "", late: "" };
  const snapshots: typeof shown[] = [];
  const changes: Record<string, (string | number | boolean)[]> = {};
  const show = <K extends keyof typeof shown>(key: K, value: typeof shown[K]) => {
    shown[key] = value;
    const values = changes[key] ??= [];
    // Compare each binding's published values, without imposing an order on
    // sibling callbacks or treating an equal callback as a new publication.
    if (values.at(-1) !== value) values.push(value);
  };
  let dispose!: () => void, disposeLate: (() => void) | undefined;
  let set!: (value: number) => number, rerun!: (value: number) => number;
  let guess!: (value: boolean) => boolean, pending!: () => boolean, id!: () => number;
  let running: Promise<void> | undefined;
  createRoot(cleanup => {
    dispose = cleanup;
    [id, set] = createSignal(0);
    const [unrelated, setUnrelated] = createSignal(0);
    rerun = setUnrelated;
    const data = createMemo(() => id() === 0 ? 0 : answer.promise);
    if (explicit) [pending, guess] = createOptimistic(() => {
      data();
      return false;
    });
    else pending = () => isPending(data);
    createRenderEffect(id, value => show("id", value), { schedule: true });
    if (outsideGuard) {
      createRenderEffect(pending, value => show("disabled", value), { schedule: true });
      createRenderEffect(
        () => `${unrelated()}:${id()}:${pending()}`,
        value => show("combined", value),
        { schedule: true }
      );
    }
    if (loading) {
      const content = createLoadingBoundary(() => `Item ${data()}`, () => "Loading", {
        on: pending
      });
      createRenderEffect(content, value => show("content", value), { schedule: true });
    }
  });
  try {
    flush();
    snapshots.push({ ...shown });
    if (explicit) running = action(function* () {
      set(1);
      guess(true);
    })();
    else set(1);
    flush();
    expect(shown.id).toBe(explicit ? 0 : 1);
    if (loading) expect(shown.content).toBe("Loading");
    if (outsideGuard) expect(shown.disabled).toBe(true);
    snapshots.push({ ...shown });
    rerun(1);
    flush();
    snapshots.push({ ...shown });
    if (outsideGuard) {
      createRoot(cleanup => {
        disposeLate = cleanup;
        createRenderEffect(
          () => `${id()}:${pending()}`,
          value => show("late", value),
          { schedule: true }
        );
      });
      flush();
      expect(shown.late).toBe(explicit ? "0:true" : "1:true");
      snapshots.push({ ...shown });
    }
    answer.resolve(10);
    await running;
    await turn();
    expect(shown.id).toBe(1);
    if (loading) expect(shown.content).toBe("Item 10");
    if (outsideGuard) expect(shown.disabled).toBe(false);
    snapshots.push({ ...shown });
    expect(changes.id).toEqual([0, 1]);
    if (outsideGuard) {
      expect(changes.disabled).toEqual([false, true, false]);
      expect(changes.combined).toEqual(explicit
        ? ["0:0:false", "0:0:true", "1:0:true", "1:1:false"]
        : ["0:0:false", "0:1:true", "1:1:true", "1:1:false"]);
      expect(changes.late).toEqual([explicit ? "0:true" : "1:true", "1:false"]);
    }
    return { snapshots, changes };
  } finally {
    disposeLate?.();
    dispose();
    flush();
  }
}

for (const [loading, outsideGuard] of [[false, true], [true, false], [true, true]])
  it(`pending reports work while an explicit optimistic input holds its own action (Loading=${loading}, outside=${outsideGuard})`, async () => {
    const pending = await publications(false, loading, outsideGuard);
    const optimistic = await publications(true, loading, outsideGuard);
    // Their ordinary output publications agree; the explicit boolean has
    // an action whose input value must finish, unlike a status-only query.
    expect(pending.changes.disabled).toEqual(optimistic.changes.disabled);
    expect(pending.changes.content).toEqual(optimistic.changes.content);
    expect(pending.snapshots.at(-1)).toEqual(optimistic.snapshots.at(-1));
  });
