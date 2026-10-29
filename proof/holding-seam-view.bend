# Settlement-hook facts read from the exact non-arena holding frame.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ../proof/settle-lane-empty.bend as Lane
import ./holding-outer.bend as Outer

type View is Data:
  Conditions{health: Bool,live: List<&2,Nat>,zombies: List<&2,Nat>,quiet: Bool}

def observe(+w: R.World) -> View:
  Conditions{B.ok(w),R.World.transactions(w),R.World.deferredZombies(w),Lane.quiet(w)}

def health(view: View) -> Bool:
  match view:
    case Conditions{health,live,zombies,quiet}: health

def live(view: View) -> List<&2,Nat>:
  match view:
    case Conditions{health,live,zombies,quiet}: live

def zombies(view: View) -> List<&2,Nat>:
  match view:
    case Conditions{health,live,zombies,quiet}: zombies

def quiet(view: View) -> Bool:
  match view:
    case Conditions{health,live,zombies,quiet}: quiet

def masked(+w: R.World) -> {observe(Outer.observe(w)) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def fromOuter(+w: R.World,+next: R.World,same: {Outer.observe(next) == Outer.observe(w) : R.World}) -> {observe(next) == observe(w) : View}:
  Equal.trans(View,observe(next),observe(Outer.observe(next)),observe(w),Equal.sym(View,observe(Outer.observe(next)),observe(next),masked(next)),Equal.trans(View,observe(Outer.observe(next)),observe(Outer.observe(w)),observe(w),Equal.cong(R.World,View,state=>observe(state),Outer.observe(next),Outer.observe(w),same),masked(w)))

def node(+w: R.World,+id: Nat,+tx: Nat) -> {observe(X.holdNode(w,id,tx)) == observe(w) : View}:
  fromOuter(w,X.holdNode(w,id,tx),Outer.node(w,id,tx))

def nodeHealth(+w: R.World,+id: Nat,+tx: Nat) -> {B.ok(X.holdNode(w,id,tx)) == B.ok(w) : Bool}:
  Equal.cong(View,Bool,view=>health(view),observe(X.holdNode(w,id,tx)),observe(w),node(w,id,tx))

def nodeLive(+w: R.World,+id: Nat,+tx: Nat) -> {R.World.transactions(X.holdNode(w,id,tx)) == R.World.transactions(w) : List<&2,Nat>}:
  Equal.cong(View,List<&2,Nat>,view=>live(view),observe(X.holdNode(w,id,tx)),observe(w),node(w,id,tx))

def nodeZombies(+w: R.World,+id: Nat,+tx: Nat) -> {R.World.deferredZombies(X.holdNode(w,id,tx)) == R.World.deferredZombies(w) : List<&2,Nat>}:
  Equal.cong(View,List<&2,Nat>,view=>zombies(view),observe(X.holdNode(w,id,tx)),observe(w),node(w,id,tx))

def nodeQuiet(+w: R.World,+id: Nat,+tx: Nat) -> {Lane.quiet(X.holdNode(w,id,tx)) == Lane.quiet(w) : Bool}:
  Equal.cong(View,Bool,view=>quiet(view),observe(X.holdNode(w,id,tx)),observe(w),node(w,id,tx))
