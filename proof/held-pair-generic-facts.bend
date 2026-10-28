# Generic first-controller boundary: all initial facts are checked fields of
# Ready, whose concrete factory is separately proved. No raw graph expansion.
# Controller constructor facts. The source group and both captures come from
# real create/open/hold operations, not supplied cells or post-join profiles.
import Base
import ./held-first-ready.bend as Ready
import ./held-controller-data.bend as Data
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ./held-pair-generic-state.bend as State
import ./action-constructor-static.bend as Constructor
import ./held-source-static.bend as V
import ./held-static-operations.bend as Frame
import ./action-opening.bend as Opening
import ./controller-second-normal.bend as Normal

def normal(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+ready: Ready.Ready<seed,id,first>) -> {State.opened(seed,second) == Normal.normalized(seed,id,first,second) : R.World}:
  +w = seed
  +shape = Normal.shape(w,id,first)
  +known = Normal.shapeIdentity(w,id,first,Ready.arena(seed,id,first,ready),Ready.actions(seed,id,first,ready))
  Equal.trans(R.World,State.opened(seed,second),Normal.run(shape,second),Normal.normalized(w,id,first,second),Equal.cong(R.World,R.World,state=>Normal.run(state,second),w,shape,Equal.sym(R.World,shape,w,known)),Normal.exact(w,id,first,second))

def actor(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+ready: Ready.Ready<seed,id,first>) -> {State.actor(seed,second) == 1n : Nat}:
  +w = seed
  Equal.trans(Nat,State.actor(seed,second),B.length(R.ActionState,R.World.actions(w)),1n,Equal.cong(B.Bundle<R.World,Nat>,Nat,pair=>B.second(R.World,Nat,pair),A.create(w,second),B.Bundle{Normal.created(w,second),B.length(R.ActionState,R.World.actions(w))},Normal.create(w,second)),Equal.cong(List<&2,R.ActionState>,Nat,rows=>B.length(R.ActionState,rows),R.World.actions(w),[Data.first(first)],Ready.actions(seed,id,first,ready)))

def arena(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+ready: Ready.Ready<seed,id,first>) -> {R.World.txArena(State.opened(seed,second)) == [B.blank_transaction(),Data.group(id),Opening.record(1n,True{})] : List<&2,R.Transaction>}:
  +before = seed
  +created = B.first(R.World,Nat,State.created(seed,second))
  +same = Equal.trans(List<&2,R.Transaction>,R.World.txArena(created),R.World.txArena(before),[B.blank_transaction(),Data.group(id)],Constructor.createdArena(before,second),Ready.arena(seed,id,first,ready))
  Equal.trans(List<&2,R.Transaction>,R.World.txArena(State.opened(seed,second)),B.append(R.Transaction,R.World.txArena(created),[Opening.record(1n,True{})]),[B.blank_transaction(),Data.group(id),Opening.record(1n,True{})],Constructor.openedArena(created,State.actor(seed,second)),Equal.cong(List<&2,R.Transaction>,List<&2,R.Transaction>,rows=>B.append(R.Transaction,rows,[Opening.record(1n,True{})]),R.World.txArena(created),[B.blank_transaction(),Data.group(id)],same))

def static(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+ready: Ready.Ready<seed,id,first>) -> {V.observe(State.opened(seed,second)) == V.observe(seed) : V.View}:
  +before = seed
  +created = B.first(R.World,Nat,State.created(seed,second))
  Frame.compose(before,created,State.opened(seed,second),Constructor.opened(created,State.actor(seed,second)),Constructor.created(before,second))

def captureFirst(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+ready: Ready.Ready<seed,id,first>) -> {R.ActionState.transaction(A.get(State.opened(seed,second),0n)) == 1n : Nat}:
  +w = seed
  +next = Normal.normalized(w,id,first,second)
  Equal.trans(Nat,R.ActionState.transaction(A.get(State.opened(seed,second),0n)),R.ActionState.transaction(A.get(next,0n)),1n,Equal.cong(R.World,Nat,state=>R.ActionState.transaction(A.get(state,0n)),State.opened(seed,second),next,normal(seed,id,first,second,ready)),Normal.captureFirst(w,id,first,second))

def captureSecond(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+ready: Ready.Ready<seed,id,first>) -> {R.ActionState.transaction(A.get(State.opened(seed,second),1n)) == 2n : Nat}:
  +w = seed
  +next = Normal.normalized(w,id,first,second)
  Equal.trans(Nat,R.ActionState.transaction(A.get(State.opened(seed,second),1n)),R.ActionState.transaction(A.get(next,1n)),2n,Equal.cong(R.World,Nat,state=>R.ActionState.transaction(A.get(state,1n)),State.opened(seed,second),next,normal(seed,id,first,second,ready)),Normal.captureSecond(w,id,first,second))

def methodFirst(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+ready: Ready.Ready<seed,id,first>) -> {R.ActionState.methods(A.get(State.opened(seed,second),0n)) == first : R.Expr}:
  +w = seed
  +next = Normal.normalized(w,id,first,second)
  Equal.trans(R.Expr,R.ActionState.methods(A.get(State.opened(seed,second),0n)),R.ActionState.methods(A.get(next,0n)),first,Equal.cong(R.World,R.Expr,state=>R.ActionState.methods(A.get(state,0n)),State.opened(seed,second),next,normal(seed,id,first,second,ready)),Normal.methodFirst(w,id,first,second))

def methodSecond(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+ready: Ready.Ready<seed,id,first>) -> {R.ActionState.methods(A.get(State.opened(seed,second),1n)) == second : R.Expr}:
  +w = seed
  +next = Normal.normalized(w,id,first,second)
  Equal.trans(R.Expr,R.ActionState.methods(A.get(State.opened(seed,second),1n)),R.ActionState.methods(A.get(next,1n)),second,Equal.cong(R.World,R.Expr,state=>R.ActionState.methods(A.get(state,1n)),State.opened(seed,second),next,normal(seed,id,first,second,ready)),Normal.methodSecond(w,id,first,second))

def cached(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+ready: Ready.Ready<seed,id,first>) -> {R.NodeExtension.transaction(B.extension(State.opened(seed,second),id)) == 1n : Nat}:
  +w = seed
  +created = B.first(R.World,Nat,State.created(seed,second))
  +same = Equal.trans(R.NodeExtension,B.extension(State.opened(seed,second),id),B.extension(created,id),B.extension(w,id),Constructor.openedExtension(created,State.actor(seed,second),id),Constructor.createdExtension(w,second,id))
  Equal.trans(Nat,R.NodeExtension.transaction(B.extension(State.opened(seed,second),id)),R.NodeExtension.transaction(B.extension(w,id)),1n,Equal.cong(R.NodeExtension,Nat,record=>R.NodeExtension.transaction(record),B.extension(State.opened(seed,second),id),B.extension(w,id),same),Ready.cached(seed,id,first,ready))

def empty(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+ready: Ready.Ready<seed,id,first>) -> {R.World.flushTransaction(State.opened(seed,second)) == 0n : Nat}:
  +w = seed
  +created = B.first(R.World,Nat,State.created(seed,second))
  Equal.trans(Nat,R.World.flushTransaction(State.opened(seed,second)),R.World.flushTransaction(created),0n,Constructor.openedFuture(created,State.actor(seed,second)),Equal.trans(Nat,R.World.flushTransaction(created),R.World.flushTransaction(w),0n,Constructor.createdFuture(w,second),Ready.empty(seed,id,first,ready)))
