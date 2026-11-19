# Ordinary scheduler: attribution and a narrow empty-publication path

Evidence: stage182 size-scalar.json; source at investigation start 03628b9;
comparison source `git diff 4fe75321 -- packages/signals/src/core/scheduler.ts`.
No runtime edits, builds, tests, or timings were performed. Numbers below are
measured historical module attribution, not new savings or function attribution.

## Shipped bytes versus source

| Scenario | Next scheduler | Experiment scheduler | Delta |
| --- | ---: | ---: | ---: |
| Ordinary | 4,687 | 5,640 | +953 |
| Optimism | 5,783 | 7,512 | +1,729 |
| Observed optimism | 6,180 | 7,731 | +1,551 |

Ordinary total is 21,456 versus 19,825 (+1,631); scheduler accounts for 953
(~58%) of that growth. Remaining largest deltas: core +277, effect +184,
owner +43. Importing optimism retains another 1,872 scheduler bytes; observations
retain another 219. These scenario deltas are not costs of invoking a hook.
Coordination contributes **zero** ordinary bytes, 8,962 optimism bytes, and
9,390 observed-optimism bytes. Committed-dependencies is also absent ordinarily.
Minified module attribution is additive; Brotli module attribution is not given.

The source diff is +603/-178 lines, dominated partly by comments and disabled
alternatives; it is not a byte allocation. `LEGACY_LANES` and module-binding
hooks deliberately permit folding. Deleting old lane hooks, arrays, and legacy
branches earns zero shipped savings where already erased. Source cannot isolate
how much of +953 belongs to an individual retained helper without a new trial.

## Mechanism and ordinary write path

`core/core.ts:2860` setSignal stages the proposal, `:2961` inserts subscribers;
`core/scheduler.ts:1795` insertSubs enqueues them; flush `:1121` drains the heap;
`core/core.ts:396` recompute routes to recomputeBody and `:664` calls `_fn`;
settle `core/scheduler.ts:1167` commits pending nodes at `:1222` when unjoined;
`:1305` reconstructs callback queues; flush runs render then user callbacks.
An ordinary synchronous turn without live updates does not call list/merge,
blocked/queuedWork, reruns/land, or scoped calculation. It nevertheless allocates
fresh empty landing queues at `:1255`, visits the empty landing loop, and runs
the two-slot queue-composition loop before restoring its original own queues.

| Hook family | Ordinary-only build | Feature imported, fully idle | Ordinary async hold with feature imported |
| --- | --- | --- | --- |
| Compute/rerun/read/join/detached | Erased | Undefined guards | Enabled |
| Own/merge/frame-read/status/notify | Erased | Undefined guards | Enabled |
| Before-commit/seam/publication/lifetime | Erased | Cleared | Enabled |
| Transaction creation/order/visibility | Erased | Installed | Installed |

Bindings/setters: `core/scheduler.ts:69-151`. Lifecycle activation/clear:
`layers/coordination.ts:211-233`, `:1075`, `:1258`. A new ordinary transaction
sets depth zero and enables coordination; optional imported code is therefore
active for ordinary holds, even without an optimistic override. Idle transaction
creation/order/visibility hooks are not all called by every ordinary read:
creation requires a transaction; visibility requires blocking traversal; order
is currently called at every seam and immediately returns when no order is owed.
Read/context hooks also appear in `core/core.ts:1337`, `:1413`, `:2355`, `:2443`.

Retained ordinary scheduler changes versus next include intrusive ownership and
transfer (`:770-795`), merge queue redirection (`:556-593`), Set-based reruns plus
disposal registry (`:1413-1471`, `:1747-1774`), queued publication work (`:1476`),
coherent landing callbacks (`:1498-1542`), proposal cancellation/parking (`:1572`),
and repeated landing traversal (`:1257-1279`). These are source mechanisms, not
separately measured pieces of +953. Ownership is already O(1) through intrusive
links; replacing it with another registry has no established algorithmic gain.

## Recommendation: one local empty-publication scope check (general upstream win)

Classification: this is generally upstream-applicable, not enabled by the
experiment. Both next 4fe75321 (settle landing block around scheduler:1100) and
bcef1041 (`:1136-1193`) allocate `[[], []]`, traverse transactions, and reconstruct
queues on an ordinary empty-publication seam. Their optional lanes require the
corresponding no-lane-work condition; ordinary-only/imported-idle cases qualify.
Only skipping the experiment's layerOrder and empty do/while is experiment-specific;
the dominant allocation/composition opportunity is shared. Keep any gain separate
from closing experiment overhead; compare equivalent changes on next before
crediting an improvement in the experiment/next ratio. No measurements taken.

Small experiment: after the preparation fixed point, commitPendingNodes and
held-trim cleanup, evaluate `t === null && transactions.length === 0` immediately
before creating landing queues (`:1247-1255`). On that path retain own queues;
skip landing queue allocation, layerOrder, empty landing traversal, and later
own/landing recomposition. Preserve storeCommit, releaseAmbientMarks, zombie
drain, boundarySeam and layerSeam in their current order. Do not early-return.
Use the local result only to record that this seam produced no landing queues;
it is not a cached claim that callbacks cannot create a transaction afterward.

This replaces empty-publication scaffolding with one guard; it adds no node
field/cache, generic registry, or optional-module dependency. It applies equally
to ordinary-only and fully idle feature-imported turns. Likely performance
benefit: fewer allocations and decisions per synchronous flush. Byte direction
is **unknown**: branching or helper extraction can grow minified output. It is
primarily a cold-placement/ordinary throughput experiment, not a demonstrated
answer to the whole +953-byte growth. If bytes grow and throughput is neutral,
reject it. A generalized callback registry or sticky per-calculation mode is
not justified: activation can occur inside user calculation, and existing
undefined hooks already clear the idle work.

## Obligations, falsifiers, and minimum validation

Do not gate queuedWork or repeated landing judgement on optional imports.
Ordinary land/reruns/cleanup can enqueue held work; absence of explicit boundary
API usage does not prove that publication scans are redundant. Private creator
retry and publication readiness are distinct. Lifetime readiness remains separate.
The multi-update ready snapshot is coordinator-guarded already (`:1263`); that
fact does not make other readiness checks coordinator-only.

The empty-publication guard must run after preparation and commit cleanup.
Falsifier: a turn starts with no updates; a replacement cleanup or boundary
preparation opens an async action. Its value, attachment and callbacks must
remain held exactly as before. Also test an unrelated pre-existing open action,
a cleanup that only writes a synchronous signal, and a scheduled callback that
opens an action after publication. Assert render/user callback ordering and
owned-child cleanup exactly; cover no optional import and import-but-idle.

Minimum existing selection: unified-coordination (bounded reruns, two independent
holders, same-depth peer entanglement), unified-lifetime-retention first case,
unified-experiment sibling join/equal-valued replacement/superseded async cases,
unified-equality-publication and unified-fresh-mount; retain Show DOM attachment
controls from stage182 for queue ordering. Add only the missing guard-trigger
cleanup/preparation controls above. Then primary-controlled production build,
source/production selection, and the same three scalar size scenarios. Only
if those pass schedule exclusive ordinary sync throughput measurements against
unmodified next 4fe75321; do not infer gains from source branch counts.

Historical rejection: SIZE-96 removed rerunHolders and scanned all live updates
on disposal; repeated pre-flush subtree disposal became quadratic. Keep the
registry and its lazy cleanup hook. No speculative Set-to-array simplification.
