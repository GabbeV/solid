# Quantified window finally/catch boundaries, not arbitrary graph histories.
import Base
import ../runtime/core.bend as C
import ../representation/records.bend as R

def expectedLatest(+w: R.World, latest: Bool, dispatch: Bool) -> R.World:
  +state = R.World.verdictState(w)
  R.World.with_verdictState(w, R.VerdictState{latest, R.VerdictState.probing(state), R.VerdictState.probeFound(state), dispatch, R.VerdictState.latestOpened(state)})

def expectedProbe(+w: R.World, probing: Bool, found: Bool, dispatch: Bool) -> R.World:
  +state = R.World.verdictState(w)
  R.World.with_verdictState(w, R.VerdictState{R.VerdictState.latestActive(state), probing, found, dispatch, R.VerdictState.latestOpened(state)})

def loading(+w: R.World, +identity: Nat, +source: Nat, found: Bool) -> R.World:
  +w = R.World.with_verdictState(w, R.VerdictState.with_probeFound(R.World.verdictState(w), found))
  R.World.with_fault(w, R.CallbackThrown{R.NotReadyFailure{identity, source}})

def latestReturn(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +saved: List<&2, R.Value>, +latest: Bool, +dispatch: Bool) ->
  {C.dispatch(w, C.LatestEnd{latest, dispatch, saved} <> rest, stack) == C.Machine{expectedLatest(w, latest, dispatch), rest, stack} : C.Machine}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match w_verdictState:
        case R.VerdictState{+bodyLatest, +bodyProbing, +bodyFound, +bodyDispatch, +latestOpened}:
          {==}

def latestThrow(+w: R.World, +rest: List<&2, C.Task>, stack: List<&2, R.Value>, +saved: List<&2, R.Value>, +latest: Bool, +dispatch: Bool) ->
  {C.unwind(w, C.LatestEnd{latest, dispatch, saved} <> rest, stack) == C.Machine{expectedLatest(w, latest, dispatch), rest, saved} : C.Machine}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match w_verdictState:
        case R.VerdictState{+bodyLatest, +bodyProbing, +bodyFound, +bodyDispatch, +latestOpened}:
          {==}

def probeReturn(+w: R.World, +rest: List<&2, C.Task>, stack: List<&2, R.Value>, +saved: List<&2, R.Value>, +probing: Bool, +found: Bool, +dispatch: Bool) ->
  {C.dispatch(w, C.ProbeEnd{probing, found, dispatch, saved} <> rest, stack) == C.Machine{expectedProbe(w, probing, found, dispatch), rest, R.Boolean{R.VerdictState.probeFound(R.World.verdictState(w))} <> saved} : C.Machine}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match w_verdictState:
        case R.VerdictState{+bodyLatest, +bodyProbing, +bodyFound, +bodyDispatch, +latestOpened}:
          {==}

def probeNumeric(+w: R.World, +rest: List<&2, C.Task>, +saved: List<&2, R.Value>, +probing: Bool, +found: Bool, +dispatch: Bool, +cause: Nat) ->
  {C.probeThrown(R.World.with_fault(w, R.CallbackThrown{R.Number{cause}}), rest, saved, probing, found, dispatch, R.CallbackThrown{R.Number{cause}}) == C.Machine{R.World.with_fault(expectedProbe(w, probing, found, dispatch), R.Healthy{}), rest, R.Boolean{R.VerdictState.probeFound(R.World.verdictState(w))} <> saved} : C.Machine}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match w_verdictState:
        case R.VerdictState{+bodyLatest, +bodyProbing, +bodyFound, +bodyDispatch, +latestOpened}:
          {==}

def probeLoadingOwned(+w: R.World, +rest: List<&2, C.Task>, +saved: List<&2, R.Value>, +probing: Bool, +found: Bool, +dispatch: Bool, +identity: Nat, +source: Nat) ->
  {C.probeThrown(R.World.with_context(loading(w, identity, source, False{}), 1n), rest, saved, probing, found, dispatch, R.CallbackThrown{R.NotReadyFailure{identity, source}}) == C.Machine{expectedProbe(R.World.with_context(loading(w, identity, source, False{}), 1n), probing, found, dispatch), rest, saved} : C.Machine}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match w_verdictState:
        case R.VerdictState{+bodyLatest, +bodyProbing, +bodyFound, +bodyDispatch, +latestOpened}:
          {==}

def probeLoadingFound(+w: R.World, +rest: List<&2, C.Task>, +saved: List<&2, R.Value>, +probing: Bool, +found: Bool, +dispatch: Bool, +identity: Nat, +source: Nat) ->
  {C.probeThrown(loading(w, identity, source, True{}), rest, saved, probing, found, dispatch, R.CallbackThrown{R.NotReadyFailure{identity, source}}) == C.Machine{R.World.with_fault(expectedProbe(loading(w, identity, source, True{}), probing, found, dispatch), R.Healthy{}), rest, R.Boolean{True{}} <> saved} : C.Machine}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match w_verdictState:
        case R.VerdictState{+bodyLatest, +bodyProbing, +bodyFound, +bodyDispatch, +latestOpened}:
          {==}

def probeLoadingOutside(+w: R.World, +rest: List<&2, C.Task>, +saved: List<&2, R.Value>, +probing: Bool, +found: Bool, +dispatch: Bool, +identity: Nat, +source: Nat) ->
  {C.probeThrown(R.World.with_context(w, 0n), rest, saved, probing, found, dispatch, R.CallbackThrown{R.NotReadyFailure{identity, source}}) == C.Machine{R.World.with_fault(expectedProbe(R.World.with_context(w, 0n), probing, found, dispatch), R.Healthy{}), rest, R.Boolean{R.VerdictState.probeFound(R.World.verdictState(w))} <> saved} : C.Machine}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match w_verdictState:
        case R.VerdictState{+bodyLatest, +bodyProbing, +bodyFound, +bodyDispatch, +latestOpened}:
          match bodyFound:
            case False{}: {==}
            case True{}: {==}
