import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/construct.bend as N
import ../../runtime/graph.bend as G
import ../../runtime/owner.bend as O
import ../../runtime/extension.bend as E
import ../../runtime/status.bend as A
import ../../runtime/pending-state.bend as P
import ../../runtime/pending.bend as Q
import ../../runtime/constants.bend as K

def seed(+w: R.World, +id: Nat, +source: Nat, +status: U32, +additional: Bool, +withSources: Bool) -> R.World:
  +w = E.ext(w, id)
  +w = B.store_node(w, id, R.Node.with_status(B.node(w, id), status))
  +error = B.choose(~R.Value, B.has(status, K.STATUS_ERROR()), _ => R.StatusFailure{2n, 2n, R.Number{99n}, "99"}, _ => R.NotReadyFailure{1n, source})
  +w = B.store_extension(w, id, R.NodeExtension.with_error(B.extension(w, id), error))
  +w = B.store_extension(w, id, R.NodeExtension.with_blocked(B.extension(w, id), R.Present{R.Boolean{True{}}}))
  sources = B.choose(~R.SourceSet, withSources, _ => R.Sources{B.choose(~List<&2, Nat>, additional, _ => [source, 4n], _ => [source])}, _ => R.NoSources{})
  B.setPendingSources(w, id, sources)

def initial(+op: U32, +status: U32, flags: U32, +extra: Bool, +additional: Bool, +block: Bool, config: U32) -> R.World:
  +w = N.createOwner(R.World.with_clock(B.empty(), 5n), 0n, False{})
  +opts = R.NodeOptions.with_lazy(N.defaults(), True{})
  +w = N.computed(0n, w, R.Literal{R.Number{7n}}, opts, 1n)
  +w = N.computed(0n, w, R.Literal{R.Number{11n}}, opts, 1n)
  +w = N.computed(0n, w, R.Literal{R.Number{13n}}, opts, 1n)
  +w = N.computed(0n, w, R.Literal{R.Number{17n}}, opts, 1n)
  +w = N.computed(0n, w, R.Literal{R.Number{19n}}, opts, 1n)
  +w = B.store_node(w, 2n, R.Node.with_flags(R.Node.with_config(B.node(w, 2n), 0), 0))
  +w = B.store_node(w, 3n, R.Node.with_flags(R.Node.with_config(B.node(w, 3n), config), 0))
  +w = B.store_node(w, 4n, R.Node.with_flags(R.Node.with_config(B.node(w, 4n), 0), 0))
  +w = B.store_node(w, 5n, R.Node.with_flags(B.node(w, 5n), flags))
  +w = G.link(G.link(G.link(G.link(w, 2n, 3n), 2n, 4n), 3n, 5n), 4n, 5n)
  +w = B.choose(~R.World, extra, _ => G.link(w, 6n, 4n), _ => w)
  +source = B.choose(~Nat, U32.is_eq(op, 1), _ => 2n, _ => 6n)
  +withSources = Bool.or(Bool.not(U32.is_eq(op, 0)), extra)
  +w = seed(w, 2n, source, status, additional, True{})
  +w = seed(w, 3n, source, status, additional, withSources)
  +w = seed(w, 4n, source, status, additional, withSources)
  +w = seed(w, 5n, source, status, additional, withSources)
  +w = B.store_extension(w, 3n, R.NodeExtension.with_unobserved(B.extension(w, 3n), 2n))
  +w = R.World.with_errorSerial(w, 2n)
  +w = O.cleanup(w, 5n, 1n)
  R.World.with_cleanupPrograms(w, [R.CleanupProgram{[], False{}, 0n}, R.CleanupProgram{R.CleanupEmit{101n} <> B.choose(~List<&2, R.CleanupAction>, block, _ => [R.CleanupThrow{R.Number{42n}}], _ => []), False{}, 0n}, R.CleanupProgram{[R.CleanupEmit{102n}], False{}, 0n}])

def apply(+w: R.World, op: U32, +additional: Bool, +block: Bool) -> R.World:
  match op:
    case 0:
      A.notifyStatusWith(w, 2n, K.STATUS_PENDING(), R.NotReadyFailure{1n, 6n}, block)
    case 1:
      Q.settlePendingSource(w, 2n, 2n)
    case 2:
      Q.settlePendingSource(w, 2n, 6n)
    case 3:
      Q.releaseSettledDependents(w, 2n)
    case 4:
      P.parkLoadingWindow(w, 2n, R.NotReadyFailure{1n, 6n})
    case 5:
      w = B.first(R.World, Bool, P.addPendingSource(w, 5n, 5n))
      Q.landStatus(w, 5n, additional)
    case 7:
      A.notifyStatusWith(w, 2n, K.STATUS_ERROR(), R.NotReadyFailure{1n, 6n}, block)
    case 8:
      A.notifyStatusWith(R.World.with_errorSerial(w, 3n), 2n, K.STATUS_PENDING(), R.NotReadyFailure{3n, 0n}, block)
    case 9:
      A.notifyStatusWith(B.store_node(w, 3n, R.Node.with_depGen(B.node(w, 3n), 1n)), 2n, K.STATUS_PENDING(), R.NotReadyFailure{1n, 6n}, block)
    case _:
      w = B.first(R.World, Bool, P.addPendingSource(w, 5n, 6n))
      w = B.first(R.World, Bool, P.addPendingSource(w, 5n, 6n))
      w = B.first(R.World, Bool, P.removePendingSource(w, 5n, 6n))
      P.setPendingError(w, 5n, B.choose(~Nat, additional, _ => 4n, _ => 0n), R.Undefined{})

def fixture(+op: U32, status: U32, flags: U32, extra: Bool, +additional: Bool, +block: Bool, config: U32) -> R.World:
  apply(initial(op, status, flags, extra, additional, block, config), op, additional, block)

# A captured Set is a live object, including deletion/reinsertion iteration.
type AliasProbe is Data:
  AliasProbe{oldItems: List<&2, Nat>, current: R.SourceSet, same: Bool, seen: List<&2, Nat>}

def aliasView(+w: R.World, +saved: Nat, seen: List<&2, Nat>) -> AliasProbe:
  AliasProbe{B.pendingItems(w, saved), B.pendingSources(w, 2n), Nat.is_eq(saved, R.NodeExtension.pendingSources(B.extension(w, 2n))), seen}

def aliasIter(fuel: Nat, +w: R.World, +saved: Nat, +index: Nat, +seen: List<&2, Nat>, +mode: U32) -> AliasProbe:
  match fuel:
    case 0n:
      aliasView(R.World.with_fault(w, R.Exhausted{}), saved, seen)
    case 1n+ +p:
      B.choose(~AliasProbe, Nat.is_ge(index, B.length(Nat, B.pendingSlots(w, saved))), _ => aliasView(w, saved, seen),
        _ =>
          +item = B.get(Nat, B.pendingSlots(w, saved), index, 0n)
          B.choose(~AliasProbe, Nat.is_eq(item, 0n), _ => aliasIter(p, w, saved, 1n+index, seen, mode),
            _ =>
              seen = B.append(Nat, seen, [item])
              +w = B.choose(~R.World, U32.is_eq(mode, 6),
                _ => B.choose(~R.World, Nat.is_eq(item, 3n),
                  _ => B.first(R.World, Bool, P.addPendingSource(B.first(R.World, Bool, P.removePendingSource(w, 2n, 3n)), 2n, 5n)),
                  _ => B.choose(~R.World, Nat.is_eq(item, 4n),
                    _ => B.first(R.World, Bool, P.addPendingSource(B.first(R.World, Bool, P.removePendingSource(w, 2n, 5n)), 2n, 6n)), _ => w)),
                _ => B.choose(~R.World, Bool.and(U32.is_eq(mode, 7), Nat.is_eq(item, 3n)),
                  _ => B.first(R.World, Bool, P.addPendingSource(B.first(R.World, Bool, P.removePendingSource(w, 2n, 3n)), 2n, 4n)),
                  _ => B.choose(~R.World, Bool.and(U32.is_eq(mode, 8), Nat.is_eq(item, 3n)),
                    _ => B.first(R.World, Bool, P.addPendingSource(P.clearPendingSources(w, 2n), 2n, 4n)), _ => w)))
              aliasIter(p, w, saved, 1n+index, seen, mode)))

def aliasApply(+w: R.World, mode: U32, +saved: Nat) -> AliasProbe:
  match mode:
    case 0:
      +w = B.first(R.World, Bool, P.addPendingSource(B.first(R.World, Bool, P.addPendingSource(w, 2n, 3n)), 2n, 4n))
      aliasView(w, saved, [])
    case 1:
      aliasView(B.first(R.World, Bool, P.removePendingSource(w, 2n, 3n)), saved, [])
    case 2:
      aliasView(B.first(R.World, Bool, P.addPendingSource(P.clearPendingSources(w, 2n), 2n, 4n)), saved, [])
    case 3:
      aliasView(B.first(R.World, Bool, P.addPendingSource(B.first(R.World, Bool, P.removePendingSource(w, 2n, 3n)), 2n, 4n)), saved, [])
    case 4:
      aliasView(B.first(R.World, Bool, P.removePendingSource(B.first(R.World, Bool, P.addPendingSource(w, 2n, 4n)), 2n, 3n)), saved, [])
    case 5:
      aliasView(B.first(R.World, Bool, P.removePendingSource(w, 2n, 7n)), saved, [])
    case 6:
      aliasIter(32n, B.first(R.World, Bool, P.addPendingSource(w, 2n, 4n)), saved, 0n, [], 6)
    case 7:
      aliasIter(32n, w, saved, 0n, [], 7)
    case _:
      aliasIter(32n, w, saved, 0n, [], 8)

def aliasFixture(+mode: U32) -> AliasProbe:
  +opts = R.NodeOptions.with_lazy(N.defaults(), True{})
  +w = N.createOwner(B.empty(), 0n, False{})
  +w = N.computed(0n, w, R.Literal{R.Number{7n}}, opts, 1n)
  +w = N.computed(0n, w, R.Literal{R.Number{7n}}, opts, 1n)
  +w = N.computed(0n, w, R.Literal{R.Number{7n}}, opts, 1n)
  +w = N.computed(0n, w, R.Literal{R.Number{7n}}, opts, 1n)
  +w = N.computed(0n, w, R.Literal{R.Number{7n}}, opts, 1n)
  +w = B.first(R.World, Bool, P.addPendingSource(w, 2n, 3n))
  aliasApply(w, mode, R.NodeExtension.pendingSources(B.extension(w, 2n)))
