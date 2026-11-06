import {
  action,
  clearSnapshots,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  getOwner,
  isPending,
  latest,
  markSnapshotScope,
  releaseSnapshotScope,
  runWithOwner,
  setSnapshotCapture
} from "../src/index.js";

// #4570: a reader in a snapshot scope (a hydration claim) is served the value
// the server rendered with. `latest()` and `isPending()` read through the
// verdict window, which must serve the snapshot as a plain read does: in a
// claim, `latest(a)` beside `a()` shows the server's frame whole (F-1).
afterEach(() => {
  clearSnapshots();
  setSnapshotCapture(false);
  flush();
});

describe("#4570: verdict reads in a snapshot scope", () => {
  for (const callback of [false, true])
    for (const initial of [1, undefined])
      it(`a claim shares a source with live observations (callback=${callback}, initial=${initial})`, async () => {
        const end = Promise.withResolvers<void>();
        let owner!: ReturnType<typeof getOwner>;
        let source!: () => number | undefined, setSource!: (v: number) => void;
        let live!: () => unknown[];
        const claims: unknown[][] = [];
        const dispose = createRoot(dispose => {
          [source, setSource] = createSignal<number | undefined>(initial);
          live = createMemo(() => [latest(source), isPending(source)]);
          createRoot(() => {
            owner = getOwner();
            setSnapshotCapture(true);
            markSnapshotScope(owner!);
          });
          return dispose;
        });
        const saving = action(function* () {
          setSource(5);
          yield end.promise;
        })();
        try {
          flush();
          expect(live()).toEqual([5, true]);
          runWithOwner(owner, () => {
            const input = callback ? () => source() : source;
            createRenderEffect(
              () => [source(), latest(input), isPending(input)],
              value => {
                claims.push(value);
              }
            );
          });
          expect(claims).toEqual([[initial, initial, false]]);
          expect(live()).toEqual([5, true]);
          releaseSnapshotScope(owner!);
          flush();
          end.resolve();
          await saving;
          flush();
          expect(claims).toEqual([
            [initial, initial, false],
            [initial, 5, true],
            [5, 5, false]
          ]);
          expect(live()).toEqual([5, false]);
        } finally {
          end.resolve();
          await saving;
          dispose();
        }
      });

  it.each([false, true])(
    "a served async answer is ready in the claim (callback=%s)",
    async callback => {
      const answer = Promise.withResolvers<string>();
      let scope!: ReturnType<typeof getOwner>;
      const frames: unknown[][] = [];
      const dispose = createRoot(dispose => {
        setSnapshotCapture(true);
        let node!: ReturnType<typeof getOwner>;
        const data = createMemo(() => {
          node = getOwner();
          return answer.promise;
        });
        markSnapshotScope(node!, "server");
        scope = getOwner();
        markSnapshotScope(scope!);
        const input = callback ? () => data() : data;
        createRenderEffect(
          () => [data(), latest(input), isPending(input)],
          value => {
            frames.push(value);
          }
        );
        return dispose;
      });
      try {
        flush();
        expect(frames).toEqual([["server", "server", false]]);
        releaseSnapshotScope(scope!);
        flush();
        answer.resolve("client");
        await new Promise(resolve => setTimeout(resolve, 0));
        flush();
        expect(frames).toEqual([
          ["server", "server", false],
          ["client", "client", false]
        ]);
      } finally {
        answer.resolve("client");
        dispose();
      }
    }
  );

  it("latest() and a plain read agree on the snapshot until release", () => {
    let setX!: (v: number) => void;
    let $x!: () => number;
    let owner!: any;
    createRoot(() => {
      [$x, setX] = createSignal(1);
      setSnapshotCapture(true);
      owner = getOwner()!;
      markSnapshotScope(owner);
    });

    // A client write before the claim's readers exist.
    setX(5);
    flush();

    let plain!: () => number, viaLatest!: () => number, pending!: () => boolean;
    runWithOwner(owner, () => {
      plain = createMemo(() => $x());
      viaLatest = createMemo(() => latest($x));
      pending = createMemo(() => isPending($x));
    });
    expect([plain(), viaLatest(), pending()]).toEqual([1, 1, false]);

    releaseSnapshotScope(owner);
    flush();
    expect([plain(), viaLatest(), pending()]).toEqual([5, 5, false]);
  });
});
