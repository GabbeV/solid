# flatten.ts production helpers. Core tasks retain the actual callback/array
# loop and catch return points; these helpers contain no scheduler decisions.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./arrays.bend as Arrays
import ./callable.bend as Callable

def zeroArgument(+w: R.World, +value: R.Value) -> Bool:
  Bool.and(Callable.isFunction(value), Nat.is_eq(Callable.functionLength(w, value), 0n))

def nonRendered(value: R.Value) -> Bool:
  match value:
    case R.Undefined{}:
      True{}
    case R.Null{}:
      True{}
    case R.Boolean{b}:
      True{}
    case R.StringValue{s}:
      String.is_empty(s)
    case other:
      False{}

def push(+w: R.World, +results: Nat, value: R.Value) -> R.World:
  Arrays.put(w, results, Arrays.length(w, results), value)

# The source closure captures the first traversal's result vector and options.
# Calling it allocates a new output and forces doNotUnwrap=false.
def wrapper(+w: R.World, results: Nat, skip: Bool) -> B.Bundle<R.World, R.Value>:
  +id = B.length(R.CleanupProgram, R.World.cleanupPrograms(w))
  +program = {R.CleanupProgram{[R.FlattenChildren{results, skip}], False{}, 0n} : R.CleanupProgram}
  B.Bundle{R.World.with_cleanupPrograms(w, B.append(R.CleanupProgram, R.World.cleanupPrograms(w), [program])), R.ProgramReference{id}}
