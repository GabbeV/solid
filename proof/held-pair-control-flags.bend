# Actual second controller allocation/opening and distinct merge preserve
# caller action-depth/running/halted flags. Ready supplies real distinct roots.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ./held-first-ready.bend as Ready
import ./held-pair-generic-state.bend as State
import ./held-pair-generic-join.bend as Join
import ./transaction-merge-frame.bend as Merge
import ./action-control-flags.bend as Flags

def created(+w: R.World,+methods: R.Expr) -> {Flags.observe(B.first(R.World,Nat,A.create(w,methods))) == Flags.observe(w) : Flags.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def opened(+w: R.World,+actor: Nat) -> {Flags.observe(A.open(w,actor)) == Flags.observe(w) : Flags.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def secondController(+w: R.World,+methods: R.Expr) -> {Flags.observe(State.opened(w,methods)) == Flags.observe(w) : Flags.View}:
  +pair = A.create(w,methods)
  +next = B.first(R.World,Nat,pair)
  Equal.trans(Flags.View,Flags.observe(State.opened(w,methods)),Flags.observe(next),Flags.observe(w),opened(next,B.second(R.World,Nat,pair)),created(w,methods))

def masked(+w: R.World) -> {Flags.observe(Merge.observe(w)) == Flags.observe(w) : Flags.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def fromMerge(+before: R.World,+next: R.World,same: {Merge.observe(next) == Merge.observe(before) : R.World}) -> {Flags.observe(next) == Flags.observe(before) : Flags.View}:
  Equal.trans(Flags.View,Flags.observe(next),Flags.observe(Merge.observe(next)),Flags.observe(before),Equal.sym(Flags.View,Flags.observe(Merge.observe(next)),Flags.observe(next),masked(next)),Equal.trans(Flags.View,Flags.observe(Merge.observe(next)),Flags.observe(Merge.observe(before)),Flags.observe(before),Equal.cong(R.World,Flags.View,w=>Flags.observe(w),Merge.observe(next),Merge.observe(before),same),masked(before)))

def joined(+seed: R.World,+id: Nat,+first: R.Expr,+second: R.Expr,+reverse: Bool,+ready: Ready.Ready<seed,id,first>) -> {Flags.observe(State.joined(seed,second,reverse)) == Flags.observe(seed) : Flags.View}:
  Equal.trans(Flags.View,Flags.observe(State.joined(seed,second,reverse)),Flags.observe(State.opened(seed,second)),Flags.observe(seed),fromMerge(State.opened(seed,second),State.joined(seed,second,reverse),Join.frame(seed,id,first,second,reverse,ready)),secondController(seed,second))
