# Compact typed fixture for executable checks of the general constructor. This
# initial World is a private represented state, not a public-component claim.
# Every equality input to the constructor is checked here, not supplied by JS.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/graph-state.bend as G
import ./graph-link-construction.bend as Constructed
import ./one-edge-settlement-return.bend as Settlement
import ./bounded-core-return.bend as Return

def initial(+value: R.Value, recomputing: Bool, +carrier: Bool) -> R.World:
  +source = R.Node.with_kind(R.Node.with_value(B.blank_node(), value), R.Memo{})
  +leaf = R.Node.with_x(R.Node.with_status(R.Node.with_flags(R.Node.with_kind(R.Node.with_value(B.blank_node(), value), R.Render{}), B.choose(~U32, recomputing, _ => 4, _ => 0)), B.choose(~U32, carrier, _ => 1, _ => 0)), 1n)
  +extension = R.NodeExtension.with_pendingSources(B.blank_extension(), B.choose(~Nat, carrier, _ => 1n, _ => 0n))
  +w = R.World.with_nodes(B.empty(), [B.blank_node(), source, leaf])
  +w = R.World.with_extensions(w, [B.blank_extension(), extension])
  R.World.with_pendingSets(w, [[], [1n]])

def linked(value: R.Value, recomputing: Bool, carrier: Bool) -> R.World:
  G.link(initial(value, recomputing, carrier), 1n, 2n)

def complete(+value: R.Value, +recomputing: Bool, +carrier: Bool, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>) ->
  Return.Returned<Settlement.start(linked(value, recomputing, carrier), 1n, rest, stack), rest, stack, 10n>:
  Constructed.startReturn(initial(value, recomputing, carrier), 1n, 2n, B.blank_link(), [], rest, stack, {==}, {==}, {==}, {==}, {==}, {==}, {==}, {==}, {==}, {==}, {==})
