# Concrete park/land through the SAME flush, graph, queues and text callback.
# The open count is an explicit transaction input here, not an action API proof.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/api.bend as A
import ../runtime/transaction.bend as X
import ../runtime/constants.bend as K

def initial() -> R.World:
  w = A.createSignal(A.createWorld(), R.Number{0n}, True{})
  w = A.attach(w, 1n, 2n)
  +w = A.createEffect(256n, w, R.Read{2n}, False{}, 2n, False{}, False{}, 1n)
  +w = B.first(R.World, Nat, X.newTransaction(w, False{}, 0n))
  B.store_transaction(w, 1n, R.Transaction.with_open(B.transaction(w, 1n), 1n))

def parked() -> R.World:
  A.flush(256n, X.joinFuture(A.setSignal(initial(), 2n, R.Number{6n}), 1n))

def landed() -> R.World:
  +w = parked()
  w = B.store_transaction(w, 1n, R.Transaction.with_open(B.transaction(w, 1n), 0n))
  A.flush(256n, B.schedule(w))

type View is Data:
  View{value: R.Value, staging: R.Slot, held: Bool, stamp: Nat, text: R.Value,
    live: List<&2, Nat>, txNodes: List<&2, Nat>, txRenders: List<&2, Nat>,
    renders: List<&2, Nat>, users: List<&2, Nat>, pending: List<&2, Nat>,
    running: Bool, scheduled: Bool, context: Nat, tracking: Bool, fault: R.Fault}

def view(+w: R.World) -> View:
  View{R.Node.value(B.node(w, 2n)), R.Node.pending(B.node(w, 2n)), B.has(R.Node.config(B.node(w, 2n)), K.CONFIG_HELD()),
    R.NodeExtension.transaction(B.extension(w, 2n)), A.displayed(w, 2n), R.World.transactions(w), R.Transaction.nodes(B.transaction(w, 1n)), R.Transaction.renderQueue(B.transaction(w, 1n)),
    R.World.renderQueue(w), R.World.userQueue(w), R.World.pendingNodes(w), R.World.running(w), R.World.scheduled(w), R.World.context(w), R.World.tracking(w), R.World.fault(w)}

def expectedPark() -> View:
  View{R.Number{0n}, R.Present{R.Number{6n}}, True{}, 1n, R.Number{0n}, [1n], [2n], [3n], [], [], [], False{}, False{}, 0n, False{}, R.Healthy{}}

def expectedLand() -> View:
  View{R.Number{6n}, R.Empty{}, False{}, 0n, R.Number{6n}, [], [2n], [], [], [], [], False{}, False{}, 0n, False{}, R.Healthy{}}
