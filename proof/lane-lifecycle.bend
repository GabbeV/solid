# Quantified boundaries of the actual core lane lifecycle helpers.
import Base
import ../runtime/core.bend as C
import ../runtime/transaction.bend as Tx
import ../runtime/constants.bend as K
import ../representation/records.bend as R
import ../representation/base.bend as B

def leakedSeam(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +lane: Nat) ->
  {C.laneSeam(w, rest, stack, lane, True{}) == C.Machine{B.store_transaction(w, lane, R.Transaction.with_held(B.transaction(w, lane), True{})), rest, stack} : C.Machine}:
  {==}

def effectCommit(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +shown: R.Slot) ->
  {C.dissolveCommitted(w, rest, stack, id, True{}, shown) == C.Machine{w, rest, stack} : C.Machine}:
  {==}

def reverseEndEntry(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +parent: Nat) ->
  {C.endLanes(w, rest, stack, parent) == B.choose(~C.Machine, R.LaneState.guessed(R.World.laneState(w)), _ => C.Machine{w, C.EndKept{parent, B.length(R.KeptGuess, R.LaneState.kept(R.World.laneState(w)))} <> rest, stack}, _ => C.Machine{w, C.EndLanesLoop{parent, B.length(Nat, R.LaneState.live(R.World.laneState(w)))} <> rest, stack}) : C.Machine}:
  {==}

def confirmationEnd(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +parent: Nat, +value: R.Value) ->
  {C.supersedeEnd(w, rest, stack, id, parent, value) == C.Machine{B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Present{value})), rest, stack} : C.Machine}:
  {==}

def hiddenCorrection(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat) ->
  {C.dispatch(w, C.DissolveHidden{id} <> rest, stack) == C.Machine{B.store_node(w, id, R.Node.with_config(B.node(w, id), B.clear(R.Node.config(B.node(w, id)), U32.or(K.CONFIG_STAGED(), U32.or(K.CONFIG_HELD(), K.CONFIG_HELD_FRAME()))))), rest, stack} : C.Machine}:
  {==}
