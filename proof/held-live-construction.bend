# Real action create/open and pair merge supply the live-list occurrence.
# The generic seed's live list is explicit; the raw factory discharges it.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ../runtime/transaction.bend as X
import ./held-opened-state.bend as First
import ./held-first-ready.bend as Ready
import ./held-controller-data.bend as Data
import ./action-opening.bend as Opening
import ./action-constructor-static.bend as Static
import ./held-pair-generic-state.bend as State
import ./held-pair-generic-join.bend as Join
import ./held-pair-generic-context.bend as Context
import ./transaction-pair.bend as Pair

def initial(+value: R.Value,+methods: R.Expr) -> {R.World.transactions(First.opened(value,methods)) == [1n] : List<&2,Nat>}:
  {==}

def created(+w: R.World,+methods: R.Expr) -> {R.World.transactions(B.first(R.World,Nat,A.create(w,methods))) == R.World.transactions(w) : List<&2,Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def opened(+w: R.World,+actor: Nat) -> {R.World.transactions(A.open(w,actor)) == B.append(Nat,R.World.transactions(w),[B.length(R.Transaction,R.World.txArena(w))]) : List<&2,Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def secondController(+w: R.World,+methods: R.Expr) -> {R.World.transactions(State.opened(w,methods)) == B.append(Nat,R.World.transactions(w),[B.length(R.Transaction,R.World.txArena(w))]) : List<&2,Nat>}:
  +pair = A.create(w,methods)
  +next = B.first(R.World,Nat,pair)
  +index = B.length(R.Transaction,R.World.txArena(next))
  Equal.trans(List<&2,Nat>,R.World.transactions(State.opened(w,methods)),B.append(Nat,R.World.transactions(next),[index]),B.append(Nat,R.World.transactions(w),[B.length(R.Transaction,R.World.txArena(w))]),opened(next,B.second(R.World,Nat,pair)),Equal.trans(List<&2,Nat>,B.append(Nat,R.World.transactions(next),[index]),B.append(Nat,R.World.transactions(w),[index]),B.append(Nat,R.World.transactions(w),[B.length(R.Transaction,R.World.txArena(w))]),Equal.cong(List<&2,Nat>,List<&2,Nat>,rows=>B.append(Nat,rows,[index]),R.World.transactions(next),R.World.transactions(w),created(w,methods)),Equal.cong(List<&2,R.Transaction>,List<&2,Nat>,rows=>B.append(Nat,R.World.transactions(w),[B.length(R.Transaction,rows)]),R.World.txArena(next),R.World.txArena(w),Static.createdArena(w,methods))))

def pairOpened(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+ready: Ready.Ready<seed,id,first>,live: {R.World.transactions(seed) == [1n] : List<&2,Nat>}) -> {R.World.transactions(State.opened(seed,second)) == [1n,2n] : List<&2,Nat>}:
  +index = B.length(R.Transaction,R.World.txArena(seed))
  Equal.trans(List<&2,Nat>,R.World.transactions(State.opened(seed,second)),B.append(Nat,R.World.transactions(seed),[index]),[1n,2n],secondController(seed,second),Equal.trans(List<&2,Nat>,B.append(Nat,R.World.transactions(seed),[index]),[1n,index],[1n,2n],Equal.cong(List<&2,Nat>,List<&2,Nat>,rows=>B.append(Nat,rows,[index]),R.World.transactions(seed),[1n],live),Equal.cong(List<&2,R.Transaction>,List<&2,Nat>,rows=>[1n,B.length(R.Transaction,rows)],R.World.txArena(seed),[B.blank_transaction(),Data.group(id)],Ready.arena(seed,id,first,ready))))

def after(+w: R.World,+id: Nat,+reverse: Bool) -> {R.World.transactions(Pair.after(w,[],Data.group(id),[],Opening.record(1n,True{}),[],reverse)) == X.removeIdentity(R.World.transactions(w),Pair.sourceId([],[],reverse)) : List<&2,Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match reverse:
        case False{}: {==}
        case True{}: {==}

def removePair(+reverse: Bool) -> {X.removeIdentity([1n,2n],Pair.sourceId([],[],reverse)) == [Context.root(reverse)] : List<&2,Nat>}:
  match reverse:
    case False{}: {==}
    case True{}: {==}

def joined(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+reverse: Bool,+ready: Ready.Ready<seed,id,first>,live: {R.World.transactions(seed) == [1n] : List<&2,Nat>}) -> {R.World.transactions(State.joined(seed,second,reverse)) == [Context.root(reverse)] : List<&2,Nat>}:
  +w = State.opened(seed,second)
  +result = Pair.after(w,[],Data.group(id),[],Opening.record(1n,True{}),[],reverse)
  Equal.trans(List<&2,Nat>,R.World.transactions(State.joined(seed,second,reverse)),R.World.transactions(result),[Context.root(reverse)],Equal.cong(R.World,List<&2,Nat>,state=>R.World.transactions(state),State.joined(seed,second,reverse),result,Join.exact(seed,id,first,second,reverse,ready)),Equal.trans(List<&2,Nat>,R.World.transactions(result),X.removeIdentity(R.World.transactions(w),Pair.sourceId([],[],reverse)),[Context.root(reverse)],after(w,id,reverse),Equal.trans(List<&2,Nat>,X.removeIdentity(R.World.transactions(w),Pair.sourceId([],[],reverse)),X.removeIdentity([1n,2n],Pair.sourceId([],[],reverse)),[Context.root(reverse)],Equal.cong(List<&2,Nat>,List<&2,Nat>,rows=>X.removeIdentity(rows,Pair.sourceId([],[],reverse)),R.World.transactions(w),[1n,2n],pairOpened(seed,id,first,second,ready,live)),removePair(reverse))))
