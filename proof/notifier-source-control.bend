# Exact source control alias after local status stores; includes 178605cf's
# persistent guessing gate and new-question versus refresh parent selection.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/status.bend as A
import ../runtime/constants.bend as K
import ../runtime/transaction.bend as X
import ./pending-notification-operations.bend as N
import ./subscriber-topology-frame.bend as Topology

def kind(shape: Topology.Shape) -> R.NodeKind:
  match shape:
    case Topology.Shape{kind,config,subscribers}: kind


def config(shape: Topology.Shape) -> U32:
  match shape:
    case Topology.Shape{kind,config,subscribers}: config

def subscribers(shape: Topology.Shape) -> Nat:
  match shape:
    case Topology.Shape{kind,config,subscribers}: subscribers


def choice(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,+rest: List<&2,A.Task>,+visited: List<&2,Nat>,+scheduled: Bool,+shape: Topology.Shape,+guess: Bool) -> A.Machine:
  B.choose(~A.Machine,guess,
    _=>
      +w = B.choose(~R.World,Nat.is_eq(R.World.passLane(w),0n),
        _=>B.choose(~R.World,B.has(R.Node.flags(B.node(w,node)),K.REACTIVE_REASK()),_=>X.joinFuture(w,0n),
          _=>
            +pair = X.txOf(w,node)
            +w = B.first(R.World,Nat,pair)
            X.joinFuture(w,R.Transaction.parent(B.transaction(w,B.second(R.World,Nat,pair))))),_=>w)
      A.Machine{w,rest,visited,scheduled},
    _=>B.choose(~A.Machine,B.effect(kind(shape)),
      _=>A.Machine{A.notifyEffectStatus(w,node),rest,visited,scheduled},
      _=>A.Machine{w,A.Propagate{subscribers(shape),K.STATUS_PENDING(),N.error(serial,source)} <> rest,visited,scheduled}))

def selected(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,+rest: List<&2,A.Task>,+visited: List<&2,Nat>,+scheduled: Bool,+shape: Topology.Shape) -> A.Machine:
  choice(w,node,source,serial,rest,visited,scheduled,shape,Bool.and(R.LaneState.guessing(R.World.laneState(w)),B.has(config(shape),K.CONFIG_GUESS())))

def selectorExact(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,+rest: List<&2,A.Task>,+visited: List<&2,Nat>,+scheduled: Bool) -> {A.dispatch(w,A.Notify{node,K.STATUS_PENDING(),N.error(serial,source)} <> rest,visited,scheduled) == selected(N.notified(w,node,source,serial),node,source,serial,rest,visited,scheduled,Topology.shape(B.node(N.notified(w,node,source,serial),node))) : A.Machine}:
  {==}
