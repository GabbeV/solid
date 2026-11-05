import { afterEach, expect, it } from "vitest";
import {
  action,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  latest
} from "../src/index.js";

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
});

for (const wrapped of [false, true]) {
  it(`nested observations compose the selected outputs (wrapped=${wrapped})`, async () => {
    const end = gate<void>();
    const [x, setX] = createSignal(0);
    const input = wrapped ? () => x() : x;
    const shown: Record<string, unknown> = {};
    createRoot(dispose => {
      disposals.push(dispose);
      const pending = createMemo(() => isPending(input));
      const reads: Record<string, () => unknown> = {
        x,
        pending,
        latestPending: () => latest(() => isPending(input)),
        latestPendingMemo: () => latest(pending),
        pendingLatest: () => isPending(() => latest(input)),
        latestLatestPending: () => latest(() => latest(() => isPending(input))),
        pendingPending: () => isPending(() => isPending(input))
      };
      for (const [key, read] of Object.entries(reads))
        createRenderEffect(read, value => {
          shown[key] = value;
        });
    });
    flush();
    const running = action(function* () {
      setX(1);
      yield end.promise;
    })();
    flush();
    expect(shown).toEqual({
      x: 0,
      pending: true,
      latestPending: true,
      latestPendingMemo: true,
      pendingLatest: false,
      latestLatestPending: true,
      pendingPending: false
    });
    end.resolve();
    await running;
    await turn();
    expect(shown).toEqual({
      x: 1,
      pending: false,
      latestPending: false,
      latestPendingMemo: false,
      pendingLatest: false,
      latestLatestPending: false,
      pendingPending: false
    });
  });

  it(`latest of pending has its own coherent publication (wrapped=${wrapped})`, async () => {
    const end = gate<void>(),
      pendingWork = gate<boolean>(),
      latestWork = gate<boolean>();
    const [x, setX] = createSignal(0),
      [tick, setTick] = createSignal(0);
    const input = wrapped ? () => x() : x;
    const pending = () => isPending(input);
    const ahead = () => latest(pending);
    const shown = {
      pending: false,
      pendingDetails: false,
      ahead: false,
      aheadDetails: false,
      late: false
    };
    createRoot(dispose => {
      disposals.push(dispose);
      const details = createMemo(() => (pending() ? pendingWork.promise : false));
      const aheadDetails = createMemo(() => (ahead() ? latestWork.promise : false));
      createRenderEffect(pending, value => {
        shown.pending = value;
      });
      createRenderEffect(details, value => {
        shown.pendingDetails = value;
      });
      createRenderEffect(
        () => {
          tick();
          return ahead();
        },
        value => {
          shown.ahead = value;
        }
      );
      createRenderEffect(aheadDetails, value => {
        shown.aheadDetails = value;
      });
    });
    flush();
    const running = action(function* () {
      setX(1);
      yield end.promise;
    })();
    flush();
    expect(shown).toEqual({
      pending: false,
      pendingDetails: false,
      ahead: false,
      aheadDetails: false,
      late: false
    });
    setTick(1);
    flush();
    createRoot(dispose => {
      disposals.push(dispose);
      createRenderEffect(ahead, value => {
        shown.late = value;
      });
    });
    flush();
    expect(ahead()).toBe(false);
    expect(shown).toEqual({
      pending: false,
      pendingDetails: false,
      ahead: false,
      aheadDetails: false,
      late: false
    });
    latestWork.resolve(true);
    await turn();
    expect(shown).toEqual({
      pending: false,
      pendingDetails: false,
      ahead: true,
      aheadDetails: true,
      late: true
    });
    expect(x()).toBe(0);
    pendingWork.resolve(true);
    await turn();
    expect(shown).toEqual({
      pending: true,
      pendingDetails: true,
      ahead: true,
      aheadDetails: true,
      late: true
    });
    end.resolve();
    await running;
    await turn();
    expect(shown).toEqual({
      pending: false,
      pendingDetails: false,
      ahead: false,
      aheadDetails: false,
      late: false
    });
  });

  it(`ending the input supersedes suspended nested observation work (wrapped=${wrapped})`, async () => {
    const end = gate<void>(),
      pendingWork = gate<boolean>(),
      latestWork = gate<boolean>();
    const [x, setX] = createSignal(0);
    const input = wrapped ? () => x() : x;
    const pending = () => isPending(input);
    const ahead = () => latest(pending);
    const shown = {
      x: 0,
      pending: false,
      pendingDetails: false,
      ahead: false,
      aheadDetails: false,
      pendingPending: false
    };
    createRoot(dispose => {
      disposals.push(dispose);
      const details = createMemo(() => (pending() ? pendingWork.promise : false));
      const aheadDetails = createMemo(() => (ahead() ? latestWork.promise : false));
      createRenderEffect(x, value => {
        shown.x = value;
      });
      createRenderEffect(pending, value => {
        shown.pending = value;
      });
      createRenderEffect(details, value => {
        shown.pendingDetails = value;
      });
      createRenderEffect(ahead, value => {
        shown.ahead = value;
      });
      createRenderEffect(aheadDetails, value => {
        shown.aheadDetails = value;
      });
      createRenderEffect(
        () => isPending(pending),
        value => {
          shown.pendingPending = value;
        }
      );
    });
    flush();
    const running = action(function* () {
      setX(1);
      yield end.promise;
    })();
    flush();
    expect(shown).toEqual({
      x: 0,
      pending: false,
      pendingDetails: false,
      ahead: false,
      aheadDetails: false,
      pendingPending: true
    });
    // The pending-of-pending output occupies the next context. It can report
    // the held true proposal while the lower observation and its async work
    // retain their committed false frame. Sharing a flush does not join them.
    end.resolve();
    await running;
    await turn();
    const completed = {
      x: 1,
      pending: false,
      pendingDetails: false,
      ahead: false,
      aheadDetails: false,
      pendingPending: false
    };
    expect(shown).toEqual(completed);
    pendingWork.resolve(true);
    latestWork.resolve(true);
    await turn();
    expect(shown).toEqual(completed);
  });
}

it("a thrown nested callback restores the enclosing observation and ordinary reads", async () => {
  const end = gate<void>();
  const [x, setX] = createSignal(0);
  let shown = "";
  createRoot(dispose => {
    disposals.push(dispose);
    createRenderEffect(
      () => {
        const ahead = latest(() => {
          try {
            latest(() => {
              isPending(() => x());
              throw new Error("callback");
            });
          } catch {}
          return x();
        });
        return `${ahead}/${x()}`;
      },
      value => {
        shown = value;
      }
    );
  });
  flush();
  const running = action(function* () {
    setX(1);
    yield end.promise;
  })();
  flush();
  expect(shown).toBe("1/0");
  expect(x()).toBe(0);
  end.resolve();
  await running;
  await turn();
  expect(shown).toBe("1/1");
});

for (const memoWrapped of [false, true])
  it(`pending of pending observes a held boolean without consuming its proposal (memoWrapped=${memoWrapped})`, async () => {
    const end = gate<void>(),
      work = gate<boolean>();
    const [x, setX] = createSignal(0);
    let pending!: () => boolean;
    const shown = { value: false, details: false, pending: false };
    createRoot(dispose => {
      disposals.push(dispose);
      pending = memoWrapped ? createMemo(() => isPending(x)) : () => isPending(x);
      const details = createMemo(() => (pending() ? work.promise : false));
      createRenderEffect(pending, value => {
        shown.value = value;
      });
      createRenderEffect(details, value => {
        shown.details = value;
      });
      createRenderEffect(
        () => isPending(pending),
        value => {
          shown.pending = value;
        }
      );
    });
    flush();
    const running = action(function* () {
      setX(1);
      yield end.promise;
    })();
    flush();
    expect(shown).toEqual({ value: false, details: false, pending: true });
    work.resolve(true);
    await turn();
    expect(shown).toEqual({ value: true, details: true, pending: false });
    end.resolve();
    await running;
    await turn();
    expect(shown).toEqual({ value: false, details: false, pending: false });
  });
