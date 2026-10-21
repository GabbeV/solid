# Actual second update of the public fixed scalar-memo program.
import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../representation/records.bend as R
import ./memo-driver.bend as First

def base(first: Nat) -> R.World:
  A.flush(256n, A.setSignal(First.base(), 2n, R.Number{first}))

def before(first: Nat, input: Nat) -> C.Machine:
  C.Machine{A.setSignal(base(first), 2n, R.Number{input}), [C.Round{}], []}

def step(machine: C.Machine) -> C.Machine:
  C.step(machine)

def update(first: Nat, input: Nat, fuel: Nat) -> R.World:
  A.flush(fuel, A.setSignal(base(first), 2n, R.Number{input}))

# Two public setters and flushes, independently variable sufficient budgets.
def program(+first: Nat, second: Nat, firstExtra: Nat, secondExtra: Nat) -> R.World:
  A.flush(Nat.add(40n, secondExtra), A.setSignal(A.flush(Nat.add(40n, firstExtra), A.setSignal(First.base(), 2n, R.Number{first})), 2n, R.Number{second}))
