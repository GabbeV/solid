import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R

def base(initial: Nat) -> R.World:
  A.createMemo(256n, A.createSignal(A.createWorld(), R.Number{initial}, False{}), R.Add{R.Read{2n}, R.Literal{R.Number{1n}}}, False{}, False{}, 1n)

def before(initial: Nat, input: Nat) -> C.Machine:
  C.Machine{A.setSignal(base(initial), 2n, R.Number{input}), [C.Round{}], []}

def step(machine: C.Machine) -> C.Machine:
  C.step(machine)

# IO-free entry used only by the finite constructor/setter boundary controls.
def flush(fuel: Nat, world: R.World) -> R.World:
  A.flush(fuel, world)

# Actual public constructor/setter used by finite before/after controls.
def constructSet(+initial: Nat, input: Nat, fuel: Nat) -> R.World:
  A.setSignal(A.createMemo(fuel, A.createSignal(A.createWorld(), R.Number{initial}, False{}), R.Add{R.Read{2n}, R.Literal{R.Number{1n}}}, False{}, False{}, 1n), 2n, R.Number{input})
