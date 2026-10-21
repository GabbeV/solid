# General semantic properties

These are quantified properties of the actual Bend runtime, separately from the
64 concrete end-to-end regressions and separately from TS/Bend correspondence.
No source operation or runtime representation changed to make these proofs pass.

## Publication at any existing slot

[publication.bend](../proof/publication.bend) quantifies over every World, every
finite arena prefix/suffix, every node and every admitted Value. The target index
is the prefix length, so it exists by construction; no unchecked index or graph
invariant is assumed.

- commitValue publishes the exact pending value and clears its pending slot.
- All other node fields, all surrounding nodes and all other World fields remain
  identical. This includes dependencies, queues, owner links, callbacks and IO.
- An empty pending slot makes commitValue exact identity.
- Repeating commitValue is idempotent, for either pending-slot shape.

The proof uses general list get/set lenses in [arena.bend](../proof/arena.bend).
Its loaded/clear expressions are proof-only algebraic forms of the two actual
stores; loadedEq checks them against scheduler.commitValue. They are not another
scheduler or an assumed reference algorithm. This does not prove computed-node
commit, effect execution, or completion of the whole transaction machinery.

## Read policy

[read-policy.bend](../proof/read-policy.bend) quantifies over Worlds, node arenas,
target IDs, caller task continuations, stacks and payloads:

- The plain-signal fast-read helper, with a normal zero sentinel and no owner,
  serves the committed value, records its read event and preserves tasks/stack.
- enterRead with no reactive reader leaves the World unchanged and joins no hold.
- At serveSelected after status/unflushed selection, no reader selects the
  committed value when no unflushed value was supplied.
- A supplied unflushed value takes precedence and marks the late linker.

These are properties at the named source helper return points. They do not say
every read reaches those points: eligibility, missing/error status, pulling and
active scope policies still matter at the callers.

## Complete numeric data-signal program

[signal-staging.bend](../proof/signal-staging.bend) proves a whole program for all
numeric initial and next values, with equals:false:

1. Construct the normal root and a data signal using the actual API.
2. Set its next value. A public read before flush returns the initial value.
3. Flush. A public read returns the next value.
4. The flush completes in 19 core steps. For every additional fuel allowance,
   the same final state has an empty pending/render/user queue, cleared pending
   slot, restored context/tracking/stale/running state and a healthy fault slot.

The ordinary host-job queue is not claimed empty: a manual flush leaves the
already-requested external flush job for the host to consume.

[signal-driver.bend](../proof/signal-driver.bend) supplies actual API inputs and
core.step. [The generator](../tools/signal-witness.mjs) records canonical states
from one emitted execution, replaces the two payloads with variables, and emits
19 step equations plus a finite Path. Every equation is checked by the independent
kernel for all numeric inputs; the generator and its sampled execution are not
trusted to establish the result. Existing generic Path.realizes composes those
steps, and checked equality transports connect them to the original API program.
Regeneration is deterministic and tools/check verifies the artifact is current.

This is a general payload/progress result for one fixed graph and comparator
setting, not arbitrary graph/history correctness or TS equivalence. Directly
unfolding even this symbolic flush exceeded the pinned kernel's reduction fuel;
canonical transitions and small equality transports avoid that expansion without
changing the runtime, raising the kernel budget or adding an axiom. The larger
arbitrary-payload memo-chain proof is still a separate unfinished step. A scratch
95-transition chain witness passed its individual symbolic steps and typed Path,
but the setter-to-staged bridge and composed flush proof exceeded the available
16 GiB memory. That experiment is outside the active proof roots and is not
counted as a completed semantic theorem.

## Flush callback scope and finally

[flush-callbacks.bend](../proof/flush-callbacks.bend) adds three quantified local
properties: entry changes only syncDepth and installs the body/finally tasks;
restoration keeps the drain's World while restoring the immediately enclosing
depth and saved operands; and a callback throw still enters the public drain
with its original error retained in a finally task. They quantify over arbitrary
Worlds, continuations, operands, callback syntax and fault/value inputs as stated.
Two separate closed executions check nested return/commit order and error
precedence. These do not prove arbitrary callback completion or a global drain
progress bound. [The source review](flush-callbacks.md) records the action/dev
exclusions and original-function read-observation boundary.

## Sensitivity and limits

Two additional compiled source variants are rejected by the quantified kernel
properties themselves: losing the new value during publication, and serving a
staged value from an unowned fast read. The other 122 mutation variants remain
differential/observation checks. These evidence families are not conflated.

General structural validity of all graphs, arbitrary callback/async/lane scopes,
full progress bounds for variable graphs and arbitrary-length histories remain
open. Numeric theorem parameters are Bend terms; this is not a new claim about
unbounded JavaScript integer execution or the compiler's correctness.

## Comparator call and catch properties

[comparators.bend](../proof/comparators.bend) proves five quantified local
properties over arbitrary Worlds, caller continuations, operand stacks and
relevant values: default selection retains the old fast helper; custom selection
calls the original identity with exact old/new arguments; NotReady returns raw
undefined and clears the control throw; ordinary errors route through the node
status notifier and return true, retaining any notifier failure; registering
metadata preserves the entire remaining World. Explicit lookup/classification
premises select the source arm. Four additional closed public executions cover
suppression, changed publication, ordinary errors and pending reads. These are
local semantic guarantees and fixed-program regressions, not general comparator
termination or graph correctness.

## Staging a changed memo

[publication-stage.bend](../proof/publication-stage.bend) adds three quantified
properties at recompute's actual publishValueChanged helper, complementing the
commitValue properties. After a successful equality gate, an existing non-effect
stages its proposal and then conditionally calls the actual subscriber notifier;
it does not use the direct creation/effect arm. The isolated pending-slot store
preserves every other World/node field at any existing arena position. For a
memo with no subscribers, the complete helper therefore updates exactly that
pending slot, preserving the old committed value and the entire remaining World.

Worlds, arena prefixes/suffixes, payloads, old heights and joined flags are
quantified. memoShape explicitly fixes Memo kind and a null subscriber head;
it does not claim arbitrary well-formedness. The changed flag is the caller's
successful gate, and create is false: this is not a proof of comparator policy,
all recompute paths, notification correctness or eventual commit. The proof-only
loaded form names the original effect/subscriber locals and is checked against
the actual runtime helper. No runtime operation was changed to obtain this proof.
A compiled mutation that overwrites the committed value instead of staging is
rejected by the quantified kernel checks.

## Lazy extension allocation

[extension-laws.bend](../proof/extension-laws.bend) proves four properties of the
actual ext helper for every existing node position and surrounding arena:
an already nonzero extension ID leaves the entire World exactly unchanged;
a first allocation appends exactly one blank extension and changes exactly the
node's x field; the new pointer retrieves the exact default record; and repeated
allocation is idempotent. Worlds, node fields and extension lists are quantified.
Idempotence requires a nonempty extension list, the runtime's sentinel-storage
invariant. Without that premise, an empty arena would allocate index zero, which
still means absent; no theorem silently assumes arbitrary records are valid.
Existing nonzero IDs are not asserted valid merely because ext returns early.

## Reactive cleanup capture

[cleanup-laws.bend](../proof/cleanup-laws.bend) proves three local properties of
the actual normal-frame runDisposal/dispatch return points. Every admitted list
representation (none, one callback, an array) is detached from its owner before
any invocation, with the exact captured callback tasks followed by EffectCleanup.
A detached list is not replayed, and the loop selects the last registered callback
before the preceding prefix. World/node fields, callback IDs, arrays, caller tasks
and the self flag are quantified; unrelated World fields remain unchanged.

These are reactive onCleanup list properties, not an error-policy ruling or a
claim that teardown continues after a throw. They do not say an effect-returned
cleanup cannot still run, that reentrant registration is discarded, or that a
zombie-frame disposal uses the normal field. The module-global collector leak
remains preserved at its source prelude. Existing public teardown/reentry/error
histories remain the behavioral evidence for interactions outside these helpers.

All seven properties use proof-only loaded locals checked against actual source
helpers; no runtime refactor or alternative evaluator was introduced. Three more
compiled mutations are rejected by proof-property assertions (the checker may
reject a corrupted theorem before reaching the independent kernel). Positive
proof claims always require the independent verdict.

## Conditional scalar-memo drain

[memo-staging.bend](../proof/memo-staging.bend) proves a drain of the actual
public flush for every natural-number proposal and every budget of at least
40 steps. Its precondition is the exact staged graph family in
[memo-states.bend](../proof/memo-states.bend): one source committed to zero, its
staged proposal, one eager memo computing source + 1 with equality disabled,
and the corresponding fixed heap/dependency/owner/queue state. The result has
committed source n and memo n + 1, no pending intake, restored ambient state,
no running/scheduled flush and no control fault. The composed equality also
identifies the complete final World, beyond the public View projection.

This is a quantified graph-family theorem, not a concrete replay. The witness
is generated by tools/memo-witness.mjs from the actual API/core driver at one
sample, then each actual core.step equation and the composed theorem are checked
for every n by the independent kernel. The generator is untrusted and --check
rejects stale data. Proof-only source-gate cuts and abstract API/machine/budget
transports avoid evaluating the entire run during kernel conversion; they are
also independently checked. The runtime was not split or altered for the proof.

The constructor/setter bridge is now checked separately by
[memo-public-program.bend](../proof/memo-public-program.bend). The original drain
lemma retains its explicit precondition, while the complete public theorem below
closes this fixed family. Eight finite controls additionally compare the boundary
and resulting values with unchanged pinned Solid; those are correspondence
evidence, separate from the proof. The larger two-memo/render graph remains
unproved. Nat arithmetic does not establish IEEE-754 behavior for unbounded numbers
or TS/Bend equivalence. The compiled increment-dropping mutation is rejected by
the quantified proof-property assertions.

## Complete scalar-memo public program

[memo-public-program.bend](../proof/memo-public-program.bend) proves the actual
public constructor, setter and flush composition for every natural proposal n
and every additional drain budget:

1. Construct a numeric signal at zero and an eager memo computing source + 1,
   both with equality disabled, under the normal root.
2. Call the public signal setter with n. Its whole resulting World equals the
   specified staged arena used by the drain theorem.
3. Flush with 40 + extra steps. The source commits n and the memo commits n + 1;
   pending intake is empty, caller context/tracking is restored, the flush is
   idle/unscheduled and no control fault remains.

The constructor has a checked 14-step eager path plus its actual facade prefix
and accessor/owner restoration. The setter has a checked two-step core path and
its actual public validity, target-selection and budget boundary. Their bridges
are composed with the existing 40-step drain; no constructor/setter state is
assumed or replaced with the generator's sample. tools/memo-boundaries.mjs records
untrusted snapshots from the actual source helpers/core and rejects stale data.
Every asserted equation, source-gate cut and composition checks in the original
independent kernel. No runtime change was made for this proof.

The initial signal value is fixed to zero; the proposal is quantified. This is
one fixed graph topology without effects, custom callbacks or active engine
scopes. It is not arbitrary-graph progress, a general constructor invariant,
unbounded JavaScript arithmetic or implementation equivalence. The two public
staging/completion properties are counted separately from the 64 closed semantic
regressions and the three complete data-signal properties. A queued host flush
request may remain after a synchronous drain; the claim does not cancel that IO.



## Action depth and callback boundaries

[action-laws.bend](../proof/action-laws.bend) adds five quantified local laws:
entry followed by exit preserves the entire arbitrary World; a positive-depth
flush callback runs directly with the exact caller stack and no finally/drain;
plain flush is identity at positive depth for every fuel; duplicate callbacks of
an already settled yield are exact identity; and a synchronous throw after yield
settlement clears only the control fault and restores the saved operands. The
entry/exit law assumes balanced entry; Nat represents nonnegative source depths.
The previous flush callback entry law now requires its source action-free guard.

Two separate closed executions construct a signal, invoke an action yielding an
immediate external thenable, flush to its held frame, then deliver a reconciled
value through the real action callback/transaction seam. They establish holding
and landing for that program. These do not assert arbitrary generator termination,
correctness of active optimistic/lane/store engines or general Promise semantics.
[The action review](actions.md) separates protocol restrictions, finite/native
controls, source correspondence and these proof domains.


The new public-program proof oracle rejects a compiled constructor that discards
its compute expression. A separate compiled setter mutation omits subscriber
intake: the old conditional drain theorem still passes because it assumes the
staged arena, while finite constructor/setter controls reject the changed public
boundary. Its initial proof-negative trial exhausted resources and was discarded;
resource failures are not counted as proof rejections.


## Scalar-memo construction for every numeric initial value

[memo-initial.bend](../proof/memo-initial.bend) generalizes the constructor part:
for every natural initial value and constructor budget >= 14, the actual signal
and eager source-plus-one memo constructor yields source n, memo n + 1, no pending
intake, restored caller state and a healthy idle scheduler. A symbolic 14-step path
and the exact public constructor facade reach the entire generated arena; the
View projection follows from that equality. Eight further finite controls compare
these arenas and pinned Solid values, including large admitted payloads.

This extends construction to every natural initializer. The separate complete
setter/flush program still starts its signal at zero; arbitrary initial and next
values have not yet been combined in one update/drain theorem. All prior numeric,
graph-topology, active-scope and TS-equivalence restrictions still apply. The
boundary generator checks both the fixed and symbolic constructor families.

## Transaction merge bookkeeping

[transaction-merge-laws.bend](../proof/transaction-merge-laws.bend) proves three
quantified properties of the actual transaction.mergeResolved helper: the target
open count is target.open + source.open, the source redirects to the target, and
the target action marker is target.acted OR source.acted. Both merge directions
between arena positions one and two are covered. Counts, flags, transaction
metadata, suffix arena and every surrounding World field are quantified.

The scoped input places a sentinel at zero and two represented ordinary roots:
redirects are zero and lane flags false. These are local bookkeeping properties,
not a proof of arbitrary valid global transaction graphs, redirect acyclicity,
landing progress or active optimistic/lane/mark/store engines. They support the
action invocation work's shared open-count and redirect machinery; seventeen
native-generator controls separately compare actual action behavior and joined
source open/action fields. The runtime was not changed for these proofs.
