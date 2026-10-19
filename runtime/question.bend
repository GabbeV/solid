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
