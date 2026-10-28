# Either real joined controller runs a finite setter body and retires exactly
# its captured obligation, with the other obligation retained in the target.
# Raw graph/controllers/hold/join supply every input profile/capture/count fact.
# This starts at captured resume; host parking/delivery and Round remain separate.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ./held-first-ready.bend as Ready
import ./held-pair-generic-state.bend as State
import ./held-pair-generic-context.bend as Context
import ./held-pair-generic-aliases.bend as Aliases
import ./held-source-cache-resume.bend as Cache
import ./held-source-cache-debt.bend as DebtBody
import ./held-pair-generic-body.bend as Generic
import ./held-next-controller-body.bend as Next
import ./held-controller-ready.bend as Controller
import ./held-alias-preparation.bend as Prepare
import ./held-resume-retirement.bend as Resume
import ./held-body-evaluation.bend as Eval
import ./held-write-history.bend as History
import ./action-body-entry.bend as Entry
import ./action-body-retirement.bend as Exit
import ./action-output-frame.bend as Output
import ./pending-stack-history.bend as Steps
import ./transaction-pair.bend as Pair

def different(+second: Bool) -> {Nat.is_eq(Context.actor(Bool.not(second)),Context.actor(second)) == False{} : Bool}:
  match second:
    case False{}: {==}
    case True{}: {==}

def otherSelect(+methods: R.Expr,+other: R.Expr,+second: Bool) -> {B.choose(~R.Expr,Bool.not(second),_=>Generic.right(methods,other,second),_=>Generic.left(methods,other,second)) == other : R.Expr}:
  match second:
    case False{}: {==}
    case True{}: {==}

def initialController(+seed: R.World,+id: Nat,+values: List<&2,R.Value>,+answer: R.Value,+nextValues: List<&2,R.Value>,+nextAnswer: R.Value,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+ready: Ready.Ready<seed,id,Generic.left(Resume.methods(values,id,answer),Resume.methods(nextValues,id,nextAnswer),second)>) -> Controller.Ready<Generic.world(seed,id,values,answer,Resume.methods(nextValues,id,nextAnswer),reverse,second),Context.actor(Bool.not(second)),Context.root(reverse),Context.actor(Bool.not(second)),Resume.methods(nextValues,id,nextAnswer)>:
  +methods = Resume.methods(values,id,answer)
  +other = Resume.methods(nextValues,id,nextAnswer)
  +l = Generic.left(methods,other,second)
  +r = Generic.right(methods,other,second)
  Controller.Captured{Aliases.selected(seed,id,l,r,reverse,Bool.not(second),ready),Aliases.captured(seed,id,l,r,reverse,Bool.not(second),ready),Aliases.selectedIdentity(seed,id,l,r,reverse,Bool.not(second),ready),Equal.trans(R.Expr,R.ActionState.methods(A.get(Generic.world(seed,id,values,answer,Resume.methods(nextValues,id,nextAnswer),reverse,second),Context.actor(Bool.not(second)))),B.choose(~R.Expr,Bool.not(second),_=>r,_=>l),other,Context.methods(seed,id,l,r,reverse,Bool.not(second),ready),otherSelect(methods,other,second))}

def preparedController(+seed: R.World,+id: Nat,+values: List<&2,R.Value>,+answer: R.Value,+nextValues: List<&2,R.Value>,+nextAnswer: R.Value,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+ready: Ready.Ready<seed,id,Generic.left(Resume.methods(values,id,answer),Resume.methods(nextValues,id,nextAnswer),second)>) -> Controller.Ready<Entry.prepared(Generic.world(seed,id,values,answer,Resume.methods(nextValues,id,nextAnswer),reverse,second),Context.actor(second),R.ActionEnd{}),Context.actor(Bool.not(second)),Context.root(reverse),Context.actor(Bool.not(second)),Resume.methods(nextValues,id,nextAnswer)>:
  +methods = Resume.methods(values,id,answer)
  +other = Resume.methods(nextValues,id,nextAnswer)
  +l = Generic.left(methods,other,second)
  +r = Generic.right(methods,other,second)
  Controller.prepared(Generic.world(seed,id,values,answer,Resume.methods(nextValues,id,nextAnswer),reverse,second),Context.actor(second),Context.actor(Bool.not(second)),Context.root(reverse),Context.actor(Bool.not(second)),R.ActionEnd{},other,initialController(seed,id,values,answer,nextValues,nextAnswer,reverse,second,rest,stack,incoming,rejected,ready),Prepare.freshArena(Generic.world(seed,id,values,answer,Resume.methods(nextValues,id,nextAnswer),reverse,second),Context.actor(second),Pair.targetPred([],[],reverse),Context.actor(second),R.ActionEnd{},Aliases.selected(seed,id,l,r,reverse,second,ready),Aliases.captured(seed,id,l,r,reverse,second,ready),Aliases.selectedIdentity(seed,id,l,r,reverse,second,ready),Context.empty(seed,id,l,r,reverse,ready)),different(second))

def complete(+seed: R.World,+id: Nat,+values: List<&2,R.Value>,+answer: R.Value,+nextValues: List<&2,R.Value>,+nextAnswer: R.Value,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+ready: Ready.Ready<seed,id,Generic.left(Resume.methods(values,id,answer),Resume.methods(nextValues,id,nextAnswer),second)>) -> Next.Ready<Resume.start(Generic.world(seed,id,values,answer,Resume.methods(nextValues,id,nextAnswer),reverse,second),Context.actor(second),rest,stack,incoming,rejected),1n+Eval.cost(values),id,Pair.targetPred([],[],reverse),Context.actor(Bool.not(second)),Context.actor(Bool.not(second)),Resume.methods(nextValues,id,nextAnswer)>:
  +methods = Resume.methods(values,id,answer)
  +other = Resume.methods(nextValues,id,nextAnswer)
  +l = Generic.left(methods,other,second)
  +r = Generic.right(methods,other,second)
  Next.fromBody(Resume.start(Generic.world(seed,id,values,answer,Resume.methods(nextValues,id,nextAnswer),reverse,second),Context.actor(second),rest,stack,incoming,rejected),1n+Eval.cost(values),Entry.prepared(Generic.world(seed,id,values,answer,Resume.methods(nextValues,id,nextAnswer),reverse,second),Context.actor(second),R.ActionEnd{}),values,id,Pair.targetPred([],[],reverse),Context.actor(Bool.not(second)),Context.actor(Bool.not(second)),other,DebtBody.freshPrepared(Generic.world(seed,id,values,answer,Resume.methods(nextValues,id,nextAnswer),reverse,second),Context.actor(second),values,id,answer,rest,stack,incoming,rejected,Pair.targetPred([],[],reverse),Context.actor(second),1n,Context.profile(seed,id,l,r,reverse,ready),Aliases.first(seed,id,l,r,reverse,ready),Aliases.cached(seed,id,l,r,reverse,ready),Aliases.selected(seed,id,l,r,reverse,second,ready),Aliases.captured(seed,id,l,r,reverse,second,ready),Aliases.selectedIdentity(seed,id,l,r,reverse,second,ready),Context.empty(seed,id,l,r,reverse,ready),Context.count(seed,id,l,r,reverse,ready),Generic.method(seed,id,values,answer,other,reverse,second,ready)),preparedController(seed,id,values,answer,nextValues,nextAnswer,reverse,second,rest,stack,incoming,rejected,ready),Generic.complete(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready))
