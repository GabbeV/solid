# Constructor/controller helper prefixes retain the whole surrounding World
# except async objects, observers, wait cells and pending host requests.
import Base
import ../runtime/flight.bend as F
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./held-delivery-constructor-state.bend as State
import ./held-opened-state.bend as Opened
import ./action-helper-context.bend as Context
import ./action-wait-history.bend as History
import ./action-control-flags.bend as Flags

def future(+w: R.World) -> R.World:
  B.first(R.World,Nat,F.newThenable(w,False{},R.Unresolved{}))

def futureErased(+w: R.World) -> {Context.erase(future(w)) == Context.erase(w) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def registered(+value: R.Value,+methods: R.Expr,+prefix: List<&2,History.WaitEvent>) -> {Context.erase(State.registered(value,methods,prefix)) == Context.erase(Opened.opened(value,methods)) : R.World}:
  +w = Opened.opened(value,methods)
  +before = State.before(value,methods,prefix)
  +initial = State.initial(value,methods)
  Equal.trans(R.World,Context.erase(State.registered(value,methods,prefix)),Context.erase(before),Context.erase(w),Context.registered(before,0n,State.result(value,methods),0),Equal.trans(R.World,Context.erase(before),Context.erase(initial),Context.erase(w),Context.history(prefix,initial),futureErased(w)))

def flags(+value: R.Value,+methods: R.Expr,+prefix: List<&2,History.WaitEvent>) -> {Flags.observe(State.registered(value,methods,prefix)) == Flags.Flags{0n,False{},False{}} : Flags.View}:
  Equal.trans(Flags.View,Flags.observe(State.registered(value,methods,prefix)),Flags.observe(Opened.opened(value,methods)),Flags.Flags{0n,False{},False{}},Flags.fromHelpers(Opened.opened(value,methods),State.registered(value,methods,prefix),registered(value,methods,prefix)),Flags.raw(value,methods))
