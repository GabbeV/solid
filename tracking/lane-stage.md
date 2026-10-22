# Lane pass staging

Source `core/lanes.ts:laneStage`, Solid a2a5b6f8 (rc.16). The actual typed helper
now executes in `runtime/lanes-state.bend`, using the existing ext/list/pending
queue functions and the newly integrated active blocker. Core hook invocation,
public windows, lane reads/writes, reveal/correction/dissolution and boundary
mounts remain unfinished. No active public scope is admitted by this helper.

| Source segment | Bend | Preserved operations |
| --- | --- | --- |
| errored false/true/source | StageError | StageAnswered, StageFailed and StagePendingFrom retain the three source meanings; a source object is not collapsed into true. |
| entry guard | laneStage | create, interrupted pass, LANE_READ or GUESS permit entry; otherwise leave. |
| leaving | leaveStage/leaveStageEnd | Capture nullable extension/transaction. A shown transaction asks actual blocked(resolveTx(parent)) before LEFT_SHOWN; clear transaction only when the captured transaction is a lane, clear lane slot, then clear override/held/frame config. No cold extension is allocated. |
| computation entry | computationStage | If not already overridden, clear pending value, change config then ext. A pass with an answer clears GUESS; an interrupted one keeps it. Actual list owns membership and stale-list behavior. |
| pending effect in its frame | framePending/effectStage | A pending source object that initialized, a held/recomputing leaf, and no existing lane seat queues the effect and returns false. A first-loading source or literal true error takes the other path. |
| effect entering | effectStage | Interrupted work sets LANE_DIRTY then lists it. Effects do not get a public lane value or computation override config. |

The source private LEFT_SHOWN bit is exactly 1<<20. Pending queue semantics are
those of the shared source queue helper (append, and mark unflushed outside a
running flush); the port does not invent a staging flag/time update or deduplicate
that queue. The helper itself publishes no lane payload and disposes no owners:
those are later source operations, still unfinished.

1,328 actual-source helper programs cover memo/effect entry and leaving,
three error forms, held/current lane identity, source loading versus initialized,
shown and blocked parents, frame staging, absent/present undefined/numeric slots,
repeat calls and pending queue order. They compare transaction membership,
node/cold-extension flags/config/status/pending/lane values, pointer/group state,
queues, unflushed state, saved judge and answers. Private exports/priming are
added only in memory; original source bodies are not replaced. Constructor
identity/held-state constraints and synthetic metadata controls are distinguished
from public programs.

Four independently checked quantified World properties cover a cold staged pass
that read no lane leaving without allocation/change, exact memo entry clearing
staging and listing, literal-true failed effect entry marking/listing without a
computation value, and an initialized-source pending effect staying with its
frame. Other record fields, arenas/payloads and surrounding World are quantified
within the scopes in `proof/lane-stage.bend`. These are not public lifecycle,
seam/progress or TypeScript-equivalence theorems. Eight added mutations target
these decisions; four fail proof assertions and four native helper assertions.
Public histories / composed closed regressions remain 3114 / 72. The public
runtime/reference artifacts are byte-for-byte unchanged from ead88ec because
this active core hook is not installed yet; direct helper probes and proof roots
compile and execute the one new implementation. The source pin/deviation register
are unchanged.
