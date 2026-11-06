// Diagnostic audit, not a proposed runtime error policy. Only existing hooks
// and metadata are inspected; production code is unchanged.
import { expect, it, vi } from "vitest";
import { writeFileSync } from "node:fs";
import {
  action,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending
} from "../src/index.js";
import { $REFRESH, CONFIG_HELD } from "../src/core/constants.js";
import * as scheduler from "../src/core/scheduler.js";
import { boundaries } from "../src/layers/boundary.js";
import type { Computed, Signal } from "../src/core/types.js";
import { ordinaryValuePath } from "./helpers/pending-feedback-audit.js";

const reports: Record<string, unknown> = {};
const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
const nodeOf = (read: () => unknown) => (read as any)[$REFRESH] as Computed<any>;
const owner = (node: Signal<any>) => (node._config & CONFIG_HELD ? scheduler.txOf(node) : null);

// Temporary audit traversal. A real diagnostic would need a bounded dev-only
// traversal or accept only direct edges; this is not constant-time metadata.
function observations(node: Signal<any>, seen = new Set<Signal<any>>()): any[] {
  if (seen.has(node)) return [];
  seen.add(node);
  const boundary = boundaries.get(node);
  if (boundary && "_observation" in boundary) return [boundary];
  const result: any[] = [];
  for (let dep = (node as Computed<any>)._deps; dep; dep = dep._nextDep)
    result.push(...observations(dep._dep, seen));
  return result;
}

for (const scenario of [
  "self",
  "indirect",
  "secondary",
  "secondary-id",
  "sync-label",
  "supersede",
  "open-action",
  "two-readers"
] as const) {
  for (const order of ["value-first", "pending-first"] as const) {
    it(`audits existing pending metadata: ${scenario}, ${order}`, async () => {
      const gates = [Promise.withResolvers<number>(), Promise.withResolvers<number>()];
      const end = Promise.withResolvers<void>();
      let running: unknown;
      const calls: any[] = [],
        notifications: any[] = [],
        shown: Record<string, unknown> = {};
      const names = new Map<Signal<any>, string>();
      const install = scheduler.setLayerReads;
      let write!: (value: number) => number, dispose!: () => void;
      const name = (node: Signal<any>) => names.get(node) ?? "internal";
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
                const flight = reader._x?._inFlight;
                const before = owner(reader);
                let event: any;
                if (flight && names.has(reader)) {
                  const probes = observations(source);
                  event = {
                    blockedBefore: before ? scheduler.blocked(before) : false,
                    openBefore: before?._open ?? 0,
                    source: name(source),
                    reader: name(reader),
                    sourceLevel: owner(source)?._level ?? 0,
                    readerLevel: before?._level ?? 0,
                    blockers: before ? scheduler.blockersOf(before).map(name) : [],
                    probes: probes.map(record => ({
                      input: name(record._input),
                      ordinaryPath: ordinaryValuePath(reader, record._input),
                      override: typeof record._override === "symbol" ? "none" : record._override,
                      parentKnown: !!record._parent,
                      sameParent:
                        !!before && record._parent && scheduler.resolveTx(record._parent) === before,
                      sameInputOwner: !!before && owner(record._input) === before,
                      inputSources: [...(record._input._x?._pendingSources ?? [])].map(name)
                    })),
                    // Retain identity only in the test to verify invalidation later.
                    flight,
                    readerNode: reader
                  };
                  notifications.push(event);
                }
                notify(source, reader);
                if (event) {
                  const after = before && scheduler.resolveTx(before);
                  event.blockedAfter = after ? scheduler.blocked(after) : false;
                  event.blockersAfter = after ? scheduler.blockersOf(after).map(name) : [];
                }
              })
          );
        });
      try {
        createRoot(cleanup => {
          dispose = cleanup;
          const [id, setId] = createSignal(0);
          write = setId;
          names.set(nodeOf(id), "id");
          const makePrimary = () =>
            createMemo(() => {
              const value = id();
              if (scenario === "two-readers") isPending(id);
              return value === 0 ? 0 : gates[0].promise.then(answer => answer);
            });
          let primary =
            scenario === "secondary" ||
            scenario === "secondary-id" ||
            scenario === "sync-label" ||
            (scenario === "two-readers" && order === "value-first")
              ? makePrimary()
              : undefined;
          if (primary) names.set(nodeOf(primary), "primary");
          const pending = () => isPending(scenario === "secondary" ? primary! : id);
          const status =
            scenario === "supersede"
              ? () => false
              : scenario === "indirect"
                ? createMemo(pending)
                : pending;
          if (scenario === "indirect") names.set(nodeOf(status), "status");
          const data = createMemo(() => {
            let value: number, p: boolean;
            if (order === "pending-first") {
              p = status();
              value = id();
            } else {
              value = id();
              p = status();
            }
            calls.push({ value, pending: p });
            if (scenario === "sync-label") return `${p}:${value}`;
            if ((scenario === "secondary" || scenario === "secondary-id") && p) return -1;
            return value === 0 ? 0 : gates[value === 2 ? 1 : 0].promise.then(answer => answer);
          });
          names.set(nodeOf(data), "data");
          if (scenario === "two-readers" && order === "pending-first") {
            primary = makePrimary();
            names.set(nodeOf(primary), "primary");
          }
          for (const [key, read] of Object.entries({
            id,
            data,
            pending,
            ...(primary ? { primary } : {})
          }))
            createRenderEffect(
              read,
              value => {
                shown[key] = value;
              },
              { schedule: true }
            );
        });
        flush();
        if (scenario === "open-action") {
          running = action(function* () {
            write(1);
            yield end.promise;
          })();
        } else write(1);
        flush();
        await turn();
        const held = { ...shown };
        if (scenario === "supersede") {
          write(2);
          flush();
          await turn();
        }
        const recorded = notifications.map(({ flight, readerNode, ...event }) => ({
          ...event,
          invalidated: readerNode._x?._inFlight !== flight
        }));
        end.resolve();
        gates[0].resolve(10);
        gates[1].resolve(20);
        await turn();
        await running;
        reports[`${scenario}/${order}`] = {
          held,
          settled: { ...shown },
          calls,
          notifications: recorded
        };
        expect(shown.id).toBe(scenario === "supersede" ? 2 : 1);
        expect(shown.pending).toBe(false);
        if (scenario === "secondary" || scenario === "secondary-id") {
          expect(held).toEqual({ id: 0, data: -1, pending: true, primary: 0 });
          expect(
            recorded.some(
              event =>
                event.invalidated &&
                event.blockers.includes("data") &&
                event.probes.some(probe => probe.sameInputOwner)
            )
          ).toBe(true);
        }
        if (scenario === "sync-label") {
          expect(held.data).toBe("true:0");
          expect(recorded).toEqual([]);
        }
        if (scenario === "supersede") {
          expect(recorded.some(event => event.reader === "data" && event.invalidated)).toBe(true);
          expect(recorded.every(event => event.probes.length === 0)).toBe(true);
        }
        if (scenario === "self" || scenario === "indirect") {
          expect(
            recorded.some(
              event =>
                event.reader === "data" &&
                event.invalidated &&
                event.probes.some(probe => probe.ordinaryPath && probe.sameInputOwner)
            )
          ).toBe(true);
        }
        if (scenario === "self" || scenario === "indirect") {
          expect(
            recorded.some(
              event => event.blockedBefore && !event.blockedAfter && event.probes.length
            )
          ).toBe(true);
        }
        if (scenario === "secondary" || scenario === "secondary-id") {
          expect(recorded.every(event => event.blockedBefore && event.blockedAfter)).toBe(true);
        }
        if (scenario === "two-readers") {
          expect(recorded.filter(event => event.blockedBefore && !event.blockedAfter)).toHaveLength(
            1
          );
          expect(
            recorded.some(event => event.probes.length && event.blockedBefore && event.blockedAfter)
          ).toBe(true);
        }
        if (scenario === "open-action") {
          expect(
            recorded.some(
              event =>
                event.openBefore > 0 &&
                event.blockedBefore &&
                event.blockedAfter &&
                event.blockersAfter.length === 0
            )
          ).toBe(true);
        }
        if (scenario === "secondary") {
          expect(recorded.flatMap(event => event.probes).every(probe => !probe.ordinaryPath)).toBe(
            true
          );
        }
      } finally {
        end.resolve();
        dispose?.();
        flush();
        spy.mockRestore();
      }
      if (process.env.PENDING_METADATA_OUT)
        writeFileSync(process.env.PENDING_METADATA_OUT, JSON.stringify(reports, null, 2) + "\n");
    });
  }
}
