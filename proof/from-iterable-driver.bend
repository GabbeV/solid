# Actual owned memo/from(AsyncIterable), bare read, pending pull, root disposal
# and flush. The inner Promise is an unresolved external input, not settled by
# the theorem; disposal must still settle the wrapper's pending output as DONE.
import Base
import ./ordinary-payload.bend as Payload
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../runtime/construct.bend as N
import ../runtime/iterator-state.bend as I

def input(value: Payload.Ordinary) -> R.World:
  +w = A.createThenable(A.createWorld(), False{})
  I.newIterable(w, [R.BareNext{False{}, Payload.value(value)}, R.PromiseNext{1n}], True{}, R.Empty{}, 0n)

def program() -> R.Expr:
  R.ArrayLiteral{R.CallArgumentsItem{
    R.Invoke{R.RootScope{R.MemoAccessor{R.FromInput{R.Literal{R.AsyncValue{2n}}}, R.NodeOptions.with_equals(N.defaults(), False{})}, False{}}},
    R.CallArgumentsItem{R.Invoke{R.Literal{R.RootDisposerReference{2n}}},
      R.CallArgumentsItem{R.FlushNow{}, R.CallArgumentsEnd{}}}}}

def before(value: Payload.Ordinary) -> C.Machine:
  C.Machine{input(value), [C.Evaluate{program(), R.Undefined{}}], []}

def step(machine: C.Machine) -> C.Machine:
  C.step(machine)

def run(fuel: Nat, value: Payload.Ordinary) -> C.Machine:
  C.run(fuel, before(value))
