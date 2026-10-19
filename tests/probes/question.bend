import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/question.bend as Q
import ../../runtime/flight.bend as F
import ../../runtime/construct.bend as N

def zero() -> R.Question:
  R.QuestionZero{}

def odd(half: R.Question) -> R.Question:
  R.QuestionOdd{half}

def even(half: R.Question) -> R.Question:
  R.QuestionEven{half}

def increment(value: R.Question) -> R.Question:
  Q.increment(value)

def equal(left: R.Question, right: R.Question) -> Bool:
  Q.equal(left, right)

def mainline() -> R.Question:
  Q.mainline()

def initial() -> R.World:
  B.empty()

def next(w: R.World) -> B.Bundle<R.World, R.Question>:
  Q.nextQuestion(w)

def set(w: R.World, value: R.Question) -> R.World:
  Q.setQuestion(w, value)

def register(+question: R.Question) -> R.Question:
  +w = N.createOwner(Q.setQuestion(B.empty(), question), 0n, False{})
  +w = N.computed(0n, w, R.Literal{R.Undefined{}}, R.NodeOptions.with_lazy(N.defaults(), True{}), 1n)
  +w = F.startFlight(w, 2n, 1n)
  R.NodeExtension.q(B.extension(w, 2n))

def primeCounter(w: R.World, value: R.Question) -> R.World:
  R.World.with_questions(w, value)
