# Quantified boundaries for the actual source-following dependency walk.
# Node one may have arbitrary graph/config/status fields; membership wins first.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/deferred-state.bend as D
import ../runtime/constants.bend as K

def noWork(w: R.World, fuel: Nat, lagging: List<&2, Nat>, seen: List<&2, Nat>) -> {D.walk(fuel, w, lagging, [], seen) == B.Bundle{w, 0n} : B.Bundle<R.World, Nat>}:
  match fuel:
    case 0n: {==}
    case 1n+p: {==}

def noLagging(w: R.World, node: Nat) -> {D.laggingOf(w, [], node) == B.Bundle{w, 0n} : B.Bundle<R.World, Nat>}:
  {==}

def exhausted(w: R.World, lagging: List<&2, Nat>, task: D.LagTask, rest: List<&2, D.LagTask>, seen: List<&2, Nat>) -> {D.walk(0n, w, lagging, task <> rest, seen) == B.Bundle{R.World.with_fault(w, R.Exhausted{}), 0n} : B.Bundle<R.World, Nat>}:
  {==}

def direct(w: R.World, tail: List<&2, Nat>, rest: List<&2, D.LagTask>, seen: List<&2, Nat>, fuel: Nat) -> {D.walk(1n+fuel, w, 1n <> tail, D.LagNode{1n} <> rest, seen) == B.Bundle{w, 1n} : B.Bundle<R.World, Nat>}:
  {==}

def membershipBeforeSeen(w: R.World, tail: List<&2, Nat>, rest: List<&2, D.LagTask>, seen: List<&2, Nat>, fuel: Nat) -> {D.walk(1n+fuel, w, 1n <> tail, D.LagNode{1n} <> rest, 1n <> seen) == B.Bundle{w, 1n} : B.Bundle<R.World, Nat>}:
  {==}

def nextAtTail(+w: R.World, +lagging: List<&2, Nat>, +rest: List<&2, D.LagTask>, +seen: List<&2, Nat>, +fuel: Nat) -> {D.walk(1n+fuel, w, lagging, D.LagNext{1n, 1n} <> rest, seen) == D.walk(fuel, w, lagging, rest, seen) : B.Bundle<R.World, Nat>}:
  {==}

def emptyDeps(+w: R.World, +lagging: List<&2, Nat>, +rest: List<&2, D.LagTask>, +seen: List<&2, Nat>, +fuel: Nat, +tail: Nat) -> {D.walk(1n+fuel, w, lagging, D.LagDeps{0n, tail} <> rest, seen) == D.walk(fuel, w, lagging, rest, seen) : B.Bundle<R.World, Nat>}:
  {==}

# Erase only the refusal/fuel result. All other 69 World fields are observable.
def eraseFault(w: R.World) -> R.World:
  R.World.with_fault(w, R.Healthy{})

def faultFrame(+w: R.World, cause: R.Fault) -> {eraseFault(R.World.with_fault(w, cause)) == eraseFault(w) : R.World}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks}:
      {==}

# Choice frame composes independently checked continuation frames.
def frameChoice(+w: R.World, flag: Bool, +left: B.Bundle<R.World, Nat>, +right: B.Bundle<R.World, Nat>, leftFrame: {eraseFault(B.first(R.World, Nat, left)) == eraseFault(w) : R.World}, rightFrame: {eraseFault(B.first(R.World, Nat, right)) == eraseFault(w) : R.World}) -> {eraseFault(B.first(R.World, Nat, B.choose(~B.Bundle<R.World, Nat>, flag, _ => left, _ => right))) == eraseFault(w) : R.World}:
  match flag:
    case True{}: leftFrame
    case False{}: rightFrame

# Arbitrary fuel/work/graphs, including cycles and adapter refusal paths.
def worldFrame(+fuel: Nat, +w: R.World, +lagging: List<&2, Nat>, +work: List<&2, D.LagTask>, +seen: List<&2, Nat>) -> {eraseFault(B.first(R.World, Nat, D.walk(fuel, w, lagging, work, seen))) == eraseFault(w) : R.World}:
  match fuel:
    case 0n:
      match work:
        case Nil{}: {==}
        case task <> rest: faultFrame(w, R.Exhausted{})
    case 1n+ +p:
      match work:
        case Nil{}: {==}
        case D.LagNode{+id} <> +rest:
          frameChoice(w, B.contains(lagging, id), B.Bundle{w, id}, B.choose(~B.Bundle<R.World, Nat>, B.contains(seen, id), _ => D.walk(p, w, lagging, rest, seen), _ => B.choose(~B.Bundle<R.World, Nat>, B.has(R.Node.config(B.node(w, id)), K.CONFIG_SLOT_NODE()), _ => B.Bundle{R.World.with_fault(w, R.Unsupported{86n}), 0n}, _ => B.choose(~B.Bundle<R.World, Nat>, Bool.and(B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_RECOMPUTING_DEPS()), Nat.is_eq(R.Node.depsTail(B.node(w, id)), 0n)), _ => D.walk(p, w, lagging, rest, B.append(Nat, seen, [id])), _ => D.walk(p, w, lagging, D.LagDeps{R.Node.deps(B.node(w, id)), B.choose(~Nat, B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_RECOMPUTING_DEPS()), _ => R.Node.depsTail(B.node(w, id)), _ => 0n)} <> rest, B.append(Nat, seen, [id]))))), {==}, frameChoice(w, B.contains(seen, id), D.walk(p, w, lagging, rest, seen), B.choose(~B.Bundle<R.World, Nat>, B.has(R.Node.config(B.node(w, id)), K.CONFIG_SLOT_NODE()), _ => B.Bundle{R.World.with_fault(w, R.Unsupported{86n}), 0n}, _ => B.choose(~B.Bundle<R.World, Nat>, Bool.and(B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_RECOMPUTING_DEPS()), Nat.is_eq(R.Node.depsTail(B.node(w, id)), 0n)), _ => D.walk(p, w, lagging, rest, B.append(Nat, seen, [id])), _ => D.walk(p, w, lagging, D.LagDeps{R.Node.deps(B.node(w, id)), B.choose(~Nat, B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_RECOMPUTING_DEPS()), _ => R.Node.depsTail(B.node(w, id)), _ => 0n)} <> rest, B.append(Nat, seen, [id])))), worldFrame(p, w, lagging, rest, seen), frameChoice(w, B.has(R.Node.config(B.node(w, id)), K.CONFIG_SLOT_NODE()), B.Bundle{R.World.with_fault(w, R.Unsupported{86n}), 0n}, B.choose(~B.Bundle<R.World, Nat>, Bool.and(B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_RECOMPUTING_DEPS()), Nat.is_eq(R.Node.depsTail(B.node(w, id)), 0n)), _ => D.walk(p, w, lagging, rest, B.append(Nat, seen, [id])), _ => D.walk(p, w, lagging, D.LagDeps{R.Node.deps(B.node(w, id)), B.choose(~Nat, B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_RECOMPUTING_DEPS()), _ => R.Node.depsTail(B.node(w, id)), _ => 0n)} <> rest, B.append(Nat, seen, [id]))), faultFrame(w, R.Unsupported{86n}), frameChoice(w, Bool.and(B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_RECOMPUTING_DEPS()), Nat.is_eq(R.Node.depsTail(B.node(w, id)), 0n)), D.walk(p, w, lagging, rest, B.append(Nat, seen, [id])), D.walk(p, w, lagging, D.LagDeps{R.Node.deps(B.node(w, id)), B.choose(~Nat, B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_RECOMPUTING_DEPS()), _ => R.Node.depsTail(B.node(w, id)), _ => 0n)} <> rest, B.append(Nat, seen, [id])), worldFrame(p, w, lagging, rest, B.append(Nat, seen, [id])), worldFrame(p, w, lagging, D.LagDeps{R.Node.deps(B.node(w, id)), B.choose(~Nat, B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_RECOMPUTING_DEPS()), _ => R.Node.depsTail(B.node(w, id)), _ => 0n)} <> rest, B.append(Nat, seen, [id]))))))
        case D.LagDeps{+edge, +tail} <> +rest:
          frameChoice(w, Nat.is_eq(edge, 0n), D.walk(p, w, lagging, rest, seen), D.walk(p, w, lagging, D.LagNode{R.Link.dep(B.link(w, edge))} <> D.LagNext{edge, tail} <> rest, seen), worldFrame(p, w, lagging, rest, seen), worldFrame(p, w, lagging, D.LagNode{R.Link.dep(B.link(w, edge))} <> D.LagNext{edge, tail} <> rest, seen))
        case D.LagNext{+edge, +tail} <> +rest:
          frameChoice(w, Nat.is_eq(edge, tail), D.walk(p, w, lagging, rest, seen), D.walk(p, w, lagging, D.LagDeps{R.Link.nextDep(B.link(w, edge)), tail} <> rest, seen), worldFrame(p, w, lagging, rest, seen), worldFrame(p, w, lagging, D.LagDeps{R.Link.nextDep(B.link(w, edge)), tail} <> rest, seen))
