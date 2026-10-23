# Actual owned memo/from constructor, buffered read, root disposal and flush.
# The subscription programme is user code supplied before construction.
import Base
import ./ordinary-payload.bend as Payload
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../runtime/construct.bend as N

def input(value: Payload.Ordinary) -> R.World:
  +w = A.createWorld()
  +w = A.registerProgram(w, R.CleanupProgram{[R.CallbackEvaluate{R.InvokeWith{R.Argument{0n}, R.Literal{Payload.value(value)}, False{}}}, R.CallbackReturn{R.Literal{R.ProgramReference{2n}}}], False{}, 3n})
  A.registerProgram(w, R.CleanupProgram{[R.CleanupEmit{99n}], False{}, 0n})

def program() -> R.Expr:
  R.ArrayLiteral{R.CallArgumentsItem{
    R.Invoke{R.RootScope{R.MemoAccessor{R.FromInput{R.Literal{R.ProgramReference{1n}}}, R.NodeOptions.with_equals(N.defaults(), False{})}, False{}}},
    R.CallArgumentsItem{R.Invoke{R.Literal{R.RootDisposerReference{2n}}},
      R.CallArgumentsItem{R.FlushNow{}, R.CallArgumentsEnd{}}}}}

def before(value: Payload.Ordinary) -> C.Machine:
  C.Machine{input(value), [C.Evaluate{program(), R.Undefined{}}], []}

def step(machine: C.Machine) -> C.Machine:
  C.step(machine)

def run(fuel: Nat, value: Payload.Ordinary) -> C.Machine:
  C.run(fuel, before(value))
