# The added source guard requests a flush for any nonempty pending queue in
# this computed-self-disposal family. This is scheduling, not a GC theorem.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/owner.bend as O

def world(machine: O.Machine) -> R.World:
  match machine:
    case O.Machine{world, tasks}: world

def dispose(value: R.Value, pending: List<&2, Nat>) -> R.World:
  +w = R.World.with_nodes(B.empty(), [B.blank_node(), R.Node.with_kind(R.Node.with_value(B.blank_node(), value), R.Memo{}), R.Node.with_kind(B.blank_node(), R.Signal{})])
  +w = R.World.with_pendingNodes(w, pending)
  world(O.afterPark(w, [], 1n, True{}, False{}, 0))

def queued(+value: R.Value, +head: Nat, +tail: List<&2, Nat>) -> {R.World.scheduled(dispose(value, head <> tail)) == True{} : Bool}:
  {==}

def empty(+value: R.Value) -> {R.World.scheduled(dispose(value, [])) == False{} : Bool}:
  {==}
