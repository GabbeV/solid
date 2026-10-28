# Small structural arithmetic facts for source-derived traversal budgets.
import Base

def zero(+n: Nat) -> {Nat.add(n,0n) == n : Nat}:
  match n:
    case 0n: {==}
    case 1n+p: Equal.cong(Nat,Nat,x=>1n+x,Nat.add(p,0n),p,zero(p))

def successor(+a: Nat,+b: Nat) -> {Nat.add(a,1n+b) == 1n+Nat.add(a,b) : Nat}:
  match a:
    case 0n: {==}
    case 1n+p: Equal.cong(Nat,Nat,x=>1n+x,Nat.add(p,1n+b),1n+Nat.add(p,b),successor(p,b))

def commute(+a: Nat,+b: Nat) -> {Nat.add(a,b) == Nat.add(b,a) : Nat}:
  match a:
    case 0n: Equal.sym(Nat,Nat.add(b,0n),b,zero(b))
    case 1n+p:
      Equal.trans(Nat,1n+Nat.add(p,b),1n+Nat.add(b,p),Nat.add(b,1n+p),Equal.cong(Nat,Nat,x=>1n+x,Nat.add(p,b),Nat.add(b,p),commute(p,b)),Equal.sym(Nat,Nat.add(b,1n+p),1n+Nat.add(b,p),successor(b,p)))

def geSelf(+n: Nat) -> {Nat.is_ge(n,n) == True{} : Bool}:
  match n:
    case 0n: {==}
    case 1n+p: geSelf(p)
