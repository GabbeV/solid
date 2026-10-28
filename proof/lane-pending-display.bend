# ac28157a/#4284: a never-valued pending source takes the token fast path
# only if its lane has shown. Otherwise the real outside-display branch runs.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/constants.bend as K
import ./lane-never-pending.bend as Seat

def selected(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+reader: Nat,+id: Nat,+lane: Nat,shown: Bool) -> C.Machine:
  B.choose(~C.Machine,shown,_=>C.Machine{w,rest,R.NotPendingToken{} <> stack},_=>C.laneReadOutside(w,rest,stack,reader,id,lane,False{},K.STATUS_PENDING(),False{}))

def outside(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+reader: Nat,+id: Nat,+lane: Nat) -> {C.laneReadOutside(w,rest,stack,reader,id,lane,False{},K.STATUS_PENDING(),True{}) == selected(w,rest,stack,reader,id,lane,R.Transaction.shown(B.transaction(w,lane))) : C.Machine}:
  {==}

def shown(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+reader: Nat,+id: Nat,+lane: Nat,known: {R.Transaction.shown(B.transaction(w,lane)) == True{} : Bool}) -> {C.laneReadOutside(w,rest,stack,reader,id,lane,False{},K.STATUS_PENDING(),True{}) == C.Machine{w,rest,R.NotPendingToken{} <> stack} : C.Machine}:
  Equal.trans(C.Machine,C.laneReadOutside(w,rest,stack,reader,id,lane,False{},K.STATUS_PENDING(),True{}),selected(w,rest,stack,reader,id,lane,R.Transaction.shown(B.transaction(w,lane))),C.Machine{w,rest,R.NotPendingToken{} <> stack},outside(w,rest,stack,reader,id,lane),Equal.cong(Bool,C.Machine,flag=>selected(w,rest,stack,reader,id,lane,flag),R.Transaction.shown(B.transaction(w,lane)),True{},known))

def unshown(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+reader: Nat,+id: Nat,+lane: Nat,known: {R.Transaction.shown(B.transaction(w,lane)) == False{} : Bool}) -> {C.laneReadOutside(w,rest,stack,reader,id,lane,False{},K.STATUS_PENDING(),True{}) == C.laneReadOutside(w,rest,stack,reader,id,lane,False{},K.STATUS_PENDING(),False{}) : C.Machine}:
  Equal.trans(C.Machine,C.laneReadOutside(w,rest,stack,reader,id,lane,False{},K.STATUS_PENDING(),True{}),selected(w,rest,stack,reader,id,lane,R.Transaction.shown(B.transaction(w,lane))),C.laneReadOutside(w,rest,stack,reader,id,lane,False{},K.STATUS_PENDING(),False{}),outside(w,rest,stack,reader,id,lane),Equal.cong(Bool,C.Machine,flag=>selected(w,rest,stack,reader,id,lane,flag),R.Transaction.shown(B.transaction(w,lane)),False{},known))
