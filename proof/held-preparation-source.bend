# Actual captured preparation into a fresh current-flush slot. The positive
# captured group is terminal and the initial flush slot is empty; no resolver
# result, post-preparation health or profile is assumed.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ../runtime/transaction.bend as X
import ./action-body-entry.bend as Prepared
import ./held-setter-entry.bend as Entry
import ./transaction-resolution.bend as Routes
import ./held-source-view.bend as View
import ./held-source-operations.bend as Frame

def flush(+w: R.World,+root: Nat) -> R.World:
  R.World.with_flushTransaction(w,root)

def resolved(+pair: B.Bundle<R.World,Nat>) -> R.World:
  Entry.scheduled(flush(B.first(R.World,Nat,pair),B.second(R.World,Nat,pair)))

def freshJoinOrdinary(+w: R.World,+offset: Nat,empty: {R.World.flushTransaction(w) == 0n : Nat},stopped: {R.Transaction.into(B.transaction(w,1n+offset)) == 0n : Nat}) -> {X.joinFutureOrdinary(w,1n+offset) == Entry.scheduled(flush(w,1n+offset)) : R.World}:
  +root = {1n+offset : Nat}
  Equal.trans(R.World,X.joinFutureOrdinary(w,root),Entry.scheduled(Entry.initial(w,root,0n)),Entry.scheduled(flush(w,root)),Equal.cong(Nat,R.World,future=>Entry.scheduled(Entry.initial(w,root,future)),R.World.flushTransaction(w),0n,empty),Equal.cong(B.Bundle<R.World,Nat>,R.World,pair=>resolved(pair),X.resolveTx(w,root),B.Bundle{w,root},Routes.stopped(w,root,B.length(R.Transaction,R.World.txArena(w)),stopped)))

# Unrestricted source result: the raw lane branch returns before scheduling.
def freshChoice(+w: R.World,+offset: Nat,+empty: {R.World.flushTransaction(w) == 0n : Nat},+stopped: {R.Transaction.into(B.transaction(w,1n+offset)) == 0n : Nat}) -> {X.joinFuture(w,1n+offset) == Entry.laneSelect(w,1n+offset,Entry.scheduled(flush(w,1n+offset))) : R.World}:
  Equal.cong(R.World,R.World,next=>Entry.laneSelect(w,1n+offset,next),X.joinFutureOrdinary(w,1n+offset),Entry.scheduled(flush(w,1n+offset)),freshJoinOrdinary(w,offset,empty,stopped))

def freshJoin(+w: R.World,+offset: Nat,empty: {R.World.flushTransaction(w) == 0n : Nat},stopped: {R.Transaction.into(B.transaction(w,1n+offset)) == 0n : Nat},plain: {R.Transaction.lane(B.transaction(w,1n+offset)) == False{} : Bool}) -> {X.joinFuture(w,1n+offset) == Entry.scheduled(flush(w,1n+offset)) : R.World}:
  Equal.trans(R.World,X.joinFuture(w,1n+offset),Entry.laneSelect(w,1n+offset,Entry.scheduled(flush(w,1n+offset))),Entry.scheduled(flush(w,1n+offset)),freshChoice(w,offset,empty,stopped),Equal.cong(Bool,R.World,lane=>B.choose(~R.World,lane,_=>w,_=>Entry.scheduled(flush(w,1n+offset))),R.Transaction.lane(B.transaction(w,1n+offset)),False{},plain))

def questionLane(+w: R.World,question: R.Question,+capture: Nat) -> {R.Transaction.lane(B.transaction(R.World.with_question(w,question),capture)) == R.Transaction.lane(B.transaction(w,capture)) : Bool}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def joinedChoice(+w: R.World,+actor: Nat,+offset: Nat,captured: {R.ActionState.transaction(A.get(w,actor)) == 1n+offset : Nat},empty: {R.World.flushTransaction(w) == 0n : Nat},stopped: {R.Transaction.into(B.transaction(w,1n+offset)) == 0n : Nat}) -> {Prepared.joined(w,actor) == Entry.laneSelect(Prepared.asked(w,actor),1n+offset,Entry.scheduled(flush(Prepared.asked(w,actor),1n+offset))) : R.World}:
  +asked = Prepared.asked(w,actor)
  +question = R.ActionState.question(A.get(w,actor))
  +nextEmpty = Equal.trans(Nat,R.World.flushTransaction(asked),R.World.flushTransaction(w),0n,Frame.questionFuture(w,question),empty)
  +nextStopped = Equal.trans(Nat,R.Transaction.into(B.transaction(asked,1n+offset)),R.Transaction.into(B.transaction(w,1n+offset)),0n,Frame.questionInto(w,question,1n+offset),stopped)
  Equal.trans(R.World,Prepared.joined(w,actor),X.joinFuture(asked,1n+offset),Entry.laneSelect(asked,1n+offset,Entry.scheduled(flush(asked,1n+offset))),Equal.cong(Nat,R.World,root=>X.joinFuture(asked,root),R.ActionState.transaction(A.get(w,actor)),1n+offset,captured),freshChoice(asked,offset,nextEmpty,nextStopped))

def joined(+w: R.World,+actor: Nat,+offset: Nat,captured: {R.ActionState.transaction(A.get(w,actor)) == 1n+offset : Nat},empty: {R.World.flushTransaction(w) == 0n : Nat},stopped: {R.Transaction.into(B.transaction(w,1n+offset)) == 0n : Nat},plain: {R.Transaction.lane(B.transaction(w,1n+offset)) == False{} : Bool}) -> {Prepared.joined(w,actor) == Entry.scheduled(flush(Prepared.asked(w,actor),1n+offset)) : R.World}:
  +asked = Prepared.asked(w,actor)
  +question = R.ActionState.question(A.get(w,actor))
  +nextEmpty = Equal.trans(Nat,R.World.flushTransaction(asked),R.World.flushTransaction(w),0n,Frame.questionFuture(w,question),empty)
  +nextStopped = Equal.trans(Nat,R.Transaction.into(B.transaction(asked,1n+offset)),R.Transaction.into(B.transaction(w,1n+offset)),0n,Frame.questionInto(w,question,1n+offset),stopped)
  Equal.trans(R.World,Prepared.joined(w,actor),X.joinFuture(asked,1n+offset),Entry.scheduled(flush(asked,1n+offset)),Equal.cong(Nat,R.World,root=>X.joinFuture(asked,root),R.ActionState.transaction(A.get(w,actor)),1n+offset,captured),freshJoin(asked,offset,nextEmpty,nextStopped,Equal.trans(Bool,R.Transaction.lane(B.transaction(asked,1n+offset)),R.Transaction.lane(B.transaction(w,1n+offset)),False{},questionLane(w,question,1n+offset),plain)))

def scheduled(+w: R.World) -> {View.observe(Entry.scheduled(w)) == View.observe(w) : View.View}:
  Frame.choice(R.World.running(w),w,w,B.schedule(w),{==},Frame.schedule(w))

def selected(+w: R.World,+root: Nat) -> {View.observe(Entry.selected(w,root)) == View.observe(w) : View.View}:
  Frame.choice(R.Transaction.lane(B.transaction(w,root)),w,w,Entry.scheduled(w),{==},scheduled(w))

def actual(+w: R.World,+actor: Nat,+offset: Nat,+tail: R.Expr,captured: {R.ActionState.transaction(A.get(w,actor)) == 1n+offset : Nat},empty: {R.World.flushTransaction(w) == 0n : Nat},stopped: {R.Transaction.into(B.transaction(w,1n+offset)) == 0n : Nat},plain: {R.Transaction.lane(B.transaction(w,1n+offset)) == False{} : Bool}) -> {View.observe(Prepared.prepared(w,actor,tail)) == View.observe(flush(w,1n+offset)) : View.View}:
  +next = Prepared.joined(w,actor)
  +entered = A.enter(next)
  +record = R.ActionState.with_methods(A.get(next,actor),tail)
  +asked = Prepared.asked(w,actor)
  +selected = flush(asked,1n+offset)
  +target = flush(w,1n+offset)
  Equal.trans(View.View,View.observe(Prepared.prepared(w,actor,tail)),View.observe(next),View.observe(target),Frame.compose(next,entered,Prepared.prepared(w,actor,tail),Frame.stored(entered,actor,record),Frame.enter(next)),Equal.trans(View.View,View.observe(next),View.observe(Entry.scheduled(selected)),View.observe(target),Equal.cong(R.World,View.View,state=>View.observe(state),next,Entry.scheduled(selected),joined(w,actor,offset,captured,empty,stopped,plain)),Equal.trans(View.View,View.observe(Entry.scheduled(selected)),View.observe(selected),View.observe(target),scheduled(selected),Frame.questionFlush(w,R.ActionState.question(A.get(w,actor)),1n+offset))))

# Already-current canonical group: preparation joins the same representative.
def joinedCurrent(+w: R.World,+actor: Nat,+offset: Nat,captured: {R.ActionState.transaction(A.get(w,actor)) == 1n+offset : Nat},future: {R.World.flushTransaction(w) == 1n+offset : Nat},stopped: {R.Transaction.into(B.transaction(w,1n+offset)) == 0n : Nat}) -> {Prepared.joined(w,actor) == Entry.selected(Prepared.asked(w,actor),1n+offset) : R.World}:
  +asked = Prepared.asked(w,actor)
  +question = R.ActionState.question(A.get(w,actor))
  +nextFuture = Equal.trans(Nat,R.World.flushTransaction(asked),R.World.flushTransaction(w),1n+offset,Frame.questionFuture(w,question),future)
  +nextStopped = Equal.trans(Nat,R.Transaction.into(B.transaction(asked,1n+offset)),R.Transaction.into(B.transaction(w,1n+offset)),0n,Frame.questionInto(w,question,1n+offset),stopped)
  Equal.trans(R.World,Prepared.joined(w,actor),X.joinFuture(asked,1n+offset),Entry.selected(asked,1n+offset),Equal.cong(Nat,R.World,root=>X.joinFuture(asked,root),R.ActionState.transaction(A.get(w,actor)),1n+offset,captured),Entry.joinFuture(asked,offset,nextFuture,nextStopped))

def current(+w: R.World,+actor: Nat,+offset: Nat,+tail: R.Expr,captured: {R.ActionState.transaction(A.get(w,actor)) == 1n+offset : Nat},future: {R.World.flushTransaction(w) == 1n+offset : Nat},stopped: {R.Transaction.into(B.transaction(w,1n+offset)) == 0n : Nat}) -> {View.observe(Prepared.prepared(w,actor,tail)) == View.observe(w) : View.View}:
  +next = Prepared.joined(w,actor)
  +entered = A.enter(next)
  +record = R.ActionState.with_methods(A.get(next,actor),tail)
  +asked = Prepared.asked(w,actor)
  Equal.trans(View.View,View.observe(Prepared.prepared(w,actor,tail)),View.observe(next),View.observe(w),Frame.compose(next,entered,Prepared.prepared(w,actor,tail),Frame.stored(entered,actor,record),Frame.enter(next)),Equal.trans(View.View,View.observe(next),View.observe(Entry.selected(asked,1n+offset)),View.observe(w),Equal.cong(R.World,View.View,state=>View.observe(state),next,Entry.selected(asked,1n+offset),joinedCurrent(w,actor,offset,captured,future,stopped)),Frame.compose(w,asked,Entry.selected(asked,1n+offset),selected(asked,1n+offset),Frame.worldQuestion(w,R.ActionState.question(A.get(w,actor))))))
