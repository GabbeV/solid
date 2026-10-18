# Solid 2 signals in Bend 2

An executable **initial translation of the synchronous, non-store core** of
`@solidjs/signals` 2.0.0-rc.15. This is **not yet the complete signals package**.

The governing requirement is operation-level source fidelity so future Solid
commits can be followed directly. The current port still has alignment gaps; see
[the source-fidelity audit](tracking/source-fidelity.md). Proof convenience does
not justify changing the algorithm, and formal TS/Bend equivalence is not required.

The Bend implementation owns dependency registration, generation-stamped linked
edges, intrusive height buckets, nested memo pulls, staged writes, commit,
render/user queue ordering, and a mechanical text tree. It evaluates the stored
callback expressions. JavaScript supplies the test host and payload encoding.

The implementation, differential tests, and composed proofs use the same runtime.
There is no second scheduler hidden behind the proof.

```sh
node tools/bootstrap.mjs          # npm ci + pinned Lean, Linux x64
npm run verify                   # build, parity tests, independent kernel
npm run mutations                # reject four broken runtime variants
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
and `untrack`. Arbitrary host JavaScript callbacks are not yet supported.

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
arbitrary-history, async, or optimistic consistency theorems**.

Tests additionally exercise strict equality, dynamic branches, diamonds,
nonconsecutive repeated reads, batching, updater composition, lazy activation,
render/user phases, disposal, and opaque payload identities against the pinned
Solid production entry. These are parity evidence, not general proofs.

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
