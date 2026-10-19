# core/core.ts:setMemo prefix and post-setSignal remainder. The callback call
# and its return points live in core.bend; these are the source field decisions.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./constants.bend as K
import ./transaction.bend as X
import ./heap.bend as H

# Keep short-circuit order: txOf is consulted only for held non-manual staging.
def held(+w: R.World, +id: Nat) -> B.Bundle<R.World, Bool>:
  eligible = Bool.and(B.has(R.Node.config(B.node(w, id)), K.CONFIG_HELD()), Bool.not(B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_MANUAL_WRITE())))
  B.choose(~B.Bundle<R.World, Bool>, eligible,
    _ =>
      +pair = X.txOf(w, id)
      +w = B.first(R.World, Nat, pair)
      B.Bundle{w, Nat.is_ne(B.second(R.World, Nat, pair), R.World.flushTransaction(w))},
    _ => B.Bundle{w, False{}})

# Source runs this only after setSignal returns successfully. The original held
# local decides the branch even if the invoked updater changed other state.
def finish(+w: R.World, +id: Nat, held: Bool) -> R.World:
  B.choose(~R.World, held,
    _ =>
      +w = B.store_node(w, id, R.Node.with_flags(B.node(w, id), B.set(B.clear(R.Node.flags(B.node(w, id)), K.REACTIVE_CHECK()), K.REACTIVE_DIRTY())))
      B.schedule(H.insertIntoHeap(w, id)),
    _ => B.choose(~R.World, B.present(R.Node.pending(B.node(w, id))),
      _ => B.store_node(w, id, R.Node.with_flags(B.node(w, id), B.set(R.Node.flags(B.node(w, id)), K.REACTIVE_MANUAL_WRITE()))),
      _ => w))
