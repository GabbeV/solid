# Entry points for witness generation. All transitions remain core.step.
import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../representation/records.bend as R

def source(initial: Nat) -> R.World:
  A.createSignal(A.createWorld(), R.Number{initial}, False{})

def staged(initial: Nat, next: Nat) -> R.World:
  A.setSignal(source(initial), 2n, R.Number{next})

def before(initial: Nat, next: Nat) -> C.Machine:
  C.Machine{staged(initial, next), [C.Round{}], []}

def step(machine: C.Machine) -> C.Machine:
  C.step(machine)

def read(world: R.World) -> R.Value:
  A.resultValue(A.read(64n, world, 2n))
