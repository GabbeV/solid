# Construct the actual next source-cache route as well as its virtual held
# profile. Empty bodies retain their old cache; the first real setter supplies
# a canonical cache. Retirement/output preserve that actual cache and route.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./held-write-profile.bend as P
import ./held-write-history.bend as History
import ./held-source-cache-body.bend as First
import ./held-cache-virtual-history.bend as Virtual
import ./held-cache-body-input.bend as Input
import ./held-source-cache-rebase.bend as Cache
import ./transaction-resolution.bend as Path
import ./transaction-rejoin-history.bend as Alias
import ./transaction-route-rebase.bend as Move
import ./held-source-view.bend as V
import ./held-source-transfer.bend as Transfer
import ./held-source-cache-resume.bend as Resume
import ./held-retirement-source-profile.bend as Post
import ./action-body-retirement.bend as Exit
import ./action-output-frame.bend as Output

def rootAlias(+w: R.World,+id: Nat,+offset: Nat,+profile: P.Profile<w,id,offset>) -> Alias.Alias<w,1n+offset>:
  Alias.Alias{Path.Root{1n+offset,P.terminal(w,id,offset,profile)},B.length(R.Transaction,R.World.txArena(w)),{==},{==}}

def rootIdentity(+w: R.World,+id: Nat,+offset: Nat,+profile: P.Profile<w,id,offset>) -> {Alias.identity(w,1n+offset,rootAlias(w,id,offset,profile)) == 1n+offset : Nat}:
  {==}

def canonical(+w: R.World,+id: Nat,+offset: Nat,+profile: P.Profile<w,id,offset>) -> Input.Input<w,id,offset>:
  Input.Prepared{rootAlias(w,id,offset,profile),Equal.trans(Nat,R.NodeExtension.transaction(B.extension(w,id)),1n+offset,Alias.identity(w,1n+offset,rootAlias(w,id,offset,profile)),Virtual.cached(w,id,offset,profile),Equal.sym(Nat,Alias.identity(w,1n+offset,rootAlias(w,id,offset,profile)),1n+offset,rootIdentity(w,id,offset,profile))),Virtual.virtualize(w,id,offset,profile)}

def written(+values: List<&2,R.Value>,+w: R.World,+id: Nat,+offset: Nat,input: Input.Input<w,id,offset>) -> Input.Input<History.run(values,w,id),id,offset>:
  match values:
    case Nil{}: input
    case +head <> +tail:
      match input:
        case Input.Prepared{source,cached,profile}:
          canonical(History.run(head <> tail,w,id),id,offset,First.afterProfile(w,head,tail,id,offset,source,cached,profile))

def retired(+written: R.World,+next: R.World,+id: Nat,+offset: Nat,+remaining: Nat,input: Input.Input<written,id,offset>,+same: {Output.outer(next) == Output.outer(Exit.target(written,1n+offset,remaining)) : R.World}) -> Input.Input<next,id,offset>:
  match input:
    case Input.Prepared{+source,cached,profile}:
      +view = Post.actual(written,next,1n+offset,remaining,same)
      +parents = Equal.cong(V.View,List<&2,Nat>,v=>V.routes(v),V.observe(next),V.observe(written),view)
      +moved = Move.moveAlias(written,next,1n+offset,source,parents)
      Input.Prepared{Move.aliasValue(written,next,1n+offset,source,moved),Resume.sourceCapture(written,next,id,1n+offset,source,cached,Transfer.sameExtension(written,next,id,view),moved),Post.profile(written,next,id,offset,remaining,profile,same)}
