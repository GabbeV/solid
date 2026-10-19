# Mathematical interpretation of the exact binary question representation.
# This proof does not unfold the large mainline ID to a unary concrete Nat.
import Base
import ../representation/records.bend as R
import ../runtime/question.bend as Q

def twice(value: Nat) -> Nat:
  match value:
    case 0n:
      0n
    case 1n+pred:
      2n+twice(pred)

def meaning(value: R.Question) -> Nat:
  match value:
    case R.QuestionZero{}:
      0n
    case R.QuestionOdd{half}:
      1n+twice(meaning(half))
    case R.QuestionEven{half}:
      2n+twice(meaning(half))

def incrementMeaning(+value: R.Question) -> {meaning(Q.increment(value)) == 1n+meaning(value) : Nat}:
  match value:
    case R.QuestionZero{}:
      {==}
    case R.QuestionOdd{half}:
      {==}
    case R.QuestionEven{+half}:
      %Equal.sym(Nat, meaning(Q.increment(half)), 1n+meaning(half), incrementMeaning(half)) : {1n+twice(_) == 1n+meaning(R.QuestionEven{half}) : Nat}
      {==}

def equalReflexive(+value: R.Question) -> {Q.equal(value, value) == True{} : Bool}:
  match value:
    case R.QuestionZero{}:
      {==}
    case R.QuestionOdd{half}:
      equalReflexive(half)
    case R.QuestionEven{half}:
      equalReflexive(half)

def fromNatMeaning(+value: Nat) -> {meaning(Q.fromNat(value)) == value : Nat}:
  match value:
    case 0n:
      {==}
    case 1n+ +pred:
      Equal.trans(Nat, meaning(Q.increment(Q.fromNat(pred))), 1n+meaning(Q.fromNat(pred)), 1n+pred,
        incrementMeaning(Q.fromNat(pred)),
        Equal.cong(Nat, Nat, v => 1n+v, meaning(Q.fromNat(pred)), pred, fromNatMeaning(pred)))
