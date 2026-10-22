# Exact binary naturals for source numeric question identities. Bijective bits
# avoid noncanonical leading zeros: Odd(q)=2*q+1, Even(q)=2*q+2, Zero=0.
# MAINLINE_QUESTION 0x7fffffff has 31 Odd bits, not 2^31-1 unary constructors.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B

def isZero(value: R.Question) -> Bool:
  match value:
    case R.QuestionZero{}:
      True{}
    case _:
      False{}

def increment(value: R.Question) -> R.Question:
  match value:
    case R.QuestionZero{}:
      R.QuestionOdd{R.QuestionZero{}}
    case R.QuestionOdd{half}:
      R.QuestionEven{half}
    case R.QuestionEven{half}:
      R.QuestionOdd{increment(half)}

def equal(left: R.Question, right: R.Question) -> Bool:
  match left right:
    case R.QuestionZero{} R.QuestionZero{}:
      True{}
    case R.QuestionOdd{x} R.QuestionOdd{y}:
      equal(x, y)
    case R.QuestionEven{x} R.QuestionEven{y}:
      equal(x, y)
    case _ _:
      False{}

# Small-Nat fixture conversion. Large IDs use their binary constructor ABI.
def fromNat(value: Nat) -> R.Question:
  match value:
    case 0n:
      R.QuestionZero{}
    case 1n+pred:
      increment(fromNat(pred))

def ones(bits: Nat) -> R.Question:
  match bits:
    case 0n:
      R.QuestionZero{}
    case 1n+pred:
      R.QuestionOdd{ones(pred)}

def mainline() -> R.Question:
  ones(31n)

# scheduler.ts:setQuestion / nextQuestion; questions is separate from the
# ambient question. The next number is returned without installing it.
def setQuestion(w: R.World, value: R.Question) -> R.World:
  R.World.with_question(w, value)

def nextQuestion(+w: R.World) -> B.Bundle<R.World, R.Question>:
  +value = increment(R.World.questions(w))
  B.Bundle{R.World.with_questions(w, value), value}

# Source numeric order, without converting an exact question into unary Nat.
# Bijective low bits: Odd(a)<Even(b) iff a<=b; Even(a)<Odd(b) iff a<b.
type Order is Data:
  Less{}
  Same{}
  More{}

def oddEven(order: Order) -> Order:
  match order:
    case Same{}:
      Less{}
    case other:
      other

def evenOdd(order: Order) -> Order:
  match order:
    case Same{}:
      More{}
    case other:
      other

def compare(left: R.Question, right: R.Question) -> Order:
  match left right:
    case R.QuestionZero{} R.QuestionZero{}:
      Same{}
    case R.QuestionZero{} _:
      Less{}
    case _ R.QuestionZero{}:
      More{}
    case R.QuestionOdd{a} R.QuestionOdd{b}:
      compare(a, b)
    case R.QuestionEven{a} R.QuestionEven{b}:
      compare(a, b)
    case R.QuestionOdd{a} R.QuestionEven{b}:
      oddEven(compare(a, b))
    case R.QuestionEven{a} R.QuestionOdd{b}:
      evenOdd(compare(a, b))

def isLess(order: Order) -> Bool:
  match order:
    case Less{}:
      True{}
    case _:
      False{}

def less(left: R.Question, right: R.Question) -> Bool:
  isLess(compare(left, right))
