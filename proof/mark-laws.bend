# Quantified properties of the actual mark walk and balanced count operations.
# Slot one is an existing node/extension; their fields, remaining arenas and
# surrounding World are arbitrary. No alternate mark traversal is supplied.
import Base
import ../representation/base.bend as B
import ../representation/records.bend as R
import ../runtime/affects-marks.bend as Marks

def scope(+w: R.World, node: R.Node, extension: R.NodeExtension, nodes: List<&2, R.Node>, extensions: List<&2, R.NodeExtension>, count: Nat, active: Nat) -> R.World:
  +w = R.World.with_nodes(w, B.blank_node() <> R.Node.with_x(node, 1n) <> nodes)
  +w = R.World.with_extensions(w, B.blank_extension() <> R.NodeExtension.with_marks(extension, count) <> extensions)
  R.World.with_activeMarks(w, active)

def direct(+w: R.World, +node: R.Node, +extension: R.NodeExtension, +nodes: List<&2, R.Node>, +extensions: List<&2, R.NodeExtension>, +count: Nat, +active: Nat, +fuel: Nat, +seen: List<&2, Nat>, +rest: List<&2, Marks.ProbeTask>) ->
  {Marks.probe(1n+fuel, scope(w, node, extension, nodes, extensions, 1n+count, active), Marks.ProbeNode{1n} <> rest, seen)
    == B.Bundle{scope(w, node, extension, nodes, extensions, 1n+count, active), True{}} : B.Bundle<R.World, Bool>}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match node:
        case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
          match extension:
            case R.NodeExtension{+x_inFlight, +x_flightTeardown, +x_error, +x_blocked, +x_pendingSources, +x_unobserved, +x_snapshotValue, +x_pendingFirstChild, +x_pendingDisposal, +x_transaction, +x_reask, +x_flushed, +x_flushedAt, +x_q, +x_lane, +x_marks, +x_shownError, +parkedFlight}:
              {==}

def increment(+w: R.World, +node: R.Node, +extension: R.NodeExtension, +nodes: List<&2, R.Node>, +extensions: List<&2, R.NodeExtension>, +count: Nat, +active: Nat) ->
  {Marks.mark(scope(w, node, extension, nodes, extensions, count, active), 1n)
    == scope(w, node, extension, nodes, extensions, 1n+count, 1n+active) : R.World}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match node:
        case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
          match extension:
            case R.NodeExtension{+x_inFlight, +x_flightTeardown, +x_error, +x_blocked, +x_pendingSources, +x_unobserved, +x_snapshotValue, +x_pendingFirstChild, +x_pendingDisposal, +x_transaction, +x_reask, +x_flushed, +x_flushedAt, +x_q, +x_lane, +x_marks, +x_shownError, +parkedFlight}:
              {==}

def nonlast(+w: R.World, +node: R.Node, +extension: R.NodeExtension, +nodes: List<&2, R.Node>, +extensions: List<&2, R.NodeExtension>, +count: Nat, +active: Nat) ->
  {Marks.unmark(scope(w, node, extension, nodes, extensions, 2n+count, 2n+active), 1n)
    == B.Bundle{scope(w, node, extension, nodes, extensions, 1n+count, 1n+active), False{}} : B.Bundle<R.World, Bool>}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match node:
        case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
          match extension:
            case R.NodeExtension{+x_inFlight, +x_flightTeardown, +x_error, +x_blocked, +x_pendingSources, +x_unobserved, +x_snapshotValue, +x_pendingFirstChild, +x_pendingDisposal, +x_transaction, +x_reask, +x_flushed, +x_flushedAt, +x_q, +x_lane, +x_marks, +x_shownError, +parkedFlight}:
              {==}

def inactive(+w: R.World, +id: Nat) ->
  {Marks.covered(R.World.with_activeMarks(w, 0n), id) == B.Bundle{R.World.with_activeMarks(w, 0n), False{}} : B.Bundle<R.World, Bool>}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      {==}
