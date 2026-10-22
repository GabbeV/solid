# Solid 2 signals in Bend 2

An executable **incremental translation of the non-store core** of
`@solidjs/signals` 2.0.0-rc.16. This is **not yet the complete signals package**.

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
There is no second scheduler hidden behind the proof. The
[scalar-memo history family](tracking/memo-history-proof.md) now proves any finite
nonempty sequence of write/flush batches of any finite nonempty size for every
natural initial value and proposal,
including the real constructor, sufficient per-update budgets and exact final
state. General graphs, effects and async histories remain open.
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

[Progress checkpoints](tracking/progress.md) show concrete implementation and proof gains, with remaining work.

The reviewed Solid pin is now `5b1b7776` (rc.17), matching `next` when fetched
on 2026-10-22. [Current integration review](tracking/reviews/solid-5b1b7776.md)
ports cleanup continuation and falsy fallback retention; shared optimistic-store
hooks remain reviewed omissions. The complete prior port is at `bb82345`.
The preceding pin remains on `baseline/solid-71153bf0` at `075455c`;
[the earlier integration review](tracking/reviews/solid-71153bf0.md) records the original three fixes.
The old pinned runtime and counterexample laws remain on `baseline/solid-d2ad8b28`.
The merged cleanup-collector (#4176) and reaction-arm (#4188) fixes now pass their
original repros and positive Bend regressions. Their former counterexamples remain
in the c11277e checkpoint. Work is regularly pushed on `feat/solid-signals-bend`.

```sh
node tools/bootstrap.mjs          # npm ci + pinned Lean, Linux x64
npm run verify                   # build, parity tests, independent kernel
npm run mutations                # reject 308 source-changing variants
npm run example                  # Number{14n}
npm run example:list             # children 20, 10, 30; Healthy
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
Arbitrary host callbacks and active optimistic/truth scopes remain unfinished.


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
