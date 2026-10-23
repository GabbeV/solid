# Nonempty graph blockage reaches the real scheduler scan. Complete flush and
# callback/application observation remain outside this boundary contract.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/transaction.bend as X
import ../runtime/constants.bend as K
import ./transaction-positive.bend as Positive
import ./transaction-rendered.bend as Graph
import ./action-landing-scan.bend as Scan

def retained(+w: R.World, +predecessor: Nat, +prefix: Graph.Skips<Positive.enter(w, 1n+predecessor), 1n+predecessor>, +id: Nat, +tail: List<&2, Nat>,
  +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +frame: C.SeamFrame, +index: Nat,
  lookup: {B.get(Nat, R.World.transactions(w), index, 0n) == 1n+predecessor : Nat},
  healthy: {B.ok(w) == True{} : Bool},
  zero: {R.Transaction.open(B.transaction(w, 1n+predecessor)) == 0n : Nat},
  nodes: {R.Transaction.nodes(B.transaction(Positive.enter(w, 1n+predecessor), 1n+predecessor)) == B.append(Nat, Graph.ids(Positive.enter(w, 1n+predecessor), 1n+predecessor, prefix), id <> tail) : List<&2, Nat>},
  active: {Graph.guard(Positive.enter(w, 1n+predecessor), id) == False{} : Bool},
  capture: {R.NodeExtension.transaction(B.extension(Positive.enter(w, 1n+predecessor), id)) == 1n+predecessor : Nat},
  stopped: {R.Transaction.into(B.transaction(Positive.enter(w, 1n+predecessor), 1n+predecessor)) == 0n : Nat},
  rendered: {X.isRender(R.Node.kind(B.node(Positive.enter(w, 1n+predecessor), id))) == True{} : Bool},
  live: {B.has(R.Node.flags(B.node(Positive.enter(w, 1n+predecessor), id)), K.REACTIVE_ZOMBIE()) == False{} : Bool}) ->
  {C.landTransactions(w, rest, stack, frame, 1n+index) == C.Machine{w, C.LandTransactions{frame, index} <> rest, stack} : C.Machine}:
  Scan.scan(w, rest, stack, frame, index, 1n+predecessor, lookup,
    Graph.renderGroup(w, predecessor, prefix, id, tail, healthy, zero, nodes, active, capture, stopped, rendered, live))
