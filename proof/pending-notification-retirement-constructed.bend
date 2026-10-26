# Constructed corollary, separated from unrelated content proof dependencies.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending.bend as Q
import ../runtime/constants.bend as K
import ./pending-notification-fixture.bend as Fixture
import ./pending-notification-retirement.bend as Generic
import ./pending-tail-status.bend as Tail
import ./memo-render-fixture.bend as Values

def constructed(+values: List<&2,R.Value>,+value: R.Value,+extensions: List<&2,R.NodeExtension>,+sets: List<&2,List<&2,Nat>>,+incoming: Fixture.Incoming,+serial: Nat,tasks: List<&2,Q.Task>,visited: List<&2,Nat>,released: List<&2,Nat>,scheduled: Bool) -> Q.Machine:
  Generic.after(Fixture.initial(values,value,extensions,sets,incoming),Fixture.leaf(values,value,extensions,sets),B.length(R.Node,Values.nodes(values)),serial,tasks,visited,released,scheduled,Fixture.root(values))

def constructedCleared(+values: List<&2,R.Value>,+value: R.Value,+extensions: List<&2,R.NodeExtension>,+sets: List<&2,List<&2,Nat>>,+incoming: Fixture.Incoming,+serial: Nat,+tasks: List<&2,Q.Task>,+visited: List<&2,Nat>,+released: List<&2,Nat>,+scheduled: Bool) -> {B.has(R.Node.status(B.node(Tail.world(constructed(values,value,extensions,sets,incoming,serial,tasks,visited,released,scheduled)),Fixture.leaf(values,value,extensions,sets))),K.STATUS_PENDING()) == False{} : Bool}:
  Generic.cleared(Fixture.initial(values,value,extensions,sets,incoming),Fixture.leaf(values,value,extensions,sets),B.length(R.Node,Values.nodes(values)),serial,tasks,visited,released,scheduled,Fixture.root(values),Fixture.seed(values,value,extensions,sets,incoming),Fixture.noError(values,value,extensions,sets,incoming),Fixture.valid(values,value,extensions,sets,incoming))
