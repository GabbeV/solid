# Payload-independent synchronous result classification. In the admitted ABI
# AsyncValue is the thenable/async-iterable carrier. Other values stay data.
import Base
import ../representation/records.bend as R
import ../runtime/core.bend as C
import ../proof/list-update-lookup.bend as Logic

def plain(value: R.Value) -> Bool:
  match value:
    case R.AsyncValue{identity}: False{}
    case _: True{}

def finish(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+frame: C.PassFrame,+id: Nat,+value: R.Value,known: {plain(value) == True{} : Bool}) -> {C.finishShape(w,rest,value <> stack,frame,id) == C.finishReady(w,rest,value <> stack,frame,False{}) : C.Machine}:
  match value:
    case R.AsyncValue{identity}:
      Empty.absurd({C.finishShape(w,rest,R.AsyncValue{identity} <> stack,frame,id) == C.finishReady(w,rest,R.AsyncValue{identity} <> stack,frame,False{}) : C.Machine},Logic.impossible(Equal.sym(Bool,False{},True{},known)))
    case R.Undefined{}:
      {==}
    case R.Null{}:
      {==}
    case R.Boolean{b}:
      {==}
    case R.Number{n}:
      {==}
    case R.NegativeZero{}:
      {==}
    case R.Reference{id}:
      {==}
    case R.ArrayReference{id}:
      {==}
    case R.OwnerReference{id}:
      {==}
    case R.RootDisposerReference{owner}:
      {==}
    case R.AccessorReference{signal}:
      {==}
    case R.SetterReference{signal}:
      {==}
    case R.ProgramReference{callback}:
      {==}
    case R.ContextFailure{identity, kind}:
      {==}
    case R.NotANumber{}:
      {==}
    case R.StringValue{s}:
      {==}
    case R.StatusFailure{identity, source, cause, message}:
      {==}
    case R.NotReadyFailure{identity, source}:
      {==}
    case R.NotPendingToken{}:
      {==}
    case R.IteratorReference{iterator}:
      {==}
    case R.StepResult{done, value}:
      {==}
    case R.StreamVerdict{stream, landed, value}:
      {==}
    case R.TimeoutFailure{identity}:
      {==}
    case R.ExternalError{id, explicit, kind, name, message, native, code}:
      {==}
