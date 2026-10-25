# Elementary Boolean/Nat consequences with no controller/history dependency.
import Base
import ./list-update-lookup.bend as Logic

def andRight(+left: Bool,+right: Bool,both: {Bool.and(left,right) == True{} : Bool}) -> {right == True{} : Bool}:
  match left:
    case True{}: both
    case False{}: Empty.absurd({right == True{} : Bool},Logic.impossible(Equal.sym(Bool,False{},True{},both)))

def self(+n: Nat) -> {Nat.is_eq(n,n) == True{} : Bool}:
  match n:
    case 0n: {==}
    case 1n+p: self(p)
