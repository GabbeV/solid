import assert from 'node:assert/strict';
import { test } from 'node:test';
import { action, createMemo, createOptimistic, createRenderEffect, createRoot,
  createSignal, flush, isPending, onCleanup } from './scalar-runtime.mjs';
const turn = () => new Promise(resolve => setTimeout(resolve, 0));

test('scalar API: a repeated revealed guess remains coherent through unrelated writes and late readers', async () => {
  const end = Promise.withResolvers(), again = Promise.withResolvers(), first = Promise.withResolvers(), second = Promise.withResolvers();
  const shown = {}, publications = [];
  let guess, setTick, read, dispose;
  createRoot(cleanup => {
    dispose = cleanup;
    const [tick, writeTick] = createSignal(0); setTick = writeTick;
    const [value, write] = createOptimistic(() => 0); guess = write; read = value;
    const detail = createMemo(() => value() === 1 ? first.promise : value() === 2 ? second.promise : 0);
    createRenderEffect(() => [value(), detail()], pair => { shown.pair = pair; publications.push([...pair]); });
    createRenderEffect(() => [tick(), value()], pair => { shown.other = pair; });
  });
  const running = action(function* () { guess(1); yield again.promise; guess(2); yield end.promise; })();
  flush(); first.resolve(1); await turn();
  assert.deepEqual(shown.pair, [1, 1]);
  again.resolve(); await turn(); flush();
  setTick(9); flush();
  let disposeLate;
  createRoot(cleanup => { disposeLate = cleanup; createRenderEffect(read, value => { shown.late = value; }); });
  flush();
  assert.deepEqual(shown.pair, [1, 1]);
  assert.equal(shown.other[1], 1); assert.equal(shown.late, 1);
  second.resolve(2); await turn();
  assert.deepEqual(shown.pair, [2, 2]); assert.deepEqual(shown.other, [9, 2]); assert.equal(shown.late, 2);
  end.resolve(); await running; flush();
  assert.deepEqual(shown.pair, [0, 0]);
  assert(publications.every(pair => pair[0] === pair[1]));
  disposeLate(); dispose();
});

test('scalar API: pending is shared and owned children clean up after replacement', async () => {
  const end = Promise.withResolvers(), owners = [];
  let setX, dispose, shown;
  createRoot(cleanup => {
    dispose = cleanup;
    const [x, write] = createSignal(0); setX = write;
    const status = createMemo(() => isPending(x));
    const pair = createMemo(() => {
      const owner = { cleaned: 0 }; owners.push(owner); onCleanup(() => owner.cleaned++);
      return [status(), x()];
    });
    createRenderEffect(pair, pair => { shown = pair; });
  });
  const running = action(function* () { setX(1); yield end.promise; })(); flush();
  assert.deepEqual(shown, [true, 0]);
  end.resolve(); await running; flush();
  assert.deepEqual(shown, [false, 1]);
  dispose(); assert(owners.every(owner => owner.cleaned === 1));
});
