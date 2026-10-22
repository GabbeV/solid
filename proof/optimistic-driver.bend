# Complete public data optimistic program. Constructor, two setter calls,
# public flush and a final accessor read all enter the actual core machine.
import Base
import ../runtime/core.bend as C
import ../runtime/api.bend as A
import ../runtime/construct.bend as N
import ../representation/records.bend as R

def program(initial: Nat, next: Nat, last: Nat) -> R.Expr:
  R.OptimisticScope{R.Literal{R.Number{initial}}, R.NodeOptions.with_equals(N.defaults(), False{}),
    R.Then{R.LocalWrite{0n, R.Literal{R.Number{next}}, False{}}, R.LocalWrite{0n, R.Literal{R.Number{last}}, False{}}}}

def before(initial: Nat, next: Nat, last: Nat) -> C.Machine:
  C.Machine{A.createWorld(), [C.Evaluate{program(initial, next, last), R.Undefined{}}, C.Discard{}, C.Evaluate{R.FlushNow{}, R.Undefined{}}, C.Discard{}, C.ReadNode{2n}], []}

def step(machine: C.Machine) -> C.Machine:
  C.step(machine)

def run(fuel: Nat, initial: Nat, next: Nat, last: Nat) -> C.Machine:
  C.run(fuel, before(initial, next, last))
