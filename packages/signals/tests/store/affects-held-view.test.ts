import { expect, it } from "vitest";
import {
  action,
  affects,
  createMemo,
  createRenderEffect,
  createRoot,
  createStore,
  flush,
  isPending
} from "../../src/index.js";

it.each(["view", "holder", "held address"] as const)(
  "marking the %s leaves its source and a parallel view clear, including for first reads",
  async mark => {
    const [source] = createStore({ address: { city: "Paris" }, name: "Ada" });
    const [view] = createStore(() => source);
    const [sibling] = createStore(() => source);
    const [card] = createStore({ place: view.address });
    const [otherCard] = createStore({ place: view.address });
    const sample = () => [
      isPending(() => source.address.city),
      isPending(() => sibling.address.city),
      isPending(() => view.address.city),
      isPending(() => card.place.city),
      isPending(() => otherCard.place.city),
      isPending(() => source.name)
    ];
    const end = Promise.withResolvers<void>();
    const running = action(function* () {
      affects(mark === "view" ? view : mark === "holder" ? card : card.place);
      yield end.promise;
    })();
    let dispose: (() => void) | undefined;
    try {
      flush();
      const held = [false, false, true, true, true, false];
      expect(sample()).toEqual(held);
      const seen: boolean[][] = [];
      const read = createRoot(d => {
        dispose = d;
        const read = createMemo(sample);
        createRenderEffect(read, values => void seen.push(values));
        return read;
      });
      flush();
      expect(read()).toEqual(held);
      end.resolve();
      await running;
      flush();
      expect(seen).toEqual([held, Array(6).fill(false)]);
      expect(sample()).toEqual(Array(6).fill(false));
    } finally {
      end.resolve();
      await running;
      dispose?.();
      flush();
    }
  }
);

it("a keyed holder declaration marks reads through its slot while a captured address stays clear", async () => {
  const [person] = createStore({ address: { city: "Paris" }, name: "Ada" });
  const address = person.address;
  const [card] = createStore({ place: address });
  const end = Promise.withResolvers<void>();
  const running = action(function* () {
    affects(card, "place");
    yield end.promise;
  })();
  try {
    flush();
    expect(isPending(() => card.place.city)).toBe(true);
    expect(isPending(() => address.city)).toBe(false);
    expect(isPending(() => person.address.city)).toBe(false);
    expect(isPending(() => person.name)).toBe(false);
  } finally {
    end.resolve();
    await running;
    flush();
  }
});

it("two views over the same input keep their own nested row declarations", async () => {
  const [person] = createStore({ address: { region: { city: "Paris" } } });
  const [left] = createStore(() => person);
  const [right] = createStore(() => person);
  const [outer] = createStore(() => ({ left: left.address, right: right.address }));
  const [card] = createStore({ place: outer.left });
  const end = Promise.withResolvers<void>();
  const running = action(function* () {
    affects(card);
    yield end.promise;
  })();
  const reads = () => [
    isPending(() => card.place.region.city),
    isPending(() => outer.left.region.city),
    isPending(() => outer.right.region.city),
    isPending(() => left.address.region.city),
    isPending(() => right.address.region.city),
    isPending(() => person.address.region.city)
  ];
  try {
    flush();
    expect(reads()).toEqual([true, true, false, false, false, false]);
  } finally {
    end.resolve();
    await running;
    flush();
  }
});
