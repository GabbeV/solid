# Proof-only loaded form of core.ts:recompute's prepared-body segment.
# The exact machine equality is checked against the single runtime; no stores
# are removed and no successful output World is an input premise.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/constants.bend as K
import ../runtime/pending-state.bend as P
import ../runtime/scheduler.bend as S

def refreshed(+n: R.Node,time: Nat) -> R.Node:
  +n = R.Node.with_depsTail(n,0n)
  +n = R.Node.with_depGen(n,1n+R.Node.depGen(n))
  +n = R.Node.with_flags(n,B.set(K.REACTIVE_RECOMPUTING_DEPS(),U32.and(R.Node.flags(n),B.set(K.REACTIVE_ZOMBIE(),K.REACTIVE_REASK()))))
  R.Node.with_time(n,time)

def row(+w: R.World,+id: Nat) -> R.Node:
  refreshed(B.node(w,id),R.World.clock(R.World.with_context(w,id)))

def stored(+w: R.World,+id: Nat) -> R.World:
  B.store_node(R.World.with_context(w,id),id,row(w,id))

def decorate(+w: R.World,+id: Nat,stale: Bool,tracked: Bool) -> R.World:
  +next = R.World.with_stale(w,stale)
  R.World.with_tracking(B.choose(~R.World,tracked,_=>next,_=>B.event(next,R.Invoked{id})),True{})

def world(+w: R.World,+id: Nat) -> R.World:
  +n = row(w,id)
  +next = stored(w,id)
  decorate(next,id,Bool.or(R.World.stale(next),Bool.and(B.effect(R.Node.kind(n)),Bool.not(S.is_user(R.Node.kind(n))))),B.tracked(R.Node.kind(n)))

def reask(+w: R.World,+id: Nat) -> Bool:
  +n = B.node(w,id)
  Bool.and(B.has(R.Node.flags(n),K.REACTIVE_REASK()),Bool.not(Bool.and(Bool.or(B.has(R.Node.status(n),K.STATUS_PENDING()),Bool.and(R.LaneState.guessing(R.World.laneState(w)),B.present(R.Node.pending(n)))),Bool.and(Nat.is_ne(R.Node.x(n),0n),Bool.not(R.NodeExtension.reask(B.extension(w,id)))))))

def frame(+w: R.World,+id: Nat,create: Bool,released: Nat,+lanePass: C.LanePass,+stack: List<&2,R.Value>) -> C.PassFrame:
  +n = row(w,id)
  +next = stored(w,id)
  C.PassFrame{id,create,R.World.context(w),R.World.tracking(next),R.Node.height(n),reask(w,id),C.passValue(next,id),B.has(R.Node.status(n),K.STATUS_UNINITIALIZED()),
    B.choose(~R.Value,B.has(R.Node.status(n),K.STATUS_ERROR()),_=>R.NodeExtension.error(B.extension(next,id)),_=>R.Number{0n}),
    B.choose(~Nat,B.has(R.Node.status(n),K.STATUS_PENDING()),_=>R.NodeExtension.pendingSources(B.extension(next,id)),_=>0n),
    P.hasSource(next,id,id),B.flight(next,id),stack,released,R.World.stale(next),C.withReleaseAfter(lanePass,B.has(R.Node.flags(B.node(w,id)),K.REACTIVE_RELEASE_AFTER()))}

def entered(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,create: Bool,released: Nat,+lanePass: C.LanePass) -> C.Machine:
  C.Machine{world(w,id),C.Evaluate{R.Node.expr(row(w,id)),C.passValue(stored(w,id),id)} <> C.Finish{frame(w,id,create,released,lanePass,stack)} <> rest,stack}

def actual(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,create: Bool,released: Nat,+lanePass: C.LanePass) -> {C.recomputePrepared(w,rest,stack,id,create,released,lanePass) == entered(w,rest,stack,id,create,released,lanePass) : C.Machine}:
  {==}
