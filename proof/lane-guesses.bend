# Actual queued-guess lookup/application boundaries, not a full lane theorem.
import Base
import ../runtime/constants.bend as K
import ../runtime/question.bend as Q
import ../runtime/core.bend as C
import ../runtime/lanes-state.bend as L
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./arena.bend as Arena
import ./lane-group-laws.bend as Groups

def scope(+w: R.World, guesses: List<&2, R.Guess>) -> R.World:
  R.World.with_laneState(w, R.LaneState.with_pendingGuesses(R.World.laneState(w), guesses))

def lengthLast(+prefix: List<&2, R.Guess>, +last: R.Guess) ->
  {B.length(R.Guess, B.append(R.Guess, prefix, [last])) == 1n+B.length(R.Guess, prefix) : Nat}:
  match prefix:
    case Nil{}:
      {==}
    case head <> +tail:
      Equal.cong(Nat, Nat, n => 1n+n, B.length(R.Guess, B.append(R.Guess, tail, [last])), 1n+B.length(R.Guess, tail), lengthLast(tail, last))

def chooseGuess(+w: R.World, +id: Nat, +index: Nat, +g: R.Guess) -> R.Slot:
  B.choose(~R.Slot, Nat.is_eq(R.Guess.node(g), id), _ => R.Present{R.Guess.value(g)}, _ => L.pendingGuessLoop(w, id, index))

def loopNewest(+w: R.World, +prefix: List<&2, R.Guess>, +id: Nat, +value: R.Value, +q: R.Question) ->
  {L.pendingGuessLoop(scope(w, B.append(R.Guess, prefix, [R.Guess{id, value, q}])), id, 1n+B.length(R.Guess, prefix)) == R.Present{value} : R.Slot}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match w_laneState:
        case R.LaneState{+s_live, +s_groups, +s_stagedReaders, +s_pendingGuesses, +s_judged, +s_root, +s_entered}:
          +queue = B.append(R.Guess, prefix, [R.Guess{id, value, q}])
          +s = scope(w, queue)
          +index = B.length(R.Guess, prefix)
          +fallback = {R.Guess{0n, R.Undefined{}, R.QuestionZero{}} : R.Guess}
          Equal.trans(R.Slot, L.pendingGuessLoop(s, id, 1n+index), chooseGuess(s, id, index, R.Guess{id, value, q}), R.Present{value},
            Equal.cong(R.Guess, R.Slot, g => chooseGuess(s, id, index, g), B.get(R.Guess, queue, index, fallback), R.Guess{id, value, q}, Arena.getPrefix(R.Guess, prefix, R.Guess{id, value, q}, [], fallback)),
            Equal.cong(Bool, R.Slot, same => B.choose(~R.Slot, same, _ => R.Present{value}, _ => L.pendingGuessLoop(s, id, index)), Nat.is_eq(id, id), True{}, Groups.sameNat(id)))

def newestWins(+w: R.World, +prefix: List<&2, R.Guess>, +id: Nat, +value: R.Value, +q: R.Question) ->
  {L.pendingGuessOf(scope(w, B.append(R.Guess, prefix, [R.Guess{id, value, q}])), id) == R.Present{value} : R.Slot}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match w_laneState:
        case R.LaneState{+s_live, +s_groups, +s_stagedReaders, +s_pendingGuesses, +s_judged, +s_root, +s_entered}:
          +queue = B.append(R.Guess, prefix, [R.Guess{id, value, q}])
          Equal.trans(R.Slot, L.pendingGuessOf(scope(w, queue), id), L.pendingGuessLoop(scope(w, queue), id, 1n+B.length(R.Guess, prefix)), R.Present{value},
            Equal.cong(Nat, R.Slot, count => L.pendingGuessLoop(scope(w, queue), id, count), B.length(R.Guess, queue), 1n+B.length(R.Guess, prefix), lengthLast(prefix, R.Guess{id, value, q})),
            loopNewest(w, prefix, id, value, q))

def emptyLookup(+w: R.World, +id: Nat) ->
  {L.pendingGuessOf(scope(w, []), id) == R.Empty{} : R.Slot}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match w_laneState:
        case R.LaneState{+s_live, +s_groups, +s_stagedReaders, +s_pendingGuesses, +s_judged, +s_root, +s_entered}:
          {==}

def judgedEmpty(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +parent: Nat) ->
  {C.applyGuessesAt(scope(w, []), rest, stack, parent) == C.Machine{R.World.with_laneState(scope(w, []), R.LaneState.with_judged(R.World.laneState(scope(w, [])), B.length(Nat, R.LaneState.live(R.World.laneState(scope(w, [])))))), rest, stack} : C.Machine}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match w_laneState:
        case R.LaneState{+s_live, +s_groups, +s_stagedReaders, +s_pendingGuesses, +s_judged, +s_root, +s_entered}:
          {==}


def compared(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +value: R.Value, guess: Bool) -> C.Machine:
  C.Machine{B.choose(~R.World, Bool.not(guess), _ => w, _ => L.pushGuess(w, id, value)), rest, value <> stack}

def equalOrdinary(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +value: R.Value,
  known: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_GUESS()) == False{} : Bool}) ->
  {C.dispatch(w, C.OptimisticCompared{id, value} <> rest, R.Boolean{True{}} <> stack) == C.Machine{w, rest, value <> stack} : C.Machine}:
  Equal.cong(Bool, C.Machine, guess => compared(w, rest, stack, id, value, guess), B.has(R.Node.config(B.node(w, id)), K.CONFIG_GUESS()), False{}, known)

def equalGuessReasks(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +value: R.Value,
  known: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_GUESS()) == True{} : Bool}) ->
  {C.dispatch(w, C.OptimisticCompared{id, value} <> rest, R.Boolean{True{}} <> stack) == C.Machine{L.pushGuess(w, id, value), rest, value <> stack} : C.Machine}:
  Equal.cong(Bool, C.Machine, guess => compared(w, rest, stack, id, value, guess), B.has(R.Node.config(B.node(w, id)), K.CONFIG_GUESS()), True{}, known)

def pushed(+w: R.World, id: Nat, value: R.Value, q: R.Question) -> R.World:
  R.World.with_laneState(w, R.LaneState.with_pendingGuesses(R.World.laneState(w), B.append(R.Guess, R.LaneState.pendingGuesses(R.World.laneState(w)), [R.Guess{id, value, q}])))

def unstampedPush(+w: R.World, +id: Nat, +value: R.Value) ->
  {L.pushGuess(R.World.with_question(w, R.QuestionZero{}), id, value) == B.schedule(pushed(R.World.with_questions(R.World.with_question(w, R.QuestionZero{}), Q.increment(R.World.questions(w))), id, value, Q.increment(R.World.questions(w)))) : R.World}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match w_laneState:
        case R.LaneState{+s_live, +s_groups, +s_stagedReaders, +s_pendingGuesses, +s_judged, +s_root, +s_entered}:
          {==}

# laneSeams' null path still judges the previously recorded live prefix.
def nullSeams(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>) ->
  {C.laneSeams(w, rest, stack, R.NoIds{}) == C.Machine{w, C.LaneLeakLoop{[], 0n, []} <> rest, stack} : C.Machine}:
  {==}

def emptyLeaks(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +leaked: List<&2, Nat>) ->
  {C.laneLeakLoop(w, rest, stack, [], 0n, leaked) == C.Machine{w, C.LaneRevealLoop{leaked, Nat.min(R.LaneState.judged(R.World.laneState(w)), B.length(Nat, R.LaneState.live(R.World.laneState(w))))} <> rest, stack} : C.Machine}:
  {==}

def zeroReveal(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +leaked: List<&2, Nat>) ->
  {C.laneRevealLoop(w, rest, stack, leaked, 0n) == C.laneEnteredLoop(w, rest, stack) : C.Machine}:
  {==}
