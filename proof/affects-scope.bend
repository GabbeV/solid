# Scoped whole-World and list laws for the actual non-store declaration engine.
import Base
import ../runtime/affects-scope.bend as Scope
import ../runtime/constants.bend as K
import ../representation/records.bend as R
import ../representation/base.bend as B

def invalidNumber(+w: R.World, value: Nat) -> {Scope.affects(w, R.Number{value}) == w : R.World}:
  {==}

def pushNone(+node: Nat) -> {Scope.push(R.NoIds{}, node) == R.SomeIds{[node]} : R.OptionalIds}:
  {==}

def pushSome(+items: List<&2, Nat>, +node: Nat) -> {Scope.push(R.SomeIds{items}, node) == R.SomeIds{B.append(Nat, items, [node])} : R.OptionalIds}:
  {==}

def releaseEmpty(+w: R.World) -> {Scope.release(w, []) == w : R.World}:
  {==}

def releaseAbsent(+w: R.World, t: Nat) -> {Scope.releaseTransactionValue(w, t, R.NoIds{}) == w : R.World}:
  {==}

def flightAt(+w: R.World, +node: Nat, pending: Bool) -> B.Bundle<R.World, Bool>:
  B.choose(~B.Bundle<R.World, Bool>, pending, _ => B.Bundle{w, True{}},
    _ => B.choose(~B.Bundle<R.World, Bool>, B.has(R.Node.config(B.node(w, node)), K.CONFIG_SLOT_NODE()), _ => B.Bundle{R.World.with_fault(w, R.Unsupported{86n}), False{}}, _ => B.Bundle{w, False{}}))

def pendingShortCircuit(+w: R.World, +node: Nat, pending: {B.has(R.Node.status(B.node(w, node)), K.STATUS_PENDING()) == True{} : Bool}) -> {Scope.inFlight(w, node) == B.Bundle{w, True{}} : B.Bundle<R.World, Bool>}:
  Equal.cong(Bool, B.Bundle<R.World, Bool>, flag => flightAt(w, node, flag), B.has(R.Node.status(B.node(w, node)), K.STATUS_PENDING()), True{}, pending)

def ambientEmpty(+w: R.World, +parked: Nat) -> {Scope.releaseAmbient(R.World.with_ambientMarks(w, []), parked) == R.World.with_ambientMarks(w, []) : R.World}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks}:
      {==}
