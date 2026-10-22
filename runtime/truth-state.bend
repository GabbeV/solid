# core/truth.ts:laneValueOf, apart from the active lane engine like the source.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./constants.bend as K

def laneValueOf(+w: R.World, +id: Nat) -> R.Value:
  +n = B.node(w, id)
  B.choose(~R.Value, Bool.and(Bool.not(B.has(R.Node.config(n), K.CONFIG_GUESS())), B.present(R.Node.pending(n))),
    _ => B.selected(R.Node.pending(n), R.Undefined{}),
    _ => B.selected(R.NodeExtension.lane(B.extension(w, id)), R.Node.value(n)))
