import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R

def base() -> R.World:
  A.createMemo(256n, A.createSignal(A.createWorld(), R.Number{0n}, False{}), R.Add{R.Read{2n}, R.Literal{R.Number{1n}}}, False{}, False{}, 1n)

def before(input: Nat) -> C.Machine:
  C.Machine{A.setSignal(base(), 2n, R.Number{input}), [C.Round{}], []}

def step(machine: C.Machine) -> C.Machine:
  C.step(machine)

type View is Data:
  View{source: R.Value, memo: R.Value, pending: List<&2, Nat>, context: Nat, tracking: Bool, running: Bool, scheduled: Bool, fault: R.Fault}

def view(+w: R.World) -> View:
  View{R.Node.value(B.node(w, 2n)), R.Node.value(B.node(w, 3n)), R.World.pendingNodes(w), R.World.context(w), R.World.tracking(w), R.World.running(w), R.World.scheduled(w), R.World.fault(w)}

def expected(+input: Nat) -> View:
  View{R.Number{input}, R.Number{Nat.add(input, 1n)}, [], 0n, False{}, False{}, False{}, R.Healthy{}}

# IO-free entry used only by the finite constructor/setter boundary controls.
def flush(fuel: Nat, world: R.World) -> R.World:
  A.flush(fuel, world)
