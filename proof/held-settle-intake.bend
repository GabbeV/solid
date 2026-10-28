# Non-lane settlement with a quiet held intake. Its initial resolver, node
# flags and empty hooks are certified; its actual scanner task is a result.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/scheduler.bend as S
import ../runtime/transaction.bend as X
import ./transaction-resolution.bend as Route
import ./held-park-intake.bend as I
import ./held-park-loop.bend as Park
import ./settle-lane-empty.bend as Lane

def selected(+pair: B.Bundle<R.World,Nat>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>) -> C.Machine:
  +w = B.first(R.World,Nat,pair)
  +tx = B.second(R.World,Nat,pair)
  B.choose(~C.Machine,Nat.is_ne(tx,0n),_=>B.choose(~C.Machine,List.is_empty(&2,R.ComparatorBinding,R.World.comparators(w)),_=>
    +next = S.parkPendingNodes(w,tx)
    B.choose(~C.Machine,B.ok(next),_=>C.afterParkIntake(next,rest,stack,tx),_=>C.Machine{next,rest,stack}),_=>C.Machine{w,C.ParkIntake{tx,0n,B.length(Nat,R.World.pendingNodes(w))} <> C.AfterPark{tx} <> rest,stack}),_=>C.Machine{w,C.CommitIntake{0n} <> C.TrimIntake{0n} <> C.FinishSettleIntake{tx} <> rest,stack})

def resolved(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,lane: {R.Transaction.lane(B.transaction(w,1n+offset)) == False{} : Bool},terminal: {R.Transaction.into(B.transaction(w,1n+offset)) == 0n : Nat}) -> {C.settleApplied(w,rest,stack,1n+offset) == selected(B.Bundle{w,1n+offset},rest,stack) : C.Machine}:
  +chosen = Equal.cong(Bool,C.Machine,flag=>selected(B.choose(~B.Bundle<R.World,Nat>,Bool.and(Nat.is_ne(1n+offset,0n),Bool.not(flag)),_=>X.resolveTx(w,1n+offset),_=>B.Bundle{w,0n}),rest,stack),R.Transaction.lane(B.transaction(w,1n+offset)),False{},lane)
  Equal.trans(C.Machine,C.settleApplied(w,rest,stack,1n+offset),selected(X.resolveTx(w,1n+offset),rest,stack),selected(B.Bundle{w,1n+offset},rest,stack),chosen,Equal.cong(B.Bundle<R.World,Nat>,C.Machine,pair=>selected(pair,rest,stack),X.resolveTx(w,1n+offset),B.Bundle{w,1n+offset},Route.stopped(w,1n+offset,B.length(R.Transaction,R.World.txArena(w)),terminal)))

def afterWalk(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+tx: Nat) -> C.Machine:
  B.choose(~C.Machine,B.ok(w),_=>C.afterParkIntake(w,rest,stack,tx),_=>C.Machine{w,rest,stack})

def withComparators(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+tx: Nat,empty: Bool) -> C.Machine:
  B.choose(~C.Machine,empty,_=>afterWalk(S.parkPendingNodes(w,tx),rest,stack,tx),_=>C.Machine{w,C.ParkIntake{tx,0n,B.length(Nat,R.World.pendingNodes(w))} <> C.AfterPark{tx} <> rest,stack})

def noComparators(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,comparators: {List.is_empty(&2,R.ComparatorBinding,R.World.comparators(w)) == True{} : Bool}) -> {selected(B.Bundle{w,1n+offset},rest,stack) == afterWalk(S.parkPendingNodes(w,1n+offset),rest,stack,1n+offset) : C.Machine}:
  Equal.cong(Bool,C.Machine,flag=>withComparators(w,rest,stack,1n+offset,flag),List.is_empty(&2,R.ComparatorBinding,R.World.comparators(w)),True{},comparators)

def walked(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+tx: Nat,+intake: I.Intake<w,B.length(Nat,R.World.pendingNodes(w))>,first: {I.cursor(w,B.length(Nat,R.World.pendingNodes(w)),intake) == 0n : Nat},healthy: {B.ok(w) == True{} : Bool}) -> {afterWalk(S.parkPendingNodes(w,tx),rest,stack,tx) == afterWalk(R.World.with_pendingNodes(w,[]),rest,stack,tx) : C.Machine}:
  Equal.cong(R.World,C.Machine,next=>afterWalk(next,rest,stack,tx),S.parkPendingNodes(w,tx),R.World.with_pendingNodes(w,[]),Park.captured(w,tx,intake,first,healthy))

def walkHealthy(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+tx: Nat,healthy: {B.ok(w) == True{} : Bool}) -> {afterWalk(w,rest,stack,tx) == C.afterParkIntake(w,rest,stack,tx) : C.Machine}:
  Equal.cong(Bool,C.Machine,flag=>B.choose(~C.Machine,flag,_=>C.afterParkIntake(w,rest,stack,tx),_=>C.Machine{w,rest,stack}),B.ok(w),True{},healthy)

def pendingHealth(+w: R.World) -> {B.ok(R.World.with_pendingNodes(w,[])) == B.ok(w) : Bool}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def parked(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,+intake: I.Intake<w,B.length(Nat,R.World.pendingNodes(w))>,first: {I.cursor(w,B.length(Nat,R.World.pendingNodes(w)),intake) == 0n : Nat},+healthy: {B.ok(w) == True{} : Bool},comparators: {List.is_empty(&2,R.ComparatorBinding,R.World.comparators(w)) == True{} : Bool}) -> {selected(B.Bundle{w,1n+offset},rest,stack) == C.afterParkIntake(R.World.with_pendingNodes(w,[]),rest,stack,1n+offset) : C.Machine}:
  +next = R.World.with_pendingNodes(w,[])
  +tx = {1n+offset : Nat}
  +ready = Equal.trans(Bool,B.ok(next),B.ok(w),True{},pendingHealth(w),healthy)
  Equal.trans(C.Machine,selected(B.Bundle{w,tx},rest,stack),afterWalk(S.parkPendingNodes(w,tx),rest,stack,tx),C.afterParkIntake(next,rest,stack,tx),noComparators(w,rest,stack,offset,comparators),Equal.trans(C.Machine,afterWalk(S.parkPendingNodes(w,tx),rest,stack,tx),afterWalk(next,rest,stack,tx),C.afterParkIntake(next,rest,stack,tx),walked(w,rest,stack,tx,intake,first,healthy),walkHealthy(next,rest,stack,tx,ready)))


def afterPark(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+tx: Nat,empty: {R.World.deferredZombies(w) == [] : List<&2,Nat>}) -> {C.afterParkIntake(w,rest,stack,tx) == C.finishSettleIntake(R.World.with_deferredZombies(w,[]),rest,stack,tx) : C.Machine}:
  Equal.cong(List<&2,Nat>,C.Machine,rows=>
    +zombies = S.sortHeights(w,rows)
    +next = R.World.with_deferredZombies(w,[])
    B.choose(~C.Machine,List.is_empty(&2,Nat,zombies),_=>C.finishSettleIntake(next,rest,stack,tx),_=>C.Machine{next,C.ParkVerdictZombies{tx,zombies} <> rest,stack}),R.World.deferredZombies(w),[],empty)

def trimmed(w: R.World) -> R.World:
  R.World.with_deferredZombies(R.World.with_pendingNodes(w,[]),[])

def target(w: R.World,rest: List<&2,C.Task>,stack: List<&2,R.Value>,tx: Nat) -> C.Machine:
  Lane.target(trimmed(w),rest,stack,tx)


def pendingZombies(+w: R.World) -> {R.World.deferredZombies(R.World.with_pendingNodes(w,[])) == R.World.deferredZombies(w) : List<&2,Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def trimmedQuiet(+w: R.World) -> {Lane.quiet(trimmed(w)) == Lane.quiet(w) : Bool}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def complete(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,+intake: I.Intake<w,B.length(Nat,R.World.pendingNodes(w))>,first: {I.cursor(w,B.length(Nat,R.World.pendingNodes(w)),intake) == 0n : Nat},healthy: {B.ok(w) == True{} : Bool},comparators: {List.is_empty(&2,R.ComparatorBinding,R.World.comparators(w)) == True{} : Bool},lane: {R.Transaction.lane(B.transaction(w,1n+offset)) == False{} : Bool},terminal: {R.Transaction.into(B.transaction(w,1n+offset)) == 0n : Nat},zombies: {R.World.deferredZombies(w) == [] : List<&2,Nat>},quiet: {Lane.quiet(w) == True{} : Bool}) -> {C.settleApplied(w,rest,stack,1n+offset) == target(w,rest,stack,1n+offset) : C.Machine}:
  +tx = {1n+offset : Nat}
  +next = R.World.with_pendingNodes(w,[])
  +park = Equal.trans(C.Machine,C.settleApplied(w,rest,stack,tx),selected(B.Bundle{w,tx},rest,stack),C.afterParkIntake(next,rest,stack,tx),resolved(w,rest,stack,offset,lane,terminal),parked(w,rest,stack,offset,intake,first,healthy,comparators))
  +after = afterPark(next,rest,stack,tx,Equal.trans(List<&2,Nat>,R.World.deferredZombies(next),R.World.deferredZombies(w),[],pendingZombies(w),zombies))
  Equal.trans(C.Machine,C.settleApplied(w,rest,stack,tx),C.afterParkIntake(next,rest,stack,tx),target(w,rest,stack,tx),park,Equal.trans(C.Machine,C.afterParkIntake(next,rest,stack,tx),C.finishSettleIntake(trimmed(w),rest,stack,tx),target(w,rest,stack,tx),after,Lane.finish(trimmed(w),rest,stack,tx,Equal.trans(Bool,Lane.quiet(trimmed(w)),Lane.quiet(w),True{},trimmedQuiet(w),quiet))))
