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
      _ => B.choose(~B.Bundle<R.World, R.Slot>, Nat.is_ne(R.Node.x(n), 0n),
        _ => B.Bundle{w, B.choose(~R.Slot, B.stampMatches(R.NodeExtension.flushedAt(B.extension(w, id)), R.World.clock(w)),
          _ => R.NodeExtension.flushed(B.extension(w, id)), _ => R.Empty{})},
        _ => B.Bundle{R.World.with_fault(w, R.Unsupported{3n}), R.Empty{}}),
      _ => B.Bundle{w, R.Present{R.Node.value(n)}}))

# core/core.ts:stashFlushed. Held nodes already have an extension in source;
# a missing one is an invalid representation, not permission to allocate it.
def stashFlushed(+w: R.World, +id: Nat) -> R.World:
  B.choose(~R.World, Nat.is_eq(R.Node.x(B.node(w, id)), 0n),
    _ => R.World.with_fault(w, R.Unsupported{3n}),
    _ => B.choose(~R.World, B.stampMatches(R.NodeExtension.flushedAt(B.extension(w, id)), R.World.clock(w)),
      _ => w,
      _ =>
        +w = B.store_extension(w, id, R.NodeExtension.with_flushed(B.extension(w, id), R.Node.pending(B.node(w, id))))
        +w = B.store_extension(w, id, R.NodeExtension.with_flushedAt(B.extension(w, id), R.Stamped{R.World.clock(w)}))
        R.World.with_unflushedStaged(w, True{})))

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

# core/core.ts:stagedRead, shared with lane routing to keep one implementation.
# The full package profile installs laneSeamsHook. Public scopes remain inactive
# until the rest of that engine is ported; passLane zero skips the collector.
def stagedRead(+w: R.World, +reader: Nat, source: Nat) -> R.World:
  B.choose(~R.World, B.has(R.Node.status(B.node(w, source)), K.STATUS_UNINITIALIZED()), _ => w,
    _ =>
      +w = B.store_node(w, reader, R.Node.with_flags(B.node(w, reader), B.set(R.Node.flags(B.node(w, reader)), K.REACTIVE_STAGED_READ())))
      B.choose(~R.World, Bool.and(Nat.is_eq(R.World.passLane(w), 0n), Bool.not(Bool.and(B.effect(R.Node.kind(B.node(w,reader))),B.has(R.Node.config(B.node(w,reader)),K.CONFIG_VERDICT())))), _ => w,
        _ =>
          +state = R.World.laneState(w)
          R.World.with_laneState(w, R.LaneState.with_stagedReaders(state, B.append(Nat, R.LaneState.stagedReaders(state), [reader])))))
