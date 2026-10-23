import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/construct.bend as N
import ../../runtime/owner.bend as O
import ../../runtime/graph.bend as G
import ../../runtime/core.bend as C
import ../../runtime/extension.bend as E
import ../../runtime/constants.bend as K

def emit(code: Nat) -> R.CleanupProgram:
  R.CleanupProgram{[R.CleanupEmit{code}], False{}, 0n}

def callbacks(+mode: U32) -> List<&2, R.CleanupProgram>:
  +tail = B.choose(~List<&2, R.CleanupAction>, Bool.or(U32.is_eq(mode, 3), U32.is_eq(mode, 7)),
    _ => [R.CleanupThrow{R.Number{99n}}],
    _ => B.choose(~List<&2, R.CleanupAction>, U32.is_eq(mode, 4), _ => [R.CleanupDispose{1n}],
      _ => B.choose(~List<&2, R.CleanupAction>, Bool.or(U32.is_eq(mode, 5), U32.is_eq(mode, 6)),
        _ => [R.CleanupRegister{3n, 1n}], _ => [])))
  [R.CleanupProgram{[], False{}, 0n}, emit(101n), emit(102n), emit(103n), emit(104n), B.choose(~R.CleanupProgram, U32.is_eq(mode, 15),
      _ => R.CleanupProgram{[R.CleanupEmit{105n}, R.CleanupDispose{3n}], False{}, 0n}, _ => emit(105n)), emit(106n), emit(107n),
    R.CleanupProgram{R.CleanupEmit{208n} <> tail, False{}, 0n}]

def initial() -> R.World:
  +w = N.createOwner(B.empty(), 0n, False{})
  +w = N.signal(w, R.Number{7n}, N.defaults())
  +opts = R.NodeOptions.with_lazy(N.defaults(), True{})
  +w = N.computed(0n, w, R.Literal{R.Number{11n}}, opts, 1n)
  +w = N.computed(0n, w, R.Literal{R.Number{13n}}, opts, 1n)
  +w = N.createOwner(w, 3n, False{})
  +w = N.computed(0n, w, R.Literal{R.Number{17n}}, opts, 5n)
  +w = B.store_node(w, 3n, R.Node.with_config(B.node(w, 3n), 0))
  +w = G.link(G.link(G.link(w, 2n, 3n), 2n, 4n), 3n, 6n)
  +w = O.cleanup(O.cleanup(w, 1n, 1n), 1n, 2n)
  +w = O.cleanup(O.cleanup(O.cleanup(O.cleanup(w, 3n, 3n), 4n, 5n), 5n, 6n), 6n, 7n)
  +w = B.store_node(w, 1n, R.Node.with_childCount(B.node(w, 1n), 11n))
  +w = B.store_node(w, 5n, R.Node.with_childCount(B.node(w, 5n), 9n))
  B.store_node(w, 3n, R.Node.with_cleanup(R.Node.with_childCount(B.node(w, 3n), 7n), 4n))

def park(+w: R.World) -> R.World:
  +w = E.ext(w, 3n)
  +w = B.store_extension(w, 3n, R.NodeExtension.with_pendingFirstChild(B.extension(w, 3n), 5n))
  +w = B.store_extension(w, 3n, R.NodeExtension.with_pendingDisposal(B.extension(w, 3n), R.Node.disposal(B.node(w, 3n))))
  +w = B.store_node(w, 3n, R.Node.with_disposal(R.Node.with_firstChild(B.node(w, 3n), 0n), R.NoDisposal{}))
  +w = B.store_node(w, 5n, R.Node.with_flags(B.node(w, 5n), B.set(R.Node.flags(B.node(w, 5n)), K.REACTIVE_ZOMBIE())))
  B.store_node(w, 6n, R.Node.with_flags(B.node(w, 6n), B.set(R.Node.flags(B.node(w, 6n)), K.REACTIVE_ZOMBIE())))

def fixture(+mode: U32) -> R.World:
  +w = R.World.with_running(R.World.with_cleanupPrograms(initial(), callbacks(mode)), True{})
  +w = B.choose(~R.World, Bool.and(U32.is_ge(mode, 3), U32.is_le(mode, 6)), _ => O.cleanup(w, 3n, 8n), _ => w)
  +w = B.choose(~R.World, U32.is_eq(mode, 7), _ => B.store_node(w, 3n, R.Node.with_cleanup(B.node(w, 3n), 8n)), _ => w)
  +w = B.choose(~R.World, U32.is_eq(mode, 8), _ => B.store_node(w, 4n, R.Node.with_flags(B.node(w, 4n), K.REACTIVE_DISPOSED())), _ => w)
  +w = B.choose(~R.World, U32.is_eq(mode, 9), _ => C.markRefresh(G.clearDeps(w, 4n), 4n), _ => w)
  +w = B.choose(~R.World, Bool.or(U32.is_eq(mode, 10), U32.is_eq(mode, 11)), _ => park(w), _ => w)
  +w = B.choose(~R.World, U32.is_eq(mode, 12),
    _ =>
      +w = E.ext(w, 3n)
      +w = B.store_extension(w, 3n, R.NodeExtension.with_transaction(R.NodeExtension.with_inFlight(B.extension(w, 3n), R.FlightActive{1n}), 1n))
      B.store_node(w, 3n, R.Node.with_status(B.node(w, 3n), K.STATUS_PENDING())), _ => w)
  +w = B.choose(~R.World, U32.is_eq(mode, 13), _ => B.store_node(w, 3n, R.Node.with_flags(B.node(w, 3n), B.set(R.Node.flags(B.node(w, 3n)), K.REACTIVE_FRAME_READ()))), _ => w)
  +w = B.choose(~R.World, U32.is_eq(mode, 14), _ => B.store_node(w, 3n, R.Node.with_flags(B.node(w, 3n), B.set(R.Node.flags(B.node(w, 3n)), K.REACTIVE_ZOMBIE()))), _ => w)
  +frame = Bool.or(U32.is_eq(mode, 2), Bool.and(U32.is_ge(mode, 4), U32.is_le(mode, 6)))
  +individual = Bool.or(U32.is_eq(mode, 1), Bool.or(U32.is_eq(mode, 12), Bool.or(U32.is_eq(mode, 13), U32.is_eq(mode, 14))))
  +w = B.choose(~R.World, U32.is_eq(mode, 15), _ => O.disposeChildren(w, 1n, False{}, False{}),
    _ => B.choose(~R.World, U32.is_eq(mode, 11), _ => O.disposeChildren(w, 3n, False{}, True{}),
    _ => B.choose(~R.World, frame, _ => O.disposeChildren(w, 3n, False{}, False{}),
      _ => O.dispose(w, B.choose(~Nat, individual, _ => 3n, _ => 1n)))))
  +w = B.choose(~R.World, U32.is_eq(mode, 6), _ => O.dispose(w, 3n), _ => w)
  +w = B.choose(~R.World, U32.is_eq(mode, 0), _ => O.dispose(w, 1n), _ => w)
  B.choose(~R.World, U32.is_eq(mode, 9), _ => C.flush(256n, R.World.with_running(w, False{})), _ => w)
