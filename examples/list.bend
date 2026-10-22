# Executable Bend consumer: preserve row owners across reorder/growth, then
# resolve the mapped children. Expected values: 20, 10, 30; fault: Healthy.
import Base
import ../runtime/api.bend as A
import ../runtime/arrays.bend as Arrays
import ../representation/base.bend as B
import ../representation/records.bend as R

type ListResult is Data:
  ListResult{values: List<&2, R.Slot>, fault: R.Fault}

def slots(+w: R.World, value: R.Value) -> List<&2, R.Slot>:
  match value:
    case R.ArrayReference{id}:
      Arrays.get(w, id)
    case other:
      []

def main() -> ListResult:
  +input = Arrays.allocate(A.createWorld(), Arrays.slots([R.Number{1n}, R.Number{2n}]))
  +w = A.createSignal(B.first(R.World, Nat, input), R.ArrayReference{B.second(R.World, Nat, input)}, True{})
  # A row returns one child. Formal arity one keeps the source no-index path.
  +row = A.arrayLiteral(R.CallArgumentsItem{A.multiply(A.argument(0n), A.literal(R.Number{10n})), R.CallArgumentsEnd{}})
  +w = A.registerProgram(w, A.programArity(A.programReturn(row, A.emptyProgram()), 1n))
  +created = A.evaluateExpression(1024n, w, A.withOwner(A.literal(R.OwnerReference{1n}), A.mapArrayCreate(A.source(2n), A.literal(R.ProgramReference{1n}), A.noRepeatBody(), False{})), R.Undefined{})
  +get = A.resultValue(created)
  +input = Arrays.allocate(A.resultWorld(created), Arrays.slots([R.Number{2n}, R.Number{1n}, R.Number{3n}]))
  +w = A.setSignal(B.first(R.World, Nat, input), 2n, R.ArrayReference{B.second(R.World, Nat, input)})
  +w = A.flush(2048n, w)
  +output = A.evaluateExpression(1024n, w, A.flatten(A.invoke(A.literal(get)), True{}, False{}), R.Undefined{})
  +values = slots(A.resultWorld(output), A.resultValue(output))
  +finished = A.evaluateExpression(2048n, A.resultWorld(output), A.disposeRoot(A.literal(R.OwnerReference{1n})), R.Undefined{})
  ListResult{values, R.World.fault(A.resultWorld(finished))}
