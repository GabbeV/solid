# Executable Bend consumer of the production non-store pending APIs.
# Expected values: false, true, 41, false, 41; fault: Healthy.
import Base
import ../runtime/api.bend as A
import ../runtime/construct.bend as N
import ../runtime/arrays.bend as Arrays
import ../representation/records.bend as R

type PendingResult is Data:
  PendingResult{values: List<&2, R.Slot>, fault: R.Fault}

def program() -> R.Expr:
  A.signalScope(A.literal(R.Number{41n}), N.defaults(),
    A.arrayLiteral(R.CallArgumentsItem{A.isPending(A.localRead(0n)),
      R.CallArgumentsItem{A.then(A.affects(A.localAccessor(0n), A.literal(R.Undefined{})), A.isPending(A.localRead(0n))),
        R.CallArgumentsItem{A.latest(A.localRead(0n)),
          R.CallArgumentsItem{A.then(A.flushNow(), A.isPending(A.localRead(0n))),
            R.CallArgumentsItem{A.localRead(0n), R.CallArgumentsEnd{}}}}}}))

def result(+w: R.World, value: R.Value) -> PendingResult:
  match value:
    case R.ArrayReference{id}:
      PendingResult{Arrays.get(w, id), R.World.fault(w)}
    case other:
      PendingResult{[], R.World.fault(w)}

def main() -> PendingResult:
  +run = A.evaluateExpression(512n, A.createWorld(), program(), R.Undefined{})
  result(A.resultWorld(run), A.resultValue(run))
