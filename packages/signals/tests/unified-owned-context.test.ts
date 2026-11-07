/** @vitest-environment jsdom */
import { afterEach, expect, it } from "vitest";
import { $REFRESH } from "../src/core/constants.js";
import {
  action,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  onCleanup
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
function gate<T = void>() {
  let resolve!: (value: T) => void;
  const promise = new Promise<T>(yes => {
    resolve = yes;
  });
  return { promise, resolve };
}
const disposals: (() => void)[] = [];
afterEach(() => {
  for (const dispose of disposals.splice(0)) dispose();
  document.body.replaceChildren();
  flush();
});

for (const depth of [0, 3])
  for (const order of ["guess-first", "mount-first", "together"] as const)
    for (const asyncChild of [false, true])
      it(`an unpublished owned frame keeps its context (${order}, async child=${asyncChild}, depth=${depth})`, async () => {
        const guessEnd = gate(),
          mountEnd = gate(),
          answer = gate<number>(),
          childAnswer = gate();
        const [mount, setMount] = createSignal(false);
        const host = document.createElement("main");
        document.body.append(host);
        const shown = { view: 0, detail: 0, mount: false };
        const frames: { cleaned: number }[] = [];
        const calculations: number[][] = [];
        let guess!: (value: number) => unknown;
        createRoot(dispose => {
          disposals.push(dispose);
          const [view, write] = createOptimistic(() => 0);
          guess = write;
          const detail = createMemo(() => (view() ? answer.promise : 0));
          const owner = createMemo(() => {
            const mounted = mount();
            const element = document.createElement("span");
            const frame = { cleaned: 0 };
            frames.push(frame);
            onCleanup(() => {
              frame.cleaned++;
            });
            if (mounted) {
              const nested = (remaining: number): number =>
                remaining ? createMemo(() => nested(remaining - 1))() : view();
              const child = createMemo(() => {
                const values = [+mounted, +mount(), nested(depth)];
                calculations.push(values);
                return asyncChild && values[2]
                  ? childAnswer.promise.then(() => values.join(":"))
                  : values.join(":");
              });
              createRenderEffect(
                child,
                value => {
                  element.textContent = value;
                },
                { schedule: true }
              );
            }
            return element;
          });
          createRenderEffect(
            owner,
            element => {
              host.replaceChildren(element);
            },
            { schedule: true }
          );
          for (const [key, read] of Object.entries({ view, detail, mount }))
            createRenderEffect<unknown>(
              read,
              value => {
                (shown as any)[key] = value;
              },
              { schedule: true }
            );
        });
        flush();
        const guessing = action(function* () {
          guess(1);
          yield guessEnd.promise;
        })();
        flush();
        const mounting = action(function* () {
          setMount(true);
          yield mountEnd.promise;
        })();
        flush();
        expect([shown, host.textContent]).toEqual([{ view: 0, detail: 0, mount: false }, ""]);
        if (order !== "mount-first") answer.resolve(1);
        if (order !== "guess-first") mountEnd.resolve();
        await turn();
        flush();
        if (order === "guess-first") {
          expect([shown, host.textContent]).toEqual([{ view: 1, detail: 1, mount: false }, ""]);
          mountEnd.resolve();
        } else if (order === "mount-first") {
          // This private frame has calculated the higher proposal. Its
          // publication waits without joining the optimistic action lifetime.
          expect([shown, host.textContent]).toEqual([{ view: 0, detail: 0, mount: false }, ""]);
          answer.resolve(1);
        }
        await mounting;
        await turn();
        flush();
        if (asyncChild) {
          // The private child holds its mounting frame, not the independent
          // guess. The guess can publish before this child's async completes.
          expect([shown, host.textContent]).toEqual([{ view: 1, detail: 1, mount: false }, ""]);
          childAnswer.resolve();
          await turn();
          flush();
        }
        expect([shown, host.textContent]).toEqual([{ view: 1, detail: 1, mount: true }, "1:1:1"]);
        expect(calculations.every(([captured, read]) => captured === read)).toBe(true);
        disposals.pop()!();
        expect(frames.every(frame => frame.cleaned === 1)).toBe(true);
        guessEnd.resolve();
        await guessing;
        await turn();
        flush();
      });

for (const supersede of [false, true])
  it(`retries a proposed owner using its still-visible input (supersede=${supersede})`, async () => {
    const guessEnd = gate(),
      ownerEnd = gate(),
      answer = gate<number>();
    const [generation, setGeneration] = createSignal(1);
    const host = document.createElement("main");
    document.body.append(host);
    const frames: { generation: number; cleaned: number }[] = [];
    const bodies: number[][] = [];
    let shown = 0,
      guess!: (value: number) => unknown;
    createRoot(dispose => {
      disposals.push(dispose);
      const [view, write] = createOptimistic(() => 0);
      guess = write;
      const detail = createMemo(() => (view() ? answer.promise : 0));
      const owner = createMemo(() => {
        const captured = generation();
        const frame = { generation: captured, cleaned: 0 };
        frames.push(frame);
        onCleanup(() => {
          frame.cleaned++;
        });
        const element = document.createElement("span");
        const child = createMemo(() => {
          const values = [captured, generation(), view()];
          bodies.push(values);
          return values.join(":");
        });
        createRenderEffect(
          child,
          value => {
            element.textContent = value;
          },
          { schedule: true }
        );
        return element;
      });
      createRenderEffect(
        owner,
        element => {
          host.replaceChildren(element);
        },
        { schedule: true }
      );
      createRenderEffect(
        detail,
        value => {
          shown = value;
        },
        { schedule: true }
      );
    });
    flush();
    const original = host.firstChild;
    const guessing = action(function* () {
      guess(1);
      yield guessEnd.promise;
    })();
    flush();
    const changing = action(function* () {
      setGeneration(2);
      yield ownerEnd.promise;
    })();
    flush();
    expect([shown, host.textContent]).toEqual([0, "1:1:0"]);
    answer.resolve(1);
    await turn();
    flush();
    expect([shown, host.textContent]).toEqual([1, "1:1:1"]);
    // The new child discovers the higher guess and retries its creator
    // against committed generation=1. It replaces the old frame coherently.
    expect(host.firstChild).not.toBe(original);
    expect(frames.find(frame => frame.generation === 1)!.cleaned).toBe(1);
    expect(frames.filter(frame => frame.cleaned === 0).map(frame => frame.generation)).toEqual([1]);
    if (supersede) {
      setGeneration(3);
      flush();
      expect(host.textContent).toBe("1:1:1");
      expect(
        frames.filter(frame => frame.generation === 2).every(frame => frame.cleaned === 1)
      ).toBe(true);
    }
    ownerEnd.resolve();
    await changing;
    await turn();
    flush();
    expect(host.textContent).toBe(supersede ? "3:3:1" : "2:2:1");
    expect(bodies.filter(([captured, read]) => captured !== read)).toEqual([]);
    disposals.pop()!();
    expect(frames.every(frame => frame.cleaned === 1)).toBe(true);
    guessEnd.resolve();
    await guessing;
    await turn();
    flush();
  });

for (const order of ["guess-first", "mount-first", "together"] as const)
  for (const readDetail of [false, true])
    for (const asyncChild of [false, true])
      it(`an unpublished child waits for first publication (${order}, detail=${readDetail}, async=${asyncChild})`, async () => {
        const initial = gate<number>(),
          answer = gate<number>(),
          mountEnd = gate(),
          guessEnd = gate(),
          childAnswer = gate();
        const [mount, setMount] = createSignal(false);
        const shown = {
          view: null as number | null,
          detail: null as number | null,
          mounted: false,
          child: null as number | null
        };
        const completed: number[] = [];
        let guess!: (value: number) => unknown;
        createRoot(dispose => {
          disposals.push(dispose);
          const source = createMemo(() => initial.promise);
          const [view, write] = createOptimistic(source);
          guess = write;
          const detail = createMemo(() => (view() ? answer.promise : 0));
          const owner = createMemo(() => {
            const mounted = mount();
            if (mounted) {
              const child = createMemo(() => {
                const value = readDetail ? detail() : view();
                completed.push(value);
                return asyncChild ? childAnswer.promise.then(() => value) : value;
              });
              createRenderEffect(
                child,
                value => {
                  shown.child = value;
                },
                { schedule: true }
              );
            }
            return mounted;
          });
          for (const [key, read] of Object.entries({ view, detail, mounted: owner }))
            createRenderEffect<unknown>(
              read,
              value => {
                (shown as any)[key] = value;
              },
              { schedule: true }
            );
        });
        flush();
        const guessing = action(function* () {
          guess(1);
          yield guessEnd.promise;
        })();
        flush();
        const mounting = action(function* () {
          setMount(true);
          yield mountEnd.promise;
        })();
        flush();
        // Discovering the optimistic context retries the creator. It sees
        // committed mount=false and removes the speculative child before
        // the child can complete, even if its proposed input is ready.
        expect(completed).toEqual([]);
        if (order !== "mount-first") answer.resolve(1);
        if (order !== "guess-first") mountEnd.resolve();
        await turn();
        flush();
        if (order === "guess-first") {
          expect(shown).toEqual({ view: 1, detail: 1, mounted: false, child: null });
          mountEnd.resolve();
        } else if (order === "mount-first") {
          expect(shown).toEqual({ view: null, detail: null, mounted: false, child: null });
          answer.resolve(1);
        }
        await mounting;
        await turn();
        flush();
        if (asyncChild) {
          expect(shown).toEqual({ view: 1, detail: 1, mounted: false, child: null });
          childAnswer.resolve();
          await turn();
          flush();
        }
        expect(shown).toEqual({ view: 1, detail: 1, mounted: true, child: 1 });
        expect(completed.length).toBeGreaterThan(0);
        expect(completed.every(value => value === 1)).toBe(true);
        disposals.pop()!();
        guessEnd.resolve();
        await guessing;
        await turn();
        flush();
      });

it("replaces unpublished first-value waiters without retaining their subscriptions", async () => {
  const initial = gate<number>(),
    answer = gate<number>(),
    mountEnd = gate(),
    guessEnd = gate();
  const [generation, setGeneration] = createSignal(0);
  const owners: { cleaned: number }[] = [];
  let detail!: () => number, guess!: (value: number) => unknown;
  let shownDetail: number | null = null,
    shownChild: number | null = null;
  createRoot(dispose => {
    disposals.push(dispose);
    const source = createMemo(() => initial.promise);
    const [view, write] = createOptimistic(source);
    guess = write;
    detail = createMemo(() => (view() ? answer.promise : 0));
    const owner = createMemo(() => {
      const current = generation();
      if (current) {
        const frame = { cleaned: 0 };
        owners.push(frame);
        onCleanup(() => {
          frame.cleaned++;
        });
        const child = createMemo(detail);
        createRenderEffect(
          child,
          value => {
            shownChild = value;
          },
          { schedule: true }
        );
      }
      return current;
    });
    createRenderEffect(
      detail,
      value => {
        shownDetail = value;
      },
      { schedule: true }
    );
    createRenderEffect(owner, () => {}, { schedule: true });
  });
  flush();
  const guessing = action(function* () {
    guess(1);
    yield guessEnd.promise;
  })();
  flush();
  const mounting = action(function* () {
    setGeneration(1);
    yield mountEnd.promise;
  })();
  flush();
  for (let value = 2; value <= 50; value++) {
    setGeneration(value);
    flush();
    // Each retry returns to committed generation=0, so no speculative
    // child remains alive between proposals.
    expect(owners.filter(owner => owner.cleaned === 0)).toHaveLength(0);
    let subscribers = 0;
    for (let edge = (detail as any)[$REFRESH]._subs; edge; edge = edge._nextSub) subscribers++;
    expect(subscribers).toBe(1);
  }
  expect([shownDetail, shownChild]).toEqual([null, null]);
  answer.resolve(1);
  await turn();
  flush();
  expect([shownDetail, shownChild]).toEqual([1, null]);
  mountEnd.resolve();
  await mounting;
  await turn();
  flush();
  expect([shownDetail, shownChild]).toEqual([1, 1]);
  // Fifty discarded proposals, followed by the committed frame.
  expect(owners).toHaveLength(51);
  expect(owners.filter(owner => owner.cleaned === 0)).toHaveLength(1);
  disposals.pop()!();
  expect(owners.every(owner => owner.cleaned === 1)).toBe(true);
  expect((detail as any)[$REFRESH]._subs).toBeNull();
  guessEnd.resolve();
  await guessing;
  await turn();
  flush();
});
