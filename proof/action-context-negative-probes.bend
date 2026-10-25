# Actual helper-only context checks with a returned, allocated actor identity.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ../runtime/flight.bend as F
import ../runtime/question.bend as Q

def initial() -> R.World:
  +actor = A.create(B.empty(),R.ActionEnd{})
  +id = B.second(R.World,Nat,actor)
  +w = A.open(B.first(R.World,Nat,actor),id)
  +w = Q.setQuestion(w,R.ActionState.question(A.get(w,id)))
  +result = F.newThenable(w,False{},R.Unresolved{})
  B.first(R.World,Nat,A.wait(B.first(R.World,Nat,result),id,B.second(R.World,Nat,result),0))

def wait_keeps_nonzero_ambient_question() -> {R.World.question(initial()) == R.QuestionOdd{R.QuestionZero{}} : R.Question}:
  {==}

def fulfilled_capture_keeps_group_debt() -> {R.Transaction.open(B.transaction(F.syncFulfilled(initial(),1n,R.Undefined{}),1n)) == 1n : Nat}:
  {==}

def rejected_capture_keeps_allocated_actor() -> {B.length(R.ActionState,R.World.actions(F.syncRejected(initial(),1n,R.Undefined{}))) == 1n : Nat}:
  {==}
