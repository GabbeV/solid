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
import ./held-resume-retirement.bend as Resume
import ./held-body-evaluation.bend as Eval
import ./held-write-history.bend as History
import ./action-body-entry.bend as Entry
import ./action-body-retirement.bend as Exit
import ./action-output-frame.bend as Output
import ./pending-stack-history.bend as Steps
import ./transaction-pair.bend as Pair

def left(+methods: R.Expr,+other: R.Expr,second: Bool) -> R.Expr:
  B.choose(~R.Expr,second,_=>other,_=>methods)

def right(+methods: R.Expr,+other: R.Expr,second: Bool) -> R.Expr:
  B.choose(~R.Expr,second,_=>methods,_=>other)

def select(+methods: R.Expr,+other: R.Expr,+second: Bool) -> {B.choose(~R.Expr,second,_=>right(methods,other,second),_=>left(methods,other,second)) == methods : R.Expr}:
  match second:
    case False{}: {==}
    case True{}: {==}

def world(+seed: R.World,+id: Nat,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool) -> R.World:
  +methods = Resume.methods(values,id,answer)
  State.joined(seed,right(methods,other,second),reverse)

def method(+seed: R.World,+id: Nat,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool,+ready: Ready.Ready<seed,id,left(Resume.methods(values,id,answer),other,second)>) -> {R.ActionState.methods(A.get(world(seed,id,values,answer,other,reverse,second),Context.actor(second))) == Resume.methods(values,id,answer) : R.Expr}:
  +methods = Resume.methods(values,id,answer)
  +l = left(methods,other,second)
  +r = right(methods,other,second)
  Equal.trans(R.Expr,R.ActionState.methods(A.get(world(seed,id,values,answer,other,reverse,second),Context.actor(second))),B.choose(~R.Expr,second,_=>r,_=>l),methods,Context.methods(seed,id,l,r,reverse,second,ready),select(methods,other,second))

def complete(+seed: R.World,+id: Nat,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+ready: Ready.Ready<seed,id,left(Resume.methods(values,id,answer),other,second)>) -> {Output.outer(C.world(Steps.iterate(1n+Eval.cost(values),Resume.start(world(seed,id,values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected)))) == Output.outer(Exit.target(History.run(values,Entry.prepared(world(seed,id,values,answer,other,reverse,second),Context.actor(second),R.ActionEnd{}),id),Context.root(reverse),1n)) : R.World}:
  +methods = Resume.methods(values,id,answer)
  +l = left(methods,other,second)
  +r = right(methods,other,second)
  Cache.fresh(State.joined(seed,r,reverse),Context.actor(second),values,id,answer,rest,stack,incoming,rejected,Pair.targetPred([],[],reverse),Context.actor(second),1n,Context.profile(seed,id,l,r,reverse,ready),Aliases.first(seed,id,l,r,reverse,ready),Aliases.cached(seed,id,l,r,reverse,ready),Aliases.selected(seed,id,l,r,reverse,second,ready),Aliases.captured(seed,id,l,r,reverse,second,ready),Aliases.selectedIdentity(seed,id,l,r,reverse,second,ready),Context.empty(seed,id,l,r,reverse,ready),Context.count(seed,id,l,r,reverse,ready),method(seed,id,values,answer,other,reverse,second,ready))

def savedStack(+seed: R.World,+id: Nat,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+ready: Ready.Ready<seed,id,left(Resume.methods(values,id,answer),other,second)>) -> {C.values(Steps.iterate(1n+Eval.cost(values),Resume.start(world(seed,id,values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected))) == stack : List<&2,R.Value>}:
  +methods = Resume.methods(values,id,answer)
  +l = left(methods,other,second)
  +r = right(methods,other,second)
  Cache.freshStack(State.joined(seed,r,reverse),Context.actor(second),values,id,answer,rest,stack,incoming,rejected,Pair.targetPred([],[],reverse),Context.actor(second),1n,Context.profile(seed,id,l,r,reverse,ready),Aliases.first(seed,id,l,r,reverse,ready),Aliases.cached(seed,id,l,r,reverse,ready),Aliases.selected(seed,id,l,r,reverse,second,ready),Aliases.captured(seed,id,l,r,reverse,second,ready),Aliases.selectedIdentity(seed,id,l,r,reverse,second,ready),Context.empty(seed,id,l,r,reverse,ready),Context.count(seed,id,l,r,reverse,ready),method(seed,id,values,answer,other,reverse,second,ready))
