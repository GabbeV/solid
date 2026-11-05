# Next scalar API decision: refresh an optimistic boundary

Historical question and subsequent clarification. The scalar implementation
now exists; [stage 69](REFRESH-69.md) supersedes the implementation-status notes
below and records the accepted relative-input behavior against pinned next.

## Clarification: invalidation must preserve next's target scope

The user clarified that refreshing the optimistic boundary reruns its own input
callback. Reading `doubled()` from that callback does not invalidate `doubled`.
The direct form `createOptimistic(doubled)` must have the same invalidation scope
as `createOptimistic(() => doubled())`. Next creates a computation for both.

The prototype now creates a separate producer for both forms. The earlier
tagged-accessor shortcut has been removed so that refresh cannot accidentally
invalidate the reused dependency. Scalar refresh itself is still unimplemented.

The user accepted this simple representation for now and suggested revisiting
the allocation later: a direct accessor may not need a full producer if its
refresh can avoid invalidating the dependency. This is an optimization of the
same contract, not a reason to require two full nodes permanently. Any shortcut
must also preserve promise settlement, notification, and override-lifetime
effects; “no re-fetch” does not necessarily mean the entire operation is a no-op.

After removing the shortcut, the layered regression set passes: 359 tests plus
two expected failures in legacy comparison cases. Source declaration checking
also passes. The expanded scalar-only run passes 128 tests in seven files with
100 seeds each for pending, branching, overlap, and latest. Its first invocation
used the default five-second per-test timeout, aborting the longer campaigns
and contaminating a following test; rerunning with a 60-second campaign timeout
passed in 19.36 seconds with all consistency assertions unchanged.
The scalar production files were regenerated, mangled, and checked for pure
annotations. The build process remained alive after those steps and was stopped;
its log is `/tmp/layered-input-node-build.log` (including pre-existing unrelated
test type diagnostics). The generated runtime's `stable-core-audit.mjs` timeline
keeps all readers at 1 while proposal 2 is suspended, then publishes 2 coherently.
Earlier stage-68 direct-input allocation/throughput measurements
describe the shortcut implementation and must not be presented as measurements
of this revision.

`refresh-equality-audit.mjs` verifies eight cases against the pinned next build:
direct/wrapper inputs, default/false equality on doubled, and default/false
equality on the optimistic node. Refresh never reruns clean doubled. It reruns
the wrapper input once. Default equality suppresses an unchanged result's
downstream recomputation; equals:false on the optimistic node allows it. Equality
does not control upstream invalidation. The public equality option accepts a
comparator or false, not literal true.

The remaining discussion below concerns the promise's selected value and
override lifetime, separate from invalidation scope. “Immediate input producer”
means the boundary's own callback computation, not a memo that callback reads.

No refresh export or implementation has been added to the scalar entry. This
question concerns its eventual relative-input contract, not preserving the old
authoritative-view machinery or changing the already accepted override lifetime.

```ts
const [first, guessFirst] = createOptimistic(() => 0);
const doubled = createMemo(() => first() * 2);
const [second, guessSecond] = createOptimistic(doubled);
```

Action A guesses first=1 and remains open. Once that is published, action B
guesses second=10 and remains open. B subsequently calls `refresh(second)` and
keeps running after that promise resolves.

Verified pinned next (`a24e911ba5e571e7adb1c9b5e5151261f9cf101c`):

- Before refresh: first=1, second=10.
- After refresh, with both actions still open: first=1, second=2, promise result=0.
- Finishing B leaves first=1, second=2. Finishing A restores both to 0.

The promise reads a non-optimistic version of doubled even though doubled's
selected input is first=1. This relies on the old multiple-value machinery. Its
early replacement of second also differs from the accepted prototype lifetime.

Recommendation to ask the user about: refreshing an optimistic accessor explicitly
refreshes its **immediate input producer**, and its promise returns that input's
settled result. It crosses exactly the target boundary; it does not recursively
remove optimism from the input graph. Here the promise returns 2, and second
stays 10 until B ends under the already chosen lifetime rule. An ordinary memo
around second would still refresh its own calculation using second's selected
output, so it would see 10.

The alternative consistent contract is to treat refresh(second) as refreshing
only the output selector, returning 10, and require refresh(doubled) explicitly
for the input. The first contract preserves more of the usual purpose of
refreshing an optimistic primitive; the second makes invalidation entirely
literal to the target output. Both avoid a universal authoritative graph.

`refresh-layer-contract.mjs` runs the scalar and nested examples against next:

```sh
node experiments/layered-updates/refresh-layer-contract.mjs \
  /workspace/layered-baseline/packages/signals/dist/prod/index.js --nested
```

The ordinary quiet-refresh/waiter integration remains separate implementation
work. Its earlier failures in stage 37 have not been represented as fixed by
this audit. No old authoritative exception has been reinstated to satisfy it.
