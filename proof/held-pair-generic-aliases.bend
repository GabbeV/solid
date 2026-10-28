# Generic first-controller boundary: all initial facts are checked fields of
# Ready, whose concrete factory is separately proved. No raw graph expansion.
# Construct both finite alias routes after the actual controller join. The
# source cache retains identity1; the second action retains identity2.
import Base
import ./held-first-ready.bend as Ready
import ./held-controller-data.bend as Data
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ./held-pair-generic-state.bend as State
import ./held-pair-generic-context.bend as Context
import ./held-pair-generic-join.bend as Joined
import ./action-opening.bend as Opening
import ./transaction-pair.bend as Pair
import ./transaction-rejoin-history.bend as Alias
import ./transaction-resolution.bend as Path

def stopped(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+reverse: Bool,+ready: Ready.Ready<seed,id,first>) -> {R.Transaction.into(B.transaction(State.joined(seed,second,reverse),Context.root(reverse))) == 0n : Nat}:
  +w = State.joined(seed,second,reverse)
  +root = Pair.targetId([],[],reverse)
  Equal.trans(Nat,R.Transaction.into(B.transaction(w,Context.root(reverse))),R.Transaction.into(B.transaction(w,root)),0n,Equal.cong(Nat,Nat,n=>R.Transaction.into(B.transaction(w,n)),Context.root(reverse),root,Context.rootPair(reverse)),Joined.stopped(seed,id,first,second,reverse,ready))

def redirected(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+reverse: Bool,+ready: Ready.Ready<seed,id,first>) -> {R.Transaction.into(B.transaction(State.joined(seed,second,reverse),Pair.sourceId([],[],reverse))) == Context.root(reverse) : Nat}:
  +before = State.opened(seed,second)
  +pair = Pair.merged(before,[],Data.group(id),[],Opening.record(1n,True{}),[],reverse)
  +w = State.joined(seed,second,reverse)
  +from = Pair.sourceId([],[],reverse)
  +root = Pair.targetId([],[],reverse)
  Equal.trans(Nat,R.Transaction.into(B.transaction(w,from)),R.Transaction.into(B.transaction(pair,from)),Context.root(reverse),Equal.cong(R.World,Nat,state=>R.Transaction.into(B.transaction(state,from)),w,pair,Equal.sym(R.World,pair,w,Joined.paired(seed,id,first,second,reverse,ready))),Equal.trans(Nat,R.Transaction.into(B.transaction(pair,from)),root,Context.root(reverse),Pair.redirected(before,[],Data.group(id),[],Opening.record(1n,True{}),[],reverse),Equal.sym(Nat,Context.root(reverse),root,Context.rootPair(reverse))))

def first(+seed: R.World,+id: Nat,+left: R.Expr,+right: R.Expr,+reverse: Bool,+ready: Ready.Ready<seed,id,left>) -> Alias.Alias<State.joined(seed,right,reverse),Context.root(reverse)>:
  match reverse:
    case False{}:
      +w = State.joined(seed,right,False{})
      Alias.Alias{Path.Redirect{1n,1n,redirected(seed,id,left,right,False{},ready),Path.Root{2n,stopped(seed,id,left,right,False{},ready)},{==}},2n,Equal.cong(Nat,Nat,n=>1n+n,B.length(R.Transaction,R.World.txArena(w)),3n,Context.length(seed,id,left,right,False{},ready)),{==}}
    case True{}:
      +w = State.joined(seed,right,True{})
      Alias.Alias{Path.Root{1n,stopped(seed,id,left,right,True{},ready)},3n,Equal.cong(Nat,Nat,n=>1n+n,B.length(R.Transaction,R.World.txArena(w)),3n,Context.length(seed,id,left,right,True{},ready)),{==}}

def second(+seed: R.World,+id: Nat,+left: R.Expr,+right: R.Expr,+reverse: Bool,+ready: Ready.Ready<seed,id,left>) -> Alias.Alias<State.joined(seed,right,reverse),Context.root(reverse)>:
  match reverse:
    case False{}:
      +w = State.joined(seed,right,False{})
      Alias.Alias{Path.Root{2n,stopped(seed,id,left,right,False{},ready)},3n,Equal.cong(Nat,Nat,n=>1n+n,B.length(R.Transaction,R.World.txArena(w)),3n,Context.length(seed,id,left,right,False{},ready)),{==}}
    case True{}:
      +w = State.joined(seed,right,True{})
      Alias.Alias{Path.Redirect{2n,0n,redirected(seed,id,left,right,True{},ready),Path.Root{1n,stopped(seed,id,left,right,True{},ready)},{==}},2n,Equal.cong(Nat,Nat,n=>1n+n,B.length(R.Transaction,R.World.txArena(w)),3n,Context.length(seed,id,left,right,True{},ready)),{==}}

def firstIdentity(+seed: R.World,+id: Nat,+left: R.Expr,+right: R.Expr,+reverse: Bool,+ready: Ready.Ready<seed,id,left>) -> {Alias.identity(State.joined(seed,right,reverse),Context.root(reverse),first(seed,id,left,right,reverse,ready)) == 1n : Nat}:
  match reverse:
    case False{}: {==}
    case True{}: {==}

def secondIdentity(+seed: R.World,+id: Nat,+left: R.Expr,+right: R.Expr,+reverse: Bool,+ready: Ready.Ready<seed,id,left>) -> {Alias.identity(State.joined(seed,right,reverse),Context.root(reverse),second(seed,id,left,right,reverse,ready)) == 2n : Nat}:
  match reverse:
    case False{}: {==}
    case True{}: {==}

def selected(+seed: R.World,+id: Nat,+left: R.Expr,+right: R.Expr,+reverse: Bool,+secondActor: Bool,+ready: Ready.Ready<seed,id,left>) -> Alias.Alias<State.joined(seed,right,reverse),Context.root(reverse)>:
  match secondActor:
    case True{}: second(seed,id,left,right,reverse,ready)
    case False{}: first(seed,id,left,right,reverse,ready)

def selectedIdentity(+seed: R.World,+id: Nat,+left: R.Expr,+right: R.Expr,+reverse: Bool,+secondActor: Bool,+ready: Ready.Ready<seed,id,left>) -> {Alias.identity(State.joined(seed,right,reverse),Context.root(reverse),selected(seed,id,left,right,reverse,secondActor,ready)) == 1n+Context.actor(secondActor) : Nat}:
  match secondActor:
    case False{}: firstIdentity(seed,id,left,right,reverse,ready)
    case True{}: secondIdentity(seed,id,left,right,reverse,ready)

def captured(+seed: R.World,+id: Nat,+left: R.Expr,+right: R.Expr,+reverse: Bool,+secondActor: Bool,+ready: Ready.Ready<seed,id,left>) -> {R.ActionState.transaction(A.get(State.joined(seed,right,reverse),Context.actor(secondActor))) == Alias.identity(State.joined(seed,right,reverse),Context.root(reverse),selected(seed,id,left,right,reverse,secondActor,ready)) : Nat}:
  +w = State.joined(seed,right,reverse)
  +alias = selected(seed,id,left,right,reverse,secondActor,ready)
  Equal.trans(Nat,R.ActionState.transaction(A.get(w,Context.actor(secondActor))),1n+Context.actor(secondActor),Alias.identity(w,Context.root(reverse),alias),Context.capture(seed,id,left,right,reverse,secondActor,ready),Equal.sym(Nat,Alias.identity(w,Context.root(reverse),alias),1n+Context.actor(secondActor),selectedIdentity(seed,id,left,right,reverse,secondActor,ready)))

def cached(+seed: R.World,+id: Nat,+left: R.Expr,+right: R.Expr,+reverse: Bool,+ready: Ready.Ready<seed,id,left>) -> {R.NodeExtension.transaction(B.extension(State.joined(seed,right,reverse),id)) == Alias.identity(State.joined(seed,right,reverse),Context.root(reverse),first(seed,id,left,right,reverse,ready)) : Nat}:
  +w = State.joined(seed,right,reverse)
  Equal.trans(Nat,R.NodeExtension.transaction(B.extension(w,id)),1n,Alias.identity(w,Context.root(reverse),first(seed,id,left,right,reverse,ready)),Context.cached(seed,id,left,right,reverse,ready),Equal.sym(Nat,Alias.identity(w,Context.root(reverse),first(seed,id,left,right,reverse,ready)),1n,firstIdentity(seed,id,left,right,reverse,ready)))
