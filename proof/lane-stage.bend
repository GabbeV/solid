# Four exact laneStage frame properties. These are internal typed helper
# boundaries, not public lane read/reveal or full lifecycle correctness.
import Base
import ../representation/base.bend as B
import ../representation/records.bend as R
import ../runtime/lanes-state.bend as L
import ../runtime/constants.bend as K

def coldScope(w: R.World, node: R.Node, nodes: List<&2, R.Node>) -> R.World:
  R.World.with_nodes(w, B.blank_node() <> R.Node.with_x(R.Node.with_flags(R.Node.with_config(R.Node.with_kind(node, R.Memo{}), K.CONFIG_STAGED()), 0), 0n) <> nodes)

def coldLeave(+w: R.World, +node: R.Node, +nodes: List<&2, R.Node>, +lane: Nat) ->
  {L.laneStage(coldScope(w, node, nodes), 1n, lane, False{}, L.StageAnswered{}) == B.Bundle{coldScope(w, node, nodes), False{}} : B.Bundle<R.World, Bool>}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match node:
        case R.Node{+node_kind, +node_value, +node_pending, +node_equals, +node_config, +node_flags, +node_status, +node_time, +node_notified, +node_deps, +node_depsTail, +node_depGen, +node_subs, +node_subsTail, +node_height, +node_nextHeap, +node_prevHeap, +node_parent, +node_firstChild, +node_nextSibling, +node_prevSibling, +node_expr, +node_modified, +node_prevValue, +node_target, +node_loading, +node_x, +node_parentComputed, +node_scope, +node_childCount, +node_disposal, +node_cleanup, +node_effectProgram, +node_returnedCleanup, +node_errorProgram}:
          {==}

def arena(+w: R.World, node: R.Node, extension: R.NodeExtension, tx: R.Transaction, nodes: List<&2, R.Node>, extensions: List<&2, R.NodeExtension>, txs: List<&2, R.Transaction>) -> R.World:
  +w = R.World.with_nodes(w, B.blank_node() <> node <> nodes)
  +w = R.World.with_extensions(w, B.blank_extension() <> extension <> extensions)
  R.World.with_txArena(w, B.blank_transaction() <> tx <> txs)

def member(+w: R.World, node: R.Node, extension: R.NodeExtension, tx: R.Transaction, nodes: List<&2, R.Node>, extensions: List<&2, R.NodeExtension>, txs: List<&2, R.Transaction>, kind: R.NodeKind) -> R.World:
  +node = R.Node.with_kind(R.Node.with_config(R.Node.with_flags(R.Node.with_x(node, 1n), 0), 0), kind)
  arena(w, node, R.NodeExtension.with_transaction(extension, 0n), R.Transaction.with_lane(tx, True{}), nodes, extensions, txs)

def entered(+w: R.World, +node: R.Node, extension: R.NodeExtension, +tx: R.Transaction, nodes: List<&2, R.Node>, extensions: List<&2, R.NodeExtension>, txs: List<&2, R.Transaction>, effect: Bool) -> R.World:
  +node = B.choose(~R.Node, effect,
    _ => R.Node.with_kind(R.Node.with_config(R.Node.with_flags(R.Node.with_x(node, 1n), K.REACTIVE_LANE_DIRTY()), 0), R.Render{}),
    _ => R.Node.with_kind(R.Node.with_config(R.Node.with_flags(R.Node.with_x(R.Node.with_pending(node, R.Empty{}), 1n), 0), K.CONFIG_OVERRIDE()), R.Memo{}))
  +tx = R.Transaction.with_nodes(R.Transaction.with_lane(tx, True{}), B.append(Nat, R.Transaction.nodes(tx), [1n]))
  arena(w, node, R.NodeExtension.with_transaction(extension, 1n), tx, nodes, extensions, txs)

def memoEnters(+w: R.World, +node: R.Node, +extension: R.NodeExtension, +tx: R.Transaction, +nodes: List<&2, R.Node>, +extensions: List<&2, R.NodeExtension>, +txs: List<&2, R.Transaction>) ->
  {L.laneStage(member(w, node, extension, tx, nodes, extensions, txs, R.Memo{}), 1n, 1n, True{}, L.StageAnswered{}) == B.Bundle{entered(w, node, extension, tx, nodes, extensions, txs, False{}), True{}} : B.Bundle<R.World, Bool>}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match w_laneState:
        case R.LaneState{+l_live, +l_groups, +l_stagedReaders, +l_pendingGuesses, +l_judged, +l_root, +l_entered, +l_guessing, +l_guessed, +l_kept, +l_reverted, +l_reverting, +revealing}:
          match l_guessed:
            case False{}:
              match node:
                case R.Node{+node_kind, +node_value, +node_pending, +node_equals, +node_config, +node_flags, +node_status, +node_time, +node_notified, +node_deps, +node_depsTail, +node_depGen, +node_subs, +node_subsTail, +node_height, +node_nextHeap, +node_prevHeap, +node_parent, +node_firstChild, +node_nextSibling, +node_prevSibling, +node_expr, +node_modified, +node_prevValue, +node_target, +node_loading, +node_x, +node_parentComputed, +node_scope, +node_childCount, +node_disposal, +node_cleanup, +node_effectProgram, +node_returnedCleanup, +node_errorProgram}:
                  match extension:
                    case R.NodeExtension{+extension_inFlight, +extension_flightTeardown, +extension_error, +extension_blocked, +extension_pendingSources, +extension_unobserved, +extension_snapshotValue, +extension_pendingFirstChild, +extension_pendingDisposal, +extension_transaction, +extension_reask, +extension_flushed, +extension_flushedAt, +extension_q, +extension_lane, +extension_marks, +extension_shownError, +parkedFlight}:
                      match tx:
                        case R.Transaction{+tx_nodes, +tx_renderQueue, +tx_userQueue, +tx_reruns, +tx_into, +tx_parent, +tx_lane, +tx_verdict, +tx_open, +tx_acted, +tx_links, +tx_shown, +tx_held, +tx_marks}:
                          {==}
            case True{}:
              match node:
                case R.Node{+node_kind, +node_value, +node_pending, +node_equals, +node_config, +node_flags, +node_status, +node_time, +node_notified, +node_deps, +node_depsTail, +node_depGen, +node_subs, +node_subsTail, +node_height, +node_nextHeap, +node_prevHeap, +node_parent, +node_firstChild, +node_nextSibling, +node_prevSibling, +node_expr, +node_modified, +node_prevValue, +node_target, +node_loading, +node_x, +node_parentComputed, +node_scope, +node_childCount, +node_disposal, +node_cleanup, +node_effectProgram, +node_returnedCleanup, +node_errorProgram}:
                  match extension:
                    case R.NodeExtension{+extension_inFlight, +extension_flightTeardown, +extension_error, +extension_blocked, +extension_pendingSources, +extension_unobserved, +extension_snapshotValue, +extension_pendingFirstChild, +extension_pendingDisposal, +extension_transaction, +extension_reask, +extension_flushed, +extension_flushedAt, +extension_q, +extension_lane, +extension_marks, +extension_shownError, +parkedFlight}:
                      match tx:
                        case R.Transaction{+tx_nodes, +tx_renderQueue, +tx_userQueue, +tx_reruns, +tx_into, +tx_parent, +tx_lane, +tx_verdict, +tx_open, +tx_acted, +tx_links, +tx_shown, +tx_held, +tx_marks}:
                          {==}

def failedEffectEnters(+w: R.World, +node: R.Node, +extension: R.NodeExtension, +tx: R.Transaction, +nodes: List<&2, R.Node>, +extensions: List<&2, R.NodeExtension>, +txs: List<&2, R.Transaction>) ->
  {L.laneStage(member(w, node, extension, tx, nodes, extensions, txs, R.Render{}), 1n, 1n, False{}, L.StageFailed{}) == B.Bundle{entered(w, node, extension, tx, nodes, extensions, txs, True{}), True{}} : B.Bundle<R.World, Bool>}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match node:
        case R.Node{+node_kind, +node_value, +node_pending, +node_equals, +node_config, +node_flags, +node_status, +node_time, +node_notified, +node_deps, +node_depsTail, +node_depGen, +node_subs, +node_subsTail, +node_height, +node_nextHeap, +node_prevHeap, +node_parent, +node_firstChild, +node_nextSibling, +node_prevSibling, +node_expr, +node_modified, +node_prevValue, +node_target, +node_loading, +node_x, +node_parentComputed, +node_scope, +node_childCount, +node_disposal, +node_cleanup, +node_effectProgram, +node_returnedCleanup, +node_errorProgram}:
          match extension:
            case R.NodeExtension{+extension_inFlight, +extension_flightTeardown, +extension_error, +extension_blocked, +extension_pendingSources, +extension_unobserved, +extension_snapshotValue, +extension_pendingFirstChild, +extension_pendingDisposal, +extension_transaction, +extension_reask, +extension_flushed, +extension_flushedAt, +extension_q, +extension_lane, +extension_marks, +extension_shownError, +parkedFlight}:
              match tx:
                case R.Transaction{+tx_nodes, +tx_renderQueue, +tx_userQueue, +tx_reruns, +tx_into, +tx_parent, +tx_lane, +tx_verdict, +tx_open, +tx_acted, +tx_links, +tx_shown, +tx_held, +tx_marks}:
                  {==}

def frameScope(w: R.World, node: R.Node, source: R.Node, nodes: List<&2, R.Node>) -> R.World:
  R.World.with_nodes(w, B.blank_node() <> R.Node.with_kind(R.Node.with_config(R.Node.with_flags(R.Node.with_x(node, 0n), K.REACTIVE_RECOMPUTING_DEPS()), 0), R.Render{}) <> R.Node.with_status(source, 0) <> nodes)

def queued(+w: R.World) -> R.World:
  +w = R.World.with_pendingNodes(w, B.append(Nat, R.World.pendingNodes(w), [1n]))
  B.choose(~R.World, Bool.not(R.World.running(w)), _ => R.World.with_unflushedStaged(w, True{}), _ => w)

def pendingEffectStays(+w: R.World, +node: R.Node, +source: R.Node, +nodes: List<&2, R.Node>, +lane: Nat) ->
  {L.laneStage(frameScope(w, node, source, nodes), 1n, lane, False{}, L.StagePendingFrom{2n}) == B.Bundle{queued(frameScope(w, node, source, nodes)), False{}} : B.Bundle<R.World, Bool>}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match node:
        case R.Node{+node_kind, +node_value, +node_pending, +node_equals, +node_config, +node_flags, +node_status, +node_time, +node_notified, +node_deps, +node_depsTail, +node_depGen, +node_subs, +node_subsTail, +node_height, +node_nextHeap, +node_prevHeap, +node_parent, +node_firstChild, +node_nextSibling, +node_prevSibling, +node_expr, +node_modified, +node_prevValue, +node_target, +node_loading, +node_x, +node_parentComputed, +node_scope, +node_childCount, +node_disposal, +node_cleanup, +node_effectProgram, +node_returnedCleanup, +node_errorProgram}:
          match source:
            case R.Node{+source_kind, +source_value, +source_pending, +source_equals, +source_config, +source_flags, +source_status, +source_time, +source_notified, +source_deps, +source_depsTail, +source_depGen, +source_subs, +source_subsTail, +source_height, +source_nextHeap, +source_prevHeap, +source_parent, +source_firstChild, +source_nextSibling, +source_prevSibling, +source_expr, +source_modified, +source_prevValue, +source_target, +source_loading, +source_x, +source_parentComputed, +source_scope, +source_childCount, +source_disposal, +source_cleanup, +source_effectProgram, +source_returnedCleanup, +source_errorProgram}:
              {==}
