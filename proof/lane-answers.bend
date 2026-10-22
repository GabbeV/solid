# Source boundary properties; no arbitrary graph/lane progress claim.
import Base
import ../runtime/core.bend as C
import ../runtime/lanes-state.bend as L
import ../runtime/constants.bend as K
import ../runtime/transaction.bend as Tx
import ../representation/records.bend as R
import ../representation/base.bend as B

def erroredOutcome(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +value: R.Value) ->
  {C.laneOutcome(w, rest, stack, id, value, True{}) == C.Machine{w, rest, R.Boolean{True{}} <> stack} : C.Machine}:
  {==}

def snapshotEntry(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>) ->
  {C.laneCorrections(w, rest, stack) == C.Machine{w, C.LaneCorrections{R.LaneState.live(R.World.laneState(w)), False{}} <> rest, stack} : C.Machine}:
  {==}

def emptyCorrections(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +judged: Bool) ->
  {C.laneCorrectionsLoop(w, rest, stack, [], judged) == C.Machine{w, rest, R.Boolean{judged} <> stack} : C.Machine}:
  {==}

# The core setter selects the lane hook after argument/updater evaluation and
# before any held join or isSame catch. current is still the caller's local.
def writeChoice(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +current: R.Value, +value: R.Value, lane: Bool) -> C.Machine:
  B.choose(~C.Machine, lane, _ => C.Machine{w, C.LaneWrite{id, value} <> rest, stack}, _ => C.setPlainResolved(w, rest, stack, id, current, value))

def writeDispatch(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +current: R.Value, +value: R.Value,
  known: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()) == True{} : Bool}) ->
  {C.setResolved(w, rest, stack, id, current, value) == C.Machine{w, C.LaneWrite{id, value} <> rest, stack} : C.Machine}:
  Equal.cong(Bool, C.Machine, flag => writeChoice(w, rest, stack, id, current, value, flag), B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()), True{}, known)

# The ordinary pending reader is served by the same pending/error continuation
# when a lane returns the real fall-through sentinel.
def fallthrough(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +reader: Nat, +forced: Bool) ->
  {C.readLaneValue(w, rest, stack, id, reader, forced, R.NotPendingToken{}) == C.readPendingStatus(w, rest, stack, id, reader, forced) : C.Machine}:
  {==}

# Successful undefined is a real early return, not fall-through or a staged read.
def undefinedRead(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +reader: Nat, +forced: Bool) ->
  {C.readLaneValue(w, rest, stack, id, reader, forced, R.Undefined{}) == C.Machine{B.event(w, R.ReadValue{reader, id, R.Undefined{}}), rest, R.Undefined{} <> stack} : C.Machine}:
  {==}
