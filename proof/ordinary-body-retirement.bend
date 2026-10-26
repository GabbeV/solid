# A live captured obligation is retired after any finite admitted ordinary
# body, using the original route/count facts. Writes preserve actual actor and
# group storage; no new resolver answer or post-body count is assumed.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ../runtime/transaction.bend as X
import ./ordinary-body-evaluation.bend as Eval
import ./ordinary-body-return.bend as Body
import ./ordinary-write-history.bend as History
import ./ordinary-write-profile.bend as P
import ./ordinary-write-outer.bend as Frame
import ./action-body-retirement.bend as Exit
import ./action-output-frame.bend as Output
import ./action-resolution.bend as Done
import ./transaction-resolution.bend as Routes
import ./transaction-route-transport.bend as Transport
import ./pending-stack-history.bend as Steps

def arena(+values: List<&2,R.Value>,+w: R.World,+id: Nat,+profile: P.Profile<w,id>) -> {R.World.txArena(A.exit(History.run(values,w,id))) == R.World.txArena(w) : List<&2,R.Transaction>}:
  Equal.trans(List<&2,R.Transaction>,R.World.txArena(A.exit(History.run(values,w,id))),R.World.txArena(History.run(values,w,id)),R.World.txArena(w),Exit.exitArena(History.run(values,w,id)),Frame.sameTxArena(w,History.run(values,w,id),History.outer(values,w,id,profile)))

def capture(+values: List<&2,R.Value>,+w: R.World,+id: Nat,+actor: Nat,profile: P.Profile<w,id>) -> {R.ActionState.transaction(A.get(A.exit(History.run(values,w,id)),actor)) == R.ActionState.transaction(A.get(w,actor)) : Nat}:
  +next = History.run(values,w,id)
  Equal.trans(Nat,R.ActionState.transaction(A.get(A.exit(next),actor)),R.ActionState.transaction(A.get(next,actor)),R.ActionState.transaction(A.get(w,actor)),Exit.exitCapture(next,actor),Equal.cong(List<&2,R.ActionState>,Nat,rows=>R.ActionState.transaction(B.get(R.ActionState,rows,actor,A.blank())),R.World.actions(next),R.World.actions(w),Frame.sameActions(w,next,History.outer(values,w,id,profile))))

def complete(+values: List<&2,R.Value>,+w: R.World,+id: Nat,+answer: R.Value,+actor: Nat,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+profile: P.Profile<w,id>,+route: Routes.Route<w>,+extra: Nat,+remaining: Nat,captured: {R.ActionState.transaction(A.get(w,actor)) == Routes.origin(w,route) : Nat},room: {1n+B.length(R.Transaction,R.World.txArena(w)) == Nat.add(Routes.depth(w,route),1n+extra) : Nat},open: {R.Transaction.open(B.transaction(w,Routes.terminal(w,route))) == 1n+remaining : Nat}) -> {Output.outer(C.world(Steps.iterate(1n+Eval.cost(values),Body.start(w,values,id,answer,actor,rest,stack)))) == Output.outer(Exit.target(History.run(values,w,id),Routes.terminal(w,route),remaining)) : R.World}:
  +next = A.exit(History.run(values,w,id))
  +sameArena = arena(values,w,id,profile)
  +capturedNext = Equal.trans(Nat,R.ActionState.transaction(A.get(next,actor)),R.ActionState.transaction(A.get(w,actor)),Routes.origin(w,route),capture(values,w,id,actor,profile),captured)
  +resolution = Equal.trans(B.Bundle<R.World,Nat>,X.resolveTx(next,R.ActionState.transaction(A.get(next,actor))),X.resolveTx(next,Routes.origin(w,route)),B.Bundle{next,Routes.terminal(w,route)},Equal.cong(Nat,B.Bundle<R.World,Nat>,n=>X.resolveTx(next,n),R.ActionState.transaction(A.get(next,actor)),Routes.origin(w,route),capturedNext),Transport.public(w,next,route,extra,sameArena,room))
  +nextOpen = Equal.trans(Nat,R.Transaction.open(B.transaction(next,Routes.terminal(w,route))),R.Transaction.open(B.transaction(w,Routes.terminal(w,route))),1n+remaining,Equal.cong(List<&2,R.Transaction>,Nat,rows=>R.Transaction.open(B.get(R.Transaction,rows,Routes.terminal(w,route),B.blank_transaction())),R.World.txArena(next),R.World.txArena(w),sameArena),open)
  Equal.trans(R.World,Output.outer(C.world(Steps.iterate(1n+Eval.cost(values),Body.start(w,values,id,answer,actor,rest,stack)))),Output.outer(A.done(next,actor)),Output.outer(Exit.target(History.run(values,w,id),Routes.terminal(w,route),remaining)),Body.outer(values,w,id,answer,actor,rest,stack,profile),Equal.cong(R.World,R.World,state=>Output.outer(state),A.done(next,actor),Exit.target(History.run(values,w,id),Routes.terminal(w,route),remaining),Done.decreases(next,actor,Routes.terminal(w,route),remaining,resolution,nextOpen)))
