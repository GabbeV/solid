# Actual body return/retirement with an initially redirected source cache.
# Empty bodies retain the input cache; nonempty bodies derive a canonical
# successor from the first real setter. Original capture and arena are retained.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ../runtime/transaction.bend as X
import ./held-source-cache-rebase.bend as Cache
import ./held-source-cache-body.bend as First
import ./transaction-rejoin-history.bend as Alias
import ./held-write-profile.bend as P
import ./held-profile-control.bend as Control
import ./held-body-evaluation.bend as Eval
import ./held-body-return.bend as Body
import ./held-body-retirement.bend as Canonical
import ./held-write-history.bend as History
import ./action-body-return.bend as Literal
import ./action-body-retirement.bend as Exit
import ./action-output-frame.bend as Output
import ./action-resolution.bend as Done
import ./transaction-resolution.bend as Routes
import ./transaction-route-transport.bend as Transport
import ./pending-stack-history.bend as Steps
import ./core-run-prefix.bend as Driver

def initialHealth(+w: R.World,+id: Nat,+offset: Nat,profile: P.Profile<Cache.canonical(w,id,1n+offset),id,offset>) -> {R.World.fault(w) == R.Healthy{} : R.Fault}:
  First.health(w,id,First.facts(w,id,offset,profile))

def healthy(+values: List<&2,R.Value>,+w: R.World,+id: Nat,+offset: Nat,+alias: Alias.Alias<w,1n+offset>,+cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,alias) : Nat},+profile: P.Profile<Cache.canonical(w,id,1n+offset),id,offset>) -> {R.World.fault(History.run(values,w,id)) == R.Healthy{} : R.Fault}:
  match values:
    case Nil{}: initialHealth(w,id,offset,profile)
    case +head <> +tail: Control.healthy(History.run(head <> tail,w,id),id,offset,First.afterProfile(w,head,tail,id,offset,alias,cached,profile))

def evaluation(+values: List<&2,R.Value>,+w: R.World,+id: Nat,+answer: R.Value,+actor: Nat,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,+alias: Alias.Alias<w,1n+offset>,+cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,alias) : Nat},+profile: P.Profile<Cache.canonical(w,id,1n+offset),id,offset>) -> {Steps.iterate(Eval.cost(values),Body.start(w,values,id,answer,actor,rest,stack)) == Literal.returned(History.run(values,w,id),rest,stack,actor,answer) : C.Machine}:
  match values:
    case Nil{}: Literal.healthyStep(w,C.Evaluate{R.Literal{R.StepResult{True{},answer}},R.Undefined{}},C.ActionStepReturn{actor,stack} <> rest,stack,Literal.health(w,initialHealth(w,id,offset,profile)))
    case +head <> +tail: First.complete(w,head,tail,id,answer,C.ActionStepReturn{actor,stack} <> rest,stack,offset,alias,cached,profile)

def complete(+values: List<&2,R.Value>,+w: R.World,+id: Nat,+answer: R.Value,+actor: Nat,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,+alias: Alias.Alias<w,1n+offset>,+cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,alias) : Nat},+profile: P.Profile<Cache.canonical(w,id,1n+offset),id,offset>) -> {Steps.iterate(1n+Eval.cost(values),Body.start(w,values,id,answer,actor,rest,stack)) == Body.done(w,values,id,answer,actor,rest,stack) : C.Machine}:
  +next = History.run(values,w,id)
  Driver.appendStep(Eval.cost(values),Body.start(w,values,id,answer,actor,rest,stack),Literal.returned(next,rest,stack,actor,answer),Body.done(w,values,id,answer,actor,rest,stack),evaluation(values,w,id,answer,actor,rest,stack,offset,alias,cached,profile),Literal.finishes(next,rest,stack,actor,answer,healthy(values,w,id,offset,alias,cached,profile)))

def actions(+w: R.World,+id: Nat,+root: Nat) -> {R.World.actions(Cache.canonical(w,id,root)) == R.World.actions(w) : List<&2,R.ActionState>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def arena(+values: List<&2,R.Value>,+w: R.World,+id: Nat,+offset: Nat,+alias: Alias.Alias<w,1n+offset>,+cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,alias) : Nat},+profile: P.Profile<Cache.canonical(w,id,1n+offset),id,offset>) -> {R.World.txArena(A.exit(History.run(values,w,id))) == R.World.txArena(w) : List<&2,R.Transaction>}:
  match values:
    case Nil{}: Exit.exitArena(w)
    case +head <> +tail:
      +virtual = Cache.canonical(w,id,1n+offset)
      +actual = History.run(head <> tail,w,id)
      +other = History.run(head <> tail,virtual,id)
      Equal.trans(List<&2,R.Transaction>,R.World.txArena(A.exit(actual)),R.World.txArena(A.exit(other)),R.World.txArena(w),Equal.cong(R.World,List<&2,R.Transaction>,state=>R.World.txArena(A.exit(state)),actual,other,Cache.history(w,id,offset,head,tail,alias,cached,profile)),Equal.trans(List<&2,R.Transaction>,R.World.txArena(A.exit(other)),R.World.txArena(virtual),R.World.txArena(w),Canonical.arena(head <> tail,virtual,id,offset,profile),Cache.arena(w,id,1n+offset)))

def capture(+values: List<&2,R.Value>,+w: R.World,+id: Nat,+actor: Nat,+offset: Nat,+alias: Alias.Alias<w,1n+offset>,+cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,alias) : Nat},+profile: P.Profile<Cache.canonical(w,id,1n+offset),id,offset>) -> {R.ActionState.transaction(A.get(A.exit(History.run(values,w,id)),actor)) == R.ActionState.transaction(A.get(w,actor)) : Nat}:
  match values:
    case Nil{}: Exit.exitCapture(w,actor)
    case +head <> +tail:
      +virtual = Cache.canonical(w,id,1n+offset)
      +actual = History.run(head <> tail,w,id)
      +other = History.run(head <> tail,virtual,id)
      Equal.trans(Nat,R.ActionState.transaction(A.get(A.exit(actual),actor)),R.ActionState.transaction(A.get(A.exit(other),actor)),R.ActionState.transaction(A.get(w,actor)),Equal.cong(R.World,Nat,state=>R.ActionState.transaction(A.get(A.exit(state),actor)),actual,other,Cache.history(w,id,offset,head,tail,alias,cached,profile)),Equal.trans(Nat,R.ActionState.transaction(A.get(A.exit(other),actor)),R.ActionState.transaction(A.get(virtual,actor)),R.ActionState.transaction(A.get(w,actor)),Canonical.capture(head <> tail,virtual,id,actor,offset,profile),Equal.cong(List<&2,R.ActionState>,Nat,rows=>R.ActionState.transaction(B.get(R.ActionState,rows,actor,A.blank())),R.World.actions(virtual),R.World.actions(w),actions(w,id,1n+offset))))

def outer(+values: List<&2,R.Value>,+w: R.World,+id: Nat,+answer: R.Value,+actor: Nat,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,+alias: Alias.Alias<w,1n+offset>,+cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,alias) : Nat},+profile: P.Profile<Cache.canonical(w,id,1n+offset),id,offset>) -> {Output.outer(C.world(Steps.iterate(1n+Eval.cost(values),Body.start(w,values,id,answer,actor,rest,stack)))) == Output.outer(A.done(A.exit(History.run(values,w,id)),actor)) : R.World}:
  +next = A.done(A.exit(History.run(values,w,id)),actor)
  Equal.trans(R.World,Output.outer(C.world(Steps.iterate(1n+Eval.cost(values),Body.start(w,values,id,answer,actor,rest,stack)))),Output.outer(C.world(Body.done(w,values,id,answer,actor,rest,stack))),Output.outer(next),Equal.cong(C.Machine,R.World,m=>Output.outer(C.world(m)),Steps.iterate(1n+Eval.cost(values),Body.start(w,values,id,answer,actor,rest,stack)),Body.done(w,values,id,answer,actor,rest,stack),complete(values,w,id,answer,actor,rest,stack,offset,alias,cached,profile)),Output.output(next,rest,stack,actor,False{},answer))

def retire(+values: List<&2,R.Value>,+w: R.World,+id: Nat,+answer: R.Value,+actor: Nat,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,+alias: Alias.Alias<w,1n+offset>,+cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,alias) : Nat},+profile: P.Profile<Cache.canonical(w,id,1n+offset),id,offset>,+route: Routes.Route<w>,+extra: Nat,+remaining: Nat,captured: {R.ActionState.transaction(A.get(w,actor)) == Routes.origin(w,route) : Nat},room: {1n+B.length(R.Transaction,R.World.txArena(w)) == Nat.add(Routes.depth(w,route),1n+extra) : Nat},open: {R.Transaction.open(B.transaction(w,Routes.terminal(w,route))) == 1n+remaining : Nat}) -> {Output.outer(C.world(Steps.iterate(1n+Eval.cost(values),Body.start(w,values,id,answer,actor,rest,stack)))) == Output.outer(Exit.target(History.run(values,w,id),Routes.terminal(w,route),remaining)) : R.World}:
  +next = A.exit(History.run(values,w,id))
  +sameArena = arena(values,w,id,offset,alias,cached,profile)
  +capturedNext = Equal.trans(Nat,R.ActionState.transaction(A.get(next,actor)),R.ActionState.transaction(A.get(w,actor)),Routes.origin(w,route),capture(values,w,id,actor,offset,alias,cached,profile),captured)
  +resolution = Equal.trans(B.Bundle<R.World,Nat>,X.resolveTx(next,R.ActionState.transaction(A.get(next,actor))),X.resolveTx(next,Routes.origin(w,route)),B.Bundle{next,Routes.terminal(w,route)},Equal.cong(Nat,B.Bundle<R.World,Nat>,n=>X.resolveTx(next,n),R.ActionState.transaction(A.get(next,actor)),Routes.origin(w,route),capturedNext),Transport.public(w,next,route,extra,sameArena,room))
  +nextOpen = Equal.trans(Nat,R.Transaction.open(B.transaction(next,Routes.terminal(w,route))),R.Transaction.open(B.transaction(w,Routes.terminal(w,route))),1n+remaining,Equal.cong(List<&2,R.Transaction>,Nat,rows=>R.Transaction.open(B.get(R.Transaction,rows,Routes.terminal(w,route),B.blank_transaction())),R.World.txArena(next),R.World.txArena(w),sameArena),open)
  Equal.trans(R.World,Output.outer(C.world(Steps.iterate(1n+Eval.cost(values),Body.start(w,values,id,answer,actor,rest,stack)))),Output.outer(A.done(next,actor)),Output.outer(Exit.target(History.run(values,w,id),Routes.terminal(w,route),remaining)),outer(values,w,id,answer,actor,rest,stack,offset,alias,cached,profile),Equal.cong(R.World,R.World,state=>Output.outer(state),A.done(next,actor),Exit.target(History.run(values,w,id),Routes.terminal(w,route),remaining),Done.decreases(next,actor,Routes.terminal(w,route),remaining,resolution,nextOpen)))

def savedStack(+values: List<&2,R.Value>,+w: R.World,+id: Nat,+answer: R.Value,+actor: Nat,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,+alias: Alias.Alias<w,1n+offset>,+cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,alias) : Nat},+profile: P.Profile<Cache.canonical(w,id,1n+offset),id,offset>) -> {C.values(Steps.iterate(1n+Eval.cost(values),Body.start(w,values,id,answer,actor,rest,stack))) == stack : List<&2,R.Value>}:
  +next = A.done(A.exit(History.run(values,w,id)),actor)
  Equal.trans(List<&2,R.Value>,C.values(Steps.iterate(1n+Eval.cost(values),Body.start(w,values,id,answer,actor,rest,stack))),C.values(Body.done(w,values,id,answer,actor,rest,stack)),stack,Equal.cong(C.Machine,List<&2,R.Value>,m=>C.values(m),Steps.iterate(1n+Eval.cost(values),Body.start(w,values,id,answer,actor,rest,stack)),Body.done(w,values,id,answer,actor,rest,stack),complete(values,w,id,answer,actor,rest,stack,offset,alias,cached,profile)),Output.outputStack(next,rest,stack,actor,False{},answer))
