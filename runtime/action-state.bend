# core/action.ts closure cells and scheduler.ts enterAction/exitAction.
# ActionMethod is the admitted user generator protocol, not a second scheduler.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./transaction.bend as X
import ./question.bend as Q
import ./flight.bend as F

def blank() -> R.ActionState:
  R.ActionState{0n, R.QuestionZero{}, R.ActionEnd{}, 0n}

def get(w: R.World, id: Nat) -> R.ActionState:
  B.get(R.ActionState, R.World.actions(w), id, blank())

def store(+w: R.World, id: Nat, state: R.ActionState) -> R.World:
  R.World.with_actions(w, List.set(&2, R.ActionState, R.World.actions(w), id, state))

# Promise executor entry. Allocate its IO identity before invoking genFn.
# No transaction/question is allocated until the factory returns successfully.
def create(+w: R.World, methods: R.Expr) -> B.Bundle<R.World, Nat>:
  +pair = F.newThenable(w, False{}, R.Unresolved{})
  +w = B.first(R.World, Nat, pair)
  +id = B.length(R.ActionState, R.World.actions(w))
  B.Bundle{R.World.with_actions(w, B.append(R.ActionState, R.World.actions(w), [R.ActionState{0n, R.QuestionZero{}, methods, B.second(R.World, Nat, pair)}])), id}

# action(genFn) creates one reusable callable. No transaction, question,
# Promise or reactive node is allocated until that callable is invoked.
def function(+w: R.World, factory: R.Expr, methods: R.Expr, previous: R.Value) -> B.Bundle<R.World, R.Value>:
  +callback = B.length(R.CleanupProgram, R.World.cleanupPrograms(w))
  B.Bundle{R.World.with_cleanupPrograms(w, B.append(R.CleanupProgram, R.World.cleanupPrograms(w), [R.CleanupProgram{[R.ActionFunction{factory, methods, previous}], False{}, 0n}])), R.ProgramReference{callback}}

def open(+w: R.World, +id: Nat) -> R.World:
  +pair = X.newTransaction(w, False{}, 0n)
  +w = B.first(R.World, Nat, pair)
  +t = B.second(R.World, Nat, pair)
  +w = B.store_transaction(w, t, R.Transaction.with_open(B.transaction(w, t), 1n))
  +w = B.store_transaction(w, t, R.Transaction.with_acted(B.transaction(w, t), True{}))
  +pair = Q.nextQuestion(w)
  +w = B.first(R.World, R.Question, pair)
  store(w, id, R.ActionState.with_question(R.ActionState.with_transaction(get(w, id), t), B.second(R.World, R.Question, pair)))

def enter(+w: R.World) -> R.World:
  R.World.with_actionDepth(w, 1n+R.World.actionDepth(w))

def exit(+w: R.World) -> R.World:
  R.World.with_actionDepth(w, Nat.sub(R.World.actionDepth(w), 1n))

# done's prefix. Redirect resolution precedes the decrement and schedule.
def done(+w: R.World, +id: Nat) -> R.World:
  +pair = X.resolveTx(w, R.ActionState.transaction(get(w, id)))
  +w = B.first(R.World, Nat, pair)
  +t = B.second(R.World, Nat, pair)
  B.schedule(B.store_transaction(w, t, R.Transaction.with_open(B.transaction(w, t), Nat.sub(R.Transaction.open(B.transaction(w, t)), 1n))))

def wait(+w: R.World, action: Nat, +result: Nat, kind: U32) -> B.Bundle<R.World, Nat>:
  +pair = F.newObserver(w, 0n, result)
  +w = B.first(R.World, Nat, pair)
  +observer = B.second(R.World, Nat, pair)
  +w = R.World.with_actionWaits(w, B.append(R.ActionWait, R.World.actionWaits(w), [R.ActionWait{observer, action, kind, False{}}]))
  B.Bundle{F.addObserver(w, result, observer), observer}

def find(waits: List<&2, R.ActionWait>, +observer: Nat) -> Maybe<&2, R.ActionWait>:
  match waits:
    case Nil{}:
      None{}
    case +entry <> tail:
      B.choose(~Maybe<&2, R.ActionWait>, Nat.is_eq(R.ActionWait.observer(entry), observer), _ => Some{entry}, _ => find(tail, observer))

def settleWait(waits: List<&2, R.ActionWait>, +observer: Nat) -> List<&2, R.ActionWait>:
  match waits:
    case Nil{}:
      []
    case +entry <> tail:
      B.choose(~R.ActionWait, Nat.is_eq(R.ActionWait.observer(entry), observer), _ => R.ActionWait.with_settled(entry, True{}), _ => entry) <> settleWait(tail, observer)
