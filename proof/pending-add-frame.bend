# Observer-polymorphic proof for actual addPendingSource. The supplied helper
# laws are instantiated below by concrete source-operation frame proofs.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P
import ../runtime/extension.bend as E
import ./pending-add-operations.bend as Segment

def created(+w: R.World, +id: Nat) -> R.World:
  +pair = B.newPendingSet(w, [])
  +w = B.first(R.World, Nat, pair)
  B.store_extension(w, id, R.NodeExtension.with_pendingSources(B.extension(w, id), B.second(R.World, Nat, pair)))

def setWorld(+w: R.World, +id: Nat, set: Nat) -> R.World:
  B.choose(~R.World, Nat.is_eq(set, 0n), _ => created(w, id), _ => w)

def choice(~A: Data, ~observe: R.World -> A, +flag: Bool, +w: R.World, +left: R.World, +right: R.World,
  yes: {observe(left) == observe(w) : A}, no: {observe(right) == observe(w) : A}) ->
  {observe(B.choose(~R.World, flag, _ => left, _ => right)) == observe(w) : A}:
  match flag:
    case True{}: yes
    case False{}: no

def pairChoice(~A: Data, ~observe: R.World -> A, +flag: Bool, +w: R.World, +left: B.Bundle<R.World, Bool>, +right: B.Bundle<R.World, Bool>,
  yes: {observe(B.first(R.World, Bool, left)) == observe(w) : A}, no: {observe(B.first(R.World, Bool, right)) == observe(w) : A}) ->
  {observe(B.first(R.World, Bool, B.choose(~B.Bundle<R.World, Bool>, flag, _ => left, _ => right))) == observe(w) : A}:
  match flag:
    case True{}: yes
    case False{}: no

def createdFrame(~A: Data, ~observe: R.World -> A,
  ~pending: @+w: R.World -> @sets: List<&2, List<&2, Nat>> -> {observe(R.World.with_pendingSets(w, sets)) == observe(w) : A},
  ~extension: @+w: R.World -> @+id: Nat -> @+record: R.NodeExtension -> {observe(B.store_extension(w, id, record)) == observe(w) : A},
  +w: R.World, +id: Nat) -> {observe(created(w, id)) == observe(w) : A}:
  +pair = B.newPendingSet(w, [])
  +next = B.first(R.World, Nat, pair)
  Equal.trans(A, observe(created(w, id)), observe(next), observe(w),
    extension(next, id, R.NodeExtension.with_pendingSources(B.extension(next, id), B.second(R.World, Nat, pair))),
    pending(w, B.append(List<&2, Nat>, R.World.pendingSets(w), [[]])))

def setFrame(~A: Data, ~observe: R.World -> A,
  ~pending: @+w: R.World -> @sets: List<&2, List<&2, Nat>> -> {observe(R.World.with_pendingSets(w, sets)) == observe(w) : A},
  ~extension: @+w: R.World -> @+id: Nat -> @+record: R.NodeExtension -> {observe(B.store_extension(w, id, record)) == observe(w) : A},
  ~store: @+w: R.World -> @+set: Nat -> @+items: List<&2, Nat> -> {observe(B.store_pendingSet(w, set, items)) == observe(w) : A},
  +w: R.World, +id: Nat, +source: Nat, +set: Nat) ->
  {observe(B.first(R.World, Bool, Segment.setPart(w, id, source, set))) == observe(w) : A}:
  +next = setWorld(w, id, set)
  +slot = R.NodeExtension.pendingSources(B.extension(next, id))
  Equal.trans(A, observe(B.first(R.World, Bool, Segment.setPart(w, id, source, set))), observe(next), observe(w),
    store(next, slot, B.append(Nat, B.pendingSlots(next, slot), [source])),
    choice(A, observe, Nat.is_eq(set, 0n), w, created(w, id), w, createdFrame(A, observe, pending, extension, w, id), {==}))

def partFrame(~A: Data, ~observe: R.World -> A,
  ~pending: @+w: R.World -> @sets: List<&2, List<&2, Nat>> -> {observe(R.World.with_pendingSets(w, sets)) == observe(w) : A},
  ~extension: @+w: R.World -> @+id: Nat -> @+record: R.NodeExtension -> {observe(B.store_extension(w, id, record)) == observe(w) : A},
  ~store: @+w: R.World -> @+set: Nat -> @+items: List<&2, Nat> -> {observe(B.store_pendingSet(w, set, items)) == observe(w) : A},
  ~ext: @+w: R.World -> @+id: Nat -> {observe(E.ext(w, id)) == observe(w) : A},
  +w: R.World, +id: Nat, +source: Nat) ->
  {observe(B.first(R.World, Bool, Segment.addPart(w, id, source))) == observe(w) : A}:
  +next = E.ext(w, id)
  Equal.trans(A, observe(B.first(R.World, Bool, Segment.addPart(w, id, source))), observe(next), observe(w),
    setFrame(A, observe, pending, extension, store, next, id, source, R.NodeExtension.pendingSources(B.extension(next, id))), ext(w, id))

def add(~A: Data, ~observe: R.World -> A,
  ~pending: @+w: R.World -> @sets: List<&2, List<&2, Nat>> -> {observe(R.World.with_pendingSets(w, sets)) == observe(w) : A},
  ~extension: @+w: R.World -> @+id: Nat -> @+record: R.NodeExtension -> {observe(B.store_extension(w, id, record)) == observe(w) : A},
  ~store: @+w: R.World -> @+set: Nat -> @+items: List<&2, Nat> -> {observe(B.store_pendingSet(w, set, items)) == observe(w) : A},
  ~ext: @+w: R.World -> @+id: Nat -> {observe(E.ext(w, id)) == observe(w) : A},
  +w: R.World, +id: Nat, +source: Nat) ->
  {observe(B.first(R.World, Bool, P.addPendingSource(w, id, source))) == observe(w) : A}:
  Equal.trans(A, observe(B.first(R.World, Bool, P.addPendingSource(w, id, source))), observe(B.first(R.World, Bool, B.choose(~B.Bundle<R.World, Bool>, P.hasSource(w, id, source), _ => B.Bundle{w, False{}}, _ => Segment.addPart(w, id, source)))), observe(w),
    Equal.cong(B.Bundle<R.World, Bool>, A, pair => observe(B.first(R.World, Bool, pair)), P.addPendingSource(w, id, source), B.choose(~B.Bundle<R.World, Bool>, P.hasSource(w, id, source), _ => B.Bundle{w, False{}}, _ => Segment.addPart(w, id, source)), Segment.exact(w, id, source)),
    pairChoice(A, observe, P.hasSource(w, id, source), w, B.Bundle{w, False{}}, Segment.addPart(w, id, source), {==}, partFrame(A, observe, pending, extension, store, ext, w, id, source)))
