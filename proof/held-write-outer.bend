# Ordinary staging's ten mutable control fields plus this source extension's
# flushed/flushedAt only. Fault, txArena, actions, waits and all other extension
# contents remain visible. This frame is not a successful-write or reveal claim.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./ordinary-write-outer.bend as Outer
import ./held-stash-frame.bend as Stash

def observe(w: R.World,slot: Nat) -> R.World:
  Stash.observe(Outer.observe(w),slot)

def commute(+w: R.World,+slot: Nat) -> {Outer.observe(Stash.observe(w,slot)) == observe(w,slot) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def fromOuter(+w: R.World,+next: R.World,+slot: Nat,same: {Outer.observe(next) == Outer.observe(w) : R.World}) -> {observe(next,slot) == observe(w,slot) : R.World}:
  Equal.cong(R.World,R.World,state=>Stash.observe(state,slot),Outer.observe(next),Outer.observe(w),same)

def fromStash(+w: R.World,+next: R.World,+slot: Nat,same: {Stash.observe(next,slot) == Stash.observe(w,slot) : R.World}) -> {observe(next,slot) == observe(w,slot) : R.World}:
  Equal.trans(R.World,observe(next,slot),Outer.observe(Stash.observe(next,slot)),observe(w,slot),Equal.sym(R.World,Outer.observe(Stash.observe(next,slot)),observe(next,slot),commute(next,slot)),Equal.trans(R.World,Outer.observe(Stash.observe(next,slot)),Outer.observe(Stash.observe(w,slot)),observe(w,slot),Equal.cong(R.World,R.World,state=>Outer.observe(state),Stash.observe(next,slot),Stash.observe(w,slot),same),commute(w,slot)))

def compose(+a: R.World,+b: R.World,+c: R.World,+slot: Nat,last: {observe(c,slot) == observe(b,slot) : R.World},first: {observe(b,slot) == observe(a,slot) : R.World}) -> {observe(c,slot) == observe(a,slot) : R.World}:
  Equal.trans(R.World,observe(c,slot),observe(b,slot),observe(a,slot),last,first)

def choice(+flag: Bool,+w: R.World,+yes: R.World,+no: R.World,+slot: Nat,left: {observe(yes,slot) == observe(w,slot) : R.World},right: {observe(no,slot) == observe(w,slot) : R.World}) -> {observe(B.choose(~R.World,flag,_=>yes,_=>no),slot) == observe(w,slot) : R.World}:
  match flag:
    case True{}: left
    case False{}: right

def readFault(+w: R.World,+slot: Nat) -> {R.World.fault(observe(w,slot)) == R.World.fault(w) : R.Fault}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def sameFault(+w: R.World,+next: R.World,+slot: Nat,same: {observe(next,slot) == observe(w,slot) : R.World}) -> {R.World.fault(next) == R.World.fault(w) : R.Fault}:
  Equal.trans(R.Fault,R.World.fault(next),R.World.fault(observe(next,slot)),R.World.fault(w),Equal.sym(R.Fault,R.World.fault(observe(next,slot)),R.World.fault(next),readFault(next,slot)),Equal.trans(R.Fault,R.World.fault(observe(next,slot)),R.World.fault(observe(w,slot)),R.World.fault(w),Equal.cong(R.World,R.Fault,state=>R.World.fault(state),observe(next,slot),observe(w,slot),same),readFault(w,slot)))

def readMarked(+w: R.World,+slot: Nat) -> {R.World.marked(observe(w,slot)) == R.World.marked(w) : Bool}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def sameMarked(+w: R.World,+next: R.World,+slot: Nat,same: {observe(next,slot) == observe(w,slot) : R.World}) -> {R.World.marked(next) == R.World.marked(w) : Bool}:
  Equal.trans(Bool,R.World.marked(next),R.World.marked(observe(next,slot)),R.World.marked(w),Equal.sym(Bool,R.World.marked(observe(next,slot)),R.World.marked(next),readMarked(next,slot)),Equal.trans(Bool,R.World.marked(observe(next,slot)),R.World.marked(observe(w,slot)),R.World.marked(w),Equal.cong(R.World,Bool,state=>R.World.marked(state),observe(next,slot),observe(w,slot),same),readMarked(w,slot)))

def readLinks(+w: R.World,+slot: Nat) -> {R.World.links(observe(w,slot)) == R.World.links(w) : List<&2,R.Link>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def sameLinks(+w: R.World,+next: R.World,+slot: Nat,same: {observe(next,slot) == observe(w,slot) : R.World}) -> {R.World.links(next) == R.World.links(w) : List<&2,R.Link>}:
  Equal.trans(List<&2,R.Link>,R.World.links(next),R.World.links(observe(next,slot)),R.World.links(w),Equal.sym(List<&2,R.Link>,R.World.links(observe(next,slot)),R.World.links(next),readLinks(next,slot)),Equal.trans(List<&2,R.Link>,R.World.links(observe(next,slot)),R.World.links(observe(w,slot)),R.World.links(w),Equal.cong(R.World,List<&2,R.Link>,state=>R.World.links(state),observe(next,slot),observe(w,slot),same),readLinks(w,slot)))

def readContext(+w: R.World,+slot: Nat) -> {R.World.context(observe(w,slot)) == R.World.context(w) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def sameContext(+w: R.World,+next: R.World,+slot: Nat,same: {observe(next,slot) == observe(w,slot) : R.World}) -> {R.World.context(next) == R.World.context(w) : Nat}:
  Equal.trans(Nat,R.World.context(next),R.World.context(observe(next,slot)),R.World.context(w),Equal.sym(Nat,R.World.context(observe(next,slot)),R.World.context(next),readContext(next,slot)),Equal.trans(Nat,R.World.context(observe(next,slot)),R.World.context(observe(w,slot)),R.World.context(w),Equal.cong(R.World,Nat,state=>R.World.context(state),observe(next,slot),observe(w,slot),same),readContext(w,slot)))

def readTxArena(+w: R.World,+slot: Nat) -> {R.World.txArena(observe(w,slot)) == R.World.txArena(w) : List<&2,R.Transaction>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def sameTxArena(+w: R.World,+next: R.World,+slot: Nat,same: {observe(next,slot) == observe(w,slot) : R.World}) -> {R.World.txArena(next) == R.World.txArena(w) : List<&2,R.Transaction>}:
  Equal.trans(List<&2,R.Transaction>,R.World.txArena(next),R.World.txArena(observe(next,slot)),R.World.txArena(w),Equal.sym(List<&2,R.Transaction>,R.World.txArena(observe(next,slot)),R.World.txArena(next),readTxArena(next,slot)),Equal.trans(List<&2,R.Transaction>,R.World.txArena(observe(next,slot)),R.World.txArena(observe(w,slot)),R.World.txArena(w),Equal.cong(R.World,List<&2,R.Transaction>,state=>R.World.txArena(state),observe(next,slot),observe(w,slot),same),readTxArena(w,slot)))

def readActions(+w: R.World,+slot: Nat) -> {R.World.actions(observe(w,slot)) == R.World.actions(w) : List<&2,R.ActionState>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def sameActions(+w: R.World,+next: R.World,+slot: Nat,same: {observe(next,slot) == observe(w,slot) : R.World}) -> {R.World.actions(next) == R.World.actions(w) : List<&2,R.ActionState>}:
  Equal.trans(List<&2,R.ActionState>,R.World.actions(next),R.World.actions(observe(next,slot)),R.World.actions(w),Equal.sym(List<&2,R.ActionState>,R.World.actions(observe(next,slot)),R.World.actions(next),readActions(next,slot)),Equal.trans(List<&2,R.ActionState>,R.World.actions(observe(next,slot)),R.World.actions(observe(w,slot)),R.World.actions(w),Equal.cong(R.World,List<&2,R.ActionState>,state=>R.World.actions(state),observe(next,slot),observe(w,slot),same),readActions(w,slot)))

def readActionWaits(+w: R.World,+slot: Nat) -> {R.World.actionWaits(observe(w,slot)) == R.World.actionWaits(w) : List<&2,R.ActionWait>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def sameActionWaits(+w: R.World,+next: R.World,+slot: Nat,same: {observe(next,slot) == observe(w,slot) : R.World}) -> {R.World.actionWaits(next) == R.World.actionWaits(w) : List<&2,R.ActionWait>}:
  Equal.trans(List<&2,R.ActionWait>,R.World.actionWaits(next),R.World.actionWaits(observe(next,slot)),R.World.actionWaits(w),Equal.sym(List<&2,R.ActionWait>,R.World.actionWaits(observe(next,slot)),R.World.actionWaits(next),readActionWaits(next,slot)),Equal.trans(List<&2,R.ActionWait>,R.World.actionWaits(observe(next,slot)),R.World.actionWaits(observe(w,slot)),R.World.actionWaits(w),Equal.cong(R.World,List<&2,R.ActionWait>,state=>R.World.actionWaits(state),observe(next,slot),observe(w,slot),same),readActionWaits(w,slot)))

def readComparators(+w: R.World,+slot: Nat) -> {R.World.comparators(observe(w,slot)) == R.World.comparators(w) : List<&2,R.ComparatorBinding>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def sameComparators(+w: R.World,+next: R.World,+slot: Nat,same: {observe(next,slot) == observe(w,slot) : R.World}) -> {R.World.comparators(next) == R.World.comparators(w) : List<&2,R.ComparatorBinding>}:
  Equal.trans(List<&2,R.ComparatorBinding>,R.World.comparators(next),R.World.comparators(observe(next,slot)),R.World.comparators(w),Equal.sym(List<&2,R.ComparatorBinding>,R.World.comparators(observe(next,slot)),R.World.comparators(next),readComparators(next,slot)),Equal.trans(List<&2,R.ComparatorBinding>,R.World.comparators(observe(next,slot)),R.World.comparators(observe(w,slot)),R.World.comparators(w),Equal.cong(R.World,List<&2,R.ComparatorBinding>,state=>R.World.comparators(state),observe(next,slot),observe(w,slot),same),readComparators(w,slot)))

def readClock(+w: R.World,+slot: Nat) -> {R.World.clock(observe(w,slot)) == R.World.clock(w) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def sameClock(+w: R.World,+next: R.World,+slot: Nat,same: {observe(next,slot) == observe(w,slot) : R.World}) -> {R.World.clock(next) == R.World.clock(w) : Nat}:
  Equal.trans(Nat,R.World.clock(next),R.World.clock(observe(next,slot)),R.World.clock(w),Equal.sym(Nat,R.World.clock(observe(next,slot)),R.World.clock(next),readClock(next,slot)),Equal.trans(Nat,R.World.clock(observe(next,slot)),R.World.clock(observe(w,slot)),R.World.clock(w),Equal.cong(R.World,Nat,state=>R.World.clock(state),observe(next,slot),observe(w,slot),same),readClock(w,slot)))
