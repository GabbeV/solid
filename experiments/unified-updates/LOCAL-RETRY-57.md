# Local retry versus later context revision

The user asked whether cancel/retry is local and therefore potentially acceptable.
Do not interpret stage 56 as banning every internal retry or every repeated memo
execution. Its demonstrated failure changes a separate request after a suspended
input beneath an override discovers ancestry. Local synchronous repair is a
distinct choice, and next itself does it, including after user code starts work.

## Verified against pinned next

`local-retry-audit.mjs` records invocation and publication separately, using
controlled promises. Baseline is a24e911ba5e571e7adb1c9b5e5151261f9cf101c.

1. A memo reads an initially unresolved dependency before issuing its request.
   Both next and the current reference execute its body twice, but issue only
   one request after the dependency answers. The first run throws at the read.
2. Start x=0 and view=optimistic(0). One open action writes x=1 and guesses
   view=10. An async memo reads both and records each request. Ordinary-first
   reads in next issue `1:0`, `1:10`, `0:10` before any request resolves.
   Optimistic-first reads issue `1:0`, `0:10`. After resolving those requests,
   both publish `0:10`, with the action still open. `1:0` is common work before
   the guess takes effect; `1:10` is the extra pass repaired by lane bookkeeping.
3. The reference issues `1:0`, `0:10` for both orders. After those requests
   answer it also starts `1:10`, illustrating its separate ready-lower admission
   behavior. This is an actual completion, not the stage-56 discovery-only event;
   it is not declared correct or incorrect by this audit.

Next's `core/lanes.ts::enterLane` detects an earlier staged read when a pass
first enters a lane. `core/core.ts::stagedRead` records it, and the lane seam
queues a fresh pass against committed ordinary inputs. This can happen after
the user function has returned a promise. Superseded promise identity suppresses
its answer; it does not abort arbitrary network work. Iterator teardown and
user cleanup are separate mechanisms.

The production prototype's `computeLayer` also validates after invoking the
body and can retry it synchronously. The reference has read-time RETRY plus
later candidate invalidation. None of these should be described collectively
as bookkeeping-only cancellation.

## Distinctions for the design decision

- Retry before reaching a request: ordinary suspension, already supported.
- Repair this computation during its synchronous preparation, possibly issuing
  extra work: present in next; candidate acceptable tradeoff, not yet a new ruling.
- Revise an already-running computation because another suspended computation
  discovers graph structure later: stage-56 reference defect; pinned next does
  not do it in the tested fixture.

Local repair need not imply global ancestry revision. It also cannot by itself
solve dependencies hidden behind an unresolved read: those only become known
later. No coordinator implementation changed here, and no claim of universal
request stability in next is warranted.

Artifacts: `results/local-retry-stage57/{next,reference}.json`.
