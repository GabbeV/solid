# Actual group allocation, resolution, merge and join retain heap/sweep intake.
# This safety frame includes exhausted/malformed resolution; health is separate.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ./heap-entry-view.bend as View

def new(+w: R.World,+lane: Bool,+parent: Nat) -> {View.observe(B.first(R.World,Nat,X.newTransaction(w,lane,parent))) == View.observe(w) : View.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match lane:
        case False{}: {==}
        case True{}: {==}

def resolve(+fuel: Nat,+w: R.World,+id: Nat) -> {View.observe(B.first(R.World,Nat,X.resolveLoop(fuel,w,id))) == View.observe(w) : View.View}:
  match fuel:
    case 0n: View.fault(w,R.Exhausted{})
    case 1n+p:
      +next = R.Transaction.into(B.transaction(w,id))
      View.pairChoice(Nat.is_eq(next,0n),w,B.Bundle{w,id},X.resolveLoop(p,w,next),{==},resolve(p,w,next))

def resolved(+w: R.World,+id: Nat) -> {View.observe(B.first(R.World,Nat,X.resolveTx(w,id))) == View.observe(w) : View.View}:
  resolve(1n+B.length(R.Transaction,R.World.txArena(w)),w,id)

# Source mergeResolved's post-guard body, retained only as an equation cut.
def body(+w: R.World,+t: Nat,+f: Nat) -> R.World:
  +from = B.transaction(w,t)
  +into = B.transaction(w,f)
  +w = B.store_transaction(w,t,R.Transaction.with_into(from,f))
  +into = R.Transaction.with_open(into,Nat.add(R.Transaction.open(into),R.Transaction.open(from)))
  +into = R.Transaction.with_acted(into,Bool.or(R.Transaction.acted(into),R.Transaction.acted(from)))
  +into = R.Transaction.with_nodes(into,B.append(Nat,R.Transaction.nodes(into),R.Transaction.nodes(from)))
  +into = R.Transaction.with_renderQueue(into,B.append(Nat,R.Transaction.renderQueue(into),R.Transaction.renderQueue(from)))
  +into = R.Transaction.with_userQueue(into,B.append(R.QueueEntry,R.Transaction.userQueue(into),R.Transaction.userQueue(from)))
  +into = R.Transaction.with_reruns(into,B.append(Nat,R.Transaction.reruns(into),R.Transaction.reruns(from)))
  +into = R.Transaction.with_marks(into,X.appendMarks(R.Transaction.marks(into),R.Transaction.marks(from)))
  +w = B.store_transaction(w,f,into)
  R.World.with_transactions(w,X.removeIdentity(R.World.transactions(w),t))

def bodyFrame(+w: R.World,+t: Nat,+f: Nat) -> {View.observe(body(w,t,f)) == View.observe(w) : View.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def mergeResolved(+w: R.World,+t: Nat,+f: Nat) -> {View.observe(X.mergeResolved(w,t,f)) == View.observe(w) : View.View}:
  View.choice(Bool.or(Nat.is_eq(t,f),Bool.or(R.Transaction.lane(B.transaction(w,t)),R.Transaction.lane(B.transaction(w,f)))),w,w,body(w,t,f),{==},bodyFrame(w,t,f))

def merge(+w: R.World,+t: Nat,+f: Nat) -> {View.observe(X.merge(w,t,f)) == View.observe(w) : View.View}:
  +first = X.resolveTx(w,t)
  +w1 = B.first(R.World,Nat,first)
  +t1 = B.second(R.World,Nat,first)
  +second = X.resolveTx(w1,f)
  +w2 = B.first(R.World,Nat,second)
  View.compose(w,w1,X.merge(w,t,f),View.compose(w1,w2,X.merge(w,t,f),mergeResolved(w2,t1,B.second(R.World,Nat,second)),resolved(w1,f)),resolved(w,t))

def capture(+w: R.World,+t: Nat) -> R.World:
  +pair = B.choose(~B.Bundle<R.World,Nat>,Nat.is_eq(t,0n),_=>X.newTransaction(w,False{},0n),_=>X.resolveTx(w,t))
  R.World.with_flushTransaction(B.first(R.World,Nat,pair),B.second(R.World,Nat,pair))

def captureFrame(+w: R.World,+t: Nat) -> {View.observe(capture(w,t)) == View.observe(w) : View.View}:
  +pair = B.choose(~B.Bundle<R.World,Nat>,Nat.is_eq(t,0n),_=>X.newTransaction(w,False{},0n),_=>X.resolveTx(w,t))
  +next = B.first(R.World,Nat,pair)
  View.compose(w,next,capture(w,t),View.flush(next,B.second(R.World,Nat,pair)),View.pairChoice(Nat.is_eq(t,0n),w,X.newTransaction(w,False{},0n),X.resolveTx(w,t),new(w,False{},0n),resolved(w,t)))

def joined(+w: R.World,+t: Nat) -> R.World:
  B.choose(~R.World,Nat.is_eq(R.World.flushTransaction(w),0n),_=>capture(w,t),_=>B.choose(~R.World,Nat.is_eq(t,0n),_=>w,_=>X.merge(w,t,R.World.flushTransaction(w))))

def joinedFrame(+w: R.World,+t: Nat) -> {View.observe(joined(w,t)) == View.observe(w) : View.View}:
  View.choice(Nat.is_eq(R.World.flushTransaction(w),0n),w,capture(w,t),B.choose(~R.World,Nat.is_eq(t,0n),_=>w,_=>X.merge(w,t,R.World.flushTransaction(w))),captureFrame(w,t),View.choice(Nat.is_eq(t,0n),w,w,X.merge(w,t,R.World.flushTransaction(w)),{==},merge(w,t,R.World.flushTransaction(w))))

def joinFuture(+w: R.World,+t: Nat) -> {View.observe(X.joinFuture(w,t)) == View.observe(w) : View.View}:
  +next = joined(w,t)
  View.choice(R.World.running(next),w,next,B.schedule(next),joinedFrame(w,t),View.compose(w,next,B.schedule(next),View.schedule(next),joinedFrame(w,t)))
