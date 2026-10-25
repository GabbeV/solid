# The status carry is selected from the actual input status, not merely the
# state after registration. All node status words survive actual source add.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/constants.bend as K
import ./pending-carrier-state.bend as State
import ./node-status-frame.bend as Status
import ./pending-notification-carrier.bend as Notify


def inputStatus(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,snapshot: State.CarrierSnapshot<w,node,source>,noError: {B.has(R.Node.status(B.node(w,node)),K.STATUS_ERROR()) == False{} : Bool},valid: {B.valid(w,node) == True{} : Bool}) -> {R.Node.status(B.node(Notify.notified(w,node,source,serial),node)) == Status.select(R.Node.status(B.node(w,node))) : U32}:
  Equal.trans(U32,R.Node.status(B.node(Notify.notified(w,node,source,serial),node)),Notify.flags(State.addWorld(w,node,source),node),Status.select(R.Node.status(B.node(w,node))),Notify.statusResult(w,node,source,serial,snapshot,noError,valid),Status.inputFlags(w,node,1n+source))
