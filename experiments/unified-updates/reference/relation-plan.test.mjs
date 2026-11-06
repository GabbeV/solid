import assert from 'node:assert/strict';
import { test } from 'node:test';
import { relationPlan } from './relation-plan.mjs';
const permutations = values => values.length ? values.flatMap((value, index) => permutations(values.filter((_, i) => i !== index)).map(rest => [value, ...rest])) : [[]];

test('an unrelated signal joins an optimistic proposal regardless of its nesting depth', () => {
  const p = relationPlan(['input', 'a', 'b', 'c', 'x'], [['a', 'input'], ['b', 'a'], ['c', 'b']], [['c', 'x']]);
  assert(p.same('c', 'x'));
  assert(p.above('x', 'b'));
  assert(!p.same('x', 'input'));
  assert.equal(p.conflicts.length, 0);
});

test('a child inherits the whole lower peer group independently of discovery order', () => {
  for (const nodes of permutations(['a', 'b', 'c'])) for (const meetings of permutations([['a', 'b'], ['c', 'b']])) {
    const p = relationPlan(nodes, [['c', 'a']], meetings);
    assert(p.same('a', 'b'));
    assert(p.above('c', 'a'));
    assert(p.above('c', 'b'));
    assert(!p.same('c', 'b'));
  }
});

test('both crossed children retain independent publication over committed parents', () => {
  for (const nodes of permutations(['a', 'b', 'c', 'd'])) for (const meetings of permutations([['c', 'b'], ['d', 'a']])) {
    const p = relationPlan(nodes, [['c', 'a'], ['d', 'b']], meetings);
    assert(p.above('c', 'b'));
    assert(p.above('d', 'a'));
    assert(!p.same('c', 'b'));
    assert(!p.same('d', 'a'));
    // The conflict does not manufacture a publication join between parents.
    assert(!p.same('a', 'b'));
  }
});

test('one crossed read alone is a peer join, and a disjoint update stays disjoint', () => {
  const p = relationPlan(['a', 'b', 'c', 'd', 'x'], [['c', 'a'], ['d', 'b']], [['c', 'b']]);
  assert(p.same('c', 'b'));
  assert(p.above('d', 'a'));
  for (const node of ['a', 'b', 'c', 'd']) {
    assert(!p.same(node, 'x')); assert(!p.above(node, 'x')); assert(!p.above('x', node));
  }
});

test('ordinary peers have no ancestry and explicit lifetime coupling remains fixed', () => {
  const ordinary = relationPlan(['a', 'b', 'c'], [], [['a', 'b'], ['b', 'c']]);
  assert(ordinary.same('a', 'c'));
  const coupled = relationPlan(['a', 'b', 'c'], [['c', 'a']], [['b', 'c']], [['a', 'b']]);
  assert(coupled.same('a', 'b'));
  assert(coupled.above('c', 'b'));
});
