import Base
import ../runtime/heap.bend as H
import ../proof/chain.bend as Chain
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/scheduler.bend as S

def base() -> R.World:
  Chain.initial()

def before(input: Nat) -> C.Machine:
  C.Machine{A.setSignal(base(), 2n, R.Number{input}), [C.Round{}], []}

def step(machine: C.Machine) -> C.Machine:
  C.step(machine)


def slot(+w: R.World, +id: Nat, value: R.Value) -> R.World:
  B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Present{value}))

def notify(w: R.World, id: Nat) -> R.World:
  S.insertSubs(w, id)

def modified(+w: R.World, +id: Nat) -> R.World:
  B.store_node(w, id, R.Node.with_modified(B.node(w, id), True{}))

def enqueue(w: R.World, id: Nat) -> R.World:
  S.enqueue(w, id)

def value(+w: R.World, +id: Nat, value: R.Value) -> R.World:
  B.store_node(w, id, R.Node.with_value(B.node(w, id), value))

def queued(w: R.World) -> R.World:
  S.queuePendingNode(w, 2n)

def scheduled(w: R.World) -> R.World:
  B.schedule(w)

def stamp(+w: R.World, +id: Nat) -> R.World:
  B.store_node(w, id, R.Node.with_notified(B.node(w, id), R.Stamped{R.World.epoch(w)}))

def heap(w: R.World, id: Nat) -> R.World:
  H.enqueueSub(w, id)

# Public drain, for finite native/canonical boundary controls.
def flush(fuel: Nat, world: R.World) -> R.World:
  A.flush(fuel, world)
