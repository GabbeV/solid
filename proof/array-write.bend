# Full-World array write frame property, using actual runtime storage.
import Base
import ../runtime/arrays.bend as Arrays
import ../runtime/flatten.bend as Flatten
import ../representation/base.bend as B
import ../representation/records.bend as R
import ./arena.bend as Arena

def scope(w: R.World, prefix: List<&2, R.ArrayData>, slots: List<&2, R.Slot>, suffix: List<&2, R.ArrayData>) -> R.World:
  R.World.with_arrays(w, B.append(R.ArrayData, prefix, R.ArrayData{slots} <> suffix))

def peek(+w: R.World, +prefix: List<&2, R.ArrayData>, +slots: List<&2, R.Slot>, +suffix: List<&2, R.ArrayData>) ->
  {Arrays.get(scope(w, prefix, slots, suffix), B.length(R.ArrayData, prefix)) == slots : List<&2, R.Slot>}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps}:
      Equal.cong(R.ArrayData, List<&2, R.Slot>, data => R.ArrayData.slots(data),
        B.get(R.ArrayData, B.append(R.ArrayData, prefix, R.ArrayData{slots} <> suffix), B.length(R.ArrayData, prefix), R.ArrayData{[]}),
        R.ArrayData{slots}, Arena.getPrefix(R.ArrayData, prefix, R.ArrayData{slots}, suffix, R.ArrayData{[]}))

def store(+w: R.World, +prefix: List<&2, R.ArrayData>, +old: List<&2, R.Slot>, +suffix: List<&2, R.ArrayData>, +slots: List<&2, R.Slot>) ->
  {R.World.with_arrays(scope(w, prefix, old, suffix), List.set(&2, R.ArrayData, R.World.arrays(scope(w, prefix, old, suffix)), B.length(R.ArrayData, prefix), R.ArrayData{slots})) == scope(w, prefix, slots, suffix) : R.World}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps}:
      Equal.cong(List<&2, R.ArrayData>, R.World, arrays => R.World.with_arrays(R.World{w_nodes, w_links, w_buckets, w_minimum, w_maximum, w_marked, w_pendingNodes, w_trims, w_renderQueue, w_userQueue, w_context, w_tracking, w_running, w_scheduled, w_clock, w_epoch, w_tree, w_events, w_fault, w_unflushedStaged, w_promotedWrites, w_extensions, w_cleanupPrograms, w_dormantNodes, w_errorSerial, w_halted, w_haltNotified, w_reports, w_callbackEffect, w_txArena, w_transactions, w_flushTransaction, w_passTx, w_passLane, w_judge, w_deferredZombies, w_question, w_pendingSets, w_asyncObjects, w_asyncObservers, w_hostJobs, w_syncDepth, w_streamPlans, w_iterators, w_streams, w_iteratorEvents, w_awaiters, w_truthReadHook, w_truthConfirmedHook, w_questions, w_abortInputs, w_contextKeys, w_contextRecords, w_deferredReleases, w_releaseLists, w_stale, w_settledCallbacks, w_reactions, w_comparators, w_actionDepth, w_actions, w_actionWaits, w_arrays, w_repeats, w_maps}, arrays),
        List.set(&2, R.ArrayData, B.append(R.ArrayData, prefix, R.ArrayData{old} <> suffix), B.length(R.ArrayData, prefix), R.ArrayData{slots}),
        B.append(R.ArrayData, prefix, R.ArrayData{slots} <> suffix), Arena.setPrefix(R.ArrayData, prefix, R.ArrayData{old}, suffix, R.ArrayData{slots}))

def putExact(+prefix: List<&2, R.Slot>, +old: R.Slot, +suffix: List<&2, R.Slot>, +value: R.Value) ->
  {B.put(R.Slot, B.append(R.Slot, prefix, old <> suffix), B.length(R.Slot, prefix), R.Empty{}, R.Present{value}) == B.append(R.Slot, prefix, R.Present{value} <> suffix) : List<&2, R.Slot>}:
  match prefix:
    case Nil{}:
      {==}
    case +head <> +tail:
      Equal.cong(List<&2, R.Slot>, List<&2, R.Slot>, xs => head <> xs,
        B.put(R.Slot, B.append(R.Slot, tail, old <> suffix), B.length(R.Slot, tail), R.Empty{}, R.Present{value}),
        B.append(R.Slot, tail, R.Present{value} <> suffix), putExact(tail, old, suffix, value))

def write(+w: R.World, +arraysBefore: List<&2, R.ArrayData>, +slotsBefore: List<&2, R.Slot>, +old: R.Slot, +slotsAfter: List<&2, R.Slot>, +arraysAfter: List<&2, R.ArrayData>, +value: R.Value) ->
  {Arrays.put(scope(w, arraysBefore, B.append(R.Slot, slotsBefore, old <> slotsAfter), arraysAfter), B.length(R.ArrayData, arraysBefore), B.length(R.Slot, slotsBefore), value)
    == scope(w, arraysBefore, B.append(R.Slot, slotsBefore, R.Present{value} <> slotsAfter), arraysAfter) : R.World}:
  +slots = B.append(R.Slot, slotsBefore, old <> slotsAfter)
  +updated = B.put(R.Slot, slots, B.length(R.Slot, slotsBefore), R.Empty{}, R.Present{value})
  +target = B.append(R.Slot, slotsBefore, R.Present{value} <> slotsAfter)
  +start = scope(w, arraysBefore, slots, arraysAfter)
  +identity = B.length(R.ArrayData, arraysBefore)
  +index = B.length(R.Slot, slotsBefore)
  Equal.trans(R.World,
    Arrays.put(start, identity, index, value),
    R.World.with_arrays(start, List.set(&2, R.ArrayData, R.World.arrays(start), identity, R.ArrayData{updated})),
    scope(w, arraysBefore, target, arraysAfter),
    Equal.cong(List<&2, R.Slot>, R.World,
      xs => R.World.with_arrays(start, List.set(&2, R.ArrayData, R.World.arrays(start), identity, R.ArrayData{B.put(R.Slot, xs, index, R.Empty{}, R.Present{value})})),
      Arrays.get(start, identity), slots, peek(w, arraysBefore, slots, arraysAfter)),
    Equal.trans(R.World,
      R.World.with_arrays(start, List.set(&2, R.ArrayData, R.World.arrays(start), identity, R.ArrayData{updated})),
      scope(w, arraysBefore, updated, arraysAfter), scope(w, arraysBefore, target, arraysAfter),
      store(w, arraysBefore, slots, arraysAfter, updated),
      Equal.cong(List<&2, R.Slot>, R.World, xs => scope(w, arraysBefore, xs, arraysAfter), updated, target, putExact(slotsBefore, old, slotsAfter, value))))

def end_slots(+slots: List<&2, R.Slot>, +value: R.Value) ->
  {B.put(R.Slot, slots, B.length(R.Slot, slots), R.Empty{}, R.Present{value}) == B.append(R.Slot, slots, [R.Present{value}]) : List<&2, R.Slot>}:
  match slots:
    case Nil{}:
      {==}
    case +head <> +tail:
      Equal.cong(List<&2, R.Slot>, List<&2, R.Slot>, xs => head <> xs,
        B.put(R.Slot, tail, B.length(R.Slot, tail), R.Empty{}, R.Present{value}),
        B.append(R.Slot, tail, [R.Present{value}]), end_slots(tail, value))

def append_at_index(+w: R.World, +arraysBefore: List<&2, R.ArrayData>, +slots: List<&2, R.Slot>, +arraysAfter: List<&2, R.ArrayData>, +value: R.Value) ->
  {Arrays.put(scope(w, arraysBefore, slots, arraysAfter), B.length(R.ArrayData, arraysBefore), B.length(R.Slot, slots), value) == scope(w, arraysBefore, B.append(R.Slot, slots, [R.Present{value}]), arraysAfter) : R.World}:
  +updated = B.put(R.Slot, slots, B.length(R.Slot, slots), R.Empty{}, R.Present{value})
  +target = B.append(R.Slot, slots, [R.Present{value}])
  +start = scope(w, arraysBefore, slots, arraysAfter)
  +identity = B.length(R.ArrayData, arraysBefore)
  +index = B.length(R.Slot, slots)
  Equal.trans(R.World,
    Arrays.put(start, identity, index, value),
    R.World.with_arrays(start, List.set(&2, R.ArrayData, R.World.arrays(start), identity, R.ArrayData{updated})),
    scope(w, arraysBefore, target, arraysAfter),
    Equal.cong(List<&2, R.Slot>, R.World,
      xs => R.World.with_arrays(start, List.set(&2, R.ArrayData, R.World.arrays(start), identity, R.ArrayData{B.put(R.Slot, xs, index, R.Empty{}, R.Present{value})})),
      Arrays.get(start, identity), slots, peek(w, arraysBefore, slots, arraysAfter)),
    Equal.trans(R.World,
      R.World.with_arrays(start, List.set(&2, R.ArrayData, R.World.arrays(start), identity, R.ArrayData{updated})),
      scope(w, arraysBefore, updated, arraysAfter), scope(w, arraysBefore, target, arraysAfter),
      store(w, arraysBefore, slots, arraysAfter, updated),
      Equal.cong(List<&2, R.Slot>, R.World, xs => scope(w, arraysBefore, xs, arraysAfter), updated, target, end_slots(slots, value))))

def push(+w: R.World, +arraysBefore: List<&2, R.ArrayData>, +slots: List<&2, R.Slot>, +arraysAfter: List<&2, R.ArrayData>, +value: R.Value) ->
  {Flatten.push(scope(w, arraysBefore, slots, arraysAfter), B.length(R.ArrayData, arraysBefore), value) == scope(w, arraysBefore, B.append(R.Slot, slots, [R.Present{value}]), arraysAfter) : R.World}:
  +start = scope(w, arraysBefore, slots, arraysAfter)
  +identity = B.length(R.ArrayData, arraysBefore)
  Equal.trans(R.World,
    Flatten.push(start, identity, value),
    Arrays.put(start, identity, B.length(R.Slot, slots), value),
    scope(w, arraysBefore, B.append(R.Slot, slots, [R.Present{value}]), arraysAfter),
    Equal.cong(Nat, R.World, size => Arrays.put(start, identity, size, value),
      Arrays.length(start, identity), B.length(R.Slot, slots),
      Equal.cong(List<&2, R.Slot>, Nat, xs => B.length(R.Slot, xs), Arrays.get(start, identity), slots, peek(w, arraysBefore, slots, arraysAfter))),
    append_at_index(w, arraysBefore, slots, arraysAfter, value))
