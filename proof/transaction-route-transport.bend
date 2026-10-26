# A redirect certificate depends only on transaction storage. Reuse it after
# an independently proved arena frame instead of assuming a new resolver result.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ./transaction-resolution.bend as Paths

def into(+w: R.World,+next: R.World,+id: Nat,same: {R.World.txArena(next) == R.World.txArena(w) : List<&2,R.Transaction>}) -> {R.Transaction.into(B.transaction(next,id)) == R.Transaction.into(B.transaction(w,id)) : Nat}:
  Equal.cong(List<&2,R.Transaction>,Nat,rows=>R.Transaction.into(B.get(R.Transaction,rows,id,B.blank_transaction())),R.World.txArena(next),R.World.txArena(w),same)

def resolves(+w: R.World,+next: R.World,path: Paths.Route<w>,+extra: Nat,+same: {R.World.txArena(next) == R.World.txArena(w) : List<&2,R.Transaction>}) -> {X.resolveLoop(Nat.add(Paths.depth(w,path),1n+extra),next,Paths.origin(w,path)) == B.Bundle{next,Paths.terminal(w,path)} : B.Bundle<R.World,Nat>}:
  match path:
    case Paths.Root{+id,known}:
      Paths.stopped(next,id,extra,Equal.trans(Nat,R.Transaction.into(B.transaction(next,id)),R.Transaction.into(B.transaction(w,id)),0n,into(w,next,id,same),known))
    case Paths.Redirect{+id,+target,known,+tail,attached}:
      +fuel = Nat.add(Paths.depth(w,tail),1n+extra)
      Equal.trans(B.Bundle<R.World,Nat>,X.resolveLoop(1n+fuel,next,id),X.resolveLoop(fuel,next,1n+target),B.Bundle{next,Paths.terminal(w,tail)},Paths.redirect(next,id,target,fuel,Equal.trans(Nat,R.Transaction.into(B.transaction(next,id)),R.Transaction.into(B.transaction(w,id)),1n+target,into(w,next,id,same),known)),Equal.trans(B.Bundle<R.World,Nat>,X.resolveLoop(fuel,next,1n+target),X.resolveLoop(fuel,next,Paths.origin(w,tail)),B.Bundle{next,Paths.terminal(w,tail)},Equal.cong(Nat,B.Bundle<R.World,Nat>,n=>X.resolveLoop(fuel,next,n),1n+target,Paths.origin(w,tail),Equal.sym(Nat,Paths.origin(w,tail),1n+target,attached)),resolves(w,next,tail,extra,same)))

def public(+w: R.World,+next: R.World,+path: Paths.Route<w>,+extra: Nat,+same: {R.World.txArena(next) == R.World.txArena(w) : List<&2,R.Transaction>},room: {1n+B.length(R.Transaction,R.World.txArena(w)) == Nat.add(Paths.depth(w,path),1n+extra) : Nat}) -> {X.resolveTx(next,Paths.origin(w,path)) == B.Bundle{next,Paths.terminal(w,path)} : B.Bundle<R.World,Nat>}:
  +budget = Equal.trans(Nat,1n+B.length(R.Transaction,R.World.txArena(next)),1n+B.length(R.Transaction,R.World.txArena(w)),Nat.add(Paths.depth(w,path),1n+extra),Equal.cong(List<&2,R.Transaction>,Nat,rows=>1n+B.length(R.Transaction,rows),R.World.txArena(next),R.World.txArena(w),same),room)
  Equal.trans(B.Bundle<R.World,Nat>,X.resolveTx(next,Paths.origin(w,path)),X.resolveLoop(Nat.add(Paths.depth(w,path),1n+extra),next,Paths.origin(w,path)),B.Bundle{next,Paths.terminal(w,path)},Equal.cong(Nat,B.Bundle<R.World,Nat>,fuel=>X.resolveLoop(fuel,next,Paths.origin(w,path)),1n+B.length(R.Transaction,R.World.txArena(next)),Nat.add(Paths.depth(w,path),1n+extra),budget),resolves(w,next,path,extra,same))
