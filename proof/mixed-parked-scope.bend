# Derive the post-scan queue/continuation obligations from the initial mixed
# admission, actual entry/holding and existing metadata/settlement frames.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../proof/mixed-settle.bend as Mixed
import ../proof/mixed-settle-scan.bend as Scan
import ../proof/held-settle-frame.bend as Frame
import ../proof/holding-outer.bend as Outer
import ../proof/holding-seam-view.bend as Hold
import ../proof/transaction-membership-frame.bend as Meta
import ../proof/natural-logic.bend as Logic
import ./settle-entry.bend as Entry
import ./settle-entered-ready.bend as Ready

def world(w: R.World,reader: Nat,offset: Nat) -> R.World:
  Frame.world(Mixed.held(Entry.entered(w),reader,offset))

type Controls is Data:
  Controls{heap: Bool,ambient: Bool,cleanup: R.Slot}

def observe(+w: R.World) -> Controls:
  Controls{Nat.is_ge(R.World.maximum(w),R.World.minimum(w)),List.is_empty(&2,Nat,R.World.ambientMarks(w)),R.World.cleanupError(w)}

def heap(controls: Controls) -> Bool:
  match controls:
    case Controls{heap,ambient,cleanup}: heap

def ambient(controls: Controls) -> Bool:
  match controls:
    case Controls{heap,ambient,cleanup}: ambient

def cleanup(controls: Controls) -> R.Slot:
  match controls:
    case Controls{heap,ambient,cleanup}: cleanup

def masked(+w: R.World) -> {observe(Outer.observe(w)) == observe(w) : Controls}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def holding(+w: R.World,+reader: Nat,+tx: Nat) -> {observe(Mixed.held(w,reader,tx)) == observe(w) : Controls}:
  +next = Mixed.held(w,reader,tx)
  Equal.trans(Controls,observe(next),observe(Outer.observe(next)),observe(w),Equal.sym(Controls,observe(Outer.observe(next)),observe(next),masked(next)),Equal.trans(Controls,observe(Outer.observe(next)),observe(Outer.observe(w)),observe(w),Equal.cong(R.World,Controls,state=>observe(state),Outer.observe(next),Outer.observe(w),Outer.node(w,reader,1n+tx)),masked(w)))

def entry(+w: R.World) -> {observe(Entry.entered(w)) == observe(w) : Controls}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def prepared(+w: R.World) -> {observe(Frame.world(w)) == observe(w) : Controls}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match trims:
        case Nil{}: {==}
        case first <> tail: {==}

def controls(+w: R.World,+reader: Nat,+offset: Nat) -> {observe(world(w,reader,offset)) == observe(w) : Controls}:
  Equal.trans(Controls,observe(world(w,reader,offset)),observe(Mixed.held(Entry.entered(w),reader,offset)),observe(w),prepared(Mixed.held(Entry.entered(w),reader,offset)),Equal.trans(Controls,observe(Mixed.held(Entry.entered(w),reader,offset)),observe(Entry.entered(w)),observe(w),holding(Entry.entered(w),reader,offset),entry(w)))

type Queues is Data:
  Queues{pending: List<&2,Nat>,renders: List<&2,Nat>,users: List<&2,R.QueueEntry>,zombies: List<&2,Nat>}

def queues(+w: R.World) -> Queues:
  Queues{R.World.pendingNodes(w),R.World.renderQueue(w),R.World.userQueue(w),R.World.deferredZombies(w)}

def emptyQueues(+w: R.World) -> {queues(Frame.world(w)) == Queues{[],[],[],[]} : Queues}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match trims:
        case Nil{}: {==}
        case first <> tail: {==}

def arena(+w: R.World) -> {R.World.txArena(Entry.entered(w)) == R.World.txArena(w) : List<&2,R.Transaction>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def metadata(+w: R.World,+reader: Nat,+offset: Nat) -> {Meta.observe(world(w,reader,offset)) == Meta.observe(w) : List<&2,R.Transaction>}:
  +next = Entry.entered(w)
  +held = Mixed.held(next,reader,offset)
  Equal.trans(List<&2,R.Transaction>,Meta.observe(world(w,reader,offset)),Meta.observe(held),Meta.observe(w),Equal.cong(List<&2,R.Transaction>,List<&2,R.Transaction>,rows=>Meta.rows(rows),R.World.txArena(world(w,reader,offset)),R.World.txArena(held),Frame.arena(held)),Equal.trans(List<&2,R.Transaction>,Meta.observe(held),Meta.observe(next),Meta.observe(w),Meta.node(next,reader,1n+offset),Equal.cong(List<&2,R.Transaction>,List<&2,R.Transaction>,rows=>Meta.rows(rows),R.World.txArena(next),R.World.txArena(w),arena(w))))

def intoMasked(+tx: R.Transaction) -> {R.Transaction.into(Meta.mask(tx)) == R.Transaction.into(tx) : Nat}:
  match tx:
    case R.Transaction{nodes,renders,users,reruns,into,parent,lane,links,open,acted,frame,shown,held,marks}: {==}

def terminal(+w: R.World,+source: Nat,+reader: Nat,+offset: Nat,ready: Mixed.Ready<w,source,reader,offset>) -> {R.Transaction.into(B.transaction(world(w,reader,offset),1n+offset)) == 0n : Nat}:
  match ready:
    case Mixed.SourceReader{pending,held,unstaged,leaf,healthy,comparators,lane,stopped,zombies,quiet}:
      +next = world(w,reader,offset)
      +tx = {1n+offset : Nat}
      Equal.trans(Nat,R.Transaction.into(B.transaction(next,tx)),R.Transaction.into(Meta.mask(B.transaction(next,tx))),0n,Equal.sym(Nat,R.Transaction.into(Meta.mask(B.transaction(next,tx))),R.Transaction.into(B.transaction(next,tx)),intoMasked(B.transaction(next,tx))),Equal.trans(Nat,R.Transaction.into(Meta.mask(B.transaction(next,tx))),R.Transaction.into(Meta.mask(B.transaction(w,tx))),0n,Equal.cong(R.Transaction,Nat,t=>R.Transaction.into(t),Meta.mask(B.transaction(next,tx)),Meta.mask(B.transaction(w,tx)),Meta.read(w,next,tx,metadata(w,reader,offset))),Equal.trans(Nat,R.Transaction.into(Meta.mask(B.transaction(w,tx))),R.Transaction.into(B.transaction(w,tx)),0n,intoMasked(B.transaction(w,tx)),stopped)))

def live(+w: R.World,+reader: Nat,+offset: Nat) -> {R.World.transactions(world(w,reader,offset)) == R.World.transactions(w) : List<&2,Nat>}:
  +next = Entry.entered(w)
  +held = Mixed.held(next,reader,offset)
  Equal.trans(List<&2,Nat>,R.World.transactions(world(w,reader,offset)),R.World.transactions(held),R.World.transactions(w),Frame.live(held),Equal.trans(List<&2,Nat>,R.World.transactions(held),R.World.transactions(next),R.World.transactions(w),Hold.nodeLive(next,reader,1n+offset),Ready.live(w)))

def member(+w: R.World,+reader: Nat,+offset: Nat,known: {R.World.transactions(w) == [1n+offset] : List<&2,Nat>}) -> {B.contains(R.World.transactions(world(w,reader,offset)),1n+offset) == True{} : Bool}:
  +same = Equal.trans(List<&2,Nat>,R.World.transactions(world(w,reader,offset)),R.World.transactions(w),[1n+offset],live(w,reader,offset),known)
  Equal.trans(Bool,B.contains(R.World.transactions(world(w,reader,offset)),1n+offset),B.contains([1n+offset],1n+offset),True{},Equal.cong(List<&2,Nat>,Bool,rows=>B.contains(rows,1n+offset),R.World.transactions(world(w,reader,offset)),[1n+offset],same),Equal.cong(Bool,Bool,yes=>Bool.or(yes,False{}),Nat.is_eq(1n+offset,1n+offset),True{},Logic.self(1n+offset)))

def health(+w: R.World,+source: Nat,+reader: Nat,+offset: Nat,ready: Mixed.Ready<w,source,reader,offset>) -> {B.ok(world(w,reader,offset)) == True{} : Bool}:
  +next = Entry.entered(w)
  +held = Mixed.held(next,reader,offset)
  Equal.trans(Bool,B.ok(world(w,reader,offset)),B.ok(held),True{},Frame.health(held),Equal.trans(Bool,B.ok(held),B.ok(next),True{},Hold.nodeHealth(next,reader,1n+offset),Scan.health(next,source,reader,offset,Ready.mixed(w,source,reader,offset,ready))))

def pending(queues: Queues) -> List<&2,Nat>:
  match queues:
    case Queues{pending,renders,users,zombies}: pending

def renders(queues: Queues) -> List<&2,Nat>:
  match queues:
    case Queues{pending,renders,users,zombies}: renders

def users(queues: Queues) -> List<&2,R.QueueEntry>:
  match queues:
    case Queues{pending,renders,users,zombies}: users

def zombies(queues: Queues) -> List<&2,Nat>:
  match queues:
    case Queues{pending,renders,users,zombies}: zombies

def count(+w: R.World,+reader: Nat,+offset: Nat,+id: Nat) -> {R.Transaction.open(B.transaction(world(w,reader,offset),id)) == R.Transaction.open(B.transaction(w,id)) : Nat}:
  Meta.count(w,world(w,reader,offset),id,metadata(w,reader,offset))
