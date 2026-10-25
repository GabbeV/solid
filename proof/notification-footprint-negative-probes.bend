# Compact actual-operation oracles for incoming graph/control-footprint faults.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/status.bend as A

def initial() -> R.World:
  R.World.with_nodes(B.empty(),[B.blank_node(),R.Node.with_config(R.Node.with_kind(B.blank_node(),R.Memo{}),1024)])

def notified() -> R.World:
  A.storeStatus(initial(),1n,1,R.NotReadyFailure{1n,1n})

def keeps_input_configuration() -> {R.Node.config(B.node(notified(),1n)) == 1024 : U32}:
  {==}

def keeps_healthy_fault() -> {B.ok(notified()) == True{} : Bool}:
  {==}
