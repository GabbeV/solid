# Generic actual list-update lookup laws. Sparse B.put fills new slots with
# the same fallback used by B.get; List.set keeps its existing-slot behavior.
import Base
import ../representation/base.bend as B

def truthType(value: Bool) -> Data:
  match value:
    case True{}: Unit
    case False{}: Empty

def impossible(e: {True{} == False{} : Bool}) -> Empty:
  %e : truthType(_)
  Unit{}

def putSame(-A: Data, +xs: List<&2, A>, +index: Nat, +fallback: A, +value: A) ->
  {B.get(A, B.put(A, xs, index, fallback, value), index, fallback) == value : A}:
  match xs index:
    case Nil{} 0n: {==}
    case Nil{} 1n+p: putSame(A, [], p, fallback, value)
    case first <> rest 0n: {==}
    case first <> rest 1n+p: putSame(A, rest, p, fallback, value)

def putOther(-A: Data, +xs: List<&2, A>, +write: Nat, +read: Nat, +fallback: A, +value: A,
  different: {Nat.is_eq(read, write) == False{} : Bool}) ->
  {B.get(A, B.put(A, xs, write, fallback, value), read, fallback) == B.get(A, xs, read, fallback) : A}:
  match xs write read:
    case Nil{} 0n 0n:
      Empty.absurd({B.get(A, B.put(A, [], 0n, fallback, value), 0n, fallback) == B.get(A, [], 0n, fallback) : A}, impossible(different))
    case Nil{} 0n 1n+p: {==}
    case Nil{} 1n+p 0n: {==}
    case Nil{} 1n+p 1n+q: putOther(A, [], p, q, fallback, value, different)
    case first <> rest 0n 0n:
      Empty.absurd({B.get(A, B.put(A, first <> rest, 0n, fallback, value), 0n, fallback) == B.get(A, first <> rest, 0n, fallback) : A}, impossible(different))
    case first <> rest 0n 1n+q: {==}
    case first <> rest 1n+p 0n: {==}
    case first <> rest 1n+p 1n+q: putOther(A, rest, p, q, fallback, value, different)

def setOther(-A: Data, +xs: List<&2, A>, +write: Nat, +read: Nat, +fallback: A, +value: A,
  different: {Nat.is_eq(read, write) == False{} : Bool}) ->
  {B.get(A, List.set(&2, A, xs, write, value), read, fallback) == B.get(A, xs, read, fallback) : A}:
  match xs write read:
    case Nil{} w r: {==}
    case first <> rest 0n 0n:
      Empty.absurd({B.get(A, List.set(&2, A, first <> rest, 0n, value), 0n, fallback) == B.get(A, first <> rest, 0n, fallback) : A}, impossible(different))
    case first <> rest 0n 1n+q: {==}
    case first <> rest 1n+p 0n: {==}
    case first <> rest 1n+p 1n+q: setOther(A, rest, p, q, fallback, value, different)

def setReadIdentity(-A: Data, +xs: List<&2, A>, +index: Nat, +fallback: A) ->
  {List.set(&2, A, xs, index, B.get(A, xs, index, fallback)) == xs : List<&2, A>}:
  match xs index:
    case Nil{} n: {==}
    case first <> rest 0n: {==}
    case +first <> +rest 1n+p:
      Equal.cong(List<&2, A>, List<&2, A>, result => first <> result, List.set(&2, A, rest, p, B.get(A, rest, p, fallback)), rest, setReadIdentity(A, rest, p, fallback))

def noOrLeft(+a: Bool, +b: Bool, no: {Bool.or(a, b) == False{} : Bool}) -> {a == False{} : Bool}:
  match a:
    case False{}: {==}
    case True{}: Empty.absurd({True{} == False{} : Bool}, impossible(no))

def noOrRight(+a: Bool, +b: Bool, no: {Bool.or(a, b) == False{} : Bool}) -> {b == False{} : Bool}:
  match a:
    case False{}: no
    case True{}: Empty.absurd({b == False{} : Bool}, impossible(no))
