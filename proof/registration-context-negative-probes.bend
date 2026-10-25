# Small source-operation probes, independent of constructor/context proofs.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/graph-state.bend as G

def linked() -> R.World:
  G.link(R.World.with_nodes(B.empty(), [B.blank_node(), R.Node.with_kind(B.blank_node(), R.Memo{}), R.Node.with_kind(B.blank_node(), R.Render{})]), 1n, 2n)

def freshX() -> {R.Node.x(B.node(linked(), 2n)) == 0n : Nat}:
  {==}

def extensions() -> {B.length(R.NodeExtension, R.World.extensions(linked())) == 1n : Nat}:
  {==}

def sets() -> {B.length(List<&2, Nat>, R.World.pendingSets(linked())) == 1n : Nat}:
  {==}
