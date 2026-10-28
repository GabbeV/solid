# A childless staged frame executes the source walk without changing World.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ../proof/list-update-lookup.bend as Logic

def zeroChild(+w: R.World,+tx: Nat,+fuel: Nat) -> {X.holdRun(1n+fuel,w,[X.HoldChild{0n,tx}]) == w : R.World}:
  match fuel:
    case 0n: {==}
    case 1n+p: {==}

def walk(+fuel: Nat,+w: R.World,+id: Nat,+tx: Nat,child: {R.Node.firstChild(B.node(w,id)) == 0n : Nat},nonzero: {Nat.is_eq(fuel,0n) == False{} : Bool}) -> {X.holdRun(fuel,w,[X.HoldChild{R.Node.firstChild(B.node(w,id)),tx}]) == w : R.World}:
  match fuel:
    case 0n:
      Empty.absurd({X.holdRun(0n,w,[X.HoldChild{R.Node.firstChild(B.node(w,id)),tx}]) == w : R.World},Logic.impossible(nonzero))
    case 1n+p:
      Equal.trans(R.World,X.holdRun(1n+p,w,[X.HoldChild{R.Node.firstChild(B.node(w,id)),tx}]),X.holdRun(1n+p,w,[X.HoldChild{0n,tx}]),w,Equal.cong(Nat,R.World,first=>X.holdRun(1n+p,w,[X.HoldChild{first,tx}]),R.Node.firstChild(B.node(w,id)),0n,child),zeroChild(w,tx,p))

def positiveFuel(+w: R.World,nonempty: {List.is_empty(&2,R.Node,R.World.nodes(w)) == False{} : Bool}) -> {Nat.is_eq(Nat.mul(4n,B.budget(w)),0n) == False{} : Bool}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match nodes:
        case Nil{}:
          Empty.absurd({Nat.is_eq(Nat.mul(4n,B.budget(w)),0n) == False{} : Bool},Logic.impossible(nonempty))
        case head <> tail: {==}

def leaf(+w: R.World,+id: Nat,+tx: Nat,child: {R.Node.firstChild(B.node(w,id)) == 0n : Nat},nonempty: {List.is_empty(&2,R.Node,R.World.nodes(w)) == False{} : Bool}) -> {X.holdFrame(w,id,tx) == w : R.World}:
  walk(Nat.mul(4n,B.budget(w)),w,id,tx,child,positiveFuel(w,nonempty))
