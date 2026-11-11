import {
  action,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  latest,
  type SourceAccessor
} from "../../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
export const observationQueries = ["none", "signal", "pending", "latest", "memo"] as const;
export type ObservationQuery = (typeof observationQueries)[number];
type Phase = "initial" | "held" | "settled" | "disposed";
type QueryState = {
  source: SourceAccessor<number>;
  unrelated: SourceAccessor<number>;
  screen: (readonly [number, boolean])[];
  answers: unknown[];
  readonly calls: number;
};

/** Shared public timeline; source-only inspections are supplied by the caller. */
export async function comparatorObservation(
  query: ObservationQuery,
  observed: boolean,
  check: (phase: Phase, state: QueryState) => void
): Promise<void> {
  const [unrelated] = createSignal(0);
  let pendingMemo!: () => boolean;
  let armed = false;
  let calls = 0;
  const answers: unknown[] = [];
  const [source, setSource] = createSignal(0, {
    equals(previous, next) {
      if (armed) {
        // Bound a runaway without the global 100,000-flush guard or wedging
        // a synchronous source or production test worker.
        if (++calls > 30) {
          armed = false;
          throw new Error("comparator observation query prevented flush quiescence");
        }
        if (query === "signal") answers.push(unrelated());
        else if (query === "pending") answers.push(isPending(unrelated));
        else if (query === "latest") answers.push(latest(unrelated));
        else if (query === "memo") answers.push(pendingMemo());
      }
      return Object.is(previous, next);
    }
  });
  const screen: (readonly [number, boolean])[] = [];
  const state: QueryState = {
    source,
    unrelated,
    screen,
    answers,
    get calls() {
      return calls;
    }
  };
  const dispose = createRoot(dispose => {
    if (query === "memo") {
      pendingMemo = createMemo(() => isPending(unrelated));
      pendingMemo();
    }
    if (observed)
      createRenderEffect(
        () => (query === "pending" ? isPending(unrelated) : latest(unrelated)),
        () => {}
      );
    createRenderEffect(
      () => [source(), isPending(source)] as const,
      value => {
        screen.push(value);
      }
    );
    return dispose;
  });
  const end = Promise.withResolvers<void>();
  let running: Promise<void> | undefined;
  try {
    flush();
    check("initial", state);
    armed = true;
    running = action(function* () {
      setSource(1);
      yield end.promise;
    })();
    flush();
    check("held", state);
    armed = false;
    end.resolve();
    await running;
    await turn();
    check("settled", state);
  } finally {
    armed = false;
    end.resolve();
    await running;
    await turn();
    dispose();
    flush();
    check("disposed", state);
  }
}

type HeldState = {
  unrelated: SourceAccessor<number>;
  reads: number[];
  screen: (readonly [number, boolean])[];
};

export async function heldComparatorObservation(
  check: (phase: Exclude<Phase, "initial">, state: HeldState) => void
): Promise<void> {
  const [held, setHeld] = createSignal(0);
  const [unrelated] = createSignal(0);
  const reads: number[] = [];
  let armed = false;
  const [source, setSource] = createSignal(0, {
    equals(previous, next) {
      if (!armed) return Object.is(previous, next);
      if (reads.length === 30) {
        armed = false;
        throw new Error("comparator held-read query prevented flush quiescence");
      }
      latest(unrelated);
      const value = held();
      reads.push(value);
      return value === 1 || Object.is(previous, next);
    }
  });
  const screen: (readonly [number, boolean])[] = [];
  const state: HeldState = { unrelated, reads, screen };
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => [source(), isPending(source)] as const,
      value => {
        screen.push(value);
      }
    );
    return dispose;
  });
  const heldEnd = Promise.withResolvers<void>();
  const sourceEnd = Promise.withResolvers<void>();
  let heldRun: Promise<void> | undefined;
  let sourceRun: Promise<void> | undefined;
  try {
    flush();
    heldRun = action(function* () {
      setHeld(1);
      yield heldEnd.promise;
    })();
    flush();
    armed = true;
    sourceRun = action(function* () {
      setSource(1);
      yield sourceEnd.promise;
    })();
    flush();
    check("held", state);
    armed = false;
    sourceEnd.resolve();
    await sourceRun;
    await turn();
    heldEnd.resolve();
    await heldRun;
    await turn();
    check("settled", state);
  } finally {
    armed = false;
    sourceEnd.resolve();
    heldEnd.resolve();
    await Promise.all([sourceRun, heldRun]);
    await turn();
    dispose();
    flush();
    await turn();
    flush();
    check("disposed", state);
  }
}
