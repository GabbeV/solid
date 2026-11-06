import assert from 'node:assert/strict';
import { test } from 'node:test';
import { SharedFrame } from './shared-frame.mjs';

function fixture() {
  const m = new SharedFrame({ x: 0, optimistic: 0 }, ({ x, optimistic }) => x + optimistic);
  const a = m.mount('a', s => `${s.inputs.x}+${s.inputs.optimistic}=${s.value}`);
  const b = m.mount('b', s => s.value * 2);
  return { m, a, b };
}

test('one shared proposal: superseding lower work preserves its publication obligation', () => {
  const { m, a, b } = fixture();
  m.propose('lower', { x: 1 });
  const lower = m.prepare(['lower']);
  m.propose('upper', { optimistic: 10 });
  const upper = m.prepare(['upper']);
  assert.equal(upper.expected, 10);
  assert.equal(m.groups.get('lower').owesMemo, true);
  assert.equal(m.answer(lower), false);
  m.answer(upper);
  assert.equal(m.commit(upper), true);
  assert.equal(a.value, '0+10=10');
  assert.equal(b.value, 20);
  // There is still no permission to publish x=1 after its old job was discarded.
  assert.equal(m.groups.get('lower').owesMemo, true);
  assert.equal(m.sources.get('x').value, 0);
  const resumed = m.prepare(['lower']);
  assert.equal(resumed.expected, 11);
  m.answer(resumed);
  assert.equal(m.commit(resumed), true);
  assert.equal(a.value, '1+10=11');
  assert.equal(b.value, 22);
  assert.equal(m.groups.size, 0);
});

test('late mounts and unrelated reruns use the same committed shared memo', () => {
  const { m, a, b } = fixture();
  m.propose('guess1', { optimistic: 1 });
  const first = m.prepare(['guess1']); m.answer(first); m.commit(first);
  m.propose('guess2', { optimistic: 2 });
  const second = m.prepare(['guess2']);
  assert.equal(m.rerun('a'), '0+1=1');
  const late = m.mount('late', s => `${s.inputs.optimistic}/${s.value}`);
  assert.equal(late.value, '1/1');
  assert.equal(b.value, 2);
  m.answer(second); m.commit(second);
  assert.equal(a.value, '0+2=2');
  assert.equal(b.value, 4);
  assert.deepEqual(late.history, ['1/1', '2/2']);
});

test('a combined preparation supersedes upper work without publishing an intermediate frame', () => {
  const { m, a } = fixture();
  m.propose('lower', { x: 1 }, { open: true });
  m.prepare(['lower']);
  m.propose('upper', { optimistic: 10 });
  const upper = m.prepare(['upper']);
  m.close('lower');
  // An EXPLICIT arbitration choice, not a claim that closing a scope alone
  // should cause this. The scheduler must decide whether to request it.
  const combined = m.prepare(['lower', 'upper']);
  assert.equal(m.answer(upper), false);
  m.answer(combined); m.commit(combined);
  assert.deepEqual(a.history, ['0+0=0', '1+10=11']);
});

test('peer updates can prepare a combined answer immediately and wait for both scopes', () => {
  const { m } = fixture();
  m.propose('a', { x: 1 }, { open: true });
  const old = m.prepare(['a']);
  m.propose('b', { optimistic: 2 }, { open: true });
  const combined = m.prepare(['a', 'b']);
  assert.equal(combined.expected, 3);
  assert.equal(m.answer(old), false);
  m.answer(combined); m.close('a');
  assert.equal(m.commit(), false);
  m.close('b'); assert.equal(m.commit(), true);
  assert.equal(m.snapshot().value, 3);
});

test('equal write invalidates a candidate generation and keeps its obligation', () => {
  const { m } = fixture();
  m.propose('guess', { optimistic: 1 });
  const old = m.prepare(['guess']); m.answer(old);
  m.propose('guess', { optimistic: 1 });
  assert.equal(m.commit(old), false);
  assert.equal(m.groups.get('guess').owesMemo, true);
  const current = m.prepare(['guess']);
  m.answer(current); assert.equal(m.commit(current), true);
  assert.deepEqual(m.lifecycle, [
    ['create candidate', old.id], ['discard candidate', old.id],
    ['create candidate', current.id], ['publish candidate', current.id]
  ]);
});

test('error and recovery publish as frames shared by every consumer', () => {
  const m = new SharedFrame({ x: 0 }, ({ x }) => {
    if (x === 1) throw new Error('failed');
    return x * 2;
  });
  const a = m.mount('a', s => s.error ?? s.value);
  const b = m.mount('b', s => s.error ?? s.value);
  for (const value of [1, 2]) {
    m.propose('update', { x: value });
    const token = m.prepare(['update']);
    m.answer(token); m.commit(token);
  }
  assert.deepEqual(a.history, [0, 'failed', 4]);
  assert.deepEqual(b.history, a.history);
});

test('finite repeated supersession leaves no live update groups or detached observers', () => {
  const { m } = fixture();
  for (let i = 1; i <= 200; i++) {
    m.propose('lower', { x: i });
    const old = m.prepare(['lower']);
    m.propose('upper', { optimistic: i * 10 });
    const upper = m.prepare(['upper']);
    m.mount('temporary');
    assert.equal(m.answer(old), false);
    m.answer(upper); m.commit(upper);
    const lower = m.prepare(['lower']); m.answer(lower); m.commit(lower);
    m.unmount('temporary');
    assert.equal(m.groups.size, 0);
    assert.equal(m.observers.size, 2);
    assert.equal(m.flight, null);
  }
  for (const frame of m.publications)
    assert.equal(frame.value, frame.inputs.x + frame.inputs.optimistic);
  // Histories deliberately retain audit evidence; this is a bookkeeping check,
  // not a retained-heap measurement or an ownership/cleanup implementation.
});
