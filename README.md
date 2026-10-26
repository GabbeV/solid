# Solid 2 signals in Bend 2

An executable **incremental translation of the non-store core** of
`@solidjs/signals` 2.0.0-rc.18. This is **not yet the complete signals package**.

The source is pinned to next@2a0da2fc. [The latest source review](tracking/reviews/solid-2a0da2fc.md)
records merged protocol-flight retirement and first-error re-ask handling. [Stream refetch](tracking/deferred-stream-refetch.md)
now runs through the existing iterator engine and has an ordinary-payload complete-program proof. The [direct from(fn) subscription branch](tracking/from-subscriptions.md) now runs with a complete fixed ordinary-payload lifecycle proof, including once-only disposal cleanup. The [wrapped AsyncIterable branch](tracking/from-iterables.md) also runs, with a complete pending-pull cancellation proof. Both [from lifecycle proofs](tracking/from-values.md) now quantify over any represented value, including function-valued data. Observable inputs, full-package and arbitrary-async-graph guarantees remain open.

The objective is increasingly general properties of reactive behavior and useful
upstream counterexamples. The [current milestone](tracking/frontier.md) targets
branching held-action histories. Its first [invariant proofs](tracking/general-properties.md)
cover arbitrary certified redirect paths. [Constructed action/join contracts](tracking/transaction-joins.md)
now connect real allocation/opening, either join direction, arbitrary finite pair
lookups/rejoins and either first completion through its original identity. The
[actual blocker judgment](tracking/action-blocker.md) also holds before/after that
completion.

The [second-completion proof](tracking/action-completion.md) now covers both orders with arbitrary finite lookups/rejoins before, between and after them; a separate wait-list invariant preserves settled yield callbacks. [Empty-group eligibility](tracking/action-eligibility.md) is also checked once both complete, under explicit health/no-live-lane conditions. The [actual landing scan](tracking/action-landing-scan.md) retains a selected positive-debt group, with live-list lookup still explicit. [Nonempty rendered snapshot contracts](tracking/rendered-blockers.md) now cover zero-action graph blockage and retained scan, with construction/preservation still explicit. [Completion-prefix histories](tracking/rendered-completion-history.md) now preserve that pending snapshot and all blocker-check answers over arbitrary finite permitted sequences. [Actual list construction](tracking/rendered-list-construction.md) now supplies that history’s initial ownership and membership, with pending-status/parking entry still explicit.

[Committed-staging safety](tracking/committed-staging.md) now spans arbitrary represented values and finite storage, including actual default setter and write-history frames. The [fulfillment prefix](tracking/async-write-prefix.md) also retains committed content/stack and constructs its exact queued continuation; execution of that tail remains open. [Constructed live selection](tracking/live-selection.md) now derives the held scan position through the real two-action join and either first completion, rather than requiring its lookup as a premise. Certified rendered completion/check histories now carry initial membership forward and derive the final held scan on the actual audit World. The full action/flight ledger and rendered visibility theorem remain open.

The governing requirement is operation-level source fidelity so future Solid
commits can be followed directly. The current port still has alignment gaps; see
[the source-fidelity audit](tracking/source-fidelity.md). Proof convenience does
not establish fidelity, and formal TS/Bend equivalence is not required. Necessary
temporary deviations are allowed with a [strict deviation record](tracking/deviations.md),
baseline/changed expectations and an explicit route back to upstream.

The Bend implementation owns dependency registration, generation-stamped linked
edges, intrusive height buckets, nested memo pulls, staged writes, commit,
render/user queue ordering, and a mechanical text tree. It evaluates the stored
callback expressions. JavaScript supplies the test host and payload encoding.

The implementation, differential tests, and composed proofs use the same runtime.
[General semantic properties](tracking/general-properties.md) now cover arbitrary
publication slots/payloads, read policies and a complete numeric signal program.
The [pending-continuation extension](tracking/pending-continuations.md) now proves caller-stack preservation by induction over arbitrary finite permitted prefixes of actual core settlement steps. The [owner extension](tracking/owner-continuations.md) includes bookkeeping and proves exact two-step completion of a no-stale dependency trim; callback bodies and flush publication remain separate. There is no second scheduler hidden behind the proof. The
[scalar-memo history family](tracking/memo-history-proof.md) now proves any finite
nonempty sequence of write/flush batches of any finite nonempty size for every
natural initial value and proposal,
including the real constructor, sufficient per-update budgets and exact final
state. The [selected-renderer laws](tracking/rendered-observation.md) now retain the chosen text/application observation through an actual independent apply step, with positive laws proving selected updates remain visible. General graphs, effects and async histories remain open.
The public `flush(() => ...)` overload now supports nested synchronous drains,
returned values and exception-safe depth restoration; see [flush callbacks](tracking/flush-callbacks.md).
Custom comparator programs now run through signal writes, memo publication, async
landings and held seams; see [comparator coverage](tracking/comparators.md).

The production `repeat` helper now executes retained-window mapping, staged
commit and exception cleanup with typed array identities; see
[repeat coverage and limits](tracking/repeat.md). The `mapArray` keyed:false profile now executes too; see
[index-mode coverage](tracking/map-index.md). The [plain identity-keyed profile](tracking/map-keyed.md) now includes duplicate
matching, pure removals and the source small-move optimization.
[Extracted keys and reactive index accessors](tracking/map-modes.md) now execute
through the same paths. Seven quantified array-storage properties and three
concrete map lifecycle executions are kernel-checked separately from parity tests.

The [children resolver flatten](tracking/flatten.md) now unwraps typed accessor
chains and nested arrays, retains deferred resolving wrappers and follows the
source pending/error collection policy. A fixed nested-children program has an
exact final-state proof for every natural payload pair and all budgets >=128;
arbitrary recursive trees remain outside that theorem.

The [deferred lag dependency](tracking/deferred-lag.md) now has a source-following
walk and an arbitrary-fuel read-only World theorem. The [public deferred
data/thenable profile](tracking/deferred.md) now connects construction, flight
lifetimes and truth readers, with a [complete ordinary-payload data update proof](tracking/deferred-payload-proof.md)
for undefined, null, arbitrary booleans/naturals/strings/opaque reference
identities, NaN and signed zero, including mixed types.
Its [first-load streams](tracking/deferred-first-stream.md) now use the ordinary
iterator engine. The stream refetch wrapper is implemented; from/store/boundary profiles remain unfinished.

The [non-store affects API](tracking/affects-scope.md) now retains declarations
through action/ambient/own-flight windows and releases them at source seams.
Its complete data program is proved for every natural payload and sufficient
budget. Current evidence totals 4,486 public histories, 589 configured mutation
controls and 73 composed closed regressions, plus quantified properties.

The [optimistic constructor](tracking/optimistic.md) now has data/function
input dispatch and its own bound setter, supported by the lane pass/flush
engine. A complete free data program is proved for every natural payload triple
and sufficient budget. The [verdict windows](tracking/verdict-windows.md) now execute full non-store
read/catch/finally paths; a nested data program is proved for all natural payload
pairs. Boundary/store, snapshots and external-source lifetimes remain unfinished.

[Progress checkpoints](tracking/progress.md) show concrete implementation and proof gains, with remaining work.

The reviewed Solid pin is `2a0da2fc` (rc.18). [The source review](tracking/reviews/solid-2a0da2fc.md)
accounts for all 77 verbatim Solid inputs and integrates merged #4248/#4250.
Deferred protocol errors now retire their flights; never-valued error re-asks
restore pending-uninitialized status. Earlier #4231/#4232/#4233 integration and
all preceding theorem domains/budgets remain. No semantic workaround is active.

```sh
node tools/bootstrap.mjs          # npm ci + pinned Lean, Linux x64
npm run verify                   # build, parity tests, independent kernel
npm run mutations                # reject 619 source-changing variants
npm run example                  # Number{14n}
npm run example:list             # children 20, 10, 30; Healthy
npm run example:pending          # false, true, 41, false, 41; Healthy
```

Node 22.12+, Python 3 (only to regenerate record helpers), curl, tar with zstd,
and a C compiler are needed. Bend compiles its independent kernel with Lean on
first use. A Lean installation can be selected with `LEAN_ROOT=/path/to/lean`.
To build and test without kernel tooling, use
`node tools/bootstrap.mjs --without-kernel`, then `npm run build && npm test`.
That does not establish a proof claim.

Start with [examples/counter.bend](examples/counter.bend),
[the executable list example](examples/list.bend),
[runtime/api.bend](runtime/api.bend), and [host/bend.mjs](host/bend.mjs).
The host uses a small reusable expression grammar: literals, actual reads,
previous values, addition/multiplication on naturals, strict equality, branches,
`untrack`, sequences, and reusable callback programs for writes, cleanup, disposal
and throws. Compute/application/error bodies support expression reads, early returns
and evaluated writes/throws, including cleanup programs. See [callback coverage](tracking/callbacks.md). Synchronous errors propagate through compute/effect catches, recovery and scheduler
halts. Pending catches, held reads/writes, staged errors and mainline transaction
park/land now run in the same driver. Ordinary typed promise-like flights now register, settle/reject and flush; typed iterator initial drains, later yields, cancellation and flattening also execute; active boundary/lane scopes remain unfinished. See [the async milestone](tracking/async.md). Public resolve/refresh watchers also execute for admitted payloads/accessor targets; see [the watcher milestone](tracking/watchers.md). Owner/observer handles, owned/detached root callbacks and runWithOwner also execute;
see [ownership coverage](tracking/ownership.md). Bound root disposers are callable
and retain identity through argument passing and updater storage; see
[argument/function coverage](tracking/arguments.md). Low-level context keys,
lookup and copied owner records also execute; see [context coverage](tracking/contexts.md). Selected bound disposers can be returned
and registered by onCleanup with preserved callable identity; see
[cleanup values](tracking/cleanup-values.md). Escaped data-signal accessors can
be returned, stored and called through the same read machine, including after
the allocating root is disposed; see [local bindings](tracking/locals.md).
Escaped data-signal setters and computed read accessors also execute; see
[setter coverage](tracking/setters.md) and [computed accessors](tracking/computed-accessors.md).
The expression-based `createSignal(fn)` overload and its distinct setMemo policy
now execute; see [writable signals](tracking/writable-signals.md).
Selected setters can also be registered directly with `onCleanup`; see
[setter cleanup](tracking/setter-cleanup.md).
First-class named callback values also support ordered calls, initializer/updater
use, native promise data and runtime-selected cleanup programs; see
[callback function values](tracking/callback-values.md). Arbitrary host JavaScript
callbacks remain unfinished. Read-capable teardown now has shared owner/core
continuations through disposal, effect cleanup, core/scheduler trims, native
watchers and async/error/pending release. Public expression cleanup programs
and direct bound getter cleanup values are admitted; arbitrary closures remain open.
See [getter cleanup](tracking/getter-cleanup.md) for coverage and read-observation limits.
See [owner/core coverage](tracking/owner-core.md).
`createTrackedEffect` now runs its tracking body in the user phase after the
commit seam, with returned cleanup and source error behavior; see
[tracked effects](tracking/tracked-effects.md) and
[onSettled callbacks](tracking/settled.md) and
[reactions](tracking/reactions.md).

The proof in [LAWS.bend](LAWS.bend) covers an actual constructed graph:

```text
source x -> memo (x + 1) -> memo ((x + 1) * 2)
       \______________________________\
             render ((x + 1) * 2 + x) -> attached tree text
```

For concrete writes `6`, then `9`, with `equals:false`, it checks the computed
values, visible text (`20`, then `29`), attachment, empty pending/effect queues,
restored ambient context, and successful completion within the execution budget.
The independent kernel checks the actual constructed executions. A separate
reusable path-composition lemma is checked for arbitrary machine states.
These concrete regressions are **not arbitrary-value, arbitrary-graph,
arbitrary-history, general async, or optimistic consistency theorems**.

A separate concrete cleanup proof checks reentrant root disposal through the
active owner machine: detached cleanup lists, exact callback order, effect cleanup
and final owner state. Two further closed regressions check error wrapper sharing
and same-value recovery through the actual graph/queues. Two pending-helper
regressions check converging retirement and an independent carrying path.
Two transaction regressions check that a held write keeps old text and appears
when its explicit transaction input is released; these are not action API proofs.
General error and
ownership theorems remain open.

Tests additionally exercise strict equality, dynamic branches, diamonds,
nonconsecutive repeated reads, batching, updater composition, lazy activation,
render/user phases, effect cleanup, reentrant writes, dormant memo revival, disposal, and opaque payload identities against the pinned
Solid production entry. Focused internal-state probes compare the actual pinned
commit/read helpers, including fast/slow value selection and their flags/queues.
Separate production constructor tests check option masks, loading-seed presence,
parent/root forwarding and lazily allocated extension defaults. Synchronous error histories and internal status states also match the pinned helpers.
Extension storage does not implement async flights or the transaction engine; see
[the representation notes](tracking/representation.md).
These are parity evidence, not general proofs or full async execution coverage.

The exact source and toolchain are retained under [upstream](upstream).
[Source correspondence](upstream/correspondence.json), the automatically checked
[unit/branch inventory](upstream/inventory.json), and the
[current frontier](tracking/frontier.md) distinguish mapped code, open branches,
proof scope, and representation assumptions.

To inspect a future Solid checkout without repinning or modifying either tree:

```sh
npm run upstream:impact -- /path/to/solid-checkout
npm run upstream:impact -- /path/to/solid-checkout --json
```

The report maps changed functions to known Bend counterparts and flags file-level
changes too. Tests/docs/build conditions still require separate diff review.

[Standalone Solid bug repros](repros/solid-signals/README.md) install independently
and import only `@solidjs/signals`. Their original versions preserve the historical
empty-iterable leak and successful-value-as-error recovery repros. Both are fixed
at the current source pin. A package version alone does not identify a source
commit; the repro instructions distinguish the historical builds.

[Minimal JSX playground repros](repros/playground/README.md) use ordinary
components and rendered expressions. The held-recovery reduction needs one
signal, two memos and three manual clicks; the empty-stream reduction needs one
memo. Browser checks exercise both production and development builds.

The important remaining work is transaction membership and publication, pending
and error propagation, promise/iterator settlement, optimistic lanes and actions,
boundaries and reveal ordering, full ownership/cleanup/context APIs, remaining
helpers, hooks and diagnostics. Stores remain excluded from the planned port.
Unsupported callback throws stop explicitly; they are not silently modeled as
successful or settled work.

`npm run check` records hashes of the checked source and emitted runtime in
`build/verification.json` only after a successful independent-kernel check.
See [verification](tracking/verification.md) for the exact trust boundary and the
open generalization work.

Five additional closed async laws cover loading, landing, supersession and a
pending diamond. Their explicit external input and the exact binary question-ID
representation are documented in [question-ids.md](tracking/question-ids.md).
Iterator pumping, native job timing and public watchers remain tested domains.

The [until path](tracking/until.md) also executes through the shared watcher,
including natural-millisecond timeouts and abort signals with represented or
default native reasons. Two closed queued-callback regressions cover the default
path; option handling is differentially tested. Built-in Error/DOMException data
and captured StatusError messages are covered by [the error contract](tracking/errors.md).
Arbitrary host callbacks and store/folded or boundary protocols remain unfinished.
The production non-store optimistic/verdict/affects paths execute as described above.


## Typed action invocation milestone

Production action invocations now run generator methods through the shared Bend
core and the existing transaction engine. Initial scheduling, held writes across
yields, nested/overlapping invocations, errors, captured local signals and typed
return adoption have 75 paired histories and seventeen native-generator controls.
Five quantified helper properties and two concrete action hold/land executions
check independently. [The scope review](tracking/actions.md) records the source
return points and remaining first-class function/protocol/active-engine gaps.
The earlier transaction laws with explicit open counts retain their narrower
historical scope; this milestone does not turn them into general action proofs.


The [scalar-memo public program proof](tracking/general-properties.md#complete-scalar-memo-public-program)
now closes the earlier constructor/setter gap. For every natural proposal, the
actual fixed-initial constructor/setter reaches the staged arena, then a drain of
40 or more steps commits source n and memo n + 1. The checked constructor and
setter paths have 14 and two steps respectively. This is a fixed graph family;
arbitrary graph correctness and TS equivalence remain outside the claim.

The constructor separately supports a proof for every natural initializer with
at least 14 steps. General transaction merge laws also preserve summed open
counts, redirect identity and the action marker for two ordinary roots. These
remain scoped semantic properties of the actual Bend code.

The [larger graph proof](tracking/chain-proof.md) now also has a checked public setter bridge and complete
constructor/setter/flush family for every natural proposal and drain budget >= 95,
including its complete final World and exact render-application trace. The staged
precondition remains on the supporting drain lemma, not on the composed public
program. See [the graph proof boundary](tracking/chain-proof.md).

The [user-call ABI](tracking/argument-vectors.md) now supports finite callback and
action argument vectors without a fixed two-argument cap, while internal source
calls retain their existing pair representation. Seventy paired histories and six
hand-written native generator controls are separate from eight quantified local
binding/order laws and two kernel-checked nine-argument executions.

[Direct owner creation](tracking/direct-owners.md) now returns the fresh owner
without entering it. The same teardown driver supports children-only clear and
reuse via the owner method's boolean self flag. Twenty-five paired histories,
four quantified frame/entry laws and one complete lifecycle execution check this
production subset; hydration IDs and owner reflection remain unfinished.


`npm run example:deferred` runs a Bend consumer that keeps 10 visible while a
typed external request refreshes, then publishes 21 and clears isPending.
[Deferred coverage](tracking/deferred.md) states the callback protocol and limits.

`npm run example:cleanup` executes the merged async-error cleanup timing in
Bend directly. It prints cleanup counts 0 while shown, 0 while the replacement
is pending, and 1 when that replacement rejects, followed by Healthy. See
[async-cleanup.bend](examples/async-cleanup.bend).


The [earlier rc.18 refresh](tracking/reviews/solid-225014bf.md) recorded development
event diagnostics. The [current refresh](tracking/reviews/solid-2a0da2fc.md) integrates
merged protocol-flight and first-error fixes while retaining earlier proof domains/budgets.


## No-subscriber settlement return (2026-10-25)

The [settlement completion contract](tracking/empty-settlement-completion.md) adds nine roots: a constructed actual six-step
prefix returns arbitrary caller work/stack, preserves committed content and stays
Healthy from input health/empty-subscriber facts. The actual Core.run decomposition
retains the original remaining fuel and explicit exhaustion policy. These are
local internal-completion results; public input construction, nonempty traversal
and queued flush/publication remain open. Eighty direct-arrival controls, 240 driver
splits and 80 exhaustion controls pass. The corrected full619 negative sweep is
verified separately on frozen4975adf2; four later focused kernel variants pass.


## General pending content safety (2026-10-25)

The [active pending frame/history proof](tracking/pending-committed-history.md) closes the previous callback-free settlement
storage-frame obstacle without reducing its observation: all committed values,
the full tree and trace are retained through actual pending steps and arbitrary
finite certified body-only prefixes. Six roots extend 487 to 493. The source
status/tail blocks now have names; an inlining audit recovers the exact previous
statements and order. Public/alignment suites pass; no runtime task, semantic
policy, theorem domain, witness budget or kernel limit changed. Owner callbacks,
general successful termination and coordinated flush/reveal remain open.


## Pending topology and derived leaf control (2026-10-25)

The [topology/leaf extension](tracking/pending-topology.md) adds seven roots, retaining the earlier 493. Actual
pending helpers/core steps and arbitrary certified body prefixes retain node
kind/configuration/subscriber heads and all intrusive links. A non-autodisposed
leaf derives its exact control layout around the actual computed World, private
visited/released locals and scheduled bit. The 1,280 step and 80 leaf controls
pass; three new metadata corruptions are kernel-rejected. Runtime/source/task
budgets are unchanged. Successful general traversal and final reveal remain open.


## Constructed one-edge return (2026-10-25)

The [one-edge return family](tracking/one-edge-return.md) derives actual control and a ten-step upper room from
Healthy input/one-edge/non-autodisposed-leaf facts, carrying the exact World and
caller work/stack. A no-stale trim composes to twelve. Early returns and faults
are explicit alternatives; the complete segment retains committed content and
uses actual driver fuel. Eight roots extend 500 to 508. Eighty real ten-step and
40 trimmed returns, plus private nine-step/five-step alternatives, pass. Runtime,
source, domains and limits are unchanged. Public premise construction, full
accounting and coordinated flush/reveal remain open.

## Composed callback entry and checker efficiency (2026-10-26)

[Actual first arrivals](tracking/action-method-first.md) now compose real action/
Promise/wait construction, arbitrary admitted helper prefixes, End or next/throw
Body staging, settled lookup and exact later stale-callback guards. The630-root
seal uses a [recorded congruence-first BendTT profile](tracking/kernel-congruence.md)
whose full Lean soundness/consistency development checks without new axioms or
fuel increases. The original Bend snapshot and baseline profile remain available.
First profile preparation also needs a `patch` command alongside the existing
Lean/C toolchain. The full678 frozen negative sweep and four later focused checks
have separate provenance; full generator/flight accounting, queued user-body
execution and coordinated flush/reveal remain open. Source runtime, representation
and host adapters are unchanged.

The [pending completion contracts](tracking/pending-completion.md) additionally
connect actual leaf-notifier completion to its original budget and actual final
source removal to the status phase's pending-bit clear, including held joins.
They recover earlier checker resource stops; full settlement/flush/reveal remains
open. Runtime and pinned sources are unchanged.
