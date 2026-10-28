# Reduced checks for compiler-valid source faults. The quantified operation
# contracts live separately; small projections keep failed verdicts bounded.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/scheduler.bend as S
import ../runtime/transaction.bend as X
import ../runtime/constants.bend as K

def held() -> R.World:
  B.store_node(B.empty(),0n,R.Node.with_config(B.node(B.empty(),0n),K.CONFIG_HELD()))

def existingHeldEntryAllocatesNoExtension() -> {B.length(R.NodeExtension,R.World.extensions(S.parkChanged(held(),0n,1n,False{}))) == B.length(R.NodeExtension,R.World.extensions(held())) : Nat}:
  {==}

def laneRenders(machine: C.Machine) -> List<&2,Nat>:
  match machine:
    case C.Machine{w,todo,stack}:
      match todo:
        case C.LandTransactions{frame,remaining} <> rest:
          match frame:
            case C.SeamFrame{tx,renders,users,laneRenders,laneUsers}: renders
        case _: []

def detachedRendersRemainInTheSeamFrame() -> {laneRenders(C.afterLaneSeams(B.empty(),[],[],1n,[3n],[])) == [3n] : List<&2,Nat>}:
  {==}

def pending() -> R.World:
  R.World.with_pendingNodes(B.first(R.World,Nat,X.newTransaction(held(),False{},0n)),[0n])

def settlementActuallyClearsTheCapturedIntake() -> {B.length(Nat,R.World.pendingNodes(C.world(C.settleApplied(pending(),[],[],1n)))) == 0n : Nat}:
  {==}
