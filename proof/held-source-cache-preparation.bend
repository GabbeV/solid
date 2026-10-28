# Initial virtual canonical-cache certificate survives real captured-alias
# question/join/method preparation. Actual cache is not rewritten here.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ./held-source-cache-rebase.bend as Cache
import ./held-source-cache-view.bend as View
import ./held-source-view.bend as V
import ./held-source-transfer.bend as Transfer
import ./held-write-profile.bend as P
import ./held-alias-preparation.bend as Prepare
import ./held-preparation-source.bend as Source
import ./held-preparation-profile.bend as Selected
import ./action-body-entry.bend as Entry
import ./transaction-rejoin-history.bend as Alias

def terminal(+w: R.World,+id: Nat,+root: Nat) -> {R.Transaction.into(B.transaction(Cache.canonical(w,id,root),root)) == R.Transaction.into(B.transaction(w,root)) : Nat}:
  Equal.cong(List<&2,R.Transaction>,Nat,rows=>R.Transaction.into(B.get(R.Transaction,rows,root,B.blank_transaction())),R.World.txArena(Cache.canonical(w,id,root)),R.World.txArena(w),Cache.arena(w,id,root))

def future(+w: R.World,+id: Nat,+offset: Nat,+profile: P.Profile<Cache.canonical(w,id,1n+offset),id,offset>) -> {R.World.flushTransaction(w) == 1n+offset : Nat}:
  +next = Cache.canonical(w,id,1n+offset)
  Equal.trans(Nat,R.World.flushTransaction(w),R.World.flushTransaction(next),1n+offset,Equal.sym(Nat,R.World.flushTransaction(next),R.World.flushTransaction(w),Cache.future(w,id,1n+offset)),P.future(next,id,offset,profile))

def stopped(+w: R.World,+id: Nat,+offset: Nat,+profile: P.Profile<Cache.canonical(w,id,1n+offset),id,offset>) -> {R.Transaction.into(B.transaction(w,1n+offset)) == 0n : Nat}:
  +next = Cache.canonical(w,id,1n+offset)
  Equal.trans(Nat,R.Transaction.into(B.transaction(w,1n+offset)),R.Transaction.into(B.transaction(next,1n+offset)),0n,Equal.sym(Nat,R.Transaction.into(B.transaction(next,1n+offset)),R.Transaction.into(B.transaction(w,1n+offset)),terminal(w,id,1n+offset)),P.terminal(next,id,offset,profile))

def current(+w: R.World,+id: Nat,+actor: Nat,+offset: Nat,+captureOffset: Nat,+tail: R.Expr,+initial: P.Profile<Cache.canonical(w,id,1n+offset),id,offset>,+alias: Alias.Alias<w,1n+offset>,captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat}) -> P.Profile<Cache.canonical(Entry.prepared(w,actor,tail),id,1n+offset),id,offset>:
  +next = Entry.prepared(w,actor,tail)
  Transfer.transfer(Cache.canonical(w,id,1n+offset),Cache.canonical(next,id,1n+offset),id,offset,initial,View.same(w,next,id,1n+offset,Prepare.current(w,actor,offset,captureOffset,tail,alias,captured,positive,future(w,id,offset,initial),stopped(w,id,offset,initial))))

def fresh(+w: R.World,+id: Nat,+actor: Nat,+offset: Nat,+captureOffset: Nat,+tail: R.Expr,+initial: P.Profile<Source.flush(Cache.canonical(w,id,1n+offset),1n+offset),id,offset>,+alias: Alias.Alias<w,1n+offset>,captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},empty: {R.World.flushTransaction(w) == 0n : Nat}) -> P.Profile<Cache.canonical(Entry.prepared(w,actor,tail),id,1n+offset),id,offset>:
  +root = {1n+offset : Nat}
  +selected = Source.flush(w,root)
  +virtual = Source.flush(Cache.canonical(w,id,root),root)
  +next = Entry.prepared(w,actor,tail)
  +source = View.same(selected,next,id,root,Prepare.fresh(w,actor,offset,captureOffset,tail,alias,captured,positive,empty))
  +equal = Equal.trans(V.View,V.observe(Cache.canonical(next,id,root)),V.observe(Cache.canonical(selected,id,root)),V.observe(virtual),source,Equal.cong(R.World,V.View,state=>V.observe(state),Cache.canonical(selected,id,root),virtual,View.flush(w,id,root,root)))
  Transfer.transfer(virtual,Cache.canonical(next,id,root),id,offset,initial,equal)
