# General read policy at the actual fast-read and selected-serve helpers.
# These do not claim their callers always reach this post-status return point.
import Base
import ../runtime/core.bend as C
import ../runtime/transaction.bend as X
import ../runtime/read-state.bend as V
import ../representation/base.bend as B
import ../representation/records.bend as R

def scope(w: R.World, arena: List<&2, R.Node>) -> R.World:
  R.World.with_context(R.World.with_nodes(w, B.blank_node() <> arena), 0n)

law committed_fast_read:
  for +w: R.World
  for +arena: List<&2, R.Node>
  for +tasks: List<&2, C.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  {C.readSignalFast(scope(w, arena), tasks, stack, id) == C.Machine{
    B.event(scope(w, arena), R.ReadValue{0n, id, R.Node.value(B.node(scope(w, arena), id))}),
    tasks, R.Node.value(B.node(scope(w, arena), id)) <> stack} : C.Machine}

def committed_fast_read(w, arena, tasks, stack, id):
  match w:
    case R.World{nodes, links, buckets, minimum, maximum, marked, pendingNodes, trims, renderQueue, userQueue, context, tracking, running, scheduled, clock, epoch, tree, events, fault, unflushedStaged, promotedWrites, extensions, cleanupPrograms, dormantNodes, errorSerial, halted, haltNotified, reports, callbackEffect, txArena, transactions, flushTransaction, passTx, passLane, judge, deferredZombies, question, pendingSets, asyncObjects, asyncObservers, hostJobs, syncDepth, streamPlans, iterators, streams, iteratorEvents, awaiters, truthReadHook, truthConfirmedHook, questions, abortInputs, contextKeys, contextRecords, deferredReleases, releaseLists, stale, settledCallbacks, reactions, comparators, actionDepth, actions, actionWaits, arrays, repeats, maps, activeMarks, laneState, verdictState, cleanupError, +w_ambientMarks, +w_deferredArena}:
      {==}

# A call with no reactive reader cannot join/borrow a held transaction.
law unowned_read_does_not_join:
  for +w: R.World
  for +id: Nat
  for slow: Bool
  {X.enterRead(w, 0n, id, slow) == B.Bundle{w, False{}} : B.Bundle<R.World, Bool>}

def unowned_read_does_not_join(w, id, slow):
  {==}

# The slow serve point, after pending/error handling and unflushed-value
# selection, serves committed for c=null while retaining the actual ambient
# observer. A pre-existing fault yields no successful read observation.
law zero_posture_selected_read_preserves_faults:
  for +w: R.World
  for +tasks: List<&2, C.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  {C.serveSelected(w, tasks, stack, id, 0n, R.Empty{})
    == B.choose(~C.Machine,Bool.not(B.ok(w)),_=>C.Machine{w,tasks,stack},_=>C.served(w,tasks,stack,B.parentComputed(w,R.World.context(w)),id,R.Node.value(B.node(w,id)))) : C.Machine}

def zero_posture_selected_read_preserves_faults(w, tasks, stack, id):
  {==}

# A selected unflushed value takes precedence and marks the late linker.
law unflushed_value_is_selected:
  for +w: R.World
  for +tasks: List<&2, C.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  for +reader: Nat
  for +value: R.Value
  {C.serveSelected(w, tasks, stack, id, reader, R.Present{value})
    == C.served(V.markLateLinker(w, reader), tasks, stack, B.parentComputed(V.markLateLinker(w,reader),R.World.context(V.markLateLinker(w,reader))), id, value) : C.Machine}

def unflushed_value_is_selected(w, tasks, stack, id, reader, value):
  {==}
