import { describe, expect, test } from "vitest";
import { action, createOptimisticStore, createStore, flush, snapshot } from "../../src/index.js";

describe("shallow derived store boundaries", () => {
  test.each(["seed", "return"])("isolates a store proxy supplied in the %s", input => {
    const raw = { name: "Alice" };
    const [person] = createStore(raw);
    const [view] =
      input === "seed"
        ? createStore(() => {}, { row: person }, { shallow: true })
        : createStore(() => ({ row: person }), undefined, { shallow: true });
    flush();

    expect(view.row).not.toBe(person);
    const [card, setCard] = createStore({ row: view.row });
    setCard(draft => {
      draft.row.name = "Bob";
    });
    flush();

    expect([raw.name, person.name, snapshot(person).name]).toEqual(["Alice", "Alice", "Alice"]);
    expect([view.row.name, card.row.name]).toEqual(["Bob", "Bob"]);
  });

  test("#5027: a shallow optimistic draft guesses on the source view's child", async () => {
    const raw = { address: { city: "Paris" } };
    const [source] = createStore(raw);
    const [view, guess] = createOptimisticStore(() => source, undefined, { shallow: true });
    flush();

    const city = () => [
      raw.address.city,
      source.address.city,
      snapshot(source).address.city,
      view.address.city
    ];
    expect(city()).toEqual(["Paris", "Paris", "Paris", "Paris"]);
    const end = Promise.withResolvers<void>();
    const done = action(function* () {
      guess(draft => {
        draft.address.city = "Rome";
      });
      yield end.promise;
    })();
    try {
      flush();
      expect(city()).toEqual(["Paris", "Paris", "Paris", "Rome"]);
    } finally {
      end.resolve();
      await done;
      flush();
    }
    expect(city()).toEqual(["Paris", "Paris", "Paris", "Paris"]);
  });

  test.each(["store proxy", "plain object from a deep source"])(
    "isolates an optimistic edit to a getter returning a %s",
    async input => {
      const raw = { city: "Paris" };
      const [external] = createStore({ address: raw });
      const attached = input === "store proxy" ? external.address : undefined;
      let getterReads = 0;
      let receiver: unknown;
      const [source] = createStore({
        get address() {
          getterReads++;
          receiver = this;
          return attached ?? raw;
        }
      });
      const [view, guess] = createOptimisticStore(() => source, undefined, { shallow: true });
      flush();

      const sourceAddress = source.address;
      expect(sourceAddress).not.toBe(raw);
      const initialAddress = view.address;
      expect(initialAddress).not.toBe(sourceAddress);
      const end = Promise.withResolvers<void>();
      const done = action(function* () {
        guess(draft => {
          const before = getterReads;
          const address = draft.address;
          expect(getterReads).toBe(before + 1);
          expect(receiver).toBe(draft);
          expect(address).toBe(initialAddress);
          address.city = "Rome";
        });
        yield end.promise;
      })();
      try {
        flush();
        expect([
          raw.city,
          source.address.city,
          snapshot(source).address.city,
          view.address.city
        ]).toEqual(["Paris", "Paris", "Paris", "Rome"]);
      } finally {
        end.resolve();
        await done;
        flush();
      }
      expect(view.address.city).toBe("Paris");
    }
  );

  test("preserves a getter's raw return value from a shallow source", () => {
    const raw = { city: "Paris" };
    const [source] = createStore(
      Object.defineProperty({} as { address: typeof raw }, "address", { get: () => raw }),
      { shallow: true }
    );
    const [view, guess] = createOptimisticStore(() => source, undefined, { shallow: true });
    flush();

    expect(view.address).toBe(raw);
    guess(draft => {
      expect(draft.address).toBe(raw);
    });
    flush();
  });

  test("preserves raw child identity from a shallow source in an optimistic draft", () => {
    const symbol = Symbol("address");
    const raw = { address: { city: "Paris" }, [symbol]: { city: "Paris" } };
    const [source] = createStore(raw, { shallow: true });
    const [view, guess] = createOptimisticStore(() => source, undefined, { shallow: true });
    flush();

    expect(view.address).toBe(raw.address);
    guess(draft => {
      expect(draft.address).toBe(raw.address);
      expect(draft[symbol]).toBe(raw[symbol]);
    });
    flush();
  });
});

test("a plain array exposed by a shallow slot retains the references stored inside it", () => {
  const [person] = createStore({ name: "Alice" });
  const rows = [person];
  const [view] = createStore(() => ({ rows }), undefined, { shallow: true });
  const [card, edit] = createStore({ row: view.rows[0] });
  expect(view.rows).toBe(rows);
  expect(card.row).toBe(person);
  edit(draft => {
    draft.row.name = "Bob";
  });
  flush();
  expect([view.rows[0].name, person.name]).toEqual(["Bob", "Bob"]);
});
