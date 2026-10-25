# Small kernel oracles for faults in status preservation during registration.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P
import ../runtime/constants.bend as K

def initial(value: R.Value) -> R.World:
  R.World.with_nodes(B.empty(),[B.blank_node(),R.Node.with_status(R.Node.with_kind(R.Node.with_value(B.blank_node(),value),R.Memo{}),K.STATUS_UNINITIALIZED())])

def registration_keeps_input_status(+value: R.Value) -> {R.Node.status(B.node(B.first(R.World,Bool,P.addPendingSource(initial(value),1n,1n)),1n)) == K.STATUS_UNINITIALIZED() : U32}:
  {==}
