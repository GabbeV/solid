# Reachable raw create/open/hold entry supplies the fresh-resume source profile.
# Factor hold through its source view; do not assume full-World commutation.
import Base
import ./held-opened-state.bend as State
import ../representation/records.bend as R
import ../runtime/transaction.bend as X
import ./held-body-opened-normal.bend as Opened
import ./action-constructor-state.bend as Normal
import ./ordinary-graph-data.bend as Graph
import ./held-body-owned-profile.bend as Owned
import ./held-source-view.bend as V
import ./held-source-transfer.bend as Transfer
import ./held-write-profile.bend as P
import ./held-preparation-source.bend as Source
import ./held-hold-view.bend as H
import ./held-hold-future.bend as F

def before(+w: R.World,+methods: R.Expr) -> {V.observe(Normal.normalized(w)) == F.future(V.observe(Opened.openedNormalized(w,methods)),1n) : V.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def selectedObserved(+w: R.World,+id: Nat,+t: Nat,+root: Nat) -> {V.observe(Source.flush(X.holdNode(w,id,t),root)) == F.future(H.hold(V.observe(w),id,t),root) : V.View}:
  Equal.trans(V.View,V.observe(Source.flush(X.holdNode(w,id,t),root)),F.future(V.observe(X.holdNode(w,id,t)),root),F.future(H.hold(V.observe(w),id,t),root),F.observed(X.holdNode(w,id,t),root),Equal.cong(V.View,V.View,v=>F.future(v,root),V.observe(X.holdNode(w,id,t)),H.hold(V.observe(w),id,t),H.holdObserved(w,id,t)))

def generic(+w: R.World,+id: Nat,+methods: R.Expr) -> {V.observe(Source.flush(X.holdNode(Opened.openedNormalized(w,methods),id,1n),1n)) == V.observe(X.holdNode(Normal.normalized(w),id,1n)) : V.View}:
  +opened = Opened.openedNormalized(w,methods)
  +normal = Normal.normalized(w)
  +left = Source.flush(X.holdNode(opened,id,1n),1n)
  +right = X.holdNode(normal,id,1n)
  Equal.trans(V.View,V.observe(left),F.future(H.hold(V.observe(opened),id,1n),1n),V.observe(right),selectedObserved(opened,id,1n,1n),Equal.trans(V.View,F.future(H.hold(V.observe(opened),id,1n),1n),H.hold(F.future(V.observe(opened),1n),id,1n),V.observe(right),Equal.sym(V.View,H.hold(F.future(V.observe(opened),1n),id,1n),F.future(H.hold(V.observe(opened),id,1n),1n),F.hold(V.observe(opened),1n,id,1n)),Equal.trans(V.View,H.hold(F.future(V.observe(opened),1n),id,1n),H.hold(V.observe(normal),id,1n),V.observe(right),Equal.cong(V.View,V.View,v=>H.hold(v,id,1n),F.future(V.observe(opened),1n),V.observe(normal),Equal.sym(V.View,V.observe(normal),F.future(V.observe(opened),1n),before(w,methods))),Equal.sym(V.View,V.observe(right),H.hold(V.observe(normal),id,1n),H.holdObserved(normal,id,1n)))))

def opened(+initial: R.Value,methods: R.Expr) -> R.World:
  State.opened(initial,methods)

def actual(+initial: R.Value,+methods: R.Expr) -> {V.observe(Source.flush(opened(initial,methods),1n)) == V.observe(Owned.normalized(initial)) : V.View}:
  +graph = Graph.linked(initial)
  +id = Graph.source(initial)
  +normal = Opened.openedNormalized(graph,methods)
  Equal.trans(V.View,V.observe(Source.flush(opened(initial,methods),1n)),V.observe(Source.flush(X.holdNode(normal,id,1n),1n)),V.observe(Owned.normalized(initial)),Equal.cong(R.World,V.View,w=>V.observe(Source.flush(X.holdNode(w,id,1n),1n)),Normal.opened(initial,methods),normal,Opened.openedExact(initial,methods)),generic(graph,id,methods))

def profile(+initial: R.Value,+methods: R.Expr) -> P.Profile<Source.flush(opened(initial,methods),1n),Graph.source(initial),0n>:
  Transfer.transfer(Owned.normalized(initial),Source.flush(opened(initial,methods),1n),Graph.source(initial),0n,Owned.profile(initial),actual(initial,methods))
