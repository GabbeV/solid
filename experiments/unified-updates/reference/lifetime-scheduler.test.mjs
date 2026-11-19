import { UnifiedScheduler } from './unified-scheduler.mjs';
import assert from 'node:assert/strict';
import { test } from 'node:test';
import { LifetimeScheduler as LifetimeModel } from './lifetime-scheduler.mjs';
import { PendingScheduler } from './pending-scheduler.mjs';
const LifetimeScheduler = process.env.UNIFIED ? UnifiedScheduler : process.env.OBSERVATION ? PendingScheduler : LifetimeModel;
import { scenario } from './expiry-peer-audit.mjs';
const turn = () => new Promise(resolve => setTimeout(resolve, 0));

for (const initialSeed of [1, 17, 83, 211]) test(`overlapping action lifecycle campaign (seed=${initialSeed})`, async () => {
  const s = new LifetimeScheduler(), calls = [], actions = [];
  const source = s.source('source', 0), flag = s.source('flag', false);
  const work = (kind, value) => {
    if (value === 0 || value === '0/0/0') return value;
    const call = { kind, value, ...Promise.withResolvers() }; calls.push(call); return call.promise;
  };
  const input = s.memo('input', read => work('input', read(source)));
  const a = s.optimistic('a', input), b = s.optimistic('b', input);
  const selected = s.memo('selected', read => read(flag) ? read(a) : read(b));
  const c = s.optimistic('c', selected);
  const label = s.memo('label', read => work('label', [read(a), read(b), read(c)].join('/')));
  for (const node of [a, b, c, label]) s.render(node.name, read => read(node));
  let seed = initialSeed, checked = 0;
  const random = n => { seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0; return Math.floor(seed / 2 ** 32 * n); };
  const check = () => {
    for (; checked < s.publications.length; checked++) {
      const frame = s.publications[checked];
      assert.equal(frame.label, `${frame.a}/${frame.b}/${frame.c}`);
    }
  };
  for (let step = 0; step < 100; step++) {
    const open = actions.filter(action => action.ownScopes.size);
    const action = open[random(open.length)];
    switch (random(5)) {
      case 0: {
        const next = s.begin('same name'); actions.push(next);
        s.guess([a, b, c][random(3)], random(5), { action: next }); break;
      }
      case 1:
        if (action) s.guess([a, b, c][random(3)], random(5), { action }); break;
      case 2:
        if (action) { s.write(source, random(5), { group: action }); s.close(action); } break;
      case 3: s.write(flag, !s.value(flag)); break;
      case 4: s.write(source, random(5)); break;
    }
    s.flush(); check();
    if (calls.length) {
      const call = calls[random(calls.length)]; call.resolve(call.value); await turn(); check();
    }
    if (step % 7 === 6) s.nodes.reverse();
  }
  for (const action of actions) if (action.ownScopes.size) s.close(action);
  for (let pass = 0; pass < 30 && s.updates.size; pass++) {
    for (const call of calls) call.resolve(call.value);
    await turn(); check();
  }
  assert.equal(s.updates.size, 0);
  assert.equal(s.actions.size, 0);
  assert.equal(s.couplings.length, 0);
  assert.equal(s.joins.length, 0);
  assert.equal(s.nodes.filter(node => node.candidate || node.dirty.size).length, 0);
  for (const node of [a, b, c]) assert.equal(s.value(node), s.value(source));
});

test('new guesses during correction supersede its async result and preserve owned frames', async () => {
  const s = new LifetimeScheduler(), input = s.source('input', 0), calls = [], owned = [];
  const view = s.optimistic('view', input);
  const detail = s.memo('detail', read => {
    const value = read(view), owner = { value, cleaned: 0 };
    owned.push(owner); s.onCleanup(() => owner.cleaned++);
    s.render('owned', () => value);
    if (!value) return 0;
    const call = { value, ...Promise.withResolvers() }; calls.push(call); return call.promise;
  });
  const screen = s.render('screen', read => [read(view), read(detail)]);
  const answer = async value => { calls.findLast(call => call.value === value).resolve(value); await turn(); };
  const first = s.begin(); s.guess(view, 1, { action: first }); s.flush(); await answer(1);
  s.write(input, 2); s.close(first);
  assert(calls.some(call => call.value === 2));
  const second = s.begin(); s.guess(view, 3, { action: second }); s.flush();
  await answer(2);
  assert.deepEqual(s.value(screen), [1, 1]);
  assert.equal(owned.findLast(frame => frame.value === 1).cleaned, 0);
  await answer(3);
  assert.deepEqual(s.value(screen), [3, 3]);
  s.close(second); await answer(2);
  assert.deepEqual(s.value(screen), [2, 2]);
  s.dispose(detail); s.dispose(screen);
  assert(owned.every(frame => frame.cleaned === 1));
  assert.equal(s.updates.size, 0);
});

for (const answer of [1, 2]) test(`an incoming answer ${answer} joins the guessing action without rebasing`, () => {
  const s = new LifetimeScheduler(), input = s.source('input', 0);
  const view = s.optimistic('view', input), tick = s.source('tick', 0);
  let guesses = 0;
  const screen = s.render('screen', read => [read(input), read(view), read(view) * 2]);
  const other = s.render('other', read => [read(tick), read(view)]);
  const action = s.begin();
  s.guess(view, x => { guesses++; return x + 1; }, { action }); s.flush();
  assert.deepEqual(s.value(screen), [0, 1, 2]);
  s.write(input, answer); s.flush();
  s.write(tick, 9); s.flush();
  const late = s.render('late', read => read(view));
  assert.deepEqual(s.value(screen), [0, 1, 2]);
  assert.deepEqual(s.value(other), [9, 1]);
  assert.equal(s.value(late), 1);
  s.close(action);
  assert.deepEqual(s.value(screen), [answer, answer, answer * 2]);
  assert.equal(guesses, 1);
  assert.equal(s.updates.size, 0);
  assert.equal(s.actions.size, 0);
  assert.equal(s.couplings.length, 0);
});

test('matching guesses in overlapping actions retain their shared lifetime', () => {
  const s = new LifetimeScheduler(), input = s.source('input', 0);
  const view = s.optimistic('view', input);
  const screen = s.render('screen', read => [read(input), read(view)]);
  const first = s.begin('same label'); s.guess(view, 1, { action: first }); s.flush();
  const second = s.begin('same label'); s.guess(view, 1, { action: second }); s.flush();
  s.write(input, 2); s.flush();
  s.close(first);
  assert.deepEqual(s.value(screen), [0, 1]);
  s.close(second);
  assert.deepEqual(s.value(screen), [2, 2]);
  assert.equal(s.updates.size, 0);
});

test('a parent guess is held by an active child action without ending the parent action', () => {
  const s = new LifetimeScheduler(), input = s.source('input', 0);
  const first = s.optimistic('first', input);
  const doubled = s.memo('doubled', read => read(first) * 2);
  const second = s.optimistic('second', doubled);
  const screen = s.render('screen', read => [read(first), read(second)]);
  const a = s.begin('parent'); s.guess(first, x => x + 1, { action: a }); s.flush();
  assert.deepEqual(s.value(screen), [1, 2]);
  const b = s.begin('child'); s.guess(second, x => x + 1, { action: b }); s.flush();
  assert.deepEqual(s.value(screen), [1, 3]);
  s.guess(first, x => x + 1, { action: a }); s.flush();
  assert.deepEqual(s.value(screen), [1, 3]);
  s.close(b);
  assert.deepEqual(s.value(screen), [2, 4]);
  s.close(a);
  assert.deepEqual(s.value(screen), [0, 0]);
  assert.equal(s.updates.size, 0);
});

test('action completion waits for its input, then cancels obsolete guessed async work', async () => {
  const s = new LifetimeScheduler(), revision = s.source('revision', 0);
  const answer = Promise.withResolvers(), wrong = Promise.withResolvers(), corrected = Promise.withResolvers();
  const input = s.memo('input', read => read(revision) ? answer.promise : 0);
  const view = s.optimistic('view', input), started = [];
  const details = s.memo('details', read => {
    const value = read(view); started.push(value);
    return value === 3 ? wrong.promise : value === 2 ? corrected.promise : 0;
  });
  const screen = s.render('screen', read => [read(input), read(view), read(details)]);
  const action = s.begin();
  s.write(revision, 1, { group: action }); s.guess(view, 3, { action }); s.flush();
  assert.deepEqual(started, [0, 3]);
  s.close(action);
  assert.deepEqual(s.value(screen), [0, 0, 0]);
  answer.resolve(2); await turn();
  assert.deepEqual(started, [0, 3, 2]);
  corrected.resolve(20); await turn();
  assert.deepEqual(s.value(screen), [2, 2, 20]);
  wrong.reject(new Error('obsolete guess failed')); await turn();
  assert.deepEqual(s.value(screen), [2, 2, 20]);
  assert.equal(s.updates.size, 0);
});

for (const reverse of [false, true]) test(`expiry supersedes a peer's obsolete consequence (reverse=${reverse})`, async () => {
  const result = await scenario(LifetimeScheduler, reverse);
  assert.deepEqual(result.revealed, [6, 2, '6/2']);
  assert.deepEqual(result.afterExpiry.visible, [6, 2, '6/2']);
  assert(result.afterExpiry.started.includes('4/1'));
  assert.deepEqual(result.afterObsolete.visible, [6, 2, '6/2']);
  assert.deepEqual(result.final, [4, 1, '4/1']);
  for (const frame of result.publications)
    assert.equal(frame['show:q'], `${frame['show:a']}/${frame['show:b']}`);
});
