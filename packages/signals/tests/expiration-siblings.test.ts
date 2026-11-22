import { expect, it } from "vitest";
import {
  createRoot,
  createMemo,
  createSignal,
  createRenderEffect,
  flush,
  isPending
} from "../src/index.js";

it.each([false, true])(
  "sibling pending corrections use one context (reverse=%s)",
  async reverse => {
    const [left, setLeft] = createSignal(0);
    const [right, setRight] = createSignal(0);
    const requests: Array<(s: string) => void> = [];
    const visits: string[] = [];
    const published: string[] = [];
    const dispose = createRoot(dispose => {
      const page = createMemo(() => {
        const l = left(),
          r = right();
        const a = isPending(reverse ? right : left),
          b = isPending(reverse ? left : right);
        visits.push([l, r, a, b].join(" "));
        if (a || b) return "Loading";
        if (!l && !r) return "Home";
        return new Promise<string>(res => requests.push(res));
      });
      createRenderEffect(page, v => {
        published.push(v);
      });
      return dispose;
    });
    try {
      flush();
      setLeft(1);
      setRight(1);
      flush();
      expect(visits).toEqual([
        "0 0 false false",
        "1 1 false false",
        "0 0 true true",
        "1 1 false false"
      ]);
      expect(published).toEqual(["Home", "Loading"]);
      expect(requests).toHaveLength(2);
      requests[1]("Ready");
      await Promise.resolve();
      flush();
      expect(published).toEqual(["Home", "Loading", "Ready"]);
    } finally {
      dispose();
    }
  }
);

it("an independent count can update while the badge correction is held", async () => {
  const [id, setId] = createSignal(0);
  const [count, setCount] = createSignal(0);
  const requests: Array<(s: string) => void> = [];
  const deliveries: string[] = [];
  const pages: string[] = [];
  const dispose = createRoot(dispose => {
    const page = createMemo(() => {
      const key = id();
      if (isPending(id)) return "Loading";
      return key ? new Promise<string>(resolve => requests.push(resolve)) : "Home";
    });
    createRenderEffect(page, value => {
      pages.push(value);
    });
    createRenderEffect(
      () => count() + "/" + isPending(id),
      value => {
        deliveries.push(value);
      }
    );
    return dispose;
  });
  try {
    flush();
    setId(1);
    flush();
    expect(deliveries).toEqual(["0/false", "0/true"]);
    setCount(1);
    flush();
    expect(deliveries).toEqual(["0/false", "0/true", "1/true"]);
    expect(pages).toEqual(["Home", "Loading"]);
    requests[1]("Page");
    await Promise.resolve();
    flush();
    expect(deliveries).toEqual(["0/false", "0/true", "1/true", "1/false"]);
    expect(pages).toEqual(["Home", "Loading", "Page"]);
  } finally {
    dispose();
  }
});

it("an independent write still delivers when the binding returns the same pending value", async () => {
  const [id, setId] = createSignal(0);
  const [revision, setRevision] = createSignal(0);
  const answers: Array<(value: string) => void> = [];
  const deliveries: boolean[] = [];
  const dispose = createRoot(dispose => {
    const page = createMemo(() => {
      const key = id();
      if (isPending(id)) return "Loading";
      return key ? new Promise<string>(resolve => answers.push(resolve)) : "Home";
    });
    createRenderEffect(page, () => {});
    createRenderEffect(
      () => {
        revision();
        return isPending(id);
      },
      value => {
        deliveries.push(value);
      }
    );
    return dispose;
  });
  try {
    flush();
    setId(1);
    flush();
    expect(deliveries).toEqual([false, true]);
    setRevision(1);
    flush();
    expect(deliveries).toEqual([false, true, true]);
    answers[0]("obsolete");
    await Promise.resolve();
    flush();
    expect(deliveries).toEqual([false, true, true]);
    answers[1]("current");
    await Promise.resolve();
    flush();
    expect(deliveries).toEqual([false, true, true, false]);
  } finally {
    dispose();
  }
});

it("disposing a binding cancels its correction delivery", async () => {
  const [id, setId] = createSignal(0);
  const answers: Array<(value: string) => void> = [];
  const events: string[] = [];
  const dispose = createRoot(dispose => {
    const page = createMemo(() => {
      const key = id();
      if (isPending(id)) return "Loading";
      return key ? new Promise<string>(resolve => answers.push(resolve)) : "Home";
    });
    createRenderEffect(page, () => {});
    return dispose;
  });
  const disposeBadge = createRoot(dispose => {
    createRenderEffect(
      () => isPending(id),
      pending => {
        events.push(`show ${pending}`);
        return () => {
          events.push(`cleanup ${pending}`);
        };
      }
    );
    return dispose;
  });
  try {
    flush();
    setId(1);
    flush();
    expect(events).toEqual(["show false", "cleanup false", "show true"]);
    disposeBadge();
    answers[0]("obsolete");
    answers[1]("current");
    await Promise.resolve();
    flush();
    expect(events).toEqual(["show false", "cleanup false", "show true", "cleanup true"]);
  } finally {
    disposeBadge();
    dispose();
  }
});
