# The actual two-step returned-body path retires its captured live group.
# The route and positive debt concern entry state, not an assumed final count.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ../runtime/transaction.bend as X
import ./transaction-resolution.bend as Paths
import ./transaction-route-transport.bend as Transport
import ./action-resolution.bend as Done
import ./action-output-frame.bend as Output
import ./action-body-return.bend as Body
import ./pending-stack-history.bend as Steps


def exitArena(+w: R.World) -> {R.World.txArena(A.exit(w)) == R.World.txArena(w) : List<&2,R.Transaction>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def exitActions(+w: R.World) -> {R.World.actions(A.exit(w)) == R.World.actions(w) : List<&2,R.ActionState>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def exitCapture(+w: R.World,+id: Nat) -> {R.ActionState.transaction(A.get(A.exit(w),id)) == R.ActionState.transaction(A.get(w,id)) : Nat}:
  Equal.cong(List<&2,R.ActionState>,Nat,rows=>R.ActionState.transaction(B.get(R.ActionState,rows,id,A.blank())),R.World.actions(A.exit(w)),R.World.actions(w),exitActions(w))

def resolution(+w: R.World,+id: Nat,+path: Paths.Route<w>,+extra: Nat,captured: {R.ActionState.transaction(A.get(w,id)) == Paths.origin(w,path) : Nat},room: {1n+B.length(R.Transaction,R.World.txArena(w)) == Nat.add(Paths.depth(w,path),1n+extra) : Nat}) -> {X.resolveTx(A.exit(w),R.ActionState.transaction(A.get(A.exit(w),id))) == B.Bundle{A.exit(w),Paths.terminal(w,path)} : B.Bundle<R.World,Nat>}:
  +capture = Equal.trans(Nat,R.ActionState.transaction(A.get(A.exit(w),id)),R.ActionState.transaction(A.get(w,id)),Paths.origin(w,path),exitCapture(w,id),captured)
  Equal.trans(B.Bundle<R.World,Nat>,X.resolveTx(A.exit(w),R.ActionState.transaction(A.get(A.exit(w),id))),X.resolveTx(A.exit(w),Paths.origin(w,path)),B.Bundle{A.exit(w),Paths.terminal(w,path)},Equal.cong(Nat,B.Bundle<R.World,Nat>,n=>X.resolveTx(A.exit(w),n),R.ActionState.transaction(A.get(A.exit(w),id)),Paths.origin(w,path),capture),Transport.public(w,A.exit(w),path,extra,exitArena(w),room))

def exitOpen(+w: R.World,+root: Nat,+remaining: Nat,open: {R.Transaction.open(B.transaction(w,root)) == 1n+remaining : Nat}) -> {R.Transaction.open(B.transaction(A.exit(w),root)) == 1n+remaining : Nat}:
  Equal.trans(Nat,R.Transaction.open(B.transaction(A.exit(w),root)),R.Transaction.open(B.transaction(w,root)),1n+remaining,Equal.cong(List<&2,R.Transaction>,Nat,rows=>R.Transaction.open(B.get(R.Transaction,rows,root,B.blank_transaction())),R.World.txArena(A.exit(w)),R.World.txArena(w),exitArena(w)),open)

def target(+w: R.World,+root: Nat,remaining: Nat) -> R.World:
  B.schedule(B.store_transaction(A.exit(w),root,R.Transaction.with_open(B.transaction(A.exit(w),root),remaining)))

def complete(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+value: R.Value,+path: Paths.Route<w>,+extra: Nat,+remaining: Nat,healthy: {R.World.fault(w) == R.Healthy{} : R.Fault},captured: {R.ActionState.transaction(A.get(w,id)) == Paths.origin(w,path) : Nat},room: {1n+B.length(R.Transaction,R.World.txArena(w)) == Nat.add(Paths.depth(w,path),1n+extra) : Nat},open: {R.Transaction.open(B.transaction(w,Paths.terminal(w,path))) == 1n+remaining : Nat}) -> {Output.outer(C.world(Steps.iterate(2n,Body.start(w,rest,stack,id,value)))) == Output.outer(target(w,Paths.terminal(w,path),remaining)) : R.World}:
  Equal.trans(R.World,Output.outer(C.world(Steps.iterate(2n,Body.start(w,rest,stack,id,value)))),Output.outer(A.done(A.exit(w),id)),Output.outer(target(w,Paths.terminal(w,path),remaining)),Body.outputFrame(w,rest,stack,id,value,healthy),Equal.cong(R.World,R.World,next=>Output.outer(next),A.done(A.exit(w),id),target(w,Paths.terminal(w,path),remaining),Done.decreases(A.exit(w),id,Paths.terminal(w,path),remaining,resolution(w,id,path,extra,captured,room),exitOpen(w,Paths.terminal(w,path),remaining,open))))
