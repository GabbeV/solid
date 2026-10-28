# Source facts at the real prepared-body boundary. Packing this boundary keeps
# subsequent history proofs generic in that World. Construction is checked by
# the actual preparation helpers; no later invariant is assumed.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./held-write-profile.bend as P
import ./held-source-cache-rebase.bend as Cache
import ./transaction-rejoin-history.bend as Alias
import ./held-cache-virtual-history.bend as Virtual
import ./held-write-history.bend as History

type Input<-w: R.World,-id: Nat,-offset: Nat> is Data:
  Prepared{source: Alias.Alias<w,1n+offset>,cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,source) : Nat},profile: P.Profile<Cache.canonical(w,id,1n+offset),id,offset>}

def written(+values: List<&2,R.Value>,+w: R.World,+id: Nat,+offset: Nat,input: Input<w,id,offset>) -> P.Profile<Cache.canonical(History.run(values,w,id),id,1n+offset),id,offset>:
  match input:
    case Prepared{source,cached,profile}: Virtual.after(values,w,id,offset,source,cached,profile)
