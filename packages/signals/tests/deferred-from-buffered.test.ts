import { afterEach, describe, expect, it } from "vitest";
import {
  createDeferred,
  createMemo,
  createRoot,
  createSignal,
  flush,
  from,
  resetErrorHalt
} from "../src/index.js";

afterEach(() => {
  resetErrorHalt();
  flush();
});

describe("buffered from() values in createDeferred", () => {
  for (const seeded of [false, true]) {
    for (const complete of [false, true]) {
      it(`keeps first and later buffered values (seeded=${seeded}, complete=${complete})`, () => {
        let dispose!: () => void;
        let setVersion!: (value: number) => unknown;
        let value!: () => number;
        createRoot(d => {
          dispose = d;
          const [version, set] = createSignal(0);
          setVersion = set;
          value = createDeferred(
            () => {
              const current = version();
              return from<number>((next, _error, done) => {
                next(current);
                if (complete) done();
              });
            },
            seeded ? { loadingValue: -1 } : undefined
          );
        });
        try {
          flush();
          expect(value()).toBe(0);
          setVersion(1);
          flush();
          expect(value()).toBe(1);
          setVersion(2);
          flush();
          expect(value()).toBe(2);
        } finally {
          dispose();
        }
      });
    }

    it(`ordinary memo control (seeded=${seeded})`, () => {
      let dispose!: () => void;
      let setVersion!: (value: number) => unknown;
      let value!: () => number;
      createRoot(d => {
        dispose = d;
        const [version, set] = createSignal(0);
        setVersion = set;
        value = createMemo(
          () => {
            const current = version();
            return from<number>(next => next(current));
          },
          seeded ? { loadingValue: -1 } : undefined
        );
      });
      try {
        flush();
        expect(value()).toBe(0);
        setVersion(1);
        flush();
        expect(value()).toBe(1);
      } finally {
        dispose();
      }
    });

    it(`promise iterator control (seeded=${seeded})`, async () => {
      let dispose!: () => void;
      let setVersion!: (value: number) => unknown;
      let value!: () => number;
      createRoot(d => {
        dispose = d;
        const [version, set] = createSignal(0);
        setVersion = set;
        value = createDeferred(
          () => {
            const current = version();
            return (async function* () {
              yield current;
            })();
          },
          seeded ? { loadingValue: -1 } : undefined
        );
      });
      try {
        for (let i = 0; i < 4; i++) await Promise.resolve();
        flush();
        expect(value()).toBe(0);
        setVersion(1);
        flush();
        for (let i = 0; i < 4; i++) await Promise.resolve();
        flush();
        expect(value()).toBe(1);
      } finally {
        dispose();
      }
    });
  }
});

it("keeps deferred answers when synchronous completion returns a throwing unsubscribe", () => {
  let closed = 0;
  const { value, setVersion, dispose } = createRoot(dispose => {
    const [version, setVersion] = createSignal(0);
    const value = createDeferred(() => {
      const current = version();
      return from<number>((next, _error, complete) => {
        next(current);
        complete();
        return () => {
          closed++;
          throw new Error("unsubscribe failed");
        };
      });
    });
    return { value, setVersion, dispose };
  });
  try {
    flush();
    expect(value()).toBe(0);
    setVersion(1);
    flush();
    expect(value()).toBe(1);
    setVersion(2);
    flush();
    expect(value()).toBe(2);
    expect(closed).toBe(3);
  } finally {
    dispose();
  }
  expect(closed).toBe(3);
});
