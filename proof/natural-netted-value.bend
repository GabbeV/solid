# A netted natural payload is still exactly the proposed represented value.
# This lemma deliberately does not assert that for all strict-equal JS values:
# opposite signed zeros have different represented payloads.
import Base
import ../representation/base.bend as B
import ../representation/records.bend as R
import ./list-update-lookup.bend as Logic

def same(+left: Nat,+right: Nat,known: {Nat.is_eq(right,left) == True{} : Bool}) -> {left == right : Nat}:
  match left right:
    case 0n 0n: {==}
    case 0n 1n+r:
      Empty.absurd({0n == 1n+r : Nat},Logic.impossible(Equal.sym(Bool,False{},True{},known)))
    case 1n+l 0n:
      Empty.absurd({1n+l == 0n : Nat},Logic.impossible(Equal.sym(Bool,False{},True{},known)))
    case 1n+l 1n+r:
      Equal.cong(Nat,Nat,n=>1n+n,l,r,same(l,r,known))

def picked(+left: Nat,+right: Nat,+gate: Bool,known: {Nat.is_eq(right,left) == gate : Bool}) -> {B.choose(~R.Value,gate,_=>R.Number{left},_=>R.Number{right}) == R.Number{right} : R.Value}:
  match gate:
    case True{}:
      Equal.cong(Nat,R.Value,n=>R.Number{n},left,right,same(left,right,known))
    case False{}: {==}

def pick(+left: Nat,+right: Nat) -> {B.choose(~R.Value,Nat.is_eq(right,left),_=>R.Number{left},_=>R.Number{right}) == R.Number{right} : R.Value}:
  picked(left,right,Nat.is_eq(right,left),{==})

# rc.21 retains the strict gate and also requires SameValue.
def both(+gate: Bool) -> {Bool.and(gate,gate) == gate : Bool}:
  match gate:
    case True{}: {==}
    case False{}: {==}

def pickSame(+left: Nat,+right: Nat) -> {B.choose(~R.Value,Bool.and(Nat.is_eq(right,left),Nat.is_eq(right,left)),_=>R.Number{left},_=>R.Number{right}) == R.Number{right} : R.Value}:
  Equal.trans(R.Value,B.choose(~R.Value,Bool.and(Nat.is_eq(right,left),Nat.is_eq(right,left)),_=>R.Number{left},_=>R.Number{right}),B.choose(~R.Value,Nat.is_eq(right,left),_=>R.Number{left},_=>R.Number{right}),R.Number{right},Equal.cong(Bool,R.Value,gate=>B.choose(~R.Value,gate,_=>R.Number{left},_=>R.Number{right}),Bool.and(Nat.is_eq(right,left),Nat.is_eq(right,left)),Nat.is_eq(right,left),both(Nat.is_eq(right,left))),pick(left,right))
