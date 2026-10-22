# Quantified representation properties for the actual array storage helpers.
# These do not assert general JavaScript array semantics or list reconciliation.
import Base
import ../runtime/arrays.bend as Arrays
import ../representation/base.bend as B
import ../representation/records.bend as R
import ./arena.bend as Arena

def holes_length(+size: Nat) -> {B.length(R.Slot, Arrays.holes(size)) == size : Nat}:
  match size:
    case 0n:
      {==}
    case 1n+ +rest:
      Equal.cong(Nat, Nat, value => 1n+value, B.length(R.Slot, Arrays.holes(rest)), rest, holes_length(rest))

# Any valid index in a fresh hole array is actually Empty, not present undefined.
def hole_slot(+prefix: Nat, +suffix: Nat) ->
  {B.get(R.Slot, Arrays.holes(Nat.add(1n+prefix, suffix)), prefix, R.Present{R.Undefined{}}) == R.Empty{} : R.Slot}:
  match prefix:
    case 0n:
      {==}
    case 1n+rest:
      hole_slot(rest, suffix)

def dense_read(+prefix: List<&2, R.Value>, +value: R.Value, +suffix: List<&2, R.Value>) ->
  {B.get(R.Slot, Arrays.slots(B.append(R.Value, prefix, value <> suffix)), B.length(R.Value, prefix), R.Empty{}) == R.Present{value} : R.Slot}:
  match prefix:
    case Nil{}:
      {==}
    case head <> tail:
      dense_read(tail, value, suffix)

# Existing-slot write, with arbitrary surrounding slots and payloads. Holes and
# Present(Undefined) remain distinct even though their indexed reads agree.
def slot_put_read(+prefix: List<&2, R.Slot>, +old: R.Slot, +suffix: List<&2, R.Slot>, +value: R.Value) ->
  {B.get(R.Slot, B.put(R.Slot, B.append(R.Slot, prefix, old <> suffix), B.length(R.Slot, prefix), R.Empty{}, R.Present{value}), B.length(R.Slot, prefix), R.Empty{}) == R.Present{value} : R.Slot}:
  match prefix:
    case Nil{}:
      {==}
    case head <> tail:
      slot_put_read(tail, old, suffix, value)

type Allocation is Data:
  Allocation{identity: Nat, slots: List<&2, R.Slot>, arrays: List<&2, R.ArrayData>, restored: R.World}

def allocation(+w: R.World, +slots: List<&2, R.Slot>) -> Allocation:
  +pair = Arrays.allocate(w, slots)
  +next = B.first(R.World, Nat, pair)
  +identity = B.second(R.World, Nat, pair)
  Allocation{identity, Arrays.get(next, identity), R.World.arrays(next), R.World.with_arrays(next, R.World.arrays(w))}

# Fresh identity, exact contents, and exact preservation of every other World
# field, quantified over the entire surrounding world and any slot vector.
def allocation_contract(+w: R.World, +slots: List<&2, R.Slot>) ->
  {allocation(w, slots) == Allocation{B.length(R.ArrayData, R.World.arrays(w)), slots, B.append(R.ArrayData, R.World.arrays(w), [R.ArrayData{slots}]), w} : Allocation}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks}:
      Equal.cong(R.ArrayData, Allocation,
        data => Allocation{B.length(R.ArrayData, w_arrays), R.ArrayData.slots(data), B.append(R.ArrayData, w_arrays, [R.ArrayData{slots}]), w},
        B.get(R.ArrayData, B.append(R.ArrayData, w_arrays, [R.ArrayData{slots}]), B.length(R.ArrayData, w_arrays), R.ArrayData{[]}),
        R.ArrayData{slots}, Arena.getPrefix(R.ArrayData, w_arrays, R.ArrayData{slots}, [], R.ArrayData{[]}))
