import { expect, it } from "vitest";
import {
  action,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush
} from "../src/index.js";
const tick = async () => {
  for (let i = 0; i < 4; i++) {
    await new Promise(r => setTimeout(r, 0));
    flush();
  }
};
for (const guessed of [9, undefined])
  it(`a changed property selects presence and shape while input deletes it (${String(guessed)})`, async () => {
    const shown = {
      value: "",
      presence: false,
      own: false,
      keys: "",
      descriptor: false,
      descriptorValue: "absent"
    };
    let start!: () => Promise<unknown>,
      finish = () => {},
      remove!: () => void,
      dispose!: () => void;
    let running: Promise<unknown> | undefined;
    createRoot(d => {
      dispose = d;
      const [removed, setRemoved] = createSignal(false);
      remove = () => setRemoved(true);
      const [st, set] = createOptimisticStore(
        (d: any) => {
          if (removed()) delete d.x;
          else d.x = 1;
        },
        { x: 1 }
      );
      createRenderEffect(
        () => st.x,
        v => {
          shown.value = String(v);
        }
      );
      createRenderEffect(
        () => "x" in st,
        v => {
          shown.presence = v;
        }
      );
      createRenderEffect(
        () => Object.hasOwn(st, "x"),
        v => {
          shown.own = v;
        }
      );
      createRenderEffect(
        () => Object.keys(st).join(","),
        v => {
          shown.keys = v;
        }
      );
      createRenderEffect(
        () => !!Object.getOwnPropertyDescriptor(st, "x"),
        v => {
          shown.descriptor = v;
        }
      );
      createRenderEffect(
        () => {
          const descriptor = Object.getOwnPropertyDescriptor(st, "x");
          return descriptor ? String(descriptor.value) : "absent";
        },
        value => {
          shown.descriptorValue = value;
        }
      );
      start = action(function* () {
        set(d => {
          d.x = guessed;
        });
        yield new Promise<void>(r => (finish = r));
      });
    });
    try {
      flush();
      running = start();
      await tick();
      const selected = {
        value: String(guessed),
        presence: true,
        own: true,
        keys: "x",
        descriptor: true,
        descriptorValue: String(guessed)
      };
      expect(shown).toEqual(selected);
      remove();
      flush();
      await tick();
      expect(shown).toEqual(selected);
      finish();
      await running;
      await tick();
      expect(shown).toEqual({
        value: "undefined",
        presence: false,
        own: false,
        keys: "",
        descriptor: false,
        descriptorValue: "absent"
      });
    } finally {
      finish();
      dispose();
      await Promise.allSettled([running]);
      flush();
    }
  });

it("descriptor values follow guesses and correction while keys ignore incoming value-only changes", async () => {
  let begin!: () => Promise<unknown>,
    finish = () => {},
    update!: (v: number) => void,
    dispose!: () => void;
  let running: Promise<unknown> | undefined;
  let descriptorValue: unknown;
  const keys: string[] = [];
  let keyCalculations = 0;
  createRoot(cleanup => {
    dispose = cleanup;
    const [value, setValue] = createSignal(1);
    update = setValue;
    const [store, set] = createOptimisticStore(
      (draft: any) => {
        draft.x = value();
      },
      { x: 1 }
    );
    createRenderEffect(
      () => Object.getOwnPropertyDescriptor(store, "x")?.value,
      next => {
        descriptorValue = next;
      }
    );
    createRenderEffect(
      () => {
        keyCalculations++;
        return Object.keys(store).join(",");
      },
      next => {
        keys.push(next);
      }
    );
    begin = action(function* () {
      set(draft => {
        draft.x = 9;
      });
      yield new Promise<void>(resolve => {
        finish = resolve;
      });
    });
  });
  try {
    flush();
    running = begin();
    await tick();
    expect(descriptorValue).toBe(9);
    const calculationsAfterDiscovery = keyCalculations;
    update(2);
    flush();
    await tick();
    expect(descriptorValue).toBe(9);
    expect(keyCalculations).toBe(calculationsAfterDiscovery);
    finish();
    await running;
    await tick();
    expect(descriptorValue).toBe(2);
    expect(keys.filter(value => value !== "x")).toEqual([]);
  } finally {
    finish();
    dispose();
    await Promise.allSettled([running]);
    flush();
  }
});
