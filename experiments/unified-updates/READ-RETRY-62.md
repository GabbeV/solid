# Stage 62: read-time retry integration rejected

The scalar core is **not ready for expansion**. This iteration tried a real-core
read/recompute retry path, found regressions, and restored the six edited source
files byte-for-byte to stage 61. There is no retained runtime fix from this
iteration. The new tests and production audit are retained. Stores remain out
of scope.

## New evidence

The new `unified-read-retry.test.ts` matrix first opens an action that proposes
`x = 1` while `x = 0` remains committed, then mounts this calculation:

```ts
const pair = createMemo(() => {
  const first = x();
  const pending = isPending(x);
  const last = x();
  return [first, pending, last];
});
```

Variants use `latest(x)`, an async function body, and an observation reached
through one or three owned memos. Render effects are scheduled. Tests inspect
completed bodies as well as publication, and verify cleanup of discarded
children. The async variants use ordinary promise-returning functions; there
is no microtask choreography to manufacture the failure.

These tests expose two implementation bugs in the retained checkpoint:

1. Eight cases finish an initial body using the lower proposal, then recalculate
   using the committed lower value. For pending, completed bodies include both
   `[1, true, 1]` and `[0, true, 0]`, although the displayed result is the latter.
   A request issued after collecting those inputs could already have started.
   This is additional early-retry coverage, not a claim that these eight cases
   display torn values.
2. Four async cases with owned observers repeatedly dispose and revive the
   observation output. They do not publish before the test's explicit bound of
   32 calculations. The bound disposes the root and fails an assertion; it does
   not turn nonconvergence into success. This is a publication/liveness bug.

All twelve are recorded as expected failures with unchanged consistency and
lifetime assertions. These are known implementation gaps, not accepted semantic
changes or deferred APIs. The earlier unrelated-mount stale-request failure also
remains an expected failure.

`read-retry-audit.mjs` independently exercises all twelve programs against the
actual production builds. Baseline is unmodified tracked source at next commit
`a24e911ba5e571e7adb1c9b5e5151261f9cf101c`. Candidate is the rebuilt, restored
scalar entry. Each program runs in a separate process.

| Observation during the open action | Pinned next | Restored candidate |
| --- | --- | --- |
| First completed pending body | `[1, true, 0]` | `[1, true, 1]` |
| Sync owned pending reader's publication | `[1, true, 0]` | `[0, true, 0]` |
| Async owned observation | Finishes its limited recalculations; no publication in this timeline | Reaches the 32-calculation bound; no publication |
| Final cleanup of created owned memos | Exactly once | Exactly once after bounded disposal |

Latest has the corresponding numeric observation in place of `true`. The
baseline's within-body change and its mount holding are reported as behavior,
not adopted as requirements. This audit does not exercise eventual release
publication: it disposes the mounted reader before ending the action.

## Rejected implementation

The first attempt moved retry handling into core recomputation. A conflicting
read threw before returning its value; async function results were discarded
before registering the aborted promise as a flight. It added optional read and
recompute hooks, an attempt context, and a cold map of result positions.

After correcting initialization of source-owned observations, the attempt
passed the twelve new cases and the stale ordinary-request test. That was not
sufficient: a broader run had 17 failures, including sibling publication and
ordinary peer coordination. A follow-up adjustment had 21 failures. A smaller
attempt to initialize observation transactions before their first calculation
also failed to converge in broader testing and was abandoned.

The routing attempt mixed two distinct operations:

- Reading an already published higher-layer output while calculating a lower
  update.
- Consuming a higher-layer proposal that requires an independent context.

A persistent result position could promote ordinary work just because it read
a published output. Conversely, first observation initialization could inherit
its caller's lower transaction, then merge that transaction into the supposedly
independent retry. One intermediate trace completed `[0, 1, 1]`: the second
ordinary read changed posture during the body. Changing result-position tests
repaired some examples but broke others. This is a reason to reject that
integration, not evidence that the accepted stable-context model is impossible.

The previous speculative adapter is still present. It has **not** been replaced
or simplified successfully. No performance or size result from the rejected
implementation is presented as an improvement.

## Direction for the next implementation

Separate context arbitration from irreversible transaction merging. The next
bounded experiment should establish these mechanics before changing existing
publication routing:

1. Keep the triggering update's context distinct from the context of a value
   being read. A published output must not carry a blanket instruction to
   promote its reader.
2. On the active coordination path, identify a proposal consumption before
   merging holders. If discovering a boundary invalidates the current attempt,
   abort before returning that read and before registering its flight. Investigate
   deferring joins until the attempt is accepted; do not assume merges can be
   reversed afterward.
3. Establish a source-owned observation's initial output context before its
   first computation can inherit the caller's hold. Exercise disposal/revival
   immediately, without retaining an extra permanent subscriber to hide loops.
4. Preserve the existing scheduled/unscheduled effect and parked-child rules.
   Run sibling, branch-switch, and ordinary-peer cases alongside the smallest
   retry example throughout integration.

This is an implementation hypothesis, not a new semantic ruling or a proven
solution. No additional user decision is needed for these checks. The next
checkpoint must demonstrate that these distinctions compose before replacing
more of the coordinator. Ordinary settled reads should not acquire a journal,
allocation, or general layer traversal.

## Reproducibility and final state

Artifacts are in `results/core-retry-stage62/`:

- `before/`: six source files before the attempt.
- `rejected-routing/`: broad retry attempt, known incorrect.
- `rejected-initialization/`: smaller initialization attempt, also rejected.
- `restored-source-sha256.json`: fingerprints of the restored source files.
- `production-audit.json`: all 24 production runs, including pinned next.
- Logs for rejected runs, restored regressions, build, types, and final tests.

Example audit invocation from the repository root:

```sh
node experiments/unified-updates/read-retry-audit.mjs \
  /workspace/layered-baseline/packages/signals/dist/prod/index.js isPending async 1
node experiments/unified-updates/read-retry-audit.mjs \
  packages/signals/dist/scalar/index.js isPending async 1
```

Final verification after restoration:

- Full signals suite: **5,472 pass, 35 expected failures, 2 skipped**, 325 files.
  The expected-failure count increased by twelve; this is additional recorded
  missing behavior, not twelve correctness passes.
- Source declaration type check passes.
- Scalar production build completes, with the existing unrelated test-file type
  diagnostics and circular dependency warnings.
- All six edited runtime source files exactly match the pre-attempt checkpoint.

The existing stage-61 measurements against next remain the last measurements of
the retained implementation. They are not new measurements, and passing the
restored suite does not close the newly documented gaps.
