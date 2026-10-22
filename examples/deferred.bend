# Deferred public data/thenable consumer. The typed external thenable in this
# example invokes settlement callbacks synchronously; native Promise queue IO
# belongs to the host adapter. Expected pairs: [10,false], [10,true], [21,false].
import Base
import ../runtime/api.bend as A
import ../runtime/construct.bend as N
import ../runtime/arrays.bend as Arrays
import ../representation/base.bend as B
import ../representation/records.bend as R

type DeferredResult is Data:
  DeferredResult{before: List<&2, R.Slot>, refreshing: List<&2, R.Slot>, landed: List<&2, R.Slot>, fault: R.Fault}

def observation() -> R.Expr:
  A.arrayLiteral(R.CallArgumentsItem{A.source(3n), R.CallArgumentsItem{A.isPending(A.source(3n)), R.CallArgumentsEnd{}}})

def observed(+w: R.World, value: R.Value) -> B.Bundle<R.World, List<&2, R.Slot>>:
  match value:
    case R.ArrayReference{id}:
      B.Bundle{w, Arrays.get(w, id)}
    case _:
      B.Bundle{w, []}

def observe(w: R.World) -> B.Bundle<R.World, List<&2, R.Slot>>:
  +run = A.evaluateExpression(4096n, w, observation(), R.Undefined{})
  observed(A.resultWorld(run), A.resultValue(run))

def main() -> DeferredResult:
  +w = A.createSignal(A.createWorld(), R.Number{0n}, True{})
  +w = A.createThenable(w, True{})
  +w = A.createDeferred(4096n, w, R.Select{A.source(2n), A.literal(R.AsyncValue{1n}), A.literal(R.Number{10n})}, N.defaults(), 1n)
  +before = observe(w)
  +w = A.flush(4096n, A.setSignal(B.first(R.World, List<&2, R.Slot>, before), 2n, R.Number{1n}))
  +refreshing = observe(w)
  +w = A.resolveThenable(4096n, B.first(R.World, List<&2, R.Slot>, refreshing), 1n, False{}, R.Number{21n})
  +landed = observe(A.flush(4096n, w))
  DeferredResult{B.second(R.World, List<&2, R.Slot>, before), B.second(R.World, List<&2, R.Slot>, refreshing), B.second(R.World, List<&2, R.Slot>, landed), R.World.fault(B.first(R.World, List<&2, R.Slot>, landed))}
