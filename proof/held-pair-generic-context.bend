# Generic first-controller boundary: all initial facts are checked fields of
# Ready, whose concrete factory is separately proved. No raw graph expansion.
# Constructed joined-controller source profile and retained context facts.
# No post-join profile/capture/count is supplied by the caller.
import Base
import ./held-first-ready.bend as Ready
import ./held-controller-data.bend as Data
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ./held-pair-generic-state.bend as State
import ./held-pair-generic-facts.bend as Input
import ./held-pair-generic-join.bend as Joined
import ./transaction-pair.bend as Pair
import ./transaction-merge-frame.bend as Frame
import ./held-source-static.bend as V
import ./held-static-operations.bend as Static
import ./held-virtual-group-profile.bend as Virtual
import ./held-write-profile.bend as P
import ./held-preparation-source.bend as Source
import ./action-opening.bend as Opening

def root(reverse: Bool) -> Nat:
  1n+Pair.targetPred([],[],reverse)

def rootPair(+reverse: Bool) -> {root(reverse) == Pair.targetId([],[],reverse) : Nat}:
  match reverse:
    case False{}: {==}
    case True{}: {==}

def profile(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+reverse: Bool,+ready: Ready.Ready<seed,id,first>) -> P.Profile<Virtual.state(State.joined(seed,second,reverse),id,Pair.targetPred([],[],reverse)),id,Pair.targetPred([],[],reverse)>:
  +w = State.joined(seed,second,reverse)
  +before = seed
  +selected = Source.flush(before,1n)
  +target = Pair.targetId([],[],reverse)
  +offset = Pair.targetPred([],[],reverse)
  +static = Equal.trans(V.View,V.observe(w),V.observe(before),V.observe(selected),Joined.static(seed,id,first,second,reverse,ready),Equal.sym(V.View,V.observe(selected),V.observe(before),Static.flush(before,1n)))
  +terminal = Equal.trans(Nat,R.Transaction.into(B.transaction(w,1n+offset)),R.Transaction.into(B.transaction(w,target)),0n,Equal.cong(Nat,Nat,n=>R.Transaction.into(B.transaction(w,n)),root(reverse),target,rootPair(reverse)),Joined.stopped(seed,id,first,second,reverse,ready))
  +valid = Equal.trans(Bool,Nat.is_lt(1n+offset,B.length(R.Transaction,R.World.txArena(w))),Nat.is_lt(target,B.length(R.Transaction,R.World.txArena(w))),True{},Equal.cong(Nat,Bool,n=>Nat.is_lt(n,B.length(R.Transaction,R.World.txArena(w))),root(reverse),target,rootPair(reverse)),Joined.allocated(seed,id,first,second,reverse,ready))
  Virtual.retarget(selected,w,id,0n,offset,Ready.profile(seed,id,first,ready),static,terminal,valid)

def actor(second: Bool) -> Nat:
  B.choose(~Nat,second,_=>1n,_=>0n)

def capturedInput(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+secondActor: Bool,+ready: Ready.Ready<seed,id,first>) -> {R.ActionState.transaction(A.get(State.opened(seed,second),actor(secondActor))) == 1n+actor(secondActor) : Nat}:
  match secondActor:
    case False{}: Input.captureFirst(seed,id,first,second,ready)
    case True{}: Input.captureSecond(seed,id,first,second,ready)

def capture(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+reverse: Bool,+secondActor: Bool,+ready: Ready.Ready<seed,id,first>) -> {R.ActionState.transaction(A.get(State.joined(seed,second,reverse),actor(secondActor))) == 1n+actor(secondActor) : Nat}:
  +w = State.opened(seed,second)
  +next = State.joined(seed,second,reverse)
  Equal.trans(Nat,R.ActionState.transaction(A.get(next,actor(secondActor))),R.ActionState.transaction(A.get(w,actor(secondActor))),1n+actor(secondActor),Frame.captureValue(w,next,actor(secondActor),Joined.frame(seed,id,first,second,reverse,ready)),capturedInput(seed,id,first,second,secondActor,ready))

def methodInput(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+secondActor: Bool,+ready: Ready.Ready<seed,id,first>) -> {R.ActionState.methods(A.get(State.opened(seed,second),actor(secondActor))) == B.choose(~R.Expr,secondActor,_=>second,_=>first) : R.Expr}:
  match secondActor:
    case False{}: Input.methodFirst(seed,id,first,second,ready)
    case True{}: Input.methodSecond(seed,id,first,second,ready)

def methods(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+reverse: Bool,+secondActor: Bool,+ready: Ready.Ready<seed,id,first>) -> {R.ActionState.methods(A.get(State.joined(seed,second,reverse),actor(secondActor))) == B.choose(~R.Expr,secondActor,_=>second,_=>first) : R.Expr}:
  +w = State.opened(seed,second)
  +next = State.joined(seed,second,reverse)
  Equal.trans(R.Expr,R.ActionState.methods(A.get(next,actor(secondActor))),R.ActionState.methods(A.get(w,actor(secondActor))),B.choose(~R.Expr,secondActor,_=>second,_=>first),Frame.methodsValue(w,next,actor(secondActor),Joined.frame(seed,id,first,second,reverse,ready)),methodInput(seed,id,first,second,secondActor,ready))

def cached(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+reverse: Bool,+ready: Ready.Ready<seed,id,first>) -> {R.NodeExtension.transaction(B.extension(State.joined(seed,second,reverse),id)) == 1n : Nat}:
  +w = State.opened(seed,second)
  +next = State.joined(seed,second,reverse)
  Equal.trans(Nat,R.NodeExtension.transaction(B.extension(next,id)),R.NodeExtension.transaction(B.extension(w,id)),1n,Equal.cong(R.NodeExtension,Nat,record=>R.NodeExtension.transaction(record),B.extension(next,id),B.extension(w,id),Frame.extension(w,next,id,Joined.frame(seed,id,first,second,reverse,ready))),Input.cached(seed,id,first,second,ready))

def empty(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+reverse: Bool,+ready: Ready.Ready<seed,id,first>) -> {R.World.flushTransaction(State.joined(seed,second,reverse)) == 0n : Nat}:
  Equal.trans(Nat,R.World.flushTransaction(State.joined(seed,second,reverse)),R.World.flushTransaction(State.opened(seed,second)),0n,Frame.future(State.opened(seed,second),State.joined(seed,second,reverse),Joined.frame(seed,id,first,second,reverse,ready)),Input.empty(seed,id,first,second,ready))

def countRecord(+id: Nat,+reverse: Bool) -> {R.Transaction.open(Pair.targetRecord(Data.group(id),Opening.record(1n,True{}),reverse)) == 2n : Nat}:
  match reverse:
    case False{}: {==}
    case True{}: {==}

def count(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+reverse: Bool,+ready: Ready.Ready<seed,id,first>) -> {R.Transaction.open(B.transaction(State.joined(seed,second,reverse),root(reverse))) == 2n : Nat}:
  +w = State.opened(seed,second)
  +next = State.joined(seed,second,reverse)
  +after = Pair.after(w,[],Data.group(id),[],Opening.record(1n,True{}),[],reverse)
  +target = Pair.targetId([],[],reverse)
  +record = Pair.targetRecord(Data.group(id),Opening.record(1n,True{}),reverse)
  +lookup = Equal.trans(R.Transaction,B.transaction(next,root(reverse)),B.transaction(next,target),record,Equal.cong(Nat,R.Transaction,n=>B.transaction(next,n),root(reverse),target,rootPair(reverse)),Equal.trans(R.Transaction,B.transaction(next,target),B.transaction(after,target),record,Equal.cong(R.World,R.Transaction,state=>B.transaction(state,target),next,after,Joined.exact(seed,id,first,second,reverse,ready)),Pair.targetAfter(w,[],Data.group(id),[],Opening.record(1n,True{}),[],reverse)))
  Equal.trans(Nat,R.Transaction.open(B.transaction(next,root(reverse))),R.Transaction.open(record),2n,Equal.cong(R.Transaction,Nat,t=>R.Transaction.open(t),B.transaction(next,root(reverse)),record,lookup),countRecord(id,reverse))

def lengthAfter(+w: R.World,+id: Nat,+reverse: Bool) -> {B.length(R.Transaction,R.World.txArena(Pair.after(w,[],Data.group(id),[],Opening.record(1n,True{}),[],reverse))) == 3n : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match reverse:
        case False{}: {==}
        case True{}: {==}

def length(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+reverse: Bool,+ready: Ready.Ready<seed,id,first>) -> {B.length(R.Transaction,R.World.txArena(State.joined(seed,second,reverse))) == 3n : Nat}:
  +w = State.opened(seed,second)
  +next = State.joined(seed,second,reverse)
  +after = Pair.after(w,[],Data.group(id),[],Opening.record(1n,True{}),[],reverse)
  Equal.trans(Nat,B.length(R.Transaction,R.World.txArena(next)),B.length(R.Transaction,R.World.txArena(after)),3n,Equal.cong(R.World,Nat,state=>B.length(R.Transaction,R.World.txArena(state)),next,after,Joined.exact(seed,id,first,second,reverse,ready)),lengthAfter(w,id,reverse))
