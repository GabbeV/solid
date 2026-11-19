import { expect, it } from "vitest";
import {
  action,
  createLoadingBoundary,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  latest
} from "../src/index.js";

const turn = async () => {
  await new Promise(resolve => setTimeout(resolve, 0));
  flush();
};

function setup() {
  const requests: { value: number; resolve: (value: number) => void }[] = [];
  const shown: number[] = [];
  const end = Promise.withResolvers<void>();
  const app = createRoot(dispose => {
    const [id, setId] = createSignal(1);
    const data = createMemo(() => {
      const value = 10 * latest(id) + id();
      return new Promise<number>(resolve => requests.push({ value, resolve }));
    });
    createLoadingBoundary(
      () => {
        createRenderEffect(data, value => {
          shown.push(value);
        });
        return null;
      },
      () => null
    );
    const run = action(function* () {
      setId(2);
      yield end.promise;
    });
    return { dispose, setId, run };
  });
  return { ...app, requests, shown, end };
}

for (const staleFirst of [false, true])
  it(`latest's expired optimistic flight cannot publish (stale answers first=${staleFirst})`, async () => {
    const app = setup();
    try {
      flush();
      expect(app.requests.map(r => r.value)).toEqual([11]);
      app.requests[0].resolve(11);
      await turn();
      expect(app.shown).toEqual([11]);
      app.requests.length = 0;
      app.setId(2);
      flush();
      // No stale latest=1 / ordinary=2 calculation (12). The optimistic
      // flight cannot keep its own input update alive; it is superseded.
      expect(app.requests.map(r => r.value)).toEqual([22, 21, 22]);
      expect(app.shown).toEqual([11]);
      const order = staleFirst ? [0, 1, 2] : [2, 1, 0];
      let published = false;
      for (const index of order) {
        const request = app.requests[index];
        request.resolve(request.value);
        await turn();
        published ||= index === 2;
        expect(app.shown).toEqual(published ? [11, 22] : [11]);
        expect(app.requests.map(r => r.value)).toEqual([22, 21, 22]);
      }
    } finally {
      app.dispose();
      flush();
    }
  });

it("an independent action lifetime lets latest's optimistic flight publish", async () => {
  const app = setup();
  try {
    flush();
    app.requests[0].resolve(11);
    await turn();
    expect(app.shown).toEqual([11]);
    app.requests.length = 0;
    const running = app.run();
    flush();
    expect(app.requests.map(r => r.value)).toEqual([21]);
    app.requests[0].resolve(21);
    await turn();
    expect(app.shown).toEqual([11, 21]);
    app.end.resolve();
    await running;
    await turn();
    expect(app.requests.map(r => r.value)).toEqual([21, 22]);
    expect(app.shown).toEqual([11, 21]);
    app.requests[1].resolve(22);
    await turn();
    expect(app.shown).toEqual([11, 21, 22]);
  } finally {
    app.end.resolve();
    app.dispose();
    flush();
  }
});
