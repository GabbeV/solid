# src/map.ts MapData/mapArray/updateKeyedMap bookkeeping: keyed:false row
# signals or plain identity-keyed mapping. _indexes/_key remain absent; their
# constructor profiles are unfinished, not replaced by these admitted modes.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./arrays.bend as Arrays
import ./owner-state.bend as Owner
import ./map.bend as Repeat

def blank() -> R.MapState:
  R.MapState{0n, 0n, R.Literal{R.Undefined{}}, 0n, R.Undefined{}, 0n, [], [], R.NoInlineBody{}, True{}, [], False{}, R.Undefined{}}

def get(+w: R.World, +id: Nat) -> R.MapState:
  B.get(R.MapState, R.World.maps(w), id, blank())

def store(+w: R.World, +id: Nat, +state: R.MapState) -> R.World:
  R.World.with_maps(w, List.set(&2, R.MapState, R.World.maps(w), id, state))

def mapArray(+w: R.World, +list: R.Expr, +mapper: R.Value, +fallback: R.InlineBody, +byIndex: Bool, +arity: Nat, +key: R.Value) -> B.Bundle<R.World, Nat>:
  +hasIndexes = Bool.and(Nat.is_gt(arity, 1n), Bool.not(byIndex))
  +owner = B.length(R.Node, R.World.nodes(w))
  +w = Owner.createOwner(w, R.World.context(w), False{})
  +items = Arrays.fresh(w, 0n)
  +mappings = Arrays.fresh(B.first(R.World, Nat, items), 0n)
  +w = B.first(R.World, Nat, mappings)
  +id = B.length(R.MapState, R.World.maps(w))
  +state = {R.MapState{owner, 0n, list, B.second(R.World, Nat, items), mapper, B.second(R.World, Nat, mappings), [], [], fallback, byIndex, [], hasIndexes, key} : R.MapState}
  B.Bundle{R.World.with_maps(w, B.append(R.MapState, R.World.maps(w), [state])), id}

def updateParent(+w: R.World, +id: Nat) -> R.World:
  +owner = R.MapState.owner(get(w, id))
  B.store_node(w, owner, R.Node.with_parentComputed(B.node(w, owner), R.World.context(w)))

# The source row vector is present for index keying or an extracted key.
def hasRows(+state: R.MapState) -> Bool:
  Bool.or(R.MapState.byIndex(state), B.truth(R.MapState.key(state)))

# Empty transition after successful owner.dispose(false), exact store order.
def clear(+w: R.World, +id: Nat) -> R.World:
  +w = store(w, id, R.MapState.with_nodes(get(w, id), []))
  +pair = Arrays.fresh(w, 0n)
  +w = store(B.first(R.World, Nat, pair), id, R.MapState.with_items(get(B.first(R.World, Nat, pair), id), B.second(R.World, Nat, pair)))
  +pair = Arrays.fresh(w, 0n)
  +w = store(B.first(R.World, Nat, pair), id, R.MapState.with_mappings(get(B.first(R.World, Nat, pair), id), B.second(R.World, Nat, pair)))
  +w = store(w, id, R.MapState.with_len(get(w, id), 0n))
  +w = B.choose(~R.World, hasRows(get(w, id)), _ => store(w, id, R.MapState.with_rows(get(w, id), [])), _ => w)
  B.choose(~R.World, R.MapState.hasIndexes(get(w, id)), _ => store(w, id, R.MapState.with_indexes(get(w, id), [])), _ => w)

# compare(undefined, old, next) in this profile. Keep the === fast disjunct
# before that always-true row-mode comparison; there is no extracted key call.
def matches(+w: R.World, oldItems: Nat, newItems: Nat, oldIndex: Nat, newIndex: Nat, byIndex: Bool) -> Bool:
  Bool.or(B.equal(Arrays.at(w, oldItems, oldIndex), Arrays.at(w, newItems, newIndex)), byIndex)


# Inclusive TS end/newEnd use exclusive bounds here (source index plus one),
# representing -1 exactly as zero. All loop guards account for this encoding.
def frame(+id: Nat, +items: Nat, +newLen: Nat, +oldLen: Nat, +start: Nat, +mappings: Nat, +initial: Bool, +newEnd: Nat, +hasRows: Bool, +hasIndexes: Bool) -> R.MapFrame:
  +size = B.choose(~Nat, initial, _ => newLen, _ => Nat.sub(newEnd, start))
  R.MapFrame{id, items, newLen, start, oldLen, newEnd, mappings, Repeat.emptyNodes(size), B.choose(~List<&2, Nat>, hasRows, _ => Repeat.emptyNodes(size), _ => []), [], [], initial, [], [], B.choose(~List<&2, Nat>, hasIndexes, _ => Repeat.emptyNodes(size), _ => [])}

# SameValueZero is the JS Map key relation, unlike source prefix strict ===.
def sameKey(+a: R.Value, +b: R.Value) -> Bool:
  match a b:
    case R.NotANumber{} R.NotANumber{}:
      True{}
    case left right:
      B.equal(left, right)

def indexGet(+entries: List<&2, R.MapEntry>, +key: R.Value) -> R.MapIndex:
  match entries:
    case Nil{}:
      R.MapMissing{}
    case entry <> tail:
      B.choose(~R.MapIndex, sameKey(R.MapEntry.key(entry), key), _ => R.MapEntry.position(entry), _ => indexGet(tail, key))

def indexSet(+entries: List<&2, R.MapEntry>, +key: R.Value, +position: R.MapIndex) -> List<&2, R.MapEntry>:
  match entries:
    case Nil{}:
      [R.MapEntry{key, position}]
    case entry <> tail:
      B.choose(~List<&2, R.MapEntry>, sameKey(R.MapEntry.key(entry), key),
        _ => R.MapEntry{R.MapEntry.key(entry), position} <> tail,
        _ => entry <> indexSet(tail, key, position))

def nextIndex(+position: R.MapIndex) -> R.MapIndex:
  match position:
    case R.MapMissing{}:
      R.MapEnd{}
    case other:
      other

# updateKeyedMap's backwards newIndices/newIndicesNext construction. Index mode
# grows only at its tail, but retains the source's actual preparation loop.
def prepareIndices(cursor: Nat, +w: R.World, +frame: R.MapFrame) -> R.MapFrame:
  match cursor:
    case 0n:
      frame
    case 1n+ +j:
      B.choose(~R.MapFrame, Nat.is_ge(j, R.MapFrame.start(frame)),
        _ =>
          +item = Arrays.at(w, R.MapFrame.newItems(frame), j)
          +old = indexGet(R.MapFrame.keyIndices(frame), item)
          +frame = R.MapFrame.with_next(frame, B.put(R.MapIndex, R.MapFrame.next(frame), Nat.sub(j, R.MapFrame.start(frame)), R.MapMissing{}, nextIndex(old)))
          +frame = R.MapFrame.with_keyIndices(frame, indexSet(R.MapFrame.keyIndices(frame), item, R.MapAt{j}))
          prepareIndices(j, w, frame),
        _ => frame)

# No-structural-change and final commit's newItems.slice(0), after callbacks.
def saveItems(+w: R.World, +id: Nat, +items: Nat) -> R.World:
  +pair = Arrays.slice(w, items, 0n, Arrays.length(w, items))
  store(B.first(R.World, Nat, pair), id, R.MapState.with_items(get(B.first(R.World, Nat, pair), id), B.second(R.World, Nat, pair)))

# Create-all commit differs from the general commit: rows land before items/len.
def publishInitial(+w: R.World, +frame: R.MapFrame) -> R.World:
  +id = R.MapFrame.map(frame)
  +w = store(w, id, R.MapState.with_mappings(get(w, id), R.MapFrame.mappings(frame)))
  +w = store(w, id, R.MapState.with_nodes(get(w, id), R.MapFrame.nodes(frame)))
  +w = B.choose(~R.World, hasRows(get(w, id)), _ => store(w, id, R.MapState.with_rows(get(w, id), R.MapFrame.rows(frame))), _ => w)
  +w = B.choose(~R.World, R.MapState.hasIndexes(get(w, id)), _ => store(w, id, R.MapState.with_indexes(get(w, id), R.MapFrame.indexes(frame))), _ => w)
  +w = saveItems(w, id, R.MapFrame.newItems(frame))
  store(w, id, R.MapState.with_len(get(w, id), R.MapFrame.newLen(frame)))

# General commit's final assignments, before removed-owner disposal.
def publishWindow(+w: R.World, +frame: R.MapFrame) -> R.World:
  +id = R.MapFrame.map(frame)
  +w = store(w, id, R.MapState.with_mappings(get(w, id), R.MapFrame.mappings(frame)))
  +w = store(w, id, R.MapState.with_len(get(w, id), R.MapFrame.newLen(frame)))
  saveItems(w, id, R.MapFrame.newItems(frame))

def takeNodes(+size: Nat, +nodes: List<&2, Nat>) -> List<&2, Nat>:
  match size nodes:
    case 0n _:
      []
    case _ Nil{}:
      []
    case 1n+p node <> tail:
      node <> takeNodes(p, tail)

# Old suffix index for new position j. This represents signed dif without
# saturating a negative difference; each subtraction is guarded by list shape.
def sourceSlot(+newLen: Nat, +oldLen: Nat, +index: Nat) -> Nat:
  Nat.add(Nat.sub(index, Nat.sub(newLen, oldLen)), Nat.sub(oldLen, newLen))
