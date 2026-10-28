# The constructed ordinary family has no from/deferred interceptor. Derive
# that fact through real helper prefixes, then use the actual outer async handler.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/from-wrap.bend as Wrapped
import ../runtime/deferred-runtime.bend as Deferred
import ./held-delivery-constructor-state.bend as State
import ./held-opened-state.bend as Opened
import ./held-construction-context.bend as Context
import ./action-helper-context.bend as Helpers
import ./action-wait-history.bend as History
import ./held-action-delivery.bend as Delivery

def erasedFrom(+w: R.World,+observer: Nat) -> {Wrapped.find(Helpers.erase(w),observer) == Wrapped.find(w,observer) : B.Bundle<Nat,Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def erasedDeferred(+w: R.World,+observer: Nat) -> {Deferred.wait(Helpers.erase(w),observer) == Deferred.wait(w,observer) : Maybe<&2,R.DeferredWait>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def rawFrom(+value: R.Value,+methods: R.Expr,+observer: Nat) -> {Wrapped.find(Opened.opened(value,methods),observer) == B.Bundle{0n,0n} : B.Bundle<Nat,Nat>}:
  {==}

def rawDeferred(+value: R.Value,+methods: R.Expr,+observer: Nat) -> {Deferred.wait(Opened.opened(value,methods),observer) == None{} : Maybe<&2,R.DeferredWait>}:
  {==}

def fromZero(+value: R.Value,+methods: R.Expr,+prefix: List<&2,History.WaitEvent>,+observer: Nat) -> {Wrapped.find(State.registered(value,methods,prefix),observer) == B.Bundle{0n,0n} : B.Bundle<Nat,Nat>}:
  +w = State.registered(value,methods,prefix)
  +raw = Opened.opened(value,methods)
  Equal.trans(B.Bundle<Nat,Nat>,Wrapped.find(w,observer),Wrapped.find(Helpers.erase(w),observer),B.Bundle{0n,0n},Equal.sym(B.Bundle<Nat,Nat>,Wrapped.find(Helpers.erase(w),observer),Wrapped.find(w,observer),erasedFrom(w,observer)),Equal.trans(B.Bundle<Nat,Nat>,Wrapped.find(Helpers.erase(w),observer),Wrapped.find(Helpers.erase(raw),observer),B.Bundle{0n,0n},Equal.cong(R.World,B.Bundle<Nat,Nat>,world=>Wrapped.find(world,observer),Helpers.erase(w),Helpers.erase(raw),Context.registered(value,methods,prefix)),Equal.trans(B.Bundle<Nat,Nat>,Wrapped.find(Helpers.erase(raw),observer),Wrapped.find(raw,observer),B.Bundle{0n,0n},erasedFrom(raw,observer),rawFrom(value,methods,observer))))

def deferredZero(+value: R.Value,+methods: R.Expr,+prefix: List<&2,History.WaitEvent>,+observer: Nat) -> {Deferred.wait(State.registered(value,methods,prefix),observer) == None{} : Maybe<&2,R.DeferredWait>}:
  +w = State.registered(value,methods,prefix)
  +raw = Opened.opened(value,methods)
  Equal.trans(Maybe<&2,R.DeferredWait>,Deferred.wait(w,observer),Deferred.wait(Helpers.erase(w),observer),None{},Equal.sym(Maybe<&2,R.DeferredWait>,Deferred.wait(Helpers.erase(w),observer),Deferred.wait(w,observer),erasedDeferred(w,observer)),Equal.trans(Maybe<&2,R.DeferredWait>,Deferred.wait(Helpers.erase(w),observer),Deferred.wait(Helpers.erase(raw),observer),None{},Equal.cong(R.World,Maybe<&2,R.DeferredWait>,world=>Deferred.wait(world,observer),Helpers.erase(w),Helpers.erase(raw),Context.registered(value,methods,prefix)),Equal.trans(Maybe<&2,R.DeferredWait>,Deferred.wait(Helpers.erase(raw),observer),Deferred.wait(raw,observer),None{},erasedDeferred(raw,observer),rawDeferred(value,methods,observer))))

# Checked normal form of core.fromWrapDelivery parameterized by its first lookup.
def route(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+observer: Nat,+rejected: Bool,+value: R.Value,+found: B.Bundle<Nat,Nat>) -> C.Machine:
  +plan = B.first(Nat,Nat,found)
  +output = B.second(Nat,Nat,found)
  B.choose(~C.Machine,Nat.is_ne(output,0n),_=>C.Machine{Wrapped.deliver(w,plan,output,rejected,value),rest,stack},_=>C.deferredDelivery(w,rest,stack,observer,rejected,value,Deferred.wait(w,observer)))

def ordinary(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+observer: Nat,+rejected: Bool,+value: R.Value) -> {C.deferredDelivery(w,rest,stack,observer,rejected,value,None{}) == Delivery.start(w,rest,stack,observer,rejected,value) : C.Machine}:
  match rejected:
    case True{}: {==}
    case False{}: {==}

def unhandled(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+observer: Nat,+rejected: Bool,+value: R.Value,from: {Wrapped.find(w,observer) == B.Bundle{0n,0n} : B.Bundle<Nat,Nat>},deferred: {Deferred.wait(w,observer) == None{} : Maybe<&2,R.DeferredWait>}) -> {C.fromWrapDelivery(w,rest,stack,observer,rejected,value) == Delivery.start(w,rest,stack,observer,rejected,value) : C.Machine}:
  Equal.trans(C.Machine,C.fromWrapDelivery(w,rest,stack,observer,rejected,value),C.deferredDelivery(w,rest,stack,observer,rejected,value,Deferred.wait(w,observer)),Delivery.start(w,rest,stack,observer,rejected,value),Equal.cong(B.Bundle<Nat,Nat>,C.Machine,found=>route(w,rest,stack,observer,rejected,value,found),Wrapped.find(w,observer),B.Bundle{0n,0n},from),Equal.trans(C.Machine,C.deferredDelivery(w,rest,stack,observer,rejected,value,Deferred.wait(w,observer)),C.deferredDelivery(w,rest,stack,observer,rejected,value,None{}),Delivery.start(w,rest,stack,observer,rejected,value),Equal.cong(Maybe<&2,R.DeferredWait>,C.Machine,found=>C.deferredDelivery(w,rest,stack,observer,rejected,value,found),Deferred.wait(w,observer),None{},deferred),ordinary(w,rest,stack,observer,rejected,value)))

def constructed(+initial: R.Value,+methods: R.Expr,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+rejected: Bool,+value: R.Value) -> {C.fromWrapDelivery(State.registered(initial,methods,prefix),rest,stack,State.observer(initial,methods,prefix),rejected,value) == Delivery.start(State.registered(initial,methods,prefix),rest,stack,State.observer(initial,methods,prefix),rejected,value) : C.Machine}:
  +w = State.registered(initial,methods,prefix)
  +observer = State.observer(initial,methods,prefix)
  unhandled(w,rest,stack,observer,rejected,value,fromZero(initial,methods,prefix,observer),deferredZero(initial,methods,prefix,observer))
