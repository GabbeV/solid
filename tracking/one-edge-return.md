# Constructed one-edge settlement return

The queued actual after-trim / pending traversal / scheduling segment now has a
constructed return bound from input graph facts, with arbitrary World, source
identity, leaf identity, payloads, caller tasks and caller value stack:

- The input fault is Healthy.
- The source subscriber head is a nonzero edge to a selected leaf, and that edge
  has no next subscriber.
- The leaf has no downstream subscribers and no auto-dispose configuration.

`one-edge-settlement-return.bend` derives a `BoundedReturn.Returned` certificate
with ten steps of room. The certificate contains the actual number of steps,
unused room, actual resulting World, an equation that used plus unused is ten,
and the exact equation from repeated actual `Core.step` to the unchanged caller
work/stack. It does not assume a successful visit, an output queue layout or a
final-machine equation. A no-stale dependency trim composes to twelve steps of
room, using its earlier exact two-step whole-World return. The original direct
no-subscriber six-step family and all earlier domains/budgets are retained.

Initial Healthy fault is not global readiness/no-halt. The visitor may fault on
malformed transaction state, and that actual fault remains on return. A normal
retirement takes ten steps in the current fixture; an early-return visit may take
nine, and a fault in the visitor takes five. No global forest validity, carrier
presence, healthy final status or successful publication is inferred.

## Control abstraction and exact World

`pending-visit-control.bend` proves an intermediate task/release observation:
actual `Pending.advance` on a non-autodisposed leaf either keeps its queued tail
or prepends a zero-cursor walk, and preserves the prior release list. It covers
already-visited, retry, missing-carrier and successful-retirement branches with
arbitrary identities. The graph footprint derives the needed shape after retry
and source removal. The core bridge retains the World computed by that exact
`Core.step`, observes its queue, and uses the existing stack theorem. It does not
replace that World with an idealized state or require another World equality.

The return suffix separately proves seven healthy bookkeeping steps or two fault
unwinding steps. An early visitor return omits one healthy step. Generic actual
prefix composition supplies the ten/twelve bounds. Committed-content composition
retains every cached node value, the entire tree and complete event trace through
the complete ten-step-room segment, including its shorter fault alternative.
The concrete driver corollary leaves the caller's requested remaining fuel
unchanged after the actual used steps. Zero remaining fuel with unfinished caller
work still follows `Core.run`'s Exhausted/empty work/stack policy; no budget or
checker limit is increased.

Whole-machine visitor-equality attempts (including a fixed source slot and a
scratch visitor extraction) exceeded the pinned checker reduction limit. They
remain unverified and are not used by these active proofs. The observation-based
control contract recovered arbitrary identities without applying that scratch
extraction or narrowing the active theorem. Runtime, source, host and limits are
unchanged from 32b007df; no semantic deviation is active.

## Evidence and limits

Eight roots extend the earlier 500; all 508 compose. On the existing 240 paired
joined-flight histories, private forks provide 80 actual ten-step returns, 40
trimmed twelve-step returns, 240 exact actual-driver splits and 80 explicit
zero-fuel exhaustion controls. Further private forks exercise 80 absent-carrier
nine-step returns and 80 redirect-cycle five-step fault returns, retaining the
same committed frame and caller stack. These malformed/partial-state controls
are not native public-program reachability claims or upstream bugs. The 4,750
public corpus and 2,280 selected observations remain unchanged.

Three new faults are rejected: wrong subscriber cursor (kernel), a forbidden leaf
release (finite control), and early publication during scheduling (kernel).
Configured totals are 633 = 484 finite /149 kernel; no complete633 sweep is
claimed. [Receipt](reviews/one-edge-return-validation.json).

This is local bounded internal completion and content safety, stopping before
queued owner callbacks/flush. Public construction and preservation of the input
graph, complete action/flight accounting, source readiness/error policy and
coordinated reveal remain open. No statement here proves eventual host delivery,
callback termination or publication fairness.
