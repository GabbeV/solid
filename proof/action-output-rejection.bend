# Rejection reasons remain data, including a thenable reference; no adoption.
import Base
import ../representation/records.bend as R
import ../runtime/core.bend as C

def raw(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+action: Nat,+result: Nat,+value: R.Value) -> {C.actionOutputValue(w,rest,stack,action,result,True{},value) == C.actionSettled(w,rest,stack,result,True{},value) : C.Machine}:
  match value:
    case R.Undefined{}: {==}
    case R.Null{}: {==}
    case R.Boolean{b}: {==}
    case R.Number{n}: {==}
    case R.NegativeZero{}: {==}
    case R.Reference{id}: {==}
    case R.ArrayReference{id}: {==}
    case R.OwnerReference{id}: {==}
    case R.RootDisposerReference{owner}: {==}
    case R.AccessorReference{signal}: {==}
    case R.SetterReference{signal}: {==}
    case R.ProgramReference{callback}: {==}
    case R.ContextFailure{identity,kind}: {==}
    case R.NotANumber{}: {==}
    case R.StringValue{s}: {==}
    case R.StatusFailure{identity,source,cause,message}: {==}
    case R.NotReadyFailure{identity,source}: {==}
    case R.NotPendingToken{}: {==}
    case R.AsyncValue{identity}: {==}
    case R.IteratorReference{iterator}: {==}
    case R.StepResult{done,value}: {==}
    case R.StreamVerdict{stream,landed,value}: {==}
    case R.TimeoutFailure{identity}: {==}
    case R.ExternalError{id,explicit,kind,name,message,native,code}: {==}
