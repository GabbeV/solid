# Source-held setter pre-comparison joins, under a stable canonical group.
# The actual txOf cache store, resolver and joinFuture run. The group is
# positive, terminal, and is already the current flush group. Redirecting or
# distinct group merges are deliberately not claimed to be identities here.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ../runtime/write.bend as W
import ./list-update-lookup.bend as ListLens
import ./transaction-resolution.bend as Routes

def resetTransaction(+record: R.NodeExtension) -> {R.NodeExtension.with_transaction(record,R.NodeExtension.transaction(record)) == record : R.NodeExtension}:
  match record:
    case R.NodeExtension{inFlight,flightTeardown,error,blocked,pendingSources,unobserved,snapshotValue,pendingFirstChild,pendingDisposal,transaction,reask,flushed,flushedAt,q,lane,marks,shownError}: {==}

def storeRead(+w: R.World,+id: Nat) -> {B.store_extension(w,id,B.extension(w,id)) == w : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Equal.cong(List<&2,R.NodeExtension>,R.World,rows=>R.World.with_extensions(w,rows),List.set(&2,R.NodeExtension,extensions,R.Node.x(B.node(w,id)),B.extension(w,id)),extensions,ListLens.setReadIdentity(R.NodeExtension,extensions,R.Node.x(B.node(w,id)),B.blank_extension()))

def storeCanonical(+w: R.World,+id: Nat,+root: Nat,canonical: {R.NodeExtension.transaction(B.extension(w,id)) == root : Nat}) -> {B.store_extension(w,id,R.NodeExtension.with_transaction(B.extension(w,id),root)) == w : R.World}:
  Equal.trans(R.World,B.store_extension(w,id,R.NodeExtension.with_transaction(B.extension(w,id),root)),B.store_extension(w,id,B.extension(w,id)),w,Equal.cong(R.NodeExtension,R.World,record=>B.store_extension(w,id,record),R.NodeExtension.with_transaction(B.extension(w,id),root),B.extension(w,id),Equal.trans(R.NodeExtension,R.NodeExtension.with_transaction(B.extension(w,id),root),R.NodeExtension.with_transaction(B.extension(w,id),R.NodeExtension.transaction(B.extension(w,id))),B.extension(w,id),Equal.cong(Nat,R.NodeExtension,tx=>R.NodeExtension.with_transaction(B.extension(w,id),tx),root,R.NodeExtension.transaction(B.extension(w,id)),Equal.sym(Nat,R.NodeExtension.transaction(B.extension(w,id)),root,canonical)),resetTransaction(B.extension(w,id)))),storeRead(w,id))

def unpack(+pair: B.Bundle<R.World,Nat>,+id: Nat) -> B.Bundle<R.World,Nat>:
  +next = B.first(R.World,Nat,pair)
  +root = B.second(R.World,Nat,pair)
  B.Bundle{B.store_extension(next,id,R.NodeExtension.with_transaction(B.extension(next,id),root)),root}

def txOf(+w: R.World,+id: Nat,+root: Nat,+canonical: {R.NodeExtension.transaction(B.extension(w,id)) == root : Nat},stopped: {R.Transaction.into(B.transaction(w,root)) == 0n : Nat}) -> {X.txOf(w,id) == B.Bundle{w,root} : B.Bundle<R.World,Nat>}:
  Equal.trans(B.Bundle<R.World,Nat>,X.txOf(w,id),unpack(B.Bundle{w,root},id),B.Bundle{w,root},Equal.cong(B.Bundle<R.World,Nat>,B.Bundle<R.World,Nat>,pair=>unpack(pair,id),X.resolveTx(w,R.NodeExtension.transaction(B.extension(w,id))),B.Bundle{w,root},Equal.trans(B.Bundle<R.World,Nat>,X.resolveTx(w,R.NodeExtension.transaction(B.extension(w,id))),X.resolveTx(w,root),B.Bundle{w,root},Equal.cong(Nat,B.Bundle<R.World,Nat>,tx=>X.resolveTx(w,tx),R.NodeExtension.transaction(B.extension(w,id)),root,canonical),Routes.stopped(w,root,B.length(R.Transaction,R.World.txArena(w)),stopped))),Equal.cong(R.World,B.Bundle<R.World,Nat>,state=>B.Bundle{state,root},B.store_extension(w,id,R.NodeExtension.with_transaction(B.extension(w,id),root)),w,storeCanonical(w,id,root,canonical)))

def scheduled(+w: R.World) -> R.World:
  B.choose(~R.World,R.World.running(w),_=>w,_=>B.schedule(w))

def initial(+w: R.World,+root: Nat,+future: Nat) -> R.World:
  B.choose(~R.World,Nat.is_eq(future,0n),
    _=>
      +pair = B.choose(~B.Bundle<R.World,Nat>,Nat.is_eq(root,0n),_=>X.newTransaction(w,False{},0n),_=>X.resolveTx(w,root))
      R.World.with_flushTransaction(B.first(R.World,Nat,pair),B.second(R.World,Nat,pair)),
    _=>B.choose(~R.World,Nat.is_eq(root,0n),_=>w,_=>X.merge(w,root,future)))

def joinFuture(+w: R.World,+offset: Nat,+current: {R.World.flushTransaction(w) == 1n+offset : Nat},+stopped: {R.Transaction.into(B.transaction(w,1n+offset)) == 0n : Nat}) -> {X.joinFuture(w,1n+offset) == scheduled(w) : R.World}:
  +root = {1n+offset : Nat}
  +resolved = Routes.stopped(w,root,B.length(R.Transaction,R.World.txArena(w)),stopped)
  Equal.cong(R.World,R.World,state=>scheduled(state),initial(w,root,R.World.flushTransaction(w)),w,Equal.trans(R.World,initial(w,root,R.World.flushTransaction(w)),X.merge(w,root,root),w,Equal.cong(Nat,R.World,future=>initial(w,root,future),R.World.flushTransaction(w),root,current),Routes.common(w,root,root,root,resolved,resolved)))

def actual(+w: R.World,+id: Nat,+offset: Nat,canonical: {R.NodeExtension.transaction(B.extension(w,id)) == 1n+offset : Nat},current: {R.World.flushTransaction(w) == 1n+offset : Nat},+stopped: {R.Transaction.into(B.transaction(w,1n+offset)) == 0n : Nat}) -> {X.joinNode(w,id) == scheduled(w) : R.World}:
  +root = {1n+offset : Nat}
  Equal.trans(R.World,X.joinNode(w,id),X.joinFuture(w,root),scheduled(w),Equal.cong(B.Bundle<R.World,Nat>,R.World,pair=>X.joinFuture(B.first(R.World,Nat,pair),B.second(R.World,Nat,pair)),X.txOf(w,id),B.Bundle{w,root},txOf(w,id,root,canonical,stopped)),joinFuture(w,offset,current,stopped))
