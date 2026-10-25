import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/owner.bend as O
import ../../runtime/constants.bend as K

def world(machine: O.Machine) -> R.World:
  match machine:
    case O.Machine{world, tasks}: world

def fixture(+queued: Bool, self: Bool, computed: Bool, pending: Bool, +transaction: Bool, frame: Bool) -> R.World:
  +flags = B.choose(~U32, frame, _ => K.REACTIVE_FRAME_READ(), _ => 0)
  +node = R.Node.with_x(R.Node.with_status(R.Node.with_flags(R.Node.with_kind(B.blank_node(), B.choose(~R.NodeKind, computed, _ => R.Memo{}, _ => R.Root{})), flags), B.choose(~U32, pending, _ => K.STATUS_PENDING(), _ => 0)), B.choose(~Nat, transaction, _ => 1n, _ => 0n))
  +w = R.World.with_nodes(B.empty(), [B.blank_node(), node, R.Node.with_kind(B.blank_node(), R.Signal{})])
  +w = R.World.with_extensions(w, [B.blank_extension(), R.NodeExtension.with_transaction(B.blank_extension(), B.choose(~Nat, transaction, _ => 1n, _ => 0n))])
  +w = R.World.with_pendingNodes(w, B.choose(~List<&2, Nat>, queued, _ => [2n], _ => []))
  world(O.afterPark(w, [], 1n, self, False{}, flags))
