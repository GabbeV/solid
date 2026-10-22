# Complete owned data createDeferred constructor/write/flush/accessor program.
# The public getter's stable node identity is the user's ABI binding, not a
# substitute evaluator. Construction is owned; the later event-style write
# runs outside that owner, as a normal event handler does. Equality is false.
import Base
import ../representation/base.bend as B
import ../runtime/write.bend as W
import ../runtime/heap.bend as H
import ../runtime/core.bend as C
import ../runtime/api.bend as A
import ../runtime/construct.bend as N
import ../representation/records.bend as R

def program(initial: Nat, next: Nat) -> R.Expr:
  R.Then{R.RootScope{R.SignalScope{R.Literal{R.Number{initial}}, R.NodeOptions.with_equals(N.defaults(), False{}),
    R.DeferredAccessor{R.LocalRead{0n}, R.NodeOptions.with_equals(N.defaults(), False{})}}, False{}},
    R.Then{R.InvokeWith{R.Literal{R.SetterReference{3n}}, R.Literal{R.Number{next}}, False{}},
      R.Then{R.FlushNow{}, R.Invoke{R.Literal{R.AccessorReference{4n}}}}}}

def before(initial: Nat, next: Nat) -> C.Machine:
  C.Machine{A.createWorld(), [C.Evaluate{program(initial, next), R.Undefined{}}], []}

def step(machine: C.Machine) -> C.Machine:
  C.step(machine)

def run(fuel: Nat, initial: Nat, next: Nat) -> C.Machine:
  C.run(fuel, before(initial, next))

# Source helper prefix snapshots used only by the untrusted proof-data builder.
def stageSlot(+w: R.World, next: Nat) -> R.World:
  +w = W.queuePendingNode(w, 3n)
  B.store_node(w, 3n, R.Node.with_pending(B.node(w, 3n), R.Present{R.Number{next}}))

def stageInsert(w: R.World) -> R.World:
  W.insertSubs(w, 3n)

def stageSchedule(w: R.World) -> R.World:
  B.schedule(w)

def stageStamp(+w: R.World) -> R.World:
  B.store_node(w, 3n, R.Node.with_notified(B.node(w, 3n), R.Stamped{R.World.epoch(w)}))

def stageFlags(+w: R.World) -> R.World:
  B.store_node(w, 4n, R.Node.with_flags(B.node(w, 4n), 8))
