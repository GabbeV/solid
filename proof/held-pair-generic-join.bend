# Generic first-controller boundary: all initial facts are checked fields of
# Ready, whose concrete factory is separately proved. No raw graph expansion.
# Actual two-controller join facts, from raw construction in either direction.
# Both initial obligations, retained captures and source cache are derived.
import Base
import ./held-first-ready.bend as Ready
import ./held-controller-data.bend as Data
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ../runtime/transaction.bend as X
import ./held-pair-generic-state.bend as State
import ./held-pair-generic-facts.bend as Input
import ./transaction-pair.bend as Pair
import ./transaction-merge-frame.bend as Frame
import ./held-source-static.bend as V
import ./held-static-operations.bend as Static
import ./action-opening.bend as Opening
import ./held-pair-join-profile.bend as Join

def sameArena(+w: R.World) -> {R.World.with_txArena(w,R.World.txArena(w)) == w : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def scoped(+w: R.World,+id: Nat,known: {R.World.txArena(w) == [B.blank_transaction(),Data.group(id),Opening.record(1n,True{})] : List<&2,R.Transaction>}) -> {Pair.scope(w,[],Data.group(id),[],Opening.record(1n,True{}),[]) == w : R.World}:
  +rows = {[B.blank_transaction(),Data.group(id),Opening.record(1n,True{})] : List<&2,R.Transaction>}
  Equal.trans(R.World,Pair.scope(w,[],Data.group(id),[],Opening.record(1n,True{}),[]),R.World.with_txArena(w,R.World.txArena(w)),w,Equal.cong(List<&2,R.Transaction>,R.World,arena=>R.World.with_txArena(w,arena),rows,R.World.txArena(w),Equal.sym(List<&2,R.Transaction>,R.World.txArena(w),rows,known)),sameArena(w))

def scope(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+ready: Ready.Ready<seed,id,first>) -> {Pair.scope(State.opened(seed,second),[],Data.group(id),[],Opening.record(1n,True{}),[]) == State.opened(seed,second) : R.World}:
  scoped(State.opened(seed,second),id,Input.arena(seed,id,first,second,ready))

def paired(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+reverse: Bool,+ready: Ready.Ready<seed,id,first>) -> {Pair.merged(State.opened(seed,second),[],Data.group(id),[],Opening.record(1n,True{}),[],reverse) == State.joined(seed,second,reverse) : R.World}:
  +w = State.opened(seed,second)
  Equal.cong(R.World,R.World,state=>X.merge(state,Pair.sourceId([],[],reverse),Pair.targetId([],[],reverse)),Pair.scope(w,[],Data.group(id),[],Opening.record(1n,True{}),[]),w,scope(seed,id,first,second,ready))

def exact(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+reverse: Bool,+ready: Ready.Ready<seed,id,first>) -> {State.joined(seed,second,reverse) == Pair.after(State.opened(seed,second),[],Data.group(id),[],Opening.record(1n,True{}),[],reverse) : R.World}:
  +w = State.opened(seed,second)
  +pair = Pair.merged(w,[],Data.group(id),[],Opening.record(1n,True{}),[],reverse)
  Equal.trans(R.World,State.joined(seed,second,reverse),pair,Pair.after(w,[],Data.group(id),[],Opening.record(1n,True{}),[],reverse),Equal.sym(R.World,pair,State.joined(seed,second,reverse),paired(seed,id,first,second,reverse,ready)),Pair.merge(w,[],Data.group(id),[],Opening.record(1n,True{}),[],reverse))

def frame(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+reverse: Bool,+ready: Ready.Ready<seed,id,first>) -> {Frame.observe(State.joined(seed,second,reverse)) == Frame.observe(State.opened(seed,second)) : R.World}:
  +w = State.opened(seed,second)
  +after = Pair.after(w,[],Data.group(id),[],Opening.record(1n,True{}),[],reverse)
  Equal.trans(R.World,Frame.observe(State.joined(seed,second,reverse)),Frame.observe(after),Frame.observe(w),Equal.cong(R.World,R.World,state=>Frame.observe(state),State.joined(seed,second,reverse),after,exact(seed,id,first,second,reverse,ready)),Frame.after(w,[],Data.group(id),[],Opening.record(1n,True{}),[],reverse))

def static(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+reverse: Bool,+ready: Ready.Ready<seed,id,first>) -> {V.observe(State.joined(seed,second,reverse)) == V.observe(seed) : V.View}:
  Static.compose(seed,State.opened(seed,second),State.joined(seed,second,reverse),Frame.static(State.opened(seed,second),State.joined(seed,second,reverse),frame(seed,id,first,second,reverse,ready)),Input.static(seed,id,first,second,ready))

def stopped(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+reverse: Bool,+ready: Ready.Ready<seed,id,first>) -> {R.Transaction.into(B.transaction(State.joined(seed,second,reverse),Pair.targetId([],[],reverse))) == 0n : Nat}:
  +w = State.opened(seed,second)
  +pair = Pair.merged(w,[],Data.group(id),[],Opening.record(1n,True{}),[],reverse)
  +root = Pair.targetId([],[],reverse)
  Equal.trans(Nat,R.Transaction.into(B.transaction(State.joined(seed,second,reverse),root)),R.Transaction.into(B.transaction(pair,root)),0n,Equal.cong(R.World,Nat,state=>R.Transaction.into(B.transaction(state,root)),State.joined(seed,second,reverse),pair,Equal.sym(R.World,pair,State.joined(seed,second,reverse),paired(seed,id,first,second,reverse,ready))),Pair.stopped(w,[],Data.group(id),[],Opening.record(1n,True{}),[],reverse))

def allocated(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+reverse: Bool,+ready: Ready.Ready<seed,id,first>) -> {Nat.is_lt(Pair.targetId([],[],reverse),B.length(R.Transaction,R.World.txArena(State.joined(seed,second,reverse)))) == True{} : Bool}:
  +w = State.opened(seed,second)
  +pair = Pair.merged(w,[],Data.group(id),[],Opening.record(1n,True{}),[],reverse)
  +root = Pair.targetId([],[],reverse)
  Equal.trans(Bool,Nat.is_lt(root,B.length(R.Transaction,R.World.txArena(State.joined(seed,second,reverse)))),Nat.is_lt(root,B.length(R.Transaction,R.World.txArena(pair))),True{},Equal.cong(R.World,Bool,state=>Nat.is_lt(root,B.length(R.Transaction,R.World.txArena(state))),State.joined(seed,second,reverse),pair,Equal.sym(R.World,pair,State.joined(seed,second,reverse),paired(seed,id,first,second,reverse,ready))),Join.allocated(w,[],Data.group(id),[],Opening.record(1n,True{}),[],reverse))
