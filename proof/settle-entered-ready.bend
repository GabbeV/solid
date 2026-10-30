# Initial admission survives the actual capture-clear/judged-prefix stores.
# No fresh post-state certificate is supplied by callers.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../proof/parkable-leaf.bend as Leaf
import ../proof/held-park-leaf.bend as Allocated
import ../proof/fresh-render-parking.bend as Fresh
import ../proof/mixed-settle.bend as Mixed
import ../proof/committed-storage-frame.bend as Content
import ./settle-entry.bend as Entry

def leaf(+w: R.World,+id: Nat,+offset: Nat,ready: Leaf.Ready<w,id,offset>) -> Leaf.Ready<Entry.entered(w),id,offset>:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match laneState:
        case R.LaneState{+laneLive,+groups,+stagedReaders,+pendingGuesses,+judged,+root,+enteredReaders,+guessing,+guessed,+kept,+reverted,+reverting, +revealing}:
          match ready:
            case Leaf.Allocated{initial}:
              match initial:
                case Allocated.LeafAt{slot,valid,allocated,extensionRoom,groupRoom,unowned,child,eligible,pending,custom,equals}:
                  Leaf.Allocated{Allocated.LeafAt{slot,valid,allocated,extensionRoom,groupRoom,unowned,child,eligible,pending,custom,equals}}
            case Leaf.UnreadyRender{initial}:
              match initial:
                case Fresh.FreshRender{valid,fresh,child,eligible,rendered,absent}:
                  Leaf.UnreadyRender{Fresh.FreshRender{valid,fresh,child,eligible,rendered,absent}}

def mixed(+w: R.World,+source: Nat,+reader: Nat,+offset: Nat,ready: Mixed.Ready<w,source,reader,offset>) -> Mixed.Ready<Entry.entered(w),source,reader,offset>:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match laneState:
        case R.LaneState{+laneLive,+groups,+stagedReaders,+pendingGuesses,+judged,+root,+enteredReaders,+guessing,+guessed,+kept,+reverted,+reverting, +revealing}:
          match ready:
            case Mixed.SourceReader{pending,held,unstaged,initial,healthy,comparators,lane,terminal,zombies,quiet}:
              Mixed.SourceReader{pending,held,unstaged,leaf(w,reader,offset,initial),healthy,comparators,lane,terminal,zombies,quiet}

def committed(+w: R.World) -> {Content.observe(Entry.entered(w)) == Content.observe(w) : Content.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match laneState:
        case R.LaneState{+laneLive,+groups,+stagedReaders,+pendingGuesses,+judged,+root,+enteredReaders,+guessing,+guessed,+kept,+reverted,+reverting, +revealing}:
          {==}

def live(+w: R.World) -> {R.World.transactions(Entry.entered(w)) == R.World.transactions(w) : List<&2,Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match laneState:
        case R.LaneState{+laneLive,+groups,+stagedReaders,+pendingGuesses,+judged,+root,+enteredReaders,+guessing,+guessed,+kept,+reverted,+reverting, +revealing}:
          {==}

def count(+w: R.World,tx: Nat) -> {R.Transaction.open(B.transaction(Entry.entered(w),tx)) == R.Transaction.open(B.transaction(w,tx)) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match laneState:
        case R.LaneState{+laneLive,+groups,+stagedReaders,+pendingGuesses,+judged,+root,+enteredReaders,+guessing,+guessed,+kept,+reverted,+reverting, +revealing}:
          {==}
