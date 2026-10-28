# Actual transaction metadata operations preserve the held source heap view.
# Resolver safety is supplied by checked finite route certificates.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ./held-source-static.bend as V
import ./held-source-cache-rebase.bend as Cache
import ./held-preparation-source.bend as Source
import ./extension-store-lenses.bend as Lens
import ./node-store-lookup.bend as Store
import ./transaction-join.bend as Join
import ./transaction-rejoin-history.bend as Alias

def compose(+w: R.World,+middle: R.World,+next: R.World,last: {V.observe(next) == V.observe(middle) : V.View},first: {V.observe(middle) == V.observe(w) : V.View}) -> {V.observe(next) == V.observe(w) : V.View}:
  Equal.trans(V.View,V.observe(next),V.observe(middle),V.observe(w),last,first)

def flush(+w: R.World,+root: Nat) -> {V.observe(Source.flush(w,root)) == V.observe(w) : V.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def arena(+w: R.World,+rows: List<&2,R.Transaction>) -> {V.observe(R.World.with_txArena(w,rows)) == V.observe(w) : V.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def live(+w: R.World,+rows: List<&2,Nat>) -> {V.observe(R.World.with_transactions(w,rows)) == V.observe(w) : V.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def store(+w: R.World,+root: Nat,+record: R.Transaction) -> {V.observe(B.store_transaction(w,root,record)) == V.observe(w) : V.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def joined(+w: R.World,+from: Nat,+into: Nat,+source: R.Transaction,+target: R.Transaction) -> {V.observe(Join.joined(w,from,into,source,target)) == V.observe(w) : V.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def canonical(+w: R.World,+id: Nat,+root: Nat) -> {V.observe(Cache.canonical(w,id,root)) == V.observe(w) : V.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      +record = R.NodeExtension.with_transaction(B.get(R.NodeExtension,extensions,R.Node.x(B.get(R.Node,nodes,id,B.blank_node())),B.blank_extension()),root)
      Equal.cong(Nat,V.View,n=>V.Static{nodes,links,n,comparators,fault,marked,context},B.length(R.NodeExtension,List.set(&2,R.NodeExtension,extensions,R.Node.x(B.get(R.Node,nodes,id,B.blank_node())),record)),B.length(R.NodeExtension,extensions),Store.lengthSet(R.NodeExtension,extensions,R.Node.x(B.get(R.Node,nodes,id,B.blank_node())),record))

def allocated(+w: R.World,+lane: Bool,+parent: Nat) -> {V.observe(B.first(R.World,Nat,X.newTransaction(w,lane,parent))) == V.observe(w) : V.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match lane:
        case True{}: {==}
        case False{}: {==}

def choice(+flag: Bool,+w: R.World,+yes: R.World,+no: R.World,left: {V.observe(yes) == V.observe(w) : V.View},right: {V.observe(no) == V.observe(w) : V.View}) -> {V.observe(B.choose(~R.World,flag,_=>yes,_=>no)) == V.observe(w) : V.View}:
  match flag:
    case True{}: left
    case False{}: right

def resolved(+w: R.World,+from: Nat,+into: Nat) -> {V.observe(X.mergeResolved(w,from,into)) == V.observe(w) : V.View}:
  +source = B.transaction(w,from)
  +target = B.transaction(w,into)
  Equal.trans(V.View,V.observe(X.mergeResolved(w,from,into)),V.observe(Join.guarded(w,from,into,source,target)),V.observe(w),Equal.cong(R.World,V.View,state=>V.observe(state),X.mergeResolved(w,from,into),Join.guarded(w,from,into,source,target),Join.expand(w,from,into)),choice(Bool.or(Nat.is_eq(from,into),Bool.or(R.Transaction.lane(source),R.Transaction.lane(target))),w,w,Join.joined(w,from,into,source,target),{==},joined(w,from,into,source,target)))

def second(+pair: B.Bundle<R.World,Nat>,+from: Nat) -> R.World:
  X.mergeResolved(B.first(R.World,Nat,pair),from,B.second(R.World,Nat,pair))

def first(+pair: B.Bundle<R.World,Nat>,+into: Nat) -> R.World:
  second(X.resolveTx(B.first(R.World,Nat,pair),into),B.second(R.World,Nat,pair))

def normalized(+w: R.World,+from: Nat,+into: Nat,+left: Nat,+right: Nat,firstResolution: {X.resolveTx(w,from) == B.Bundle{w,left} : B.Bundle<R.World,Nat>},secondResolution: {X.resolveTx(w,into) == B.Bundle{w,right} : B.Bundle<R.World,Nat>}) -> {X.merge(w,from,into) == X.mergeResolved(w,left,right) : R.World}:
  Equal.trans(R.World,X.merge(w,from,into),first(B.Bundle{w,left},into),X.mergeResolved(w,left,right),Equal.cong(B.Bundle<R.World,Nat>,R.World,pair=>first(pair,into),X.resolveTx(w,from),B.Bundle{w,left},firstResolution),Equal.cong(B.Bundle<R.World,Nat>,R.World,pair=>second(pair,left),X.resolveTx(w,into),B.Bundle{w,right},secondResolution))

def merge(+w: R.World,+left: Nat,+right: Nat,+source: Alias.Alias<w,left>,+target: Alias.Alias<w,right>) -> {V.observe(X.merge(w,Alias.identity(w,left,source),Alias.identity(w,right,target))) == V.observe(w) : V.View}:
  +from = Alias.identity(w,left,source)
  +into = Alias.identity(w,right,target)
  Equal.trans(V.View,V.observe(X.merge(w,from,into)),V.observe(X.mergeResolved(w,left,right)),V.observe(w),Equal.cong(R.World,V.View,state=>V.observe(state),X.merge(w,from,into),X.mergeResolved(w,left,right),normalized(w,from,into,left,right,Alias.resolution(w,left,source),Alias.resolution(w,right,target))),resolved(w,left,right))
