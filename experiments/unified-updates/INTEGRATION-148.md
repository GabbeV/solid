# Keep commit callbacks with the publication they complete

The #4567 web fixture exposed two separate things:

1. Its async memo read the optimistic accessor again inside `.then()`. That
   imperative read depends on next's flushed-outside-read exception, which this
   experiment deliberately does not retain. Capture the value synchronously so
   the promise answers the question it started with.
2. Even with that correction, a user effect ran with value 1 before its child
   DOM was attached. This was a scheduler defect, also reproducible for ordinary
   updates. The old test expected next's user effect to see the attached child
   still displaying 0; that expectation does not establish the intended
   render-before-user contract.

## Mechanism

When a landing has stale readers to recompute, `land()` already delays the
update's stored callback queues until the following pure/render round. But
`commitPendingNode()` can enqueue more callbacks while committing the same
update. Those went directly to the current global queues. A new user callback
therefore ran before the deferred render and attachment callbacks.

Route callbacks generated during that commit into the same held queues when
`reruns()` requires another frame pass. Restore the global queue in `finally`.
The existing release operation publishes them together. No new node state,
read-path condition, dependency walk or sibling ordering rule is added.
Ordinary settled synchronous propagation is not changed; no performance claim
is made for active landings.

## Evidence and contracts

Eight JSX controls cover ordinary versus optimistic writes, scheduled versus
unscheduled render effects, and direct versus memo-wrapped reads. They verify:
no value-1 callback before the controlled async answer; the final complete DOM;
exactly one render/user callback for 1; render before user; and the full DOM
observed inside the user callback. They do not pin order among sibling render
callbacks. Before the fix four fail and four pass; after it all eight pass.

Pinned next 4fe75321 passes two and fails six: the user callback sees a missing
child, stale child 0, or an empty child binding. The captured-value version of
next's original #4567 fixture still passes its original expectations. The
migrated fixture instead requires user effects to see the complete rendered
frame and retains exact effect values/counts. This is a correctness fix, not
an intentional exception for tearing or a newly imposed sibling order.

`docs/QUEUE_EXECUTION_CONTROL.md` describes render effects before user effects.
`heldRun` in boundaries.ts explicitly preserves user effects' ability to read
attached DOM. The #4557 issue and #4567 commit focus on defer, one run per write,
and holding first effects until reveal; no human comment found on #4567 asks
for the particular stale DOM snapshot in its test. The issue's closing comment
is explicitly AI-generated. None of that stale snapshot is used as a semantic
constraint here.

## Validation

- Full signals: **5,384 passed / 2,047 failed / two skipped**. No new failures.
  Five existing #4341 joined-branch effect failures pass with unchanged
  assertions. Its remaining nested-memo case remains open.
- Source web focus: **13 passed**, including the eight new controls and the
  existing #4557/#4567 fixtures.
- Production-mode scalar focus: **676 passed**, including all 654 unified
  tests, effect-mount guards and the new node-less store frame tests.
- Normal build, property mangling, purity checks and declaration compilation
  pass. Rules-index and diff checks pass.

- Full web against rebuilt artifacts: **1,689 passed / 128 failed / one
  skipped**. Eight new controls pass and the migrated #4567 test passes; no
  new old-suite failures.
- Remaining signals inventory: 1,953 deferred API, 78 untriaged, twelve
  calculation expectations and four implementation-bug cases. Web: 115
  deferred API, seven untriaged, six calculation expectations.

 The instrumentation
and temporary source/next configurations are archived as investigation receipts,
not shipped runtime. Receipts: `checkpoints/integration-stage148.tar.xz`.
