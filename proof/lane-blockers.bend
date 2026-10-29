# Actual active-lane blocker boundaries; not general graph progress/lifecycle.
import Base
import ../representation/base.bend as B
import ../representation/records.bend as R
import ../runtime/transaction.bend as X
import ../runtime/constants.bend as K

def openScope(w: R.World, tx: R.Transaction, rest: List<&2, R.Transaction>, count: Nat) -> R.World:
  R.World.with_fault(R.World.with_txArena(w, B.blank_transaction() <> R.Transaction.with_open(tx, 1n+count) <> rest), R.Healthy{})

def openRestoresJudge(+w: R.World, +tx: R.Transaction, +rest: List<&2, R.Transaction>, +count: Nat) ->
  {X.blocked(openScope(w, tx, rest, count), 1n) == B.Bundle{openScope(w, tx, rest, count), True{}} : B.Bundle<R.World, Bool>}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match w_judge:
        case 0n:
          match tx:
            case R.Transaction{+t_nodes, +t_renderQueue, +t_userQueue, +t_reruns, +t_into, +t_parent, +t_lane, +t_verdict, +t_open, +t_acted, +t_links, +t_shown, +t_held, +t_marks}:
              {==}
        case 1n+previous:
          match tx:
            case R.Transaction{+t_nodes, +t_renderQueue, +t_userQueue, +t_reruns, +t_into, +t_parent, +t_lane, +t_verdict, +t_open, +t_acted, +t_links, +t_shown, +t_held, +t_marks}:
              {==}


def emptyScope(+w: R.World, tx: R.Transaction, rest: List<&2, R.Transaction>) -> R.World:
  +tx = R.Transaction.with_lane(R.Transaction.with_nodes(R.Transaction.with_open(tx, 0n), []), False{})
  +w = R.World.with_txArena(w, B.blank_transaction() <> tx <> rest)
  +w = R.World.with_laneState(w, R.LaneState.with_live(R.World.laneState(w), []))
  R.World.with_fault(w, R.Healthy{})

# Source empty-list judgment for any budget, not a larger runtime budget.
def emptyList(+fuel: Nat, +w: R.World, +owner: Nat) ->
  {X.blockedList(fuel, w, [], owner, False{}) == B.Bundle{w, False{}} : B.Bundle<R.World, Bool>}:
  match fuel:
    case 0n:
      {==}
    case 1n+p:
      {==}

# Proof decomposition of the exact blocked-head return point.
def afterOwn(+pair: B.Bundle<R.World, Bool>, +previous: Nat) -> X.BlockFrame:
  +w = B.first(R.World, Bool, pair)
  B.choose(~X.BlockFrame, B.second(R.World, Bool, pair),
    _ => X.BlockFrame{w, [X.RestoreJudge{previous}], True{}},
    _ => X.BlockFrame{w, [X.JudgeLanes{1n}, X.RestoreJudge{previous}], False{}})

def entered(+w: R.World, +tx: R.Transaction, +rest: List<&2, R.Transaction>) -> R.World:
  +start = emptyScope(w, tx, rest)
  B.choose(~R.World, Nat.is_eq(R.World.judge(start), 0n), _ => R.World.with_judge(start, 1n), _ => start)

def emptyHead(+w: R.World, +tx: R.Transaction, +rest: List<&2, R.Transaction>) ->
  {X.blockStep(emptyScope(w, tx, rest), [X.JudgeTx{1n}], False{}) == X.BlockFrame{entered(w, tx, rest), [X.JudgeLanes{1n}, X.RestoreJudge{R.World.judge(emptyScope(w, tx, rest))}], False{}} : X.BlockFrame}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match w_judge:
        case 0n:
          match w_laneState:
            case R.LaneState{+l_live, +l_groups, +l_stagedReaders, +l_pendingGuesses, +l_judged, +l_root, +l_entered, +l_guessing, +l_guessed, +l_kept, +l_reverted, +l_reverting}:
              match tx:
                case R.Transaction{+t_nodes, +t_renderQueue, +t_userQueue, +t_reruns, +t_into, +t_parent, +t_lane, +t_verdict, +t_open, +t_acted, +t_links, +t_shown, +t_held, +t_marks}:
                  +current = entered(w, tx, rest)
                  +previous = R.World.judge(emptyScope(w, tx, rest))
                  Equal.cong(B.Bundle<R.World, Bool>, X.BlockFrame, pair => afterOwn(pair, previous),
                    X.blockedBy(current, [], 1n, False{}), B.Bundle{current, False{}},
                    emptyList(Nat.add(B.budget(current), 0n), current, 1n))
        case 1n+previous:
          match w_laneState:
            case R.LaneState{+l_live, +l_groups, +l_stagedReaders, +l_pendingGuesses, +l_judged, +l_root, +l_entered, +l_guessing, +l_guessed, +l_kept, +l_reverted, +l_reverting}:
              match tx:
                case R.Transaction{+t_nodes, +t_renderQueue, +t_userQueue, +t_reruns, +t_into, +t_parent, +t_lane, +t_verdict, +t_open, +t_acted, +t_links, +t_shown, +t_held, +t_marks}:
                  +current = entered(w, tx, rest)
                  +previous = R.World.judge(emptyScope(w, tx, rest))
                  Equal.cong(B.Bundle<R.World, Bool>, X.BlockFrame, pair => afterOwn(pair, previous),
                    X.blockedBy(current, [], 1n, False{}), B.Bundle{current, False{}},
                    emptyList(Nat.add(B.budget(current), 0n), current, 1n))

def firstStep(+w: R.World, +tx: R.Transaction, +rest: List<&2, R.Transaction>) ->
  {X.blocked(emptyScope(w, tx, rest), 1n) == X.blockRun(Nat.sub(X.blockBudget(emptyScope(w, tx, rest)), 1n), X.blockStep(emptyScope(w, tx, rest), [X.JudgeTx{1n}], False{})) : B.Bundle<R.World, Bool>}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      {==}

def afterEmptyHead(+w: R.World, +tx: R.Transaction, +rest: List<&2, R.Transaction>) ->
  {X.blockRun(Nat.sub(X.blockBudget(emptyScope(w, tx, rest)), 1n), X.BlockFrame{entered(w, tx, rest), [X.JudgeLanes{1n}, X.RestoreJudge{R.World.judge(emptyScope(w, tx, rest))}], False{}}) == B.Bundle{emptyScope(w, tx, rest), False{}} : B.Bundle<R.World, Bool>}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match w_judge:
        case 0n:
          match w_laneState:
            case R.LaneState{+l_live, +l_groups, +l_stagedReaders, +l_pendingGuesses, +l_judged, +l_root, +l_entered, +l_guessing, +l_guessed, +l_kept, +l_reverted, +l_reverting}:
              match tx:
                case R.Transaction{+t_nodes, +t_renderQueue, +t_userQueue, +t_reruns, +t_into, +t_parent, +t_lane, +t_verdict, +t_open, +t_acted, +t_links, +t_shown, +t_held, +t_marks}:
                  {==}
        case 1n+previous:
          match w_laneState:
            case R.LaneState{+l_live, +l_groups, +l_stagedReaders, +l_pendingGuesses, +l_judged, +l_root, +l_entered, +l_guessing, +l_guessed, +l_kept, +l_reverted, +l_reverting}:
              match tx:
                case R.Transaction{+t_nodes, +t_renderQueue, +t_userQueue, +t_reruns, +t_into, +t_parent, +t_lane, +t_verdict, +t_open, +t_acted, +t_links, +t_shown, +t_held, +t_marks}:
                  {==}

def emptyUnblocked(+w: R.World, +tx: R.Transaction, +rest: List<&2, R.Transaction>) ->
  {X.blocked(emptyScope(w, tx, rest), 1n) == B.Bundle{emptyScope(w, tx, rest), False{}} : B.Bundle<R.World, Bool>}:
  +start = emptyScope(w, tx, rest)
  +tail = Nat.sub(X.blockBudget(start), 1n)
  +head = X.blockStep(start, [X.JudgeTx{1n}], False{})
  +next = {X.BlockFrame{entered(w, tx, rest), [X.JudgeLanes{1n}, X.RestoreJudge{R.World.judge(start)}], False{}} : X.BlockFrame}
  Equal.trans(B.Bundle<R.World, Bool>, X.blocked(start, 1n), X.blockRun(tail, head), B.Bundle{start, False{}},
    firstStep(w, tx, rest),
    Equal.trans(B.Bundle<R.World, Bool>, X.blockRun(tail, head), X.blockRun(tail, next), B.Bundle{start, False{}},
      Equal.cong(X.BlockFrame, B.Bundle<R.World, Bool>, frame => X.blockRun(tail, frame), head, next, emptyHead(w, tx, rest)),
      afterEmptyHead(w, tx, rest)))


def groupScope(+w: R.World, a: R.Transaction, b: R.Transaction, rest: List<&2, R.Transaction>, count: Nat) -> R.World:
  +a = R.Transaction.with_lane(R.Transaction.with_links(a, 1n), True{})
  +b = R.Transaction.with_lane(R.Transaction.with_open(R.Transaction.with_links(b, 1n), 1n+count), True{})
  +w = R.World.with_txArena(w, B.blank_transaction() <> a <> b <> rest)
  +w = R.World.with_laneState(w, R.LaneState.with_groups(R.World.laneState(w), [[], [1n, 2n]]))
  R.World.with_fault(w, R.Healthy{})

def peerOpenBlocks(+w: R.World, +a: R.Transaction, +b: R.Transaction, +rest: List<&2, R.Transaction>, +count: Nat) ->
  {X.linkBlocked(groupScope(w, a, b, rest, count), 1n) == B.Bundle{groupScope(w, a, b, rest, count), True{}} : B.Bundle<R.World, Bool>}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match w_laneState:
        case R.LaneState{+l_live, +l_groups, +l_stagedReaders, +l_pendingGuesses, +l_judged, +l_root, +l_entered, +l_guessing, +l_guessed, +l_kept, +l_reverted, +l_reverting}:
          match a:
            case R.Transaction{+a_nodes, +a_renderQueue, +a_userQueue, +a_reruns, +a_into, +a_parent, +a_lane, +a_verdict, +a_open, +a_acted, +a_links, +a_shown, +a_held, +a_marks}:
              match b:
                case R.Transaction{+b_nodes, +b_renderQueue, +b_userQueue, +b_reruns, +b_into, +b_parent, +b_lane, +b_verdict, +b_open, +b_acted, +b_links, +b_shown, +b_held, +b_marks}:
                  {==}

def guessScope(+w: R.World, node: R.Node, extension: R.NodeExtension, tx: R.Transaction, nodes: List<&2, R.Node>, extensions: List<&2, R.NodeExtension>, rest: List<&2, R.Transaction>) -> R.World:
  +node = R.Node.with_x(R.Node.with_status(R.Node.with_config(node, U32.or(K.CONFIG_GUESS(), K.CONFIG_OVERRIDE())), K.STATUS_PENDING()), 1n)
  +w = R.World.with_nodes(w, B.blank_node() <> node <> nodes)
  +w = R.World.with_extensions(w, B.blank_extension() <> R.NodeExtension.with_transaction(extension, 1n) <> extensions)
  +w = R.World.with_txArena(w, B.blank_transaction() <> R.Transaction.with_lane(R.Transaction.with_nodes(tx, [1n]), True{}) <> rest)
  R.World.with_fault(w, R.Healthy{})

def ownGuessFlight(+w: R.World, +node: R.Node, +extension: R.NodeExtension, +tx: R.Transaction, +nodes: List<&2, R.Node>, +extensions: List<&2, R.NodeExtension>, +rest: List<&2, R.Transaction>) ->
  {X.guessFlights(guessScope(w, node, extension, tx, nodes, extensions, rest), 1n) == B.Bundle{guessScope(w, node, extension, tx, nodes, extensions, rest), True{}} : B.Bundle<R.World, Bool>}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match node:
        case R.Node{+node_kind, +node_value, +node_pending, +node_equals, +node_config, +node_flags, +node_status, +node_time, +node_notified, +node_deps, +node_depsTail, +node_depGen, +node_subs, +node_subsTail, +node_height, +node_nextHeap, +node_prevHeap, +node_parent, +node_firstChild, +node_nextSibling, +node_prevSibling, +node_expr, +node_modified, +node_prevValue, +node_target, +node_loading, +node_x, +node_parentComputed, +node_scope, +node_childCount, +node_disposal, +node_cleanup, +node_effectProgram, +node_returnedCleanup, +node_errorProgram}:
          match extension:
            case R.NodeExtension{+extension_inFlight, +extension_flightTeardown, +extension_error, +extension_blocked, +extension_pendingSources, +extension_unobserved, +extension_snapshotValue, +extension_pendingFirstChild, +extension_pendingDisposal, +extension_transaction, +extension_reask, +extension_flushed, +extension_flushedAt, +extension_q, +extension_lane, +extension_marks, +extension_shownError}:
              match tx:
                case R.Transaction{+tx_nodes, +tx_renderQueue, +tx_userQueue, +tx_reruns, +tx_into, +tx_parent, +tx_lane, +tx_verdict, +tx_open, +tx_acted, +tx_links, +tx_shown, +tx_held, +tx_marks}:
                  {==}
