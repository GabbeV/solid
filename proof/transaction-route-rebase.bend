# Construct a route in the next World from retained redirect pointers. Counts,
# action records and other group fields may change; the actual pointer vector
# preserves both path shape and arena room. No resolver result is assumed.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./transaction-resolution.bend as Path
import ./transaction-rejoin-history.bend as Alias
import ./held-source-view.bend as View

def parents(+w: R.World) -> List<&2,Nat>:
  View.intos(R.World.txArena(w))

type Rebased<-w: R.World,-next: R.World,-original: Path.Route<w>> is Data:
  RebasedAt{value: Path.Route<next>,origin: {Path.origin(next,value) == Path.origin(w,original) : Nat},terminal: {Path.terminal(next,value) == Path.terminal(w,original) : Nat},depth: {Path.depth(next,value) == Path.depth(w,original) : Nat}}

def into(+w: R.World,+next: R.World,+id: Nat,same: {parents(next) == parents(w) : List<&2,Nat>}) -> {R.Transaction.into(B.transaction(next,id)) == R.Transaction.into(B.transaction(w,id)) : Nat}:
  Equal.trans(Nat,R.Transaction.into(B.transaction(next,id)),B.get(Nat,parents(next),id,0n),R.Transaction.into(B.transaction(w,id)),Equal.sym(Nat,B.get(Nat,parents(next),id,0n),R.Transaction.into(B.transaction(next,id)),View.intoRead(R.World.txArena(next),id)),Equal.trans(Nat,B.get(Nat,parents(next),id,0n),B.get(Nat,parents(w),id,0n),R.Transaction.into(B.transaction(w,id)),Equal.cong(List<&2,Nat>,Nat,rows=>B.get(Nat,rows,id,0n),parents(next),parents(w),same),View.intoRead(R.World.txArena(w),id)))

def redirect(+w: R.World,+next: R.World,+id: Nat,+target: Nat,+tail: Path.Route<w>,linked: {R.Transaction.into(B.transaction(w,id)) == 1n+target : Nat},+attached: {Path.origin(w,tail) == 1n+target : Nat},same: {parents(next) == parents(w) : List<&2,Nat>},moved: Rebased<w,next,tail>) -> Rebased<w,next,Path.Redirect{id,target,linked,tail,attached}>:
  match moved:
    case RebasedAt{+value,origin,terminal,depth}:
      +nextLinked = Equal.trans(Nat,R.Transaction.into(B.transaction(next,id)),R.Transaction.into(B.transaction(w,id)),1n+target,into(w,next,id,same),linked)
      +nextAttached = Equal.trans(Nat,Path.origin(next,value),Path.origin(w,tail),1n+target,origin,attached)
      RebasedAt{Path.Redirect{id,target,nextLinked,value,nextAttached},{==},terminal,Equal.cong(Nat,Nat,n=>1n+n,Path.depth(next,value),Path.depth(w,tail),depth)}

def move(+w: R.World,+next: R.World,path: Path.Route<w>,+same: {parents(next) == parents(w) : List<&2,Nat>}) -> Rebased<w,next,path>:
  match path:
    case Path.Root{+id,stopped}:
      RebasedAt{Path.Root{id,Equal.trans(Nat,R.Transaction.into(B.transaction(next,id)),R.Transaction.into(B.transaction(w,id)),0n,into(w,next,id,same),stopped)},{==},{==},{==}}
    case Path.Redirect{+id,+target,+linked,+tail,+attached}:
      redirect(w,next,id,target,tail,linked,attached,same,move(w,next,tail,same))

def arenaSize(+w: R.World,+next: R.World,same: {parents(next) == parents(w) : List<&2,Nat>}) -> {B.length(R.Transaction,R.World.txArena(next)) == B.length(R.Transaction,R.World.txArena(w)) : Nat}:
  Equal.trans(Nat,B.length(R.Transaction,R.World.txArena(next)),B.length(Nat,parents(next)),B.length(R.Transaction,R.World.txArena(w)),Equal.sym(Nat,B.length(Nat,parents(next)),B.length(R.Transaction,R.World.txArena(next)),View.intoLength(R.World.txArena(next))),Equal.trans(Nat,B.length(Nat,parents(next)),B.length(Nat,parents(w)),B.length(R.Transaction,R.World.txArena(w)),Equal.cong(List<&2,Nat>,Nat,rows=>B.length(Nat,rows),parents(next),parents(w),same),View.intoLength(R.World.txArena(w))))

def fullArena(+w: R.World,+next: R.World,same: {R.World.txArena(next) == R.World.txArena(w) : List<&2,R.Transaction>}) -> {parents(next) == parents(w) : List<&2,Nat>}:
  Equal.cong(List<&2,R.Transaction>,List<&2,Nat>,rows=>View.intos(rows),R.World.txArena(next),R.World.txArena(w),same)

type AliasRebased<-w: R.World,-next: R.World,-root: Nat,-original: Alias.Alias<w,root>> is Data:
  AliasAt{value: Alias.Alias<next,root>,identity: {Alias.identity(next,root,value) == Alias.identity(w,root,original) : Nat}}

def aliasAt(+w: R.World,+next: R.World,+root: Nat,+path: Path.Route<w>,+extra: Nat,+room: {1n+B.length(R.Transaction,R.World.txArena(w)) == Nat.add(Path.depth(w,path),1n+extra) : Nat},+atRoot: {Path.terminal(w,path) == root : Nat},same: {parents(next) == parents(w) : List<&2,Nat>},moved: Rebased<w,next,path>) -> AliasRebased<w,next,root,Alias.Alias{path,extra,room,atRoot}>:
  match moved:
    case RebasedAt{+value,origin,terminal,+depth}:
      +nextRoom = Equal.trans(Nat,1n+B.length(R.Transaction,R.World.txArena(next)),1n+B.length(R.Transaction,R.World.txArena(w)),Nat.add(Path.depth(next,value),1n+extra),Equal.cong(Nat,Nat,n=>1n+n,B.length(R.Transaction,R.World.txArena(next)),B.length(R.Transaction,R.World.txArena(w)),arenaSize(w,next,same)),Equal.trans(Nat,1n+B.length(R.Transaction,R.World.txArena(w)),Nat.add(Path.depth(w,path),1n+extra),Nat.add(Path.depth(next,value),1n+extra),room,Equal.cong(Nat,Nat,n=>Nat.add(n,1n+extra),Path.depth(w,path),Path.depth(next,value),Equal.sym(Nat,Path.depth(next,value),Path.depth(w,path),depth))))
      +nextRoot = Equal.trans(Nat,Path.terminal(next,value),Path.terminal(w,path),root,terminal,atRoot)
      AliasAt{Alias.Alias{value,extra,nextRoom,nextRoot},origin}

def moveAlias(+w: R.World,+next: R.World,+root: Nat,alias: Alias.Alias<w,root>,+same: {parents(next) == parents(w) : List<&2,Nat>}) -> AliasRebased<w,next,root,alias>:
  match alias:
    case Alias.Alias{+path,+extra,+room,+atRoot}:
      aliasAt(w,next,root,path,extra,room,atRoot,same,move(w,next,path,same))

def aliasValue(-w: R.World,-next: R.World,-root: Nat,-original: Alias.Alias<w,root>,moved: AliasRebased<w,next,root,original>) -> Alias.Alias<next,root>:
  match moved:
    case AliasAt{value,identity}: value

def aliasIdentity(-w: R.World,-next: R.World,-root: Nat,-original: Alias.Alias<w,root>,+moved: AliasRebased<w,next,root,original>) -> {Alias.identity(next,root,aliasValue(w,next,root,original,moved)) == Alias.identity(w,root,original) : Nat}:
  match moved:
    case AliasAt{value,identity}: identity
