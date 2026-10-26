# Executing an action method's return

The previous admitted-method family reached `Evaluate`/`ActionStepReturn` before
executing the method. This extension crosses that boundary using the shared core
step relation. It changes no runtime, source pin, host semantics or checker limit.

## General operation contracts

- `action-output-frame.bend` proves that actual action output handling changes
  only `asyncObjects` and `hostJobs`, for every represented return/rejection value
  and every prior result state. All other World fields and the arbitrary caller
  value stack survive. A returned thenable may enqueue adoption rather than settle.
- `transaction-route-transport.bend` transports the actual resolver certificate
  across a proved transaction-arena frame. It reuses actual `into` fields and the
  original structural fuel room; it does not assume the next resolver's answer.
- `action-body-return.bend` executes a literal `StepResult{true,value}` and its
  `ActionStepReturn` in exactly two real steps. Initial health is explicit. Its
  conclusion is the actual `actionDone` operation, with caller continuation and
  saved stack retained at this boundary.
- `action-body-entry.bend` connects actual captured-question installation,
  `joinFuture`, method advancement and callback binding to that body. Both next
  and caught-throw methods return the same arbitrary represented value; the
  incoming fulfillment/rejection and remaining generator methods are arbitrary.
- `action-body-retirement.bend` connects the two steps to decrementing a positive
  obligation at the captured live representative. Its arbitrary-World theorem
  requires an entry route, capture, sufficient arena room and positive count;
  output processing preserves the exact remaining World except the two output
  fields above. It covers arbitrary remaining debt, including joined groups.

These are Bend semantic contracts with reviewed source correspondence, not a
formal TypeScript/Bend equivalence claim.

## Construction and histories

`action-context-reconstruction.bend` provides a proof-side record lens: restoring
exactly the four callback tables erased by the established helper-history
invariant recovers the original World. This is a proof device, never an extra
runtime transition or replacement scheduler.

`action-body-constructed.bend` uses actual action creation/opening, Promise and
wait allocation, any finite admitted helper prefix, the real first callback,
method evaluation and return. It derives body health, actor capture, a terminal
route, resolver room and one outstanding obligation. None of the final count,
settled mark or completion transition is an input premise. Its exact outer-World
conclusion is the real scheduled decrement to zero.

`action-body-guard.bend` preserves the actual settled lookup through completion
and arbitrary later admitted helper histories. A stale fulfillment or rejection
retains the exact *current* Machine, including its continuation, saved values and
counts. `action-body-debt.bend` exposes the zero-count corollary after those
suffixes. The earlier End and arbitrary pre-evaluation Body domains remain.

The helper alphabet is the existing private callback-table protocol. Arbitrary
prefixes may register synthetic clients or reserved stream-zero probes; this
family does **not** prove that every such history is a complete reachable public
JavaScript program. In particular, its callback entry does not first settle the
input Promise object. Full public invocation-to-host delivery reachability and a
whole generator/flight identity ledger remain separate obligations.

## Completion and publication

Solid calls `done`'s group decrement before resolving/adopting the returned value.
The proof therefore distinguishes zero scheduling-group debt from a settled
output Promise. It does not assert that all represented returns fulfill
immediately, that a pending adopted Promise must settle, or that the queued
observer delivery, `ActionSliceEnd`, public flush and rendered reveal have run.

The literal body supplies its own termination proof. Arbitrary user-code
termination, real signal writes within a body, rejection escaping the body,
supersession/disposal and publication through nonempty rendered flights are
unfinished. Initial health and route conditions of generic contracts are supplied
by the constructed specialization; they are not blanket global assumptions.

## Verification

Nine composed roots extend649 to658 without removing previous roots or changing
budgets.1,950 actual body returns across65 sampled helper orders and15 payload
representations,3,900 exact stale-Machine checks and130 pending-adoption controls
pass. Sixteen independently authored native generator/port cases cover fulfilled
and rejected source callbacks, ordinary returns, pending Promise adoption and
stale callbacks. These finite checks support the general contracts; their counts
are not a progress percentage.

The compact negative oracle passes unchanged. Five new source-changing variants
must compile before rejection: missing depth exit, incorrect stored method tail,
lost wait guards in ordinary/adopted output and corrupted caller stack. The
mutation runner now requires a passing unchanged kernel oracle before credit.
An initial typo caused the new oracle itself to fail; its apparent rejections
were discarded and are not evidence. A malformed-oracle control verifies that
the runner refuses credit before testing a mutant. Current configured totals
and completed frozen sweeps remain distinct in [verification.md](verification.md).
