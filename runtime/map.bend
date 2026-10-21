# src/map.ts repeat/RepeatData. Continuations at callbacks/disposal/computed
# entry live in core.repeat*; no alternative reconciliation algorithm is used.
import Base
import ../representation/base.bend as B
import ../representation/records.bend as R
import ./arrays.bend as Arrays
import ./owner-state.bend as Owner

def blank() -> R.RepeatState:
  R.RepeatState{0n, 0n, 0n, R.Literal{R.Undefined{}}, R.Undefined{}, R.NoInlineBody{}, R.NoInlineBody{}, [], 0n}

def get(w: R.World, id: Nat) -> R.RepeatState:
  B.get(R.RepeatState, R.World.repeats(w), id, blank())

def store(+w: R.World, id: Nat, state: R.RepeatState) -> R.World:
  R.World.with_repeats(w, List.set(&2, R.RepeatState, R.World.repeats(w), id, state))

# repeat's data literal before computed(updateRepeat.bind(data)). Function
# bodies are captured syntax, and mapper is the existing callable Value ABI.
def repeat(+w: R.World, count: R.Expr, mapper: R.Value, from: R.InlineBody, fallback: R.InlineBody) -> B.Bundle<R.World, Nat>:
  +owner = B.length(R.Node, R.World.nodes(w))
  +w = Owner.createOwner(w, R.World.context(w), False{})
  +pair = Arrays.fresh(w, 0n)
  +w = B.first(R.World, Nat, pair)
  +id = B.length(R.RepeatState, R.World.repeats(w))
  +state = {R.RepeatState{owner, 0n, 0n, count, mapper, from, fallback, [], B.second(R.World, Nat, pair)} : R.RepeatState}
  B.Bundle{R.World.with_repeats(w, B.append(R.RepeatState, R.World.repeats(w), [state])), id}

# updateRepeat's first statement runs every pass, including the first eager one.
def updateParent(+w: R.World, id: Nat) -> R.World:
  +owner = R.RepeatState.owner(get(w, id))
  B.store_node(w, owner, R.Node.with_parentComputed(B.node(w, owner), R.World.context(w)))

# Empty transition, only after owner.dispose(false) returned successfully.
def clear(+w: R.World, +id: Nat) -> R.World:
  +w = store(w, id, R.RepeatState.with_nodes(get(w, id), []))
  +pair = Arrays.fresh(w, 0n)
  +w = store(B.first(R.World, Nat, pair), id, R.RepeatState.with_mappings(get(B.first(R.World, Nat, pair), id), B.second(R.World, Nat, pair)))
  +w = store(w, id, R.RepeatState.with_len(get(w, id), 0n))
  store(w, id, R.RepeatState.with_offset(get(w, id), 0n))

def emptyNodes(size: Nat) -> List<&2, Nat>:
  match size:
    case 0n:
      []
    case 1n+p:
      0n <> emptyNodes(p)

def frame(+id: Nat, +state: R.RepeatState, +newLen: Nat, +from: Nat, mappings: Nat) -> R.RepeatFrame:
  +to = Nat.add(from, newLen)
  +prevTo = Nat.add(R.RepeatState.offset(state), R.RepeatState.len(state))
  R.RepeatFrame{id, newLen, from, to, prevTo, Nat.max(from, R.RepeatState.offset(state)), Nat.min(to, prevTo), mappings, emptyNodes(newLen)}

def retained(+frame: R.RepeatFrame, +index: Nat) -> Bool:
  Bool.and(Nat.is_ge(index, R.RepeatFrame.keepStart(frame)), Nat.is_lt(index, R.RepeatFrame.keepEnd(frame)))

# Final assignments after every mapper and exiting-owner disposal succeeded.
def publish(+w: R.World, +frame: R.RepeatFrame) -> R.World:
  +id = R.RepeatFrame.repeat(frame)
  +w = store(w, id, R.RepeatState.with_mappings(get(w, id), R.RepeatFrame.mappings(frame)))
  +w = store(w, id, R.RepeatState.with_nodes(get(w, id), R.RepeatFrame.nodes(frame)))
  +w = store(w, id, R.RepeatState.with_offset(get(w, id), R.RepeatFrame.from(frame)))
  store(w, id, R.RepeatState.with_len(get(w, id), R.RepeatFrame.newLen(frame)))
