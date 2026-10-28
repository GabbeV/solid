# An actual distinct-root join derives the selected group's terminal and
# membership facts, then reconstructs its virtual source profile. No post-join
# profile, terminal, allocation or resolver answer is an input premise.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ./transaction-pair.bend as Pair
import ./transaction-merge-laws.bend as Old
import ./transaction-join.bend as Join
import ./held-source-static.bend as V
import ./held-static-operations.bend as Frame
import ./held-virtual-group-profile.bend as Virtual
import ./held-write-profile.bend as P

def leftFits(+prefix: List<&2,R.Transaction>,+record: R.Transaction,+suffix: List<&2,R.Transaction>) -> {Nat.is_lt(B.length(R.Transaction,prefix),B.length(R.Transaction,B.append(R.Transaction,prefix,record <> suffix))) == True{} : Bool}:
  match prefix:
    case Nil{}: {==}
    case head <> +tail: leftFits(tail,record,suffix)

def rightFits(+prefix: List<&2,R.Transaction>,+left: R.Transaction,+gap: List<&2,R.Transaction>,+right: R.Transaction,+suffix: List<&2,R.Transaction>) -> {Nat.is_lt(Nat.add(B.length(R.Transaction,prefix),1n+B.length(R.Transaction,gap)),B.length(R.Transaction,B.append(R.Transaction,prefix,left <> B.append(R.Transaction,gap,right <> suffix)))) == True{} : Bool}:
  match prefix:
    case Nil{}: leftFits(gap,right,suffix)
    case head <> +tail: rightFits(tail,left,gap,right,suffix)

def allocatedAfter(+w: R.World,+prefix: List<&2,R.Transaction>,+left: R.Transaction,+gap: List<&2,R.Transaction>,+right: R.Transaction,+suffix: List<&2,R.Transaction>,+reverse: Bool) -> {Nat.is_lt(Pair.targetId(prefix,gap,reverse),B.length(R.Transaction,R.World.txArena(Pair.after(w,prefix,left,gap,right,suffix,reverse)))) == True{} : Bool}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match reverse:
        case False{}: rightFits(prefix,R.Transaction.with_into(Old.root(left),Pair.rightId(prefix,gap)),gap,Join.transfer(Old.root(left),Old.root(right)),suffix)
        case True{}: leftFits(prefix,Join.transfer(Old.root(right),Old.root(left)),B.append(R.Transaction,gap,R.Transaction.with_into(Old.root(right),Pair.leftId(prefix)) <> suffix))

def allocated(+w: R.World,+prefix: List<&2,R.Transaction>,+left: R.Transaction,+gap: List<&2,R.Transaction>,+right: R.Transaction,+suffix: List<&2,R.Transaction>,+reverse: Bool) -> {Nat.is_lt(Pair.targetId(prefix,gap,reverse),B.length(R.Transaction,R.World.txArena(Pair.merged(w,prefix,left,gap,right,suffix,reverse)))) == True{} : Bool}:
  +next = Pair.merged(w,prefix,left,gap,right,suffix,reverse)
  +after = Pair.after(w,prefix,left,gap,right,suffix,reverse)
  +root = Pair.targetId(prefix,gap,reverse)
  Equal.trans(Bool,Nat.is_lt(root,B.length(R.Transaction,R.World.txArena(next))),Nat.is_lt(root,B.length(R.Transaction,R.World.txArena(after))),True{},Equal.cong(R.World,Bool,state=>Nat.is_lt(root,B.length(R.Transaction,R.World.txArena(state))),next,after,Pair.merge(w,prefix,left,gap,right,suffix,reverse)),allocatedAfter(w,prefix,left,gap,right,suffix,reverse))

def static(+w: R.World,+prefix: List<&2,R.Transaction>,+left: R.Transaction,+gap: List<&2,R.Transaction>,+right: R.Transaction,+suffix: List<&2,R.Transaction>,+reverse: Bool) -> {V.observe(Pair.merged(w,prefix,left,gap,right,suffix,reverse)) == V.observe(Pair.scope(w,prefix,Old.root(left),gap,Old.root(right),suffix)) : V.View}:
  match reverse:
    case False{}:
      +start = Pair.scope(w,prefix,Old.root(left),gap,Old.root(right),suffix)
      Equal.trans(V.View,V.observe(Pair.merged(w,prefix,left,gap,right,suffix,False{})),V.observe(X.mergeResolved(start,Pair.leftId(prefix),Pair.rightId(prefix,gap))),V.observe(start),Equal.cong(R.World,V.View,state=>V.observe(state),Pair.merged(w,prefix,left,gap,right,suffix,False{}),X.mergeResolved(start,Pair.leftId(prefix),Pair.rightId(prefix,gap)),Frame.normalized(start,Pair.leftId(prefix),Pair.rightId(prefix,gap),Pair.leftId(prefix),Pair.rightId(prefix,gap),Pair.leftResolution(w,prefix,left,gap,right,suffix),Pair.rightResolution(w,prefix,left,gap,right,suffix))),Frame.resolved(start,Pair.leftId(prefix),Pair.rightId(prefix,gap)))
    case True{}:
      +start = Pair.scope(w,prefix,Old.root(left),gap,Old.root(right),suffix)
      Equal.trans(V.View,V.observe(Pair.merged(w,prefix,left,gap,right,suffix,True{})),V.observe(X.mergeResolved(start,Pair.rightId(prefix,gap),Pair.leftId(prefix))),V.observe(start),Equal.cong(R.World,V.View,state=>V.observe(state),Pair.merged(w,prefix,left,gap,right,suffix,True{}),X.mergeResolved(start,Pair.rightId(prefix,gap),Pair.leftId(prefix)),Frame.normalized(start,Pair.rightId(prefix,gap),Pair.leftId(prefix),Pair.rightId(prefix,gap),Pair.leftId(prefix),Pair.rightResolution(w,prefix,left,gap,right,suffix),Pair.leftResolution(w,prefix,left,gap,right,suffix))),Frame.resolved(start,Pair.rightId(prefix,gap),Pair.leftId(prefix)))

def profile(+w: R.World,+prefix: List<&2,R.Transaction>,+left: R.Transaction,+gap: List<&2,R.Transaction>,+right: R.Transaction,+suffix: List<&2,R.Transaction>,+reverse: Bool,+id: Nat,+oldOffset: Nat,+initial: P.Profile<Pair.scope(w,prefix,Old.root(left),gap,Old.root(right),suffix),id,oldOffset>) -> P.Profile<Virtual.state(Pair.merged(w,prefix,left,gap,right,suffix,reverse),id,Pair.targetPred(prefix,gap,reverse)),id,Pair.targetPred(prefix,gap,reverse)>:
  +next = Pair.merged(w,prefix,left,gap,right,suffix,reverse)
  +root = Pair.targetId(prefix,gap,reverse)
  +offset = Pair.targetPred(prefix,gap,reverse)
  +same = Pair.targetPositive(prefix,gap,reverse)
  +back = Equal.sym(Nat,root,1n+offset,same)
  +terminal = Equal.trans(Nat,R.Transaction.into(B.transaction(next,1n+offset)),R.Transaction.into(B.transaction(next,root)),0n,Equal.cong(Nat,Nat,n=>R.Transaction.into(B.transaction(next,n)),1n+offset,root,back),Pair.stopped(w,prefix,left,gap,right,suffix,reverse))
  +room = Equal.trans(Bool,Nat.is_lt(1n+offset,B.length(R.Transaction,R.World.txArena(next))),Nat.is_lt(root,B.length(R.Transaction,R.World.txArena(next))),True{},Equal.cong(Nat,Bool,n=>Nat.is_lt(n,B.length(R.Transaction,R.World.txArena(next))),1n+offset,root,back),allocated(w,prefix,left,gap,right,suffix,reverse))
  Virtual.retarget(Pair.scope(w,prefix,Old.root(left),gap,Old.root(right),suffix),next,id,oldOffset,offset,initial,static(w,prefix,left,gap,right,suffix,reverse),terminal,room)
