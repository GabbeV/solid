# The preserved profile supplies actual updater machine-entry obligations.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ./ordinary-write-profile.bend as P
import ./ordinary-updater-evaluation.bend as Eval
import ./ordinary-updater-health.bend as Health
import ./pending-stack-history.bend as Steps

def healthy(-w: R.World,-id: Nat,profile: P.Profile<w,id>) -> {R.World.fault(w) == R.Healthy{} : R.Fault}:
  match profile:
    case P.ProfileAt{path,extra,health,unmarked,valid,head,room,context,signal,ordinary,override,custom}: health

def exact(+w: R.World,+id: Nat,+value: R.Value,+previous: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,profile: P.Profile<w,id>) -> {Steps.iterate(3n,Eval.start(w,rest,stack,id,value,previous)) == Eval.updated(w,rest,stack,id,value) : C.Machine}:
  match profile:
    case P.ProfileAt{path,extra,health,unmarked,valid,head,room,context,signal,ordinary,override,custom}:
      Eval.complete(w,rest,stack,id,value,previous,health,Health.nonmemo(w,id,signal),override,custom)
