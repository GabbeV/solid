# Properties of the actual exact question comparator. These are algebraic
# order/coherence facts, separate from native finite numeric-order controls.
import Base
import ../representation/records.bend as R
import ../runtime/question.bend as Q
import ../runtime/lanes-state.bend as L

def inverse(order: Q.Order) -> Q.Order:
  match order:
    case Q.Less{}: Q.More{}
    case Q.Same{}: Q.Same{}
    case Q.More{}: Q.Less{}

def same(order: Q.Order) -> Bool:
  match order:
    case Q.Same{}: True{}
    case _: False{}

def inverseOdd(+order: Q.Order) -> {inverse(Q.oddEven(order)) == Q.evenOdd(inverse(order)) : Q.Order}:
  match order:
    case Q.Less{}: {==}
    case Q.Same{}: {==}
    case Q.More{}: {==}

def inverseEven(+order: Q.Order) -> {inverse(Q.evenOdd(order)) == Q.oddEven(inverse(order)) : Q.Order}:
  match order:
    case Q.Less{}: {==}
    case Q.Same{}: {==}
    case Q.More{}: {==}

def crossOdd(+order: Q.Order) -> {same(Q.oddEven(order)) == False{} : Bool}:
  match order:
    case Q.Less{}: {==}
    case Q.Same{}: {==}
    case Q.More{}: {==}

def crossEven(+order: Q.Order) -> {same(Q.evenOdd(order)) == False{} : Bool}:
  match order:
    case Q.Less{}: {==}
    case Q.Same{}: {==}
    case Q.More{}: {==}

def reflexive(+q: R.Question) -> {Q.compare(q, q) == Q.Same{} : Q.Order}:
  match q:
    case R.QuestionZero{}: {==}
    case R.QuestionOdd{half}: reflexive(half)
    case R.QuestionEven{half}: reflexive(half)

def swapped(+a: R.Question, +b: R.Question) -> {inverse(Q.compare(a, b)) == Q.compare(b, a) : Q.Order}:
  match a b:
    case R.QuestionZero{} R.QuestionZero{}: {==}
    case R.QuestionZero{} R.QuestionOdd{half}: {==}
    case R.QuestionZero{} R.QuestionEven{half}: {==}
    case R.QuestionOdd{half} R.QuestionZero{}: {==}
    case R.QuestionEven{half} R.QuestionZero{}: {==}
    case R.QuestionOdd{a} R.QuestionOdd{b}: swapped(a, b)
    case R.QuestionEven{a} R.QuestionEven{b}: swapped(a, b)
    case R.QuestionOdd{+a} R.QuestionEven{+b}:
      Equal.trans(Q.Order, inverse(Q.oddEven(Q.compare(a, b))), Q.evenOdd(inverse(Q.compare(a, b))), Q.evenOdd(Q.compare(b, a)),
        inverseOdd(Q.compare(a, b)), Equal.cong(Q.Order, Q.Order, x => Q.evenOdd(x), inverse(Q.compare(a, b)), Q.compare(b, a), swapped(a, b)))
    case R.QuestionEven{+a} R.QuestionOdd{+b}:
      Equal.trans(Q.Order, inverse(Q.evenOdd(Q.compare(a, b))), Q.oddEven(inverse(Q.compare(a, b))), Q.oddEven(Q.compare(b, a)),
        inverseEven(Q.compare(a, b)), Equal.cong(Q.Order, Q.Order, x => Q.oddEven(x), inverse(Q.compare(a, b)), Q.compare(b, a), swapped(a, b)))

def equality(+a: R.Question, +b: R.Question) -> {same(Q.compare(a, b)) == Q.equal(a, b) : Bool}:
  match a b:
    case R.QuestionZero{} R.QuestionZero{}: {==}
    case R.QuestionZero{} R.QuestionOdd{half}: {==}
    case R.QuestionZero{} R.QuestionEven{half}: {==}
    case R.QuestionOdd{half} R.QuestionZero{}: {==}
    case R.QuestionEven{half} R.QuestionZero{}: {==}
    case R.QuestionOdd{a} R.QuestionOdd{b}: equality(a, b)
    case R.QuestionEven{a} R.QuestionEven{b}: equality(a, b)
    case R.QuestionOdd{a} R.QuestionEven{b}: crossOdd(Q.compare(a, b))
    case R.QuestionEven{a} R.QuestionOdd{b}: crossEven(Q.compare(a, b))

def irreflexive(+q: R.Question) -> {Q.less(q, q) == False{} : Bool}:
  Equal.cong(Q.Order, Bool, order => Q.isLess(order), Q.compare(q, q), Q.Same{}, reflexive(q))

def unstamped(+w: R.World, +id: Nat) -> {L.stale(w, id, R.QuestionZero{}) == False{} : Bool}:
  {==}
