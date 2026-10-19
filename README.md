# Solid 2 signals in Bend 2

An executable **incremental translation of the non-store core** of
`@solidjs/signals` 2.0.0-rc.15. This is **not yet the complete signals package**.

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
There is no second scheduler hidden behind the proof.

```sh
node tools/bootstrap.mjs          # npm ci + pinned Lean, Linux x64
npm run verify                   # build, parity tests, independent kernel
npm run mutations                # reject sixteen source-changing variants
npm run example                  # Number{14n}
```

Node 22.12+, Python 3 (only to regenerate record helpers), curl, tar with zstd,
and a C compiler are needed. Bend compiles its independent kernel with Lean on
first use. A Lean installation can be selected with `LEAN_ROOT=/path/to/lean`.
To build and test without kernel tooling, use
`node tools/bootstrap.mjs --without-kernel`, then `npm run build && npm test`.
That does not establish a proof claim.

Start with [examples/counter.bend](examples/counter.bend),
[runtime/api.bend](runtime/api.bend), and [host/bend.mjs](host/bend.mjs).
The host uses a small reusable expression grammar: literals, actual reads,
previous values, addition/multiplication on naturals, strict equality, branches,
`untrack`, sequences, and reusable callback programs for writes, cleanup, disposal
and throws. Compute/application/error bodies support expression reads, early returns
and evaluated writes/throws; teardown reads remain unfinished. See [callback coverage](tracking/callbacks.md). Synchronous errors propagate through compute/effect catches, recovery and scheduler
halts. Pending catches, held reads/writes, staged errors and mainline transaction
park/land now run in the same driver. Ordinary typed promise-like flights now register, settle/reject and flush; typed iterator initial drains, later yields, cancellation and flattening also execute; active boundary/lane scopes remain unfinished. See [the async milestone](tracking/async.md). Public resolve/refresh watchers also execute for admitted payloads/accessor targets; see [the watcher milestone](tracking/watchers.md). Arbitrary host JavaScript callbacks are not yet supported.

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
and import only `@solidjs/signals`. They reproduce the empty-iterable leak on the
published package and current next, and successful-value-as-error recovery on
current next. The shared rc.15 version string does not identify the same source
commit in npm and next; the repro instructions distinguish them.

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
