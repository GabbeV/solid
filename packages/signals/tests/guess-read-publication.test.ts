import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  refresh
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

type Spend = (previous: number, limit: number) => number;
function budget(
  kind: "scalar" | "store draft",
  limitInput: () => number,
  spendInput: () => number
) {
  if (kind === "scalar") {
    const [cap, guessCap] = createOptimistic(limitInput);
    const [amount, guessSpent] = createOptimistic(spendInput);
    return {
      cap,
      amount,
      raise: () => guessCap(120),
      spend: (fn: Spend) => guessSpent(prev => fn(prev, cap()))
    };
  }
  const [store, guess] = createOptimisticStore(() => ({
    limit: limitInput(),
    spent: spendInput()
  }));
  return {
    cap: () => store.limit,
    amount: () => store.spent,
    raise: () =>
      guess(draft => {
        draft.limit = 120;
      }),
    spend(fn: Spend) {
      let amount!: number;
      guess(draft => {
        amount = draft.spent = fn(draft.spent, draft.limit);
      });
      return amount;
    }
  };
}

function visiblePair(first: () => number, second: () => number) {
  const shown = [0, 0];
  createRenderEffect(first, value => {
    shown[0] = value;
  });
  createRenderEffect(second, value => {
    shown[1] = value;
  });
  return shown;
}

it.each(["scalar", "store draft"] as const)(
  "%s: a spend guess reads the held limit once and waits for its publication",
  async kind => {
    const details = Promise.withResolvers<number>();
    const raiseAck = Promise.withResolvers<void>();
    const spendAck = Promise.withResolvers<void>();
    let balance = { limit: 100, spent: 80 };
    const shown = { limit: 0, spent: 0, details: 0 };
    const reads: number[] = [];
    const seenSpent: number[] = [];
    const app = createRoot(dispose => {
      const limitInput = createMemo(async () => balance.limit);
      const spendInput = createMemo(async () => balance.spent);
      const account = budget(kind, limitInput, spendInput);
      const { cap, amount } = account;
      const quote = createMemo(() => (cap() === 120 ? details.promise : cap()));
      const [tick, setTick] = createSignal(0);
      const reruns: number[] = [];
      createRenderEffect(
        () => [tick(), amount()],
        ([, value]) => {
          reruns.push(value);
        }
      );
      const mount = () =>
        createRoot(stop => {
          const values: number[] = [];
          createRenderEffect(amount, value => {
            values.push(value);
          });
          return { values, stop };
        });
      createRenderEffect(cap, value => {
        shown.limit = value;
      });
      createRenderEffect(amount, value => {
        seenSpent.push(value);
        shown.spent = value;
      });
      createRenderEffect(quote, value => {
        shown.details = value;
      });
      const raise = action(function* () {
        account.raise();
        yield raiseAck.promise;
        refresh(limitInput);
      });
      const propose = (previous: number, max: number) => {
        reads.push(max);
        return previous + 30 <= max ? previous + 30 : previous;
      };
      let result: number | undefined;
      const spend = action(function* () {
        result = account.spend(propose);
        yield spendAck.promise;
        refresh(spendInput);
      });
      return { raise, spend, result: () => result, mount, reruns, setTick, dispose };
    });
    let mounted: ReturnType<typeof app.mount> | undefined;
    try {
      flush();
      await turn();
      const raising = app.raise();
      await turn();
      const spending = app.spend();
      await turn();
      expect(reads).toEqual([120]);
      expect(app.result()).toBe(110);
      expect(shown).toEqual({ limit: 100, spent: 80, details: 100 });
      app.setTick(1);
      mounted = app.mount();
      flush();
      expect(app.reruns.at(-1)).toBe(80);
      expect(mounted.values).not.toContain(110);
      balance = { limit: 120, spent: 109 };
      spendAck.resolve();
      await spending;
      await turn();
      expect(seenSpent).toEqual([80]);
      details.resolve(120);
      await turn();
      expect(shown).toEqual({ limit: 120, spent: 110, details: 120 });
      expect(mounted.values.at(-1)).toBe(110);
      raiseAck.resolve();
      await raising;
      await turn();
      expect(shown).toEqual({ limit: 120, spent: 109, details: 120 });
      expect(reads).toEqual([120]);
    } finally {
      details.resolve(120);
      spendAck.resolve();
      raiseAck.resolve();
      await turn();
      mounted?.stop();
      app.dispose();
    }
  }
);

it("the limit can publish while the spend preview still waits for its own work", async () => {
  const capReady = Promise.withResolvers<number>();
  const spendReady = Promise.withResolvers<number>();
  const finish = Promise.withResolvers<void>();
  const app = createRoot(dispose => {
    const [cap, guessCap] = createOptimistic(100);
    const [spent, guessSpent] = createOptimistic(80);
    const quote = createMemo(() => (cap() === 120 ? capReady.promise : cap()));
    const receipt = createMemo(() => (spent() === 110 ? spendReady.promise : spent()));
    const shown = visiblePair(cap, spent);
    createRenderEffect(quote, () => {});
    createRenderEffect(receipt, () => {});
    const raise = action(function* () {
      guessCap(120);
      yield finish.promise;
    });
    const buy = action(function* () {
      guessSpent(p => Math.min(p + 30, cap()));
      yield finish.promise;
    });
    return { dispose, shown, raise, buy };
  });
  try {
    flush();
    app.raise();
    await turn();
    app.buy();
    await turn();
    expect(app.shown).toEqual([100, 80]);
    capReady.resolve(120);
    await turn();
    expect(app.shown).toEqual([120, 80]);
    spendReady.resolve(110);
    await turn();
    expect(app.shown).toEqual([120, 110]);
  } finally {
    finish.resolve();
    capReady.resolve(120);
    spendReady.resolve(110);
    await turn();
    app.dispose();
  }
});

it("successive writes can read each other's unpublished guesses", async () => {
  const details = Promise.withResolvers<void>();
  const revise = Promise.withResolvers<void>();
  const end = Promise.withResolvers<void>();
  const app = createRoot(dispose => {
    const [a, setA] = createOptimistic(0);
    const [b, setB] = createOptimistic(0);
    const detail = createMemo(() => {
      const value = a();
      return value ? details.promise.then(() => value) : 0;
    });
    const shown = visiblePair(a, b);
    createRenderEffect(detail, () => {});
    const first = action(function* () {
      setA(1);
      yield revise.promise;
      setA(() => b() + 1);
      yield end.promise;
    });
    const second = action(function* () {
      setB(() => a() + 1);
      yield end.promise;
    });
    return { dispose, shown, first, second };
  });
  try {
    flush();
    app.first();
    await turn();
    app.second();
    await turn();
    revise.resolve();
    await turn();
    expect(app.shown).toEqual([0, 0]);
    details.resolve();
    await turn();
    expect(app.shown).toEqual([3, 2]);
  } finally {
    end.resolve();
    revise.resolve();
    details.resolve();
    await turn();
    app.dispose();
  }
});

it.each([false, true])(
  "uses a second proposal across an action yield (nested %s)",
  async nested => {
    const details = Promise.withResolvers<void>();
    const revise = Promise.withResolvers<void>();
    const write = Promise.withResolvers<void>();
    const finish = Promise.withResolvers<void>();
    const app = createRoot(dispose => {
      const [parent, setParent] = createOptimistic(0);
      const [a, setA] = createOptimistic(nested ? parent : 0);
      const [b, setB] = createOptimistic(0);
      const detail = createMemo(() => (a() === 2 ? details.promise.then(() => 2) : a()));
      const shown = visiblePair(a, b);
      createRenderEffect(detail, () => {});
      const first = action(function* () {
        if (nested) setParent(10);
        setA(1);
        yield revise.promise;
        setA(2);
        yield finish.promise;
      });
      const second = action(function* () {
        const captured = a();
        yield write.promise;
        setB(captured * 10);
        yield finish.promise;
      });
      return { dispose, shown, first, second, a };
    });
    try {
      flush();
      app.first();
      await turn();
      expect(app.shown).toEqual([1, 0]);
      revise.resolve();
      await turn();
      app.second();
      await turn();
      write.resolve();
      await turn();
      expect(app.a()).toBe(1);
      expect(app.shown).toEqual([1, 0]);
      details.resolve();
      await turn();
      expect(app.shown).toEqual([2, 20]);
    } finally {
      finish.resolve();
      revise.resolve();
      details.resolve();
      write.resolve();
      await turn();
      app.dispose();
    }
  }
);

it("reads an earlier unflushed draft write without exposing it in another scalar accessor", async () => {
  const gate = Promise.withResolvers<number>();
  const end = Promise.withResolvers<void>();
  const reads: number[] = [];
  const app = createRoot(dispose => {
    const [a, setA] = createOptimistic(0);
    const [s, set] = createOptimisticStore({ a: 0, b: 0 });
    const held = createMemo(() => (s.a ? gate.promise : 0));
    const shown = [0, 0];
    createRenderEffect(
      () => s.a,
      n => {
        shown[0] = n;
      }
    );
    createRenderEffect(
      () => s.b,
      n => {
        shown[1] = n;
      }
    );
    createRenderEffect(held, () => {});
    const start = action(function* () {
      setA(1);
      set(d => {
        d.a = 1;
      });
      set(d => {
        reads.push(a(), d.a);
        d.b = d.a + 1;
      });
      yield end.promise;
    });
    return { dispose, shown, start };
  });
  try {
    flush();
    app.start();
    await turn();
    expect(reads).toEqual([0, 1]);
    expect(app.shown).toEqual([0, 0]);
    gate.resolve(1);
    await turn();
    expect(app.shown).toEqual([1, 2]);
  } finally {
    end.resolve();
    gate.resolve(1);
    await turn();
    app.dispose();
  }
});

it("retiring both guesses releases an unpublished read without waiting for its flight", async () => {
  const endA = Promise.withResolvers<void>();
  const endB = Promise.withResolvers<void>();
  const never = new Promise<number>(() => {});
  const app = createRoot(dispose => {
    const [a, setA] = createOptimistic(0);
    const [b, setB] = createOptimistic(0);
    const [marker, setMarker] = createOptimistic(false);
    const detail = createMemo(() => (a() === 1 ? never : 0));
    const seen: number[] = [];
    let marked = false;
    createRenderEffect(detail, () => {});
    createRenderEffect(b, v => {
      seen.push(v);
    });
    createRenderEffect(marker, v => {
      marked = v;
    });
    const first = action(function* () {
      setA(1);
      yield endA.promise;
    });
    const second = action(function* () {
      setMarker(true);
      setB(() => a() + 1);
      yield endB.promise;
    });
    return { dispose, first, second, seen, marked: () => marked };
  });
  try {
    flush();
    const a = app.first();
    await turn();
    const b = app.second();
    await turn();
    expect(app.marked()).toBe(true);
    endB.resolve();
    await b;
    await turn();
    expect(app.marked()).toBe(true);
    endA.resolve();
    await a;
    await turn();
    expect(app.marked()).toBe(false);
    // A held render callback can deliver the committed zero again on correction.
    expect(new Set(app.seen)).toEqual(new Set([0]));
  } finally {
    endA.resolve();
    endB.resolve();
    await turn();
    app.dispose();
  }
});

it.each(["array", "added key", "unchanged keys"])(
  "a scalar guess reads %s structure",
  async kind => {
    const gate = Promise.withResolvers<number>();
    const end = Promise.withResolvers<void>();
    const app = createRoot(dispose => {
      const [rows, setRows] = createOptimisticStore<number[]>([]);
      const [record, setRecord] = createOptimisticStore<{ price?: number }>(
        kind === "unchanged keys" ? { price: 1 } : {}
      );
      const [summary, guess] = createOptimistic("");
      const input = kind === "array" ? () => rows[0] : () => record.price;
      const quote = createMemo(() => (input() === 12 ? gate.promise : 0));
      createRenderEffect(quote, () => {});
      const seen: string[] = [];
      createRenderEffect(summary, value => {
        seen.push(value);
      });
      let result = "";
      const edit = action(function* () {
        if (kind === "array")
          setRows(d => {
            d.push(12);
          });
        else
          setRecord(d => {
            d.price = 12;
          });
        yield end.promise;
      });
      const describe = action(function* () {
        result = guess(() =>
          kind === "array"
            ? [rows.length, 0 in rows, Object.keys(rows)].join("/")
            : ["price" in record, Object.keys(record)].join("/")
        );
        yield end.promise;
      });
      return { edit, describe, seen, result: () => result, dispose };
    });
    try {
      flush();
      app.edit();
      await turn();
      app.describe();
      await turn();
      const expected = kind === "array" ? "1/true/0" : "true/price";
      expect(app.result()).toBe(expected);
      expect(app.seen.at(-1)).toBe(kind === "unchanged keys" ? expected : "");
      gate.resolve(12);
      await turn();
      expect(app.seen.at(-1)).toBe(expected);
    } finally {
      gate.resolve(12);
      end.resolve();
      await turn();
      app.dispose();
    }
  }
);

it.each(["price first", "stock first"])(
  "a cycle waits for an independent input and its own async work (%s)",
  async order => {
    const priceReady = Promise.withResolvers<void>();
    const stockReady = Promise.withResolvers<void>();
    const revise = Promise.withResolvers<void>();
    const finish = Promise.withResolvers<void>();
    const app = createRoot(dispose => {
      const [price, setPrice] = createOptimistic(0);
      const [quote, setQuote] = createOptimistic(0);
      const [stock, setStock] = createOptimistic(0);
      const [summary, setSummary] = createOptimistic(0);
      const shown = visiblePair(price, quote);
      const others = visiblePair(stock, summary);
      const checkedPrice = createMemo(() => (price() ? priceReady.promise : 0));
      const checkedStock = createMemo(() => (stock() ? stockReady.promise : 0));
      createRenderEffect(checkedPrice, () => {});
      createRenderEffect(checkedStock, () => {});
      const priceAction = action(function* () {
        setPrice(1);
        yield revise.promise;
        setPrice(() => quote() + stock());
        yield finish.promise;
      });
      const stockAction = action(function* () {
        setStock(10);
        yield finish.promise;
      });
      const quoteAction = action(function* () {
        setQuote(() => price() + 1);
        yield finish.promise;
      });
      const summarize = action(function* () {
        setSummary(() => price() + quote());
        yield finish.promise;
      });
      return { dispose, shown, others, priceAction, stockAction, quoteAction, summarize };
    });
    try {
      flush();
      app.priceAction();
      await turn();
      app.stockAction();
      await turn();
      app.quoteAction();
      await turn();
      revise.resolve();
      await turn();
      app.summarize();
      await turn();
      expect(app.shown).toEqual([0, 0]);
      expect(app.others).toEqual([0, 0]);
      (order === "stock first" ? stockReady : priceReady).resolve();
      await turn();
      expect(app.shown).toEqual([0, 0]);
      expect(app.others).toEqual([order === "stock first" ? 10 : 0, 0]);
      (order === "stock first" ? priceReady : stockReady).resolve();
      await turn();
      expect(app.shown).toEqual([12, 2]);
      expect(app.others).toEqual([10, 14]);
    } finally {
      revise.resolve();
      stockReady.resolve();
      priceReady.resolve();
      finish.resolve();
      await turn();
      app.dispose();
    }
  }
);
