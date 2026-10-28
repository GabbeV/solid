# Retain the exact live group list across prepared finite held bodies,
# retirement and the output request drain. Membership is constructed separately.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ../runtime/core.bend as C
import ./held-write-history.bend as History
import ./held-write-outer.bend as Outer
import ./held-cache-body-input.bend as Input
import ./held-source-cache-rebase.bend as Cache
import ./held-alias-preparation.bend as Prepare
import ./held-preparation-source.bend as Source
import ./held-setter-entry.bend as Join
import ./transaction-rejoin-history.bend as Alias
import ./action-body-entry.bend as Entry
import ./action-body-retirement.bend as Exit
import ./action-output-frame.bend as Output
import ./action-output-continuation.bend as Queue
import ./action-output-delivery-loop.bend as Loop
import ./scheduler-frame.bend as Scheduler

def readOuter(+w: R.World,+slot: Nat) -> {R.World.transactions(Outer.observe(w,slot)) == R.World.transactions(w) : List<&2,Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def outer(+w: R.World,+next: R.World,+slot: Nat,same: {Outer.observe(next,slot) == Outer.observe(w,slot) : R.World}) -> {R.World.transactions(next) == R.World.transactions(w) : List<&2,Nat>}:
  Equal.trans(List<&2,Nat>,R.World.transactions(next),R.World.transactions(Outer.observe(next,slot)),R.World.transactions(w),Equal.sym(List<&2,Nat>,R.World.transactions(Outer.observe(next,slot)),R.World.transactions(next),readOuter(next,slot)),Equal.trans(List<&2,Nat>,R.World.transactions(Outer.observe(next,slot)),R.World.transactions(Outer.observe(w,slot)),R.World.transactions(w),Equal.cong(R.World,List<&2,Nat>,s=>R.World.transactions(s),Outer.observe(next,slot),Outer.observe(w,slot),same),readOuter(w,slot)))

def virtual(+w: R.World,+id: Nat,+root: Nat) -> {R.World.transactions(Cache.canonical(w,id,root)) == R.World.transactions(w) : List<&2,Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def written(+values: List<&2,R.Value>,+w: R.World,+id: Nat,+offset: Nat,input: Input.Input<w,id,offset>) -> {R.World.transactions(History.run(values,w,id)) == R.World.transactions(w) : List<&2,Nat>}:
  match values:
    case Nil{}: {==}
    case +head <> +tail:
      match input:
        case Input.Prepared{source,cached,+profile}:
          +canonical = Cache.canonical(w,id,1n+offset)
          +actual = History.run(head <> tail,w,id)
          +other = History.run(head <> tail,canonical,id)
          Equal.trans(List<&2,Nat>,R.World.transactions(actual),R.World.transactions(other),R.World.transactions(w),Equal.cong(R.World,List<&2,Nat>,s=>R.World.transactions(s),actual,other,Cache.history(w,id,offset,head,tail,source,cached,profile)),Equal.trans(List<&2,Nat>,R.World.transactions(other),R.World.transactions(canonical),R.World.transactions(w),outer(canonical,other,R.Node.x(B.node(canonical,id)),History.outer(head <> tail,canonical,id,offset,profile)),virtual(w,id,1n+offset)))

def ledgerLive(frame: Scheduler.LedgerFrame) -> List<&2,Nat>:
  match frame:
    case Scheduler.LedgerFrame{arena,live,actions}: live

def schedule(+w: R.World) -> {R.World.transactions(B.schedule(w)) == R.World.transactions(w) : List<&2,Nat>}:
  Equal.cong(Scheduler.LedgerFrame,List<&2,Nat>,frame=>ledgerLive(frame),Scheduler.ledger(B.schedule(w)),Scheduler.ledger(w),Scheduler.preserves(w))

def stored(+w: R.World,+root: Nat,+record: R.Transaction) -> {R.World.transactions(B.store_transaction(w,root,record)) == R.World.transactions(w) : List<&2,Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def exited(+w: R.World) -> {R.World.transactions(A.exit(w)) == R.World.transactions(w) : List<&2,Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def target(+w: R.World,+root: Nat,+remaining: Nat) -> {R.World.transactions(Exit.target(w,root,remaining)) == R.World.transactions(w) : List<&2,Nat>}:
  +next = A.exit(w)
  +record = R.Transaction.with_open(B.transaction(next,root),remaining)
  +written = B.store_transaction(next,root,record)
  Equal.trans(List<&2,Nat>,R.World.transactions(Exit.target(w,root,remaining)),R.World.transactions(written),R.World.transactions(w),schedule(written),Equal.trans(List<&2,Nat>,R.World.transactions(written),R.World.transactions(next),R.World.transactions(w),stored(next,root,record),exited(w)))

def output(+w: R.World) -> {R.World.transactions(Output.outer(w)) == R.World.transactions(w) : List<&2,Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def actual(+written: R.World,+next: R.World,+root: Nat,+remaining: Nat,same: {Output.outer(next) == Output.outer(Exit.target(written,root,remaining)) : R.World}) -> {R.World.transactions(next) == R.World.transactions(written) : List<&2,Nat>}:
  Equal.trans(List<&2,Nat>,R.World.transactions(next),R.World.transactions(Output.outer(next)),R.World.transactions(written),Equal.sym(List<&2,Nat>,R.World.transactions(Output.outer(next)),R.World.transactions(next),output(next)),Equal.trans(List<&2,Nat>,R.World.transactions(Output.outer(next)),R.World.transactions(Output.outer(Exit.target(written,root,remaining))),R.World.transactions(written),Equal.cong(R.World,List<&2,Nat>,s=>R.World.transactions(s),Output.outer(next),Output.outer(Exit.target(written,root,remaining)),same),Equal.trans(List<&2,Nat>,R.World.transactions(Output.outer(Exit.target(written,root,remaining))),R.World.transactions(Exit.target(written,root,remaining)),R.World.transactions(written),output(Exit.target(written,root,remaining)),target(written,root,remaining))))

def retired(+values: List<&2,R.Value>,+w: R.World,+next: R.World,+id: Nat,+offset: Nat,+remaining: Nat,input: Input.Input<w,id,offset>,same: {Output.outer(next) == Output.outer(Exit.target(History.run(values,w,id),1n+offset,remaining)) : R.World}) -> {R.World.transactions(next) == R.World.transactions(w) : List<&2,Nat>}:
  Equal.trans(List<&2,Nat>,R.World.transactions(next),R.World.transactions(History.run(values,w,id)),R.World.transactions(w),actual(History.run(values,w,id),next,1n+offset,remaining,same),written(values,w,id,offset,input))

def jobs(+w: R.World) -> {R.World.transactions(Loop.outer(w)) == R.World.transactions(w) : List<&2,Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def queued(+machine: C.Machine,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+form: Queue.Queue<machine,rest,stack>) -> {R.World.transactions(Queue.world(machine,rest,stack,form)) == R.World.transactions(C.world(machine)) : List<&2,Nat>}:
  +next = Queue.world(machine,rest,stack,form)
  Equal.trans(List<&2,Nat>,R.World.transactions(next),R.World.transactions(Loop.outer(next)),R.World.transactions(C.world(machine)),Equal.sym(List<&2,Nat>,R.World.transactions(Loop.outer(next)),R.World.transactions(next),jobs(next)),Equal.trans(List<&2,Nat>,R.World.transactions(Loop.outer(next)),R.World.transactions(Loop.outer(C.world(machine))),R.World.transactions(C.world(machine)),Equal.cong(R.World,List<&2,Nat>,s=>R.World.transactions(s),Loop.outer(next),Loop.outer(C.world(machine)),Queue.frame(machine,rest,stack,form)),jobs(C.world(machine))))

def question(+w: R.World,+actor: Nat) -> {R.World.transactions(Entry.asked(w,actor)) == R.World.transactions(w) : List<&2,Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def flush(+w: R.World,+root: Nat) -> {R.World.transactions(Source.flush(w,root)) == R.World.transactions(w) : List<&2,Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def choice(+flag: Bool,+w: R.World,+yes: R.World,+no: R.World,left: {R.World.transactions(yes) == R.World.transactions(w) : List<&2,Nat>},right: {R.World.transactions(no) == R.World.transactions(w) : List<&2,Nat>}) -> {R.World.transactions(B.choose(~R.World,flag,_=>yes,_=>no)) == R.World.transactions(w) : List<&2,Nat>}:
  match flag:
    case True{}: left
    case False{}: right

def selected(+w: R.World) -> {R.World.transactions(Join.scheduled(w)) == R.World.transactions(w) : List<&2,Nat>}:
  choice(R.World.running(w),w,w,B.schedule(w),{==},schedule(w))

def tail(+w: R.World,+actor: Nat,+methods: R.Expr) -> {R.World.transactions(A.store(A.enter(w),actor,R.ActionState.with_methods(A.get(w,actor),methods))) == R.World.transactions(w) : List<&2,Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def preparedFresh(+w: R.World,+actor: Nat,+offset: Nat,+captureOffset: Nat,+methods: R.Expr,+alias: Alias.Alias<w,1n+offset>,captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},empty: {R.World.flushTransaction(w) == 0n : Nat}) -> {R.World.transactions(Entry.prepared(w,actor,methods)) == R.World.transactions(w) : List<&2,Nat>}:
  +asked = Entry.asked(w,actor)
  +joined = Entry.joined(w,actor)
  +flushed = Source.flush(asked,1n+offset)
  +scheduled = Join.scheduled(flushed)
  Equal.trans(List<&2,Nat>,R.World.transactions(Entry.prepared(w,actor,methods)),R.World.transactions(joined),R.World.transactions(w),tail(joined,actor,methods),Equal.trans(List<&2,Nat>,R.World.transactions(joined),R.World.transactions(scheduled),R.World.transactions(w),Equal.cong(R.World,List<&2,Nat>,s=>R.World.transactions(s),joined,scheduled,Prepare.joinedFresh(w,actor,offset,captureOffset,alias,captured,positive,empty)),Equal.trans(List<&2,Nat>,R.World.transactions(scheduled),R.World.transactions(flushed),R.World.transactions(w),selected(flushed),Equal.trans(List<&2,Nat>,R.World.transactions(flushed),R.World.transactions(asked),R.World.transactions(w),flush(asked,1n+offset),question(w,actor)))))
