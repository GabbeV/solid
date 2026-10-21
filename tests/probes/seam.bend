import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/construct.bend as N
import ../../runtime/transaction.bend as X
import ../../runtime/extension.bend as E
import ../../runtime/owner.bend as O
import ../../runtime/graph.bend as G
import ../../runtime/core.bend as C
import ../../runtime/scheduler.bend as S
import ../../runtime/constants.bend as K

def slot(stage: U32) -> R.Slot:
  match stage:
    case 0:
      R.Empty{}
    case 1:
      R.Present{R.Number{33n}}
    case _:
      R.Present{R.Undefined{}}

def initial(+joined: Bool, +waiting: Bool, +zombie: Bool, +write: Bool, +throw: Bool, +status: U32, stage: U32, +revert: Bool, +open: Bool, +held: Bool) -> R.World:
  +w = N.createOwner(B.empty(), 0n, False{})
  +w = N.signal(w, R.Number{11n}, N.defaults())
  +w = N.computed(0n, w, R.Read{2n}, R.NodeOptions.with_lazy(N.defaults(), True{}), 1n)
  +w = N.createEffectNode(w, R.Read{3n}, R.Render{}, 2n, N.defaults(), 3n, 0n, 0n)
  +w = N.createEffectNode(w, R.Read{2n}, R.User{}, 3n, N.defaults(), 1n, 0n, 0n)
  +w = B.store_node(w, 3n, R.Node.with_value(R.Node.with_status(R.Node.with_flags(R.Node.with_config(B.node(w, 3n), K.CONFIG_STAGED()), 0), status), R.Number{11n}))
  +w = B.store_node(w, 3n, R.Node.with_pending(B.node(w, 3n), slot(stage)))
  +w = B.store_node(w, 2n, R.Node.with_pending(B.node(w, 2n), R.Present{B.choose(~R.Value, revert, _ => R.Number{11n}, _ => R.Number{23n})}))
  +w = B.store_node(w, 4n, R.Node.with_flags(R.Node.with_status(R.Node.with_modified(R.Node.with_value(B.node(w, 4n), R.Number{11n}), True{}), B.choose(~U32, waiting, _ => K.STATUS_PENDING(), _ => 0)), 0))
  +w = B.store_node(w, 5n, R.Node.with_flags(R.Node.with_status(R.Node.with_modified(R.Node.with_value(B.node(w, 5n), R.Number{11n}), True{}), 0), 0))
  +w = G.link(G.link(w, 2n, 3n), 3n, 4n)
  +w = E.ext(E.ext(w, 3n), 4n)
  +w = B.choose(~R.World, B.has(status, K.STATUS_PENDING()),
    _ => B.store_extension(w, 3n, R.NodeExtension.with_error(B.extension(w, 3n), R.NotReadyFailure{1n, 3n})), _ => w)
  +w = B.choose(~R.World, waiting,
    _ => B.store_extension(w, 4n, R.NodeExtension.with_error(B.extension(w, 4n), R.NotReadyFailure{1n, 3n})), _ => w)
  +w = O.cleanup(w, 3n, 1n)
  +w = B.choose(~R.World, zombie, _ => O.parkChildren(w, 3n), _ => w)
  +w = R.World.with_cleanupPrograms(w, [R.CleanupProgram{[], False{}, 0n}, R.CleanupProgram{R.CleanupEmit{101n} <>
    B.append(R.CleanupAction, B.choose(~List<&2, R.CleanupAction>, write, _ => [R.CleanupWrite{2n, R.Number{77n}}], _ => []),
      B.choose(~List<&2, R.CleanupAction>, throw, _ => [R.CleanupThrow{R.Number{42n}}], _ => [])), False{}, 0n}])
  +w = B.first(R.World, Nat, X.newTransaction(w, False{}, 0n))
  +w = B.choose(~R.World, held, _ => X.holdNode(X.holdNode(w, 3n, 1n), 2n, 1n), _ => w)
  +w = B.store_transaction(w, 1n, R.Transaction.with_open(R.Transaction.with_userQueue(R.Transaction.with_renderQueue(B.transaction(w, 1n), [4n]), [R.NodeRun{5n}]), B.choose(~Nat, open, _ => 1n, _ => 0n)))
  +w = R.World.with_flushTransaction(w, B.choose(~Nat, joined, _ => 1n, _ => 0n))
  +w = R.World.with_renderQueue(R.World.with_userQueue(w, [R.NodeRun{4n}]), [5n])
  +w = R.World.with_running(w, True{})
  +w = R.World.with_pendingNodes(w, [2n, 3n, 4n])
  R.World.with_trims(w, [3n])

def fixture(joined: Bool, waiting: Bool, zombie: Bool, write: Bool, throw: Bool, status: U32, stage: U32, revert: Bool, open: Bool, held: Bool) -> R.World:
  C.settleWorld(4096n, initial(joined, waiting, zombie, write, throw, status, stage, revert, open, held))

def fixtureDeferred(joined: Bool, waiting: Bool, status: U32, open: Bool, held: Bool) -> R.World:
  +w = initial(joined, waiting, True{}, False{}, False{}, status, 1, False{}, open, held)
  C.settleWorld(8192n, R.World.with_deferredZombies(w, [4n]))
