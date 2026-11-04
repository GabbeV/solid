# Captured aliases may name a redirect path into the canonical source group.
# Resolution comes from that path and its arena room, not a supplied result.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ./transaction-rejoin-history.bend as Alias
import ./transaction-resolution.bend as Routes
import ./held-setter-entry.bend as Entry
import ./held-preparation-source.bend as Prepare

def currentOrdinary(+w: R.World,+rootOffset: Nat,+captureOffset: Nat,+alias: Alias.Alias<w,1n+rootOffset>,+positive: {Alias.identity(w,1n+rootOffset,alias) == 1n+captureOffset : Nat},future: {R.World.flushTransaction(w) == 1n+rootOffset : Nat},stopped: {R.Transaction.into(B.transaction(w,1n+rootOffset)) == 0n : Nat}) -> {X.joinFutureOrdinary(w,1n+captureOffset) == Entry.scheduled(w) : R.World}:
  +root = {1n+rootOffset : Nat}
  +capture = {1n+captureOffset : Nat}
  +resolved = Equal.trans(B.Bundle<R.World,Nat>,X.resolveTx(w,capture),X.resolveTx(w,Alias.identity(w,root,alias)),B.Bundle{w,root},Equal.cong(Nat,B.Bundle<R.World,Nat>,id=>X.resolveTx(w,id),capture,Alias.identity(w,root,alias),Equal.sym(Nat,Alias.identity(w,root,alias),capture,positive)),Alias.resolution(w,root,alias))
  +merged = Routes.common(w,capture,root,root,resolved,Routes.stopped(w,root,B.length(R.Transaction,R.World.txArena(w)),stopped))
  Equal.cong(R.World,R.World,state=>Entry.scheduled(state),Entry.initial(w,capture,R.World.flushTransaction(w)),w,Equal.trans(R.World,Entry.initial(w,capture,R.World.flushTransaction(w)),X.merge(w,capture,root),w,Equal.cong(Nat,R.World,selected=>Entry.initial(w,capture,selected),R.World.flushTransaction(w),root,future),merged))

def freshOrdinary(+w: R.World,+rootOffset: Nat,+captureOffset: Nat,+alias: Alias.Alias<w,1n+rootOffset>,+positive: {Alias.identity(w,1n+rootOffset,alias) == 1n+captureOffset : Nat},empty: {R.World.flushTransaction(w) == 0n : Nat}) -> {X.joinFutureOrdinary(w,1n+captureOffset) == Entry.scheduled(Prepare.flush(w,1n+rootOffset)) : R.World}:
  +root = {1n+rootOffset : Nat}
  +capture = {1n+captureOffset : Nat}
  +resolved = Equal.trans(B.Bundle<R.World,Nat>,X.resolveTx(w,capture),X.resolveTx(w,Alias.identity(w,root,alias)),B.Bundle{w,root},Equal.cong(Nat,B.Bundle<R.World,Nat>,id=>X.resolveTx(w,id),capture,Alias.identity(w,root,alias),Equal.sym(Nat,Alias.identity(w,root,alias),capture,positive)),Alias.resolution(w,root,alias))
  Equal.trans(R.World,X.joinFutureOrdinary(w,capture),Entry.scheduled(Entry.initial(w,capture,0n)),Entry.scheduled(Prepare.flush(w,root)),Equal.cong(Nat,R.World,selected=>Entry.scheduled(Entry.initial(w,capture,selected)),R.World.flushTransaction(w),0n,empty),Equal.cong(B.Bundle<R.World,Nat>,R.World,pair=>Prepare.resolved(pair),X.resolveTx(w,capture),B.Bundle{w,root},resolved))

def current(+w: R.World,+rootOffset: Nat,+captureOffset: Nat,+alias: Alias.Alias<w,1n+rootOffset>,+positive: {Alias.identity(w,1n+rootOffset,alias) == 1n+captureOffset : Nat},future: {R.World.flushTransaction(w) == 1n+rootOffset : Nat},stopped: {R.Transaction.into(B.transaction(w,1n+rootOffset)) == 0n : Nat}) -> {X.joinFuture(w,Alias.identity(w,1n+rootOffset,alias)) == Entry.laneSelect(w,1n+captureOffset,Entry.scheduled(w)) : R.World}:
  Equal.trans(R.World,X.joinFuture(w,Alias.identity(w,1n+rootOffset,alias)),X.joinFuture(w,1n+captureOffset),Entry.laneSelect(w,1n+captureOffset,Entry.scheduled(w)),Equal.cong(Nat,R.World,id=>X.joinFuture(w,id),Alias.identity(w,1n+rootOffset,alias),1n+captureOffset,positive),Equal.cong(R.World,R.World,state=>Entry.laneSelect(w,1n+captureOffset,state),X.joinFutureOrdinary(w,1n+captureOffset),Entry.scheduled(w),currentOrdinary(w,rootOffset,captureOffset,alias,positive,future,stopped)))

def freshChoice(+w: R.World,+rootOffset: Nat,+captureOffset: Nat,+alias: Alias.Alias<w,1n+rootOffset>,+positive: {Alias.identity(w,1n+rootOffset,alias) == 1n+captureOffset : Nat},empty: {R.World.flushTransaction(w) == 0n : Nat}) -> {X.joinFuture(w,Alias.identity(w,1n+rootOffset,alias)) == Entry.laneSelect(w,1n+captureOffset,Entry.scheduled(Prepare.flush(w,1n+rootOffset))) : R.World}:
  Equal.trans(R.World,X.joinFuture(w,Alias.identity(w,1n+rootOffset,alias)),X.joinFuture(w,1n+captureOffset),Entry.laneSelect(w,1n+captureOffset,Entry.scheduled(Prepare.flush(w,1n+rootOffset))),Equal.cong(Nat,R.World,id=>X.joinFuture(w,id),Alias.identity(w,1n+rootOffset,alias),1n+captureOffset,positive),Equal.cong(R.World,R.World,state=>Entry.laneSelect(w,1n+captureOffset,state),X.joinFutureOrdinary(w,1n+captureOffset),Entry.scheduled(Prepare.flush(w,1n+rootOffset)),freshOrdinary(w,rootOffset,captureOffset,alias,positive,empty)))

def fresh(+w: R.World,+rootOffset: Nat,+captureOffset: Nat,+alias: Alias.Alias<w,1n+rootOffset>,+positive: {Alias.identity(w,1n+rootOffset,alias) == 1n+captureOffset : Nat},empty: {R.World.flushTransaction(w) == 0n : Nat},plain: {R.Transaction.lane(B.transaction(w,1n+captureOffset)) == False{} : Bool}) -> {X.joinFuture(w,Alias.identity(w,1n+rootOffset,alias)) == Entry.scheduled(Prepare.flush(w,1n+rootOffset)) : R.World}:
  Equal.trans(R.World,X.joinFuture(w,Alias.identity(w,1n+rootOffset,alias)),Entry.laneSelect(w,1n+captureOffset,Entry.scheduled(Prepare.flush(w,1n+rootOffset))),Entry.scheduled(Prepare.flush(w,1n+rootOffset)),freshChoice(w,rootOffset,captureOffset,alias,positive,empty),Equal.cong(Bool,R.World,lane=>B.choose(~R.World,lane,_=>w,_=>Entry.scheduled(Prepare.flush(w,1n+rootOffset))),R.Transaction.lane(B.transaction(w,1n+captureOffset)),False{},plain))
