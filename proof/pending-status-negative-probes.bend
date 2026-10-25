# Old-error/no-value branch probes; runtime sources are mutated by the harness.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/status.bend as A

def initial() -> R.World:
  R.World.with_nodes(R.World.with_extensions(B.empty(),[B.blank_extension(),B.blank_extension()]),[B.blank_node(),R.Node.with_x(R.Node.with_status(B.blank_node(),10),1n)])

def old_error_reask_keeps_pending_uninitialized() -> {R.Node.status(B.node(A.storeStatus(initial(),1n,1,R.NotReadyFailure{1n,1n}),1n)) == 5 : U32}:
  {==}
