# Elementary aliases for actual addPendingSource segments, without invariant
# dependencies. The exact law names the unchanged production helper.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P
import ../runtime/extension.bend as E

def finish(+w: R.World, +source: Nat, +set: Nat, slots: List<&2, Nat>) -> B.Bundle<R.World, Bool>:
  B.Bundle{B.store_pendingSet(w, set, B.append(Nat, slots, [source])), True{}}

def setPart(+w: R.World, +id: Nat, +source: Nat, +set: Nat) -> B.Bundle<R.World, Bool>:
  +w = B.choose(~R.World, Nat.is_eq(set, 0n),
    _ =>
      +pair = B.newPendingSet(w, [])
      +w = B.first(R.World, Nat, pair)
      B.store_extension(w, id, R.NodeExtension.with_pendingSources(B.extension(w, id), B.second(R.World, Nat, pair))), _ => w)
  +set = R.NodeExtension.pendingSources(B.extension(w, id))
  finish(w, source, set, B.pendingSlots(w, set))

def addPart(+w: R.World, +id: Nat, +source: Nat) -> B.Bundle<R.World, Bool>:
  +w = E.ext(w, id)
  setPart(w, id, source, R.NodeExtension.pendingSources(B.extension(w, id)))

def exact(+w: R.World, +id: Nat, +source: Nat) ->
  {P.addPendingSource(w, id, source) == B.choose(~B.Bundle<R.World, Bool>, P.hasSource(w, id, source), _ => B.Bundle{w, False{}}, _ => addPart(w, id, source)) : B.Bundle<R.World, Bool>}:
  {==}
