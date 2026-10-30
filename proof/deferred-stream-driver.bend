import Base
import ./ordinary-payload.bend as Payload
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../runtime/construct.bend as N
import ../runtime/write.bend as W
import ../runtime/deferred-stream.bend as Stream
import ../runtime/deferred-runtime.bend as Deferred
import ../runtime/flight.bend as Flight
import ../runtime/iterator-state.bend as Iter
# Complete public data-to-buffered-stream refetch. The typed producer is an
# external input, created before the owning root; every reactive operation
# runs through the existing constructor/setter/flush/accessor evaluator.

def inputWorld(next: Payload.Ordinary) -> R.World:
  A.createStream(A.createWorld(), [R.BareNext{False{}, Payload.value(next)}, R.BareNext{True{}, R.Undefined{}}], True{}, False{}, R.Undefined{}, 0n)

def program(initial: Payload.Ordinary) -> R.Expr:
  R.Then{R.RootScope{R.SignalScope{R.Literal{R.Number{0n}}, R.NodeOptions.with_equals(N.defaults(), False{}),
    R.DeferredAccessor{R.Select{R.LocalRead{0n}, R.Literal{R.AsyncValue{1n}}, R.Literal{Payload.value(initial)}}, R.NodeOptions.with_equals(N.defaults(), False{})}}, False{}},
    R.Then{R.InvokeWith{R.Literal{R.SetterReference{3n}}, R.Literal{R.Number{1n}}, False{}},
      R.Then{R.FlushNow{}, R.Invoke{R.Literal{R.AccessorReference{4n}}}}}}

def before(initial: Payload.Ordinary, next: Payload.Ordinary) -> C.Machine:
  C.Machine{inputWorld(next), [C.Evaluate{program(initial), R.Undefined{}}], []}

def step(machine: C.Machine) -> C.Machine:
  C.step(machine)

def run(fuel: Nat, initial: Payload.Ordinary, next: Payload.Ordinary) -> C.Machine:
  C.run(fuel, before(initial, next))

# Source setter-prefix snapshots for the untrusted witness-data builder.
def stageSlot(+w: R.World, -unused: Payload.Ordinary) -> R.World:
  +w = W.queuePendingNode(w, 3n)
  B.store_node(w, 3n, R.Node.with_pending(B.node(w, 3n), R.Present{R.Number{1n}}))

def stageInsert(w: R.World) -> R.World:
  W.insertSubs(w, 3n)

def stageSchedule(w: R.World) -> R.World:
  B.schedule(w)

def stageStamp(+w: R.World) -> R.World:
  B.store_node(w, 3n, R.Node.with_notified(B.node(w, 3n), R.Stamped{R.World.epoch(w)}))

def stageFlags(+w: R.World) -> R.World:
  B.store_node(w, 4n, R.Node.with_flags(B.node(w, 4n), 8))


# Untrusted snapshot generation calls only; independent equations check them.

def streamWrap(w: R.World,cell: Nat,source: Nat) -> B.Bundle<R.World,Nat>: Stream.wrap(w,cell,source)
def streamNode(w: R.World,cell: Nat) -> Nat: R.DeferredCell.node(Deferred.cell(w,cell))
def streamRegistered(+w: R.World,+cell: Nat,+result: Nat) -> R.World:
  +node = R.DeferredCell.node(Deferred.cell(w,cell))
  Flight.startFlight(Deferred.ask(w,cell,Stream.flight(w,result)),node,result)
def streamCreated(w: R.World,node: Nat,+result: Nat) -> B.Bundle<R.World,Nat>: Iter.newStream(w,node,result,result,False{},R.Undefined{})
def streamAttached(w: R.World,rest: List<&2,C.Task>,stack: List<&2,R.Value>,node: Nat,stream: Nat) -> C.Machine: C.attachIterator(w,rest,stack,node,stream,False{})
