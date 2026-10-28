# Derive body profile/capture from initial source and captured alias facts.
# Source views carry source topology; arena/capture facts remain separate.
import Base
import ../representation/records.bend as R
import ../runtime/action-state.bend as A
import ./action-body-entry.bend as Entry
import ./held-write-profile.bend as P
import ./held-source-transfer.bend as Transfer
import ./held-alias-preparation.bend as Prepare
import ./held-preparation-source.bend as Source
import ./held-preparation-control.bend as Control
import ./transaction-rejoin-history.bend as Alias

def current(+w: R.World,+id: Nat,+actor: Nat,+offset: Nat,+captureOffset: Nat,+tail: R.Expr,+initial: P.Profile<w,id,offset>,+alias: Alias.Alias<w,1n+offset>,captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat}) -> P.Profile<Entry.prepared(w,actor,tail),id,offset>:
  Transfer.transfer(w,Entry.prepared(w,actor,tail),id,offset,initial,Prepare.current(w,actor,offset,captureOffset,tail,alias,captured,positive,P.future(w,id,offset,initial),P.terminal(w,id,offset,initial)))

def fresh(+w: R.World,+id: Nat,+actor: Nat,+offset: Nat,+captureOffset: Nat,+tail: R.Expr,+initial: P.Profile<Source.flush(w,1n+offset),id,offset>,+alias: Alias.Alias<w,1n+offset>,captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},empty: {R.World.flushTransaction(w) == 0n : Nat}) -> P.Profile<Entry.prepared(w,actor,tail),id,offset>:
  Transfer.transfer(Source.flush(w,1n+offset),Entry.prepared(w,actor,tail),id,offset,initial,Prepare.fresh(w,actor,offset,captureOffset,tail,alias,captured,positive,empty))

def capture(+w: R.World,+actor: Nat,+offset: Nat,+captureOffset: Nat,+tail: R.Expr,+alias: Alias.Alias<w,1n+offset>,captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},+positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat}) -> {R.ActionState.transaction(A.get(Entry.prepared(w,actor,tail),actor)) == Alias.identity(w,1n+offset,alias) : Nat}:
  +initial = Equal.trans(Nat,R.ActionState.transaction(A.get(w,actor)),Alias.identity(w,1n+offset,alias),1n+captureOffset,captured,positive)
  Equal.trans(Nat,R.ActionState.transaction(A.get(Entry.prepared(w,actor,tail),actor)),1n+captureOffset,Alias.identity(w,1n+offset,alias),Control.capture(w,actor,captureOffset,tail,initial),Equal.sym(Nat,Alias.identity(w,1n+offset,alias),1n+captureOffset,positive))
