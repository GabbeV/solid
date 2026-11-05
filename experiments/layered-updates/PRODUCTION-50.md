# Stage 50: observation forwarding exposed an earlier coordination error

The attempted production port is **rejected and restored**. No stage-50 runtime
change is retained. The accepted stage-49 policy is unchanged. The experiment
located a concrete missing seam in the production coordinator; adding a hold
predicate alone is insufficient.

## What the port established

Seven real-runtime tests exercised the accepted two-action example, direct
observer disposal, conditional removal, equal-valued owner replacement, removal
held by another update, a pending-only reader, and a closed action losing its
last observer. Six failed before the attempt. All seven passed after introducing:

- An active input-to-output observation registry consulted for pending work.
- Registration of ordinary pending work when a hidden input starts async.
  The existing runtime starts such an update when pending reaches a render
  reader; an override absorbs that status, so readiness alone runs too late.
- Retention of the input subscription, including explicit-clear test overrides.
- A disposal wakeup while forwarding is active.
- A visibility query for optimistic selectors. `CONFIG_REDERIVE` absorbs their
  status but must not make the selector itself a permanent display observer.
  Without this distinction, a closed action remains stuck after its last
  observer disappears.

These seams touch async registration, readiness, and disposal. No ordinary read
or node field was changed. The prototype is not retained because broader
composition still failed; this limited success is not a completed integration.

## Same-action nesting reveals the missing origin

```js
const [first, guessFirst] = createOptimistic(() => 0);
const middle = createMemo(() => first() === 1 ? answer.promise : 0);
const [second, guessSecond] = createOptimistic(middle);
createRenderEffect(first, showFirst);
createRenderEffect(second, showSecond);

action(function* () {
  guessFirst(1);
  guessSecond(2);
  yield end.promise;
})();
```

While `middle` is unanswered:

| Implementation | first / second |
| --- | --- |
| Pinned unmodified next | 1 / 2 |
| Accepted reference model | 0 / 2 |
| Production port with forwarding only | 0 / 0 |

The first difference is the accepted observation policy: the displayed override
continues to observe the lower calculation. The second is an implementation bug:
the upper override should publish independently of that lower calculation.

`settleLayers` stages both guesses before either propagates. Neither input is
held yet, so both take `stageLayer`'s no-held-input fast path. The later async
work creates one ordinary transaction for both. The existing coordinator tries
to discover the cut from held ownership, after it has already lost the distinct
proposal origins. With observation dropped, both previously escaped together;
forwarding observation exposes the wrong shared publication unit.

Explicitly assigning each boundary a transaction and evaluating its output in
that transaction produces 0 / 2 here. It fails the broader layered suite:
19 assertions fail, including detached-child initialization, ownership, and
async-publication cases. Two nested-input expectations also encode the old
observation policy; those differences are intentional policy changes, but do not
explain the remaining failures. No failing consistency assertion was weakened.
The independent-transaction patch was therefore rejected as well.

The initial forwarding-only run had 286 passes, two existing expected failures,
and two failing tests: one old-policy expectation and the same-action bug above.
Its result does not override the failed broader replacement experiment.

## Consequence for the next port

Proposal origin must exist **before** assigning storage ownership or propagating
the batch, even when an optimistic input has not suspended yet. `CONFIG_HELD`
and the ambient `flushTransaction` cannot be the source of that information.

The next replacement must implement these responsibilities together:

1. Record independent boundary proposal origins before dispatching queued work.
   Action lifetime remains separate from proposal publication.
2. Propagate each computation's obligations to pending origins. Reading an
   existing obligation must not send another notification.
3. Select the eligible context before evaluating; register new dependencies
   before selecting their value. Discovering a higher context invalidates the
   provisional pass, rather than retroactively accepting its values.
4. Revalidate affected candidates when context relations or peer groups change.
   Cancellation does not erase work owed to other origins.
5. Publish through the ordinary value, async, error, child-frame, and effect
   mechanisms after that validation. Forwarded observation is a separate input
   to readiness, not a value read or membership edge.

Use sparse metadata for pending nodes, activated by nonordinary contexts; do
not add a general version lookup to settled reads. Ordinary synchronous work
can keep its existing representation. Boundary proposals may pay for explicit
origin records. The reference scheduler already expresses the protocol, but
its broad scans and allocations are not a suitable production representation.

This is the same architectural issue identified by stage 46, now demonstrated
before any async answer or peer-group split: the incomplete port cannot assign
origins correctly even at the beginning of a single batch. A further local
change to release conditions would not solve it. No new user ruling is needed.

## Artifacts and reproduction

`results/production-observation-stage50/` retains the four exact pre-change
source files, the forwarding-only layer, the rejected separate-proposal source,
all failing logs, and the seven-test contract. The contract is archived outside
the active suite because the production port is rejected; its assertions remain
intact. Copy it to `packages/signals/tests/layered-forwarded-observation.test.ts`
in a disposable checkout to run it. The first port can be reconstructed using
`forwarding-layer.ts` and the other three files in `rejected-port/`.

The ordinary public-API timeline runs without internal test helpers:

```sh
node experiments/layered-updates/forwarding-batch-audit.mjs \
  /workspace/layered-baseline/packages/signals/dist/prod/index.js
node experiments/layered-updates/forwarding-batch-audit.mjs \
  /workspace/layered-solid/experiments/layered-updates/reference/scalar-runtime.mjs
```

Both executions are retained as JSON. The reference test now covers this
same-action case with and without tracing. Existing production sources were
restored byte-for-byte from the pre-attempt snapshots; no rejected patch is
active, and no new production performance/size claim follows from this attempt.
