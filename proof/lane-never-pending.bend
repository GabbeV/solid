# #4275: the actual tracked-render laneRead branch exits a verdict lane before
# continuing the pending read from the cleared frame seat. The new source
# returns the pending token only for a shown lane; initial facts are explicit.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/constants.bend as K
import ../runtime/lanes-state.bend as L


def verdict(+w: R.World) -> Bool:
  +pass = R.World.passLane(w)
  Bool.and(Nat.is_ne(pass,0n),Nat.is_eq(R.Transaction.verdict(B.transaction(w,R.Transaction.parent(B.transaction(w,pass)))),pass))

def after(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+reader: Nat,+id: Nat,+lane: Nat,+never: Bool,+escape: Bool) -> C.Machine:
  +next = B.choose(~R.World,Bool.and(Bool.or(never,Nat.is_ne(R.World.passLane(w),lane)),escape),_=>R.World.with_passLane(w,0n),_=>w)
  B.choose(~C.Machine,Bool.or(Nat.is_eq(R.World.passLane(next),0n),Bool.not(L.sameLane(next,R.World.passLane(next),lane))),_=>C.laneReadOutside(next,rest,stack,reader,id,lane,False{},K.STATUS_PENDING(),never),_=>C.laneReadEnter(next,rest,stack,reader,id,lane,False{},K.STATUS_PENDING()))

def source(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+reader: Nat,+id: Nat,+lane: Nat) -> {C.laneReadRender(w,rest,stack,reader,id,lane,False{},K.STATUS_PENDING()) == after(w,rest,stack,reader,id,lane,Bool.not(B.present(R.NodeExtension.lane(B.extension(w,id)))),verdict(w)) : C.Machine}:
  {==}

def passUpdated(+w: R.World,+pass: Nat) -> {R.World.passLane(R.World.with_passLane(w,pass)) == pass : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def resetSelected(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+reader: Nat,+id: Nat,+lane: Nat) -> {after(w,rest,stack,reader,id,lane,True{},True{}) == C.laneReadOutside(R.World.with_passLane(w,0n),rest,stack,reader,id,lane,False{},K.STATUS_PENDING(),True{}) : C.Machine}:
  +next = R.World.with_passLane(w,0n)
  Equal.cong(Nat,C.Machine,pass=>B.choose(~C.Machine,Bool.or(Nat.is_eq(pass,0n),Bool.not(L.sameLane(next,pass,lane))),_=>C.laneReadOutside(next,rest,stack,reader,id,lane,False{},K.STATUS_PENDING(),True{}),_=>C.laneReadEnter(next,rest,stack,reader,id,lane,False{},K.STATUS_PENDING())),R.World.passLane(next),0n,passUpdated(w,0n))

def verdictKnown(+w: R.World,+present: {Nat.is_ne(R.World.passLane(w),0n) == True{} : Bool},same: {Nat.is_eq(R.Transaction.verdict(B.transaction(w,R.Transaction.parent(B.transaction(w,R.World.passLane(w))))),R.World.passLane(w)) == True{} : Bool}) -> {verdict(w) == True{} : Bool}:
  Equal.trans(Bool,verdict(w),Nat.is_eq(R.Transaction.verdict(B.transaction(w,R.Transaction.parent(B.transaction(w,R.World.passLane(w))))),R.World.passLane(w)),True{},Equal.cong(Bool,Bool,nonzero=>Bool.and(nonzero,Nat.is_eq(R.Transaction.verdict(B.transaction(w,R.Transaction.parent(B.transaction(w,R.World.passLane(w))))),R.World.passLane(w))),Nat.is_ne(R.World.passLane(w),0n),True{},present),same)

def exits(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+reader: Nat,+id: Nat,+lane: Nat,empty: {B.present(R.NodeExtension.lane(B.extension(w,id))) == False{} : Bool},present: {Nat.is_ne(R.World.passLane(w),0n) == True{} : Bool},same: {Nat.is_eq(R.Transaction.verdict(B.transaction(w,R.Transaction.parent(B.transaction(w,R.World.passLane(w))))),R.World.passLane(w)) == True{} : Bool}) -> {C.laneReadRender(w,rest,stack,reader,id,lane,False{},K.STATUS_PENDING()) == C.laneReadOutside(R.World.with_passLane(w,0n),rest,stack,reader,id,lane,False{},K.STATUS_PENDING(),True{}) : C.Machine}:
  +never = Bool.not(B.present(R.NodeExtension.lane(B.extension(w,id))))
  Equal.trans(C.Machine,C.laneReadRender(w,rest,stack,reader,id,lane,False{},K.STATUS_PENDING()),after(w,rest,stack,reader,id,lane,never,verdict(w)),C.laneReadOutside(R.World.with_passLane(w,0n),rest,stack,reader,id,lane,False{},K.STATUS_PENDING(),True{}),source(w,rest,stack,reader,id,lane),Equal.trans(C.Machine,after(w,rest,stack,reader,id,lane,never,verdict(w)),after(w,rest,stack,reader,id,lane,True{},verdict(w)),C.laneReadOutside(R.World.with_passLane(w,0n),rest,stack,reader,id,lane,False{},K.STATUS_PENDING(),True{}),Equal.cong(Bool,C.Machine,n=>after(w,rest,stack,reader,id,lane,n,verdict(w)),never,True{},Equal.cong(Bool,Bool,b=>Bool.not(b),B.present(R.NodeExtension.lane(B.extension(w,id))),False{},empty)),Equal.trans(C.Machine,after(w,rest,stack,reader,id,lane,True{},verdict(w)),after(w,rest,stack,reader,id,lane,True{},True{}),C.laneReadOutside(R.World.with_passLane(w,0n),rest,stack,reader,id,lane,False{},K.STATUS_PENDING(),True{}),Equal.cong(Bool,C.Machine,v=>after(w,rest,stack,reader,id,lane,True{},v),verdict(w),True{},verdictKnown(w,present,same)),resetSelected(w,rest,stack,reader,id,lane))))
