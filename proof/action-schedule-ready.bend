# Scheduling an unhalted World sets readiness. Actual retirement supplies
# that final schedule; the body/queue flags are transported independently.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ./action-body-retirement.bend as Exit
import ./action-control-flags.bend as Flags

def identity(+w: R.World) -> {R.World.with_halted(w,R.World.halted(w)) == w : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def unhalted(+w: R.World,known: {R.World.halted(w) == False{} : Bool}) -> {R.World.with_halted(w,False{}) == w : R.World}:
  Equal.trans(R.World,R.World.with_halted(w,False{}),R.World.with_halted(w,R.World.halted(w)),w,Equal.cong(Bool,R.World,b=>R.World.with_halted(w,b),False{},R.World.halted(w),Equal.sym(Bool,R.World.halted(w),False{},known)),identity(w))

def forced(+w: R.World) -> {R.World.scheduled(B.schedule(R.World.with_halted(w,False{}))) == True{} : Bool}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match running scheduled syncDepth:
        case _ True{} _: {==}
        case True{} False{} 0n: {==}
        case True{} False{} 1n+p: {==}
        case False{} False{} 0n: {==}
        case False{} False{} 1n+p: {==}

def scheduled(+w: R.World,known: {R.World.halted(w) == False{} : Bool}) -> {R.World.scheduled(B.schedule(w)) == True{} : Bool}:
  Equal.trans(Bool,R.World.scheduled(B.schedule(w)),R.World.scheduled(B.schedule(R.World.with_halted(w,False{}))),True{},Equal.cong(R.World,Bool,state=>R.World.scheduled(B.schedule(state)),w,R.World.with_halted(w,False{}),Equal.sym(R.World,R.World.with_halted(w,False{}),w,unhalted(w,known))),forced(w))

def target(+w: R.World,+root: Nat,+remaining: Nat,known: {R.World.halted(w) == False{} : Bool}) -> {R.World.scheduled(Exit.target(w,root,remaining)) == True{} : Bool}:
  +next = A.exit(w)
  +record = R.Transaction.with_open(B.transaction(next,root),remaining)
  +stored = B.store_transaction(next,root,record)
  +same = Equal.trans(Flags.View,Flags.observe(stored),Flags.observe(next),Flags.exit(Flags.observe(w)),Flags.transaction(next,root,record),Flags.exited(w))
  +halted = Equal.trans(Bool,R.World.halted(stored),R.World.halted(w),False{},Equal.cong(Flags.View,Bool,view=>Flags.halted(view),Flags.observe(stored),Flags.exit(Flags.observe(w)),same),known)
  scheduled(stored,halted)
