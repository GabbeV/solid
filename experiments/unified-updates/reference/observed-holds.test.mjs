import assert from 'node:assert/strict';
import { test } from 'node:test';
import { UnifiedScheduler } from './unified-scheduler.mjs';
const turn = () => new Promise(resolve => setTimeout(resolve, 0));

for (const reverse of [false, true]) for (const directReader of [false, true]) {
  test(`an observed override preserves its input hold (reverse=${reverse}, direct=${directReader})`, async () => {
    const s = new UnifiedScheduler(), answer = Promise.withResolvers();
    const source = s.source('source', 0), first = s.optimistic('first', source);
    const middle = s.memo('middle', read => read(first) === 0 ? 0 : answer.promise);
    const second = s.optimistic('second', middle);
    const firstDisplay = s.render('firstDisplay', read => read(first));
    const secondDisplay = s.render('secondDisplay', read => [read(second), read(second) * 2]);
    if (directReader) s.render('direct', read => [read(first), read(middle)]);
    const pending = s.render('pending', () => s.isPending(middle));
    if (reverse) s.nodes.reverse();
    const parent = s.begin(), child = s.begin();
    s.guess(first, 1, { action: parent }); s.flush();
    assert.equal(s.value(firstDisplay), 0);
    s.guess(second, 3, { action: child }); s.flush();
    assert.equal(s.value(firstDisplay), 0);
    assert.deepEqual(s.value(secondDisplay), [3, 6]);
    assert.equal(s.value(pending), true);
    assert.equal(s.value(middle), 0);
    const lateOverride = s.render('lateOverride', read => [read(second), read(second) * 2]);
    assert.deepEqual(s.value(lateOverride), [3, 6]);
    const lateInput = s.render('lateInput', read => [read(first), read(middle)]);
    assert.deepEqual(s.value(lateInput), [0, 0]);
    answer.resolve(2); await turn();
    // A ready answer still joins the guessing lifetime; forwarding observation
    // must not replace or bypass that separate lifetime rule.
    assert.deepEqual(s.value(secondDisplay), [3, 6]);
    s.close(child); await turn();
    assert.equal(s.value(firstDisplay), 1);
    assert.deepEqual(s.value(lateInput), [1, 2]);
    assert.deepEqual(s.value(secondDisplay), [2, 4]);
    assert.equal(s.value(pending), false);
    s.close(parent); await turn();
    assert.deepEqual(s.value(lateInput), [0, 0]);
    assert.deepEqual(s.value(secondDisplay), [0, 0]);
    assert.equal(s.updates.size, 0);
    for (const frame of s.publications) {
      for (const name of ['secondDisplay', 'lateOverride'])
        if (frame[name]) assert.equal(frame[name][1], frame[name][0] * 2);
      if (!directReader && frame.lateInput) assert.equal(frame.lateInput[0], frame.firstDisplay);
    }
  });
}

for (const optimistic of [false, true]) {
  test(`hidden flights supersede, recover, and release owners (optimistic=${optimistic})`, async () => {
    const s = new UnifiedScheduler(), flights = [], cleanups = [];
    const source = s.source('source', 0);
    const input = optimistic ? s.optimistic('input', source) : source;
    const write = value => optimistic ? s.guess(input, value) : s.write(input, value);
    const middle = s.memo('middle', read => {
      const value = read(input);
      s.onCleanup(() => cleanups.push(value));
      if (!value) return 0;
      const gate = Promise.withResolvers();
      flights.push({ value, ...gate });
      return gate.promise;
    });
    const visible = s.render('visible', read => read(input));
    write(1); s.flush();
    assert.equal(s.value(visible), 1);
    assert.equal(s.value(middle), undefined);
    write(2); s.flush();
    assert.equal(s.value(visible), 2);
    flights.find(f => f.value === 1).resolve(100); await turn();
    assert.equal(s.value(middle), undefined);
    const late = s.render('late', read => [read(input), read(middle)]);
    assert.equal(s.value(late), undefined);
    flights.find(f => f.value === 2).reject(new Error('answer failed')); await turn();
    assert.deepEqual(s.value(late), { error: 'answer failed' });
    write(3); s.flush();
    assert.equal(s.value(visible), 2);
    flights.findLast(f => f.value === 3).resolve(30); await turn();
    assert.deepEqual(s.value(late), [3, 30]);
    assert.equal(s.value(visible), 3);
    s.dispose(late);
    for (let value = 4; value < 24; value++) {
      write(value); s.flush();
      assert.equal(s.value(visible), value);
      assert.equal(s.value(middle), undefined);
      flights.findLast(f => f.value === value).resolve(value * 10); await turn();
      assert.equal(s.value(middle), value * 10);
      assert.equal(s.updates.size, 0);
      assert.equal(middle.readers.size, 0);
      assert.equal(input.readers.size, 2);
      assert.equal(s.joins.length, 0);
    }
    s.dispose(middle);
    assert.deepEqual(cleanups.toSorted((a, b) => a - b), Array.from({ length: 24 }, (_, i) => i));
    assert.equal(input.readers.size, 1);
  });
}
