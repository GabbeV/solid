# Small actual-step counterchecks. General entry/heap contracts live separately;
# these projections keep an intentionally bad implementation's diagnostics small.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C

def tasks(m: C.Machine) -> List<&2,C.Task>:
  match m:
    case C.Machine{w,todo,stack}: todo

def emptyBucketAdvances() -> {R.World.minimum(C.world(C.step(C.Machine{B.empty(),[C.HeapLoop{}],[]}))) == 1n : Nat}:
  {==}

def seamKeepsPostSettlementWork() -> {tasks(C.step(C.Machine{B.empty(),[C.Seam{},C.RoundEnd{}],[R.Number{17n}]})) == [C.Settle{},C.AfterSettle{},C.RoundEnd{}] : List<&2,C.Task>}:
  {==}
