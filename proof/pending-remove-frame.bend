# Generic frame for actual source deletion, instantiated by concrete helper laws.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P
import ./pending-carrier-retirement.bend as Segment
import ./pending-add-frame.bend as Choice

def tail(~A: Data, ~observe: R.World -> A,
  ~extension: @+w: R.World -> @+id: Nat -> @+record: R.NodeExtension -> {observe(B.store_extension(w, id, record)) == observe(w) : A},
  ~store: @+w: R.World -> @+set: Nat -> @+items: List<&2, Nat> -> {observe(B.store_pendingSet(w, set, items)) == observe(w) : A},
  +w: R.World, +id: Nat, +set: Nat, +items: List<&2, Nat>) -> {observe(Segment.afterSlots(w, id, set, items)) == observe(w) : A}:
  +next = B.store_pendingSet(w, set, items)
  +record = R.NodeExtension.with_pendingSources(B.extension(next, id), 0n)
  Equal.trans(A, observe(Segment.afterSlots(w, id, set, items)), observe(next), observe(w), Choice.choice(A, observe, List.is_empty(&2, Nat, B.liveIds(items)), next, B.store_extension(next, id, record), next, extension(next, id, record), {==}), store(w, set, items))

def remove(~A: Data, ~observe: R.World -> A,
  ~extension: @+w: R.World -> @+id: Nat -> @+record: R.NodeExtension -> {observe(B.store_extension(w, id, record)) == observe(w) : A},
  ~store: @+w: R.World -> @+set: Nat -> @+items: List<&2, Nat> -> {observe(B.store_pendingSet(w, set, items)) == observe(w) : A},
  +w: R.World, +id: Nat, +source: Nat) -> {observe(B.first(R.World, Bool, P.removePendingSource(w, id, source))) == observe(w) : A}:
  +set = R.NodeExtension.pendingSources(B.extension(w, id))
  +items = P.removeSlot(B.pendingSlots(w, set), source)
  Equal.trans(A, observe(B.first(R.World, Bool, P.removePendingSource(w, id, source))), observe(B.first(R.World, Bool, B.choose(~B.Bundle<R.World, Bool>, P.hasSource(w, id, source), _ => B.Bundle{Segment.body(w, id, source), True{}}, _ => B.Bundle{w, False{}}))), observe(w), Equal.cong(B.Bundle<R.World, Bool>, A, pair => observe(B.first(R.World, Bool, pair)), P.removePendingSource(w, id, source), B.choose(~B.Bundle<R.World, Bool>, P.hasSource(w, id, source), _ => B.Bundle{Segment.body(w, id, source), True{}}, _ => B.Bundle{w, False{}}), Segment.exact(w, id, source)), Choice.pairChoice(A, observe, P.hasSource(w, id, source), w, B.Bundle{Segment.body(w, id, source), True{}}, B.Bundle{w, False{}}, tail(A, observe, extension, store, w, id, set, items), {==}))
