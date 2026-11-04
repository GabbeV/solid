// Public source-only regression repro. Stores remain outside the Bend grammar.
// Run the pinned build with --expect-crash; omit it for the pre-#4625 control.
import assert from 'node:assert/strict';

const reference = process.env.SOLID_REFERENCE ?? new URL('../../build/solid.mjs', import.meta.url).href;
const expectCrash = process.argv.includes('--expect-crash');
const delay = (ms, value) => new Promise(resolve => setTimeout(resolve, ms, value));
const unwrap = error => error && Object.hasOwn(error, 'cause') ? unwrap(error.cause) : error;
const rows = [];

for (const variant of ['latest-untracked', 'latest-tracked', 'pending-untracked', 'no-flight']) {
  const S = await import(reference + '?store-staged-screen=' + variant);
  const seen = [], reports = [];
  let dispose;
  const original = console.error;
  console.error = (...args) => reports.push(args);
  try {
    const app = S.createRoot(stop => {
      dispose = stop;
      const [step, setStep] = S.createSignal(0);
      const [state, setState] = S.createStore({ count: 0 });
      const data = S.createMemo(() => {
        const current = step();
        return variant === 'no-flight' || current === 0 ? current : delay(50, current);
      });
      const value = S.createMemo(() => [
        variant === 'pending-untracked' ? S.isPending(data) : S.latest(data),
        variant === 'latest-tracked' ? state.count : S.untrack(() => state.count)
      ]);
      S.createRenderEffect(value, result => { seen.push(result); });
      return { setStep, setState, value };
    });
    S.flush();
    app.setStep(1);
    app.setState(draft => { draft.count = 1; });
    let escaped, readError, result;
    try { S.flush(); } catch (error) { escaped = unwrap(error); }
    try { result = app.value(); } catch (error) { readError = unwrap(error); }
    const failing = expectCrash && variant === 'latest-untracked';
    if (failing) {
      assert.ok(escaped instanceof TypeError);
      assert.match(escaped.message, /reading '_x'/);
      assert.equal(readError, escaped);
      assert.equal(reports[0]?.[0], '[REACTIVITY_HALTED]');
    } else {
      assert.equal(escaped, undefined);
      assert.equal(readError, undefined);
      assert.deepEqual(reports, []);
      assert.ok(Array.isArray(result));
      assert.ok(seen.length >= 2, "the passing control must actually rerun its reader");
      if (variant === "no-flight") assert.deepEqual(result, [1, 1]);
    }
    rows.push({ variant, seen, result, error: readError?.message, halted: reports.length !== 0 });
  } finally {
    try { dispose?.(); } finally { S.resetErrorHalt(); console.error = original; }
  }
}
console.log(JSON.stringify({ expectCrash, rows }, null, 2));
