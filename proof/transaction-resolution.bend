# Proof-side finite redirect paths. No resolver or scheduler is implemented here.
# The certificate names actual into fields; its structural length supplies fuel.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ./arena.bend as Arena

type Route<-w: R.World> is Data:
  Root{id: Nat, stopped: {R.Transaction.into(B.transaction(w, id)) == 0n : Nat}}
  Redirect{id: Nat, next: Nat, linked: {R.Transaction.into(B.transaction(w, id)) == 1n+next : Nat}, tail: Route<w>, attached: {origin(w, tail) == 1n+next : Nat}}

def origin(-w: R.World, path: Route<w>) -> Nat:
  match path:
    case Root{id, stopped}: id
    case Redirect{id, next, linked, tail, attached}: id

def terminal(-w: R.World, path: Route<w>) -> Nat:
  match path:
    case Root{id, stopped}: id
    case Redirect{id, next, linked, tail, attached}: terminal(w, tail)

def depth(-w: R.World, path: Route<w>) -> Nat:
  match path:
    case Root{id, stopped}: 0n
    case Redirect{id, next, linked, tail, attached}: 1n+depth(w, tail)

def stopped(+w: R.World, +id: Nat, +extra: Nat,
  known: {R.Transaction.into(B.transaction(w, id)) == 0n : Nat}) ->
  {X.resolveLoop(1n+extra, w, id) == B.Bundle{w, id} : B.Bundle<R.World, Nat>}:
  Equal.cong(Nat, B.Bundle<R.World, Nat>, into => B.choose(~B.Bundle<R.World, Nat>, Nat.is_eq(into, 0n), _ => B.Bundle{w, id}, _ => X.resolveLoop(extra, w, into)), R.Transaction.into(B.transaction(w, id)), 0n, known)

def redirect(+w: R.World, +id: Nat, +next: Nat, +fuel: Nat,
  known: {R.Transaction.into(B.transaction(w, id)) == 1n+next : Nat}) ->
  {X.resolveLoop(1n+fuel, w, id) == X.resolveLoop(fuel, w, 1n+next) : B.Bundle<R.World, Nat>}:
  Equal.cong(Nat, B.Bundle<R.World, Nat>, into => B.choose(~B.Bundle<R.World, Nat>, Nat.is_eq(into, 0n), _ => B.Bundle{w, id}, _ => X.resolveLoop(fuel, w, into)), R.Transaction.into(B.transaction(w, id)), 1n+next, known)

def resolves(+w: R.World, path: Route<w>, +extra: Nat) ->
  {X.resolveLoop(Nat.add(depth(w, path), 1n+extra), w, origin(w, path)) == B.Bundle{w, terminal(w, path)} : B.Bundle<R.World, Nat>}:
  match path:
    case Root{+id, known}:
      stopped(w, id, extra, known)
    case Redirect{+id, +next, known, +tail, attached}:
      +fuel = Nat.add(depth(w, tail), 1n+extra)
      Equal.trans(B.Bundle<R.World, Nat>, X.resolveLoop(1n+fuel, w, id), X.resolveLoop(fuel, w, 1n+next), B.Bundle{w, terminal(w, tail)}, redirect(w, id, next, fuel, known),
        Equal.trans(B.Bundle<R.World, Nat>, X.resolveLoop(fuel, w, 1n+next), X.resolveLoop(fuel, w, origin(w, tail)), B.Bundle{w, terminal(w, tail)},
          Equal.cong(Nat, B.Bundle<R.World, Nat>, n => X.resolveLoop(fuel, w, n), 1n+next, origin(w, tail), Equal.sym(Nat, origin(w, tail), 1n+next, attached)), resolves(w, tail, extra)))

# The public resolver's arena-derived bound is sufficient when it covers the
# certified path. This does not silently assume global arena well-formedness.
def public(+w: R.World, +path: Route<w>, +extra: Nat,
  room: {1n+B.length(R.Transaction, R.World.txArena(w)) == Nat.add(depth(w, path), 1n+extra) : Nat}) ->
  {X.resolveTx(w, origin(w, path)) == B.Bundle{w, terminal(w, path)} : B.Bundle<R.World, Nat>}:
  Equal.trans(B.Bundle<R.World, Nat>, X.resolveTx(w, origin(w, path)), X.resolveLoop(Nat.add(depth(w, path), 1n+extra), w, origin(w, path)), B.Bundle{w, terminal(w, path)},
    Equal.cong(Nat, B.Bundle<R.World, Nat>, fuel => X.resolveLoop(fuel, w, origin(w, path)), 1n+B.length(R.Transaction, R.World.txArena(w)), Nat.add(depth(w, path), 1n+extra), room), resolves(w, path, extra))

# Source merge's two resolution results are composed before the same-root guard.
def mergeSecond(+pair: B.Bundle<R.World, Nat>, t: Nat) -> R.World:
  X.mergeResolved(B.first(R.World, Nat, pair), t, B.second(R.World, Nat, pair))

def mergeFirst(+pair: B.Bundle<R.World, Nat>, f: Nat) -> R.World:
  mergeSecond(X.resolveTx(B.first(R.World, Nat, pair), f), B.second(R.World, Nat, pair))

def sameNat(+n: Nat) -> {Nat.is_eq(n, n) == True{} : Bool}:
  match n:
    case 0n: {==}
    case 1n+p: sameNat(p)

def sameRoot(+w: R.World, +root: Nat) -> {X.mergeResolved(w, root, root) == w : R.World}:
  Equal.cong(Bool, R.World, same => B.choose(~R.World, Bool.or(same, Bool.or(R.Transaction.lane(B.transaction(w, root)), R.Transaction.lane(B.transaction(w, root)))), _ => w,
    _ =>
      +from = B.transaction(w, root)
      +into = B.transaction(w, root)
      +next = B.store_transaction(w, root, R.Transaction.with_into(from, root))
      +into = R.Transaction.with_open(into, Nat.add(R.Transaction.open(into), R.Transaction.open(from)))
      +into = R.Transaction.with_acted(into, Bool.or(R.Transaction.acted(into), R.Transaction.acted(from)))
      +into = R.Transaction.with_nodes(into, B.append(Nat, R.Transaction.nodes(into), R.Transaction.nodes(from)))
      +into = R.Transaction.with_renderQueue(into, B.append(Nat, R.Transaction.renderQueue(into), R.Transaction.renderQueue(from)))
      +into = R.Transaction.with_userQueue(into, B.append(R.QueueEntry, R.Transaction.userQueue(into), R.Transaction.userQueue(from)))
      +into = R.Transaction.with_reruns(into, B.append(Nat, R.Transaction.reruns(into), R.Transaction.reruns(from)))
      +into = R.Transaction.with_marks(into, X.appendMarks(R.Transaction.marks(into), R.Transaction.marks(from)))
      +next = B.store_transaction(next, root, into)
      R.World.with_transactions(next, X.removeIdentity(R.World.transactions(next), root))), Nat.is_eq(root, root), True{}, sameNat(root))

def common(+w: R.World, +source: Nat, +target: Nat, +root: Nat,
  first: {X.resolveTx(w, source) == B.Bundle{w, root} : B.Bundle<R.World, Nat>},
  second: {X.resolveTx(w, target) == B.Bundle{w, root} : B.Bundle<R.World, Nat>}) ->
  {X.merge(w, source, target) == w : R.World}:
  Equal.trans(R.World, X.merge(w, source, target), mergeFirst(B.Bundle{w, root}, target), w,
    Equal.cong(B.Bundle<R.World, Nat>, R.World, pair => mergeFirst(pair, target), X.resolveTx(w, source), B.Bundle{w, root}, first),
    Equal.trans(R.World, mergeSecond(X.resolveTx(w, target), root), X.mergeResolved(w, root, root), w,
      Equal.cong(B.Bundle<R.World, Nat>, R.World, pair => mergeSecond(pair, root), X.resolveTx(w, target), B.Bundle{w, root}, second), sameRoot(w, root)))

# Actual allocation establishes a terminal route; the arena lens proves that
# the freshly appended record is the one found at the returned identity.
def freshInto(+w: R.World, +lane: Bool, +parent: Nat) ->
  {R.Transaction.into(B.transaction(B.first(R.World, Nat, X.newTransaction(w, lane, parent)), B.second(R.World, Nat, X.newTransaction(w, lane, parent)))) == 0n : Nat}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match lane:
        case False{}:
          Equal.cong(R.Transaction, Nat, t => R.Transaction.into(t), B.get(R.Transaction, B.append(R.Transaction, w_txArena, [R.Transaction{[], [], [], [], 0n, parent, False{}, 0n, 0n, False{}, 0n, False{}, False{}, R.NoIds{}}]), B.length(R.Transaction, w_txArena), B.blank_transaction()), R.Transaction{[], [], [], [], 0n, parent, False{}, 0n, 0n, False{}, 0n, False{}, False{}, R.NoIds{}}, Arena.getPrefix(R.Transaction, w_txArena, R.Transaction{[], [], [], [], 0n, parent, False{}, 0n, 0n, False{}, 0n, False{}, False{}, R.NoIds{}}, [], B.blank_transaction()))
        case True{}:
          Equal.cong(R.Transaction, Nat, t => R.Transaction.into(t), B.get(R.Transaction, B.append(R.Transaction, w_txArena, [R.Transaction{[], [], [], [], 0n, parent, True{}, 0n, 0n, False{}, 0n, False{}, False{}, R.NoIds{}}]), B.length(R.Transaction, w_txArena), B.blank_transaction()), R.Transaction{[], [], [], [], 0n, parent, True{}, 0n, 0n, False{}, 0n, False{}, False{}, R.NoIds{}}, Arena.getPrefix(R.Transaction, w_txArena, R.Transaction{[], [], [], [], 0n, parent, True{}, 0n, 0n, False{}, 0n, False{}, False{}, R.NoIds{}}, [], B.blank_transaction()))

def freshRoute(+w: R.World, +lane: Bool, +parent: Nat) -> Route<B.first(R.World, Nat, X.newTransaction(w, lane, parent))>:
  Root{B.second(R.World, Nat, X.newTransaction(w, lane, parent)), freshInto(w, lane, parent)}
