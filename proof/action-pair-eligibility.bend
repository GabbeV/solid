# A zero-action, empty ordinary pair reports the source revelation delay
# once no nested lanes remain. Arbitrary initial delay lists are retained.
# This is actual blocked eligibility, not a renderer publication theorem.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ./transaction-pair.bend as Pair
import ./transaction-count-pair.bend as Count
import ./transaction-empty.bend as Empty
import ./action-pair-completion.bend as Complete
import ./action-pair.bend as Actions
import ./action-blocker.bend as Blocker
import ./action-opening.bend as Opening
import ./transaction-joined-history.bend as History

type Ambient is Data:
  Ambient{healthy: Bool, live: List<&2, Nat>}

def ambient(+w: R.World) -> Ambient:
  Ambient{B.ok(w), R.LaneState.live(R.World.laneState(w))}

def healthy(value: Ambient) -> Bool:
  match value:
    case Ambient{ok, live}: ok

def live(value: Ambient) -> List<&2, Nat>:
  match value:
    case Ambient{ok, values}: values

def retiredAmbient(+w: R.World, +source: Nat) -> {ambient(Pair.retire(w, source)) == ambient(w) : Ambient}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def countedAmbient(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, +count: Nat) ->
  {ambient(Count.state(w, before, reverse, count)) == ambient(w) : Ambient}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def scheduledAmbient(+w: R.World) -> {ambient(B.schedule(w)) == ambient(w) : Ambient}:
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

def expected(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool) -> R.World:
  Count.state(B.schedule(B.schedule(Pair.retire(w, Pair.sourceId(before, [], reverse)))), before, reverse, 0n)

def finalAmbient(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool) ->
  {ambient(expected(w, before, reverse)) == ambient(w) : Ambient}:
  +retired = Pair.retire(w, Pair.sourceId(before, [], reverse))
  Equal.trans(Ambient, ambient(expected(w, before, reverse)), ambient(B.schedule(B.schedule(retired))), ambient(w), countedAmbient(B.schedule(B.schedule(retired)), before, reverse, 0n),
    Equal.trans(Ambient, ambient(B.schedule(B.schedule(retired))), ambient(B.schedule(retired)), ambient(w), scheduledAmbient(B.schedule(retired)),
      Equal.trans(Ambient, ambient(B.schedule(retired)), ambient(retired), ambient(w), scheduledAmbient(retired), retiredAmbient(w, Pair.sourceId(before, [], reverse)))))

def expectedEligible(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool,
  ok: {B.ok(w) == True{} : Bool},
  noLanes: {R.LaneState.live(R.World.laneState(w)) == [] : List<&2, Nat>}) ->
  {X.blocked(expected(w, before, reverse), Pair.targetId(before, [], reverse)) == Empty.answer(expected(w, before, reverse),Pair.targetId(before,[],reverse)) : B.Bundle<R.World, Bool>}:
  +s = expected(w, before, reverse)
  +root = Pair.targetId(before, [], reverse)
  +base = B.schedule(B.schedule(Pair.retire(w, Pair.sourceId(before, [], reverse))))
  Empty.public(s, root,
    Equal.trans(Bool, B.ok(s), B.ok(w), True{}, Equal.cong(Ambient, Bool, frame => healthy(frame), ambient(s), ambient(w), finalAmbient(w, before, reverse)), ok),
    Count.count(base, before, reverse, 0n),
    Equal.cong(R.Transaction, List<&2, Nat>, record => R.Transaction.nodes(record), B.transaction(s, root), Opening.record(0n, True{}), Count.targetRead(base, before, reverse, 0n)),
    Equal.cong(R.Transaction, Bool, record => R.Transaction.lane(record), B.transaction(s, root), Opening.record(0n, True{}), Count.targetRead(base, before, reverse, 0n)),
    Equal.trans(List<&2, Nat>, R.LaneState.live(R.World.laneState(s)), R.LaneState.live(R.World.laneState(w)), [], Equal.cong(Ambient, List<&2, Nat>, frame => live(frame), ambient(s), ambient(w), finalAmbient(w, before, reverse)), noLanes))

def transport(+actual: R.World, +normal: R.World, +root: Nat,
  +same: {actual == normal : R.World},
  eligible: {X.blocked(normal, root) == Empty.answer(normal,root) : B.Bundle<R.World, Bool>}) ->
  {X.blocked(actual, root) == Empty.answer(actual,root) : B.Bundle<R.World, Bool>}:
  Equal.trans(B.Bundle<R.World, Bool>, X.blocked(actual, root), X.blocked(normal, root), Empty.answer(actual,root),
    Equal.cong(R.World, B.Bundle<R.World, Bool>, state => X.blocked(state, root), actual, normal, same),
    Equal.trans(B.Bundle<R.World, Bool>, X.blocked(normal, root), Empty.answer(normal,root), Empty.answer(actual,root), eligible,
      Equal.cong(R.World, B.Bundle<R.World, Bool>, state => Empty.answer(state,root), normal, actual, Equal.sym(R.World, actual, normal, same))))

def fromCompletion(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, +firstId: Nat, +otherId: Nat,
  +initial: List<&2, History.JoinEvent>, +middle: List<&2, History.JoinEvent>, +final: List<&2, History.JoinEvent>,
  certificate: Complete.Completion<w, before, reverse, firstId, otherId, initial, middle, final>,
  ok: {B.ok(w) == True{} : Bool},
  noLanes: {R.LaneState.live(R.World.laneState(w)) == [] : List<&2, Nat>}) ->
  {X.blocked(Complete.run(X.merge(w, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse)), before, reverse, firstId, otherId, initial, middle, final), Pair.targetId(before, [], reverse)) == Empty.answer(Complete.run(X.merge(w, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse)), before, reverse, firstId, otherId, initial, middle, final),Pair.targetId(before,[],reverse)) : B.Bundle<R.World, Bool>}:
  transport(Complete.run(X.merge(w, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse)), before, reverse, firstId, otherId, initial, middle, final), expected(w, before, reverse), Pair.targetId(before, [], reverse), Complete.equation(w, before, reverse, firstId, otherId, initial, middle, final, certificate), expectedEligible(w, before, reverse, ok, noLanes))

type Eligibility<-w: R.World, -before: List<&2, R.Transaction>, -reverse: Bool, -firstId: Nat, -otherId: Nat,
  -initial: List<&2, History.JoinEvent>, -middle: List<&2, History.JoinEvent>, -final: List<&2, History.JoinEvent>> is Data:
  PairJudged{completion: Complete.Completion<w, before, reverse, firstId, otherId, initial, middle, final>,
    judgment: {X.blocked(Complete.run(X.merge(w, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse)), before, reverse, firstId, otherId, initial, middle, final), Pair.targetId(before, [], reverse)) == Empty.answer(Complete.run(X.merge(w, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse)), before, reverse, firstId, otherId, initial, middle, final),Pair.targetId(before,[],reverse)) : B.Bundle<R.World, Bool>}}

def certify(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, +firstId: Nat, +otherId: Nat,
  +initial: List<&2, History.JoinEvent>, +middle: List<&2, History.JoinEvent>, +final: List<&2, History.JoinEvent>,
  +certificate: Complete.Completion<w, before, reverse, firstId, otherId, initial, middle, final>,
  ok: {B.ok(w) == True{} : Bool},
  noLanes: {R.LaneState.live(R.World.laneState(w)) == [] : List<&2, Nat>}) -> Eligibility<w, before, reverse, firstId, otherId, initial, middle, final>:
  PairJudged{certificate, fromCompletion(w, before, reverse, firstId, otherId, initial, middle, final, certificate, ok, noLanes)}

def expectedLanes(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr) ->
  {R.LaneState.live(R.World.laneState(Actions.expected(w, before, cells, first, other))) == R.LaneState.live(R.World.laneState(w)) : List<&2, Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def constructedLanes(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr) ->
  {R.LaneState.live(R.World.laneState(Actions.second(w, before, cells, first, other))) == R.LaneState.live(R.World.laneState(w)) : List<&2, Nat>}:
  Equal.trans(List<&2, Nat>, R.LaneState.live(R.World.laneState(Actions.second(w, before, cells, first, other))), R.LaneState.live(R.World.laneState(Actions.expected(w, before, cells, first, other))), R.LaneState.live(R.World.laneState(w)),
    Equal.cong(R.World, List<&2, Nat>, state => R.LaneState.live(R.World.laneState(state)), Actions.second(w, before, cells, first, other), Actions.expected(w, before, cells, first, other), Actions.constructs(w, before, cells, first, other)), expectedLanes(w, before, cells, first, other))

def constructed(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr, +reverse: Bool, +second: Bool,
  +initial: List<&2, History.JoinEvent>, +middle: List<&2, History.JoinEvent>, +final: List<&2, History.JoinEvent>,
  ok: {B.ok(w) == True{} : Bool},
  noLanes: {R.LaneState.live(R.World.laneState(w)) == [] : List<&2, Nat>}) ->
  Eligibility<Actions.second(w, before, cells, first, other), before, reverse, Complete.selectedId(cells, second), Complete.selectedId(cells, Bool.not(second)), initial, middle, final>:
  certify(Actions.second(w, before, cells, first, other), before, reverse, Complete.selectedId(cells, second), Complete.selectedId(cells, Bool.not(second)), initial, middle, final,
    Complete.constructed(w, before, cells, first, other, reverse, second, initial, middle, final),
    Equal.trans(Bool, B.ok(Actions.second(w, before, cells, first, other)), B.ok(w), True{}, Blocker.constructedOk(w, before, cells, first, other), ok),
    Equal.trans(List<&2, Nat>, R.LaneState.live(R.World.laneState(Actions.second(w, before, cells, first, other))), R.LaneState.live(R.World.laneState(w)), [], constructedLanes(w, before, cells, first, other), noLanes))
