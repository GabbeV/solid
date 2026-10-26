# Actual held setter, including the pre-comparison source join and both default
# comparator outcomes. The post-join and post-write profiles are derived from
# checked operation frames; none is an input assumption.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/write.bend as W
import ../runtime/transaction.bend as X
import ../runtime/equality.bend as Equality
import ../runtime/constants.bend as K
import ./held-write-profile.bend as P
import ./held-transition-frame.bend as T
import ./held-write-outer.bend as Frame
import ./ordinary-write-outer.bend as Outer
import ./held-setter-entry.bend as Entry
import ./held-stage-health.bend as Stage
import ./held-stage-topology.bend as Topology
import ./subscriber-topology-frame.bend as Shape
import ./pointer-store-frame.bend as Pointer
import ./setter-committed-frame.bend as Source
import ./ordinary-setter-health.bend as Default

def comparatorZero(-w: R.World,-id: Nat,-offset: Nat,profile: P.Profile<w,id,offset>) -> {Equality.custom(w,id) == 0n : Nat}:
  match profile:
    case P.HeldAt{path,extra,health,unmarked,valid,head,room,context,signal,held,override,custom,existing,extensionRoom,canonical,future,terminal,groupRoom}: custom

def stage(+w: R.World,+id: Nat,+value: R.Value,+offset: Nat,profile: P.Profile<w,id,offset>) -> T.Transition<w,W.stageResolved(w,id,value),id>:
  match profile:
    case P.HeldAt{path,extra,health,unmarked,valid,head,room,+context,+signal,held,override,custom,+existing,extensionRoom,canonical,future,terminal,groupRoom}:
      T.Retained{Stage.actual(w,path,id,value,extra,unmarked,valid,head,room,context,signal,existing),Topology.shape(w,id,value,context,signal,existing),Topology.pointers(w,id,value,context,signal,existing)}

def scheduled(+w: R.World,+id: Nat) -> T.Transition<w,Entry.scheduled(w),id>:
  +next = B.schedule(w)
  +slot = R.Node.x(B.node(w,id))
  T.Retained{Frame.choice(R.World.running(w),w,w,next,slot,{==},Frame.fromOuter(w,next,slot,Outer.schedule(w))),Shape.choice(R.World.running(w),w,w,next,{==},Shape.schedule(w)),Pointer.choice(R.World.running(w),w,w,next,{==},Pointer.schedule(w))}

def beforeExact(+w: R.World,+id: Nat,+offset: Nat,profile: P.Profile<w,id,offset>) -> {W.beforeCompare(w,id) == Entry.scheduled(w) : R.World}:
  match profile:
    case P.HeldAt{path,extra,health,unmarked,valid,head,room,context,signal,held,override,custom,existing,extensionRoom,canonical,future,terminal,groupRoom}:
      Equal.trans(R.World,W.beforeCompare(w,id),X.joinNode(w,id),Entry.scheduled(w),Equal.cong(Bool,R.World,flag=>B.choose(~R.World,flag,_=>X.joinNode(w,id),_=>w),B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()),True{},held),Entry.actual(w,id,offset,canonical,future,terminal))

def before(+w: R.World,+id: Nat,+offset: Nat,profile: P.Profile<w,id,offset>) -> T.Transition<w,W.beforeCompare(w,id),id>:
  T.target(w,Entry.scheduled(w),W.beforeCompare(w,id),id,Equal.sym(R.World,W.beforeCompare(w,id),Entry.scheduled(w),beforeExact(w,id,offset,profile)),scheduled(w,id))

def compared(+w: R.World,+id: Nat,+current: R.Value,+value: R.Value,+offset: Nat,+profile: P.Profile<w,id,offset>) -> T.Transition<w,Source.compared(w,id,current,value),id>:
  +staged = W.stageResolved(w,id,value)
  +stageFrame = stage(w,id,value,offset,profile)
  +equal = B.choose(~R.World,Equality.isSame(w,id,current,value),_=>w,_=>staged)
  +result = B.choose(~R.World,W.skipCompare(w,id),_=>staged,_=>equal)
  +frame = T.choice(W.skipCompare(w,id),w,staged,equal,id,stageFrame,T.choice(Equality.isSame(w,id,current,value),w,w,staged,id,T.identity(w,id),stageFrame))
  T.target(w,result,Source.compared(w,id,current,value),id,Equal.sym(R.World,Source.compared(w,id,current,value),result,Default.comparedDefault(w,id,current,value,comparatorZero(w,id,offset,profile))),frame)

def actual(+w: R.World,+id: Nat,+value: R.Value,+offset: Nat,+profile: P.Profile<w,id,offset>) -> T.Transition<w,W.setSignal(w,id,value),id>:
  +next = W.beforeCompare(w,id)
  +frame = before(w,id,offset,profile)
  +prepared = P.transport(w,next,id,offset,profile,frame)
  T.compose(w,next,W.setSignal(w,id,value),id,frame,compared(next,id,B.current(B.node(w,id)),value,offset,prepared))

def next(+w: R.World,+id: Nat,+value: R.Value,+offset: Nat,+profile: P.Profile<w,id,offset>) -> P.Profile<W.setSignal(w,id,value),id,offset>:
  P.transport(w,W.setSignal(w,id,value),id,offset,profile,actual(w,id,value,offset,profile))
