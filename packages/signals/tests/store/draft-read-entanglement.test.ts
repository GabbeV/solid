import { describe, expect, it } from "vitest";
import {
  action,
  createRenderEffect,
  createRoot,
  createStore,
  flush,
  reconcile,
  snapshot
} from "../../src/index.js";

function observe<T>(read: () => T) {
  const frames: T[] = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(read, value => {
      frames.push(value);
    });
    return dispose;
  });
  flush();
  return { frames, dispose };
}

function expectVisible<T>(read: () => T, value: T) {
  const { frames, dispose } = observe(read);
  try {
    expect(frames).toEqual([value]);
  } finally {
    dispose();
  }
}

function hold(write: () => void) {
  const gate = Promise.withResolvers<void>();
  const done = action(function* () {
    write();
    yield gate.promise;
  })();
  flush();
  return async () => {
    gate.resolve();
    await done;
    flush();
  };
}

type SetScore = (update: (draft: { score: number; copy: number; other: number }) => void) => void;

describe("plain store draft reads from a held action", () => {
  it.each(["source", "copy"] as const)(
    "publishes both action writes together when the %s action finishes first",
    async first => {
      const [state, setState] = createStore({ score: 0, copy: -1 });
      const read = () => [state.score, state.copy];
      const { frames, dispose } = observe(read);
      const releaseSource = hold(() =>
        setState(d => {
          d.score = 1;
        })
      );
      let draftScore: number | undefined;
      const releaseCopy = hold(() =>
        setState(d => {
          draftScore = d.score;
          d.copy = draftScore;
        })
      );
      const [releaseFirst, releaseLast] =
        first === "source" ? [releaseSource, releaseCopy] : [releaseCopy, releaseSource];

      try {
        expect(draftScore).toBe(1);
        expectVisible(read, [0, -1]);
        await releaseFirst();
        expectVisible(read, [0, -1]);
        await releaseLast();
        expectVisible(read, [1, 1]);
        expect(frames).toEqual([
          [0, -1],
          [1, 1]
        ]);
      } finally {
        await releaseSource();
        await releaseCopy();
        dispose();
      }
    }
  );

  it.each(["field", "descriptor", "snapshot", "replacement", "reconcile"] as const)(
    "a %s copy joins even when nobody previously read the held score",
    async method => {
      const [state, setState] = createStore({ score: 0, copy: -1 });
      const read = () => state.copy;
      const { frames, dispose } = observe(read);
      const release = hold(() =>
        setState(d => {
          d.score = 1;
        })
      );
      try {
        setState(d => {
          const score =
            method === "snapshot"
              ? snapshot(d).score
              : method === "descriptor"
                ? Object.getOwnPropertyDescriptor(d, "score")!.value
                : d.score;
          expect(score).toBe(1);
          if (method === "replacement") return { score, copy: score };
          if (method === "reconcile") reconcile({ score, copy: score })(d);
          else d.copy = score;
        });
        flush();
        expectVisible(read, -1);
        await release();
        expect(frames).toEqual([-1, 1]);
      } finally {
        await release();
        dispose();
      }
    }
  );

  it("composes two unflushed setters inside the holding action", async () => {
    const [state, set] = createStore({ score: 0, copy: -1 });
    const read = () => [state.score, state.copy];
    const { frames, dispose } = observe(read);
    const release = hold(() => {
      set(d => {
        d.score = 1;
      });
      set(d => {
        expect(d.score).toBe(1);
        d.copy = d.score;
      });
    });
    try {
      expectVisible(read, [0, -1]);
      await release();
      expect(frames).toEqual([
        [0, -1],
        [1, 1]
      ]);
    } finally {
      await release();
      dispose();
    }
  });

  it("a copy that reads two independently held proposals joins both actions", async () => {
    const [left, editLeft] = createStore({ score: 0 });
    const [right, editRight] = createStore({ score: 0 });
    const [card, editCard] = createStore({ left, right, copy: -1 });
    const read = () => [left.score, right.score, card.copy];
    const { frames, dispose } = observe(read);
    const releaseLeft = hold(() =>
      editLeft(d => {
        d.score = 1;
      })
    );
    const releaseRight = hold(() =>
      editRight(d => {
        d.score = 2;
      })
    );
    try {
      editCard(d => {
        d.copy = d.left.score + d.right.score;
      });
      flush();
      await releaseLeft();
      expectVisible(read, [0, 0, -1]);
      await releaseRight();
      expect(frames).toEqual([
        [0, 0, -1],
        [1, 2, 3]
      ]);
    } finally {
      await releaseLeft();
      await releaseRight();
      dispose();
    }
  });

  it("holds a mainline copy of the draft value", async () => {
    const [state, setState] = createStore({ score: 0, copy: -1 });
    const read = () => [state.score, state.copy];
    const { frames, dispose } = observe(read);
    const release = hold(() =>
      setState(d => {
        d.score = 1;
      })
    );

    try {
      let draftScore: number | undefined;
      setState(d => {
        draftScore = d.score;
        d.copy = draftScore;
      });
      flush();
      expect(draftScore).toBe(1);
      expectVisible(read, [0, -1]);
      await release();
      expectVisible(read, [1, 1]);
      expect(frames).toEqual([
        [0, -1],
        [1, 1]
      ]);
    } finally {
      await release();
      dispose();
    }
  });

  it("holds a mainline copy of the draft value through a nested store alias", async () => {
    const [person, setPerson] = createStore({ score: 0 });
    const [card, setCard] = createStore({ person, copy: -1 });
    const read = () => [person.score, card.copy];
    const { frames, dispose } = observe(read);
    const release = hold(() =>
      setPerson(d => {
        d.score = 1;
      })
    );

    try {
      let draftScore: number | undefined;
      setCard(d => {
        draftScore = d.person.score;
        d.copy = draftScore;
      });
      flush();
      expect(draftScore).toBe(1);
      expectVisible(read, [0, -1]);
      await release();
      expectVisible(read, [1, 1]);
      expect(frames).toEqual([
        [0, -1],
        [1, 1]
      ]);
    } finally {
      await release();
      dispose();
    }
  });

  it.each([
    ["presence", (draft: { score?: number }) => "score" in draft],
    ["enumeration", (draft: { score?: number }) => Object.keys(draft).includes("score")]
  ] as const)("holds a copy of a staged key removal observed through %s", async (_, hasScore) => {
    const [state, setState] = createStore<{ score?: number; copy: boolean }>({
      score: 1,
      copy: true
    });
    const read = () => [hasScore(state), state.copy];
    const { frames, dispose } = observe(read);
    const release = hold(() =>
      setState(d => {
        delete d.score;
      })
    );

    try {
      let draftPresence: boolean | undefined;
      setState(d => {
        draftPresence = hasScore(d);
        d.copy = draftPresence;
      });
      flush();
      expect(draftPresence).toBe(false);
      expectVisible(read, [true, true]);
      await release();
      expectVisible(read, [false, false]);
      expect(frames).toEqual([
        [true, true],
        [false, false]
      ]);
    } finally {
      await release();
      dispose();
    }
  });

  it.each([
    [
      "a constant",
      setState =>
        setState(d => {
          d.copy = 1;
        })
    ],
    [
      "an unchanged value",
      setState =>
        setState(d => {
          d.copy = d.other;
        })
    ],
    [
      "unchanged presence",
      setState =>
        setState(d => {
          d.copy = Number("score" in d);
        })
    ],
    [
      "an unchanged key list",
      setState =>
        setState(d => {
          d.copy = Number(Reflect.ownKeys(d).includes("score"));
        })
    ],
    [
      "a separate read-only setter in the same tick",
      setState => {
        setState(d => {
          expect(d.score).toBe(1);
        });
        setState(d => {
          d.copy = 1;
        });
      }
    ],
    [
      "a read-only nested setter",
      setState => {
        setState(d => {
          setState(inner => {
            expect(inner.score).toBe(1);
          });
          d.copy = 1;
        });
      }
    ]
  ] satisfies [string, (setState: SetScore) => void][])(
    "publishes the copy independently with %s",
    async (_, update) => {
      const [state, setState] = createStore({ score: 0, copy: -1, other: 1 });
      const read = () => [state.score, state.copy];
      const { frames, dispose } = observe(read);
      const release = hold(() =>
        setState(d => {
          d.score = 1;
        })
      );

      try {
        update(setState);
        flush();
        expectVisible(read, [0, 1]);
        await release();
        expectVisible(read, [1, 1]);
        expect(frames).toEqual([
          [0, -1],
          [0, 1],
          [1, 1]
        ]);
      } finally {
        await release();
        dispose();
      }
    }
  );
});
