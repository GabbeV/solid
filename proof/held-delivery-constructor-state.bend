# Actual raw constructor/controller entry, separate from source/profile proofs.
import Base
import ../representation/records.bend as R
import ./held-opened-state.bend as Input
import ../representation/base.bend as B
import ../runtime/flight.bend as F
import ./action-wait-history.bend as History
import ./action-wait-allocation.bend as Allocation

def initial(+value: R.Value,methods: R.Expr) -> R.World:
  B.first(R.World,Nat,F.newThenable(Input.opened(value,methods),False{},R.Unresolved{}))

def result(value: R.Value,methods: R.Expr) -> Nat:
  B.second(R.World,Nat,F.newThenable(Input.opened(value,methods),False{},R.Unresolved{}))

def before(value: R.Value,methods: R.Expr,prefix: List<&2,History.WaitEvent>) -> R.World:
  History.run(prefix,initial(value,methods))

def registered(+value: R.Value,+methods: R.Expr,+prefix: List<&2,History.WaitEvent>) -> R.World:
  Allocation.after(before(value,methods,prefix),0n,result(value,methods),0)

def observer(value: R.Value,methods: R.Expr,prefix: List<&2,History.WaitEvent>) -> Nat:
  Allocation.index(before(value,methods,prefix))
