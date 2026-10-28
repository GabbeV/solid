# Proof-only canonical source-cache view; this is not a runtime transition.
# Congruence transports a virtual input certificate across actual preparation.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./held-source-cache-rebase.bend as Cache
import ./held-source-view.bend as V
import ./held-hold-view.bend as H
import ./held-preparation-source.bend as Source

def canonical(+view: V.View,+id: Nat,root: Nat) -> V.View:
  H.storeExtension(view,id,R.NodeExtension.with_transaction(H.extension(view,id),root))

def observed(+w: R.World,+id: Nat,+root: Nat) -> {V.observe(Cache.canonical(w,id,root)) == canonical(V.observe(w),id,root) : V.View}:
  Equal.trans(V.View,V.observe(Cache.canonical(w,id,root)),H.storeExtension(V.observe(w),id,R.NodeExtension.with_transaction(B.extension(w,id),root)),canonical(V.observe(w),id,root),H.extensionStoreObserved(w,id,R.NodeExtension.with_transaction(B.extension(w,id),root)),Equal.cong(R.NodeExtension,V.View,record=>H.storeExtension(V.observe(w),id,R.NodeExtension.with_transaction(record,root)),B.extension(w,id),H.extension(V.observe(w),id),H.extensionObserved(w,id)))

def same(+w: R.World,+next: R.World,+id: Nat,+root: Nat,equal: {V.observe(next) == V.observe(w) : V.View}) -> {V.observe(Cache.canonical(next,id,root)) == V.observe(Cache.canonical(w,id,root)) : V.View}:
  Equal.trans(V.View,V.observe(Cache.canonical(next,id,root)),canonical(V.observe(next),id,root),V.observe(Cache.canonical(w,id,root)),observed(next,id,root),Equal.trans(V.View,canonical(V.observe(next),id,root),canonical(V.observe(w),id,root),V.observe(Cache.canonical(w,id,root)),Equal.cong(V.View,V.View,view=>canonical(view,id,root),V.observe(next),V.observe(w),equal),Equal.sym(V.View,V.observe(Cache.canonical(w,id,root)),canonical(V.observe(w),id,root),observed(w,id,root))))

def flush(+w: R.World,+id: Nat,+root: Nat,+future: Nat) -> {Cache.canonical(Source.flush(w,future),id,root) == Source.flush(Cache.canonical(w,id,root),future) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}
