# The actual body retirement changes debt, not the profile-sufficient source
# view. Output promise storage is projected separately; no post-body profile is
# supplied. Count/health/blocker observations remain separate theorems.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ./held-write-profile.bend as P
import ./held-source-view.bend as V
import ./held-source-operations.bend as Ops
import ./held-source-cache-rebase.bend as Cache
import ./held-source-cache-view.bend as CacheView
import ./held-source-transfer.bend as Transfer
import ./action-body-retirement.bend as Exit
import ./action-output-frame.bend as Output

def intoSetter(+record: R.Transaction,+remaining: Nat) -> {R.Transaction.into(R.Transaction.with_open(record,remaining)) == R.Transaction.into(record) : Nat}:
  match record:
    case R.Transaction{nodes,renderQueue,userQueue,reruns,into,parent,lane,verdict,open,acted,links,shown,held,marks}: {==}

def intoSet(+rows: List<&2,R.Transaction>,+root: Nat,+remaining: Nat) -> {V.intos(List.set(&2,R.Transaction,rows,root,R.Transaction.with_open(B.get(R.Transaction,rows,root,B.blank_transaction()),remaining))) == V.intos(rows) : List<&2,Nat>}:
  match rows root:
    case Nil{} at: {==}
    case +head <> +tail 0n:
      Equal.cong(Nat,List<&2,Nat>,n=>n <> V.intos(tail),R.Transaction.into(R.Transaction.with_open(head,remaining)),R.Transaction.into(head),intoSetter(head,remaining))
    case +head <> +tail 1n+at:
      Equal.cong(List<&2,Nat>,List<&2,Nat>,rest=>R.Transaction.into(head) <> rest,V.intos(List.set(&2,R.Transaction,tail,at,R.Transaction.with_open(B.get(R.Transaction,tail,at,B.blank_transaction()),remaining))),V.intos(tail),intoSet(tail,at,remaining))

def stored(+w: R.World,+root: Nat,+remaining: Nat) -> {V.observe(B.store_transaction(w,root,R.Transaction.with_open(B.transaction(w,root),remaining))) == V.observe(w) : V.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Equal.cong(List<&2,Nat>,V.View,rows=>V.Source{nodes,links,extensions,comparators,fault,marked,context,flushTransaction,rows},V.intos(List.set(&2,R.Transaction,txArena,root,R.Transaction.with_open(B.get(R.Transaction,txArena,root,B.blank_transaction()),remaining))),V.intos(txArena),intoSet(txArena,root,remaining))

def target(+w: R.World,+root: Nat,+remaining: Nat) -> {V.observe(Exit.target(w,root,remaining)) == V.observe(w) : V.View}:
  +exited = A.exit(w)
  +writtenState = B.store_transaction(exited,root,R.Transaction.with_open(B.transaction(exited,root),remaining))
  Equal.trans(V.View,V.observe(Exit.target(w,root,remaining)),V.observe(writtenState),V.observe(w),Ops.schedule(writtenState),Equal.trans(V.View,V.observe(writtenState),V.observe(exited),V.observe(w),stored(exited,root,remaining),Ops.worldActionDepth(w,Nat.sub(R.World.actionDepth(w),1n))))

def output(+w: R.World) -> {V.observe(Output.outer(w)) == V.observe(w) : V.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def actual(+written: R.World,+next: R.World,+root: Nat,+remaining: Nat,same: {Output.outer(next) == Output.outer(Exit.target(written,root,remaining)) : R.World}) -> {V.observe(next) == V.observe(written) : V.View}:
  Equal.trans(V.View,V.observe(next),V.observe(Output.outer(next)),V.observe(written),Equal.sym(V.View,V.observe(Output.outer(next)),V.observe(next),output(next)),Equal.trans(V.View,V.observe(Output.outer(next)),V.observe(Output.outer(Exit.target(written,root,remaining))),V.observe(written),Equal.cong(R.World,V.View,w=>V.observe(w),Output.outer(next),Output.outer(Exit.target(written,root,remaining)),same),Equal.trans(V.View,V.observe(Output.outer(Exit.target(written,root,remaining))),V.observe(Exit.target(written,root,remaining)),V.observe(written),output(Exit.target(written,root,remaining)),target(written,root,remaining))))

def profile(+written: R.World,+next: R.World,+id: Nat,+offset: Nat,+remaining: Nat,+before: P.Profile<Cache.canonical(written,id,1n+offset),id,offset>,same: {Output.outer(next) == Output.outer(Exit.target(written,1n+offset,remaining)) : R.World}) -> P.Profile<Cache.canonical(next,id,1n+offset),id,offset>:
  Transfer.transfer(Cache.canonical(written,id,1n+offset),Cache.canonical(next,id,1n+offset),id,offset,before,CacheView.same(written,next,id,1n+offset,actual(written,next,1n+offset,remaining,same)))
