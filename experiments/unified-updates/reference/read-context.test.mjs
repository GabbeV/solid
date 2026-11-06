import assert from "node:assert/strict";
import { test } from "node:test";
import { ReadModel, WAIT, summary } from "./read-context.mjs";

function pendingFixture(value = 1) {
  const m = new ReadModel();
  m.group("input");
  m.cut("pending");
  const x = m.source("x", 0, { proposal: { group: "input", value } });
  const pending = m.source("isPending(x)", true, { cut: "pending" });
  return { m, x, pending };
}

test("ordinary mounts still consume held proposals; unrestricted mounts are a separate policy", () => {
  const { m, x } = pendingFixture();
  const node = m.memo("plain", read => read(x) * 10);
  const ordinary = m.select(node);
  assert.equal(ordinary.value, 10);
  assert.deepEqual(ordinary.heldBy, ["input"]);
  assert.deepEqual(ordinary.context, []);
  const unrestricted = m.select(node, { policy: "committed" });
  assert.equal(unrestricted.value, 0);
  assert.deepEqual(unrestricted.heldBy, []);
  assert.deepEqual(unrestricted.observes, ["input"]);
});

for (const asynchronous of [false, true]) {
  for (const reversed of [false, true]) {
    for (const wrapped of [false, true]) {
      test(`pending boundary, async=${asynchronous}, reversed=${reversed}, wrapped=${wrapped}`, () => {
        const { m, x, pending } = pendingFixture(asynchronous ? WAIT : 1);
        const status = wrapped ? m.memo("status wrapper", read => read(pending)) : pending;
        const node = m.memo("pair", read => {
          if (reversed) {
            const value = read(x);
            return [read(status), value];
          }
          const flag = read(status);
          return [flag, read(x)];
        });
        const result = m.select(node);
        assert.deepEqual(result.value, [true, 0]);
        assert.equal(result.suspended, false);
        assert.deepEqual(result.heldBy, []);
        assert.deepEqual(result.observes, ["input"]);
      });
    }
  }
}

test("conditional boundary reachable from committed input authorizes that read", () => {
  const { m, x, pending } = pendingFixture();
  const node = m.memo("conditional", read => {
    const value = read(x);
    return value === 0 ? `${read(pending)}:${value}` : `value:${value}`;
  });
  const selected = m.select(node);
  assert.equal(selected.value, "true:0");
  assert.deepEqual(selected.heldBy, []);
  const ordinary = m.select(node, { policy: "ordinary" });
  assert.equal(ordinary.value, "value:1");
  assert.deepEqual(ordinary.heldBy, ["input"]);
});

test("boundary reached only through a proposal does not make context discovery oscillate", () => {
  const { m, x, pending } = pendingFixture();
  const node = m.memo("inverse conditional", read => {
    const value = read(x);
    return value === 1 ? `${read(pending)}:${value}` : "idle";
  });
  const result = m.select(node);
  assert.equal(result.value, "true:1");
  assert.deepEqual(result.heldBy, ["input"]);
  assert.deepEqual(result.context, []);
  assert.equal(result.attempts.length, 2);
});

test("adding a disjoint active observer changes neither selection nor evaluation count", () => {
  const { m, x, pending } = pendingFixture();
  const node = m.memo("conditional", read => read(x) === 0 ? read(pending) : "new");
  const before = summary(m.select(node));
  m.cut("disjoint");
  m.group("other input");
  const y = m.source("y", 0, { proposal: { group: "other input", value: 1 } });
  const p = m.source("isPending(y)", true, { cut: "disjoint" });
  m.select(m.memo("other observer", read => [read(p), read(y)]));
  assert.deepEqual(summary(m.select(node)), before);
});

test("ordinary peer proposals are consumed together immediately", () => {
  const m = new ReadModel();
  m.group("a update"); m.group("b update");
  const a = m.source("a", 0, { proposal: { group: "a update", value: 1 } });
  const b = m.source("b", 0, { proposal: { group: "b update", value: 2 } });
  const result = m.select(m.memo("sum", read => read(a) + read(b)));
  assert.equal(result.value, 3);
  assert.deepEqual(result.consumes, ["a update", "b update"]);
  assert.deepEqual(result.heldBy, ["a update", "b update"]);
});

test("sibling boundary proposals combine while their ordinary inputs remain committed", () => {
  const m = new ReadModel();
  m.cut("left"); m.cut("right");
  m.group("left output", { cut: "left" });
  m.group("right output", { cut: "right" });
  m.group("left input"); m.group("right input");
  const a = m.source("a", 0, { cut: "left", proposal: { group: "left output", value: 1 } });
  const b = m.source("b", 0, { cut: "right", proposal: { group: "right output", value: 2 } });
  const x = m.source("x", 0, { proposal: { group: "left input", value: 10 } });
  const y = m.source("y", 0, { proposal: { group: "right input", value: 20 } });
  const result = m.select(m.memo("combined", read => [read(a) + read(b), read(x), read(y)]));
  assert.deepEqual(result.value, [3, 0, 0]);
  assert.deepEqual(result.consumes, ["left output", "right output"]);
  assert.deepEqual(result.observes, ["left input", "right input"]);
});

test("a child uses its parent's published boundary output, not a universal base value", () => {
  const m = new ReadModel();
  m.cut("first"); m.cut("second", ["first"]); m.cut("third", ["second"]);
  for (const cut of m.cuts.keys()) m.group(cut, { cut });
  const a = m.source("first", 1, { cut: "first", proposal: { group: "first", value: 2 } });
  const b = m.source("second", 3, { cut: "second", proposal: { group: "second", value: 4 } });
  const c = m.source("third", 5, { cut: "third", proposal: { group: "third", value: 6 } });
  const result = m.select(m.memo("triple", read => [read(a), read(b), read(c)]));
  assert.deepEqual(result.value, [1, 3, 6]);
  assert.deepEqual(result.consumes, ["third"]);
  assert.deepEqual(result.observes, ["first", "second"]);
});

test("an observation output's own held proposal cannot be published by a new reader", () => {
  const { m, x } = pendingFixture();
  m.group("pending output", { cut: "pending" });
  const p = m.source("pending", false, {
    cut: "pending", proposal: { group: "pending output", value: true }
  });
  const result = m.select(m.memo("pair", read => [read(p), read(x)]));
  assert.deepEqual(result.value, [true, 0]);
  assert.deepEqual(result.heldBy, ["pending output"]);
  assert.deepEqual(result.observes, ["input"]);
});

test("a published memo frame can carry a live boundary witness", () => {
  const { m, x } = pendingFixture();
  const cached = m.source("published status memo", true, { supports: ["pending"] });
  const result = m.select(m.memo("pair", read => [read(x), read(cached)]));
  assert.deepEqual(result.value, [0, true]);
  assert.deepEqual(result.heldBy, []);
});

test("an owned computation can inherit a validated boundary context", () => {
  const { m, x } = pendingFixture();
  const node = m.memo("owned child", read => read(x));
  assert.deepEqual(m.select(node).heldBy, ["input"]);
  const inherited = m.select(node, { inherited: ["pending"] });
  assert.equal(inherited.value, 0);
  assert.deepEqual(inherited.heldBy, []);
});

test("an error from rejected discovery is not the selected result", () => {
  const { m, x, pending } = pendingFixture();
  const node = m.memo("error", read => {
    if (read(x) === 0) throw new Error("old branch");
    return read(pending);
  });
  const result = m.select(node);
  assert.equal(result.attempts[0].error.message, "old branch");
  assert.equal(result.error, undefined);
  assert.deepEqual(result.heldBy, ["input"]);
});

test("request and owned-child descriptors expose provisional work rather than hiding it", () => {
  const { m, x, pending } = pendingFixture();
  const node = m.memo("request", (read, work) => {
    const value = read(x);
    work.child(`child:${value}`);
    read(pending);
    return work.request(`request:${value}`);
  });
  const result = m.select(node);
  assert.deepEqual(result.requests, ["request:0"]);
  assert.deepEqual(result.children, ["child:0"]);
  assert.equal(result.attempts.flatMap(attempt => attempt.requests).length, 2);
});

test("equal-valued proposals still carry different coordination obligations", () => {
  const { m, x } = pendingFixture(0);
  const result = m.select(m.memo("equal", read => read(x)));
  assert.equal(result.value, 0);
  assert.deepEqual(result.consumes, ["input"]);
});

test("finite graph transformations preserve the selected values and obligations", () => {
  // Finite synchronous snapshots, not a proof or a publication fuzzer.
  for (let bits = 0; bits < 64; bits++) {
    const { m, x, pending } = pendingFixture((bits >> 1) & 1);
    m.group("y update");
    const y = m.source("y", (bits >> 2) & 1, {
      proposal: { group: "y update", value: (bits >> 3) & 1 }
    });
    const choose = (bits & 1) !== 0;
    const make = (wrap, reverse) => {
      const wrapNode = n => wrap ? m.memo(`identity:${n.name}`, read => read(n)) : n;
      const left = wrapNode(x), right = wrapNode(y), flag = wrapNode(pending);
      return m.memo("transformed", read => {
        let a, b;
        if (reverse) { b = read(right); a = read(left); }
        else { a = read(left); b = read(right); }
        return choose || a === b ? `${read(flag)}:${a + b}` : `plain:${a + b}`;
      });
    };
    const observable = node => {
      const { evaluations, ...result } = summary(m.select(node));
      return result;
    };
    const expected = observable(make(false, false));
    for (const wrap of [false, true]) for (const reverse of [false, true])
      assert.deepEqual(observable(make(wrap, reverse)), expected, `snapshot ${bits}`);
    m.cut("irrelevant");
    assert.deepEqual(observable(make(false, false)), expected);
  }
});
