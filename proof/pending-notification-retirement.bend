# Notification-local carrier construction followed by the actual dependent
# retirement controller. Full outer notification propagation stays separate.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending.bend as Q
import ../runtime/constants.bend as K
import ./pending-notification-carrier.bend as Notify
import ./pending-notification-storage.bend as Storage
import ./pending-one-edge-transport.bend as Transport
import ./pending-carrier-state.bend as State
import ./pending-retirement-controller.bend as Retire
import ./pending-tail-status.bend as Tail


def after(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,tasks: List<&2,Q.Task>,visited: List<&2,Nat>,released: List<&2,Nat>,scheduled: Bool,root: Nat) -> Q.Machine:
  Q.visitRemoved(Notify.notified(w,node,source,serial),tasks,visited,released,scheduled,node,root,1n+source)

def cleared(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,+tasks: List<&2,Q.Task>,+visited: List<&2,Nat>,+released: List<&2,Nat>,+scheduled: Bool,+root: Nat,snapshot: State.CarrierSnapshot<w,node,source>,noError: {B.has(R.Node.status(B.node(w,node)),K.STATUS_ERROR()) == False{} : Bool},valid: {B.valid(w,node) == True{} : Bool}) -> {B.has(R.Node.status(B.node(Tail.world(after(w,node,source,serial,tasks,visited,released,scheduled,root)),node)),K.STATUS_PENDING()) == False{} : Bool}:
  +next = Notify.notified(w,node,source,serial)
  Retire.removedCleared(next,tasks,visited,released,scheduled,node,root,source,Notify.single(w,node,source,serial,snapshot,noError),Transport.valid(w,next,node,Storage.allStored(w,node,source,serial),valid))
