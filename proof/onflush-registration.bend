# Registration is the actual schedule + queueMicrotask outbox operation.
# A finite synchronous registration prefix queues each body once in order.
# This does not prove arbitrary callback termination or browser delivery fairness.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/on-flush.bend as O
import ./scheduler-frame.bend as Scheduler
import ./committed-storage-frame.bend as Content


def jobsRead(+w: R.World,+jobs: List<&2,R.HostJob>) -> {R.World.hostJobs(R.World.with_hostJobs(w,jobs)) == jobs : List<&2,R.HostJob>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def jobContent(+w: R.World,+jobs: List<&2,R.HostJob>) -> {Content.observe(R.World.with_hostJobs(w,jobs)) == Content.observe(w) : Content.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def jobLedger(+w: R.World,+jobs: List<&2,R.HostJob>) -> {Scheduler.ledger(R.World.with_hostJobs(w,jobs)) == Scheduler.ledger(w) : Scheduler.LedgerFrame}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def keepsContent(+w: R.World,+body: R.Expr) -> {Content.observe(O.register(w,body)) == Content.observe(w) : Content.View}:
  +next = B.schedule(w)
  Content.compose(w,next,O.register(w,body),jobContent(next,B.append(R.HostJob,R.World.hostJobs(next),[R.MicrotaskCallback{body}])),Content.schedule(w))

def keepsLedger(+w: R.World,+body: R.Expr) -> {Scheduler.ledger(O.register(w,body)) == Scheduler.ledger(w) : Scheduler.LedgerFrame}:
  +next = B.schedule(w)
  Equal.trans(Scheduler.LedgerFrame,Scheduler.ledger(O.register(w,body)),Scheduler.ledger(next),Scheduler.ledger(w),jobLedger(next,B.append(R.HostJob,R.World.hostJobs(next),[R.MicrotaskCallback{body}])),Scheduler.preserves(w))

# Canonical initial ambient fields: idle, unhalted, outside a sync-depth hold.
# All other fields, including the transaction/flight/owner arenas, are arbitrary.
def idle(w: R.World) -> R.World:
  R.World.with_syncDepth(R.World.with_running(R.World.with_halted(R.World.with_scheduled(w,False{}),False{}),False{}),0n)

def scheduled(w: R.World) -> R.World:
  R.World.with_scheduled(idle(w),True{})

def queued(w: R.World,jobs: List<&2,R.HostJob>) -> R.World:
  R.World.with_hostJobs(scheduled(w),jobs)

def registerQueued(+w: R.World,+jobs: List<&2,R.HostJob>,+body: R.Expr) -> {O.register(queued(w,jobs),body) == queued(w,B.append(R.HostJob,jobs,[R.MicrotaskCallback{body}])) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def first(+w: R.World,+body: R.Expr) -> {O.register(idle(w),body) == queued(w,B.append(R.HostJob,B.append(R.HostJob,R.World.hostJobs(idle(w)),[R.FlushJob{}]),[R.MicrotaskCallback{body}])) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def history(bodies: List<&2,R.Expr>,w: R.World) -> R.World:
  match bodies:
    case Nil{}: w
    case body <> rest: history(rest,O.register(w,body))

def appended(bodies: List<&2,R.Expr>,jobs: List<&2,R.HostJob>) -> List<&2,R.HostJob>:
  match bodies:
    case Nil{}: jobs
    case body <> rest: appended(rest,B.append(R.HostJob,jobs,[R.MicrotaskCallback{body}]))

def queuedHistory(+bodies: List<&2,R.Expr>,+w: R.World,+jobs: List<&2,R.HostJob>) -> {history(bodies,queued(w,jobs)) == queued(w,appended(bodies,jobs)) : R.World}:
  match bodies:
    case Nil{}: {==}
    case +body <> +rest:
      +nextJobs = B.append(R.HostJob,jobs,[R.MicrotaskCallback{body}])
      Equal.trans(R.World,history(rest,O.register(queued(w,jobs),body)),history(rest,queued(w,nextJobs)),queued(w,appended(rest,nextJobs)),Equal.cong(R.World,R.World,state=>history(rest,state),O.register(queued(w,jobs),body),queued(w,nextJobs),registerQueued(w,jobs,body)),queuedHistory(rest,w,nextJobs))

def expectedJobs(+w: R.World,+body: R.Expr,rest: List<&2,R.Expr>) -> List<&2,R.HostJob>:
  appended(rest,B.append(R.HostJob,B.append(R.HostJob,R.World.hostJobs(idle(w)),[R.FlushJob{}]),[R.MicrotaskCallback{body}]))

def nonempty(+w: R.World,+body: R.Expr,+rest: List<&2,R.Expr>) -> {history(body <> rest,idle(w)) == queued(w,expectedJobs(w,body,rest)) : R.World}:
  +firstJobs = B.append(R.HostJob,B.append(R.HostJob,R.World.hostJobs(idle(w)),[R.FlushJob{}]),[R.MicrotaskCallback{body}])
  Equal.trans(R.World,history(body <> rest,idle(w)),history(rest,queued(w,firstJobs)),queued(w,expectedJobs(w,body,rest)),Equal.cong(R.World,R.World,state=>history(rest,state),O.register(idle(w),body),queued(w,firstJobs),first(w,body)),queuedHistory(rest,w,firstJobs))

def allContent(+bodies: List<&2,R.Expr>,+w: R.World) -> {Content.observe(history(bodies,w)) == Content.observe(w) : Content.View}:
  match bodies:
    case Nil{}: {==}
    case +body <> +rest:
      Content.compose(w,O.register(w,body),history(body <> rest,w),allContent(rest,O.register(w,body)),keepsContent(w,body))

def allLedger(+bodies: List<&2,R.Expr>,+w: R.World) -> {Scheduler.ledger(history(bodies,w)) == Scheduler.ledger(w) : Scheduler.LedgerFrame}:
  match bodies:
    case Nil{}: {==}
    case +body <> +rest:
      Equal.trans(Scheduler.LedgerFrame,Scheduler.ledger(history(body <> rest,w)),Scheduler.ledger(O.register(w,body)),Scheduler.ledger(w),allLedger(rest,O.register(w,body)),keepsLedger(w,body))

# Keep every field except the four touched by scheduling/host submission.
def outer(w: R.World) -> R.World:
  R.World.with_hostJobs(R.World.with_reports(R.World.with_haltNotified(R.World.with_scheduled(w,False{}),False{}),[]),[])

def outerJobs(+w: R.World,+jobs: List<&2,R.HostJob>) -> {outer(R.World.with_hostJobs(w,jobs)) == outer(w) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def outerScheduled(+w: R.World) -> {outer(B.schedule(w)) == outer(w) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match running scheduled halted haltNotified syncDepth:
        case _ _ True{} True{} _: {==}
        case _ _ True{} False{} _: {==}
        case _ True{} False{} _ _: {==}
        case True{} False{} False{} _ 0n: {==}
        case True{} False{} False{} _ 1n+p: {==}
        case False{} False{} False{} _ 0n: {==}
        case False{} False{} False{} _ 1n+p: {==}

def outerRegister(+w: R.World,+body: R.Expr) -> {outer(O.register(w,body)) == outer(w) : R.World}:
  +next = B.schedule(w)
  Equal.trans(R.World,outer(O.register(w,body)),outer(next),outer(w),outerJobs(next,B.append(R.HostJob,R.World.hostJobs(next),[R.MicrotaskCallback{body}])),outerScheduled(w))

def outerHistory(+bodies: List<&2,R.Expr>,+w: R.World) -> {outer(history(bodies,w)) == outer(w) : R.World}:
  match bodies:
    case Nil{}: {==}
    case +body <> +rest:
      Equal.trans(R.World,outer(history(body <> rest,w)),outer(O.register(w,body)),outer(w),outerHistory(rest,O.register(w,body)),outerRegister(w,body))
