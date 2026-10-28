# Quantified boundaries of actual verdict bookkeeping/value helpers. Public
# windows, seam outcomes and arbitrary graph/history correctness remain open.
import Base
import ../representation/base.bend as B
import ../representation/records.bend as R
import ../runtime/verdict-state.bend as V
import ../runtime/constants.bend as K

def nodeScope(w: R.World, node: R.Node, nodes: List<&2, R.Node>) -> R.World:
  R.World.with_nodes(w, B.blank_node() <> node <> nodes)

def noExtension(+w: R.World, +node: R.Node, +nodes: List<&2, R.Node>) ->
  {V.quietPending(nodeScope(w, R.Node.with_x(node, 0n), nodes), 1n) == False{} : Bool}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match node:
        case R.Node{+node_kind, +node_value, +node_pending, +node_equals, +node_config, +node_flags, +node_status, +node_time, +node_notified, +node_deps, +node_depsTail, +node_depGen, +node_subs, +node_subsTail, +node_height, +node_nextHeap, +node_prevHeap, +node_parent, +node_firstChild, +node_nextSibling, +node_prevSibling, +node_expr, +node_modified, +node_prevValue, +node_target, +node_loading, +node_x, +node_parentComputed, +node_scope, +node_childCount, +node_disposal, +node_cleanup, +node_effectProgram, +node_returnedCleanup, +node_errorProgram}:
          {==}

def emptySources(+w: R.World, node: R.Node, extension: R.NodeExtension, nodes: List<&2, R.Node>, extensions: List<&2, R.NodeExtension>) -> R.World:
  +w = nodeScope(w, R.Node.with_x(node, 1n), nodes)
  +w = R.World.with_extensions(w, B.blank_extension() <> R.NodeExtension.with_pendingSources(extension, 1n) <> extensions)
  R.World.with_pendingSets(w, [[], []])

def emptyIsQuiet(+w: R.World, +node: R.Node, +extension: R.NodeExtension, +nodes: List<&2, R.Node>, +extensions: List<&2, R.NodeExtension>) ->
  {V.quietPending(emptySources(w, node, extension, nodes, extensions), 1n) == True{} : Bool}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match node:
        case R.Node{+node_kind, +node_value, +node_pending, +node_equals, +node_config, +node_flags, +node_status, +node_time, +node_notified, +node_deps, +node_depsTail, +node_depGen, +node_subs, +node_subsTail, +node_height, +node_nextHeap, +node_prevHeap, +node_parent, +node_firstChild, +node_nextSibling, +node_prevSibling, +node_expr, +node_modified, +node_prevValue, +node_target, +node_loading, +node_x, +node_parentComputed, +node_scope, +node_childCount, +node_disposal, +node_cleanup, +node_effectProgram, +node_returnedCleanup, +node_errorProgram}:
          match extension:
            case R.NodeExtension{+extension_inFlight, +extension_flightTeardown, +extension_error, +extension_blocked, +extension_pendingSources, +extension_unobserved, +extension_snapshotValue, +extension_pendingFirstChild, +extension_pendingDisposal, +extension_transaction, +extension_reask, +extension_flushed, +extension_flushedAt, +extension_q, +extension_lane, +extension_marks, +extension_shownError}:
              {==}

def witnessInactive(+w: R.World, +state: R.VerdictState) ->
  {V.witnessMark(R.World.with_verdictState(w, R.VerdictState.with_probing(state, False{}))) == R.World.with_verdictState(w, R.VerdictState.with_probing(state, False{})) : R.World}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match state:
        case R.VerdictState{+state_latestActive, +state_probing, +state_probeFound, +state_dispatch}:
          {==}

def provisionalScope(+w: R.World, node: R.Node, nodes: List<&2, R.Node>) -> R.World:
  +w = nodeScope(w, node, nodes)
  +w = R.World.with_flushTransaction(w, 0n)
  R.World.with_verdictState(w, R.VerdictState.with_probing(R.World.verdictState(w), True{}))

def waiting(+w: R.World, +node: R.Node, +nodes: List<&2, R.Node>, unanswered: Bool) -> R.World:
  +start = provisionalScope(w, node, nodes)
  +node = B.choose(~R.Node, unanswered, _ => R.Node.with_flags(node, B.set(R.Node.flags(node), K.REACTIVE_PROBE_UNANSWERED())), _ => node)
  +next = nodeScope(start, node, nodes)
  +state = R.World.laneState(next)
  R.World.with_laneState(next, R.LaneState.with_stagedReaders(state, B.append(Nat, R.LaneState.stagedReaders(state), [1n])))

def provisionalWaits(+w: R.World, +node: R.Node, +nodes: List<&2, R.Node>, +unanswered: Bool) ->
  {V.provisionalVerdict(provisionalScope(w, node, nodes), 1n, unanswered) == waiting(w, node, nodes, unanswered) : R.World}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match w_laneState:
        case R.LaneState{+l_live, +l_groups, +l_stagedReaders, +l_pendingGuesses, +l_judged, +l_root, +l_entered}:
          match w_verdictState:
            case R.VerdictState{+v_latestActive, +v_probing, +v_probeFound, +v_dispatch}:
              match node:
                case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
                  match unanswered:
                    case True{}:
                      {==}
                    case False{}:
                      {==}

def joinedScope(w: R.World, node: R.Node, nodes: List<&2, R.Node>) -> R.World:
  R.World.with_passLane(nodeScope(w, R.Node.with_flags(node, K.REACTIVE_JOINED()), nodes), 0n)

def joinedStays(+w: R.World, +node: R.Node, +nodes: List<&2, R.Node>, +tx: Nat) ->
  {V.route(joinedScope(w, node, nodes), 1n, tx) == R.World.with_passLane(nodeScope(w, R.Node.with_flags(node, U32.or(K.REACTIVE_JOINED(), K.REACTIVE_LANE_READ())), nodes), 0n) : R.World}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match node:
        case R.Node{+node_kind, +node_value, +node_pending, +node_equals, +node_config, +node_flags, +node_status, +node_time, +node_notified, +node_deps, +node_depsTail, +node_depGen, +node_subs, +node_subsTail, +node_height, +node_nextHeap, +node_prevHeap, +node_parent, +node_firstChild, +node_nextSibling, +node_prevSibling, +node_expr, +node_modified, +node_prevValue, +node_target, +node_loading, +node_x, +node_parentComputed, +node_scope, +node_childCount, +node_disposal, +node_cleanup, +node_effectProgram, +node_returnedCleanup, +node_errorProgram}:
          {==}

def errorScope(w: R.World, node: R.Node, nodes: List<&2, R.Node>, error: R.Value) -> R.World:
  R.World.with_running(nodeScope(w, R.Node.with_config(R.Node.with_pending(node, R.Present{error}), K.CONFIG_STAGED_ERROR()), nodes), True{})

def stagedError(+w: R.World, +node: R.Node, +nodes: List<&2, R.Node>, +error: R.Value, +reader: Nat) ->
  {V.heldLatest(errorScope(w, node, nodes, error), 1n, reader) == B.Bundle{R.World.with_fault(errorScope(w, node, nodes, error), R.CallbackThrown{error}), R.Undefined{}} : B.Bundle<R.World, R.Value>}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match node:
        case R.Node{+node_kind, +node_value, +node_pending, +node_equals, +node_config, +node_flags, +node_status, +node_time, +node_notified, +node_deps, +node_depsTail, +node_depGen, +node_subs, +node_subsTail, +node_height, +node_nextHeap, +node_prevHeap, +node_parent, +node_firstChild, +node_nextSibling, +node_prevSibling, +node_expr, +node_modified, +node_prevValue, +node_target, +node_loading, +node_x, +node_parentComputed, +node_scope, +node_childCount, +node_disposal, +node_cleanup, +node_effectProgram, +node_returnedCleanup, +node_errorProgram}:
          {==}
