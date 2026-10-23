# Two allocated ordinary roots at arbitrary distinct positions, joining in
# either direction. Structural list splits supply real identities; no entire
# arena validity or source publication guarantee is assumed or established.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ./transaction-arena.bend as Arena
import ./transaction-merge-laws.bend as Old
import ./transaction-resolution.bend as Paths
import ./transaction-join.bend as Join

def scope(w: R.World, prefix: List<&2, R.Transaction>, left: R.Transaction, gap: List<&2, R.Transaction>, right: R.Transaction, suffix: List<&2, R.Transaction>) -> R.World:
  Arena.scope(w, B.blank_transaction() <> prefix, left, B.append(R.Transaction, gap, right <> suffix))

def leftId(prefix: List<&2, R.Transaction>) -> Nat:
  1n+B.length(R.Transaction, prefix)

def rightId(prefix: List<&2, R.Transaction>, gap: List<&2, R.Transaction>) -> Nat:
  1n+Arena.later(prefix, gap)

def sourceId(+prefix: List<&2, R.Transaction>, gap: List<&2, R.Transaction>, reverse: Bool) -> Nat:
  B.choose(~Nat, reverse, _ => rightId(prefix, gap), _ => leftId(prefix))

def targetId(+prefix: List<&2, R.Transaction>, gap: List<&2, R.Transaction>, reverse: Bool) -> Nat:
  B.choose(~Nat, reverse, _ => leftId(prefix), _ => rightId(prefix, gap))

def peekLeft(+w: R.World, +prefix: List<&2, R.Transaction>, +left: R.Transaction, +gap: List<&2, R.Transaction>, +right: R.Transaction, +suffix: List<&2, R.Transaction>) ->
  {B.transaction(scope(w, prefix, left, gap, right, suffix), leftId(prefix)) == left : R.Transaction}:
  Arena.peek(w, B.blank_transaction() <> prefix, left, B.append(R.Transaction, gap, right <> suffix))

def peekRight(+w: R.World, +prefix: List<&2, R.Transaction>, +left: R.Transaction, +gap: List<&2, R.Transaction>, +right: R.Transaction, +suffix: List<&2, R.Transaction>) ->
  {B.transaction(scope(w, prefix, left, gap, right, suffix), rightId(prefix, gap)) == right : R.Transaction}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Arena.getLater(B.blank_transaction() <> prefix, left, gap, right, suffix, B.blank_transaction())

def putLeft(+w: R.World, +prefix: List<&2, R.Transaction>, +left: R.Transaction, +gap: List<&2, R.Transaction>, +right: R.Transaction, +suffix: List<&2, R.Transaction>, +value: R.Transaction) ->
  {B.store_transaction(scope(w, prefix, left, gap, right, suffix), leftId(prefix), value) == scope(w, prefix, value, gap, right, suffix) : R.World}:
  Arena.store(w, B.blank_transaction() <> prefix, left, B.append(R.Transaction, gap, right <> suffix), value)

def putRight(+w: R.World, +prefix: List<&2, R.Transaction>, +left: R.Transaction, +gap: List<&2, R.Transaction>, +right: R.Transaction, +suffix: List<&2, R.Transaction>, +value: R.Transaction) ->
  {B.store_transaction(scope(w, prefix, left, gap, right, suffix), rightId(prefix, gap), value) == scope(w, prefix, left, gap, value, suffix) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Equal.cong(List<&2, R.Transaction>, R.World, xs => R.World.with_txArena(w, xs),
        List.set(&2, R.Transaction, B.append(R.Transaction, B.blank_transaction() <> prefix, left <> B.append(R.Transaction, gap, right <> suffix)), rightId(prefix, gap), value),
        B.append(R.Transaction, B.blank_transaction() <> prefix, left <> B.append(R.Transaction, gap, value <> suffix)), Arena.setLater(B.blank_transaction() <> prefix, left, gap, right, suffix, value))

def rootInto(+t: R.Transaction) -> {R.Transaction.into(Old.root(t)) == 0n : Nat}:
  match t:
    case R.Transaction{nodes, renderQueue, userQueue, reruns, into, parent, lane, verdict, open, acted, links, shown, held, marks}: {==}

def rootLane(+t: R.Transaction) -> {R.Transaction.lane(Old.root(t)) == False{} : Bool}:
  match t:
    case R.Transaction{nodes, renderQueue, userQueue, reruns, into, parent, lane, verdict, open, acted, links, shown, held, marks}: {==}

# Both source lookups really terminate, within their actual public budgets.
def leftResolution(+w: R.World, +prefix: List<&2, R.Transaction>, +left: R.Transaction, +gap: List<&2, R.Transaction>, +right: R.Transaction, +suffix: List<&2, R.Transaction>) ->
  {X.resolveTx(scope(w, prefix, Old.root(left), gap, Old.root(right), suffix), leftId(prefix)) == B.Bundle{scope(w, prefix, Old.root(left), gap, Old.root(right), suffix), leftId(prefix)} : B.Bundle<R.World, Nat>}:
  +start = scope(w, prefix, Old.root(left), gap, Old.root(right), suffix)
  Paths.stopped(start, leftId(prefix), B.length(R.Transaction, R.World.txArena(start)),
    Equal.trans(Nat, R.Transaction.into(B.transaction(start, leftId(prefix))), R.Transaction.into(Old.root(left)), 0n,
      Equal.cong(R.Transaction, Nat, t => R.Transaction.into(t), B.transaction(start, leftId(prefix)), Old.root(left), peekLeft(w, prefix, Old.root(left), gap, Old.root(right), suffix)), rootInto(left)))

def rightResolution(+w: R.World, +prefix: List<&2, R.Transaction>, +left: R.Transaction, +gap: List<&2, R.Transaction>, +right: R.Transaction, +suffix: List<&2, R.Transaction>) ->
  {X.resolveTx(scope(w, prefix, Old.root(left), gap, Old.root(right), suffix), rightId(prefix, gap)) == B.Bundle{scope(w, prefix, Old.root(left), gap, Old.root(right), suffix), rightId(prefix, gap)} : B.Bundle<R.World, Nat>}:
  +start = scope(w, prefix, Old.root(left), gap, Old.root(right), suffix)
  Paths.stopped(start, rightId(prefix, gap), B.length(R.Transaction, R.World.txArena(start)),
    Equal.trans(Nat, R.Transaction.into(B.transaction(start, rightId(prefix, gap))), R.Transaction.into(Old.root(right)), 0n,
      Equal.cong(R.Transaction, Nat, t => R.Transaction.into(t), B.transaction(start, rightId(prefix, gap)), Old.root(right), peekRight(w, prefix, Old.root(left), gap, Old.root(right), suffix)), rootInto(right)))

def retire(+w: R.World, id: Nat) -> R.World:
  R.World.with_transactions(w, X.removeIdentity(R.World.transactions(w), id))

def after(+w: R.World, +prefix: List<&2, R.Transaction>, +left: R.Transaction, +gap: List<&2, R.Transaction>, +right: R.Transaction, +suffix: List<&2, R.Transaction>, +reverse: Bool) -> R.World:
  retire(B.choose(~R.World, reverse,
    _ => scope(w, prefix, Join.transfer(Old.root(right), Old.root(left)), gap, R.Transaction.with_into(Old.root(right), leftId(prefix)), suffix),
    _ => scope(w, prefix, R.Transaction.with_into(Old.root(left), rightId(prefix, gap)), gap, Join.transfer(Old.root(left), Old.root(right)), suffix)), sourceId(prefix, gap, reverse))

def orderedStores(+w: R.World, +prefix: List<&2, R.Transaction>, +left: R.Transaction, +gap: List<&2, R.Transaction>, +right: R.Transaction, +suffix: List<&2, R.Transaction>, +reverse: Bool) ->
  {Join.joined(scope(w, prefix, Old.root(left), gap, Old.root(right), suffix), sourceId(prefix, gap, reverse), targetId(prefix, gap, reverse), B.choose(~R.Transaction, reverse, _ => Old.root(right), _ => Old.root(left)), B.choose(~R.Transaction, reverse, _ => Old.root(left), _ => Old.root(right))) == after(w, prefix, left, gap, right, suffix, reverse) : R.World}:
  match reverse:
    case False{}:
      +start = scope(w, prefix, Old.root(left), gap, Old.root(right), suffix)
      +redirect = R.Transaction.with_into(Old.root(left), rightId(prefix, gap))
      +transfer = Join.transfer(Old.root(left), Old.root(right))
      Equal.cong(R.World, R.World, world => retire(world, leftId(prefix)),
        B.store_transaction(B.store_transaction(start, leftId(prefix), redirect), rightId(prefix, gap), transfer),
        scope(w, prefix, redirect, gap, transfer, suffix),
        Equal.trans(R.World, B.store_transaction(B.store_transaction(start, leftId(prefix), redirect), rightId(prefix, gap), transfer), B.store_transaction(scope(w, prefix, redirect, gap, Old.root(right), suffix), rightId(prefix, gap), transfer), scope(w, prefix, redirect, gap, transfer, suffix),
          Equal.cong(R.World, R.World, world => B.store_transaction(world, rightId(prefix, gap), transfer), B.store_transaction(start, leftId(prefix), redirect), scope(w, prefix, redirect, gap, Old.root(right), suffix), putLeft(w, prefix, Old.root(left), gap, Old.root(right), suffix, redirect)), putRight(w, prefix, redirect, gap, Old.root(right), suffix, transfer)))
    case True{}:
      +start = scope(w, prefix, Old.root(left), gap, Old.root(right), suffix)
      +redirect = R.Transaction.with_into(Old.root(right), leftId(prefix))
      +transfer = Join.transfer(Old.root(right), Old.root(left))
      Equal.cong(R.World, R.World, world => retire(world, rightId(prefix, gap)),
        B.store_transaction(B.store_transaction(start, rightId(prefix, gap), redirect), leftId(prefix), transfer),
        scope(w, prefix, transfer, gap, redirect, suffix),
        Equal.trans(R.World, B.store_transaction(B.store_transaction(start, rightId(prefix, gap), redirect), leftId(prefix), transfer), B.store_transaction(scope(w, prefix, Old.root(left), gap, redirect, suffix), leftId(prefix), transfer), scope(w, prefix, transfer, gap, redirect, suffix),
          Equal.cong(R.World, R.World, world => B.store_transaction(world, leftId(prefix), transfer), B.store_transaction(start, rightId(prefix, gap), redirect), scope(w, prefix, Old.root(left), gap, redirect, suffix), putRight(w, prefix, Old.root(left), gap, Old.root(right), suffix, redirect)), putLeft(w, prefix, Old.root(left), gap, redirect, suffix, transfer)))

def merge(+w: R.World, +prefix: List<&2, R.Transaction>, +left: R.Transaction, +gap: List<&2, R.Transaction>, +right: R.Transaction, +suffix: List<&2, R.Transaction>, +reverse: Bool) ->
  {X.merge(scope(w, prefix, Old.root(left), gap, Old.root(right), suffix), sourceId(prefix, gap, reverse), targetId(prefix, gap, reverse)) == after(w, prefix, left, gap, right, suffix, reverse) : R.World}:
  match reverse:
    case False{}:
      +start = scope(w, prefix, Old.root(left), gap, Old.root(right), suffix)
      Equal.trans(R.World, X.merge(start, leftId(prefix), rightId(prefix, gap)), Join.joined(start, leftId(prefix), rightId(prefix, gap), Old.root(left), Old.root(right)), after(w, prefix, left, gap, right, suffix, False{}),
        Join.public(start, leftId(prefix), rightId(prefix, gap), leftId(prefix), rightId(prefix, gap), Old.root(left), Old.root(right), leftResolution(w, prefix, left, gap, right, suffix), rightResolution(w, prefix, left, gap, right, suffix), peekLeft(w, prefix, Old.root(left), gap, Old.root(right), suffix), peekRight(w, prefix, Old.root(left), gap, Old.root(right), suffix), Arena.different(1n+B.length(R.Transaction, prefix), B.length(R.Transaction, gap)), rootLane(left), rootLane(right)), orderedStores(w, prefix, left, gap, right, suffix, False{}))
    case True{}:
      +start = scope(w, prefix, Old.root(left), gap, Old.root(right), suffix)
      Equal.trans(R.World, X.merge(start, rightId(prefix, gap), leftId(prefix)), Join.joined(start, rightId(prefix, gap), leftId(prefix), Old.root(right), Old.root(left)), after(w, prefix, left, gap, right, suffix, True{}),
        Join.public(start, rightId(prefix, gap), leftId(prefix), rightId(prefix, gap), leftId(prefix), Old.root(right), Old.root(left), rightResolution(w, prefix, left, gap, right, suffix), leftResolution(w, prefix, left, gap, right, suffix), peekRight(w, prefix, Old.root(left), gap, Old.root(right), suffix), peekLeft(w, prefix, Old.root(left), gap, Old.root(right), suffix), Arena.differentReverse(1n+B.length(R.Transaction, prefix), B.length(R.Transaction, gap)), rootLane(right), rootLane(left)), orderedStores(w, prefix, left, gap, right, suffix, True{}))

# Reading a retired-list update observes the same arena; no hidden source ID
# is rewritten by removing it from the live list.
def lookupRetired(+w: R.World, +retired: Nat, +id: Nat) ->
  {B.transaction(retire(w, retired), id) == B.transaction(w, id) : R.Transaction}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def sourceRecord(+left: R.Transaction, +right: R.Transaction, +target: Nat, reverse: Bool) -> R.Transaction:
  R.Transaction.with_into(B.choose(~R.Transaction, reverse, _ => Old.root(right), _ => Old.root(left)), target)

def targetRecord(+left: R.Transaction, +right: R.Transaction, reverse: Bool) -> R.Transaction:
  B.choose(~R.Transaction, reverse, _ => Join.transfer(Old.root(right), Old.root(left)), _ => Join.transfer(Old.root(left), Old.root(right)))

def sourceAfter(+w: R.World, +prefix: List<&2, R.Transaction>, +left: R.Transaction, +gap: List<&2, R.Transaction>, +right: R.Transaction, +suffix: List<&2, R.Transaction>, +reverse: Bool) ->
  {B.transaction(after(w, prefix, left, gap, right, suffix, reverse), sourceId(prefix, gap, reverse)) == sourceRecord(left, right, targetId(prefix, gap, reverse), reverse) : R.Transaction}:
  match reverse:
    case False{}:
      +from = R.Transaction.with_into(Old.root(left), rightId(prefix, gap))
      +to = Join.transfer(Old.root(left), Old.root(right))
      +changed = scope(w, prefix, from, gap, to, suffix)
      Equal.trans(R.Transaction, B.transaction(retire(changed, leftId(prefix)), leftId(prefix)), B.transaction(changed, leftId(prefix)), from, lookupRetired(changed, leftId(prefix), leftId(prefix)), peekLeft(w, prefix, from, gap, to, suffix))
    case True{}:
      +from = R.Transaction.with_into(Old.root(right), leftId(prefix))
      +to = Join.transfer(Old.root(right), Old.root(left))
      +changed = scope(w, prefix, to, gap, from, suffix)
      Equal.trans(R.Transaction, B.transaction(retire(changed, rightId(prefix, gap)), rightId(prefix, gap)), B.transaction(changed, rightId(prefix, gap)), from, lookupRetired(changed, rightId(prefix, gap), rightId(prefix, gap)), peekRight(w, prefix, to, gap, from, suffix))

def targetAfter(+w: R.World, +prefix: List<&2, R.Transaction>, +left: R.Transaction, +gap: List<&2, R.Transaction>, +right: R.Transaction, +suffix: List<&2, R.Transaction>, +reverse: Bool) ->
  {B.transaction(after(w, prefix, left, gap, right, suffix, reverse), targetId(prefix, gap, reverse)) == targetRecord(left, right, reverse) : R.Transaction}:
  match reverse:
    case False{}:
      +from = R.Transaction.with_into(Old.root(left), rightId(prefix, gap))
      +to = Join.transfer(Old.root(left), Old.root(right))
      +changed = scope(w, prefix, from, gap, to, suffix)
      Equal.trans(R.Transaction, B.transaction(retire(changed, leftId(prefix)), rightId(prefix, gap)), B.transaction(changed, rightId(prefix, gap)), to, lookupRetired(changed, leftId(prefix), rightId(prefix, gap)), peekRight(w, prefix, from, gap, to, suffix))
    case True{}:
      +from = R.Transaction.with_into(Old.root(right), leftId(prefix))
      +to = Join.transfer(Old.root(right), Old.root(left))
      +changed = scope(w, prefix, to, gap, from, suffix)
      Equal.trans(R.Transaction, B.transaction(retire(changed, rightId(prefix, gap)), leftId(prefix)), B.transaction(changed, leftId(prefix)), to, lookupRetired(changed, rightId(prefix, gap), leftId(prefix)), peekLeft(w, prefix, to, gap, from, suffix))

def transferInto(+source: R.Transaction, +target: R.Transaction) ->
  {R.Transaction.into(Join.transfer(source, target)) == R.Transaction.into(target) : Nat}:
  match target:
    case R.Transaction{nodes, renderQueue, userQueue, reruns, into, parent, lane, verdict, open, acted, links, shown, held, marks}: {==}

def redirectInto(+source: R.Transaction, +target: Nat) ->
  {R.Transaction.into(R.Transaction.with_into(source, target)) == target : Nat}:
  match source:
    case R.Transaction{nodes, renderQueue, userQueue, reruns, into, parent, lane, verdict, open, acted, links, shown, held, marks}: {==}

def targetStopped(+left: R.Transaction, +right: R.Transaction, +reverse: Bool) ->
  {R.Transaction.into(targetRecord(left, right, reverse)) == 0n : Nat}:
  match reverse:
    case False{}:
      Equal.trans(Nat, R.Transaction.into(Join.transfer(Old.root(left), Old.root(right))), R.Transaction.into(Old.root(right)), 0n, transferInto(Old.root(left), Old.root(right)), rootInto(right))
    case True{}:
      Equal.trans(Nat, R.Transaction.into(Join.transfer(Old.root(right), Old.root(left))), R.Transaction.into(Old.root(left)), 0n, transferInto(Old.root(right), Old.root(left)), rootInto(left))

def merged(+w: R.World, +prefix: List<&2, R.Transaction>, left: R.Transaction, +gap: List<&2, R.Transaction>, right: R.Transaction, suffix: List<&2, R.Transaction>, +reverse: Bool) -> R.World:
  X.merge(scope(w, prefix, Old.root(left), gap, Old.root(right), suffix), sourceId(prefix, gap, reverse), targetId(prefix, gap, reverse))

def redirected(+w: R.World, +prefix: List<&2, R.Transaction>, +left: R.Transaction, +gap: List<&2, R.Transaction>, +right: R.Transaction, +suffix: List<&2, R.Transaction>, +reverse: Bool) ->
  {R.Transaction.into(B.transaction(merged(w, prefix, left, gap, right, suffix, reverse), sourceId(prefix, gap, reverse))) == targetId(prefix, gap, reverse) : Nat}:
  +next = merged(w, prefix, left, gap, right, suffix, reverse)
  +expected = after(w, prefix, left, gap, right, suffix, reverse)
  +from = sourceRecord(left, right, targetId(prefix, gap, reverse), reverse)
  Equal.trans(Nat, R.Transaction.into(B.transaction(next, sourceId(prefix, gap, reverse))), R.Transaction.into(from), targetId(prefix, gap, reverse),
    Equal.cong(R.Transaction, Nat, t => R.Transaction.into(t), B.transaction(next, sourceId(prefix, gap, reverse)), from,
      Equal.trans(R.Transaction, B.transaction(next, sourceId(prefix, gap, reverse)), B.transaction(expected, sourceId(prefix, gap, reverse)), from,
        Equal.cong(R.World, R.Transaction, world => B.transaction(world, sourceId(prefix, gap, reverse)), next, expected, merge(w, prefix, left, gap, right, suffix, reverse)), sourceAfter(w, prefix, left, gap, right, suffix, reverse))),
    redirectInto(B.choose(~R.Transaction, reverse, _ => Old.root(right), _ => Old.root(left)), targetId(prefix, gap, reverse)))

def stopped(+w: R.World, +prefix: List<&2, R.Transaction>, +left: R.Transaction, +gap: List<&2, R.Transaction>, +right: R.Transaction, +suffix: List<&2, R.Transaction>, +reverse: Bool) ->
  {R.Transaction.into(B.transaction(merged(w, prefix, left, gap, right, suffix, reverse), targetId(prefix, gap, reverse))) == 0n : Nat}:
  +next = merged(w, prefix, left, gap, right, suffix, reverse)
  +expected = after(w, prefix, left, gap, right, suffix, reverse)
  +to = targetRecord(left, right, reverse)
  Equal.trans(Nat, R.Transaction.into(B.transaction(next, targetId(prefix, gap, reverse))), R.Transaction.into(to), 0n,
    Equal.cong(R.Transaction, Nat, t => R.Transaction.into(t), B.transaction(next, targetId(prefix, gap, reverse)), to,
      Equal.trans(R.Transaction, B.transaction(next, targetId(prefix, gap, reverse)), B.transaction(expected, targetId(prefix, gap, reverse)), to,
        Equal.cong(R.World, R.Transaction, world => B.transaction(world, targetId(prefix, gap, reverse)), next, expected, merge(w, prefix, left, gap, right, suffix, reverse)), targetAfter(w, prefix, left, gap, right, suffix, reverse))), targetStopped(left, right, reverse))

def targetPred(+prefix: List<&2, R.Transaction>, gap: List<&2, R.Transaction>, reverse: Bool) -> Nat:
  B.choose(~Nat, reverse, _ => B.length(R.Transaction, prefix), _ => Arena.later(prefix, gap))

def targetPositive(+prefix: List<&2, R.Transaction>, +gap: List<&2, R.Transaction>, +reverse: Bool) ->
  {targetId(prefix, gap, reverse) == 1n+targetPred(prefix, gap, reverse) : Nat}:
  match reverse:
    case False{}: {==}
    case True{}: {==}

# A genuine joined-source certificate, constructed from the actual merge. No
# resolution equation or fuel sufficiency is assumed by this construction.
def route(+w: R.World, +prefix: List<&2, R.Transaction>, +left: R.Transaction, +gap: List<&2, R.Transaction>, +right: R.Transaction, +suffix: List<&2, R.Transaction>, +reverse: Bool) -> Paths.Route<merged(w, prefix, left, gap, right, suffix, reverse)>:
  +next = merged(w, prefix, left, gap, right, suffix, reverse)
  +source = sourceId(prefix, gap, reverse)
  +target = targetId(prefix, gap, reverse)
  +pred = targetPred(prefix, gap, reverse)
  Paths.Redirect{source, pred,
    Equal.trans(Nat, R.Transaction.into(B.transaction(next, source)), target, 1n+pred, redirected(w, prefix, left, gap, right, suffix, reverse), targetPositive(prefix, gap, reverse)),
    Paths.Root{target, stopped(w, prefix, left, gap, right, suffix, reverse)}, targetPositive(prefix, gap, reverse)}

# Arena length has a structural first slot even after the join. One redirect
# therefore fits the real public resolver budget, independent of prefix/gap size.
def tail(xs: List<&2, R.Transaction>) -> List<&2, R.Transaction>:
  match xs:
    case Nil{}: []
    case head <> rest: rest

def roomAfter(+w: R.World, +prefix: List<&2, R.Transaction>, +left: R.Transaction, +gap: List<&2, R.Transaction>, +right: R.Transaction, +suffix: List<&2, R.Transaction>, +reverse: Bool) ->
  {1n+B.length(R.Transaction, R.World.txArena(after(w, prefix, left, gap, right, suffix, reverse))) == 2n+B.length(R.Transaction, tail(R.World.txArena(after(w, prefix, left, gap, right, suffix, reverse)))) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match reverse:
        case False{}: {==}
        case True{}: {==}

def room(+w: R.World, +prefix: List<&2, R.Transaction>, +left: R.Transaction, +gap: List<&2, R.Transaction>, +right: R.Transaction, +suffix: List<&2, R.Transaction>, +reverse: Bool) ->
  {1n+B.length(R.Transaction, R.World.txArena(merged(w, prefix, left, gap, right, suffix, reverse))) == 2n+B.length(R.Transaction, tail(R.World.txArena(merged(w, prefix, left, gap, right, suffix, reverse)))) : Nat}:
  +next = merged(w, prefix, left, gap, right, suffix, reverse)
  +expected = after(w, prefix, left, gap, right, suffix, reverse)
  Equal.trans(Nat, 1n+B.length(R.Transaction, R.World.txArena(next)), 1n+B.length(R.Transaction, R.World.txArena(expected)), 2n+B.length(R.Transaction, tail(R.World.txArena(next))),
    Equal.cong(R.World, Nat, world => 1n+B.length(R.Transaction, R.World.txArena(world)), next, expected, merge(w, prefix, left, gap, right, suffix, reverse)),
    Equal.trans(Nat, 1n+B.length(R.Transaction, R.World.txArena(expected)), 2n+B.length(R.Transaction, tail(R.World.txArena(expected))), 2n+B.length(R.Transaction, tail(R.World.txArena(next))), roomAfter(w, prefix, left, gap, right, suffix, reverse),
      Equal.cong(R.World, Nat, world => 2n+B.length(R.Transaction, tail(R.World.txArena(world))), expected, next, Equal.sym(R.World, next, expected, merge(w, prefix, left, gap, right, suffix, reverse)))))

def sourceResolves(+w: R.World, +prefix: List<&2, R.Transaction>, +left: R.Transaction, +gap: List<&2, R.Transaction>, +right: R.Transaction, +suffix: List<&2, R.Transaction>, +reverse: Bool) ->
  {X.resolveTx(merged(w, prefix, left, gap, right, suffix, reverse), sourceId(prefix, gap, reverse)) == B.Bundle{merged(w, prefix, left, gap, right, suffix, reverse), targetId(prefix, gap, reverse)} : B.Bundle<R.World, Nat>}:
  +next = merged(w, prefix, left, gap, right, suffix, reverse)
  +source = sourceId(prefix, gap, reverse)
  +target = targetId(prefix, gap, reverse)
  +pred = targetPred(prefix, gap, reverse)
  +extra = B.length(R.Transaction, tail(R.World.txArena(next)))
  Equal.trans(B.Bundle<R.World, Nat>, X.resolveTx(next, source), X.resolveLoop(2n+extra, next, source), B.Bundle{next, target},
    Equal.cong(Nat, B.Bundle<R.World, Nat>, fuel => X.resolveLoop(fuel, next, source), 1n+B.length(R.Transaction, R.World.txArena(next)), 2n+extra, room(w, prefix, left, gap, right, suffix, reverse)),
    Equal.trans(B.Bundle<R.World, Nat>, X.resolveLoop(2n+extra, next, source), X.resolveLoop(1n+extra, next, 1n+pred), B.Bundle{next, target},
      Paths.redirect(next, source, pred, 1n+extra, Equal.trans(Nat, R.Transaction.into(B.transaction(next, source)), target, 1n+pred, redirected(w, prefix, left, gap, right, suffix, reverse), targetPositive(prefix, gap, reverse))),
      Equal.trans(B.Bundle<R.World, Nat>, X.resolveLoop(1n+extra, next, 1n+pred), X.resolveLoop(1n+extra, next, target), B.Bundle{next, target},
        Equal.cong(Nat, B.Bundle<R.World, Nat>, id => X.resolveLoop(1n+extra, next, id), 1n+pred, target, Equal.sym(Nat, target, 1n+pred, targetPositive(prefix, gap, reverse))), Paths.stopped(next, target, extra, stopped(w, prefix, left, gap, right, suffix, reverse)))))

def targetResolves(+w: R.World, +prefix: List<&2, R.Transaction>, +left: R.Transaction, +gap: List<&2, R.Transaction>, +right: R.Transaction, +suffix: List<&2, R.Transaction>, +reverse: Bool) ->
  {X.resolveTx(merged(w, prefix, left, gap, right, suffix, reverse), targetId(prefix, gap, reverse)) == B.Bundle{merged(w, prefix, left, gap, right, suffix, reverse), targetId(prefix, gap, reverse)} : B.Bundle<R.World, Nat>}:
  +next = merged(w, prefix, left, gap, right, suffix, reverse)
  Paths.stopped(next, targetId(prefix, gap, reverse), B.length(R.Transaction, R.World.txArena(next)), stopped(w, prefix, left, gap, right, suffix, reverse))

def rootOpen(+t: R.Transaction) -> {R.Transaction.open(Old.root(t)) == R.Transaction.open(t) : Nat}:
  match t:
    case R.Transaction{nodes, renderQueue, userQueue, reruns, into, parent, lane, verdict, open, acted, links, shown, held, marks}: {==}

def transferOpen(+source: R.Transaction, +target: R.Transaction) ->
  {R.Transaction.open(Join.transfer(source, target)) == Nat.add(R.Transaction.open(target), R.Transaction.open(source)) : Nat}:
  match target:
    case R.Transaction{nodes, renderQueue, userQueue, reruns, into, parent, lane, verdict, open, acted, links, shown, held, marks}: {==}

def obligations(+left: R.Transaction, +right: R.Transaction, reverse: Bool) -> Nat:
  B.choose(~Nat, reverse, _ => Nat.add(R.Transaction.open(left), R.Transaction.open(right)), _ => Nat.add(R.Transaction.open(right), R.Transaction.open(left)))

def targetCount(+left: R.Transaction, +right: R.Transaction, +reverse: Bool) ->
  {R.Transaction.open(targetRecord(left, right, reverse)) == obligations(left, right, reverse) : Nat}:
  match left:
    case R.Transaction{+ln, +lr, +lu, +lrr, +li, +lp, +ll, +lv, +lo, +la, +lk, +ls, +lh, +lm}:
      match right:
        case R.Transaction{+rn, +rr, +ru, +rrr, +ri, +rp, +rl, +rv, +ro, +ra, +rk, +rs, +rh, +rm}:
          match reverse:
            case False{}: {==}
            case True{}: {==}

def count(+w: R.World, +prefix: List<&2, R.Transaction>, +left: R.Transaction, +gap: List<&2, R.Transaction>, +right: R.Transaction, +suffix: List<&2, R.Transaction>, +reverse: Bool) ->
  {R.Transaction.open(B.transaction(merged(w, prefix, left, gap, right, suffix, reverse), targetId(prefix, gap, reverse))) == obligations(left, right, reverse) : Nat}:
  +next = merged(w, prefix, left, gap, right, suffix, reverse)
  +expected = after(w, prefix, left, gap, right, suffix, reverse)
  +to = targetRecord(left, right, reverse)
  Equal.trans(Nat, R.Transaction.open(B.transaction(next, targetId(prefix, gap, reverse))), R.Transaction.open(to), obligations(left, right, reverse),
    Equal.cong(R.Transaction, Nat, t => R.Transaction.open(t), B.transaction(next, targetId(prefix, gap, reverse)), to,
      Equal.trans(R.Transaction, B.transaction(next, targetId(prefix, gap, reverse)), B.transaction(expected, targetId(prefix, gap, reverse)), to,
        Equal.cong(R.World, R.Transaction, world => B.transaction(world, targetId(prefix, gap, reverse)), next, expected, merge(w, prefix, left, gap, right, suffix, reverse)), targetAfter(w, prefix, left, gap, right, suffix, reverse))), targetCount(left, right, reverse))

def afterActions(+w: R.World, +prefix: List<&2, R.Transaction>, +left: R.Transaction, +gap: List<&2, R.Transaction>, +right: R.Transaction, +suffix: List<&2, R.Transaction>, +reverse: Bool) ->
  {R.World.actions(after(w, prefix, left, gap, right, suffix, reverse)) == R.World.actions(w) : List<&2, R.ActionState>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match reverse:
        case False{}: {==}
        case True{}: {==}

def actionFrame(+w: R.World, +prefix: List<&2, R.Transaction>, +left: R.Transaction, +gap: List<&2, R.Transaction>, +right: R.Transaction, +suffix: List<&2, R.Transaction>, +reverse: Bool) ->
  {R.World.actions(merged(w, prefix, left, gap, right, suffix, reverse)) == R.World.actions(w) : List<&2, R.ActionState>}:
  Equal.trans(List<&2, R.ActionState>, R.World.actions(merged(w, prefix, left, gap, right, suffix, reverse)), R.World.actions(after(w, prefix, left, gap, right, suffix, reverse)), R.World.actions(w),
    Equal.cong(R.World, List<&2, R.ActionState>, world => R.World.actions(world), merged(w, prefix, left, gap, right, suffix, reverse), after(w, prefix, left, gap, right, suffix, reverse), merge(w, prefix, left, gap, right, suffix, reverse)), afterActions(w, prefix, left, gap, right, suffix, reverse))
