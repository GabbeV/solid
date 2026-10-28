# Real helper registration and finite helper histories preserve the source
# profile and action/debt observations used by a resumed held body.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/flight.bend as F
import ./action-helper-context.bend as Context
import ./action-wait-history.bend as History
import ./action-wait-allocation.bend as Allocation
import ./held-source-view.bend as V
import ./held-hold-control.bend as Control
import ./held-preparation-source.bend as Source
import ./held-source-transfer.bend as Transfer
import ./held-write-profile.bend as P

def future(+w: R.World) -> R.World:
  B.first(R.World,Nat,F.newThenable(w,False{},R.Unresolved{}))

def result(+w: R.World) -> Nat:
  B.second(R.World,Nat,F.newThenable(w,False{},R.Unresolved{}))

def erasedSource(+w: R.World,+root: Nat) -> {V.observe(Source.flush(Context.erase(w),root)) == V.observe(Source.flush(w,root)) : V.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def erasedControl(+w: R.World) -> {Control.observe(Context.erase(w)) == Control.observe(w) : Control.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def futureSource(+w: R.World,+root: Nat) -> {V.observe(Source.flush(future(w),root)) == V.observe(Source.flush(w,root)) : V.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def futureControl(+w: R.World) -> {Control.observe(future(w)) == Control.observe(w) : Control.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def source(+w: R.World,+next: R.World,+root: Nat,same: {Context.erase(next) == Context.erase(w) : R.World}) -> {V.observe(Source.flush(next,root)) == V.observe(Source.flush(w,root)) : V.View}:
  Equal.trans(V.View,V.observe(Source.flush(next,root)),V.observe(Source.flush(Context.erase(next),root)),V.observe(Source.flush(w,root)),Equal.sym(V.View,V.observe(Source.flush(Context.erase(next),root)),V.observe(Source.flush(next,root)),erasedSource(next,root)),Equal.trans(V.View,V.observe(Source.flush(Context.erase(next),root)),V.observe(Source.flush(Context.erase(w),root)),V.observe(Source.flush(w,root)),Equal.cong(R.World,V.View,state=>V.observe(Source.flush(state,root)),Context.erase(next),Context.erase(w),same),erasedSource(w,root)))

def control(+w: R.World,+next: R.World,same: {Context.erase(next) == Context.erase(w) : R.World}) -> {Control.observe(next) == Control.observe(w) : Control.View}:
  Equal.trans(Control.View,Control.observe(next),Control.observe(Context.erase(next)),Control.observe(w),Equal.sym(Control.View,Control.observe(Context.erase(next)),Control.observe(next),erasedControl(next)),Equal.trans(Control.View,Control.observe(Context.erase(next)),Control.observe(Context.erase(w)),Control.observe(w),Equal.cong(R.World,Control.View,state=>Control.observe(state),Context.erase(next),Context.erase(w),same),erasedControl(w)))

def registerSource(+w: R.World,+actor: Nat,+result: Nat,+kind: U32,+root: Nat) -> {V.observe(Source.flush(Allocation.after(w,actor,result,kind),root)) == V.observe(Source.flush(w,root)) : V.View}:
  source(w,Allocation.after(w,actor,result,kind),root,Context.registered(w,actor,result,kind))

def registerControl(+w: R.World,+actor: Nat,+result: Nat,+kind: U32) -> {Control.observe(Allocation.after(w,actor,result,kind)) == Control.observe(w) : Control.View}:
  control(w,Allocation.after(w,actor,result,kind),Context.registered(w,actor,result,kind))

def historySource(+events: List<&2,History.WaitEvent>,+w: R.World,+root: Nat) -> {V.observe(Source.flush(History.run(events,w),root)) == V.observe(Source.flush(w,root)) : V.View}:
  source(w,History.run(events,w),root,Context.history(events,w))

def historyControl(+events: List<&2,History.WaitEvent>,+w: R.World) -> {Control.observe(History.run(events,w)) == Control.observe(w) : Control.View}:
  control(w,History.run(events,w),Context.history(events,w))

def futureProfile(+w: R.World,+id: Nat,+offset: Nat,profile: P.Profile<Source.flush(w,1n+offset),id,offset>) -> P.Profile<Source.flush(future(w),1n+offset),id,offset>:
  Transfer.transfer(Source.flush(w,1n+offset),Source.flush(future(w),1n+offset),id,offset,profile,futureSource(w,1n+offset))

def registeredProfile(+w: R.World,+actor: Nat,+result: Nat,+kind: U32,+id: Nat,+offset: Nat,profile: P.Profile<Source.flush(w,1n+offset),id,offset>) -> P.Profile<Source.flush(Allocation.after(w,actor,result,kind),1n+offset),id,offset>:
  Transfer.transfer(Source.flush(w,1n+offset),Source.flush(Allocation.after(w,actor,result,kind),1n+offset),id,offset,profile,registerSource(w,actor,result,kind,1n+offset))

def historyProfile(+events: List<&2,History.WaitEvent>,+w: R.World,+id: Nat,+offset: Nat,profile: P.Profile<Source.flush(w,1n+offset),id,offset>) -> P.Profile<Source.flush(History.run(events,w),1n+offset),id,offset>:
  Transfer.transfer(Source.flush(w,1n+offset),Source.flush(History.run(events,w),1n+offset),id,offset,profile,historySource(events,w,1n+offset))
