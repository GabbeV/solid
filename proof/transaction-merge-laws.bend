import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X

def root(t: R.Transaction) -> R.Transaction:
  R.Transaction.with_lane(R.Transaction.with_into(t, 0n), False{})

def scope(+w: R.World, +source: R.Transaction, +target: R.Transaction, +suffix: List<&2, R.Transaction>, reverse: Bool) -> R.World:
  R.World.with_txArena(w, B.choose(~List<&2, R.Transaction>, reverse, _ => B.blank_transaction() <> root(target) <> root(source) <> suffix, _ => B.blank_transaction() <> root(source) <> root(target) <> suffix))

def sourceId(reverse: Bool) -> Nat:
  B.choose(~Nat, reverse, _ => 2n, _ => 1n)

def targetId(reverse: Bool) -> Nat:
  B.choose(~Nat, reverse, _ => 1n, _ => 2n)

def merged(w: R.World, source: R.Transaction, target: R.Transaction, suffix: List<&2, R.Transaction>, +reverse: Bool) -> R.World:
  X.mergeResolved(scope(w, source, target, suffix, reverse), sourceId(reverse), targetId(reverse))

def open_sum(+w: R.World, +source: R.Transaction, +target: R.Transaction, +suffix: List<&2, R.Transaction>, +reverse: Bool) ->
  {R.Transaction.open(B.transaction(merged(w, source, target, suffix, reverse), targetId(reverse))) == Nat.add(R.Transaction.open(target), R.Transaction.open(source)) : Nat}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats}:
      match source:
        case R.Transaction{+source_nodes, +source_renderQueue, +source_userQueue, +source_reruns, +source_into, +source_parent, +source_lane, +source_verdict, +source_open, +source_acted, +source_links, +source_shown, +source_held, +source_marks}:
          match target:
            case R.Transaction{+target_nodes, +target_renderQueue, +target_userQueue, +target_reruns, +target_into, +target_parent, +target_lane, +target_verdict, +target_open, +target_acted, +target_links, +target_shown, +target_held, +target_marks}:
              match reverse:
                case False{}:
                  {==}
                case True{}:
                  {==}

def redirects(+w: R.World, +source: R.Transaction, +target: R.Transaction, +suffix: List<&2, R.Transaction>, +reverse: Bool) ->
  {R.Transaction.into(B.transaction(merged(w, source, target, suffix, reverse), sourceId(reverse))) == targetId(reverse) : Nat}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats}:
      match source:
        case R.Transaction{+source_nodes, +source_renderQueue, +source_userQueue, +source_reruns, +source_into, +source_parent, +source_lane, +source_verdict, +source_open, +source_acted, +source_links, +source_shown, +source_held, +source_marks}:
          match target:
            case R.Transaction{+target_nodes, +target_renderQueue, +target_userQueue, +target_reruns, +target_into, +target_parent, +target_lane, +target_verdict, +target_open, +target_acted, +target_links, +target_shown, +target_held, +target_marks}:
              match reverse:
                case False{}:
                  {==}
                case True{}:
                  {==}

def acted_union(+w: R.World, +source: R.Transaction, +target: R.Transaction, +suffix: List<&2, R.Transaction>, +reverse: Bool) ->
  {R.Transaction.acted(B.transaction(merged(w, source, target, suffix, reverse), targetId(reverse))) == Bool.or(R.Transaction.acted(target), R.Transaction.acted(source)) : Bool}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats}:
      match source:
        case R.Transaction{+source_nodes, +source_renderQueue, +source_userQueue, +source_reruns, +source_into, +source_parent, +source_lane, +source_verdict, +source_open, +source_acted, +source_links, +source_shown, +source_held, +source_marks}:
          match target:
            case R.Transaction{+target_nodes, +target_renderQueue, +target_userQueue, +target_reruns, +target_into, +target_parent, +target_lane, +target_verdict, +target_open, +target_acted, +target_links, +target_shown, +target_held, +target_marks}:
              match reverse:
                case False{}:
                  {==}
                case True{}:
                  {==}
