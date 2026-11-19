import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  latest
} from "../src/index.js";

const turn = async () => {
  await new Promise<void>(resolve => setTimeout(resolve, 0));
  flush();
};

for (const asyncInput of [false, true])
  for (const wrapped of [false, true])
    for (const asyncConsequence of [false, true])
      it(`latest exposes a ready first held value (async input=${asyncInput}, wrapped=${wrapped}, async consequence=${asyncConsequence})`, async () => {
        const end = Promise.withResolvers<void>();
        const answer = Promise.withResolvers<void>();
        const consequence = Promise.withResolvers<void>();
        const [tick, setTick] = createSignal(0);
        let late: number | undefined;
        let disposeReader: (() => void) | undefined;
        let output!: () => number;
        const [source, setSource] = createSignal(0);
        let inputShown = 0;
        let preview: number | undefined;
        let doubled: number | undefined;
        const dispose = createRoot(dispose => {
          createRenderEffect(source, value => {
            inputShown = value;
          });
          return dispose;
        });
        flush();
        const running = action(function* () {
          setSource(1);
          yield end.promise;
        })();
        flush();
        const disposeLate = createRoot(dispose => {
          const born = createMemo(() => {
            const value = source();
            return asyncInput ? answer.promise.then(() => value) : value;
          });
          output = wrapped ? createMemo(() => latest(born)) : () => latest(born);
          const twice = createMemo(() => {
            const value = output() * 2;
            return asyncConsequence ? consequence.promise.then(() => value) : value;
          });
          createRenderEffect(
            () => {
              tick();
              return output();
            },
            value => {
              preview = value;
            },
            { schedule: true }
          );
          createRenderEffect(
            twice,
            value => {
              doubled = value;
            },
            { schedule: true }
          );
          return dispose;
        });
        try {
          flush();
          if (asyncInput) {
            expect([inputShown, preview, doubled]).toEqual([0, undefined, undefined]);
            answer.resolve();
            await turn();
          }
          if (asyncConsequence) {
            expect([inputShown, preview, doubled]).toEqual([0, undefined, undefined]);
            setTick(1);
            disposeReader = createRoot(dispose => {
              createRenderEffect(
                output,
                value => {
                  late = value;
                },
                { schedule: true }
              );
              return dispose;
            });
            flush();
            // A synchronous first read initializes the output before the new
            // async reader exists. Like an ordinary initialized memo (control
            // below), it can serve that value to a subsequent independent
            // mount. An async first answer is still an unpublished proposal.
            expect([inputShown, preview, doubled, late]).toEqual(
              asyncInput ? [0, undefined, undefined, undefined] : [0, 1, undefined, 1]
            );
            consequence.resolve();
            await turn();
            expect(late).toBe(1);
          }
          expect([inputShown, preview, doubled]).toEqual([0, 1, 2]);
          end.resolve();
          await running;
          await turn();
          expect([inputShown, preview, doubled]).toEqual([1, 1, 2]);
        } finally {
          disposeReader?.();
          disposeLate();
          dispose();
          answer.resolve();
          consequence.resolve();
          end.resolve();
          await running;
          await turn();
        }
      });

// Compare the initialized-first-value case above to ordinary propagation.
it("an initialized ordinary memo can serve a later reader while a new async reader loads", async () => {
  const [source] = createSignal(1);
  const [tick, setTick] = createSignal(0);
  const answer = Promise.withResolvers<void>();
  let preview: number | undefined, doubled: number | undefined, late: number | undefined;
  let output!: () => number;
  const dispose = createRoot(dispose => {
    output = createMemo(source);
    const twice = createMemo(() => {
      const value = output() * 2;
      return answer.promise.then(() => value);
    });
    createRenderEffect(
      () => {
        tick();
        return output();
      },
      value => {
        preview = value;
      },
      { schedule: true }
    );
    createRenderEffect(
      twice,
      value => {
        doubled = value;
      },
      { schedule: true }
    );
    return dispose;
  });
  let disposeLate: (() => void) | undefined;
  try {
    flush();
    expect([preview, doubled]).toEqual([undefined, undefined]);
    setTick(1);
    disposeLate = createRoot(dispose => {
      createRenderEffect(
        output,
        value => {
          late = value;
        },
        { schedule: true }
      );
      return dispose;
    });
    flush();
    expect([preview, doubled, late]).toEqual([1, undefined, 1]);
    answer.resolve();
    await turn();
    expect([preview, doubled, late]).toEqual([1, 2, 1]);
  } finally {
    disposeLate?.();
    dispose();
    answer.resolve();
    await turn();
  }
});

it("a superseded first latest proposal cannot publish through its old async consequence", async () => {
  const end = Promise.withResolvers<void>();
  const [source, setSource] = createSignal(0);
  const consequences = new Map<number, ReturnType<typeof Promise.withResolvers<number>>>();
  let outside = 0,
    preview: number | undefined,
    doubled: number | undefined;
  const dispose = createRoot(dispose => {
    createRenderEffect(source, value => {
      outside = value;
    });
    return dispose;
  });
  flush();
  const running = action(function* () {
    setSource(1);
    yield end.promise;
  })();
  flush();
  const disposeLate = createRoot(dispose => {
    const born = createMemo(async () => source());
    const output = createMemo(() => latest(born));
    const twice = createMemo(() => {
      const value = output();
      const request = Promise.withResolvers<number>();
      consequences.set(value, request);
      return request.promise;
    });
    createRenderEffect(
      output,
      value => {
        preview = value;
      },
      { schedule: true }
    );
    createRenderEffect(
      twice,
      value => {
        doubled = value;
      },
      { schedule: true }
    );
    return dispose;
  });
  try {
    await turn();
    expect(consequences.has(1)).toBe(true);
    expect([outside, preview, doubled]).toEqual([0, undefined, undefined]);
    setSource(2);
    await turn();
    expect(consequences.has(2)).toBe(true);
    consequences.get(1)!.resolve(2);
    await turn();
    expect([outside, preview, doubled]).toEqual([0, undefined, undefined]);
    consequences.get(2)!.resolve(4);
    await turn();
    expect([outside, preview, doubled]).toEqual([0, 2, 4]);
    end.resolve();
    await running;
    await turn();
    expect([outside, preview, doubled]).toEqual([2, 2, 4]);
  } finally {
    disposeLate();
    dispose();
    end.resolve();
    for (const [value, request] of consequences) request.resolve(value * 2);
    await running;
    await turn();
  }
});
