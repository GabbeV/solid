# Complete public data-signal program with an unflushed latest read, flush,
# and nested latest/isPending read windows. Every transition is core.step.
import Base
import ../runtime/core.bend as C
import ../runtime/api.bend as A
import ../runtime/construct.bend as N
import ../representation/records.bend as R

def program(initial: Nat, next: Nat) -> R.Expr:
  R.SignalScope{R.Literal{R.Number{initial}}, R.NodeOptions.with_equals(N.defaults(), False{}),
    R.Then{R.LocalWrite{0n, R.Literal{R.Number{next}}, False{}},
      R.Then{R.Latest{R.LocalRead{0n}},
        R.Then{R.FlushNow{}, R.Latest{R.Then{R.IsPending{R.LocalRead{0n}}, R.LocalRead{0n}}}}}}}

def before(initial: Nat, next: Nat) -> C.Machine:
  C.Machine{A.createWorld(), [C.Evaluate{program(initial, next), R.Undefined{}}], []}

def step(machine: C.Machine) -> C.Machine:
  C.step(machine)

def run(fuel: Nat, initial: Nat, next: Nat) -> C.Machine:
  C.run(fuel, before(initial, next))
