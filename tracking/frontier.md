# Active frontier

This is the first executable checkpoint, not a completed package port.

The user now explicitly requires a source-followable translation. Read
[source-fidelity.md](source-fidelity.md) for the contract and the audit of existing
substitutions. These must be repaired before expanding affected paths. A formal
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

- Owned synchronous nodes under one explicit top-level root; stable signal,
  owner/computed, link and mechanical-tree identities. Lazy **initial activation**
  works; lazy/ownerless observation-lifecycle dormancy is not implemented.
- Reusable defunctionalized callback programs, not arbitrary JavaScript closures.
  Render application writes computed text. User application records its value
  and previous value. Callback writes, nested primitive construction, returned
  cleanup functions, and arbitrary imperative callback reads remain open.
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
completion, empty pending/render/user queues and restored runtime context.

A separate reusable path lemma relates actual `core.step` transitions to
`core.run` for arbitrary machine states and a valid finite execution path.
The concrete top-level laws are checked directly through the real API and driver.
No generated result, safety gate, alternate scheduler, or imported axiom supplies
the tree values.

Attempted arbitrary-natural-payload versions passed the frontend, but caused
excessive independent-kernel expansion under open contexts. Even canonical
transition witnesses remained too costly without further helper refinements.
Those attempts are not completed proofs and were removed from the active roots.
The two concrete laws pass independent checking. The differential suite passes
185 scenarios, and four deliberately broken implementations are rejected. No arbitrary-value, arbitrary-
graph/history, error, async, or optimistic theorem is claimed. Exact TypeScript
correspondence and backend compiler correctness are trusted/tested, not proved.

## Next dependency and broader roadmap

1. Establish reusable arena/linked-list invariants and operation refinements,
   then generalize the concrete composed proof to arbitrary payloads and graphs. Preserve the current scenarios as regressions.
2. Port `NodeExtension`, outcome/status storage and source-shaped control unwinding;
   then translate pending-source propagation/retirement and superseded settlements.
3. Add actual transaction discovery, blockers, merge redirects, park/land/reruns,
   and queue release to the SAME driver. This is necessary before async consistency
   claims; waiting for all host promises is not an acceptable substitute.
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
