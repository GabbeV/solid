import { expect } from "vitest";
import { createMemo, createRenderEffect, mapArray, onCleanup } from "../../src/index.js";

/** Observe the same selected array through direct, memo, indexed and For-like
 * bindings. Capture after callback application, then assert in the test body. */
export function selectedListReaders<T extends { id: number }>(
  list: T[],
  primary?: () => string | undefined
) {
  const text = (row: T) => `[#${row.id}]`;
  const direct = () => list.map(text).join("");
  const memo = createMemo(direct);
  const indexed = () =>
    Array.from({ length: list.length }, (_, index) => {
      const row = list[index];
      return row ? text(row) : "<hole>";
    }).join("");
  type Cell = { value?: string };
  let directValue: string | undefined,
    memoValue: string | undefined,
    indexedValue: string | undefined,
    shownCells: Cell[] | undefined;
  const publications: Array<Array<string | undefined>> = [];
  let active = true;
  onCleanup(() => {
    active = false;
  });
  const capture = () =>
    queueMicrotask(() => {
      if (active)
        publications.push([
          directValue,
          memoValue,
          indexedValue,
          shownCells?.map(cell => cell.value ?? "<uninitialized>").join(""),
          primary?.()
        ]);
    });
  const rows = mapArray(
    () => list,
    row => {
      const cell: Cell = {};
      createRenderEffect(
        () => text(row),
        value => {
          cell.value = value;
          capture();
        }
      );
      return cell;
    }
  );
  createRenderEffect(direct, value => {
    directValue = value;
    capture();
  });
  createRenderEffect(memo, value => {
    memoValue = value;
    capture();
  });
  createRenderEffect(indexed, value => {
    indexedValue = value;
    capture();
  });
  createRenderEffect(rows, cells => {
    shownCells = cells;
    capture();
  });
  let checked = 0;
  const check = () => {
    for (; checked < publications.length; checked++) {
      const [direct, memo, indexed, cells, primary] = publications[checked];
      if (direct !== undefined) expect(direct).not.toContain("<hole>");
      expect(memo).toBe(direct);
      expect(indexed).toBe(direct);
      expect(cells).toBe(direct);
      if (primary !== undefined) expect(primary).toBe(direct);
    }
  };
  return Object.assign(check, { capture });
}
