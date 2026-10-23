# Payload is an arbitrary represented value; the real producer/graph shape is fixed.
# Actual owned memo/from constructor, buffered read, root disposal and flush.
# The subscription programme is user code supplied before construction.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../runtime/construct.bend as N

def input(value: R.Value) -> R.World:
  +w = A.createWorld()
  +w = A.registerProgram(w, R.CleanupProgram{[R.CallbackEvaluate{R.InvokeWith{R.Argument{0n}, R.Literal{value}, False{}}}, R.CallbackReturn{R.Literal{R.ProgramReference{2n}}}], False{}, 3n})
  A.registerProgram(w, R.CleanupProgram{[R.CleanupEmit{99n}], False{}, 0n})

def program() -> R.Expr:
  R.ArrayLiteral{R.CallArgumentsItem{
    R.Invoke{R.RootScope{R.MemoAccessor{R.FromInput{R.Literal{R.ProgramReference{1n}}}, R.NodeOptions.with_equals(N.defaults(), False{})}, False{}}},
    R.CallArgumentsItem{R.Invoke{R.Literal{R.RootDisposerReference{2n}}},
      R.CallArgumentsItem{R.FlushNow{}, R.CallArgumentsEnd{}}}}}

def before(value: R.Value) -> C.Machine:
  C.Machine{input(value), [C.Evaluate{program(), R.Undefined{}}], []}

def step(machine: C.Machine) -> C.Machine:
  C.step(machine)

def run(fuel: Nat, value: R.Value) -> C.Machine:
  C.run(fuel, before(value))
