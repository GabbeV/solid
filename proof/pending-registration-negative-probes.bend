# Small kernel probes of actual operations; general laws live in the registration
# modules. No source result is supplied by JavaScript.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P

def initial() -> R.World:
  R.World.with_nodes(B.empty(), [B.blank_node(), R.Node.with_kind(B.blank_node(), R.Memo{}), R.Node.with_kind(B.blank_node(), R.Render{})])

def added() -> R.World:
  B.first(R.World, Bool, P.addPendingSource(initial(), 2n, 1n))

def removed() -> R.World:
  B.first(R.World, Bool, P.removePendingSource(added(), 2n, 1n))

def member() -> {P.hasSource(added(), 2n, 1n) == True{} : Bool}:
  {==}

def duplicateAdd() -> {B.second(R.World, Bool, P.addPendingSource(added(), 2n, 1n)) == False{} : Bool}:
  {==}

def pointer() -> {R.NodeExtension.pendingSources(B.extension(removed(), 2n)) == 0n : Nat}:
  {==}

def tombstone() -> {B.pendingSlots(removed(), 1n) == [0n] : List<&2, Nat>}:
  {==}

def zeroUntouched() -> {B.pendingSlots(added(), 0n) == [] : List<&2, Nat>}:
  {==}
