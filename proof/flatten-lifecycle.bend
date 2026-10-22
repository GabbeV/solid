# Concrete children resolver program through the actual expression, callback,
# committed read, setter and flush machinery; not a general flatten theorem.
import Base
import ../runtime/api.bend as A
import ../runtime/arrays.bend as Arrays
import ../runtime/callable.bend as Callable
import ../runtime/flatten.bend as Flatten
import ../representation/base.bend as B
import ../representation/records.bend as R

def children() -> R.Expr:
  A.arrayLiteral(R.CallArgumentsItem{R.Literal{R.ProgramReference{1n}}, R.CallArgumentsItem{A.arrayLiteral(R.CallArgumentsItem{R.Literal{R.Number{0n}}, R.CallArgumentsItem{R.Literal{R.Boolean{False{}}}, R.CallArgumentsEnd{}}}), R.CallArgumentsEnd{}}})

def values(+w: R.World, value: R.Value) -> List<&2, R.Slot>:
  match value:
    case R.ArrayReference{id}:
      Arrays.get(w, id)
    case other:
      []

type View is Data:
  View{first: List<&2, R.Slot>, beforeFlush: List<&2, R.Slot>, afterFlush: List<&2, R.Slot>, fresh: Bool, arity: Nat, context: Nat, tracking: Bool, fault: R.Fault}

def program() -> View:
  +w = A.createSignal(A.createWorld(), R.Number{1n}, True{})
  +w = A.registerProgram(w, A.programReturn(R.Read{2n}, A.emptyProgram()))
  +created = A.evaluateExpression(256n, w, A.flatten(children(), True{}, True{}), R.Undefined{})
  +closure = A.resultValue(created)
  +first = A.evaluateExpression(256n, A.resultWorld(created), A.invoke(R.Literal{closure}), R.Undefined{})
  +w = A.setSignal(A.resultWorld(first), 2n, R.Number{3n})
  +before = A.evaluateExpression(256n, w, A.invoke(R.Literal{closure}), R.Undefined{})
  +w = A.flush(256n, A.resultWorld(before))
  +after = A.evaluateExpression(256n, w, A.invoke(R.Literal{closure}), R.Undefined{})
  +w = A.resultWorld(after)
  View{values(w, A.resultValue(first)), values(w, A.resultValue(before)), values(w, A.resultValue(after)), Bool.not(B.equal(A.resultValue(first), A.resultValue(after))), Callable.functionLength(w, closure), R.World.context(w), R.World.tracking(w), R.World.fault(w)}

def expected() -> View:
  View{[R.Present{R.Number{1n}}, R.Present{R.Number{0n}}], [R.Present{R.Number{1n}}, R.Present{R.Number{0n}}], [R.Present{R.Number{3n}}, R.Present{R.Number{0n}}], True{}, 0n, 0n, False{}, R.Healthy{}}

def complete() -> {program() == expected() : View}:
  {==}

# Quantified exact allocation boundary: capture the results/skip options in a
# zero-arity callable, append once, and leave every reactive World field alone.
def wrapper(+w: R.World, +results: Nat, +skip: Bool) ->
  {Flatten.wrapper(w, results, skip) == B.Bundle{R.World.with_cleanupPrograms(w, B.append(R.CleanupProgram, R.World.cleanupPrograms(w), [R.CleanupProgram{[R.FlattenChildren{results, skip}], False{}, 0n}])), R.ProgramReference{B.length(R.CleanupProgram, R.World.cleanupPrograms(w))}} : B.Bundle<R.World, R.Value>}:
  {==}
