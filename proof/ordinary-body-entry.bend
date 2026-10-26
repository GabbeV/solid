# Actual generator next/caught-throw entry for the finite updater body grammar.
# Binding is proved closed; capture/join/store order remains the source's order.
import Base
import ../representation/records.bend as R
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ../runtime/callback.bend as Callback
import ./action-first-frame.bend as First
import ./action-body-entry.bend as Entry
import ./ordinary-body-evaluation.bend as Eval
import ./ordinary-body-return.bend as Body
import ./ordinary-body-binding.bend as Binding

def method(+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,tail: R.Expr) -> First.Method:
  First.Body{Eval.expression(values,id,answer),True{},Eval.expression(values,id,answer),tail}

def prepared(+w: R.World,+actor: Nat,+state: R.ActionState,tail: R.Expr) -> R.World:
  A.store(A.enter(w),actor,R.ActionState.with_methods(state,tail))

def methods(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+actor: Nat,+incoming: R.Value,rejected: Bool,+state: R.ActionState,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+tail: R.Expr) -> {C.actionStepMethods(w,rest,stack,actor,incoming,rejected,state,First.expression(method(values,id,answer,tail))) == Body.start(prepared(w,actor,state,tail),values,id,answer,actor,rest,stack) : C.Machine}:
  match rejected:
    case False{}:
      Equal.cong(R.Expr,C.Machine,expr=>C.Machine{prepared(w,actor,state,tail),C.Evaluate{expr,R.Undefined{}} <> C.ActionStepReturn{actor,stack} <> rest,stack},Callback.bind(Eval.expression(values,id,answer),incoming,R.Boolean{False{}}),Eval.expression(values,id,answer),Binding.closed(values,id,answer,Callback.Pair{incoming,R.Boolean{False{}}}))
    case True{}:
      Equal.cong(R.Expr,C.Machine,expr=>C.Machine{prepared(w,actor,state,tail),C.Evaluate{expr,R.Undefined{}} <> C.ActionStepReturn{actor,stack} <> rest,stack},Callback.bind(Eval.expression(values,id,answer),incoming,R.Boolean{True{}}),Eval.expression(values,id,answer),Binding.closed(values,id,answer,Callback.Pair{incoming,R.Boolean{True{}}}))

def resume(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+actor: Nat,+incoming: R.Value,+rejected: Bool,+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+tail: R.Expr,known: {R.ActionState.methods(A.get(w,actor)) == First.expression(method(values,id,answer,tail)) : R.Expr}) -> {C.actionResume(w,rest,stack,actor,incoming,rejected) == Body.start(Entry.prepared(w,actor,tail),values,id,answer,actor,C.ActionSliceEnd{R.World.question(w)} <> rest,stack) : C.Machine}:
  +next = Entry.joined(w,actor)
  +work = {C.ActionSliceEnd{R.World.question(w)} <> rest : List<&2,C.Task>}
  Equal.trans(C.Machine,C.actionResume(w,rest,stack,actor,incoming,rejected),C.actionStepMethods(next,work,stack,actor,incoming,rejected,A.get(next,actor),First.expression(method(values,id,answer,tail))),Body.start(Entry.prepared(w,actor,tail),values,id,answer,actor,work,stack),Equal.cong(R.Expr,C.Machine,expr=>C.actionStepMethods(next,work,stack,actor,incoming,rejected,A.get(next,actor),expr),R.ActionState.methods(A.get(next,actor)),First.expression(method(values,id,answer,tail)),First.methodTransport(w,next,actor,method(values,id,answer,tail),Entry.actions(w,actor),known)),methods(next,work,stack,actor,incoming,rejected,A.get(next,actor),values,id,answer,tail))
