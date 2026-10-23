# Existing allocated transaction slots. The split supplies real list membership,
# unlike the blank fallback returned for an out-of-range transaction identity.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./arena.bend as Arena

def scope(w: R.World, prefix: List<&2, R.Transaction>, value: R.Transaction, suffix: List<&2, R.Transaction>) -> R.World:
  R.World.with_txArena(w, B.append(R.Transaction, prefix, value <> suffix))

def peek(+w: R.World, +prefix: List<&2, R.Transaction>, +value: R.Transaction, +suffix: List<&2, R.Transaction>) ->
  {B.transaction(scope(w, prefix, value, suffix), B.length(R.Transaction, prefix)) == value : R.Transaction}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Arena.getPrefix(R.Transaction, prefix, value, suffix, B.blank_transaction())

def store(+w: R.World, +prefix: List<&2, R.Transaction>, +old: R.Transaction, +suffix: List<&2, R.Transaction>, +value: R.Transaction) ->
  {B.store_transaction(scope(w, prefix, old, suffix), B.length(R.Transaction, prefix), value) == scope(w, prefix, value, suffix) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Equal.cong(List<&2, R.Transaction>, R.World, xs => R.World.with_txArena(w, xs),
        List.set(&2, R.Transaction, B.append(R.Transaction, prefix, old <> suffix), B.length(R.Transaction, prefix), value),
        B.append(R.Transaction, prefix, value <> suffix), Arena.setPrefix(R.Transaction, prefix, old, suffix, value))

# Later allocated slot beyond an earlier one; structural indices guarantee
# distinctness without a guessed numeric bound or a resolver premise.
def later(+prefix: List<&2, R.Transaction>, +gap: List<&2, R.Transaction>) -> Nat:
  Nat.add(B.length(R.Transaction, prefix), 1n+B.length(R.Transaction, gap))

def getLater(+prefix: List<&2, R.Transaction>, +left: R.Transaction, +gap: List<&2, R.Transaction>, +right: R.Transaction, +suffix: List<&2, R.Transaction>, +fallback: R.Transaction) ->
  {B.get(R.Transaction, B.append(R.Transaction, prefix, left <> B.append(R.Transaction, gap, right <> suffix)), later(prefix, gap), fallback) == right : R.Transaction}:
  match prefix:
    case Nil{}:
      Arena.getPrefix(R.Transaction, gap, right, suffix, fallback)
    case head <> tail:
      getLater(tail, left, gap, right, suffix, fallback)

def setLater(+prefix: List<&2, R.Transaction>, +left: R.Transaction, +gap: List<&2, R.Transaction>, +right: R.Transaction, +suffix: List<&2, R.Transaction>, +value: R.Transaction) ->
  {List.set(&2, R.Transaction, B.append(R.Transaction, prefix, left <> B.append(R.Transaction, gap, right <> suffix)), later(prefix, gap), value)
    == B.append(R.Transaction, prefix, left <> B.append(R.Transaction, gap, value <> suffix)) : List<&2, R.Transaction>}:
  match prefix:
    case Nil{}:
      Equal.cong(List<&2, R.Transaction>, List<&2, R.Transaction>, xs => left <> xs,
        List.set(&2, R.Transaction, B.append(R.Transaction, gap, right <> suffix), B.length(R.Transaction, gap), value),
        B.append(R.Transaction, gap, value <> suffix), Arena.setPrefix(R.Transaction, gap, right, suffix, value))
    case +head <> +tail:
      Equal.cong(List<&2, R.Transaction>, List<&2, R.Transaction>, xs => head <> xs,
        List.set(&2, R.Transaction, B.append(R.Transaction, tail, left <> B.append(R.Transaction, gap, right <> suffix)), later(tail, gap), value),
        B.append(R.Transaction, tail, left <> B.append(R.Transaction, gap, value <> suffix)), setLater(tail, left, gap, right, suffix, value))

def different(+index: Nat, +gap: Nat) -> {Nat.is_eq(index, Nat.add(index, 1n+gap)) == False{} : Bool}:
  match index:
    case 0n:
      {==}
    case 1n+p:
      different(p, gap)

def differentReverse(+index: Nat, +gap: Nat) -> {Nat.is_eq(Nat.add(index, 1n+gap), index) == False{} : Bool}:
  match index:
    case 0n:
      {==}
    case 1n+p:
      differentReverse(p, gap)
