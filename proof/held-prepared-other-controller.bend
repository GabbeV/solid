# Real action preparation replaces only the selected controller's method.
# A different controller retains its complete record through question/join,
# depth entry and the selected-method store. No final record is supplied.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ./list-update-lookup.bend as Lens
import ./action-body-entry.bend as Entry
import ./held-preparation-control.bend as Control

def storedOther(+w: R.World,+actor: Nat,+other: Nat,+record: R.ActionState,different: {Nat.is_eq(other,actor) == False{} : Bool}) -> {A.get(A.store(w,actor,record),other) == A.get(w,other) : R.ActionState}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Lens.setOther(R.ActionState,actions,actor,other,A.blank(),record,different)

def joinedOther(+w: R.World,+actor: Nat,+other: Nat) -> {A.get(Entry.joined(w,actor),other) == A.get(w,other) : R.ActionState}:
  Equal.cong(List<&2,R.ActionState>,R.ActionState,rows=>B.get(R.ActionState,rows,other,A.blank()),R.World.actions(Entry.joined(w,actor)),R.World.actions(w),Entry.actions(w,actor))

def preparedOther(+w: R.World,+actor: Nat,+other: Nat,+tail: R.Expr,different: {Nat.is_eq(other,actor) == False{} : Bool}) -> {A.get(Entry.prepared(w,actor,tail),other) == A.get(w,other) : R.ActionState}:
  +joined = Entry.joined(w,actor)
  +entered = A.enter(joined)
  +record = R.ActionState.with_methods(A.get(joined,actor),tail)
  Equal.trans(R.ActionState,A.get(Entry.prepared(w,actor,tail),other),A.get(entered,other),A.get(w,other),storedOther(entered,actor,other,record,different),Equal.trans(R.ActionState,A.get(entered,other),A.get(joined,other),A.get(w,other),Control.enterRead(joined,other),joinedOther(w,actor,other)))
