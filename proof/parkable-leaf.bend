# Two source parking branches with initial certificates. Allocated memos may
# have a pending value; a render can be fresh with an empty pending slot.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/scheduler.bend as S
import ../runtime/transaction.bend as X
import ../proof/held-park-leaf.bend as Existing
import ./fresh-render-parking.bend as Fresh

type Ready<-w: R.World,-id: Nat,-offset: Nat> is Data:
  Allocated{ready: Existing.Ready<w,id,offset>}
  UnreadyRender{ready: Fresh.Ready<w,id>}

def actual(+w: R.World,+id: Nat,+offset: Nat,ready: Ready<w,id,offset>) -> {S.parkPendingNode(w,id,1n+offset) == X.holdNode(w,id,1n+offset) : R.World}:
  match ready:
    case Allocated{before}: Existing.actual(w,id,offset,before)
    case UnreadyRender{before}: Fresh.actual(w,id,offset,before)

def health(+w: R.World,+id: Nat,+offset: Nat,ready: Ready<w,id,offset>) -> {B.ok(S.parkPendingNode(w,id,1n+offset)) == B.ok(w) : Bool}:
  match ready:
    case Allocated{before}: Existing.health(w,id,offset,before)
    case UnreadyRender{before}: Fresh.health(w,id,offset,before)
