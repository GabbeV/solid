# Attempt, retry, and transfer review

Source review at the stage-182 baseline; no runtime edits, builds, tests, or
timing measurements were performed. References below are relative to
`packages/signals/`. Candidate savings are unmeasured.

## Mechanism and attribution

- Ordinary recomputation selects previous history, installs tracking, executes,
  normalizes, and handles status/error/publication in `src/core/core.ts:380`,
  `:633`, `:660`, `:682`. `normalizeCalculation` is already shared between plain
  and layered attempts. Synchronous selectors deliberately bypass async probing:
  a literal promise can be their value. Primitive-result and object-result
  cleanup overlap with `src/core/async.ts:503`, but separating those fast paths
  avoids probing primitives. This is not demonstrated accidental duplication.
- One normal layered attempt: `computeLayer` (`src/layers/coordination.ts:969`)
  saves discovery globals, invokes `_fn(previous)`, checks a pending creator
  retry, normalizes inside the discovery context, and accepts reads in finally.
  `acceptCalculation` (`:881`) either defers private-child peer joins, passes
  reads to its creator, or joins accepted updates. Success and ordinary errors
  both accept discovered context; aborted attempts must not do so.
- One context retry: the same invocation/check/normalize/catch block repeats in
  `retryCalculation` (`:950` versus `:994`). Before it, retry-only reset (`:935`)
  consumes discarded promise rejection, chooses committed previous history when
  depth changed, invalidates the old flight, releases iterator teardown, disposes
  tentative children, increments dependency generation, clears discovery and
  dev thrown-read state. These are essential differences from a normal attempt.
- One transferred proposal: `adoptOutput` (`:1085`) selects output ownership,
  preserves staged value/status/flight, copies an owed effect callback, then
  `holdNode`/`list` (`src/core/scheduler.ts:769`) moves existing held-list links.
  Scalar ownership is already O(1), with one `_transaction` owner. There is no
  second flight owner to consolidate: async callbacks test node flight identity
  (`src/core/async.ts:566`, `:623`) and publish through its current ownership.
- Transfer differs fundamentally from rerun: unchanged-output adoption (`:1162`)
  recursively retains eligible leaf reader calculations/requests when other
  inputs are settled. Owned subtrees, effects, errors, and pending-without-flight
  readers require fresh work. Dropping this scan for unconditional enqueue would
  simplify source by restarting valid requests, contrary to the goal.
- Stage-182 attribution: coordination is 8,962 minified bytes for optimism and
  9,390 with observations; absent from ordinary core. Scheduler contributes
  7,512/7,731 respectively. These module totals cannot attribute either candidate.

## Bounded candidate: one inline layered attempt loop

Fold `retryCalculation` into `computeLayer` with one inline loop; do not add a
helper call to every first attempt. Keep outer context setup and acceptance
finally unchanged. The loop executes the current first-attempt try/catch, returns
when `retryEvaluation` is false, otherwise runs the existing retry reset and
continues. Reset occurs between iterations, never before the first attempt.

Delete the second `_fn` invocation block, duplicate `previousFlight` capture,
duplicate pending-owner check/rejection consumption, duplicate normalization,
duplicate `receiveOwnerRetry`/conditional-rethrow catch, the separate retry
function and its call. Retain all retry reset operations and the rejection sink
inside the pending-owner check: nested creator unwinding can bypass local reset.
Reset `result` before each invocation just as the current retry loop does.

This is source-supported duplication; extracting a common helper is an alternate
shape, not an assumed performance improvement. Current duplication may keep the
first attempt smaller for JIT optimization. An inline loop adds a backedge to that
function but no allocation, cache, node field, or ordinary-core branch. Expected
direction is fewer optional-coordinator bytes, uncertain layered throughput, and
unchanged request count. Minifier/JIT behavior can falsify the benefit.

Smallest validation: run `unified-read-retry`, `unified-stable-context`,
`unified-previous-context`, `unified-owned-adversarial`, `unified-equality-publication`,
and `unified-input-reuse`; include creator/user-catch controls from the existing
stage-173 selection. Check source and correctly configured mangled production.
Compare minified/Brotli scalar scenarios to the unchanged experiment before
claiming savings. Only then schedule exclusive layered timing against unmodified
next `4fe75321`; keep simple successful first attempts separate from retry-heavy
cases. Reject on changed request counts, cleanup counts, previous arguments,
unhandled rejections, error coherence, or material successful-attempt slowdown.

## Larger ownership candidate: unsupported at present

The initial idea of consolidating callback routing with proposal ownership does
not establish a redundant ownership mechanism to delete. `_modified` records a
run obligation, `_boundRunEffect` is its reusable runner, transaction queues record
publication scheduling, and `_transaction` identifies scalar proposal ownership.
`adoptOutput:1154` copies an existing callback into the new queue; it does not
remove a queue-owner field. `queueEffectRun` (`src/core/scheduler.ts:1885`) creates
an obligation, while adoption preserves one. `runEffect`
(`src/core/effect.ts:212`) gates stale/duplicate entries and held attachment.
Replacing the queue copy with generic enqueue can also change scheduling.

A larger design could derive all callback publication scheduling from current
node ownership, replacing transfer-time callback copies and stale queue entries.
However it would need to represent phase/order and obligations for every queued
effect without adding persistent ordinary-node state or scanning all held nodes.
No such bounded replacement is demonstrated. Do not implement a new attempt or
callback-owner object merely to rename these responsibilities. Keep separate
creator publication obligations from plan 1 unless a replacement proves them.
The smallest falsifier for any future design is two transfers before publication,
with an owed scheduled render callback, a held/private owner, and then disposal:
callback must run once in coherent order or zero times if disposed. Existing
render-scheduling, overlap, fresh-mount and effect-error-retry controls are needed.

## Constraints and recommendation

Stage 177 showed premature dormancy sweep duplicates lazy requests during creator
retry; retain microtask-spanning retry release deferral and immediate owned-child
disposal. Stage 178 rejected first-observation transfer in the common initializer;
keep feature-specific selection. Accepted peer joins cannot be rolled back by a
later retry. An async function or user catch can consume the thrown retry token,
so the explicit pending-owner check must precede normalization and acceptance.

Try only the inline attempt-loop consolidation first. Preserve transfer reuse,
committed previous selection, equality with lifecycle changes, exactly-once
teardown, and separate publication/lifetime judgments. Larger ownership work
currently has no supported deletion or demonstrated performance advantage.
