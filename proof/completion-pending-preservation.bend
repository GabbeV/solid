# Completion prefixes preserve a pending rendered snapshot. These contracts do
# not settle a flight or execute the rest of the generator body/result protocol.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ../runtime/action-state.bend as A
import ./transaction-positive-update.bend as Update
import ./action-resolution.bend as Completion
import ./completion-graph-frame.bend as Frame
import ./pending-rendered-snapshot.bend as Snapshot

def readCore(+xs: List<&2, R.Transaction>, +index: Nat, +count: Nat, +fallback: R.Transaction) ->
  {Snapshot.ownership(B.get(R.Transaction, List.set(&2, R.Transaction, xs, index, R.Transaction.with_open(B.get(R.Transaction, xs, index, fallback), count)), index, fallback)) == Snapshot.ownership(B.get(R.Transaction, xs, index, fallback)) : Snapshot.Ownership}:
  match xs index:
    case Nil{} n: {==}
    case head <> tail 0n: Snapshot.openOwnership(head, count)
    case head <> tail 1n+previous: readCore(tail, previous, count, fallback)

def bareOwnership(+w: R.World, +root: Nat, +remaining: Nat) ->
  {Snapshot.ownership(B.transaction(Update.bare(w, root, remaining), root)) == Snapshot.ownership(B.transaction(w, root)) : Snapshot.Ownership}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      readCore(txArena, root, remaining, B.blank_transaction())

def countOwnership(+w: R.World, +root: Nat, +remaining: Nat) ->
  {Snapshot.ownership(B.transaction(Update.result(w, root, remaining), root)) == Snapshot.ownership(B.transaction(w, root)) : Snapshot.Ownership}:
  Equal.trans(Snapshot.Ownership, Snapshot.ownership(B.transaction(Update.result(w, root, remaining), root)), Snapshot.ownership(B.transaction(Update.bare(w, root, remaining), root)), Snapshot.ownership(B.transaction(w, root)),
    Equal.cong(R.Transaction, Snapshot.Ownership, record => Snapshot.ownership(record), B.transaction(Update.result(w, root, remaining), root), B.transaction(Update.bare(w, root, remaining), root), Update.scheduledRecord(Update.bare(w, root, remaining), root)), bareOwnership(w, root, remaining))

def completionOwnership(+w: R.World, +id: Nat, +root: Nat, +remaining: Nat,
  resolution: {X.resolveTx(w, R.ActionState.transaction(A.get(w, id))) == B.Bundle{w, root} : B.Bundle<R.World, Nat>},
  positive: {R.Transaction.open(B.transaction(w, root)) == 1n+remaining : Nat}) ->
  {Snapshot.ownership(B.transaction(A.done(w, id), root)) == Snapshot.ownership(B.transaction(w, root)) : Snapshot.Ownership}:
  Equal.trans(Snapshot.Ownership, Snapshot.ownership(B.transaction(A.done(w, id), root)), Snapshot.ownership(B.transaction(Update.result(w, root, remaining), root)), Snapshot.ownership(B.transaction(w, root)),
    Equal.cong(R.World, Snapshot.Ownership, state => Snapshot.ownership(B.transaction(state, root)), A.done(w, id), Update.result(w, root, remaining), Completion.decreases(w, id, root, remaining, resolution, positive)), countOwnership(w, root, remaining))

def completed(+w: R.World, +id: Nat, +root: Nat, +remaining: Nat, snapshot: Snapshot.Pending<w, root>,
  +resolution: {X.resolveTx(w, R.ActionState.transaction(A.get(w, id))) == B.Bundle{w, root} : B.Bundle<R.World, Nat>},
  +positive: {R.Transaction.open(B.transaction(w, root)) == 1n+remaining : Nat}) -> Snapshot.Pending<A.done(w, id), root>:
  Snapshot.transfer(w, A.done(w, id), root, snapshot, Frame.completion(w, id, root, remaining, resolution, positive), completionOwnership(w, id, root, remaining, resolution, positive))

def healthy(+w: R.World, +id: Nat, +root: Nat, +remaining: Nat,
  resolution: {X.resolveTx(w, R.ActionState.transaction(A.get(w, id))) == B.Bundle{w, root} : B.Bundle<R.World, Nat>},
  positive: {R.Transaction.open(B.transaction(w, root)) == 1n+remaining : Nat}) ->
  {B.ok(A.done(w, id)) == B.ok(w) : Bool}:
  Equal.trans(Bool, B.ok(A.done(w, id)), B.ok(Update.result(w, root, remaining)), B.ok(w),
    Equal.cong(R.World, Bool, state => B.ok(state), A.done(w, id), Update.result(w, root, remaining), Completion.decreases(w, id, root, remaining, resolution, positive)), Update.healthyResult(w, root, remaining))
