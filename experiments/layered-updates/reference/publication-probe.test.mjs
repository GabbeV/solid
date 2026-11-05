import assert from "node:assert/strict";
import { test } from "node:test";
import { ReadModel } from "./read-context.mjs";
import { PublicationProbe } from "./publication-probe.mjs";

function fixture() {
  const model = new ReadModel();
  model.cut("override");
  const view = model.source("view", 0, { cut: "override" });
  const x = model.source("x", 0);
  const derived = model.memo("label", read => `${read(view)}:${read(x)}`);
  const probe = new PublicationProbe(model, [view, x], derived);
  probe.flush(); probe.answer(probe.flight);
  function propose(node, group, value, open = false) {
    model.group(group, { cut: node.cut, open });
    node.proposal = { group, value };
    probe.flush();
    return probe.flight;
  }
  return { model, view, x, probe, propose };
}

test("second guess preserves the published value through unrelated reads and a late binding", () => {
  const { view, probe, propose } = fixture();
  probe.answer(propose(view, "guess 1", 1));
  assert.deepEqual(probe.snapshot(), { sources: [1, 0], consequence: "1:0" });
  const second = propose(view, "guess 2", 2);
  // An unrelated event and a new direct binding both read the actual committed slot.
  const eventRead = view.value, lateBinding = view.value;
  assert.deepEqual([eventRead, lateBinding], [1, 1]);
  assert.deepEqual(probe.snapshot(), { sources: [1, 0], consequence: "1:0" });
  probe.answer(second);
  assert.deepEqual(probe.snapshot(), { sources: [2, 0], consequence: "2:0" });
});

for (const lowerFirst of [false, true]) {
  test(`lower update and upper consequence coordinate in either completion order (${lowerFirst})`, () => {
    const { model, view, x, probe, propose } = fixture();
    propose(x, "lower", 10, true);
    const upper = propose(view, "guess", 1);
    assert.deepEqual(probe.snapshot(), { sources: [0, 0], consequence: "0:0" });
    if (!lowerFirst) {
      probe.answer(upper);
      assert.deepEqual(probe.snapshot(), { sources: [1, 0], consequence: "1:0" });
    }
    model.groups.get("lower").open = false;
    probe.flush();
    const combined = probe.flight;
    assert.equal(combined.key, "1:10");
    assert.equal(probe.answer(upper), false);
    assert.equal(x.value, 0);
    assert.equal(view.value, lowerFirst ? 0 : 1);
    probe.answer(combined);
    assert.deepEqual(probe.snapshot(), { sources: [1, 10], consequence: "1:10" });
    for (const frame of probe.frames)
      assert.equal(frame.consequence, frame.sources.join(":"));
  });
}

test("ordinary peers immediately calculate the combined proposal and share publication", () => {
  const model = new ReadModel();
  const a = model.source("a", 0), b = model.source("b", 0);
  const derived = model.memo("sum", read => read(a) + read(b));
  const probe = new PublicationProbe(model, [a, b], derived);
  probe.flush(); probe.answer(probe.flight);
  model.group("a"); a.proposal = { group: "a", value: 1 }; probe.flush();
  const old = probe.flight;
  model.group("b"); b.proposal = { group: "b", value: 2 }; probe.flush();
  assert.equal(probe.flight.key, 3);
  model.groups.get("a").open = false;
  probe.answer(probe.flight);
  assert.deepEqual(probe.snapshot(), { sources: [0, 0], consequence: 0 });
  assert.equal(probe.answer(old), false);
  model.groups.get("b").open = false;
  probe.flush();
  assert.deepEqual(probe.snapshot(), { sources: [1, 2], consequence: 3 });
});

test("a ready lower optimistic update uses the same revalidation rule", () => {
  const model = new ReadModel();
  model.cut("parent"); model.cut("child", ["parent"]);
  const parent = model.source("parent", 1, { cut: "parent" });
  const child = model.source("child", 3, { cut: "child" });
  const derived = model.memo("pair", read => `${read(parent)}:${read(child)}`);
  const probe = new PublicationProbe(model, [parent, child], derived);
  probe.flush(); probe.answer(probe.flight);
  model.group("parent update", { cut: "parent", open: true });
  parent.proposal = { group: "parent update", value: 2 };
  model.group("child update", { cut: "child", open: false });
  child.proposal = { group: "child update", value: 4 };
  probe.flush();
  const upper = probe.flight;
  assert.equal(upper.key, "1:4");
  model.groups.get("parent update").open = false;
  probe.flush();
  assert.equal(probe.flight.key, "2:4");
  assert.equal(probe.answer(upper), false);
  assert.deepEqual(probe.snapshot(), { sources: [1, 3], consequence: "1:3" });
  probe.answer(probe.flight);
  assert.deepEqual(probe.snapshot(), { sources: [2, 4], consequence: "2:4" });
});

test("post-commit delivery waits for publication without becoming a preparation loop", () => {
  const { model, x, probe, propose } = fixture();
  propose(x, "lower", 10, true);
  const delivered = [];
  probe.afterCommit("lower", frame => delivered.push(frame));
  model.groups.get("lower").open = false;
  probe.flush();
  assert.deepEqual(delivered, []);
  probe.answer(probe.flight);
  assert.deepEqual(delivered, [{ sources: [0, 10], consequence: "0:10" }]);
  probe.flush();
  assert.equal(delivered.length, 1);
});
