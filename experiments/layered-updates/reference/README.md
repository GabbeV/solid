# Coordination reference experiments (stages 39–45)

[Stage 47](../SEMANTICS-47.md) adds pending input contexts to the consolidated
model and identifies an unresolved readiness/lifetime difference for input
calculations hidden behind active overrides. It adds ten reference tests.

The following [production integration checkpoint](../PRODUCTION-46.md) retains
sparse committed dependency tracking and records a rejected peer-gate port.
The reference engine itself is unchanged by that work.

The latest checkpoint [consolidates the engine and tests its runtime cost](COORDINATION-45.md).
The direct representation fails the performance gate; it is not a replacement runtime.
The preceding experiment adds [action lifetimes and lazy pending](COORDINATION-44.md)
to the [stage-43 active selector model](COORDINATION-43.md),
which refines the [stage-42 layer-order model](COORDINATION-42.md),
following the [stage-41 join experiments](COORDINATION-41.md).
The initial automatic scheduler is described in [the stage-40 checkpoint](SCHEDULER.md).
The sections below retain the preceding snapshot/protocol experiments.

These are research instruments, not a replacement runtime. They have no Solid
imports and do not extend the scalar prototype's acceptance claims. The main
coordinator still has the stage-38 context-discovery defect; stage 46 changes
only its supporting dependency-frame infrastructure.

Run from the checkout root:

```sh
UNIFIED=1 node --test experiments/layered-updates/reference/*.test.mjs
node experiments/layered-updates/reference/search-contexts.mjs 10000
node experiments/layered-updates/reference/reduce-context.mjs experiments/layered-updates/results/reference-stage39/context-search.json
```

## What the experiments establish

### Inferring context from reads is a policy, not just bookkeeping

`read-context.mjs` explores committed-first discovery, then narrowing the set of
boundary permissions until actual reads support every remaining permission.
Each unsuccessful pass removes a permission, so this local search terminates.
This is **not** a progress proof for a reactive scheduler.

The deterministic 10,000-snapshot search found at most four evaluations and 220
differences from an alternative exhaustive maximal-context policy. Neither
policy is an oracle. These differences show that “find a supported context”
does not uniquely define observable behavior.

The first disagreement reduces to this expression:

```js
return a() ? (e() ? c() : a()) : (b() ? x() : e());
```

All published values are zero. Proposals for a, b, c are one; e and x remain
zero. b and c are boundary descendants of a; e is separate; x is ordinary.
Committed discovery visits a, b, e. Selecting b's context uses a's committed
zero and b's proposed one, then reads x: result zero. Selecting e's context
uses a's proposed one and reaches e: result one. Both contexts have witnesses
in their respective executions. Choosing all discovered permissions then
removing unsupported ones selects b. Rejecting multiple maximal choices falls
back to ordinary consumption and returns one. These are *held candidates*,
not two proven-safe alternative DOM publications.

Narrowing is deterministic and bounded, but adds branch-dependent selection
semantics and repeats user code. Its tests also expose repeated request/child
*descriptors*. Real work started inside a function cannot necessarily be undone.
Do not port this discovery algorithm merely because its tests pass.

### A shared memo needs one publication frame and retained lower obligations

`shared-frame.mjs` gives multiple consumers one committed memo frame and at most
one eligible async candidate. Consumers cannot ask the memo to compute private
versions. A discarded candidate loses publication rights; its update's outstanding
work remains. Equal-valued writes change generations. An error is a publishable
frame shared by all consumers. Candidate lifecycle entries are audit descriptors,
not real owners or cleanup callbacks.

A tested timeline, with shared memo `x() + optimistic()`:

| Event | Inputs visible | Memo visible | Eligible work |
| --- | --- | --- | --- |
| Initial | 0, 0 | 0 | none |
| Propose x=1 | 0, 0 | 0 | 1 |
| Propose optimistic=10 | 0, 0 | 0 | 10; old token invalid |
| Answer 10 | 0, 10 | 10 | x=1 still owed |
| Resume lower work | 0, 10 | 10 | 11 |
| Answer 11 | 1, 10 | 11 | none |

A different explicit preparation can combine the updates before 10 publishes,
producing a direct transition to inputs 1,10 and memo 11. The probe deliberately
requires a caller to choose that preparation. It does **not** establish which
scheduler event should choose it. In particular, finishing an action body,
finishing an independent upstream calculation, and discarding a shared async
calculation are not interchangeable readiness signals.

`publication-probe.mjs` is an earlier one-consequence probe. It automatically
requests combined preparation when an observed group's externally supplied
`open` flag becomes false. That is a simplifying assumption, not a complete
rule for the runtime: it does not derive group readiness from outstanding
reactive work. Its request reuse also compares scalar request keys, unlike the
generation checks in the shared-frame protocol. Keep these limitations visible.

## Direction to try next

The user's latest guidance permits reducing mount entanglement if it naturally
simplifies the model. Explore **a frame selected by the cause of evaluation**,
instead of inferring permission from a boundary discovered inside user code:

1. An independent new root reads committed inputs. It can mount while inputs
   have proposals, provided those committed inputs exist. This includes an
   ordinary memo with no observation primitive. No discovery pass is needed.
2. A computation preparing an update reads that update's selected frame. Peer
   proposals reaching a shared memo combine; an optimistic boundary can select
   a child frame that reads excluded lower proposals at their committed values.
3. A child created by a preparing parent inherits the parent's frame. It must
   not mix a closure containing the parent's proposed values with arbitrary
   committed reactive reads. “Mount committed” is not a blanket child-owner rule.
4. A mounted reader becomes a publication obligation for subsequent updates to
   its inputs, including proposals already in progress. It cannot let an input
   publish while its own newly started async consequence remains stale.
5. With no committed input, independent mounting suspends. It must wait for a
   coherent producing frame rather than treating absence as a committed value.
6. A shared memo exposes one committed frame and one selected candidate. Losing
   candidate ownership leaves a deferred recomputation obligation for the
   superseded update, not another live private graph or async answer slot.

This changes current next: the stage-38 conditional mount currently waits, while
this direction would display `true:0` then `value:1`. A plain late `x()*2` memo
would likewise be eligible to mount zero before two. Current next's behavior is
recorded in `../results/strategy-review-stage38/read-context.json` for the
conditional case; the plain case has not been remeasured in this stage.

The snapshots interpreter's `policy: "committed"` and the shared-frame probe
exercise pieces of this direction. **No general implementation exists yet.**
In particular, one must not mistake recursive evaluation under each consumer's
context in `ReadModel` for a valid implementation of shared memo caching.

## A real-runtime check: ancestry must follow joined updates

The audit `../coordination-join-audit.mjs` runs this shape against the production
baseline and the existing scalar build, with both memo creation orders:

```js
const [a, guessA] = createOptimistic(() => 0);
const [b, guessB] = createOptimistic(() => 0);
const [c, guessC] = createOptimistic(a);
const p = createMemo(() => delayed(a() + b()));
const q = createMemo(() => delayed(c() + b()));
```

Each initial zero returns synchronously. Separate open actions propose a=1,
then b=2, then c=10. `p` has already joined the proposals for a and b. Controlled
gates let q's candidate finish before p's. Separate render bindings observe
all five outputs; the audit records them after each flush/turn.

- Baseline starts q=12 and holds every output until p=3 also answers.
- The existing prototype starts q=10. Answering it publishes c=10 and q=10
  while a, b, p remain zero. Once p=3 answers, q=12 must finish before a=1,
  b=2, p=3 can publish. The final visible values are 1,2,10,3,12.
- Both tested memo creation orders produce those same phase snapshots. This
  does not prove arbitrary traversal-order independence or inspect intermediate
  callback delivery order.

The important relationship is between **live joined updates**, not just the
static nesting of boundary declarations: b is not c's input, but b's proposal
has joined a's proposal through p. A child of that joined update must therefore
observe b's committed value too. A static depth number or ancestor-cut test
alone is insufficient. This audit is evidence in favor of the existing
prototype's observable behavior, not a new defect requiring a patch.

For a new scheduler, group merging must update inherited exclusions and
invalidate candidates whose consumed/observed relationships changed. An already
accepted proposal cannot silently change its input version when groups merge.
The hard next case is discovering these joins in the opposite order or through
new conditional dependencies. Do not infer a general solution from this
pre-established join, or preserve several versions of q to avoid deciding.

## Next falsification gates, before a runtime rewrite

- Add a small operational DAG scheduler that selects preparation, rather than
  supplying it manually. It must cover two async memos sharing an input, a
  diamond with two consumers of one memo, nested boundaries and sibling joins.
- Distinguish open action scope, unresolved upstream input, active downstream
  work, and deferred work displaced by a child. Cancellation must not make an
  update publishable; closed scope alone must not defeat optimism.
- Exercise a late async mount, including an input becoming ready during mount.
  Test a child created by a proposed parent separately from an independent root.
- Handle dependency removal and conditional branches without global unrelated
  activity selecting contexts. Reversing sibling traversal must not change
  which input version a committed frame represents; callback order can remain
  unspecified.
- Treat lazy source-owned pending output creation as an event that must reach
  existing readers. Do not hide it behind a pre-existing supplied status bit.
- Introduce actual errors and owned cleanup before claiming publication solved.
  Logs/descriptors and pure read plans do not validate user lifecycle behavior.

The 35 tests here include 200 repeated shared-frame supersession cycles and
conditional graph transformations. They are bounded protocol tests, not the
scalar acceptance suite, a proof, a heap measurement, or performance evidence.
Do not add stores or port the context search to the runtime on their strength.
