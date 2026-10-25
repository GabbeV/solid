# Compact actual-operation oracles for deliberate notification faults. These
# support the general notification roots without making a resource stop a pass.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/status.bend as A
import ../runtime/pending-state.bend as P
import ../runtime/constants.bend as K

def initial(value: R.Value,status: U32) -> R.World:
  R.World.with_nodes(B.empty(),[B.blank_node(),R.Node.with_kind(B.blank_node(),R.Memo{}),R.Node.with_status(R.Node.with_kind(R.Node.with_value(B.blank_node(),value),R.Memo{}),status)])

def notified(value: R.Value,status: U32,serial: Nat) -> R.World:
  A.storeStatus(initial(value,status),2n,K.STATUS_PENDING(),R.NotReadyFailure{serial,1n})

def source_registered(+value: R.Value,+serial: Nat) -> {P.hasSource(notified(value,0,serial),2n,1n) == True{} : Bool}:
  {==}

def ready_becomes_pending(+value: R.Value,+serial: Nat) -> {R.Node.status(B.node(notified(value,0,serial),2n)) == K.STATUS_PENDING() : U32}:
  {==}

def incoming_error_is_retained(+value: R.Value,+serial: Nat) -> {R.NodeExtension.error(B.extension(notified(value,0,serial),2n)) == R.NotReadyFailure{serial,1n} : R.Value}:
  {==}

def never_valued_becomes_pending_uninitialized(+value: R.Value,+serial: Nat) -> {R.Node.status(B.node(notified(value,K.STATUS_NO_VALUE(),serial),2n)) == B.set(K.STATUS_PENDING(),K.STATUS_UNINITIALIZED()) : U32}:
  {==}
