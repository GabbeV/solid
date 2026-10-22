# Complete mark/window/flush program, with observable pending-before/after data.
import Base
import ../runtime/core.bend as C
import ../runtime/api.bend as A
import ../runtime/construct.bend as N
import ../representation/records.bend as R

def program(initial: Nat) -> R.Expr:
  R.SignalScope{R.Literal{R.Number{initial}}, N.defaults(),
    R.Then{R.Affects{R.LocalAccessor{0n}, R.Literal{R.Undefined{}}},
      R.ArrayLiteral{R.CallArgumentsItem{R.IsPending{R.LocalRead{0n}},
        R.CallArgumentsItem{R.Then{R.FlushNow{}, R.IsPending{R.LocalRead{0n}}},
          R.CallArgumentsItem{R.LocalRead{0n}, R.CallArgumentsEnd{}}}}}}}

def before(initial: Nat) -> C.Machine:
  C.Machine{A.createWorld(), [C.Evaluate{program(initial), R.Undefined{}}], []}

def step(machine: C.Machine) -> C.Machine:
  C.step(machine)

def run(fuel: Nat, initial: Nat) -> C.Machine:
  C.run(fuel, before(initial))
