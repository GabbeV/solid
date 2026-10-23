import { expect, it } from "vitest";
import {
  action,
  createErrorBoundary,
  createMemo,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  createStore,
  isPending
} from "../../src/index.js";

const delay = () => new Promise<void>(resolve => setTimeout(resolve, 20));

it("shows the same optimistic leaf through its root and a retained row while the source is pending", async () => {
  let direct = -1;
  let retained = -1;
  let refresh!: () => void;
  let update!: () => void;
  let complete!: (rows: { value: number }[]) => void;
  let dispose!: () => void;
  let pending!: () => boolean;

  createRoot(d => {
    dispose = d;
    const [refreshing, setRefreshing] = createSignal(false);
    const remote = createMemo(() =>
      refreshing()
        ? new Promise<{ value: number }[]>(resolve => {
            complete = resolve;
          })
        : [{ value: 0 }]
    );
    const [local, setLocal] = createStore(() => remote(), []);
    const [items, setOptimistic] = createOptimisticStore(local);
    const row = items[0];
    pending = () => isPending(() => items[0].value);

    createRenderEffect(
      () => items[0].value,
      value => {
        direct = value;
      }
    );
    createRenderEffect(
      () => row.value,
      value => {
        retained = value;
      }
    );

    refresh = () => setRefreshing(true);
    update = () => {
      setLocal(draft => {
        draft[0].value = 1;
      });
      setOptimistic(draft => {
        draft[0].value = 1;
      });
    };
  });

  try {
    await delay();
    expect([direct, retained]).toEqual([0, 0]);
    refresh();
    await delay();
    update();
    await delay();
    expect([direct, retained]).toEqual([1, 1]);
    expect(pending()).toBe(true);
    complete([{ value: 0 }]);
    await delay();
    expect([direct, retained]).toEqual([0, 0]);
  } finally {
    dispose();
  }
});

it("also reaches the optimistic leaf when the root path is first observed during the pending refresh", async () => {
  let direct = -1;
  let retained = -1;
  let refresh!: () => void;
  let update!: () => void;
  let mount!: () => void;
  let complete!: (rows: { value: number }[]) => void;
  let dispose!: () => void;
  let disposeMounted: (() => void) | undefined;
  let finishAction!: () => void;
  let acting: Promise<unknown> | undefined;

  createRoot(d => {
    dispose = d;
    const [refreshing, setRefreshing] = createSignal(false);
    const remote = createMemo(() =>
      refreshing()
        ? new Promise<{ value: number }[]>(resolve => {
            complete = resolve;
          })
        : [{ value: 0 }]
    );
    const [local, setLocal] = createStore(() => remote(), []);
    const [items, setOptimistic] = createOptimisticStore(local);
    const row = items[0];
    createRenderEffect(
      () => row.value,
      value => {
        retained = value;
      }
    );
    refresh = () => setRefreshing(true);
    const write = action(function* () {
      setLocal(draft => {
        draft[0].value = 1;
      });
      setOptimistic(draft => {
        draft[0].value = 1;
      });
      yield new Promise<void>(resolve => {
        finishAction = resolve;
      });
    });
    update = () => {
      acting = write();
    };
    mount = () =>
      createRoot(d => {
        disposeMounted = d;
        createRenderEffect(
          () => items[0].value,
          value => {
            direct = value;
          }
        );
      });
  });

  try {
    await delay();
    refresh();
    await delay();
    update();
    await delay();
    mount();
    await delay();
    expect([direct, retained]).toEqual([1, 1]);
    complete([{ value: 0 }]);
    finishAction();
    await acting;
    await delay();
    expect([direct, retained]).toEqual([0, 0]);
  } finally {
    disposeMounted?.();
    dispose();
  }
});

it("does not publish underlying local writes or unguessed sibling fields through the optimistic view", async () => {
  let base = -1;
  let guessed = -1;
  let sibling = -1;
  let refresh!: () => void;
  let update!: () => void;
  let complete!: (rows: { value: number }[]) => void;
  let dispose!: () => void;

  createRoot(d => {
    dispose = d;
    const [refreshing, setRefreshing] = createSignal(false);
    const remote = createMemo(() =>
      refreshing()
        ? new Promise<{ value: number }[]>(resolve => {
            complete = resolve;
          })
        : [{ value: 0 }, { value: 0 }]
    );
    const [local, setLocal] = createStore(() => remote(), []);
    const [items, setOptimistic] = createOptimisticStore(local);
    createRenderEffect(
      () => local[0].value,
      value => {
        base = value;
      }
    );
    createRenderEffect(
      () => items[0].value,
      value => {
        guessed = value;
      }
    );
    createRenderEffect(
      () => items[1].value,
      value => {
        sibling = value;
      }
    );
    refresh = () => setRefreshing(true);
    update = () => {
      setLocal(draft => {
        draft[0].value = 1;
        draft[1].value = 2;
      });
      setOptimistic(draft => {
        draft[0].value = 1;
      });
    };
  });

  try {
    await delay();
    refresh();
    await delay();
    update();
    await delay();
    expect([base, guessed, sibling]).toEqual([0, 1, 0]);
    complete([{ value: 0 }, { value: 0 }]);
    await delay();
    expect([base, guessed, sibling]).toEqual([0, 0, 0]);
  } finally {
    dispose();
  }
});

it("does not redirect a retained row's guess to another row at its held array slot", async () => {
  type Row = { id: string; value: number };
  let direct = -1;
  let retained = -1;
  let refresh!: () => void;
  let update!: () => void;
  let complete!: (rows: Row[]) => void;
  let dispose!: () => void;

  createRoot(d => {
    dispose = d;
    const [refreshing, setRefreshing] = createSignal(false);
    const remote = createMemo(() =>
      refreshing()
        ? new Promise<Row[]>(resolve => {
            complete = resolve;
          })
        : [
            { id: "A", value: 0 },
            { id: "B", value: 0 }
          ]
    );
    const [local, setLocal] = createStore(() => remote(), []);
    const [items, setOptimistic] = createOptimisticStore(local);
    const row = items[0];
    createRenderEffect(
      () => items[0].value,
      value => {
        direct = value;
      }
    );
    createRenderEffect(
      () => row.value,
      value => {
        retained = value;
      }
    );
    refresh = () => setRefreshing(true);
    update = () => {
      setLocal(draft => {
        draft.splice(0, 1);
      });
      setOptimistic(draft => {
        expect(draft[0].id).toBe("A");
        draft[0].value = 1;
      });
    };
  });

  try {
    await delay();
    refresh();
    await delay();
    update();
    await delay();
    expect([direct, retained]).toEqual([0, 1]);
    complete([{ id: "B", value: 0 }]);
    await delay();
    expect(direct).toBe(0);
  } finally {
    dispose();
  }
});

it("still exposes a source failure after showing the optimistic child", async () => {
  let shown = "";
  let refresh!: () => void;
  let update!: () => void;
  let fail!: (error: Error) => void;
  let dispose!: () => void;

  createRoot(d => {
    dispose = d;
    const [refreshing, setRefreshing] = createSignal(false);
    const remote = createMemo(() =>
      refreshing()
        ? new Promise<{ value: number }[]>((_resolve, reject) => {
            fail = reject;
          })
        : [{ value: 0 }]
    );
    const [local, setLocal] = createStore(() => remote(), []);
    const [items, setOptimistic] = createOptimisticStore(local);
    const view = createErrorBoundary(
      () => () => String(items[0].value),
      () => () => "error"
    );
    createRenderEffect(
      () => {
        let value: any = view();
        while (typeof value === "function") value = value();
        return String(value);
      },
      value => {
        shown = value;
      }
    );
    refresh = () => setRefreshing(true);
    update = () => {
      setLocal(draft => {
        draft[0].value = 1;
      });
      setOptimistic(draft => {
        draft[0].value = 1;
      });
    };
  });

  try {
    await delay();
    refresh();
    await delay();
    update();
    await delay();
    expect(shown).toBe("1");
    fail(new Error("source failed"));
    await delay();
    expect(shown).toBe("error");
  } finally {
    dispose();
  }
});
