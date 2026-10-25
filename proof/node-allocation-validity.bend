# Fresh and retained valid IDs from actual append. Nonzero identity follows
# from the reserved nonempty input arena; no final membership is assumed.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/construct-state.bend as N
import ./node-append-construction.bend as Append
import ./pending-committed-history.bend as Logic
import ./list-update-lookup.bend as Lookup

def nextRoom(+n: Nat) -> {Nat.is_lt(n, Nat.add(n, 1n)) == True{} : Bool}:
  match n:
    case 0n: {==}
    case 1n+p: nextRoom(p)

def extend(+id: Nat, +n: Nat, room: {Nat.is_lt(id, n) == True{} : Bool}) ->
  {Nat.is_lt(id, Nat.add(n, 1n)) == True{} : Bool}:
  match id n:
    case 0n 0n: Empty.absurd({Nat.is_lt(0n, Nat.add(0n, 1n)) == True{} : Bool}, Lookup.impossible(Equal.sym(Bool, False{}, True{}, room)))
    case 1n+p 0n: Empty.absurd({Nat.is_lt(1n+p, Nat.add(0n, 1n)) == True{} : Bool}, Lookup.impossible(Equal.sym(Bool, False{}, True{}, room)))
    case 0n 1n+n: {==}
    case 1n+p 1n+n: extend(p, n, room)

def fresh(+w: R.World, +value: R.Node, +first: R.Node, +tail: List<&2, R.Node>, known: {R.World.nodes(w) == first <> tail : List<&2, R.Node>}) ->
  {B.valid(N.append(w, value), B.length(R.Node, R.World.nodes(w))) == True{} : Bool}:
  +id = B.length(R.Node, R.World.nodes(w))
  +nonzero = Equal.cong(Nat, Bool, i => Nat.is_ne(i, 0n), id, 1n+B.length(R.Node, tail), Append.positive(w, first, tail, known))
  +room = Equal.trans(Bool, Nat.is_lt(id, B.length(R.Node, R.World.nodes(N.append(w, value)))), Nat.is_lt(id, Nat.add(id, 1n)), True{}, Equal.cong(Nat, Bool, count => Nat.is_lt(id, count), B.length(R.Node, R.World.nodes(N.append(w, value))), Nat.add(id, 1n), Append.count(w, value)), nextRoom(id))
  Equal.trans(Bool, Bool.and(Nat.is_ne(id, 0n), Nat.is_lt(id, B.length(R.Node, R.World.nodes(N.append(w, value))))), Nat.is_lt(id, B.length(R.Node, R.World.nodes(N.append(w, value)))), True{}, Equal.cong(Bool, Bool, flag => Bool.and(flag, Nat.is_lt(id, B.length(R.Node, R.World.nodes(N.append(w, value))))), Nat.is_ne(id, 0n), True{}, nonzero), room)

def old(+w: R.World, +value: R.Node, +id: Nat, +known: {B.valid(w, id) == True{} : Bool}) ->
  {B.valid(N.append(w, value), id) == True{} : Bool}:
  +n = B.length(R.Node, R.World.nodes(w))
  +nz = Logic.andLeft(Nat.is_ne(id, 0n), Nat.is_lt(id, n), known)
  +fits = Logic.andRight(Nat.is_ne(id, 0n), Nat.is_lt(id, n), known)
  +room = Equal.trans(Bool, Nat.is_lt(id, B.length(R.Node, R.World.nodes(N.append(w, value)))), Nat.is_lt(id, Nat.add(n, 1n)), True{}, Equal.cong(Nat, Bool, count => Nat.is_lt(id, count), B.length(R.Node, R.World.nodes(N.append(w, value))), Nat.add(n, 1n), Append.count(w, value)), extend(id, n, fits))
  Equal.trans(Bool, B.valid(N.append(w, value), id), Nat.is_lt(id, B.length(R.Node, R.World.nodes(N.append(w, value)))), True{}, Equal.cong(Bool, Bool, flag => Bool.and(flag, Nat.is_lt(id, B.length(R.Node, R.World.nodes(N.append(w, value))))), Nat.is_ne(id, 0n), True{}, nz), room)
