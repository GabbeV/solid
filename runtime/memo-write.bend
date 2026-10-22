# core/core.ts:setMemo prefix and post-setSignal remainder. The callback call
# and its return points live in core.bend; these are the source field decisions.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./constants.bend as K
import ./transaction.bend as X
import ./heap.bend as H
import ./write.bend as W
import ./status.bend as A

# Keep short-circuit order: txOf is consulted only for held non-manual staging.
def held(+w: R.World, +id: Nat) -> B.Bundle<R.World, Bool>:
  eligible = Bool.and(B.has(R.Node.config(B.node(w, id)), K.CONFIG_HELD()), Bool.not(B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_MANUAL_WRITE())))
  B.choose(~B.Bundle<R.World, Bool>, eligible,
    _ =>
      +pair = X.txOf(w, id)
      +w = B.first(R.World, Nat, pair)
      B.Bundle{w, Nat.is_ne(B.second(R.World, Nat, pair), R.World.flushTransaction(w))},
    _ => B.Bundle{w, False{}})

# setMemo's error recovery is after a held updater pre-call, before setSignal.
# The shown error remains read-visible until the staged write commits (#4110).
def recover(+w: R.World, +id: Nat) -> R.World:
  B.choose(~R.World, B.has(R.Node.status(B.node(w, id)), K.STATUS_ERROR()),
    _ =>
      +w = B.store_extension(w, id, R.NodeExtension.with_shownError(B.extension(w, id), R.NodeExtension.error(B.extension(w, id))))
      A.notifyStatusWith(w, id, 0, R.Undefined{}), _ => w)

# Source runs this only after setSignal returns successfully. The original held
# local decides the branch even if the invoked updater changed other state.
def finish(+w: R.World, +id: Nat, held: Bool) -> R.World:
  +w = B.store_node(w, id, R.Node.with_config(B.node(w, id), B.clear(R.Node.config(B.node(w, id)), K.CONFIG_STAGED_ERROR())))
  B.choose(~R.World, held,
    _ =>
      +w = B.store_node(w, id, R.Node.with_flags(B.node(w, id), B.set(B.clear(R.Node.flags(B.node(w, id)), K.REACTIVE_CHECK()), K.REACTIVE_DIRTY())))
      B.schedule(H.insertIntoHeap(w, id)),
    _ => B.choose(~R.World, B.present(R.Node.pending(B.node(w, id))),
      _ => B.store_node(w, id, R.Node.with_flags(B.node(w, id), B.set(R.Node.flags(B.node(w, id)), K.REACTIVE_MANUAL_WRITE()))),
      _ => w))

# Source setMemo(undefined), used when owner invokes its bound cleanup with no
# arguments. This argument has no callable arm, so the same prefix and remainder
# can run in the existing owner machine without an expression/read suspension.
def clear(+w: R.World, +id: Nat) -> R.World:
  +pair = held(w, id)
  +w = W.setSignal(recover(B.first(R.World, Bool, pair), id), id, R.Undefined{})
  B.choose(~R.World, B.ok(w), _ => finish(w, id, B.second(R.World, Bool, pair)), _ => w)
