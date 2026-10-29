# Elementary Boolean/Nat consequences with no controller/history dependency.
import Base
import ./list-update-lookup.bend as Logic

def andLeft(+left: Bool,+right: Bool,both: {Bool.and(left,right) == True{} : Bool}) -> {left == True{} : Bool}:
  match left:
    case True{}: {==}
    case False{}: Empty.absurd({False{} == True{} : Bool},Logic.impossible(Equal.sym(Bool,False{},True{},both)))

def andRight(+left: Bool,+right: Bool,both: {Bool.and(left,right) == True{} : Bool}) -> {right == True{} : Bool}:
  match left:
    case True{}: both
    case False{}: Empty.absurd({right == True{} : Bool},Logic.impossible(Equal.sym(Bool,False{},True{},both)))

def self(+n: Nat) -> {Nat.is_eq(n,n) == True{} : Bool}:
  match n:
    case 0n: {==}
    case 1n+p: self(p)

# A source fast-path gate can be armed or not; a nonguess never takes it.
def andFalse(left: Bool) -> {Bool.and(left,False{}) == False{} : Bool}:
  match left:
    case True{}: {==}
    case False{}: {==}
