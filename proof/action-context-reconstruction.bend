# Four callback tables may vary while the complete outer construction survives.
# Restoring those fields is a proof-side record lens, never a runtime transition.
import Base
import ../representation/records.bend as R
import ./action-helper-context.bend as Context

def restore(w: R.World,+source: R.World) -> R.World:
  R.World.with_actionWaits(R.World.with_asyncObservers(R.World.with_asyncObjects(R.World.with_hostJobs(w,R.World.hostJobs(source)),R.World.asyncObjects(source)),R.World.asyncObservers(source)),R.World.actionWaits(source))

def recover(+w: R.World) -> {restore(Context.erase(w),w) == w : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def eraseRestore(+w: R.World,+source: R.World) -> {Context.erase(restore(w,source)) == Context.erase(w) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def shape(+w: R.World,+model: R.World,known: {Context.erase(w) == Context.erase(model) : R.World}) -> {w == restore(Context.erase(model),w) : R.World}:
  Equal.trans(R.World,w,restore(Context.erase(w),w),restore(Context.erase(model),w),Equal.sym(R.World,restore(Context.erase(w),w),w,recover(w)),Equal.cong(R.World,R.World,base=>restore(base,w),Context.erase(w),Context.erase(model),known))
