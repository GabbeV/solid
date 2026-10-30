# Actual finishSettleIntake and its fused empty lane hook. No scanner task is
# supplied: these operations construct it with the source's detached queues.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/scheduler.bend as S
import ./natural-logic.bend as Logic
import ../runtime/lanes-state.bend as Lanes

def quiet(+w: R.World) -> Bool:
  Bool.and(List.is_empty(&2,Nat,R.LaneState.live(R.World.laneState(w))),Bool.and(List.is_empty(&2,Nat,R.LaneState.stagedReaders(R.World.laneState(w))),List.is_empty(&2,Nat,R.LaneState.entered(R.World.laneState(w)))))

def staged(+w: R.World) -> Bool:
  List.is_empty(&2,Nat,R.LaneState.stagedReaders(R.World.laneState(w)))

def queues(w: R.World) -> R.World:
  R.World.with_renderQueue(R.World.with_userQueue(w,[]),[])

def target(+w: R.World,rest: List<&2,C.Task>,stack: List<&2,R.Value>,tx: Nat) -> C.Machine:
  +next = Lanes.clearRevealing(S.clearTrims(w))
  C.Machine{queues(next),C.LandTransactions{C.SeamFrame{tx,R.World.renderQueue(next),R.World.userQueue(next),[],[]},B.length(Nat,R.World.transactions(next))} <> rest,stack}

def noStaged(+w: R.World,known: {quiet(w) == True{} : Bool}) -> {staged(w) == True{} : Bool}:
  +live = List.is_empty(&2,Nat,R.LaneState.live(R.World.laneState(w)))
  +entered = List.is_empty(&2,Nat,R.LaneState.entered(R.World.laneState(w)))
  Logic.andLeft(staged(w),entered,Logic.andRight(live,Bool.and(staged(w),entered),known))

def afterLane(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+tx: Nat,+renders: List<&2,Nat>,+users: List<&2,R.QueueEntry>,empty: {staged(w) == True{} : Bool}) -> {C.afterLaneSeams(w,rest,stack,tx,renders,users) == C.Machine{queues(w),C.LandTransactions{C.SeamFrame{tx,renders,users,R.World.renderQueue(w),R.World.userQueue(w)},B.length(Nat,R.World.transactions(queues(w)))} <> rest,stack} : C.Machine}:
  Equal.cong(Bool,C.Machine,flag=>
    +next = B.choose(~R.World,flag,_=>w,_=>R.World.with_laneState(w,R.LaneState.with_stagedReaders(R.World.laneState(w),[])))
    C.Machine{queues(next),C.LandTransactions{C.SeamFrame{tx,renders,users,R.World.renderQueue(next),R.World.userQueue(next)},B.length(Nat,R.World.transactions(queues(next)))} <> rest,stack},staged(w),True{},empty)

def clearedQuiet(+w: R.World) -> {quiet(Lanes.clearRevealing(S.clearTrims(w))) == quiet(w) : Bool}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match trims:
        case Nil{}:
          match laneState:
            case R.LaneState{+live,+groups,+stagedReaders,+pendingGuesses,+judged,+root,+enteredReaders,+guessing,+guessed,+kept,+reverted,+reverting,+revealing}:
              {==}
        case first <> tail:
          match laneState:
            case R.LaneState{+live,+groups,+stagedReaders,+pendingGuesses,+judged,+root,+enteredReaders,+guessing,+guessed,+kept,+reverted,+reverting,+revealing}:
              {==}

def queuesQuiet(+w: R.World) -> {quiet(queues(w)) == quiet(w) : Bool}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def finishShape(+w: R.World,rest: List<&2,C.Task>,stack: List<&2,R.Value>,tx: Nat) -> {C.Machine{queues(queues(Lanes.clearRevealing(S.clearTrims(w)))),C.LandTransactions{C.SeamFrame{tx,R.World.renderQueue(S.clearTrims(w)),R.World.userQueue(S.clearTrims(w)),R.World.renderQueue(queues(S.clearTrims(w))),R.World.userQueue(queues(S.clearTrims(w)))},B.length(Nat,R.World.transactions(queues(queues(Lanes.clearRevealing(S.clearTrims(w))))))} <> rest,stack} == target(w,rest,stack,tx) : C.Machine}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match trims:
        case Nil{}:
          match laneState:
            case R.LaneState{+live,+groups,+stagedReaders,+pendingGuesses,+judged,+root,+enteredReaders,+guessing,+guessed,+kept,+reverted,+reverting,+revealing}:
              {==}
        case first <> tail:
          match laneState:
            case R.LaneState{+live,+groups,+stagedReaders,+pendingGuesses,+judged,+root,+enteredReaders,+guessing,+guessed,+kept,+reverted,+reverting,+revealing}:
              {==}

def finish(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+tx: Nat,known: {quiet(w) == True{} : Bool}) -> {C.finishSettleIntake(w,rest,stack,tx) == target(w,rest,stack,tx) : C.Machine}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match trims:
        case Nil{}:
          match laneState:
            case R.LaneState{+live,+groups,+stagedReaders,+pendingGuesses,+judged,+root,+enteredReaders,+guessing,+guessed,+kept,+reverted,+reverting,+revealing}:
              +cleared = Lanes.clearRevealing(S.clearTrims(w))
              +ready = Equal.trans(Bool,quiet(cleared),quiet(w),True{},clearedQuiet(w),known)
              +next = queues(cleared)
              +nextReady = Equal.trans(Bool,quiet(next),quiet(cleared),True{},queuesQuiet(cleared),ready)
              +selected = Equal.cong(Bool,C.Machine,flag=>B.choose(~C.Machine,flag,_=>C.afterLaneSeams(Lanes.clearRevealing(next),rest,stack,tx,R.World.renderQueue(cleared),R.World.userQueue(cleared)),_=>C.laneSeams(next,C.AfterLaneSeams{tx,R.World.renderQueue(cleared),R.World.userQueue(cleared)} <> rest,stack,tx)),quiet(next),True{},nextReady)
              +after = afterLane(next,rest,stack,tx,R.World.renderQueue(cleared),R.World.userQueue(cleared),noStaged(next,nextReady))
              Equal.trans(C.Machine,C.finishSettleIntake(w,rest,stack,tx),C.afterLaneSeams(Lanes.clearRevealing(next),rest,stack,tx,R.World.renderQueue(cleared),R.World.userQueue(cleared)),target(w,rest,stack,tx),selected,Equal.trans(C.Machine,C.afterLaneSeams(Lanes.clearRevealing(next),rest,stack,tx,R.World.renderQueue(cleared),R.World.userQueue(cleared)),C.Machine{queues(next),C.LandTransactions{C.SeamFrame{tx,R.World.renderQueue(cleared),R.World.userQueue(cleared),R.World.renderQueue(next),R.World.userQueue(next)},B.length(Nat,R.World.transactions(queues(next)))} <> rest,stack},target(w,rest,stack,tx),after,finishShape(w,rest,stack,tx)))
        case first <> tail:
          match laneState:
            case R.LaneState{+live,+groups,+stagedReaders,+pendingGuesses,+judged,+root,+enteredReaders,+guessing,+guessed,+kept,+reverted,+reverting,+revealing}:
              +cleared = Lanes.clearRevealing(S.clearTrims(w))
              +ready = Equal.trans(Bool,quiet(cleared),quiet(w),True{},clearedQuiet(w),known)
              +next = queues(cleared)
              +nextReady = Equal.trans(Bool,quiet(next),quiet(cleared),True{},queuesQuiet(cleared),ready)
              +selected = Equal.cong(Bool,C.Machine,flag=>B.choose(~C.Machine,flag,_=>C.afterLaneSeams(Lanes.clearRevealing(next),rest,stack,tx,R.World.renderQueue(cleared),R.World.userQueue(cleared)),_=>C.laneSeams(next,C.AfterLaneSeams{tx,R.World.renderQueue(cleared),R.World.userQueue(cleared)} <> rest,stack,tx)),quiet(next),True{},nextReady)
              +after = afterLane(next,rest,stack,tx,R.World.renderQueue(cleared),R.World.userQueue(cleared),noStaged(next,nextReady))
              Equal.trans(C.Machine,C.finishSettleIntake(w,rest,stack,tx),C.afterLaneSeams(Lanes.clearRevealing(next),rest,stack,tx,R.World.renderQueue(cleared),R.World.userQueue(cleared)),target(w,rest,stack,tx),selected,Equal.trans(C.Machine,C.afterLaneSeams(Lanes.clearRevealing(next),rest,stack,tx,R.World.renderQueue(cleared),R.World.userQueue(cleared)),C.Machine{queues(next),C.LandTransactions{C.SeamFrame{tx,R.World.renderQueue(cleared),R.World.userQueue(cleared),R.World.renderQueue(next),R.World.userQueue(next)},B.length(Nat,R.World.transactions(queues(next)))} <> rest,stack},target(w,rest,stack,tx),after,finishShape(w,rest,stack,tx)))
