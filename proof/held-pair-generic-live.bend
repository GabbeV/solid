# Live-list and local scan-step facts on the constructed queued-Round snapshot.
# This does not execute Round intake or establish scanner-task reachability.
# Either real joined controller runs a finite setter body and retires exactly
# its captured obligation, with the other obligation retained in the target.
# Raw graph/controllers/hold/join supply every input profile/capture/count fact.
# This starts at captured resume; host parking/delivery and Round remain separate.
import Base
import ../runtime/transaction.bend as X
import ./action-output-queue-debt.bend as QueueDebt
import ./action-retirement-count.bend as Count
import ./transaction-positive.bend as Positive
import ./action-body-return.bend as StepHealth
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ./held-first-ready.bend as Ready
import ./held-pair-generic-state.bend as State
import ./held-pair-generic-context.bend as Context
import ./held-pair-generic-aliases.bend as Aliases
import ./held-source-cache-debt.bend as Cache
import ./held-count-certificate.bend as Debt
import ./held-pair-generic-body.bend as Generic
import ./held-resume-retirement.bend as Resume
import ./held-body-evaluation.bend as Eval
import ./held-write-history.bend as History
import ./action-body-entry.bend as Entry
import ./action-body-retirement.bend as Exit
import ./action-output-frame.bend as Output
import ./pending-stack-history.bend as Steps
import ./transaction-pair.bend as Pair

import ./held-pair-generic-output-queue.bend as PairQueue
import ./held-source-cache-output-queue.bend as SourceQueue
import ./action-output-continuation.bend as Queue
import ./action-output-queue-state.bend as QueueState
import ./held-pair-generic-debt.bend as PairDebt
import ./held-source-cache-debt.bend as SourceDebt
import ./held-cache-body-input.bend as Input
import ./held-cached-body-control.bend as Control
import ./held-pair-control-flags.bend as PairFlags
import ./action-control-flags.bend as Flags
import ./action-slice-entry.bend as Slice
import ./core-run-prefix.bend as Driver

import ./held-pair-generic-round.bend as Round
import ./held-live-construction.bend as Construction
import ./held-live-group-frame.bend as Live
import ./action-landing-scan.bend as Scan

def complete(+seed: R.World,+id: Nat,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+ready: Ready.Ready<seed,id,Generic.left(Resume.methods(values,id,answer),other,second)>,+known: {Flags.observe(seed) == Flags.Flags{0n,False{},False{}} : Flags.View},+live: {R.World.transactions(seed) == [1n] : List<&2,Nat>}) -> {R.World.transactions(C.world(Steps.iterate(Round.cost(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known),Resume.start(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected)))) == [Context.root(reverse)] : List<&2,Nat>}:
  +methods = Resume.methods(values,id,answer)
  +l = Generic.left(methods,other,second)
  +r = Generic.right(methods,other,second)
  +fromRound = Equal.cong(C.Machine,List<&2,Nat>,m=>R.World.transactions(C.world(m)),Steps.iterate(Round.cost(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known),Resume.start(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected)),C.Machine{Round.world(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known),C.Round{} <> C.ActionRestoreQuestion{R.World.question(Generic.world(seed,id,values,answer,other,reverse,second))} <> rest,stack},Round.complete(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known))
  +fromQueue = Live.queued(SourceQueue.after(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),values,rest,stack,incoming,rejected),SourceQueue.work(Generic.world(seed,id,values,answer,other,reverse,second),rest),stack,PairQueue.classify(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready))
  +fromBody = Live.retired(values,Entry.prepared(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),R.ActionEnd{}),C.world(SourceQueue.after(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),values,rest,stack,incoming,rejected)),id,Pair.targetPred([],[],reverse),1n,Round.input(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known),Generic.complete(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready))
  +fromEntry = Live.preparedFresh(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),Pair.targetPred([],[],reverse),Context.actor(second),R.ActionEnd{},Aliases.selected(seed,id,l,r,reverse,second,ready),Aliases.captured(seed,id,l,r,reverse,second,ready),Aliases.selectedIdentity(seed,id,l,r,reverse,second,ready),Context.empty(seed,id,l,r,reverse,ready))
  Equal.trans(List<&2,Nat>,R.World.transactions(C.world(Steps.iterate(Round.cost(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known),Resume.start(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected)))),R.World.transactions(Round.world(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known)),[Context.root(reverse)],fromRound,Equal.trans(List<&2,Nat>,R.World.transactions(Round.world(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known)),R.World.transactions(C.world(SourceQueue.after(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),values,rest,stack,incoming,rejected))),[Context.root(reverse)],fromQueue,Equal.trans(List<&2,Nat>,R.World.transactions(C.world(SourceQueue.after(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),values,rest,stack,incoming,rejected))),R.World.transactions(Entry.prepared(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),R.ActionEnd{})),[Context.root(reverse)],fromBody,Equal.trans(List<&2,Nat>,R.World.transactions(Entry.prepared(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),R.ActionEnd{})),R.World.transactions(Generic.world(seed,id,values,answer,other,reverse,second)),[Context.root(reverse)],fromEntry,Construction.joined(seed,id,l,r,reverse,ready,live)))))

def scan(+seed: R.World,+id: Nat,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+ready: Ready.Ready<seed,id,Generic.left(Resume.methods(values,id,answer),other,second)>,+known: {Flags.observe(seed) == Flags.Flags{0n,False{},False{}} : Flags.View},+live: {R.World.transactions(seed) == [1n] : List<&2,Nat>},+scanRest: List<&2,C.Task>,+scanStack: List<&2,R.Value>,+frame: C.SeamFrame) -> {C.landTransactions(C.world(Steps.iterate(Round.cost(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known),Resume.start(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected))),scanRest,scanStack,frame,1n) == C.Machine{C.world(Steps.iterate(Round.cost(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known),Resume.start(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected))),C.LandTransactions{frame,0n} <> scanRest,scanStack} : C.Machine}:
  Scan.scan(C.world(Steps.iterate(Round.cost(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known),Resume.start(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected))),scanRest,scanStack,frame,0n,Context.root(reverse),Equal.cong(List<&2,Nat>,Nat,rows=>B.get(Nat,rows,0n,0n),R.World.transactions(C.world(Steps.iterate(Round.cost(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known),Resume.start(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected)))),[Context.root(reverse)],complete(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known,live)),Round.blocked(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known))

def step(+seed: R.World,+id: Nat,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+ready: Ready.Ready<seed,id,Generic.left(Resume.methods(values,id,answer),other,second)>,+known: {Flags.observe(seed) == Flags.Flags{0n,False{},False{}} : Flags.View},+live: {R.World.transactions(seed) == [1n] : List<&2,Nat>},+scanRest: List<&2,C.Task>,+scanStack: List<&2,R.Value>,+frame: C.SeamFrame) -> {C.step(C.Machine{C.world(Steps.iterate(Round.cost(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known),Resume.start(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected))),C.LandTransactions{frame,1n} <> scanRest,scanStack}) == C.Machine{C.world(Steps.iterate(Round.cost(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known),Resume.start(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected))),C.LandTransactions{frame,0n} <> scanRest,scanStack} : C.Machine}:
  Equal.trans(C.Machine,C.step(C.Machine{C.world(Steps.iterate(Round.cost(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known),Resume.start(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected))),C.LandTransactions{frame,1n} <> scanRest,scanStack}),C.landTransactions(C.world(Steps.iterate(Round.cost(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known),Resume.start(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected))),scanRest,scanStack,frame,1n),C.Machine{C.world(Steps.iterate(Round.cost(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known),Resume.start(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected))),C.LandTransactions{frame,0n} <> scanRest,scanStack},StepHealth.healthyStep(C.world(Steps.iterate(Round.cost(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known),Resume.start(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected))),C.LandTransactions{frame,1n},scanRest,scanStack,StepHealth.health(C.world(Steps.iterate(Round.cost(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known),Resume.start(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected))),Round.postHealth(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known))),scan(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known,live,scanRest,scanStack,frame))
