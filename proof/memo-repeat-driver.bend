# Actual repeated public scalar-memo updates, arbitrary initial value.
import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../representation/records.bend as R
import ./memo-general-driver.bend as Initial
import ./memo-initial-driver.bend as Constructor

def base(initial: Nat, first: Nat) -> R.World:
  A.flush(256n, A.setSignal(Initial.base(initial), 2n, R.Number{first}))

def before(initial: Nat, first: Nat, input: Nat) -> C.Machine:
  C.Machine{A.setSignal(base(initial, first), 2n, R.Number{input}), [C.Round{}], []}

def step(machine: C.Machine) -> C.Machine:
  C.step(machine)

def program(initial: Nat, first: Nat, second: Nat, constructorExtra: Nat, firstExtra: Nat, secondExtra: Nat) -> R.World:
  A.flush(Nat.add(40n, secondExtra), A.setSignal(A.flush(Nat.add(40n, firstExtra), A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), Constructor.expr(), False{}, False{}, 1n), 2n, R.Number{first})), 2n, R.Number{second}))
