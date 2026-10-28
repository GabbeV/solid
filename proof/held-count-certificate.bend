# Checked semantic outcome. No count or health of the actual execution is
# assumed: both follow from the written source certificate and World equality.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ../runtime/core.bend as C
import ./pending-stack-history.bend as Steps
import ./held-write-profile.bend as P
import ./held-source-cache-rebase.bend as Cache
import ./held-source-cache-body.bend as First
import ./action-retirement-count.bend as Count
import ./action-retirement-health.bend as Health
import ./action-body-retirement.bend as Exit
import ./action-output-frame.bend as Output
import ./transaction-positive.bend as Positive
import ./action-body-return.bend as Body

type Evidence<-id: Nat,-offset: Nat,-remaining: Nat> is Data:
  Written{before: C.Machine,steps: Nat,written: R.World,profile: P.Profile<Cache.canonical(written,id,1n+offset),id,offset>,same: {Output.outer(C.world(Steps.iterate(steps,before))) == Output.outer(Exit.target(written,1n+offset,remaining)) : R.World}}

def initial(-id: Nat,-offset: Nat,-remaining: Nat,evidence: Evidence<id,offset,remaining>) -> C.Machine:
  match evidence:
    case Written{before,steps,written,profile,same}: before

def bound(-id: Nat,-offset: Nat,-remaining: Nat,evidence: Evidence<id,offset,remaining>) -> Nat:
  match evidence:
    case Written{before,steps,written,profile,same}: steps

type Outcome<-before: C.Machine,-steps: Nat,-id: Nat,-offset: Nat,-remaining: Nat> is Data:
  At{evidence: Evidence<id,offset,remaining>,initial: {initial(id,offset,remaining,evidence) == before : C.Machine},bound: {bound(id,offset,remaining,evidence) == steps : Nat}}

def finish(+before: C.Machine,+steps: Nat,+written: R.World,+id: Nat,+offset: Nat,+remaining: Nat,profile: P.Profile<Cache.canonical(written,id,1n+offset),id,offset>,same: {Output.outer(C.world(Steps.iterate(steps,before))) == Output.outer(Exit.target(written,1n+offset,remaining)) : R.World}) -> Outcome<before,steps,id,offset,remaining>:
  +evidence = {Written{before,steps,written,profile,same} : Evidence<id,offset,remaining>}
  At{evidence,{==},{==}}

def groupRoom(-w: R.World,-id: Nat,-offset: Nat,profile: P.Profile<w,id,offset>) -> {Nat.is_lt(1n+offset,B.length(R.Transaction,R.World.txArena(w))) == True{} : Bool}:
  match profile:
    case P.HeldAt{path,extra,health,unmarked,valid,head,room,context,signal,held,override,custom,existing,extensionRoom,canonical,future,terminal,groupRoom}: groupRoom

def writtenRoom(+w: R.World,+id: Nat,+offset: Nat,+profile: P.Profile<Cache.canonical(w,id,1n+offset),id,offset>) -> {Nat.is_lt(1n+offset,B.length(R.Transaction,R.World.txArena(w))) == True{} : Bool}:
  +next = Cache.canonical(w,id,1n+offset)
  Equal.trans(Bool,Nat.is_lt(1n+offset,B.length(R.Transaction,R.World.txArena(w))),Nat.is_lt(1n+offset,B.length(R.Transaction,R.World.txArena(next))),True{},Equal.cong(List<&2,R.Transaction>,Bool,rows=>Nat.is_lt(1n+offset,B.length(R.Transaction,rows)),R.World.txArena(w),R.World.txArena(next),Equal.sym(List<&2,R.Transaction>,R.World.txArena(next),R.World.txArena(w),Cache.arena(w,id,1n+offset))),groupRoom(next,id,offset,profile))

def writtenHealth(+w: R.World,+id: Nat,+offset: Nat,profile: P.Profile<Cache.canonical(w,id,1n+offset),id,offset>) -> {R.World.fault(w) == R.Healthy{} : R.Fault}:
  +next = Cache.canonical(w,id,1n+offset)
  Equal.trans(R.Fault,R.World.fault(w),R.World.fault(next),R.Healthy{},Equal.sym(R.Fault,R.World.fault(next),R.World.fault(w),First.fault(w,id,1n+offset)),P.healthy(next,id,offset,profile))

def countMapped(+actual: R.World,+written: R.World,+id: Nat,+offset: Nat,+remaining: Nat,profile: P.Profile<Cache.canonical(written,id,1n+offset),id,offset>,same: {Output.outer(actual) == Output.outer(Exit.target(written,1n+offset,remaining)) : R.World}) -> {Count.count(actual,1n+offset) == remaining : Nat}:
  +root = {1n+offset : Nat}
  +target = Exit.target(written,root,remaining)
  Equal.trans(Nat,Count.count(actual,root),Count.count(Output.outer(actual),root),remaining,Equal.sym(Nat,Count.count(Output.outer(actual),root),Count.count(actual,root),Count.output(actual,root)),Equal.trans(Nat,Count.count(Output.outer(actual),root),Count.count(Output.outer(target),root),remaining,Equal.cong(R.World,Nat,w=>Count.count(w,root),Output.outer(actual),Output.outer(target),same),Equal.trans(Nat,Count.count(Output.outer(target),root),Count.count(target,root),remaining,Count.output(target,root),Count.target(written,root,remaining,writtenRoom(written,id,offset,profile)))))

def evidenceCount(+id: Nat,+offset: Nat,+remaining: Nat,+evidence: Evidence<id,offset,remaining>) -> {Count.count(C.world(Steps.iterate(bound(id,offset,remaining,evidence),initial(id,offset,remaining,evidence))),1n+offset) == remaining : Nat}:
  match evidence:
    case Written{before,steps,written,profile,same}:
      countMapped(C.world(Steps.iterate(steps,before)),written,id,offset,remaining,profile,same)

def evidenceHealth(+id: Nat,+offset: Nat,+remaining: Nat,+evidence: Evidence<id,offset,remaining>) -> {R.World.fault(C.world(Steps.iterate(bound(id,offset,remaining,evidence),initial(id,offset,remaining,evidence)))) == R.Healthy{} : R.Fault}:
  match evidence:
    case Written{before,steps,+written,profile,same}:
      Health.healthy(written,C.world(Steps.iterate(steps,before)),1n+offset,remaining,writtenHealth(written,id,offset,profile),same)

def count(+before: C.Machine,+steps: Nat,+id: Nat,+offset: Nat,+remaining: Nat,outcome: Outcome<before,steps,id,offset,remaining>) -> {Count.count(C.world(Steps.iterate(steps,before)),1n+offset) == remaining : Nat}:
  match outcome:
    case At{+evidence,initialEq,boundEq}:
      %boundEq : {Count.count(C.world(Steps.iterate(_,before)),1n+offset) == remaining : Nat}
      %initialEq : {Count.count(C.world(Steps.iterate(bound(id,offset,remaining,evidence),_)),1n+offset) == remaining : Nat}
      evidenceCount(id,offset,remaining,evidence)

def healthy(+before: C.Machine,+steps: Nat,+id: Nat,+offset: Nat,+remaining: Nat,outcome: Outcome<before,steps,id,offset,remaining>) -> {R.World.fault(C.world(Steps.iterate(steps,before))) == R.Healthy{} : R.Fault}:
  match outcome:
    case At{+evidence,initialEq,boundEq}:
      %boundEq : {R.World.fault(C.world(Steps.iterate(_,before))) == R.Healthy{} : R.Fault}
      %initialEq : {R.World.fault(C.world(Steps.iterate(bound(id,offset,remaining,evidence),_))) == R.Healthy{} : R.Fault}
      evidenceHealth(id,offset,remaining,evidence)

def blocked(+before: C.Machine,+steps: Nat,+id: Nat,+offset: Nat,+outcome: Outcome<before,steps,id,offset,1n>) -> {X.blocked(C.world(Steps.iterate(steps,before)),1n+offset) == B.Bundle{C.world(Steps.iterate(steps,before)),True{}} : B.Bundle<R.World,Bool>}:
  Positive.public(C.world(Steps.iterate(steps,before)),1n+offset,0n,Body.health(C.world(Steps.iterate(steps,before)),healthy(before,steps,id,offset,1n,outcome)),count(before,steps,id,offset,1n,outcome))
