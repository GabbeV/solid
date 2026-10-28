# Recover the next held-source invariant from checked body evidence. The actual
# World is retained; the canonical cache is only a proof view, including zero
# setters whose real cache can remain an old alias.
import Base
import ../representation/records.bend as R
import ../runtime/core.bend as C
import ./pending-stack-history.bend as Steps
import ./held-write-profile.bend as P
import ./held-source-cache-rebase.bend as Cache
import ./held-count-certificate.bend as Debt
import ./held-retirement-source-profile.bend as Post

def evidence(+id: Nat,+offset: Nat,+remaining: Nat,+evidence: Debt.Evidence<id,offset,remaining>) -> P.Profile<Cache.canonical(C.world(Steps.iterate(Debt.bound(id,offset,remaining,evidence),Debt.initial(id,offset,remaining,evidence))),id,1n+offset),id,offset>:
  match evidence:
    case Debt.Written{before,steps,written,profile,same}:
      Post.profile(written,C.world(Steps.iterate(steps,before)),id,offset,remaining,profile,same)

def outcome(+before: C.Machine,+steps: Nat,+id: Nat,+offset: Nat,+remaining: Nat,proof: Debt.Outcome<before,steps,id,offset,remaining>) -> P.Profile<Cache.canonical(C.world(Steps.iterate(steps,before)),id,1n+offset),id,offset>:
  match proof:
    case Debt.At{+record,initialEq,boundEq}:
      %boundEq : P.Profile<Cache.canonical(C.world(Steps.iterate(_,before)),id,1n+offset),id,offset>
      %initialEq : P.Profile<Cache.canonical(C.world(Steps.iterate(Debt.bound(id,offset,remaining,record),_)),id,1n+offset),id,offset>
      evidence(id,offset,remaining,record)
