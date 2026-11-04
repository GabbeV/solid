# Closed runtime-only oracles keep failing diagnostics bounded. They import
# no generic setup proof and cannot assume the setup operation is correct.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ./recomputed-read-data.bend as Data
import ./pending-stack-history.bend as Steps

def returned() -> C.Machine:
  Steps.iterate(4n,Data.start())

def linked() -> {R.Node.deps(B.node(C.world(returned()),2n)) == 1n : Nat}:
  {==}

def context() -> {R.World.context(C.world(returned())) == 2n : Nat}:
  {==}

def tracking() -> {R.World.tracking(C.world(returned())) == True{} : Bool}:
  {==}

def valueAndCallerStack() -> {C.values(returned()) == [R.Number{8n},R.Number{91n}] : List<&2,R.Value>}:
  {==}

def frameCaller(frame: C.PassFrame) -> Bool:
  match frame:
    case C.PassFrame{id,create,context,tracking,height,reask,previous,uninitialized,outgoing,sources,pendingSource,flight,saved,released,stale,lanePass}:
      Bool.and(Nat.is_eq(context,0n),Bool.not(tracking))

def tasks(machine: C.Machine) -> List<&2,C.Task>:
  match machine:
    case C.Machine{world,tasks,values}: tasks

def retained(tasks: List<&2,C.Task>) -> Bool:
  match tasks:
    case C.Finish{frame} <> C.Seam{} <> Nil{}:
      frameCaller(frame)
    case _: False{}

def caller() -> {retained(tasks(returned())) == True{} : Bool}:
  {==}
