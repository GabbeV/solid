# Source completeSettle retains captured callbacks on the live held group.
# No callback is evaluated here; actual source stores/queue order are retained.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/transaction.bend as X
import ../runtime/scheduler.bend as S
import ../runtime/affects-scope.bend as Marks
import ../proof/transaction-resolution.bend as Route
import ../proof/natural-logic.bend as Logic

def liveSelected(+pair: B.Bundle<R.World,Nat>,+id: Nat) -> B.Bundle<R.World,Nat>:
  +w = B.first(R.World,Nat,pair)
  +tx = B.second(R.World,Nat,pair)
  B.Bundle{w,B.choose(~Nat,B.contains(R.World.transactions(w),tx),_=>tx,_=>0n)}

def live(+w: R.World,+offset: Nat,terminal: {R.Transaction.into(B.transaction(w,1n+offset)) == 0n : Nat},member: {B.contains(R.World.transactions(w),1n+offset) == True{} : Bool}) -> {X.liveTx(w,1n+offset) == B.Bundle{w,1n+offset} : B.Bundle<R.World,Nat>}:
  +tx = {1n+offset : Nat}
  Equal.trans(B.Bundle<R.World,Nat>,X.liveTx(w,tx),liveSelected(B.Bundle{w,tx},tx),B.Bundle{w,tx},Equal.cong(B.Bundle<R.World,Nat>,B.Bundle<R.World,Nat>,p=>liveSelected(p,tx),X.resolveTx(w,tx),B.Bundle{w,tx},Route.stopped(w,tx,B.length(R.Transaction,R.World.txArena(w)),terminal)),Equal.cong(Bool,B.Bundle<R.World,Nat>,known=>B.Bundle{w,B.choose(~Nat,known,_=>tx,_=>0n)},B.contains(R.World.transactions(w),tx),True{},member))

def selected(+pair: B.Bundle<R.World,Nat>,rest: List<&2,C.Task>,stack: List<&2,R.Value>,+renders: List<&2,Nat>,+users: List<&2,R.QueueEntry>) -> C.Machine:
  +w = B.first(R.World,Nat,pair)
  +live = B.second(R.World,Nat,pair)
  +parked = Nat.is_ne(live,0n)
  +w = Marks.releaseAmbient(w,live)
  +w = B.choose(~R.World,parked,_=>
    +w = B.store_transaction(w,live,R.Transaction.with_renderQueue(B.transaction(w,live),B.append(Nat,R.Transaction.renderQueue(B.transaction(w,live)),renders)))
    B.store_transaction(w,live,R.Transaction.with_userQueue(B.transaction(w,live),B.append(R.QueueEntry,R.Transaction.userQueue(B.transaction(w,live)),users))),_=>w)
  +w = R.World.with_renderQueue(w,C.orderedRuns(~Nat,parked,renders,[],R.World.renderQueue(w)))
  +w = R.World.with_userQueue(w,C.orderedRuns(~R.QueueEntry,parked,users,[],R.World.userQueue(w)))
  C.Machine{R.World.with_deferredZombies(w,[]),C.ZombieLoop{S.sortHeights(w,R.World.deferredZombies(w))} <> rest,stack}

def shape(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,+renders: List<&2,Nat>,+users: List<&2,R.QueueEntry>) -> {C.completeSettle(w,rest,stack,C.SeamFrame{1n+offset,renders,users,[],[]}) == selected(X.liveTx(w,1n+offset),rest,stack,renders,users) : C.Machine}:
  {==}

def stored(+w: R.World,+tx: Nat,+renders: List<&2,Nat>,users: List<&2,R.QueueEntry>) -> R.World:
  +w = B.store_transaction(w,tx,R.Transaction.with_renderQueue(B.transaction(w,tx),B.append(Nat,R.Transaction.renderQueue(B.transaction(w,tx)),renders)))
  B.store_transaction(w,tx,R.Transaction.with_userQueue(B.transaction(w,tx),B.append(R.QueueEntry,R.Transaction.userQueue(B.transaction(w,tx)),users)))

def world(w: R.World,tx: Nat,renders: List<&2,Nat>,users: List<&2,R.QueueEntry>) -> R.World:
  R.World.with_deferredZombies(R.World.with_userQueue(R.World.with_renderQueue(stored(w,tx,renders,users),[]),[]),[])

def afterMarks(+w: R.World,rest: List<&2,C.Task>,stack: List<&2,R.Value>,+offset: Nat,+renders: List<&2,Nat>,+users: List<&2,R.QueueEntry>) -> C.Machine:
  +w = stored(w,1n+offset,renders,users)
  +w = R.World.with_renderQueue(w,C.orderedRuns(~Nat,True{},renders,[],R.World.renderQueue(w)))
  +w = R.World.with_userQueue(w,C.orderedRuns(~R.QueueEntry,True{},users,[],R.World.userQueue(w)))
  C.Machine{R.World.with_deferredZombies(w,[]),C.ZombieLoop{S.sortHeights(w,R.World.deferredZombies(w))} <> rest,stack}

def marks(+w: R.World,+tx: Nat,empty: {List.is_empty(&2,Nat,R.World.ambientMarks(w)) == True{} : Bool}) -> {Marks.releaseAmbient(w,tx) == w : R.World}:
  Equal.cong(Bool,R.World,quiet=>B.choose(~R.World,quiet,_=>w,_=>B.choose(~R.World,Nat.is_ne(tx,0n),_=>Marks.parkAmbient(1n+B.length(Nat,R.World.ambientMarks(w)),w,tx,0n),_=>Marks.ambientLoop(1n+B.length(Nat,R.World.ambientMarks(w)),w,0n,0n,[]))),List.is_empty(&2,Nat,R.World.ambientMarks(w)),True{},empty)

def noMarks(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,+renders: List<&2,Nat>,+users: List<&2,R.QueueEntry>,empty: {List.is_empty(&2,Nat,R.World.ambientMarks(w)) == True{} : Bool}) -> {selected(B.Bundle{w,1n+offset},rest,stack,renders,users) == afterMarks(w,rest,stack,offset,renders,users) : C.Machine}:
  Equal.cong(R.World,C.Machine,next=>afterMarks(next,rest,stack,offset,renders,users),Marks.releaseAmbient(w,1n+offset),w,marks(w,1n+offset,empty))

def emptyQueues(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,+renders: List<&2,Nat>,+users: List<&2,R.QueueEntry>,renderEmpty: {R.World.renderQueue(w) == [] : List<&2,Nat>},userEmpty: {R.World.userQueue(w) == [] : List<&2,R.QueueEntry>},zombies: {R.World.deferredZombies(w) == [] : List<&2,Nat>}) -> {afterMarks(w,rest,stack,offset,renders,users) == C.Machine{world(w,1n+offset,renders,users),C.ZombieLoop{[]} <> rest,stack} : C.Machine}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      +raw = stored(w,1n+offset,renders,users)
      +mid = R.World.with_userQueue(R.World.with_renderQueue(raw,[]),userQueue)
      +queued = R.World.with_userQueue(R.World.with_renderQueue(raw,[]),[])
      +first = Equal.cong(List<&2,Nat>,C.Machine,rows=>
        +next = R.World.with_userQueue(R.World.with_renderQueue(raw,rows),userQueue)
        C.Machine{R.World.with_deferredZombies(next,[]),C.ZombieLoop{S.sortHeights(next,deferredZombies)} <> rest,stack},renderQueue,[],renderEmpty)
      +second = Equal.cong(List<&2,R.QueueEntry>,C.Machine,rows=>
        +next = R.World.with_userQueue(R.World.with_renderQueue(raw,[]),rows)
        C.Machine{R.World.with_deferredZombies(next,[]),C.ZombieLoop{S.sortHeights(next,deferredZombies)} <> rest,stack},userQueue,[],userEmpty)
      +last = Equal.cong(List<&2,Nat>,C.Machine,rows=>C.Machine{world(w,1n+offset,renders,users),C.ZombieLoop{S.sortHeights(queued,rows)} <> rest,stack},deferredZombies,[],zombies)
      Equal.trans(C.Machine,afterMarks(w,rest,stack,offset,renders,users),C.Machine{R.World.with_deferredZombies(mid,[]),C.ZombieLoop{S.sortHeights(mid,deferredZombies)} <> rest,stack},C.Machine{world(w,1n+offset,renders,users),C.ZombieLoop{[]} <> rest,stack},first,Equal.trans(C.Machine,C.Machine{R.World.with_deferredZombies(mid,[]),C.ZombieLoop{S.sortHeights(mid,deferredZombies)} <> rest,stack},C.Machine{world(w,1n+offset,renders,users),C.ZombieLoop{S.sortHeights(queued,deferredZombies)} <> rest,stack},C.Machine{world(w,1n+offset,renders,users),C.ZombieLoop{[]} <> rest,stack},second,last))

def complete(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,+renders: List<&2,Nat>,+users: List<&2,R.QueueEntry>,terminal: {R.Transaction.into(B.transaction(w,1n+offset)) == 0n : Nat},member: {B.contains(R.World.transactions(w),1n+offset) == True{} : Bool},ambient: {List.is_empty(&2,Nat,R.World.ambientMarks(w)) == True{} : Bool},renderEmpty: {R.World.renderQueue(w) == [] : List<&2,Nat>},userEmpty: {R.World.userQueue(w) == [] : List<&2,R.QueueEntry>},zombies: {R.World.deferredZombies(w) == [] : List<&2,Nat>}) -> {C.completeSettle(w,rest,stack,C.SeamFrame{1n+offset,renders,users,[],[]}) == C.Machine{world(w,1n+offset,renders,users),C.ZombieLoop{[]} <> rest,stack} : C.Machine}:
  Equal.trans(C.Machine,C.completeSettle(w,rest,stack,C.SeamFrame{1n+offset,renders,users,[],[]}),selected(X.liveTx(w,1n+offset),rest,stack,renders,users),C.Machine{world(w,1n+offset,renders,users),C.ZombieLoop{[]} <> rest,stack},shape(w,rest,stack,offset,renders,users),Equal.trans(C.Machine,selected(X.liveTx(w,1n+offset),rest,stack,renders,users),selected(B.Bundle{w,1n+offset},rest,stack,renders,users),C.Machine{world(w,1n+offset,renders,users),C.ZombieLoop{[]} <> rest,stack},Equal.cong(B.Bundle<R.World,Nat>,C.Machine,p=>selected(p,rest,stack,renders,users),X.liveTx(w,1n+offset),B.Bundle{w,1n+offset},live(w,offset,terminal,member)),Equal.trans(C.Machine,selected(B.Bundle{w,1n+offset},rest,stack,renders,users),afterMarks(w,rest,stack,offset,renders,users),C.Machine{world(w,1n+offset,renders,users),C.ZombieLoop{[]} <> rest,stack},noMarks(w,rest,stack,offset,renders,users,ambient),emptyQueues(w,rest,stack,offset,renders,users,renderEmpty,userEmpty,zombies))))
