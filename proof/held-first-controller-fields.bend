# Raw first-controller fields through established constructor/hold boundaries.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./held-opened-state.bend as State
import ./held-opened-facts.bend as Facts
import ./held-body-opened-normal.bend as Opened
import ./action-constructor-state.bend as Normal
import ./ordinary-graph-data.bend as Graph
import ./held-controller-data.bend as Data

def normalActions(+w: R.World,+methods: R.Expr) -> {R.World.actions(Opened.openedNormalized(w,methods)) == [Data.first(methods)] : List<&2,R.ActionState>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def actions(+value: R.Value,+methods: R.Expr) -> {R.World.actions(State.opened(value,methods)) == [Data.first(methods)] : List<&2,R.ActionState>}:
  +w = Normal.opened(value,methods)
  +next = Opened.openedNormalized(Graph.linked(value),methods)
  Equal.trans(List<&2,R.ActionState>,R.World.actions(State.opened(value,methods)),R.World.actions(w),[Data.first(methods)],Facts.holdActions(value,methods),Equal.trans(List<&2,R.ActionState>,R.World.actions(w),R.World.actions(next),[Data.first(methods)],Equal.cong(R.World,List<&2,R.ActionState>,state=>R.World.actions(state),w,next,Opened.openedExact(value,methods)),normalActions(Graph.linked(value),methods)))

def cached(+value: R.Value,+methods: R.Expr) -> {R.NodeExtension.transaction(B.extension(State.opened(value,methods),Graph.source(value))) == 1n : Nat}:
  {==}
