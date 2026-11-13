import { expect, it } from "vitest";
import {
  action,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  createStore,
  flush
} from "../src/index.js";

const turn = async () => {
  await new Promise(resolve => setTimeout(resolve, 0));
  flush();
};

for (const answerFirst of [true, false]) {
  it(`discards an ordinary chained child's initial write and retains its action (${answerFirst})`, async () => {
    const answer = Promise.withResolvers<{ name: string }>();
    const end = Promise.withResolvers<void>();
    const shown: string[] = [];
    const flags: number[] = [];
    let calls = 0;
    const [outer, setOuter, dispose] = createRoot(dispose => {
      const [child] = createOptimisticStore(() => answer.promise, { name: "seed" });
      const [outer, setOuter] = createStore(() => {}, { child, flag: 0 });
      createRenderEffect(
        () => outer.child.name,
        value => {
          shown.push(value);
        }
      );
      createRenderEffect(
        () => outer.flag,
        value => {
          flags.push(value);
        }
      );
      return [outer, setOuter, dispose] as const;
    });
    let running: Promise<unknown> | undefined;
    try {
      flush();
      expect(shown).toEqual([]);
      running = action(function* () {
        setOuter(draft => {
          calls++;
          draft.child.name = "discarded";
          draft.flag = 1;
        });
        yield end.promise;
      })();
      await turn();
      expect(calls).toBe(1);
      expect(shown).toEqual([]);
      if (answerFirst) {
        answer.resolve({ name: "answer" });
        await turn();
        expect(shown).toEqual([]);
        expect(flags).toEqual([0]);
        end.resolve();
      } else {
        end.resolve();
        await running;
        await turn();
        expect(shown).toEqual([]);
        answer.resolve({ name: "answer" });
      }
      await running;
      await turn();
      expect(shown).toEqual(["answer"]);
      expect(flags).toEqual([0, 1]);
      expect(outer.child.name).toBe("answer");
    } finally {
      answer.resolve({ name: "answer" });
      end.resolve();
      await Promise.allSettled(running ? [running] : []);
      dispose();
      flush();
    }
  });
}

it("keeps a synchronous derived store write before its first flush", () => {
  const [state, setState, dispose] = createRoot(dispose => {
    const [state, setState] = createStore(
      draft => {
        draft.name = "ready";
      },
      { name: "seed" }
    );
    return [state, setState, dispose] as const;
  });
  try {
    setState(draft => {
      draft.name = "written";
    });
    flush();
    expect(state.name).toBe("written");
  } finally {
    dispose();
    flush();
  }
});

for (const optimistic of [false, true])
  for (const answerFirst of [false, true]) {
    for (const replacement of [false, true]) {
      it(`discards initial ${optimistic ? "optimistic" : "ordinary"} root proposals (${answerFirst}, replacement ${replacement})`, async () => {
        const answer = Promise.withResolvers<string[]>();
        const end = Promise.withResolvers<void>();
        const shown: string[][] = [];
        let calls = 0;
        const [rows, setRows, dispose] = createRoot(dispose => {
          const factory = optimistic ? createOptimisticStore : createStore;
          const [rows, setRows] = factory(() => answer.promise, ["seed"]);
          createRenderEffect(
            () => Array.from(rows),
            value => {
              shown.push(value);
            }
          );
          return [rows, setRows, dispose] as const;
        });
        let running: Promise<unknown> | undefined;
        try {
          flush();
          running = action(function* () {
            setRows(draft => {
              calls++;
              if (replacement) return ["discarded"];
              draft.push("discarded");
            });
            yield end.promise;
          })();
          await turn();
          expect(calls).toBe(1);
          expect(shown).toEqual([]);
          if (answerFirst) {
            answer.resolve(["answer"]);
            await turn();
            expect(shown).toEqual([]);
            end.resolve();
          } else {
            end.resolve();
            await running;
            await turn();
            expect(shown).toEqual([]);
            answer.resolve(["answer"]);
          }
          await running;
          await turn();
          expect(shown).toEqual([["answer"]]);
          expect(Array.from(rows)).toEqual(["answer"]);
        } finally {
          answer.resolve(["answer"]);
          end.resolve();
          await Promise.allSettled(running ? [running] : []);
          dispose();
          flush();
        }
      });
    }
  }

for (const optimistic of [false, true]) {
  it(`keeps a late reader loading and restores the first answer after a failed ${optimistic ? "optimistic" : "ordinary"} draft`, async () => {
    const answer = Promise.withResolvers<{ name: string; nested: { value: string } }>();
    const end = Promise.withResolvers<void>();
    const shown: unknown[] = [];
    let calls = 0;
    const [state, setState, dispose] = createRoot(dispose => {
      const factory = optimistic ? createOptimisticStore : createStore;
      const [state, setState] = factory(() => answer.promise, {
        name: "seed",
        nested: { value: "seed" }
      });
      return [state, setState, dispose] as const;
    });
    let running: Promise<unknown> | undefined;
    let unmount: (() => void) | undefined;
    try {
      flush();
      running = action(function* () {
        setState(draft => {
          calls++;
          draft.name = "discarded";
        });
        yield end.promise;
      })();
      await turn();
      answer.resolve({ name: "answer", nested: { value: "answer" } });
      await turn();
      expect(() =>
        setState(draft => {
          calls++;
          draft.name = "failed";
          draft.nested.value = "failed";
          throw new Error("callback failed");
        })
      ).toThrow("callback failed");
      unmount = createRoot(dispose => {
        createRenderEffect(
          () => [state.name, state.nested.value],
          value => {
            shown.push(value);
          }
        );
        return dispose;
      });
      flush();
      expect(shown).toEqual([]);
      expect(calls).toBe(2);
      end.resolve();
      await running;
      await turn();
      expect(shown).toEqual([["answer", "answer"]]);
    } finally {
      answer.resolve({ name: "answer", nested: { value: "answer" } });
      end.resolve();
      await Promise.allSettled(running ? [running] : []);
      unmount?.();
      dispose();
      flush();
    }
  });
}

it("retains explicit seedLoadingValue commit zero as an optimistic value", async () => {
  const answer = Promise.withResolvers<string[]>();
  const end = Promise.withResolvers<void>();
  const shown: string[][] = [];
  const [rows, setRows, dispose] = createRoot(dispose => {
    const [rows, setRows] = createOptimisticStore(() => answer.promise, ["seed"], {
      seedLoadingValue: true
    });
    createRenderEffect(
      () => Array.from(rows),
      value => {
        shown.push(value);
      }
    );
    return [rows, setRows, dispose] as const;
  });
  let running: Promise<unknown> | undefined;
  try {
    flush();
    running = action(function* () {
      setRows(draft => {
        draft.push("shown");
      });
      yield end.promise;
    })();
    await turn();
    expect(shown).toEqual([["seed"], ["seed", "shown"]]);
    end.resolve();
    await running;
    answer.resolve(["answer"]);
    await turn();
    expect(Array.from(rows)).toEqual(["answer"]);
  } finally {
    answer.resolve(["answer"]);
    end.resolve();
    await Promise.allSettled(running ? [running] : []);
    dispose();
    flush();
  }
});

for (const observed of [false, true]) {
  it(`retains existing observedness after an initial write action ends (${observed})`, async () => {
    const answer = Promise.withResolvers<{ name: string }>();
    const end = Promise.withResolvers<void>();
    const flags: number[] = [];
    const [setState, setFlag, dispose] = createRoot(dispose => {
      const [state, setState] = createOptimisticStore(() => answer.promise, { name: "seed" });
      const [flag, setFlag] = createSignal(0);
      createRenderEffect(flag, value => {
        flags.push(value);
      });
      if (observed)
        createRenderEffect(
          () => state.name,
          () => {}
        );
      return [setState, setFlag, dispose] as const;
    });
    let running: Promise<unknown> | undefined;
    try {
      flush();
      running = action(function* () {
        setState(draft => {
          draft.name = "discarded";
        });
        setFlag(1);
        yield end.promise;
      })();
      await turn();
      expect(flags).toEqual([0]);
      end.resolve();
      await running;
      await turn();
      expect(flags).toEqual(observed ? [0] : [0, 1]);
      answer.resolve({ name: "answer" });
      await turn();
      expect(flags).toEqual([0, 1]);
    } finally {
      answer.resolve({ name: "answer" });
      end.resolve();
      await Promise.allSettled(running ? [running] : []);
      dispose();
      flush();
    }
  });
}

it("joins repeated initial writes from separate actions until both actions finish", async () => {
  const answer = Promise.withResolvers<{ name: string }>();
  const firstEnd = Promise.withResolvers<void>();
  const secondEnd = Promise.withResolvers<void>();
  const shown: string[] = [];
  let calls = 0;
  const [setState, dispose] = createRoot(dispose => {
    const [state, setState] = createOptimisticStore(() => answer.promise, { name: "seed" });
    createRenderEffect(
      () => state.name,
      value => {
        shown.push(value);
      }
    );
    return [setState, dispose] as const;
  });
  const writes = [firstEnd, secondEnd].map(end =>
    action(function* () {
      setState(draft => {
        calls++;
        draft.name = "discarded";
      });
      yield end.promise;
    })
  );
  let running: Promise<unknown>[] = [];
  try {
    flush();
    running.push(writes[0]());
    await turn();
    running.push(writes[1]());
    await turn();
    answer.resolve({ name: "answer" });
    await turn();
    expect(shown).toEqual([]);
    firstEnd.resolve();
    await running[0];
    await turn();
    expect(shown).toEqual([]);
    secondEnd.resolve();
    await running[1];
    await turn();
    expect(calls).toBe(2);
    expect(shown).toEqual(["answer"]);
  } finally {
    answer.resolve({ name: "answer" });
    firstEnd.resolve();
    secondEnd.resolve();
    await Promise.allSettled(running);
    dispose();
    flush();
  }
});

it("discards two loading chained children but retains the outer setter's ordinary write", async () => {
  const a = Promise.withResolvers<{ name: string }>();
  const b = Promise.withResolvers<{ name: string }>();
  const end = Promise.withResolvers<void>();
  const shown: string[][] = [];
  const flags: number[] = [];
  const [setOuter, dispose] = createRoot(dispose => {
    const [first] = createOptimisticStore(() => a.promise, { name: "seed-a" });
    const [second] = createOptimisticStore(() => b.promise, { name: "seed-b" });
    const [outer, setOuter] = createStore(() => {}, { first, second, flag: 0 });
    createRenderEffect(
      () => [outer.first.name, outer.second.name],
      value => {
        shown.push(value);
      }
    );
    createRenderEffect(
      () => outer.flag,
      value => {
        flags.push(value);
      }
    );
    return [setOuter, dispose] as const;
  });
  let running: Promise<unknown> | undefined;
  try {
    flush();
    running = action(function* () {
      setOuter(draft => {
        draft.first.name = "discard-a";
        draft.second.name = "discard-b";
        draft.flag = 1;
      });
      yield end.promise;
    })();
    await turn();
    a.resolve({ name: "a" });
    b.resolve({ name: "b" });
    await turn();
    expect(shown).toEqual([]);
    expect(flags).toEqual([0]);
    end.resolve();
    await running;
    await turn();
    expect(shown).toEqual([["a", "b"]]);
    expect(flags).toEqual([0, 1]);
  } finally {
    a.resolve({ name: "a" });
    b.resolve({ name: "b" });
    end.resolve();
    await Promise.allSettled(running ? [running] : []);
    dispose();
    flush();
  }
});

for (const failAction of [false, true]) {
  it(`discards an initial setter with ${failAction ? "a failed action" : "no action"}`, async () => {
    const answer = Promise.withResolvers<{ name: string }>();
    const end = Promise.withResolvers<void>();
    const shown: string[] = [];
    const [setState, dispose] = createRoot(dispose => {
      const [state, setState] = createOptimisticStore(() => answer.promise, { name: "seed" });
      createRenderEffect(
        () => state.name,
        value => {
          shown.push(value);
        }
      );
      return [setState, dispose] as const;
    });
    let running: Promise<unknown> | undefined;
    try {
      flush();
      if (failAction) {
        running = action(function* () {
          setState(draft => {
            draft.name = "discarded";
          });
          yield end.promise;
          throw new Error("action failed");
        })();
        const rejected = expect(running).rejects.toThrow("action failed");
        await turn();
        end.resolve();
        await rejected;
      } else
        setState(draft => {
          draft.name = "discarded";
        });
      await turn();
      expect(shown).toEqual([]);
      answer.resolve({ name: "answer" });
      await turn();
      expect(shown).toEqual(["answer"]);
    } finally {
      answer.resolve({ name: "answer" });
      end.resolve();
      await Promise.allSettled(running ? [running] : []);
      dispose();
      flush();
    }
  });
}
