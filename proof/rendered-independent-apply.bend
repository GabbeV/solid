# Actual application of an independent renderer preserves selected mounted text
# and selected application events. A queued application callback is not run.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/scheduler.bend as S
import ../observation/tree.bend as T
import ./rendered-observation.bend as View

def afterEvent(+w: R.World, +id: Nat) -> R.World:
  B.choose(~R.World, S.is_user(R.Node.kind(B.node(w, id))), _ => w,
    _ => T.setText(w, R.Node.target(B.node(w, id)), R.Node.value(B.node(w, id))))

def applyWorld(+w: R.World, +id: Nat) -> R.World:
  +w = B.event(w, R.Applied{id, R.Node.value(B.node(w, id)), R.Node.prevValue(B.node(w, id))})
  B.choose(~R.World, S.is_user(R.Node.kind(B.node(w, id))), _ => w,
    _ => T.setText(w, R.Node.target(B.node(w, id)), R.Node.value(B.node(w, id))))

def worldExact(w: R.World, rest: List<&2, C.Task>, stack: List<&2, R.Value>, id: Nat) ->
  {C.world(C.applyEffect(w, rest, stack, id)) == applyWorld(w, id) : R.World}:
  {==}

def afterFrame(+renderers: List<&2, Nat>, +targets: List<&2, Nat>, +w: R.World, +id: Nat,
  absent: {B.contains(targets, R.Node.target(B.node(w, id))) == False{} : Bool}) ->
  {View.observe(renderers, targets, afterEvent(w, id)) == View.observe(renderers, targets, w) : View.View}:
  View.choice(S.is_user(R.Node.kind(B.node(w, id))), renderers, targets, w, w, T.setText(w, R.Node.target(B.node(w, id)), R.Node.value(B.node(w, id))), {==}, View.textOther(renderers, targets, w, R.Node.target(B.node(w, id)), R.Node.value(B.node(w, id)), absent))

def eventNode(w: R.World, event: R.TraceEvent, +id: Nat) ->
  {B.node(B.event(w, event), id) == B.node(w, id) : R.Node}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def worldFrame(+renderers: List<&2, Nat>, +targets: List<&2, Nat>, +w: R.World, +id: Nat,
  absentRenderer: {B.contains(renderers, id) == False{} : Bool},
  absentTarget: {B.contains(targets, R.Node.target(B.node(w, id))) == False{} : Bool}) ->
  {View.observe(renderers, targets, applyWorld(w, id)) == View.observe(renderers, targets, w) : View.View}:
  +event = {R.Applied{id, R.Node.value(B.node(w, id)), R.Node.prevValue(B.node(w, id))} : R.TraceEvent}
  +next = B.event(w, event)
  +stillAbsent = Equal.trans(Bool, B.contains(targets, R.Node.target(B.node(next, id))), B.contains(targets, R.Node.target(B.node(w, id))), False{}, Equal.cong(R.Node, Bool, node => B.contains(targets, R.Node.target(node)), B.node(next, id), B.node(w, id), eventNode(w, event, id)), absentTarget)
  View.compose(renderers, targets, w, next, applyWorld(w, id), afterFrame(renderers, targets, next, id, stillAbsent), View.eventOther(renderers, targets, w, id, R.Node.value(B.node(w, id)), R.Node.prevValue(B.node(w, id)), absentRenderer))

def actualFrame(+renderers: List<&2, Nat>, +targets: List<&2, Nat>, +w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat,
  absentRenderer: {B.contains(renderers, id) == False{} : Bool},
  absentTarget: {B.contains(targets, R.Node.target(B.node(w, id))) == False{} : Bool}) ->
  {View.observe(renderers, targets, C.world(C.applyEffect(w, rest, stack, id))) == View.observe(renderers, targets, w) : View.View}:
  Equal.trans(View.View, View.observe(renderers, targets, C.world(C.applyEffect(w, rest, stack, id))), View.observe(renderers, targets, applyWorld(w, id)), View.observe(renderers, targets, w),
    Equal.cong(R.World, View.View, result => View.observe(renderers, targets, result), C.world(C.applyEffect(w, rest, stack, id)), applyWorld(w, id), worldExact(w, rest, stack, id)), worldFrame(renderers, targets, w, id, absentRenderer, absentTarget))

def stack(w: R.World, rest: List<&2, C.Task>, +stack: List<&2, R.Value>, id: Nat) ->
  {C.values(C.applyEffect(w, rest, stack, id)) == stack : List<&2, R.Value>}:
  {==}

def machineChoice(+condition: Bool, +renderers: List<&2, Nat>, +targets: List<&2, Nat>, +w: R.World, +left: C.Machine, +right: C.Machine,
  leftFrame: {View.observe(renderers, targets, C.world(left)) == View.observe(renderers, targets, w) : View.View},
  rightFrame: {View.observe(renderers, targets, C.world(right)) == View.observe(renderers, targets, w) : View.View}) ->
  {View.observe(renderers, targets, C.world(B.choose(~C.Machine, condition, _ => left, _ => right))) == View.observe(renderers, targets, w) : View.View}:
  match condition:
    case True{}: leftFrame
    case False{}: rightFrame

def stepFrame(+renderers: List<&2, Nat>, +targets: List<&2, Nat>, +w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat,
  absentRenderer: {B.contains(renderers, id) == False{} : Bool},
  absentTarget: {B.contains(targets, R.Node.target(B.node(w, id))) == False{} : Bool}) ->
  {View.observe(renderers, targets, C.world(C.step(C.Machine{w, C.ApplyEffect{id} <> rest, stack}))) == View.observe(renderers, targets, w) : View.View}:
  machineChoice(B.ok(w), renderers, targets, w, C.applyEffect(w, rest, stack, id), C.Machine{w, rest, stack}, actualFrame(renderers, targets, w, rest, stack, id, absentRenderer, absentTarget), {==})
