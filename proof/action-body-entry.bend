# Exact actual resume-to-literal-body bridge. Input method knowledge is
# transported through captured question installation and the real group join.
import Base
import ../representation/records.bend as R
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ../runtime/question.bend as Q
import ../runtime/transaction.bend as X
import ./action-first-frame.bend as First
import ./action-resume-frame.bend as Frame
import ./action-resume-transaction.bend as Transaction
import ./action-body-return.bend as Body

def method(+value: R.Value,tail: R.Expr) -> First.Method:
  First.Body{R.Literal{R.StepResult{True{},value}},True{},R.Literal{R.StepResult{True{},value}},tail}

def asked(+w: R.World,id: Nat) -> R.World:
  Q.setQuestion(w,R.ActionState.question(A.get(w,id)))

def joined(+w: R.World,+id: Nat) -> R.World:
  X.joinFuture(asked(w,id),R.ActionState.transaction(A.get(w,id)))

def prepared(+w: R.World,+id: Nat,tail: R.Expr) -> R.World:
  +next = joined(w,id)
  A.store(A.enter(next),id,R.ActionState.with_methods(A.get(next,id),tail))

def actions(+w: R.World,+id: Nat) -> {R.World.actions(joined(w,id)) == R.World.actions(w) : List<&2,R.ActionState>}:
  Equal.cong(Frame.View,List<&2,R.ActionState>,view=>Frame.actions(view),Frame.observe(joined(w,id)),Frame.observe(w),Frame.compose(w,asked(w,id),joined(w,id),Transaction.joinFuture(asked(w,id),R.ActionState.transaction(A.get(w,id))),Frame.worldQuestion(w,R.ActionState.question(A.get(w,id)))))

def methods(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+incoming: R.Value,rejected: Bool,+state: R.ActionState,+value: R.Value,+tail: R.Expr) -> {C.actionStepMethods(w,rest,stack,id,incoming,rejected,state,First.expression(method(value,tail))) == Body.start(A.store(A.enter(w),id,R.ActionState.with_methods(state,tail)),rest,stack,id,value) : C.Machine}:
  match rejected:
    case True{}: {==}
    case False{}: {==}

def resume(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+incoming: R.Value,+rejected: Bool,+value: R.Value,+tail: R.Expr,known: {R.ActionState.methods(A.get(w,id)) == First.expression(method(value,tail)) : R.Expr}) -> {C.actionResume(w,rest,stack,id,incoming,rejected) == Body.start(prepared(w,id,tail),C.ActionSliceEnd{R.World.question(w)} <> rest,stack,id,value) : C.Machine}:
  +next = joined(w,id)
  +work = {C.ActionSliceEnd{R.World.question(w)} <> rest : List<&2,C.Task>}
  Equal.trans(C.Machine,C.actionResume(w,rest,stack,id,incoming,rejected),C.actionStepMethods(next,work,stack,id,incoming,rejected,A.get(next,id),First.expression(method(value,tail))),Body.start(prepared(w,id,tail),work,stack,id,value),Equal.cong(R.Expr,C.Machine,expr=>C.actionStepMethods(next,work,stack,id,incoming,rejected,A.get(next,id),expr),R.ActionState.methods(A.get(next,id)),First.expression(method(value,tail)),First.methodTransport(w,next,id,method(value,tail),actions(w,id),known)),methods(next,work,stack,id,incoming,rejected,A.get(next,id),value,tail))
