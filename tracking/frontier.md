# Active frontier

This is an incremental executable translation, not a completed package port.

The user now explicitly requires a source-followable translation. Read
[source-fidelity.md](source-fidelity.md) for the contract and the audit of existing
substitutions. Repair these before expanding affected paths, or register a
necessary temporary deviation under [deviations.md](deviations.md). The user permits
tracked deviations to unblock progress while an issue/fix is investigated. A formal
TS/Bend equivalence proof is not required; no silent semantic repairs are allowed.

## Established execution path

`api.createMemo/createEffect -> core.recompute -> Evaluate/ReadNode -> graph.link
-> heap marking/pull -> core.finish/publish -> scheduler.commitPendingNode
-> core.runEffect -> tree.setText`.

The same definitions implement explicit `flush` and both differential and proof
scenarios. Setters evaluate pure updater expressions against the staged slot and
retain Solid's return-value behavior. Earlier preferences reported in the uploaded
guide were not treated as new user instructions. No previous implementation or
proof credit was imported.

## Supported grammar and limitations

- Owned synchronous nodes under one explicit top-level host root; stable signal,
  owner/computed, link and mechanical-tree identities. Lazy activation
  and observation-lifecycle dormancy/revival work, including dead-parent freeze. Internal
  constructors support nested-root parentComputed forwarding, tested at height,
  heap and read sites. Nested callback construction/root callback APIs remain open.
- Separate source constructors and lazy extension defaults now exist. Default
  sync is false; loading-seed presence includes explicit undefined. Synchronous
  seed/option histories execute; loading-window pending catches now execute through
  direct source probes; ordinary promise-like registration/settlement now executes; typed iterator consumption/flattening now executes. See
  [representation.md](representation.md) for storage-only extension fields.
- Reusable defunctionalized callback programs, not arbitrary JavaScript closures.
  Render application writes computed text. User application records its value
  and previous value. Owner cleanup programs can emit trace events, dispose
  owners, register cleanup, or throw a payload. They execute on the active owner
  machine, including reentrancy. Compute/effect programs can also write signals, register cleanup in the active context,
  dispose the root and install returned effect cleanup. Nested primitive construction
  and arbitrary callback reads remain open. Synchronous compute/effect error catches,
  user error programs, explicit previous-cleanup helpers and scheduler halts work.
  Pending-source propagation/retirement and loading-window/landing helpers now
  execute through core catches/reads. Mainline transactions join, merge, park,
  judge blockers and land through the same flush. Typed promise-like programs now execute registration and callback delivery.
  Typed iterator consumption/flattening executes; active boundary/lane scopes remain unfinished.
- Default strict equality and `equals:false`; arbitrary/throwing comparators are
  open. No equality-equivalence axiom is assumed. NaN is nonreflexive.
- Payloads distinguish absent staging, undefined, null, booleans, naturals, NaN,
  text, and opaque reference identities. Reference tokens must preserve host
  identity. Signed zero has strict-equality semantics. General binary64 numeric
  computation, functions-as-data, thenable shape probing and user Error objects
  as data still need a richer host protocol.
- Nat counters are mathematically unbounded in proofs. The emitted JS backend's
  supported integer range and the facade's 2^48-1 payload/arithmetic bound apply
  to execution. Proofs are about Bend terms, not unbounded JS integer arithmetic.
- Persistent list arenas retain retired records and have linear lookups. This is
  a representation cost, not evidence of Solid's algorithmic performance.
- Pointer walkers rely on structurally valid generated lists and finite resource
  budgets. The composed fixed-graph proofs establish successful completion for
  their inputs. A general representation invariant and progress bound remain
  open. Host tests check both link directions, tails, cycles, context restoration,
  and absence of stranded staging after completion.
- No browser, DOM, JSX, SSR, hydration, or store implementation is attempted.
  The reference build starts at the actual full signals index and retains store
  module initialization when reachable. Tests call no store APIs. Inertness of
  omitted shared store hooks is reviewed/tested for this grammar, not formally
  proved as a general module-initialization theorem.

## Proof coverage

`chain_once` and `chain_twice` check concrete writes `6`, then `9`, on the
source -> (+1) -> (*2) -> render (+source) graph with `equals:false`.
Initial allocation, staging, actual callback reads, memo results, dirty-heap
execution, commit and render application all participate. The result includes
actual attached tree text (`20`, then `29`), source/memo values, successful
completion, empty pending/render/user queues, restored runtime context, and reset
unflushed/promotion state. They also check that no live cold extension is allocated
(the arena retains only its reserved zero record).

A separate reusable path lemma relates actual `core.step` transitions to
`core.run` for arbitrary machine states and a valid finite execution path.
The concrete top-level laws are checked directly through the real API and driver.
No generated result, safety gate, alternate scheduler, or imported axiom supplies
the tree values.

Attempted arbitrary-natural-payload versions passed the frontend, but caused
excessive independent-kernel expansion under open contexts. Even canonical
transition witnesses remained too costly without further helper refinements.
Those attempts are not completed proofs and were removed from the active roots.
The concrete laws pass independent checking. The differential suite has
203 scenarios; focused tests additionally compare 7,680 constructor states,
4,608 commit states, 768 read states and 24 held-stash helper cases with the
actual pinned TS helpers. These include synthetic internal
states to probe branches; their counts are separate from end-to-end histories.
144 graph-state comparisons cover last-subscriber callbacks, cascading dormancy,
pending/zombie/dead guards and exact partial state after callback throws. Twelve
lifecycle comparisons cover recompute/park/commit/cancellation, cleanup-staged
live intake, unchanged frames and flush finally restoration.
Sixteen owner teardown scenarios additionally compare state and cleanup order,
including cleanup exceptions (distinct from reactive error/status programs).
The concrete `cleanup_reentry` law executes a detached disposal array whose
second callback disposes its root. It checks both owners' death, empty child and
disposal heads, effect-cleanup detachment, exact callback order `[22,44,33,11]`
and successful completion through the active owner machine. It is a closed
regression, not a general cleanup/reentrancy theorem.
Eighteen error histories and 2,880 status-state comparisons cover synchronous
error identity/sharing, diamond propagation, rederive/verdict enqueue branches,
clearStatus masks/metadata, later tracked retry, effect error programs/cleanup,
raw versus wrapped throws, halt/report ordering and overriding finally throws.
Status probes include blocked forwards. A separate 2,880-case pending matrix
compares source-set identity/order, new/repeated/stale-link propagation, null
source, loading parks, own-flight-only landing, retained retry paths, converging
settle walks, deferred releases and cleanup throws. These are direct helper
executions over synthetic state, not promise execution. Nine additional cases check
captured Set identity and live deletion/reinsertion/iteration semantics.
The concrete `error_propagates` and `error_recovers_same_value` laws check a
source -> conditional memo -> memo -> user chain through failure and equal-value
recovery: all three status/error slots, preserved wrapper identity, previous/value
slots, reports, empty queues and restored context/tracking/running, with no halt.
These are closed regressions, not a general error/status theorem.
The `pending_diamond_retires` and `pending_other_path_remains` laws additionally
construct initialized nodes, wire a diamond, propagate a NotReady source, and
check source/error/status/blocked slots after the actual settle helper. A node
skipped while another branch carries the source can be revisited after that
branch settles; an independent carrying path preserves pending. Host async
registration, delivery and transaction landing do not participate in those laws.
Eleven source-changing variants must be rejected. No arbitrary-value, arbitrary-
graph/history, general-error, async, or optimistic theorem is claimed. Exact TypeScript
correspondence and backend compiler correctness are trusted/tested, not proved.

## Concrete async proof extension

Five additional closed laws now check loading seed 0, later fulfillment 6, stale
object 1's ignored answer 99, object 2's committed answer 6, and an unseeded
pending diamond landing 6/7/8/15 with text 15. They use actual API construction,
callback delivery, status/graph/transaction/flush code and the mechanical tree;
settlement is an explicit external thenable input, not a native Promise timing
proof. Together with the earlier nine cases there are fourteen closed composed
regressions. Iterator and watcher semantics remain tested, not generally proved.

The old async proof fuel failure came from representing source 0x7fffffff as unary
Nat. Exact binary Question IDs repair that cost without changing source values or
branches. Three general kernel laws establish increment meaning, small-Nat
conversion meaning and reflexive equality. 4096 source counter steps, five large
counter starts, 69 provenance cases and 4103 mathematical vectors support the
representation. See [question-ids.md](question-ids.md). No generated execution
state, runtime fork or modified kernel supplies the direct new proofs.

## Current transaction milestone and next dependency

2,160 transaction-state comparisons cover source allocation/redirect/merge/join,
list/hold/frame walk, stale-reader and born-held decisions. Another 4,096 blocker
comparisons cover own-source filtering, retained link generations, truthy versus
nullish errors, zombie removal judgments and exact blocker lists. The 2,304 seam
and 48 deferred-zombie comparisons execute actual park/land, full queue ordering,
net-zero writes, cleanup-driven live rewrites and exceptional partial state.
4,096 held-operation comparisons cover signal/memo reads/writes, source unflushed
stash, frame/born-held posture, pending/error throws, recompute catches, staged
errors and error commits. Synthetic states are included; full package coverage
and arbitrary histories are not claimed.

The closed `transaction_parks` / `transaction_lands` laws construct a signal and
render callback, stage a write, and run the actual flush while a transaction's
explicit open count holds it. The text stays old while parked and becomes 6 after
closing the open count and landing. They check held slots/stamps, live and effect
queues, visible text, ambient restoration and successful completion. These laws
use an explicit transaction input, not the public action API or host promises.

1. Ordinary handleAsync thenable registration, callback delivery, supersession
   guards, settlement/rejection and loading windows now execute. Typed iterator initial drain, pumping, flattening and cancellation also execute.
   Continue with richer callbacks and active scopes. Public resolve/refresh watchers now have 158 histories and
   6,144 direct body comparisons; see [watchers.md](watchers.md).
   See [async.md](async.md) for 68 promise histories, 255 iterator histories, 18 source-only controls and
   4,096 flight-helper comparisons. Node state and next/return order are checked.
2. Preserve source behavior while extending actual async histories. Inert full-index
   hook bodies are exercised without boundary/lane/mark/store scopes; those scopes
   require their own translated engines, not an assumption that source hooks are
   absent.
3. Extend the translated transaction path to boundary/lane/action hooks and public
   scopes. Do not replace park/land decisions with waiting for all host promises.
4. Expand to typed error outcomes, loading seeds, ownership/cleanup and boundaries.
   Characterize the documented loading-seed conflict with a current-source repro
   before proposing a stronger law. No conflict is silently resolved by this port.
5. Port lanes/actions/verdict/truth as composed layers; then remaining public
   helpers, context, tracked reactions, marks, deferred/collection helpers and
   nonproduction hooks. Track every meaningful branch in the inventory.
6. Prove actual observation consistency and progress over increasing graph/program
   families, preserving source counterexamples and explicit host assumptions.

All source branches are still marked open for individual branch review, even
where a restricted function port exists. No blended completion percentage is used.

A fifteenth closed composed law is explicitly negative baseline evidence:
`staged_error_recovery_counterexample` checks the pinned successful-value-as-error
recovery failure. It is not a successful coherence guarantee. See
[the upstream candidate](upstream/staged-error-recovery.md) for native/immediate
controls, exact source operations and current-head/duplicate checks. Both bug
candidates are preserved; the semantic deviation register remains empty.
