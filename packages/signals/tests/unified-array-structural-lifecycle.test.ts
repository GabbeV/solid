import { it, expect } from "vitest";
import {
  action,
  createMemo,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush
} from "../src/index.js";
const turn = async () => {
  await new Promise<void>(r => setTimeout(r, 0));
  flush();
};
for (const guessing of ["before-pending", "during-pending"])
  it(`a chained async structural answer joins an edit made ${guessing}`, async () => {
    const initial = ["A", "B"];
    const answer = Promise.withResolvers<string[]>(),
      gate = Promise.withResolvers<void>();
    const raw: string[][] = [],
      shown: string[][] = [];
    let dispose!: () => void;
    let rows!: string[];
    let guess!: (edit: (draft: string[]) => void) => void;
    let inner!: string[];
    const [request, setRequest] = createSignal(0);
    createRoot(d => {
      dispose = d;
      const derived = createMemo(() => (request() === 0 ? initial : answer.promise));
      [inner] = createOptimisticStore(() => derived(), initial);
      [rows, guess] = createOptimisticStore(() => inner, initial);
      createRenderEffect(
        () => Array.from(rows),
        v => {
          shown.push(v);
        }
      );
      createRenderEffect(
        () => Array.from(inner),
        v => {
          raw.push(v);
        }
      );
    });
    flush();
    let p: Promise<unknown> | undefined;
    const start = () => {
      p = action(function* () {
        guess(d => {
          d[1] = "M";
        });
        yield gate.promise;
      })();
      flush();
    };
    try {
      if (guessing === "before-pending") start();
      setRequest(1);
      flush();
      if (guessing === "during-pending") start();
      answer.resolve([]);
      await turn();
      expect(raw).toEqual([initial]);
      // The structural landing establishes the shared selected context. This
      // fresh-array computation can publish that same complete frame again.
      expect(shown).toEqual([initial, ["A", "M"], ["A", "M"]]);
      gate.resolve();
      await p;
      await turn();
      expect(raw).toEqual([initial, []]);
      expect(shown).toEqual([initial, ["A", "M"], ["A", "M"], []]);
    } finally {
      answer.resolve([]);
      gate.resolve();
      await p;
      dispose();
      flush();
    }
  });
for (const chained of [false, true])
  it(`a structural input before the first edit retains coordination (${chained ? "chain" : "direct"})`, async () => {
    const initial = ["A", "B"];
    const incomingGate = Promise.withResolvers<void>(),
      guessGate = Promise.withResolvers<void>();
    const raw: string[][] = [],
      shown: string[][] = [];
    let dispose!: () => void;
    let rows!: string[];
    let guess!: (edit: (draft: string[]) => void) => void;
    const [input, setInput] = createSignal(initial);
    createRoot(d => {
      dispose = d;
      const [inner] = createOptimisticStore(() => input(), initial);
      [rows, guess] = createOptimisticStore(() => (chained ? inner : input()), initial);
      createRenderEffect(
        () => Array.from(rows),
        v => {
          shown.push(v);
        }
      );
      createRenderEffect(
        () => input(),
        v => {
          raw.push(v);
        }
      );
    });
    flush();
    let pi: Promise<unknown> | undefined, pg: Promise<unknown> | undefined;
    try {
      pi = action(function* () {
        setInput([]);
        yield incomingGate.promise;
      })();
      flush();
      pg = action(function* () {
        guess(d => {
          d[1] = "M";
        });
        yield guessGate.promise;
      })();
      flush();
      incomingGate.resolve();
      await pi;
      await turn();
      expect(raw).toEqual([initial]);
      expect(shown).toEqual([initial, ["A", "M"]]);
      guessGate.resolve();
      await pg;
      await turn();
      expect(raw).toEqual([initial, []]);
    } finally {
      incomingGate.resolve();
      guessGate.resolve();
      await Promise.allSettled([pi, pg]);
      dispose();
      flush();
    }
  });
for (const chained of [false, true])
  it(`an unobserved length-only edit coordinates structural input (${chained ? "chain" : "direct"})`, async () => {
    const initial = ["A"];
    const gate = Promise.withResolvers<void>();
    const raw: string[][] = [];
    let dispose!: () => void;
    let guess!: (edit: (draft: string[]) => void) => void;
    const [input, setInput] = createSignal(initial);
    createRoot(d => {
      dispose = d;
      const [inner] = createOptimisticStore(() => input(), initial);
      const [, g] = createOptimisticStore(() => (chained ? inner : input()), initial);
      guess = g;
      createRenderEffect(
        () => input(),
        v => {
          raw.push(v);
        }
      );
    });
    flush();
    const p = action(function* () {
      guess(d => {
        d.length = 3;
      });
      yield gate.promise;
    })();
    flush();
    try {
      setInput([]);
      flush();
      expect(raw).toEqual([initial]);
      gate.resolve();
      await p;
      await turn();
      expect(raw).toEqual([initial, []]);
    } finally {
      gate.resolve();
      await p;
      dispose();
      flush();
    }
  });
