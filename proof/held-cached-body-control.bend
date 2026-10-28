# Ambient depth/running/halted flags and scheduling after a real cached-alias
# body. Preparation enters once; finite held writes retain flags; retirement
# exits once. Result output projection does not hide any of these flags.
import Base
import ./action-laws.bend as Arithmetic
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ./held-write-profile.bend as P
import ./held-write-history.bend as History
import ./held-write-outer.bend as Outer
import ./held-cache-body-input.bend as Input
import ./held-source-cache-rebase.bend as Cache
import ./transaction-rejoin-history.bend as Alias
import ./held-alias-preparation.bend as Prepare
import ./held-preparation-source.bend as Source
import ./held-setter-entry.bend as Join
import ./action-body-entry.bend as Entry
import ./action-body-retirement.bend as Exit
import ./action-output-frame.bend as Output
import ./action-control-flags.bend as Flags
import ./action-schedule-ready.bend as Schedule

def virtual(+w: R.World,+id: Nat,+root: Nat) -> {Flags.observe(Cache.canonical(w,id,root)) == Flags.observe(w) : Flags.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def written(+values: List<&2,R.Value>,+w: R.World,+id: Nat,+offset: Nat,input: Input.Input<w,id,offset>) -> {Flags.observe(History.run(values,w,id)) == Flags.observe(w) : Flags.View}:
  match values:
    case Nil{}: {==}
    case +head <> +tail:
      match input:
        case Input.Prepared{source,cached,+profile}:
          +canonical = Cache.canonical(w,id,1n+offset)
          +actual = History.run(head <> tail,w,id)
          +other = History.run(head <> tail,canonical,id)
          Equal.trans(Flags.View,Flags.observe(actual),Flags.observe(other),Flags.observe(w),Equal.cong(R.World,Flags.View,state=>Flags.observe(state),actual,other,Cache.history(w,id,offset,head,tail,source,cached,profile)),Equal.trans(Flags.View,Flags.observe(other),Flags.observe(canonical),Flags.observe(w),Flags.fromWrites(canonical,other,R.Node.x(B.node(canonical,id)),History.outer(head <> tail,canonical,id,offset,profile)),virtual(w,id,1n+offset)))

def preparedFresh(+w: R.World,+actor: Nat,+offset: Nat,+captureOffset: Nat,+tail: R.Expr,+alias: Alias.Alias<w,1n+offset>,captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},empty: {R.World.flushTransaction(w) == 0n : Nat}) -> {Flags.observe(Entry.prepared(w,actor,tail)) == Flags.enter(Flags.observe(w)) : Flags.View}:
  +asked = Entry.asked(w,actor)
  +joined = Entry.joined(w,actor)
  +flushed = Source.flush(asked,1n+offset)
  +scheduled = Join.scheduled(flushed)
  +same = Equal.trans(Flags.View,Flags.observe(joined),Flags.observe(scheduled),Flags.observe(w),Equal.cong(R.World,Flags.View,state=>Flags.observe(state),joined,scheduled,Prepare.joinedFresh(w,actor,offset,captureOffset,alias,captured,positive,empty)),Equal.trans(Flags.View,Flags.observe(scheduled),Flags.observe(flushed),Flags.observe(w),Flags.selected(flushed),Equal.trans(Flags.View,Flags.observe(flushed),Flags.observe(asked),Flags.observe(w),Flags.future(asked,1n+offset),Flags.question(w,R.ActionState.question(A.get(w,actor))))))
  Equal.trans(Flags.View,Flags.observe(Entry.prepared(w,actor,tail)),Flags.observe(A.enter(joined)),Flags.enter(Flags.observe(w)),Flags.store(A.enter(joined),actor,R.ActionState.with_methods(A.get(joined,actor),tail)),Equal.trans(Flags.View,Flags.observe(A.enter(joined)),Flags.enter(Flags.observe(joined)),Flags.enter(Flags.observe(w)),Flags.entered(joined),Equal.cong(Flags.View,Flags.View,v=>Flags.enter(v),Flags.observe(joined),Flags.observe(w),same)))

def actual(+written: R.World,+next: R.World,+root: Nat,+remaining: Nat,same: {Output.outer(next) == Output.outer(Exit.target(written,root,remaining)) : R.World}) -> {Flags.observe(next) == Flags.exit(Flags.observe(written)) : Flags.View}:
  Equal.trans(Flags.View,Flags.observe(next),Flags.observe(Output.outer(next)),Flags.exit(Flags.observe(written)),Equal.sym(Flags.View,Flags.observe(Output.outer(next)),Flags.observe(next),Flags.output(next)),Equal.trans(Flags.View,Flags.observe(Output.outer(next)),Flags.observe(Output.outer(Exit.target(written,root,remaining))),Flags.exit(Flags.observe(written)),Equal.cong(R.World,Flags.View,w=>Flags.observe(w),Output.outer(next),Output.outer(Exit.target(written,root,remaining)),same),Equal.trans(Flags.View,Flags.observe(Output.outer(Exit.target(written,root,remaining))),Flags.observe(Exit.target(written,root,remaining)),Flags.exit(Flags.observe(written)),Flags.output(Exit.target(written,root,remaining)),Flags.target(written,root,remaining))))

def exitEnter(+view: Flags.View) -> {Flags.exit(Flags.enter(view)) == view : Flags.View}:
  match view:
    case Flags.Flags{+depth,+running,+halted}: Equal.cong(Nat,Flags.View,n=>Flags.Flags{n,running,halted},Nat.sub(depth,0n),depth,Arithmetic.subZero(depth))

def enterHalted(+view: Flags.View) -> {Flags.halted(Flags.enter(view)) == Flags.halted(view) : Bool}:
  match view:
    case Flags.Flags{depth,running,halted}: {==}

def writtenEntry(+initial: R.World,+body: R.World,+values: List<&2,R.Value>,+id: Nat,+offset: Nat,input: Input.Input<body,id,offset>,entered: {Flags.observe(body) == Flags.enter(Flags.observe(initial)) : Flags.View}) -> {Flags.observe(History.run(values,body,id)) == Flags.enter(Flags.observe(initial)) : Flags.View}:
  Equal.trans(Flags.View,Flags.observe(History.run(values,body,id)),Flags.observe(body),Flags.enter(Flags.observe(initial)),written(values,body,id,offset,input),entered)

def finish(+initial: R.World,+body: R.World,+next: R.World,+values: List<&2,R.Value>,+id: Nat,+offset: Nat,+remaining: Nat,input: Input.Input<body,id,offset>,entered: {Flags.observe(body) == Flags.enter(Flags.observe(initial)) : Flags.View},same: {Output.outer(next) == Output.outer(Exit.target(History.run(values,body,id),1n+offset,remaining)) : R.World}) -> {Flags.observe(next) == Flags.observe(initial) : Flags.View}:
  Equal.trans(Flags.View,Flags.observe(next),Flags.exit(Flags.observe(History.run(values,body,id))),Flags.observe(initial),actual(History.run(values,body,id),next,1n+offset,remaining,same),Equal.trans(Flags.View,Flags.exit(Flags.observe(History.run(values,body,id))),Flags.exit(Flags.enter(Flags.observe(initial))),Flags.observe(initial),Equal.cong(Flags.View,Flags.View,v=>Flags.exit(v),Flags.observe(History.run(values,body,id)),Flags.enter(Flags.observe(initial)),writtenEntry(initial,body,values,id,offset,input,entered)),exitEnter(Flags.observe(initial))))

def scheduled(+initial: R.World,+body: R.World,+next: R.World,+values: List<&2,R.Value>,+id: Nat,+offset: Nat,+remaining: Nat,input: Input.Input<body,id,offset>,entered: {Flags.observe(body) == Flags.enter(Flags.observe(initial)) : Flags.View},+same: {Output.outer(next) == Output.outer(Exit.target(History.run(values,body,id),1n+offset,remaining)) : R.World},unhalted: {R.World.halted(initial) == False{} : Bool}) -> {R.World.scheduled(next) == True{} : Bool}:
  +written = History.run(values,body,id)
  +target = Exit.target(written,1n+offset,remaining)
  +halted = Equal.trans(Bool,R.World.halted(written),Flags.halted(Flags.enter(Flags.observe(initial))),False{},Equal.cong(Flags.View,Bool,v=>Flags.halted(v),Flags.observe(written),Flags.enter(Flags.observe(initial)),writtenEntry(initial,body,values,id,offset,input,entered)),Equal.trans(Bool,Flags.halted(Flags.enter(Flags.observe(initial))),R.World.halted(initial),False{},enterHalted(Flags.observe(initial)),unhalted))
  Equal.trans(Bool,R.World.scheduled(next),R.World.scheduled(Output.outer(next)),True{},Equal.sym(Bool,R.World.scheduled(Output.outer(next)),R.World.scheduled(next),Flags.scheduledOutput(next)),Equal.trans(Bool,R.World.scheduled(Output.outer(next)),R.World.scheduled(Output.outer(target)),True{},Equal.cong(R.World,Bool,w=>R.World.scheduled(w),Output.outer(next),Output.outer(target),same),Equal.trans(Bool,R.World.scheduled(Output.outer(target)),R.World.scheduled(target),True{},Flags.scheduledOutput(target),Schedule.target(written,1n+offset,remaining,halted))))
