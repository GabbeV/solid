# core/core.ts read-state helpers, shared with scheduler.ts. Keeping these in
# a leaf module expresses the TS core/scheduler cycle without a Bend import
# cycle. Globals are fields of the threaded World, not recomputed predicates.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./constants.bend as K

def markUnflushedStaged(w: R.World) -> R.World:
  R.World.with_unflushedStaged(w, True{})

def readerSeesCommitted(+w: R.World, source: Nat, +reader: Nat) -> Bool:
  Bool.or(Nat.is_eq(reader, 0n), Bool.or(Bool.not(B.present(R.Node.pending(B.node(w, source)))),
    B.has(R.Node.config(B.node(w, reader)), K.CONFIG_CHILDREN_FORBIDDEN())))

def unflushedValue(+w: R.World, +id: Nat) -> B.Bundle<R.World, R.Slot>:
  +n = B.node(w, id)
  B.choose(~B.Bundle<R.World, R.Slot>, Bool.or(R.World.running(w), Bool.or(Bool.not(B.present(R.Node.pending(n))), B.has(R.Node.config(n), K.CONFIG_PROMOTED()))),
    _ => B.Bundle{w, R.Empty{}},
    _ => B.choose(~B.Bundle<R.World, R.Slot>, B.has(R.Node.config(n), K.CONFIG_HELD()),
      # The held node's _x._flushedAt / _flushed stash is not yet translated.
      # Refusal is an unsupported domain, not a substitute visibility rule.
      _ => B.Bundle{R.World.with_fault(w, R.Unsupported{3n}), R.Empty{}},
      _ => B.Bundle{w, R.Present{R.Node.value(n)}}))

def markLateLinker(+w: R.World, +reader: Nat) -> R.World:
  B.store_node(w, reader, R.Node.with_flags(B.node(w, reader), B.set(R.Node.flags(B.node(w, reader)), K.REACTIVE_MISSED_WAKE())))

def notePromotedWrite(+w: R.World, +id: Nat) -> R.World:
  B.choose(~R.World, Bool.or(R.World.running(w), B.has(R.Node.config(B.node(w, id)), K.CONFIG_PROMOTED())),
    _ => w,
    _ =>
      +w = B.store_node(w, id, R.Node.with_config(B.node(w, id), B.set(R.Node.config(B.node(w, id)), K.CONFIG_PROMOTED())))
      R.World.with_promotedWrites(w, B.append(Nat, R.World.promotedWrites(w), [id])))

def clearPromoted(ids: List<&2, Nat>, +w: R.World) -> R.World:
  match ids:
    case Nil{}:
      w
    case +id <> rest:
      clearPromoted(rest, B.store_node(w, id, R.Node.with_config(B.node(w, id), B.clear(R.Node.config(B.node(w, id)), K.CONFIG_PROMOTED()))))

def resyncUnflushedCompanions(+w: R.World) -> R.World:
  +w = R.World.with_unflushedStaged(w, False{})
  B.choose(~R.World, List.is_empty(&2, Nat, R.World.promotedWrites(w)), _ => w,
    _ =>
      +w = clearPromoted(R.World.promotedWrites(w), w)
      R.World.with_promotedWrites(w, []))
