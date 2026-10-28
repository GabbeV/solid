# The finite cached-alias setter body and actual retirement preserve every
# controller record and redirect pointer. The current body's method was already
# replaced by preparation; this frame starts at that prepared boundary.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ./held-write-profile.bend as P
import ./held-write-history.bend as History
import ./held-write-outer.bend as Outer
import ./held-source-cache-rebase.bend as Cache
import ./held-source-cache-retirement.bend as Retire
import ./held-cache-body-input.bend as Input
import ./held-retirement-source-profile.bend as Post
import ./held-source-view.bend as V
import ./transaction-route-rebase.bend as Move
import ./scheduler-frame.bend as Scheduler
import ./action-body-retirement.bend as Exit
import ./action-output-frame.bend as Output

def canonicalActions(+values: List<&2,R.Value>,+w: R.World,+id: Nat,+offset: Nat,+profile: P.Profile<w,id,offset>) -> {R.World.actions(History.run(values,w,id)) == R.World.actions(w) : List<&2,R.ActionState>}:
  Outer.sameActions(w,History.run(values,w,id),R.Node.x(B.node(w,id)),History.outer(values,w,id,offset,profile))

def writtenActions(+values: List<&2,R.Value>,+w: R.World,+id: Nat,+offset: Nat,input: Input.Input<w,id,offset>) -> {R.World.actions(History.run(values,w,id)) == R.World.actions(w) : List<&2,R.ActionState>}:
  match values:
    case Nil{}: {==}
    case +head <> +tail:
      match input:
        case Input.Prepared{source,cached,+profile}:
          +virtual = Cache.canonical(w,id,1n+offset)
          +written = History.run(head <> tail,w,id)
          +other = History.run(head <> tail,virtual,id)
          Equal.trans(List<&2,R.ActionState>,R.World.actions(written),R.World.actions(other),R.World.actions(w),Equal.cong(R.World,List<&2,R.ActionState>,state=>R.World.actions(state),written,other,Cache.history(w,id,offset,head,tail,source,cached,profile)),Equal.trans(List<&2,R.ActionState>,R.World.actions(other),R.World.actions(virtual),R.World.actions(w),canonicalActions(head <> tail,virtual,id,offset,profile),Retire.actions(w,id,1n+offset)))

def writtenParents(+values: List<&2,R.Value>,+w: R.World,+id: Nat,+offset: Nat,input: Input.Input<w,id,offset>) -> {Move.parents(History.run(values,w,id)) == Move.parents(w) : List<&2,Nat>}:
  match input:
    case Input.Prepared{source,cached,+profile}:
      Equal.cong(List<&2,R.Transaction>,List<&2,Nat>,rows=>V.intos(rows),R.World.txArena(History.run(values,w,id)),R.World.txArena(w),Equal.trans(List<&2,R.Transaction>,R.World.txArena(History.run(values,w,id)),R.World.txArena(A.exit(History.run(values,w,id))),R.World.txArena(w),Equal.sym(List<&2,R.Transaction>,R.World.txArena(A.exit(History.run(values,w,id))),R.World.txArena(History.run(values,w,id)),Exit.exitArena(History.run(values,w,id))),Retire.arena(values,w,id,offset,source,cached,profile)))

def ledgerActions(frame: Scheduler.LedgerFrame) -> List<&2,R.ActionState>:
  match frame:
    case Scheduler.LedgerFrame{arena,live,actions}: actions

def scheduledActions(+w: R.World) -> {R.World.actions(B.schedule(w)) == R.World.actions(w) : List<&2,R.ActionState>}:
  Equal.cong(Scheduler.LedgerFrame,List<&2,R.ActionState>,frame=>ledgerActions(frame),Scheduler.ledger(B.schedule(w)),Scheduler.ledger(w),Scheduler.preserves(w))

def storedActions(+w: R.World,+root: Nat,+record: R.Transaction) -> {R.World.actions(B.store_transaction(w,root,record)) == R.World.actions(w) : List<&2,R.ActionState>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def targetActions(+w: R.World,+root: Nat,+remaining: Nat) -> {R.World.actions(Exit.target(w,root,remaining)) == R.World.actions(w) : List<&2,R.ActionState>}:
  +exited = A.exit(w)
  +record = R.Transaction.with_open(B.transaction(exited,root),remaining)
  +stored = B.store_transaction(exited,root,record)
  Equal.trans(List<&2,R.ActionState>,R.World.actions(Exit.target(w,root,remaining)),R.World.actions(stored),R.World.actions(w),scheduledActions(stored),Equal.trans(List<&2,R.ActionState>,R.World.actions(stored),R.World.actions(exited),R.World.actions(w),storedActions(exited,root,record),Exit.exitActions(w)))

def outputActions(+w: R.World) -> {R.World.actions(Output.outer(w)) == R.World.actions(w) : List<&2,R.ActionState>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def actualActions(+written: R.World,+next: R.World,+root: Nat,+remaining: Nat,same: {Output.outer(next) == Output.outer(Exit.target(written,root,remaining)) : R.World}) -> {R.World.actions(next) == R.World.actions(written) : List<&2,R.ActionState>}:
  Equal.trans(List<&2,R.ActionState>,R.World.actions(next),R.World.actions(Output.outer(next)),R.World.actions(written),Equal.sym(List<&2,R.ActionState>,R.World.actions(Output.outer(next)),R.World.actions(next),outputActions(next)),Equal.trans(List<&2,R.ActionState>,R.World.actions(Output.outer(next)),R.World.actions(Output.outer(Exit.target(written,root,remaining))),R.World.actions(written),Equal.cong(R.World,List<&2,R.ActionState>,w=>R.World.actions(w),Output.outer(next),Output.outer(Exit.target(written,root,remaining)),same),Equal.trans(List<&2,R.ActionState>,R.World.actions(Output.outer(Exit.target(written,root,remaining))),R.World.actions(Exit.target(written,root,remaining)),R.World.actions(written),outputActions(Exit.target(written,root,remaining)),targetActions(written,root,remaining))))

type Kept<-before: R.World,-next: R.World> is Data:
  Retained{parents: {Move.parents(next) == Move.parents(before) : List<&2,Nat>},actions: {R.World.actions(next) == R.World.actions(before) : List<&2,R.ActionState>}}

def frame(+values: List<&2,R.Value>,+w: R.World,+next: R.World,+id: Nat,+offset: Nat,+remaining: Nat,+input: Input.Input<w,id,offset>,+same: {Output.outer(next) == Output.outer(Exit.target(History.run(values,w,id),1n+offset,remaining)) : R.World}) -> Kept<w,next>:
  Retained{Equal.trans(List<&2,Nat>,Move.parents(next),Move.parents(History.run(values,w,id)),Move.parents(w),Equal.cong(V.View,List<&2,Nat>,v=>V.routes(v),V.observe(next),V.observe(History.run(values,w,id)),Post.actual(History.run(values,w,id),next,1n+offset,remaining,same)),writtenParents(values,w,id,offset,input)),Equal.trans(List<&2,R.ActionState>,R.World.actions(next),R.World.actions(History.run(values,w,id)),R.World.actions(w),actualActions(History.run(values,w,id),next,1n+offset,remaining,same),writtenActions(values,w,id,offset,input))}
