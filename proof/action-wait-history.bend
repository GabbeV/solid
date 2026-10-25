# Arbitrary finite actual wait registration, shared observer allocation and wait
# marking histories. Callback execution/transaction debt is a separate protocol.
import Base
import ./committed-storage-frame.bend as Content
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ../runtime/core.bend as Core
import ./action-wait-allocation.bend as Allocation
import ./action-wait-range.bend as Range
import ./action-wait-construction.bend as Register
import ./action-wait-settlement.bend as Wait
import ./observer-allocation-frame.bend as Observer
import ./action-laws.bend as Guard


type WaitEvent is Data:
  WaitRegister{action: Nat,result: Nat,kind: U32}
  ObserverAllocate{node: Nat,result: Nat}
  WaitMark{observer: Nat}

def step(+w: R.World,event: WaitEvent) -> R.World:
  match event:
    case WaitRegister{action,result,kind}: Allocation.after(w,action,result,kind)
    case ObserverAllocate{node,result}: Observer.after(w,node,result)
    case WaitMark{observer}: R.World.with_actionWaits(w,A.settleWait(R.World.actionWaits(w),observer))

def run(events: List<&2,WaitEvent>,w: R.World) -> R.World:
  match events:
    case Nil{}: w
    case event <> tail: run(tail,step(w,event))


def markBelow(waits: List<&2,R.ActionWait>,+id: Nat,+bound: Nat) -> {Range.below(A.settleWait(waits,id),bound) == Range.below(waits,bound) : Bool}:
  match waits:
    case Nil{}: {==}
    case +head <> +tail:
      +same = Nat.is_eq(R.ActionWait.observer(head),id)
      Equal.trans(Bool,Range.below(A.settleWait(head <> tail,id),bound),Bool.and(Nat.is_lt(R.ActionWait.observer(head),bound),Range.below(A.settleWait(tail,id),bound)),Range.below(head <> tail,bound),Equal.cong(Nat,Bool,observer=>Bool.and(Nat.is_lt(observer,bound),Range.below(A.settleWait(tail,id),bound)),R.ActionWait.observer(Wait.change(same,head)),R.ActionWait.observer(head),Wait.observer(head,same)),Equal.cong(Bool,Bool,valid=>Bool.and(Nat.is_lt(R.ActionWait.observer(head),bound),valid),Range.below(A.settleWait(tail,id),bound),Range.below(tail,bound),markBelow(tail,id,bound)))

def indexUnchanged(+w: R.World,waits: List<&2,R.ActionWait>) -> {Allocation.index(R.World.with_actionWaits(w,waits)) == Allocation.index(w) : Nat}:
  match w:
    case R.World{nodes,links,buckets,minimum,maximum,marked,pendingNodes,trims,renderQueue,userQueue,context,tracking,running,scheduled,clock,epoch,tree,events,fault,unflushedStaged,promotedWrites,extensions,cleanupPrograms,dormantNodes,errorSerial,halted,haltNotified,reports,callbackEffect,txArena,transactions,flushTransaction,passTx,passLane,judge,deferredZombies,question,pendingSets,asyncObjects,asyncObservers,hostJobs,syncDepth,streamPlans,iterators,streams,iteratorEvents,awaiters,truthReadHook,truthConfirmedHook,questions,abortInputs,contextKeys,contextRecords,deferredReleases,releaseLists,stale,settledCallbacks,reactions,comparators,actionDepth,actions,actionWaits,arrays,repeats,maps,activeMarks,laneState,verdictState,cleanupError,ambientMarks,deferredArena}: {==}

def markedRange(+w: R.World,+id: Nat,valid: {Range.below(R.World.actionWaits(w),Allocation.index(w)) == True{} : Bool}) -> {Range.below(R.World.actionWaits(step(w,WaitMark{id})),Allocation.index(step(w,WaitMark{id}))) == True{} : Bool}:
  +entries = A.settleWait(R.World.actionWaits(w),id)
  Equal.trans(Bool,Range.below(R.World.actionWaits(step(w,WaitMark{id})),Allocation.index(step(w,WaitMark{id}))),Range.below(entries,Allocation.index(step(w,WaitMark{id}))),True{},Equal.cong(List<&2,R.ActionWait>,Bool,rows=>Range.below(rows,Allocation.index(step(w,WaitMark{id}))),R.World.actionWaits(step(w,WaitMark{id})),entries,Allocation.waitsStored(w,entries)),Equal.trans(Bool,Range.below(entries,Allocation.index(step(w,WaitMark{id}))),Range.below(entries,Allocation.index(w)),True{},Equal.cong(Nat,Bool,bound=>Range.below(entries,bound),Allocation.index(step(w,WaitMark{id})),Allocation.index(w),indexUnchanged(w,entries)),Equal.trans(Bool,Range.below(entries,Allocation.index(w)),Range.below(R.World.actionWaits(w),Allocation.index(w)),True{},markBelow(R.World.actionWaits(w),id,Allocation.index(w)),valid)))

def observerRange(+w: R.World,+node: Nat,+result: Nat,valid: {Range.below(R.World.actionWaits(w),Allocation.index(w)) == True{} : Bool}) -> {Range.below(R.World.actionWaits(Observer.after(w,node,result)),Allocation.index(Observer.after(w,node,result))) == True{} : Bool}:
  Equal.trans(Bool,Range.below(R.World.actionWaits(Observer.after(w,node,result)),Allocation.index(Observer.after(w,node,result))),Range.below(R.World.actionWaits(w),Allocation.index(Observer.after(w,node,result))),True{},Equal.cong(List<&2,R.ActionWait>,Bool,waits=>Range.below(waits,Allocation.index(Observer.after(w,node,result))),R.World.actionWaits(Observer.after(w,node,result)),R.World.actionWaits(w),Observer.waits(w,node,result)),Equal.trans(Bool,Range.below(R.World.actionWaits(w),Allocation.index(Observer.after(w,node,result))),Range.below(R.World.actionWaits(w),Nat.add(Allocation.index(w),1n)),True{},Equal.cong(Nat,Bool,bound=>Range.below(R.World.actionWaits(w),bound),Allocation.index(Observer.after(w,node,result)),Nat.add(Allocation.index(w),1n),Observer.size(w,node,result)),Range.extend(R.World.actionWaits(w),Allocation.index(w),valid)))

def stepRange(+w: R.World,event: WaitEvent,valid: {Range.below(R.World.actionWaits(w),Allocation.index(w)) == True{} : Bool}) -> {Range.below(R.World.actionWaits(step(w,event)),Allocation.index(step(w,event))) == True{} : Bool}:
  match event:
    case WaitRegister{action,result,kind}: Register.bounded(w,action,result,kind,valid)
    case ObserverAllocate{node,result}: observerRange(w,node,result,valid)
    case WaitMark{id}: markedRange(w,id,valid)

def historyRange(events: List<&2,WaitEvent>,+w: R.World,valid: {Range.below(R.World.actionWaits(w),Allocation.index(w)) == True{} : Bool}) -> {Range.below(R.World.actionWaits(run(events,w)),Allocation.index(run(events,w))) == True{} : Bool}:
  match events:
    case Nil{}: valid
    case +event <> tail: historyRange(tail,step(w,event),stepRange(w,event,valid))


def stepFound(+w: R.World,event: WaitEvent,+id: Nat,+observer: Nat,+action: Nat,+kind: U32,found: {A.find(R.World.actionWaits(w),id) == Some{R.ActionWait{observer,action,kind,True{}}} : Maybe<&2,R.ActionWait>}) -> {A.find(R.World.actionWaits(step(w,event)),id) == Some{R.ActionWait{observer,action,kind,True{}}} : Maybe<&2,R.ActionWait>}:
  match event:
    case WaitRegister{newAction,result,newKind}: Register.oldLookup(w,newAction,result,newKind,id,R.ActionWait{observer,action,kind,True{}},found)
    case ObserverAllocate{node,result}:
      Equal.trans(Maybe<&2,R.ActionWait>,A.find(R.World.actionWaits(Observer.after(w,node,result)),id),A.find(R.World.actionWaits(w),id),Some{R.ActionWait{observer,action,kind,True{}}},Equal.cong(List<&2,R.ActionWait>,Maybe<&2,R.ActionWait>,waits=>A.find(waits,id),R.World.actionWaits(Observer.after(w,node,result)),R.World.actionWaits(w),Observer.waits(w,node,result)),found)
    case WaitMark{+other}:
      +entries = A.settleWait(R.World.actionWaits(w),other)
      Equal.trans(Maybe<&2,R.ActionWait>,A.find(R.World.actionWaits(step(w,WaitMark{other})),id),A.find(entries,id),Some{R.ActionWait{observer,action,kind,True{}}},Equal.cong(List<&2,R.ActionWait>,Maybe<&2,R.ActionWait>,rows=>A.find(rows,id),R.World.actionWaits(step(w,WaitMark{other})),entries,Allocation.waitsStored(w,entries)),Wait.otherKeeps(R.World.actionWaits(w),id,other,observer,action,kind,found))

def historyFound(events: List<&2,WaitEvent>,+w: R.World,+id: Nat,+observer: Nat,+action: Nat,+kind: U32,found: {A.find(R.World.actionWaits(w),id) == Some{R.ActionWait{observer,action,kind,True{}}} : Maybe<&2,R.ActionWait>}) -> {A.find(R.World.actionWaits(run(events,w)),id) == Some{R.ActionWait{observer,action,kind,True{}}} : Maybe<&2,R.ActionWait>}:
  match events:
    case Nil{}: found
    case +event <> tail: historyFound(tail,step(w,event),id,observer,action,kind,stepFound(w,event,id,observer,action,kind,found))


def afterRegistered(+w: R.World,+action: Nat,+result: Nat,events: List<&2,WaitEvent>) -> R.World:
  run(events,Register.marked(w,action,result,Allocation.index(w)))

def constructedSettledLookup(+w: R.World,+action: Nat,+result: Nat,+events: List<&2,WaitEvent>,valid: {Range.below(R.World.actionWaits(w),Allocation.index(w)) == True{} : Bool}) -> {A.find(R.World.actionWaits(afterRegistered(w,action,result,events)),Allocation.index(w)) == Some{R.ActionWait{Allocation.index(w),action,0,True{}}} : Maybe<&2,R.ActionWait>}:
  historyFound(events,Register.marked(w,action,result,Allocation.index(w)),Allocation.index(w),Allocation.index(w),action,0,Register.markedFound(w,action,result,valid))


def constructedDuplicate(+w: R.World,+action: Nat,+result: Nat,+events: List<&2,WaitEvent>,+rest: List<&2,Core.Task>,+stack: List<&2,R.Value>,+rejected: Bool,+value: R.Value,valid: {Range.below(R.World.actionWaits(w),Allocation.index(w)) == True{} : Bool}) -> {Core.asyncActionDelivery(afterRegistered(w,action,result,events),rest,stack,Allocation.index(w),rejected,value,A.find(R.World.actionWaits(afterRegistered(w,action,result,events)),Allocation.index(w))) == Core.Machine{afterRegistered(w,action,result,events),rest,stack} : Core.Machine}:
  +next = afterRegistered(w,action,result,events)
  Equal.trans(Core.Machine,Core.asyncActionDelivery(next,rest,stack,Allocation.index(w),rejected,value,A.find(R.World.actionWaits(next),Allocation.index(w))),Core.asyncActionDelivery(next,rest,stack,Allocation.index(w),rejected,value,Some{R.ActionWait{Allocation.index(w),action,0,True{}}}),Core.Machine{next,rest,stack},Equal.cong(Maybe<&2,R.ActionWait>,Core.Machine,found=>Core.asyncActionDelivery(next,rest,stack,Allocation.index(w),rejected,value,found),A.find(R.World.actionWaits(next),Allocation.index(w)),Some{R.ActionWait{Allocation.index(w),action,0,True{}}},constructedSettledLookup(w,action,result,events,valid)),Guard.duplicate_yield(next,rest,stack,Allocation.index(w),action,rejected,value))


def stepPositive(+w: R.World,event: WaitEvent,positive: {Nat.is_ne(Allocation.index(w),0n) == True{} : Bool}) -> {Nat.is_ne(Allocation.index(step(w,event)),0n) == True{} : Bool}:
  match event:
    case WaitRegister{action,result,kind}:
      Equal.trans(Bool,Nat.is_ne(Allocation.index(Allocation.after(w,action,result,kind)),0n),Nat.is_ne(Nat.add(Allocation.index(w),1n),0n),True{},Equal.cong(Nat,Bool,id=>Nat.is_ne(id,0n),Allocation.index(Allocation.after(w,action,result,kind)),Nat.add(Allocation.index(w),1n),Allocation.size(w,action,result,kind)),Range.successorPositive(Allocation.index(w)))
    case ObserverAllocate{node,result}:
      Equal.trans(Bool,Nat.is_ne(Allocation.index(Observer.after(w,node,result)),0n),Nat.is_ne(Nat.add(Allocation.index(w),1n),0n),True{},Equal.cong(Nat,Bool,id=>Nat.is_ne(id,0n),Allocation.index(Observer.after(w,node,result)),Nat.add(Allocation.index(w),1n),Observer.size(w,node,result)),Range.successorPositive(Allocation.index(w)))
    case WaitMark{id}:
      Equal.trans(Bool,Nat.is_ne(Allocation.index(step(w,WaitMark{id})),0n),Nat.is_ne(Allocation.index(w),0n),True{},Equal.cong(Nat,Bool,index=>Nat.is_ne(index,0n),Allocation.index(step(w,WaitMark{id})),Allocation.index(w),indexUnchanged(w,A.settleWait(R.World.actionWaits(w),id))),positive)

def historyPositive(events: List<&2,WaitEvent>,+w: R.World,positive: {Nat.is_ne(Allocation.index(w),0n) == True{} : Bool}) -> {Nat.is_ne(Allocation.index(run(events,w)),0n) == True{} : Bool}:
  match events:
    case Nil{}: positive
    case +event <> tail: historyPositive(tail,step(w,event),stepPositive(w,event,positive))


def afterRange(+w: R.World,+action: Nat,+result: Nat,+events: List<&2,WaitEvent>,valid: {Range.below(R.World.actionWaits(w),Allocation.index(w)) == True{} : Bool}) -> {Range.below(R.World.actionWaits(afterRegistered(w,action,result,events)),Allocation.index(afterRegistered(w,action,result,events))) == True{} : Bool}:
  historyRange(events,Register.marked(w,action,result,Allocation.index(w)),markedRange(Allocation.after(w,action,result,0),Allocation.index(w),Register.bounded(w,action,result,0,valid)))


def markContent(+w: R.World,+id: Nat) -> {Content.observe(step(w,WaitMark{id})) == Content.observe(w) : Content.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def stepContent(+w: R.World,event: WaitEvent) -> {Content.observe(step(w,event)) == Content.observe(w) : Content.View}:
  match event:
    case WaitRegister{action,result,kind}: Allocation.content(w,action,result,kind)
    case ObserverAllocate{node,result}: Observer.content(w,node,result)
    case WaitMark{id}: markContent(w,id)

def historyContent(events: List<&2,WaitEvent>,+w: R.World) -> {Content.observe(run(events,w)) == Content.observe(w) : Content.View}:
  match events:
    case Nil{}: {==}
    case +event <> +tail: Content.compose(w,step(w,event),run(tail,step(w,event)),historyContent(tail,step(w,event)),stepContent(w,event))


def settledCaught(+w: R.World,+rest: List<&2,Core.Task>,+stack: List<&2,R.Value>,+observer: Nat,+action: Nat,+error: R.Value) -> {Core.actionYieldCaught(w,rest,stack,error,Some{R.ActionWait{observer,action,0,True{}}}) == Core.Machine{R.World.with_fault(w,R.Healthy{}),rest,stack} : Core.Machine}:
  {==}

def constructedThrow(+w: R.World,+action: Nat,+result: Nat,+events: List<&2,WaitEvent>,+rest: List<&2,Core.Task>,+stack: List<&2,R.Value>,+error: R.Value,valid: {Range.below(R.World.actionWaits(w),Allocation.index(w)) == True{} : Bool}) -> {Core.actionYieldThrow(afterRegistered(w,action,result,events),rest,stack,Allocation.index(w),R.CallbackThrown{error}) == Core.Machine{R.World.with_fault(afterRegistered(w,action,result,events),R.Healthy{}),rest,stack} : Core.Machine}:
  +next = afterRegistered(w,action,result,events)
  Equal.trans(Core.Machine,Core.actionYieldThrow(next,rest,stack,Allocation.index(w),R.CallbackThrown{error}),Core.actionYieldCaught(next,rest,stack,error,Some{R.ActionWait{Allocation.index(w),action,0,True{}}}),Core.Machine{R.World.with_fault(next,R.Healthy{}),rest,stack},Equal.cong(Maybe<&2,R.ActionWait>,Core.Machine,found=>Core.actionYieldCaught(next,rest,stack,error,found),A.find(R.World.actionWaits(next),Allocation.index(w)),Some{R.ActionWait{Allocation.index(w),action,0,True{}}},constructedSettledLookup(w,action,result,events,valid)),settledCaught(next,rest,stack,Allocation.index(w),action,error))
