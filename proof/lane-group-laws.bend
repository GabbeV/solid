# General exact frame properties for actual lane-group unlink. Group members
# before target one are IDs >=2; suffix data and other World fields are arbitrary.
import Base
import ../representation/base.bend as B
import ../representation/records.bend as R
import ../runtime/lanes-state.bend as L
import ../runtime/pending-state.bend as P

def peers(offsets: List<&2, Nat>) -> List<&2, Nat>:
  match offsets:
    case Nil{}:
      []
    case head <> tail:
      (2n+head) <> peers(tail)

def before(+prefix: List<&2, Nat>, suffix: List<&2, Nat>) -> List<&2, Nat>:
  B.append(Nat, peers(prefix), 1n <> suffix)

def after(+prefix: List<&2, Nat>, suffix: List<&2, Nat>) -> List<&2, Nat>:
  B.append(Nat, peers(prefix), suffix)

def containsTarget(+prefix: List<&2, Nat>, +suffix: List<&2, Nat>) -> {B.contains(before(prefix, suffix), 1n) == True{} : Bool}:
  match prefix:
    case Nil{}:
      {==}
    case head <> tail:
      containsTarget(tail, suffix)

def excludesTarget(+prefix: List<&2, Nat>) -> {B.contains(peers(prefix), 1n) == False{} : Bool}:
  match prefix:
    case Nil{}:
      {==}
    case head <> tail:
      excludesTarget(tail)

def removeTarget(+prefix: List<&2, Nat>, +suffix: List<&2, Nat>) -> {P.remove(before(prefix, suffix), 1n) == after(prefix, suffix) : List<&2, Nat>}:
  match prefix:
    case Nil{}:
      {==}
    case +head <> +tail:
      Equal.cong(List<&2, Nat>, List<&2, Nat>, xs => (2n+head) <> xs, P.remove(before(tail, suffix), 1n), after(tail, suffix), removeTarget(tail, suffix))

def frame(+w: R.World, tx: R.Transaction, rest: List<&2, R.Transaction>, groupRest: List<&2, List<&2, Nat>>, link: Nat, items: List<&2, Nat>) -> R.World:
  +w = R.World.with_txArena(w, B.blank_transaction() <> R.Transaction.with_links(R.Transaction.with_lane(tx, True{}), link) <> rest)
  R.World.with_laneState(w, R.LaneState.with_groups(R.World.laneState(w), [] <> items <> groupRest))

# Checked decomposition of unlink after its captured group/null test.
def branch(+start: R.World, present: Bool, +removed: List<&2, Nat>) -> R.World:
  +w = B.choose(~R.World, present, _ => L.storeGroup(start, 1n, removed), _ => start)
  B.store_transaction(w, 1n, R.Transaction.with_links(B.transaction(w, 1n), 0n))
def entry(+w: R.World, +tx: R.Transaction, +rest: List<&2, R.Transaction>, +groupRest: List<&2, List<&2, Nat>>, +items: List<&2, Nat>) ->
  {L.unlink(frame(w, tx, rest, groupRest, 1n, items), 1n) == branch(frame(w, tx, rest, groupRest, 1n, items), B.contains(items, 1n), P.remove(items, 1n)) : R.World}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match w_laneState:
        case R.LaneState{+l_live, +l_groups, +l_stagedReaders, +l_pendingGuesses, +l_judged, +l_root, +l_entered}:
          match tx:
            case R.Transaction{+t_nodes, +t_renderQueue, +t_userQueue, +t_reruns, +t_into, +t_parent, +t_lane, +t_verdict, +t_open, +t_acted, +t_links, +t_shown, +t_held, +t_marks}:
              {==}

def presentResult(+w: R.World, +tx: R.Transaction, +rest: List<&2, R.Transaction>, +groupRest: List<&2, List<&2, Nat>>, +items: List<&2, Nat>, +removed: List<&2, Nat>) ->
  {branch(frame(w, tx, rest, groupRest, 1n, items), True{}, removed) == frame(w, tx, rest, groupRest, 0n, removed) : R.World}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match w_laneState:
        case R.LaneState{+l_live, +l_groups, +l_stagedReaders, +l_pendingGuesses, +l_judged, +l_root, +l_entered}:
          match tx:
            case R.Transaction{+t_nodes, +t_renderQueue, +t_userQueue, +t_reruns, +t_into, +t_parent, +t_lane, +t_verdict, +t_open, +t_acted, +t_links, +t_shown, +t_held, +t_marks}:
              {==}

def absentResult(+w: R.World, +tx: R.Transaction, +rest: List<&2, R.Transaction>, +groupRest: List<&2, List<&2, Nat>>, +items: List<&2, Nat>, +removed: List<&2, Nat>) ->
  {branch(frame(w, tx, rest, groupRest, 1n, items), False{}, removed) == frame(w, tx, rest, groupRest, 0n, items) : R.World}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match w_laneState:
        case R.LaneState{+l_live, +l_groups, +l_stagedReaders, +l_pendingGuesses, +l_judged, +l_root, +l_entered}:
          match tx:
            case R.Transaction{+t_nodes, +t_renderQueue, +t_userQueue, +t_reruns, +t_into, +t_parent, +t_lane, +t_verdict, +t_open, +t_acted, +t_links, +t_shown, +t_held, +t_marks}:
              {==}

def unlinkPresent(+w: R.World, +tx: R.Transaction, +rest: List<&2, R.Transaction>, +groupRest: List<&2, List<&2, Nat>>, +prefix: List<&2, Nat>, +suffix: List<&2, Nat>) ->
  {L.unlink(frame(w, tx, rest, groupRest, 1n, before(prefix, suffix)), 1n) == frame(w, tx, rest, groupRest, 0n, after(prefix, suffix)) : R.World}:
  +items = before(prefix, suffix)
  +removed = P.remove(items, 1n)
  +start = frame(w, tx, rest, groupRest, 1n, items)
  +finish = frame(w, tx, rest, groupRest, 0n, after(prefix, suffix))
  Equal.trans(R.World, L.unlink(start, 1n), branch(start, B.contains(items, 1n), removed), finish,
    entry(w, tx, rest, groupRest, items),
    Equal.trans(R.World, branch(start, B.contains(items, 1n), removed), branch(start, True{}, removed), finish,
      Equal.cong(Bool, R.World, found => branch(start, found, removed), B.contains(items, 1n), True{}, containsTarget(prefix, suffix)),
      Equal.trans(R.World, branch(start, True{}, removed), branch(start, True{}, after(prefix, suffix)), finish,
        Equal.cong(List<&2, Nat>, R.World, xs => branch(start, True{}, xs), removed, after(prefix, suffix), removeTarget(prefix, suffix)),
        presentResult(w, tx, rest, groupRest, items, after(prefix, suffix)))))

def unlinkAbsent(+w: R.World, +tx: R.Transaction, +rest: List<&2, R.Transaction>, +groupRest: List<&2, List<&2, Nat>>, +prefix: List<&2, Nat>) ->
  {L.unlink(frame(w, tx, rest, groupRest, 1n, peers(prefix)), 1n) == frame(w, tx, rest, groupRest, 0n, peers(prefix)) : R.World}:
  +items = peers(prefix)
  +start = frame(w, tx, rest, groupRest, 1n, items)
  +removed = P.remove(items, 1n)
  +finish = frame(w, tx, rest, groupRest, 0n, items)
  Equal.trans(R.World, L.unlink(start, 1n), branch(start, B.contains(items, 1n), removed), finish,
    entry(w, tx, rest, groupRest, items),
    Equal.trans(R.World, branch(start, B.contains(items, 1n), removed), branch(start, False{}, removed), finish,
      Equal.cong(Bool, R.World, found => branch(start, found, removed), B.contains(items, 1n), False{}, excludesTarget(prefix)),
      absentResult(w, tx, rest, groupRest, items, removed)))

# The link guard's remaining source branch, checked below against linkLanes.
def differentLink(+w: R.World, +b: Nat, +ga: Nat, +gb: Nat) -> R.World:
  B.choose(~R.World, Nat.is_eq(gb, 0n),
    _ =>
      +w = L.storeGroup(w, ga, B.append(Nat, L.groups(w, ga), [b]))
      B.store_transaction(w, b, R.Transaction.with_links(B.transaction(w, b), ga)),
    _ => L.groupLoop(1n+B.length(Nat, L.groups(w, gb)), w, 0n, ga, gb))

def finishLink(+w: R.World, +b: Nat, +ga: Nat, +gb: Nat) -> R.World:
  B.choose(~R.World, Nat.is_eq(gb, ga), _ => w, _ => differentLink(w, b, ga, gb))

def sameNat(+n: Nat) -> {Nat.is_eq(n, n) == True{} : Bool}:
  match n:
    case 0n:
      {==}
    case 1n+p:
      sameNat(p)

def finishSame(+w: R.World, +b: Nat, +group: Nat) -> {finishLink(w, b, group, group) == w : R.World}:
  Equal.cong(Bool, R.World, same => B.choose(~R.World, same, _ => w, _ => differentLink(w, b, group, group)), Nat.is_eq(group, group), True{}, sameNat(group))

def linkedFrame(w: R.World, a: R.Transaction, b: R.Transaction, rest: List<&2, R.Transaction>, +group: Nat) -> R.World:
  R.World.with_txArena(w, B.blank_transaction() <> R.Transaction.with_links(a, 1n+group) <> R.Transaction.with_links(b, 1n+group) <> rest)
def linkedEntry(+w: R.World, +a: R.Transaction, +b: R.Transaction, +rest: List<&2, R.Transaction>, +group: Nat) ->
  {L.linkLanes(linkedFrame(w, a, b, rest, group), 1n, 2n) == finishLink(linkedFrame(w, a, b, rest, group), 2n, 1n+group, 1n+group) : R.World}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match a:
        case R.Transaction{+a_nodes, +a_renderQueue, +a_userQueue, +a_reruns, +a_into, +a_parent, +a_lane, +a_verdict, +a_open, +a_acted, +a_links, +a_shown, +a_held, +a_marks}:
          match b:
            case R.Transaction{+b_nodes, +b_renderQueue, +b_userQueue, +b_reruns, +b_into, +b_parent, +b_lane, +b_verdict, +b_open, +b_acted, +b_links, +b_shown, +b_held, +b_marks}:
              {==}

def alreadyLinked(+w: R.World, +a: R.Transaction, +b: R.Transaction, +rest: List<&2, R.Transaction>, +group: Nat) ->
  {L.linkLanes(linkedFrame(w, a, b, rest, group), 1n, 2n) == linkedFrame(w, a, b, rest, group) : R.World}:
  +start = linkedFrame(w, a, b, rest, group)
  Equal.trans(R.World, L.linkLanes(start, 1n, 2n), finishLink(start, 2n, 1n+group, 1n+group), start,
    linkedEntry(w, a, b, rest, group), finishSame(start, 2n, 1n+group))

def selfFrame(+w: R.World, tx: R.Transaction, rest: List<&2, R.Transaction>, groupRest: List<&2, List<&2, Nat>>) -> R.World:
  +w = R.World.with_txArena(w, B.blank_transaction() <> R.Transaction.with_links(tx, 0n) <> rest)
  R.World.with_laneState(w, R.LaneState.with_groups(R.World.laneState(w), [] <> groupRest))

def selfAllocated(+w: R.World, tx: R.Transaction, rest: List<&2, R.Transaction>, +groupRest: List<&2, List<&2, Nat>>) -> R.World:
  +group = {1n+B.length(List<&2, Nat>, groupRest) : Nat}
  +w = R.World.with_txArena(w, B.blank_transaction() <> R.Transaction.with_links(tx, group) <> rest)
  R.World.with_laneState(w, R.LaneState.with_groups(R.World.laneState(w), B.append(List<&2, Nat>, [] <> groupRest, [[1n]])))

def selfEntry(+w: R.World, +tx: R.Transaction, +rest: List<&2, R.Transaction>, +groupRest: List<&2, List<&2, Nat>>) ->
  {L.linkLanes(selfFrame(w, tx, rest, groupRest), 1n, 1n) == finishLink(selfAllocated(w, tx, rest, groupRest), 1n, 1n+B.length(List<&2, Nat>, groupRest), 1n+B.length(List<&2, Nat>, groupRest)) : R.World}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      match w_laneState:
        case R.LaneState{+l_live, +l_groups, +l_stagedReaders, +l_pendingGuesses, +l_judged, +l_root, +l_entered}:
          match tx:
            case R.Transaction{+t_nodes, +t_renderQueue, +t_userQueue, +t_reruns, +t_into, +t_parent, +t_lane, +t_verdict, +t_open, +t_acted, +t_links, +t_shown, +t_held, +t_marks}:
              {==}

def selfLink(+w: R.World, +tx: R.Transaction, +rest: List<&2, R.Transaction>, +groupRest: List<&2, List<&2, Nat>>) ->
  {L.linkLanes(selfFrame(w, tx, rest, groupRest), 1n, 1n) == selfAllocated(w, tx, rest, groupRest) : R.World}:
  +start = selfFrame(w, tx, rest, groupRest)
  +finish = selfAllocated(w, tx, rest, groupRest)
  +group = {1n+B.length(List<&2, Nat>, groupRest) : Nat}
  Equal.trans(R.World, L.linkLanes(start, 1n, 1n), finishLink(finish, 1n, group, group), finish,
    selfEntry(w, tx, rest, groupRest), finishSame(finish, 1n, group))
