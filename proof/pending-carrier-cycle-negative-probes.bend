# Independent small source probes for cycle identity and exact duplicate no-op.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P

def initial() -> R.World:
  R.World.with_nodes(B.empty(), [B.blank_node(), R.Node.with_kind(B.blank_node(), R.Memo{}), R.Node.with_kind(B.blank_node(), R.Render{})])

def added() -> R.World:
  B.first(R.World, Bool, P.addPendingSource(initial(), 2n, 1n))

def readded() -> R.World:
  +w = B.first(R.World, Bool, P.removePendingSource(added(), 2n, 1n))
  B.first(R.World, Bool, P.addPendingSource(w, 2n, 1n))

def duplicateEpoch() -> {R.World.epoch(B.first(R.World, Bool, P.addPendingSource(added(), 2n, 1n))) == 0n : Nat}:
  {==}

def distinctNewSet() -> {B.length(List<&2, Nat>, R.World.pendingSets(readded())) == 3n : Nat}:
  {==}
