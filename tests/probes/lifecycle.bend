import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/construct.bend as N
import ../../runtime/core.bend as C
import ../../runtime/owner.bend as O
import ../../runtime/scheduler.bend as S
import ../../runtime/extension.bend as E
import ../../runtime/constants.bend as K

def cb(code: Nat, actions: List<&2, R.CleanupAction>) -> R.CleanupProgram:
  R.CleanupProgram{R.CleanupEmit{code} <> actions, False{}, 0n}

def programs(+mode: U32) -> List<&2, R.CleanupProgram>:
  +throw = Bool.or(U32.is_eq(mode, 4), Bool.or(U32.is_eq(mode, 5), U32.is_eq(mode, 9)))
  [R.CleanupProgram{[], False{}, 0n}, cb(101n, []), cb(102n, []),
    cb(103n, B.choose(~List<&2, R.CleanupAction>, throw, _ => [R.CleanupThrow{R.Number{99n}}],
      _ => B.choose(~List<&2, R.CleanupAction>, U32.is_eq(mode, 11), _ => [R.CleanupWrite{2n, R.Number{7n}}], _ => []))), cb(104n, []),
    cb(105n, B.choose(~List<&2, R.CleanupAction>, U32.is_eq(mode, 6), _ => [R.CleanupThrow{R.Number{99n}}], _ => []))]

def initial(+mode: U32) -> R.World:
  +w = N.createOwner(B.empty(), 0n, False{})
  +w = N.signal(w, R.Number{1n}, N.defaults())
  expr = B.choose(~R.Expr, U32.is_eq(mode, 2), _ => R.Same{R.Read{2n}, R.Literal{R.Number{0n}}}, _ => R.Read{2n})
  +w = N.computed(256n, R.World.with_context(w, 1n), expr, N.defaults(), 1n)
  +w = N.createOwner(R.World.with_context(w, 3n), 3n, False{})
  +w = N.computed(0n, w, R.Literal{R.Number{17n}}, R.NodeOptions.with_lazy(N.defaults(), True{}), 3n)
  +w = R.World.with_context(w, 0n)
  +w = R.World.with_cleanupPrograms(w, programs(mode))
  +w = O.cleanup(O.cleanup(O.cleanup(w, 4n, 1n), 5n, 2n), 3n, 3n)
  +w = B.store_node(w, 5n, R.Node.with_cleanup(B.node(w, 5n), 4n))
  R.World.with_events(w, [])

def fixture(+mode: U32) -> R.World:
  +w = initial(mode)
  +w = B.choose(~R.World, Bool.or(U32.is_eq(mode, 3), U32.is_eq(mode, 4)),
    _ => B.store_node(w, 3n, R.Node.with_config(B.node(w, 3n), K.CONFIG_STAGED())), _ => w)
  +w = B.choose(~R.World, Bool.or(U32.is_eq(mode, 6), U32.is_eq(mode, 7)),
    _ =>
      +w = E.ext(w, 3n)
      B.store_extension(w, 3n, R.NodeExtension.with_flightTeardown(R.NodeExtension.with_inFlight(B.extension(w, 3n), R.FlightActive{1n}), 5n)), _ => w)
  B.choose(~R.World, Bool.and(U32.is_ge(mode, 8), U32.is_le(mode, 10)),
    _ =>
      +w = O.parkChildren(w, 3n)
      +w = B.store_node(w, 3n, R.Node.with_config(B.node(w, 3n), K.CONFIG_STAGED()))
      +w = B.store_node(w, 3n, R.Node.with_pending(B.node(w, 3n), B.choose(~R.Slot, U32.is_eq(mode, 10), _ => R.Empty{}, _ => R.Present{R.Number{23n}})))
      +w = B.choose(~R.World, U32.is_eq(mode, 10), _ => B.store_node(w, 3n, R.Node.with_status(B.node(w, 3n), K.STATUS_PENDING())), _ => w)
      S.commitPendingNode(S.queuePendingNode(w, 3n), 3n),
    _ =>
      +w = S.setSignal(w, 2n, R.Number{2n})
      B.choose(~R.World, U32.is_eq(mode, 1),
        _ => S.commitPendingNode(C.world(C.run(512n, C.Machine{w, [C.Recompute{3n, False{}}], []})), 3n),
        _ => C.flush(2048n, w)))
