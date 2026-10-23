# General semantic properties

These are quantified properties of the actual Bend runtime, separately from the
72 concrete end-to-end regressions and separately from TS/Bend correspondence.
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

These are reactive onCleanup list properties, separate from the rc.17 cleanup error policy: these three laws alone do not
prove continuation after a throw. They do not say an effect-returned
cleanup cannot still run, that reentrant registration is discarded, or that a
zombie-frame disposal uses the normal field. At rc.17 the separate cleanup-policy laws below cover error collection; the
original collector-leak regression is positive. Existing public teardown/reentry/error
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

## Reusable action functions and general scalar-memo program

`proof/action-function-laws.bend` adds six local laws over arbitrary admitted
World/Expr/Value/task/stack data: wrapper construction modifies only the callable
arena; invocation enters the existing action engine with independent argument
capture; action parameters bind without consuming the resume binder; nested
wrappers shadow/capture parameters; enclosing callback parameters bind the factory.
Its repeated-call fixture is a separate closed execution, not a termination law.

`proof/memo-general-public.bend` proves the actual public constructor/setter/flush
composition for every pair of natural initial/proposed values, every constructor
budget `14 + extra` and every drain budget `40 + extra`. The graph is one data
signal and one memo computing source + 1, with equals:false, under the root and no
effects. `memo-general-setter.bend` closes the two-step public setter boundary;
`memo-general-staging.bend` checks all 40 actual drain steps. The previous-value
frame cuts now quantify the previous payload rather than assuming Number(1).

`tools/memo-witness.mjs` and `tools/memo-boundaries.mjs` generate the two-parameter
canonical data from actual emitted helpers/core.step. Only numeric payload samples
are replaced by the two symbolic parameters, independently. All resulting equations
and public API composition still need the original kernel's positive verdict.
Sixty-four additional canonical/native finite controls cover zero, equal values,
reversed values and large natural payloads. They support but do not establish the
quantified result. The original fixed-initial theorem and witnesses remain checked.

## Two-memo/render staged graph and publication composition

[The graph proof boundary](chain-proof.md) records the completed conditional
95-step drain, exact render-application trace, supporting fixed constructor lemma
and, now, its separately checked public setter bridge. The proposal is arbitrary
Nat, the drain budget is `95 + extra`, and the topology/initial zero value are
fixed. The complete public composition is recorded in the next section. Eight additional
finite controls compare public entry behavior and whole Worlds with pinned Solid;
they are separate from the quantified results.

`changed_memo_publication_stages_then_notifies` proves the actual default leaf
`core.publishValue` stages the changed value before notifying live subscribers,
under equals:false, non-effect and nonzero-subscriber premises.
`effect_publication_marks_and_queues_before_store` proves the corresponding
mark/queue/store order for effects with no subscribers and no pending slot before
or after queue preparation. Both quantify arbitrary admitted surrounding World,
payload, node and height; malformed-graph progress and arbitrary source custom
comparator execution are not claimed. They extend the previous changed-helper
laws through the default comparison entry.

Earlier scratch references above retain the old failed larger-graph experiment.
The active `chain-staging.bend` supersedes that experiment's composed-drain limit;
the new setter proof below closes its remaining boundary. Resource-limited
scratch attempts were discarded rather than counted as positive proof evidence.

## Complete public two-memo/render program

The staged-arena precondition above is now discharged by
`proof/chain-setter.bend`. `chain-subscriber-step.bend` proves each of the two
actual notification iterations for arbitrary remaining fuel in its canonical
arena. Keeping that fuel symbolic prevents conversion from unfolding subsequent
heap work. `chain-notification.bend` composes those lemmas with the actual heap,
stamp and scheduling checkpoints. No source algorithm or kernel budget changes.

`chain-public-program.bend` composes the fixed constructor in `Chain.initial`,
actual public setter and actual public flush for every natural proposal and
budget `95 + extra`. Four root properties identify the staged arena, complete
final World, committed/displayed values and exact application trace `[2, 3n+2]`.
The equal write `n=0` has one new application as the memos use equals:false.
This supersedes the previously recorded missing setter bridge. Constructor
budgets remain fixed at 256; arbitrary initial values, repeated-update histories,
arbitrary graph topology and formal TypeScript equivalence remain unproved.

## Variable-arity user-call bindings

`proof/argument-vector-laws.bend` adds eight quantified local properties for
arbitrary admitted lists, indices, values and surrounding machine state: callback
lookup, action parameter lookup, independent resume binder, root shadowing,
action-factory capture, nested action shadow/capture, callee-first entry and
next-argument evaluation before invocation. Two closed complete executions call
a named callback and a reusable action wrapper with nine arguments. They obtain
the real ninth value and the action Promise's fulfilled result through the actual
public evaluator. These are not arbitrary callback/generator termination or
formal JavaScript equivalence results. The source-alignment and finite evidence
boundary is in [argument-vectors.md](argument-vectors.md).

## Direct owner frame and lifecycle properties

`proof/direct-owner-laws.bend` proves the actual expression's ambient-parent entry,
child-link and constructor preservation of the eight-field ambient snapshot, and
root-method self-flag forwarding under an explicit root-kind premise. These
quantify arbitrary represented surrounding state; they do not assert graph
validity or progress for malformed arenas. One complete public execution checks
child-only teardown, reuse, final disposal and exact cleanup order. No source
algorithm or kernel budget was changed. See [direct-owners.md](direct-owners.md)
for native controls and the remaining ID/reflection/active-scope boundaries.

## Arbitrary finite scalar-memo histories

[The history family](memo-history-proof.md) proves any finite nonempty list of
natural proposals with the actual constructor, setters and independently
sufficient drains. Its repeatable steady pass checks the unchanged setter and
forty core transitions over symbolic counters and arbitrary existing trace/job
prefixes; the complete program theorem then inducts over the update list.
Three new root properties cover that pass, exact final World and committed view.
No state is reset at the induction boundary. This removes the earlier
exactly-two-write limit only for the fixed equals:false signal/memo graph.
Arbitrary graph/effect/async histories and formal TS equivalence remain open.

The same family now also admits arbitrarily many setter calls before each
flush, including its first pass after construction. Four more roots prove
pending replacement, batch staging and the complete batched public program's
World/view. Every nonempty batch schedules and computes once, with only its
last pending proposal read by the memo. The exact source stamp gate and old
committed values are preserved; equals:false remains an explicit restriction.

## Typed array storage and concrete map lifecycles

Five properties in `proof/array-laws.bend`, exposed by LAWS/PROOF, quantify the
actual storage helpers rather than a second array model:

- `holes_length(size)`: any natural length produces exactly that many slots.
- `hole_slot(prefix,suffix)`: every in-bounds slot in a fresh hole vector is
  Empty, with Present(Undefined) as the lookup default to distinguish presence.
- `dense_read(prefix,value,suffix)`: arbitrary value vectors retain the exact
  Present(value) slot, including undefined and reference payloads.
- `slot_put_read(prefix,old,suffix,value)`: replacing an existing slot retains
  the exact Present(value), with arbitrary surrounding slots and payloads.
- `allocation_contract(world,slots)`: Arrays.allocate returns the previous arena
  length as identity, appends exactly one supplied array without changing earlier
  arrays, retrieves its exact slots and preserves every non-array World field.

The proofs use structural induction and the existing arena append lookup lemma.
They do not claim general JavaScript array/property/coercion semantics or a
mapArray/repeat theorem. Two compiled array mutations are rejected by these
quantified assertions, separately from their positive independent-kernel check.

`proof/map-lifecycle.bend` adds three closed executions of the actual public
constructor, setter, committed read, flush, bound item/index reads and root
teardown. A two-item list becomes [2,1,3] in each mode. The checked View contains
items/indexes, the pre-flush committed list, retained row identity, all final row
and map disposals, exactly three cleanup events and restored ambient/fault state.
These are concrete programs with fixed sufficient budgets and a projected final
view, not arbitrary histories, a full-final-World equality or formal TS equivalence.

## Full-World existing-slot array writes

`proof/array-write.bend` adds the sixth general storage property. Given arbitrary
array-arena prefixes/suffixes, arbitrary slot prefixes/suffixes, an old slot, a
replacement Value and arbitrary surrounding World, actual Arrays.put changes
exactly that existing slot to Present(value). Its result equals the full World
with exactly the selected array updated; all other slots, arrays and fields are
unchanged. The proof composes actual arena read/store lenses and an inductive
exact slot-vector write lemma. The precondition identifies an existing array
and in-bounds slot; out-of-bounds extension/property semantics are not claimed.

## Children-flatten construction and closed program

`proof/flatten-lifecycle.bend` quantifies actual resolving-wrapper construction
over every World, captured result-array identity and skip flag: exactly one
zero-arity function descriptor is appended, with no reactive-state changes.
Its separate closed execution checks committed reads before flush, the new
value after flush, output freshness, arity and ambient/fault state through the
real wrapper, callback, setter and drain APIs. There is no arbitrary recursive
children/history/termination theorem. Larger map-payload-family direct attempts
exhausted original kernel fuel; those remain unproved, with decomposition open.


The seventh storage property covers actual flatten.push: for arbitrary existing
slot vectors, array-arena prefixes/suffixes, payloads and surrounding World, it
appends exactly one Present(value) slot. Every earlier slot, other array and
non-array field stays unchanged. An inductive append-at-length lemma composes
with the same real arena lenses; an independent compiled mutation checks the
claim detects overwriting slot zero instead of appending.


## Complete natural-payload children program

`proof/flatten-natural.bend` proves the actual public expression program for
[first,[second,false]], skipNonRendered=true and doNotUnwrap=false. Both payloads
are arbitrary naturals, including zero; every resource budget >=128 produces the
same exact machine: an empty task stack, result ArrayReference(2), and the whole
initial World with precisely three arrays. The first two preserve the input
nested fragments; the fresh third contains Present(first), Present(second).
All non-array fields remain exactly their actual createWorld values.

The base endpoint and every composed step use real Core.step. A structurally
constructed execution Path and checked path-length lemma use the existing
Path.realizes theorem for arbitrary extra fuel. This is a proof iterator over
the actual machine, not a second children resolver. No generated endpoint,
axiom, kernel change or additional source algorithm is used. Sixty-four finite
canonical/public/native comparisons with four sufficient budgets are separate
correspondence evidence. The fixed tree has no accessor/async callbacks; those
and arbitrary tree shapes/history/progress remain outside this family.


Four quantified mark-engine properties now check exact count changes, non-last
removal without repoll, direct-mark short circuit and inactive-global gating.
They preserve the whole surrounding World and quantify other node/extension
fields and arenas. A general graph traversal/progress theorem remains open;
see [affects-marks.md](affects-marks.md).


Five quantified lane properties establish exact fresh allocation/mainline
preservation, unchanged cached verdict return, shared nonnull group identity,
non-guess staging precedence and guess-slot precedence. These are actual helper
boundaries with arbitrary surrounding records/World/payloads, not lane lifecycle
or arbitrary-group-invariant theorems. See [lane-identity.md](lane-identity.md).


Six quantified verdict helper properties cover missing/empty quiet sources,
inactive mark witnesses, exact provisional seam waiting without premature pending,
joined-reader lane refusal, and unwrapped staged-error propagation from heldLatest.
They do not establish public window/read or lane lifecycle correctness; see
[verdict-bookkeeping.md](verdict-bookkeeping.md).


Four quantified active-lane judgment properties now check positive open-count
blocking and exact judge/World restoration, empty mainline unblocking, linked
peer open-count blocking and owned pending-guess flight recognition. An any-budget
empty-list lemma and checked driver head/return equations support the empty case;
the source algorithm, runtime budget and independent kernel are unchanged by that
proof decomposition. General graph/lane lifecycle progress remains open; see
[lane-blockers.md](lane-blockers.md).


Four general group mutation frame properties now check exact first/absent unlink,
shared-group no-op and single-member fresh self-link; list induction handles any
finite peer prefix. Four laneStage World properties check cold exit, memo entry,
failed effect entry and pending frame refusal. They do not prove a public lane
lifecycle or global group invariants. See [lane-group-laws.md](lane-group-laws.md)
and [lane-stage.md](lane-stage.md).

## rc.17 cleanup collection

[cleanup-policy.bend](../proof/cleanup-policy.bend) adds seven whole-World
properties over arbitrary raw payloads: first capture, retaining the first error,
clear/raw rethrow, clear/drop, in-flush root deferral, already-halted preservation
and first-halt drop. These actual helper laws supplement the existing LIFO-list
laws and the quantified Core cleanup-catch continuation. They are scoped helper
properties; complete arbitrary owner-tree progress remains unproved. See
[cleanup-policy.md](cleanup-policy.md) and the rc.17 integration review.

## Lane read and question boundaries

[question-order.bend](../proof/question-order.bend) proves reflexivity, swapped
inverse, equality coherence, less irreflexivity and zero-question staleness.
[lane-read-laws.bend](../proof/lane-read-laws.bend) proves the actual raw custom
comparator call frame without a catch, plain truth answer under source guards,
and pending lane-entry token with exact entered World/caller continuation.
These eight quantified helper laws do not establish numerical-order semantics,
arbitrary recursive truth progress or public lane lifecycle correctness. Native
controls and exclusions are separate in [lane-reads.md](lane-reads.md).

## Lane lifecycle boundaries

[lane-lifecycle.bend](../proof/lane-lifecycle.bend) proves leaked-seam held-only
mutation, effect-commit comparison refusal, live reverse-scan entry,
confirmation stage-before-join and hidden correction flag clearing. These five
quantified actual helper boundaries preserve World/caller fields and arbitrary
payloads. Complete lane lifecycle, arbitrary callback mutation and progress
remain open. See [lane-lifecycle.md](lane-lifecycle.md).

## Lane answer and core dispatch boundaries

[lane-answers.bend](../proof/lane-answers.bend) adds six quantified boundaries:
errored outcome preserves World, correction snapshot entry, empty scan judgment,
override setter dispatch before mainline work, true token fall-through and
successful undefined early read. The complete memo/chain setter callers now
explicitly discharge the nonoverride condition on their default setter lemma;
their public program domains and budgets remain unchanged. See lane-answers.md.

## Queued guesses and capped reveal

[lane-guesses.bend](../proof/lane-guesses.bend) adds nine properties: newest
queued value for any finite prefix, empty lookup, empty prefix capture,
equal-plain suppression, equal-guess reask, exact unstamped question allocation,
null seam entry, capped live-prefix entry and zero reveal. All preserve their
stated World/caller frames; full application/lifecycle progress remains open.
The source fields extend LaneState without changing existing program domains;
regenerated witnesses must pass the independent kernel before they are trusted.


## Complete ordinary-payload deferred data program

[deferred-payload-program.bend](../proof/deferred-payload-program.bend) generalizes
the existing 103-step public data lifecycle to every admitted ordinary initial
and proposed payload: undefined, null, booleans, naturals, negative zero, NaN,
arbitrary strings and opaque reference identities. Mixed types are included.
The exact final Machine and returned payload hold at every budget >=103. A
checked numeric-specialization bridge retains the old theorem as the same
program. Six shape case splits occur only in proofs; runtime/source are unchanged.
This does not prove arbitrary graphs/functions or callable/async payloads. See
[the domain and controls](deferred-payload-proof.md) for the exact scope.


The subsequent [stream-refetch checkpoint](deferred-stream-refetch.md) supersedes
older Unsupported88/open-window exclusions above. It adds the actual source
wrapper, 184 public histories (3,952 total), 13 kernel roots including a complete
ordinary-payload fixed one-yield programme for every budget >=118, and ten
compiled negative controls (534 configured). Every prior complete-program
domain/budget is retained. The preceding 524-variant complete sweep applies to
9c1f2ec, as recorded in reviews/solid-b9b6f333-complete-negative.json.
A newly confirmed protocol-error bug010 remains faithfully preserved; from/
onSupersede and store/boundary/snapshot scopes remain unfinished.


The subsequent [internal supersession checkpoint](supersede.md) preserves exact
undefined/null/active flight slots and adds the source onSupersede hook through
the existing callback machine. It adds 3,456 private helper controls and fifteen
quantified roots, with five compiled negative checks (539 configured: 450 finite,
89 kernel). Public histories/closed regressions remain 3,952/73. All earlier
complete-program domains and budgets are retained. The complete preceding
534-variant stream receipt names its frozen 93de532 checkpoint; from wiring is
still unfinished and no deviation is active.
