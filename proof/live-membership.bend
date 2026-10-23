# Concrete occurrence certificates for actual finite live lists. A split gives
# a real index; it does not use the out-of-range identity-zero fallback.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P
import ../runtime/transaction.bend as X
import ./arena.bend as Arena
import ./transaction-resolution.bend as Paths

type Located<-xs: List<&2, Nat>, -id: Nat> is Data:
  Located{before: List<&2, Nat>, after: List<&2, Nat>, shape: {xs == B.append(Nat, before, id <> after) : List<&2, Nat>}}

def index(-xs: List<&2, Nat>, -id: Nat, location: Located<xs, id>) -> Nat:
  match location:
    case Located{before, after, shape}: B.length(Nat, before)

def lookup(+xs: List<&2, Nat>, +id: Nat, +location: Located<xs, id>) ->
  {B.get(Nat, xs, index(xs, id, location), 0n) == id : Nat}:
  match location:
    case Located{+before, +after, shape}:
      Equal.trans(Nat, B.get(Nat, xs, B.length(Nat, before), 0n), B.get(Nat, B.append(Nat, before, id <> after), B.length(Nat, before), 0n), id,
        Equal.cong(List<&2, Nat>, Nat, values => B.get(Nat, values, B.length(Nat, before), 0n), xs, B.append(Nat, before, id <> after), shape), Arena.getPrefix(Nat, before, id, after, 0n))

def cast(-a: List<&2, Nat>, -b: List<&2, Nat>, -id: Nat, same: {a == b : List<&2, Nat>}, location: Located<a, id>) -> Located<b, id>:
  %same : Located<_, id>
  location

def orTrue(+left: Bool) -> {Bool.or(left, True{}) == True{} : Bool}:
  match left:
    case True{}: {==}
    case False{}: {==}

def containsSplit(+before: List<&2, Nat>, +after: List<&2, Nat>, +id: Nat) ->
  {B.contains(B.append(Nat, before, id <> after), id) == True{} : Bool}:
  match before:
    case Nil{}:
      Equal.cong(Bool, Bool, same => Bool.or(same, B.contains(after, id)), Nat.is_eq(id, id), True{}, Paths.sameNat(id))
    case +head <> +rest:
      Equal.trans(Bool, B.contains(head <> B.append(Nat, rest, id <> after), id), Bool.or(Nat.is_eq(head, id), True{}), True{},
        Equal.cong(Bool, Bool, found => Bool.or(Nat.is_eq(head, id), found), B.contains(B.append(Nat, rest, id <> after), id), True{}, containsSplit(rest, after, id)), orTrue(Nat.is_eq(head, id)))

def contains(+xs: List<&2, Nat>, +id: Nat, location: Located<xs, id>) -> {B.contains(xs, id) == True{} : Bool}:
  match location:
    case Located{+before, +after, shape}:
      Equal.trans(Bool, B.contains(xs, id), B.contains(B.append(Nat, before, id <> after), id), True{}, Equal.cong(List<&2, Nat>, Bool, values => B.contains(values, id), xs, B.append(Nat, before, id <> after), shape), containsSplit(before, after, id))

def prepend(+xs: List<&2, Nat>, +id: Nat, +head: Nat, location: Located<xs, id>) -> Located<head <> xs, id>:
  match location:
    case Located{+before, +after, shape}:
      Located{head <> before, after, Equal.cong(List<&2, Nat>, List<&2, Nat>, values => head <> values, xs, B.append(Nat, before, id <> after), shape)}

def choice(+condition: Bool, +left: List<&2, Nat>, +right: List<&2, Nat>, +id: Nat, leftLocation: Located<left, id>, rightLocation: Located<right, id>) ->
  Located<B.choose(~List<&2, Nat>, condition, _ => left, _ => right), id>:
  match condition:
    case True{}: leftLocation
    case False{}: rightLocation

def removeSplit(+before: List<&2, Nat>, +after: List<&2, Nat>, +removed: Nat, +kept: Nat,
  +different: {Nat.is_eq(kept, removed) == False{} : Bool}) -> Located<P.remove(B.append(Nat, before, kept <> after), removed), kept>:
  match before:
    case Nil{}:
      Located{[], P.remove(after, removed), Equal.cong(Bool, List<&2, Nat>, same => B.choose(~List<&2, Nat>, same, _ => after, _ => kept <> P.remove(after, removed)), Nat.is_eq(kept, removed), False{}, different)}
    case +head <> +rest:
      +tail = B.append(Nat, rest, kept <> after)
      choice(Nat.is_eq(head, removed), tail, head <> P.remove(tail, removed), kept, Located{rest, after, {==}}, prepend(P.remove(tail, removed), kept, head, removeSplit(rest, after, removed, kept, different)))

def removeLocated(+xs: List<&2, Nat>, +removed: Nat, +kept: Nat, location: Located<xs, kept>,
  different: {Nat.is_eq(kept, removed) == False{} : Bool}) -> Located<P.remove(xs, removed), kept>:
  match location:
    case Located{+before, +after, shape}:
      +split = B.append(Nat, before, kept <> after)
      cast(P.remove(split, removed), P.remove(xs, removed), kept,
        Equal.cong(List<&2, Nat>, List<&2, Nat>, values => P.remove(values, removed), split, xs, Equal.sym(List<&2, Nat>, xs, split, shape)), removeSplit(before, after, removed, kept, different))

def retained(+xs: List<&2, Nat>, +removed: Nat, +kept: Nat, removedLocation: Located<xs, removed>, keptLocation: Located<xs, kept>,
  different: {Nat.is_eq(kept, removed) == False{} : Bool}) -> Located<X.removeIdentity(xs, removed), kept>:
  cast(P.remove(xs, removed), X.removeIdentity(xs, removed), kept,
    Equal.sym(List<&2, Nat>, X.removeIdentity(xs, removed), P.remove(xs, removed),
      Equal.cong(Bool, List<&2, Nat>, present => B.choose(~List<&2, Nat>, present, _ => P.remove(xs, removed), _ => X.dropLast(xs)), B.contains(xs, removed), True{}, contains(xs, removed, removedLocation))), removeLocated(xs, removed, kept, keptLocation, different))

def pair(+xs: List<&2, Nat>, +left: Nat, +right: Nat, +chooseLeft: Bool) ->
  Located<B.append(Nat, xs, [left, right]), B.choose(~Nat, chooseLeft, _ => left, _ => right)>:
  match chooseLeft:
    case True{}: Located{xs, [right], {==}}
    case False{}:
      Located{B.append(Nat, xs, [left]), [], Equal.sym(List<&2, Nat>, B.append(Nat, B.append(Nat, xs, [left]), [right]), B.append(Nat, xs, [left, right]), Arena.appendSingletons(Nat, xs, left, right))}
