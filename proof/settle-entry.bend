# Source empty lane/guess entry. Clearing the ambient capture and recording
# judged lanes remain actual runtime stores, not an assumed no-op World.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C

def cleared(w: R.World) -> R.World:
  R.World.with_flushTransaction(w,0n)

def entered(+w: R.World) -> R.World:
  +w = cleared(w)
  R.World.with_laneState(w,R.LaneState.with_judged(R.World.laneState(w),B.length(Nat,R.LaneState.live(R.World.laneState(w)))))

def apply(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+parent: Nat,empty: {List.is_empty(&2,R.Guess,R.LaneState.pendingGuesses(R.World.laneState(w))) == True{} : Bool}) -> {C.applyGuessesAt(w,rest,stack,parent) == C.Machine{R.World.with_laneState(w,R.LaneState.with_judged(R.World.laneState(w),B.length(Nat,R.LaneState.live(R.World.laneState(w))))),rest,stack} : C.Machine}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match laneState:
        case R.LaneState{+live,+groups,+stagedReaders,+pendingGuesses,+judged,+root,+enteredReaders,+guessing,+guessed,+kept,+reverted,+reverting}:
          Equal.cong(Bool,C.Machine,quiet=>B.choose(~C.Machine,quiet,_=>C.Machine{R.World.with_laneState(w,R.LaneState.with_judged(R.World.laneState(w),B.length(Nat,live))),rest,stack},_=>C.Machine{R.World.with_laneState(w,R.LaneState.with_judged(R.World.laneState(w),B.length(Nat,live))),C.ApplyGuesses{parent,0n,0n} <> rest,stack}),List.is_empty(&2,R.Guess,pendingGuesses),True{},empty)

def joined(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+empty: {List.is_empty(&2,R.Guess,R.LaneState.pendingGuesses(R.World.laneState(w))) == True{} : Bool}) -> {C.settleJoined(w,rest,stack) == C.settleApplied(entered(w),rest,stack,R.World.flushTransaction(w)) : C.Machine}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match laneState:
        case R.LaneState{+live,+groups,+stagedReaders,+pendingGuesses,+judged,+root,+enteredReaders,+guessing,+guessed,+kept,+reverted,+reverting}:
          +next = cleared(w)
          +selected = Equal.cong(Bool,C.Machine,quiet=>B.choose(~C.Machine,quiet,_=>C.settleApplied(C.world(C.applyGuessesAt(next,[],[],flushTransaction)),rest,stack,flushTransaction),_=>C.applyGuessesAt(next,C.SettleApplied{flushTransaction} <> rest,stack,flushTransaction)),List.is_empty(&2,R.Guess,pendingGuesses),True{},empty)
          Equal.trans(C.Machine,C.settleJoined(w,rest,stack),C.settleApplied(C.world(C.applyGuessesAt(next,[],[],flushTransaction)),rest,stack,flushTransaction),C.settleApplied(entered(w),rest,stack,flushTransaction),selected,Equal.cong(C.Machine,C.Machine,m=>C.settleApplied(C.world(m),rest,stack,flushTransaction),C.applyGuessesAt(next,[],[],flushTransaction),C.Machine{entered(w),[],[]},apply(next,[],[],flushTransaction,empty)))

def begin(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,live: {List.is_empty(&2,Nat,R.LaneState.live(R.World.laneState(w))) == True{} : Bool},empty: {List.is_empty(&2,R.Guess,R.LaneState.pendingGuesses(R.World.laneState(w))) == True{} : Bool}) -> {C.beginSettle(w,rest,stack) == C.settleApplied(entered(w),rest,stack,R.World.flushTransaction(w)) : C.Machine}:
  Equal.trans(C.Machine,C.beginSettle(w,rest,stack),C.settleJoined(w,rest,stack),C.settleApplied(entered(w),rest,stack,R.World.flushTransaction(w)),Equal.cong(Bool,C.Machine,quiet=>B.choose(~C.Machine,quiet,_=>C.settleJoined(w,rest,stack),_=>C.laneCorrections(w,C.SettleCorrectionsDone{} <> rest,stack)),List.is_empty(&2,Nat,R.LaneState.live(R.World.laneState(w))),True{},live),joined(w,rest,stack,empty))
