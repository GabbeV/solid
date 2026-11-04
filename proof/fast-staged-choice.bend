# Actual fast selection after a non-verdict held entry. The value domain is
# arbitrary; strict equality and SameValue are both retained in the netting gate.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/constants.bend as K
import ../runtime/read-transaction.bend as ReadTx
import ./read-entry-metadata.bend as M

def globalsChoice(+test: Bool,+w: R.World,+yes: R.World,+no: R.World,left: {M.globals(yes) == M.globals(w) : M.GlobalView},right: {M.globals(no) == M.globals(w) : M.GlobalView}) -> {M.globals(B.choose(~R.World,test,_=>yes,_=>no)) == M.globals(w) : M.GlobalView}:
  match test:
    case True{}: left
    case False{}: right

def collect(+w: R.World,reader: Nat) -> R.World:
  +state = R.World.laneState(w)
  R.World.with_laneState(w,R.LaneState.with_stagedReaders(state,B.append(Nat,R.LaneState.stagedReaders(state),[reader])))

def collectGlobals(+w: R.World,reader: Nat) -> {M.globals(collect(w,reader)) == M.globals(w) : M.GlobalView}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}: {==}

def marked(+w: R.World,+reader: Nat) -> R.World:
  B.store_node(w,reader,R.Node.with_flags(B.node(w,reader),B.set(R.Node.flags(B.node(w,reader)),K.REACTIVE_STAGED_READ())))

def afterMark(+w: R.World,+reader: Nat) -> R.World:
  +next = marked(w,reader)
  B.choose(~R.World,Bool.and(Nat.is_eq(R.World.passLane(next),0n),Bool.not(Bool.and(B.effect(R.Node.kind(B.node(next,reader))),B.has(R.Node.config(B.node(next,reader)),K.CONFIG_VERDICT())))),_=>next,_=>collect(next,reader))

def afterMarkGlobals(+w: R.World,+reader: Nat) -> {M.globals(afterMark(w,reader)) == M.globals(w) : M.GlobalView}:
  +next = marked(w,reader)
  +gate = Bool.and(Nat.is_eq(R.World.passLane(next),0n),Bool.not(Bool.and(B.effect(R.Node.kind(B.node(next,reader))),B.has(R.Node.config(B.node(next,reader)),K.CONFIG_VERDICT()))))
  Equal.trans(M.GlobalView,M.globals(afterMark(w,reader)),M.globals(next),M.globals(w),globalsChoice(gate,next,next,collect(next,reader),{==},collectGlobals(next,reader)),M.storeGlobals(w,reader,R.Node.with_flags(B.node(w,reader),B.set(R.Node.flags(B.node(w,reader)),K.REACTIVE_STAGED_READ()))))

def stagedShape(+w: R.World,+reader: Nat,+source: Nat) -> {C.stagedRead(w,reader,source) == B.choose(~R.World,B.has(R.Node.status(B.node(w,source)),K.STATUS_UNINITIALIZED()),_=>w,_=>afterMark(w,reader)) : R.World}:
  {==}

def stagedGlobals(+w: R.World,+reader: Nat,+source: Nat) -> {M.globals(C.stagedRead(w,reader,source)) == M.globals(w) : M.GlobalView}:
  Equal.trans(M.GlobalView,M.globals(C.stagedRead(w,reader,source)),M.globals(B.choose(~R.World,B.has(R.Node.status(B.node(w,source)),K.STATUS_UNINITIALIZED()),_=>w,_=>afterMark(w,reader))),M.globals(w),Equal.cong(R.World,M.GlobalView,M.globals,C.stagedRead(w,reader,source),B.choose(~R.World,B.has(R.Node.status(B.node(w,source)),K.STATUS_UNINITIALIZED()),_=>w,_=>afterMark(w,reader)),stagedShape(w,reader,source)),globalsChoice(B.has(R.Node.status(B.node(w,source)),K.STATUS_UNINITIALIZED()),w,w,afterMark(w,reader),{==},afterMarkGlobals(w,reader)))

def chosen(+w: R.World,reader: Nat,committed: Bool) -> R.World:
  B.choose(~R.World,committed,_=>w,_=>C.stagedRead(w,reader,0n))

def chosenGlobals(+w: R.World,+reader: Nat,committed: Bool) -> {M.globals(chosen(w,reader,committed)) == M.globals(w) : M.GlobalView}:
  globalsChoice(committed,w,w,C.stagedRead(w,reader,0n),{==},stagedGlobals(w,reader,0n))

def netted(+meta: M.NodeView) -> Bool:
  Bool.and(B.equal(M.current(meta),M.value(meta)),B.objectIs(M.current(meta),M.value(meta)))

def gate(+meta: M.NodeView) -> Bool:
  Bool.or(Bool.not(B.present(M.pending(meta))),netted(meta))

def gateWithChildren(+meta: M.NodeView,forbidden: Bool) -> Bool:
  Bool.or(Bool.or(Bool.not(B.present(M.pending(meta))),forbidden),netted(meta))

def pick(+meta: M.NodeView,committed: Bool) -> R.Value:
  B.choose(~R.Value,committed,_=>M.value(meta),_=>M.current(meta))

def output(+w: R.World,rest: List<&2,C.Task>,stack: List<&2,R.Value>,id: Nat,+reader: Nat,+meta: M.NodeView) -> C.Machine:
  C.served(chosen(w,reader,gate(meta)),rest,stack,reader,id,pick(meta,gate(meta)))

def outGuard(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+reader: Nat,+meta: M.NodeView,+committed: Bool) -> C.Machine:
  +next = chosen(w,reader,committed)
  +value = pick(meta,committed)
  B.choose(~C.Machine,B.ok(next),_=>C.served(next,rest,stack,reader,id,value),_=>C.Machine{next,rest,stack})

# Pure algebraic source cut, with the captured metadata and screen test explicit.
def screen(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+offset: Nat,+meta: M.NodeView,+committed: Bool,screened: Bool) -> C.Machine:
  +reader = {1n+offset : Nat}
  +pair = B.choose(~B.Bundle<R.World,Bool>,screened,_=>ReadTx.stagedScreenFor(w,reader,id),_=>B.Bundle{w,False{}})
  +w = B.first(R.World,Bool,pair)
  +committed = Bool.or(committed,B.second(R.World,Bool,pair))
  outGuard(w,rest,stack,id,reader,meta,committed)

def afterGuard(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+offset: Nat,+meta: M.NodeView,+committed: Bool,verdict: Bool) -> C.Machine:
  screen(w,rest,stack,id,offset,meta,committed,Bool.and(Bool.not(committed),verdict))

def loaded(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+offset: Nat,+meta: M.NodeView,forbidden: Bool,verdict: Bool) -> C.Machine:
  afterGuard(w,rest,stack,id,offset,meta,gateWithChildren(meta,forbidden),verdict)

def shape(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+offset: Nat) -> {C.readFastEntered(w,rest,stack,id,1n+offset,False{}) == loaded(w,rest,stack,id,offset,M.node(B.node(w,id)),B.has(R.Node.config(B.node(w,1n+offset)),K.CONFIG_CHILDREN_FORBIDDEN()),B.has(R.Node.config(B.node(w,1n+offset)),K.CONFIG_VERDICT())) : C.Machine}:
  {==}

def orFalse(+value: Bool) -> {Bool.or(value,False{}) == value : Bool}:
  match value:
    case True{}: {==}
    case False{}: {==}

def andFalse(+value: Bool) -> {Bool.and(value,False{}) == False{} : Bool}:
  match value:
    case True{}: {==}
    case False{}: {==}

def noChildren(+meta: M.NodeView) -> {gateWithChildren(meta,False{}) == gate(meta) : Bool}:
  Equal.cong(Bool,Bool,first=>Bool.or(first,netted(meta)),Bool.or(Bool.not(B.present(M.pending(meta))),False{}),Bool.not(B.present(M.pending(meta))),orFalse(Bool.not(B.present(M.pending(meta)))))

def noVerdict(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+offset: Nat,+meta: M.NodeView,+committed: Bool) -> {afterGuard(w,rest,stack,id,offset,meta,committed,False{}) == outGuard(w,rest,stack,id,1n+offset,meta,committed) : C.Machine}:
  Equal.trans(C.Machine,afterGuard(w,rest,stack,id,offset,meta,committed,False{}),screen(w,rest,stack,id,offset,meta,committed,False{}),outGuard(w,rest,stack,id,1n+offset,meta,committed),Equal.cong(Bool,C.Machine,flag=>screen(w,rest,stack,id,offset,meta,committed,flag),Bool.and(Bool.not(committed),False{}),False{},andFalse(Bool.not(committed))),Equal.cong(Bool,C.Machine,gate=>outGuard(w,rest,stack,id,1n+offset,meta,gate),Bool.or(committed,False{}),committed,orFalse(committed)))

def ready(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+reader: Nat,+meta: M.NodeView,+committed: Bool,healthy: {B.ok(w) == True{} : Bool}) -> {outGuard(w,rest,stack,id,reader,meta,committed) == C.served(chosen(w,reader,committed),rest,stack,reader,id,pick(meta,committed)) : C.Machine}:
  +next = chosen(w,reader,committed)
  +value = pick(meta,committed)
  +good = Equal.trans(Bool,B.ok(next),B.ok(w),True{},M.sameHealthy(next,w,chosenGlobals(w,reader,committed)),healthy)
  Equal.cong(Bool,C.Machine,flag=>B.choose(~C.Machine,flag,_=>C.served(next,rest,stack,reader,id,value),_=>C.Machine{next,rest,stack}),B.ok(next),True{},good)

def actual(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+offset: Nat,children: {B.has(R.Node.config(B.node(w,1n+offset)),K.CONFIG_CHILDREN_FORBIDDEN()) == False{} : Bool},notVerdict: {B.has(R.Node.config(B.node(w,1n+offset)),K.CONFIG_VERDICT()) == False{} : Bool},healthy: {B.ok(w) == True{} : Bool}) -> {C.readFastEntered(w,rest,stack,id,1n+offset,False{}) == output(w,rest,stack,id,1n+offset,M.node(B.node(w,id))) : C.Machine}:
  +meta = M.node(B.node(w,id))
  +forbidden = B.has(R.Node.config(B.node(w,1n+offset)),K.CONFIG_CHILDREN_FORBIDDEN())
  +verdict = B.has(R.Node.config(B.node(w,1n+offset)),K.CONFIG_VERDICT())
  +first = Equal.trans(C.Machine,C.readFastEntered(w,rest,stack,id,1n+offset,False{}),loaded(w,rest,stack,id,offset,meta,forbidden,verdict),loaded(w,rest,stack,id,offset,meta,False{},verdict),shape(w,rest,stack,id,offset),Equal.cong(Bool,C.Machine,flag=>loaded(w,rest,stack,id,offset,meta,flag,verdict),forbidden,False{},children))
  +second = Equal.trans(C.Machine,C.readFastEntered(w,rest,stack,id,1n+offset,False{}),loaded(w,rest,stack,id,offset,meta,False{},verdict),afterGuard(w,rest,stack,id,offset,meta,gateWithChildren(meta,False{}),False{}),first,Equal.cong(Bool,C.Machine,flag=>loaded(w,rest,stack,id,offset,meta,False{},flag),verdict,False{},notVerdict))
  +third = Equal.trans(C.Machine,C.readFastEntered(w,rest,stack,id,1n+offset,False{}),afterGuard(w,rest,stack,id,offset,meta,gateWithChildren(meta,False{}),False{}),outGuard(w,rest,stack,id,1n+offset,meta,gateWithChildren(meta,False{})),second,noVerdict(w,rest,stack,id,offset,meta,gateWithChildren(meta,False{})))
  +fourth = Equal.trans(C.Machine,C.readFastEntered(w,rest,stack,id,1n+offset,False{}),outGuard(w,rest,stack,id,1n+offset,meta,gateWithChildren(meta,False{})),outGuard(w,rest,stack,id,1n+offset,meta,gate(meta)),third,Equal.cong(Bool,C.Machine,flag=>outGuard(w,rest,stack,id,1n+offset,meta,flag),gateWithChildren(meta,False{}),gate(meta),noChildren(meta)))
  Equal.trans(C.Machine,C.readFastEntered(w,rest,stack,id,1n+offset,False{}),outGuard(w,rest,stack,id,1n+offset,meta,gate(meta)),output(w,rest,stack,id,1n+offset,meta),fourth,ready(w,rest,stack,id,1n+offset,meta,gate(meta),healthy))


def outputGlobals(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+reader: Nat,+meta: M.NodeView) -> {M.globals(C.world(output(w,rest,stack,id,reader,meta))) == M.globals(w) : M.GlobalView}:
  +next = chosen(w,reader,gate(meta))
  Equal.trans(M.GlobalView,M.globals(C.world(output(w,rest,stack,id,reader,meta))),M.globals(next),M.globals(w),M.eventGlobals(next,R.ReadValue{reader,id,pick(meta,gate(meta))}),chosenGlobals(w,reader,gate(meta)))
