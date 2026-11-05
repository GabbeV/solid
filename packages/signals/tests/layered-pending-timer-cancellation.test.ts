import { expect, it, vi } from "vitest";
import {
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  onCleanup
} from "../src/index.js";
import { $REFRESH, CONFIG_HELD } from "../src/core/constants.js";
import * as scheduler from "../src/core/scheduler.js";
import { boundaries } from "../src/layers/boundary.js";
import { ordinaryValuePath } from "./helpers/pending-feedback-audit.js";

it("a pending update can intentionally cancel a delayed indicator in its own update", async () => {
  const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
  const requests: ReturnType<typeof Promise.withResolvers<number>>[] = [];
  const timers: ReturnType<typeof Promise.withResolvers<boolean>>[] = [];
  const cancellations: boolean[] = [],
    relationships: boolean[] = [];
  let set!: (value: number) => number, dispose!: () => void;
  let data!: () => number,
    indicator!: () => boolean,
    shown = false;
  const install = scheduler.setLayerReads;
  const spy = vi
    .spyOn(scheduler, "setLayerReads")
    .mockImplementation((own, merge, frame, status, notify) => {
      install(
        own,
        merge,
        frame,
        status,
        notify &&
          ((source, reader) => {
            let inputUpdate: ReturnType<typeof scheduler.txOf> | undefined;
            if (indicator && reader === (indicator as any)[$REFRESH] && reader._x?._inFlight) {
              const input = boundaries.get(source)?._input;
              if (input === (data as any)[$REFRESH]) {
                expect(ordinaryValuePath(reader, input)).toBe(false);
                relationships.push(
                  !!(input._config & CONFIG_HELD) &&
                    !!(reader._config & CONFIG_HELD) &&
                    scheduler.txOf(input) === scheduler.txOf(reader)
                );
                inputUpdate = scheduler.txOf(input);
                expect(scheduler.blocked(inputUpdate)).toBe(true);
              }
            }
            notify(source, reader);
            if (inputUpdate) expect(scheduler.blocked(scheduler.resolveTx(inputUpdate))).toBe(true);
          })
      );
    });
  try {
    createRoot(cleanup => {
      dispose = cleanup;
      const [id, write] = createSignal(0);
      set = write;
      data = createMemo(() => {
        if (id() === 0) return 0;
        const request = Promise.withResolvers<number>();
        requests.push(request);
        return request.promise;
      });
      indicator = createMemo<boolean>(previous => {
        if (isPending(data)) return true;
        if (!previous) return false;
        const timer = Promise.withResolvers<boolean>();
        timers.push(timer);
        let finished = false;
        onCleanup(() => {
          if (!finished) cancellations.push(true);
        });
        return timer.promise.then(value => {
          finished = true;
          return value;
        });
      });
      createRenderEffect(data, () => {}, { schedule: true });
      createRenderEffect(
        indicator,
        value => {
          shown = value;
        },
        { schedule: true }
      );
    });
    flush();
    set(1);
    flush();
    await turn();
    expect(shown).toBe(true);
    requests[0].resolve(10);
    await turn();
    expect(timers).toHaveLength(1);
    set(2);
    flush();
    await turn();
    expect(relationships).toContain(true);
    expect(cancellations).toHaveLength(1);
    timers[0].resolve(false);
    await turn();
    expect(shown).toBe(true);
    expect(requests).toHaveLength(2);
    requests[1].resolve(20);
    await turn();
    timers[1].resolve(false);
    await turn();
    expect(shown).toBe(false);
  } finally {
    dispose?.();
    flush();
    spy.mockRestore();
  }
});
