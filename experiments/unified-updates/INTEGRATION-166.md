# First callbacks in unpublished owned subtrees

No runtime changes retained. Stage 165 remains the implementation checkpoint,
with 26 non-deferred signals failures.

Eleven failures concern first callbacks in an unpublished owned subtree:
six held-frame grouping cases, four C4 latest/memo cases and one merged-hold
case. Re-read D-19 (synchronous first render versus queued callbacks behind a
fallback) and D-2 (first reads of held values). They distinguish cases that a
blanket first-callback exception would conflate.

A normal JSX reduction verifies an observable difference beyond log counts:

```tsx
const [count, setCount] = createSignal(0);
const change = action(function* () {
  setCount(1);
  yield delay(500);
  setCount(2);
  yield delay(500);
});
function Child() {
  const element = <span>{latest(count) * 10}</span>;
  console.log(element.textContent);
  return element;
}
// <button onClick={change}>Change</button>
// <Show when={count() > 0} fallback="off"><Child /></Show>
```

Next `4fe75321` creates the detached span with text `10`; the experiment creates
it empty. In both, it stays detached while the action is open, the visible page
stays `off`, and the final attached span contains `20`. An ordinary `count()`
read in place of `latest(count)` has the same difference. This concerns
synchronous detached-node initialization, not permission for a scheduled
callback or a DOM attachment to publish early.

A trial that merely exempted type-0 callbacks from the held callback guard did
not fix the failures: the first value was staged before reaching that guard.
Applying that private staging before the first run fixed three old assertions,
but broke seven born-held/mount controls and exposed `captured=1 / ordinary=1 /
latest=0` in the C4 child. The first calculated value cannot simply be declared
ready. Both changes are reverted. The focused set is restored to **76 passed /
11 known failures**, and the runtime diff against stage 165 is empty.

The remaining contract question is whether this specific unpublished subtree
must retain next's immediate initialization from its proposed inputs, or may
wait for coherent publication. The latter is the current behavior, not an
approved assertion migration. It leaves the on-screen timeline unchanged but
changes synchronous inspection of detached DOM. The former requires coherent
initial context selection, not merely releasing callbacks earlier. No failing
assertion has been changed for this choice.

Receipts, both JSX forms, next/experiment timelines and rejected source:
`checkpoints/integration-stage166.tar.xz`.
