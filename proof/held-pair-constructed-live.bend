# Live-list and local scan-step facts on the constructed queued-Round snapshot.
# This does not execute Round intake or establish scanner-task reachability.
# Closed constructor-to-resume/body boundary for two joined controllers. The
# first source graph/controller/hold and second create/open/join are all actual
# runtime operations. No intermediate World/profile/capture/count is supplied.
# Public factory/parking, host settlement and queued Round remain separate.
import Base
import ../representation/records.bend as R
import ../runtime/core.bend as C
import ./ordinary-graph-data.bend as Graph
import ./held-opened-state.bend as First
import ./held-first-ready-construction.bend as Ready
import ./held-pair-generic-body.bend as Generic
import ./held-pair-generic-debt.bend as PairDebt
import ./held-count-certificate.bend as Debt
import ./transaction-pair.bend as Pair
import ./held-pair-generic-context.bend as Context
import ./held-resume-retirement.bend as Resume
import ./held-body-evaluation.bend as Eval
import ./held-write-history.bend as History
import ./action-body-entry.bend as Entry
import ./action-body-retirement.bend as Exit
import ./action-output-frame.bend as Output
import ./pending-stack-history.bend as Steps

import ./held-pair-generic-round.bend as Round
import ./action-control-flags.bend as Flags

import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ./action-retirement-count.bend as Count

import ./held-pair-generic-live.bend as Live
import ./held-live-construction.bend as Construction

def complete(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> {R.World.transactions(C.world(Steps.iterate(Round.cost(First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Graph.source(value),values,answer,other,reverse,second,rest,stack,incoming,rejected,Ready.constructed(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Flags.raw(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second))),Resume.start(Generic.world(First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Graph.source(value),values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected)))) == [Context.root(reverse)] : List<&2,Nat>}:
  Live.complete(First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Graph.source(value),values,answer,other,reverse,second,rest,stack,incoming,rejected,Ready.constructed(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Flags.raw(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Construction.initial(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)))

def step(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+scanRest: List<&2,C.Task>,+scanStack: List<&2,R.Value>,+frame: C.SeamFrame) -> {C.step(C.Machine{C.world(Steps.iterate(Round.cost(First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Graph.source(value),values,answer,other,reverse,second,rest,stack,incoming,rejected,Ready.constructed(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Flags.raw(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second))),Resume.start(Generic.world(First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Graph.source(value),values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected))),C.LandTransactions{frame,1n} <> scanRest,scanStack}) == C.Machine{C.world(Steps.iterate(Round.cost(First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Graph.source(value),values,answer,other,reverse,second,rest,stack,incoming,rejected,Ready.constructed(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Flags.raw(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second))),Resume.start(Generic.world(First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Graph.source(value),values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected))),C.LandTransactions{frame,0n} <> scanRest,scanStack} : C.Machine}:
  Live.step(First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Graph.source(value),values,answer,other,reverse,second,rest,stack,incoming,rejected,Ready.constructed(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Flags.raw(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Construction.initial(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),scanRest,scanStack,frame)
