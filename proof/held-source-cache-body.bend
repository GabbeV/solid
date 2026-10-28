# A nonempty real body resolves an initially redirected source cache on its
# first setter, even when equality suppresses staging. The successor certificate
# is derived, then the existing canonical held-body theorem handles the tail.
# Zero setters deliberately do not normalize the source cache.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/write.bend as W
import ../runtime/equality.bend as Equality
import ../runtime/constants.bend as K
import ./held-source-cache-rebase.bend as Cache
import ./transaction-rejoin-history.bend as Alias
import ./held-write-profile.bend as P
import ./held-body-evaluation.bend as Eval
import ./held-write-history.bend as History
import ./ordinary-updater-evaluation.bend as Write
import ./action-body-return.bend as Body
import ./pending-stack-history.bend as Steps
import ./core-prefix-compose.bend as Prefix
import ./core-run-prefix.bend as Driver

type Facts<-w: R.World,-id: Nat> is Data:
  CacheReady{healthy: {R.World.fault(w) == R.Healthy{} : R.Fault},signal: {C.memoNode(R.Node.kind(B.node(w,id))) == False{} : Bool},override: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_OVERRIDE()) == False{} : Bool},custom: {Equality.custom(w,id) == 0n : Nat}}

def fault(+w: R.World,+id: Nat,+root: Nat) -> {R.World.fault(Cache.canonical(w,id,root)) == R.World.fault(w) : R.Fault}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def sameCustom(+w: R.World,+id: Nat,+root: Nat) -> {Equality.custom(Cache.canonical(w,id,root),id) == Equality.custom(w,id) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def facts(+w: R.World,+id: Nat,+offset: Nat,profile: P.Profile<Cache.canonical(w,id,1n+offset),id,offset>) -> Facts<w,id>:
  match profile:
    case P.HeldAt{path,extra,health,unmarked,valid,head,room,context,+signal,held,+override,+custom,existing,extensionRoom,canonical,future,terminal,groupRoom}:
      +next = Cache.canonical(w,id,1n+offset)
      +node = Equal.sym(R.Node,B.node(next,id),B.node(w,id),Cache.node(w,id,1n+offset,id))
      CacheReady{Equal.trans(R.Fault,R.World.fault(w),R.World.fault(next),R.Healthy{},Equal.sym(R.Fault,R.World.fault(next),R.World.fault(w),fault(w,id,1n+offset)),health),Equal.trans(Bool,C.memoNode(R.Node.kind(B.node(w,id))),C.memoNode(R.Node.kind(B.node(next,id))),False{},Equal.cong(R.Node,Bool,n=>C.memoNode(R.Node.kind(n)),B.node(w,id),B.node(next,id),node),Equal.cong(R.NodeKind,Bool,kind=>C.memoNode(kind),R.Node.kind(B.node(next,id)),R.Signal{},signal)),Equal.trans(Bool,B.has(R.Node.config(B.node(w,id)),K.CONFIG_OVERRIDE()),B.has(R.Node.config(B.node(next,id)),K.CONFIG_OVERRIDE()),False{},Equal.cong(R.Node,Bool,n=>B.has(R.Node.config(n),K.CONFIG_OVERRIDE()),B.node(w,id),B.node(next,id),node),override),Equal.trans(Nat,Equality.custom(w,id),Equality.custom(next,id),0n,Equal.sym(Nat,Equality.custom(next,id),Equality.custom(w,id),sameCustom(w,id,1n+offset)),custom)}

def health(-w: R.World,-id: Nat,facts: Facts<w,id>) -> {R.World.fault(w) == R.Healthy{} : R.Fault}:
  match facts:
    case CacheReady{healthy,signal,override,custom}: healthy

def updater(+w: R.World,+id: Nat,+value: R.Value,+previous: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,facts: Facts<w,id>) -> {Steps.iterate(3n,Write.start(w,rest,stack,id,value,previous)) == Write.updated(w,rest,stack,id,value) : C.Machine}:
  match facts:
    case CacheReady{healthy,signal,override,custom}: Write.complete(w,rest,stack,id,value,previous,healthy,signal,override,custom)

def first(+w: R.World,+head: R.Value,+tail: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,+alias: Alias.Alias<w,1n+offset>,cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,alias) : Nat},+profile: P.Profile<Cache.canonical(w,id,1n+offset),id,offset>) -> {Steps.iterate(5n,Eval.start(w,head <> tail,id,answer,rest,stack)) == Eval.start(W.setSignal(w,id,head),tail,id,answer,rest,stack) : C.Machine}:
  +ready = facts(w,id,offset,profile)
  +before = Eval.start(w,head <> tail,id,answer,rest,stack)
  +after = Eval.discard(w,head,tail,id,answer,rest,stack)
  +work = {C.Discard{} <> C.Evaluate{Eval.expression(tail,id,answer),R.Undefined{}} <> rest : List<&2,C.Task>}
  +entry = Body.healthyStep(w,C.Evaluate{Eval.expression(head <> tail,id,answer),R.Undefined{}},rest,stack,Body.health(w,health(w,id,ready)))
  Driver.appendStep(4n,before,after,Eval.start(W.setSignal(w,id,head),tail,id,answer,rest,stack),Prefix.compose(1n,3n,before,Eval.entered(w,head,tail,id,answer,rest,stack),after,entry,updater(w,id,head,R.Undefined{},work,stack,ready)),Eval.discards(w,head,tail,id,answer,rest,stack,offset,Cache.successor(w,id,offset,head,alias,cached,profile)))

def complete(+w: R.World,+head: R.Value,+tail: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,+alias: Alias.Alias<w,1n+offset>,+cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,alias) : Nat},+profile: P.Profile<Cache.canonical(w,id,1n+offset),id,offset>) -> {Steps.iterate(Eval.cost(head <> tail),Eval.start(w,head <> tail,id,answer,rest,stack)) == Eval.finished(w,head <> tail,id,answer,rest,stack) : C.Machine}:
  +next = W.setSignal(w,id,head)
  Prefix.compose(5n,Eval.cost(tail),Eval.start(w,head <> tail,id,answer,rest,stack),Eval.start(next,tail,id,answer,rest,stack),Eval.finished(w,head <> tail,id,answer,rest,stack),first(w,head,tail,id,answer,rest,stack,offset,alias,cached,profile),Eval.complete(tail,next,id,answer,rest,stack,offset,Cache.successor(w,id,offset,head,alias,cached,profile)))

def afterProfile(+w: R.World,+head: R.Value,+tail: List<&2,R.Value>,+id: Nat,+offset: Nat,+alias: Alias.Alias<w,1n+offset>,cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,alias) : Nat},profile: P.Profile<Cache.canonical(w,id,1n+offset),id,offset>) -> P.Profile<History.run(head <> tail,w,id),id,offset>:
  History.invariant(tail,W.setSignal(w,id,head),id,offset,Cache.successor(w,id,offset,head,alias,cached,profile))
