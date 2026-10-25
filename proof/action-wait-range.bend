# All previous action-wait identities lie below the append-only observer arena.
# This establishes freshness without assuming a final lookup or unique old IDs.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ./node-allocation-validity.bend as Order
import ./list-update-lookup.bend as Logic
import ./pending-committed-history.bend as BoolProof


def below(waits: List<&2,R.ActionWait>,+bound: Nat) -> Bool:
  match waits:
    case Nil{}: True{}
    case head <> tail: Bool.and(Nat.is_lt(R.ActionWait.observer(head),bound),below(tail,bound))

def lessDifferent(+a: Nat,+b: Nat,less: {Nat.is_lt(a,b) == True{} : Bool}) -> {Nat.is_eq(a,b) == False{} : Bool}:
  match a b:
    case 0n 0n: Empty.absurd({Nat.is_eq(0n,0n) == False{} : Bool},Logic.impossible(Equal.sym(Bool,False{},True{},less)))
    case 1n+p 0n: Empty.absurd({Nat.is_eq(1n+p,0n) == False{} : Bool},Logic.impossible(Equal.sym(Bool,False{},True{},less)))
    case 0n 1n+p: {==}
    case 1n+p 1n+q: lessDifferent(p,q,less)

def absent(waits: List<&2,R.ActionWait>,+bound: Nat,+valid: {below(waits,bound) == True{} : Bool}) -> {A.find(waits,bound) == None{} : Maybe<&2,R.ActionWait>}:
  match waits:
    case Nil{}: {==}
    case +head <> +tail:
      +less = BoolProof.andLeft(Nat.is_lt(R.ActionWait.observer(head),bound),below(tail,bound),valid)
      +rest = BoolProof.andRight(Nat.is_lt(R.ActionWait.observer(head),bound),below(tail,bound),valid)
      Equal.trans(Maybe<&2,R.ActionWait>,A.find(head <> tail,bound),A.find(tail,bound),None{},Equal.cong(Bool,Maybe<&2,R.ActionWait>,same=>B.choose(~Maybe<&2,R.ActionWait>,same,_=>Some{head},_=>A.find(tail,bound)),Nat.is_eq(R.ActionWait.observer(head),bound),False{},lessDifferent(R.ActionWait.observer(head),bound,less)),absent(tail,bound,rest))

def extend(waits: List<&2,R.ActionWait>,+bound: Nat,+valid: {below(waits,bound) == True{} : Bool}) -> {below(waits,Nat.add(bound,1n)) == True{} : Bool}:
  match waits:
    case Nil{}: {==}
    case +head <> +tail:
      +oldLess = BoolProof.andLeft(Nat.is_lt(R.ActionWait.observer(head),bound),below(tail,bound),valid)
      +oldTail = BoolProof.andRight(Nat.is_lt(R.ActionWait.observer(head),bound),below(tail,bound),valid)
      +newLess = Order.extend(R.ActionWait.observer(head),bound,oldLess)
      +newTail = extend(tail,bound,oldTail)
      Equal.trans(Bool,below(head <> tail,Nat.add(bound,1n)),Bool.and(True{},below(tail,Nat.add(bound,1n))),True{},Equal.cong(Bool,Bool,flag=>Bool.and(flag,below(tail,Nat.add(bound,1n))),Nat.is_lt(R.ActionWait.observer(head),Nat.add(bound,1n)),True{},newLess),newTail)

def append(waits: List<&2,R.ActionWait>,+suffix: List<&2,R.ActionWait>,+bound: Nat,+valid: {below(waits,bound) == True{} : Bool},+extra: {below(suffix,bound) == True{} : Bool}) -> {below(B.append(R.ActionWait,waits,suffix),bound) == True{} : Bool}:
  match waits:
    case Nil{}: extra
    case +head <> +tail:
      +headLess = BoolProof.andLeft(Nat.is_lt(R.ActionWait.observer(head),bound),below(tail,bound),valid)
      +tailLess = BoolProof.andRight(Nat.is_lt(R.ActionWait.observer(head),bound),below(tail,bound),valid)
      Equal.trans(Bool,below(B.append(R.ActionWait,head <> tail,suffix),bound),below(B.append(R.ActionWait,tail,suffix),bound),True{},Equal.cong(Bool,Bool,flag=>Bool.and(flag,below(B.append(R.ActionWait,tail,suffix),bound)),Nat.is_lt(R.ActionWait.observer(head),bound),True{},headLess),append(tail,suffix,bound,tailLess,extra))

def freshFits(+observer: Nat,+action: Nat,+kind: U32) -> {below([R.ActionWait{observer,action,kind,False{}}],Nat.add(observer,1n)) == True{} : Bool}:
  Equal.cong(Bool,Bool,flag=>Bool.and(flag,True{}),Nat.is_lt(observer,Nat.add(observer,1n)),True{},Order.nextRoom(observer))


def successorPositive(+n: Nat) -> {Nat.is_ne(Nat.add(n,1n),0n) == True{} : Bool}:
  match n:
    case 0n: {==}
    case 1n+p: {==}
