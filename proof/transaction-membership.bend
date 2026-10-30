# The actual txOf compression is an identity when the captured group is already
# terminal. List.set is a no-op beyond the list too; validity is a separate
# representation/reachability obligation, not implied by this lens law.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ./transaction-resolution.bend as Paths

def setReadback(-A: Data, +xs: List<&2, A>, +index: Nat, +fallback: A) ->
  {List.set(&2, A, xs, index, B.get(A, xs, index, fallback)) == xs : List<&2, A>}:
  match xs index:
    case Nil{} n: {==}
    case head <> tail 0n: {==}
    case +head <> +tail 1n+previous:
      Equal.cong(List<&2, A>, List<&2, A>, rest => head <> rest, List.set(&2, A, tail, previous, B.get(A, tail, previous, fallback)), tail, setReadback(A, tail, previous, fallback))

def extensionSelf(+w: R.World, +id: Nat) ->
  {B.store_extension(w, id, B.extension(w, id)) == w : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Equal.cong(List<&2, R.NodeExtension>, R.World, xs => R.World.with_extensions(w, xs), List.set(&2, R.NodeExtension, extensions, R.Node.x(B.node(w, id)), B.get(R.NodeExtension, extensions, R.Node.x(B.node(w, id)), B.blank_extension())), extensions, setReadback(R.NodeExtension, extensions, R.Node.x(B.node(w, id)), B.blank_extension()))

def recordSelf(+record: R.NodeExtension) ->
  {R.NodeExtension.with_transaction(record, R.NodeExtension.transaction(record)) == record : R.NodeExtension}:
  match record:
    case R.NodeExtension{inFlight, flightTeardown, error, blocked, pendingSources, unobserved, snapshotValue, pendingFirstChild, pendingDisposal, transaction, reask, flushed, flushedAt, q, lane, marks, shownError, +parkedFlight}: {==}

def compressed(+w: R.World, +id: Nat, +owner: Nat,
  captured: {R.NodeExtension.transaction(B.extension(w, id)) == owner : Nat}) ->
  {B.store_extension(w, id, R.NodeExtension.with_transaction(B.extension(w, id), owner)) == w : R.World}:
  Equal.trans(R.World, B.store_extension(w, id, R.NodeExtension.with_transaction(B.extension(w, id), owner)), B.store_extension(w, id, B.extension(w, id)), w,
    Equal.cong(R.NodeExtension, R.World, record => B.store_extension(w, id, record), R.NodeExtension.with_transaction(B.extension(w, id), owner), B.extension(w, id),
      Equal.trans(R.NodeExtension, R.NodeExtension.with_transaction(B.extension(w, id), owner), R.NodeExtension.with_transaction(B.extension(w, id), R.NodeExtension.transaction(B.extension(w, id))), B.extension(w, id),
        Equal.cong(Nat, R.NodeExtension, tx => R.NodeExtension.with_transaction(B.extension(w, id), tx), owner, R.NodeExtension.transaction(B.extension(w, id)), Equal.sym(Nat, R.NodeExtension.transaction(B.extension(w, id)), owner, captured)), recordSelf(B.extension(w, id)))), extensionSelf(w, id))

def afterResolve(+pair: B.Bundle<R.World, Nat>, +id: Nat) -> B.Bundle<R.World, Nat>:
  +w = B.first(R.World, Nat, pair)
  +tx = B.second(R.World, Nat, pair)
  B.Bundle{B.store_extension(w, id, R.NodeExtension.with_transaction(B.extension(w, id), tx)), tx}

def terminal(+w: R.World, +id: Nat, +owner: Nat,
  +captured: {R.NodeExtension.transaction(B.extension(w, id)) == owner : Nat},
  stopped: {R.Transaction.into(B.transaction(w, owner)) == 0n : Nat}) ->
  {X.txOf(w, id) == B.Bundle{w, owner} : B.Bundle<R.World, Nat>}:
  Equal.trans(B.Bundle<R.World, Nat>, X.txOf(w, id), afterResolve(B.Bundle{w, owner}, id), B.Bundle{w, owner},
    Equal.cong(B.Bundle<R.World, Nat>, B.Bundle<R.World, Nat>, pair => afterResolve(pair, id), X.resolveTx(w, R.NodeExtension.transaction(B.extension(w, id))), B.Bundle{w, owner},
      Equal.trans(B.Bundle<R.World, Nat>, X.resolveTx(w, R.NodeExtension.transaction(B.extension(w, id))), X.resolveTx(w, owner), B.Bundle{w, owner},
        Equal.cong(Nat, B.Bundle<R.World, Nat>, tx => X.resolveTx(w, tx), R.NodeExtension.transaction(B.extension(w, id)), owner, captured), Paths.stopped(w, owner, B.length(R.Transaction, R.World.txArena(w)), stopped))),
    Equal.cong(R.World, B.Bundle<R.World, Nat>, next => B.Bundle{next, owner}, B.store_extension(w, id, R.NodeExtension.with_transaction(B.extension(w, id), owner)), w, compressed(w, id, owner, captured)))
