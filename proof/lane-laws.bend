# Quantified identity/value boundaries for actual lane helpers. Not a lane
# seam, lifecycle, arbitrary-graph or source-language equivalence theorem.
import Base
import ../runtime/constants.bend as K
import ../representation/base.bend as B
import ../representation/records.bend as R
import ../runtime/lanes-state.bend as L
import ../runtime/truth-state.bend as T

def allocation(+w: R.World, parent: Nat) -> B.Bundle<R.World, Nat>:
  +id = B.length(R.Transaction, R.World.txArena(w))
  +tx = {R.Transaction{[], [], [], [], 0n, parent, True{}, 0n, 0n, False{}, 0n, False{}, False{}, R.NoIds{}} : R.Transaction}
  +state = R.World.laneState(w)
  +w = R.World.with_txArena(w, B.append(R.Transaction, R.World.txArena(w), [tx]))
  B.Bundle{R.World.with_laneState(w, R.LaneState.with_live(state, B.append(Nat, R.LaneState.live(state), [id]))), id}

def new_contract(+w: R.World, +parent: Nat) ->
  {L.newLane(w, parent) == allocation(w, parent) : B.Bundle<R.World, Nat>}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      {==}

def cachedWorld(w: R.World, tx: R.Transaction, suffix: List<&2, R.Transaction>, cached: Nat) -> R.World:
  R.World.with_txArena(w, B.blank_transaction() <> R.Transaction.with_verdict(tx, 1n+cached) <> suffix)

def cached(+w: R.World, +tx: R.Transaction, +suffix: List<&2, R.Transaction>, +cached: Nat) ->
  {L.verdictLane(cachedWorld(w, tx, suffix, cached), 1n) == B.Bundle{cachedWorld(w, tx, suffix, cached), 1n+cached} : B.Bundle<R.World, Nat>}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match tx:
        case R.Transaction{+tx_nodes, +tx_renderQueue, +tx_userQueue, +tx_reruns, +tx_into, +tx_parent, +tx_lane, +tx_verdict, +tx_open, +tx_acted, +tx_links, +tx_shown, +tx_held, +tx_marks}:
          {==}

def linkedWorld(w: R.World, a: R.Transaction, b: R.Transaction, suffix: List<&2, R.Transaction>, +group: Nat) -> R.World:
  R.World.with_txArena(w, B.blank_transaction() <> R.Transaction.with_links(a, 1n+group) <> R.Transaction.with_links(b, 1n+group) <> suffix)

def sameNat(+n: Nat) -> {Nat.is_eq(n, n) == True{} : Bool}:
  match n:
    case 0n:
      {==}
    case 1n+p:
      sameNat(p)

def shared(+w: R.World, +a: R.Transaction, +b: R.Transaction, +suffix: List<&2, R.Transaction>, +group: Nat) ->
  {L.sameLane(linkedWorld(w, a, b, suffix, group), 1n, 2n) == True{} : Bool}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match a:
        case R.Transaction{+a_nodes, +a_renderQueue, +a_userQueue, +a_reruns, +a_into, +a_parent, +a_lane, +a_verdict, +a_open, +a_acted, +a_links, +a_shown, +a_held, +a_marks}:
          match b:
            case R.Transaction{+b_nodes, +b_renderQueue, +b_userQueue, +b_reruns, +b_into, +b_parent, +b_lane, +b_verdict, +b_open, +b_acted, +b_links, +b_shown, +b_held, +b_marks}:
              sameNat(group)

def stagedWorld(w: R.World, node: R.Node, suffix: List<&2, R.Node>, value: R.Value) -> R.World:
  R.World.with_nodes(w, B.blank_node() <> R.Node.with_config(R.Node.with_pending(node, R.Present{value}), 0) <> suffix)

def staged(+w: R.World, +node: R.Node, +suffix: List<&2, R.Node>, +value: R.Value) ->
  {T.laneValueOf(stagedWorld(w, node, suffix, value), 1n) == value : R.Value}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match node:
        case R.Node{+node_kind, +node_value, +node_pending, +node_equals, +node_config, +node_flags, +node_status, +node_time, +node_notified, +node_deps, +node_depsTail, +node_depGen, +node_subs, +node_subsTail, +node_height, +node_nextHeap, +node_prevHeap, +node_parent, +node_firstChild, +node_nextSibling, +node_prevSibling, +node_expr, +node_modified, +node_prevValue, +node_target, +node_loading, +node_x, +node_parentComputed, +node_scope, +node_childCount, +node_disposal, +node_cleanup, +node_effectProgram, +node_returnedCleanup, +node_errorProgram}:
          {==}

def guessWorld(+w: R.World, node: R.Node, extension: R.NodeExtension, nodes: List<&2, R.Node>, extensions: List<&2, R.NodeExtension>, pending: R.Slot, value: R.Value) -> R.World:
  +w = R.World.with_nodes(w, B.blank_node() <> R.Node.with_x(R.Node.with_config(R.Node.with_pending(node, pending), K.CONFIG_GUESS()), 1n) <> nodes)
  R.World.with_extensions(w, B.blank_extension() <> R.NodeExtension.with_lane(extension, R.Present{value}) <> extensions)

def guess(+w: R.World, +node: R.Node, +extension: R.NodeExtension, +nodes: List<&2, R.Node>, +extensions: List<&2, R.NodeExtension>, +pending: R.Slot, +value: R.Value) ->
  {T.laneValueOf(guessWorld(w, node, extension, nodes, extensions, pending, value), 1n) == value : R.Value}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match node:
        case R.Node{+node_kind, +node_value, +node_pending, +node_equals, +node_config, +node_flags, +node_status, +node_time, +node_notified, +node_deps, +node_depsTail, +node_depGen, +node_subs, +node_subsTail, +node_height, +node_nextHeap, +node_prevHeap, +node_parent, +node_firstChild, +node_nextSibling, +node_prevSibling, +node_expr, +node_modified, +node_prevValue, +node_target, +node_loading, +node_x, +node_parentComputed, +node_scope, +node_childCount, +node_disposal, +node_cleanup, +node_effectProgram, +node_returnedCleanup, +node_errorProgram}:
          match extension:
            case R.NodeExtension{+extension_inFlight, +extension_flightTeardown, +extension_error, +extension_blocked, +extension_pendingSources, +extension_unobserved, +extension_snapshotValue, +extension_pendingFirstChild, +extension_pendingDisposal, +extension_transaction, +extension_reask, +extension_flushed, +extension_flushedAt, +extension_q, +extension_lane, +extension_marks, +extension_shownError, +parkedFlight}:
              {==}
