# Preserved held facts supply actual updater-machine obligations, including the
# same nonmemo/default-comparator gates as the existing real expression proof.
import Base
import ../representation/records.bend as R
import ../runtime/core.bend as C
import ./held-write-profile.bend as P
import ./ordinary-updater-evaluation.bend as Eval
import ./ordinary-updater-health.bend as Health
import ./pending-stack-history.bend as Steps

def healthy(-w: R.World,-id: Nat,-offset: Nat,profile: P.Profile<w,id,offset>) -> {R.World.fault(w) == R.Healthy{} : R.Fault}:
  P.healthy(w,id,offset,profile)

def exact(+w: R.World,+id: Nat,+value: R.Value,+previous: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,profile: P.Profile<w,id,offset>) -> {Steps.iterate(3n,Eval.start(w,rest,stack,id,value,previous)) == Eval.updated(w,rest,stack,id,value) : C.Machine}:
  match profile:
    case P.HeldAt{path,extra,health,unmarked,valid,head,room,context,signal,held,override,custom,existing,extensionRoom,canonical,future,terminal,groupRoom}:
      Eval.complete(w,rest,stack,id,value,previous,health,Health.nonmemo(w,id,signal),override,custom)
