# Scoped recompute return boundaries. These are not a complete lane/flush law.
import Base
import ../runtime/core.bend as C
import ../runtime/constants.bend as K
import ../representation/records.bend as R
import ../representation/base.bend as B

def selected(+w: R.World, +id: Nat, pending: Bool) -> R.Value:
  B.choose(~R.Value, pending,
    _ => B.selected(R.Node.pending(B.node(w, id)), R.Undefined{}),
    _ => B.choose(~R.Value, Bool.and(B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()), B.present(R.NodeExtension.lane(B.extension(w, id)))),
      _ => B.selected(R.NodeExtension.lane(B.extension(w, id)), R.Undefined{}), _ => R.Node.value(B.node(w, id))))

def pendingFirst(+w: R.World, +id: Nat,
  present: {B.present(R.Node.pending(B.node(w, id))) == True{} : Bool}) ->
  {C.passValue(w, id) == B.selected(R.Node.pending(B.node(w, id)), R.Undefined{}) : R.Value}:
  Equal.cong(Bool, R.Value, flag => selected(w, id, flag), B.present(R.Node.pending(B.node(w, id))), True{}, present)

def nonEffectNoRun(+w: R.World, +id: Nat, +value: R.Value, +create: Bool, +changed: Bool, +lane: Nat) ->
  {C.markPublishedEffectAs(w, id, value, create, changed, lane, False{}) == w : R.World}:
  {==}

def unchangedNoRun(+w: R.World, +id: Nat, +value: R.Value, +create: Bool, +effect: Bool, +lane: Nat) ->
  {C.markPublishedEffectAs(w, id, value, create, False{}, lane, effect) == w : R.World}:
  match effect:
    case False{}: {==}
    case True{}: {==}

def noMountJoin(+w: R.World, +id: Nat, +previous: Nat, +old: R.LaneMount) ->
  {C.joinedPass(w, id, C.LanePass{previous, old, R.MountFalse{}, False{}}) == B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_JOINED()) : Bool}:
  {==}

# Even with arbitrary current root/seat data, restore writes only the captured
# root. It does not undo the lane a tracked read seated for publication.
def restoreCapturedMount(+w: R.World, +previous: Nat, +old: R.LaneMount, +mount: R.LaneMount) ->
  {C.restoreMount(w, C.LanePass{previous, old, mount, False{}}) == R.World.with_laneState(w, R.LaneState.with_root(R.World.laneState(w), old)) : R.World}:
  {==}

# Mainline truth outcomes return to the original publication continuation.
# An accepted truth does not also publish into the ordinary value slot.
def handledOutcome(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +value: R.Value, +create: Bool, +height: Nat, +outgoing: R.Value, +sources: Nat, +wasSource: Bool, +joined: Bool, +changed: Bool) ->
  {C.dispatch(w, C.PublishOutcome{id, value, create, height, outgoing, sources, wasSource, joined, changed} <> rest, R.Boolean{True{}} <> stack)
    == C.publicationCompleted(rest, stack, id, outgoing, sources, wasSource, B.Bundle{w, changed}) : C.Machine}:
  {==}
