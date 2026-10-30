# Empty ordinary group eligibility. Positive action debt and graph/lane
# blockers are separate source branches; zero actions alone is not sufficient.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ./transaction-positive.bend as Positive
import ./transaction-blocking-list.bend as Lists

# A lane revealed with readers to re-derive can delay an otherwise empty
# parent. Preserve arbitrary initial lists instead of assuming that delay away.
def delay(+w: R.World,tx: Nat) -> Bool:
  B.contains(R.LaneState.revealing(R.World.laneState(w)),tx)

def answer(+w: R.World,tx: Nat) -> B.Bundle<R.World,Bool>:
  B.Bundle{w,delay(w,tx)}

def chooseRestore(+w: R.World,+previous: Nat,+flag: Bool) -> {B.choose(~X.BlockFrame,flag,_=>X.BlockFrame{w,[X.RestoreJudge{previous}],True{}},_=>X.BlockFrame{w,[X.RestoreJudge{previous}],False{}}) == X.BlockFrame{w,[X.RestoreJudge{previous}],flag} : X.BlockFrame}:
  match flag:
    case True{}: {==}
    case False{}: {==}

def afterOwn(+pair: B.Bundle<R.World, Bool>, +tx: Nat, +previous: Nat) -> X.BlockFrame:
  +w = B.first(R.World, Bool, pair)
  B.choose(~X.BlockFrame, B.second(R.World, Bool, pair),
    _ => X.BlockFrame{w, [X.RestoreJudge{previous}], True{}},
    _ => X.BlockFrame{w, [X.JudgeLanes{tx}, X.RestoreJudge{previous}], False{}})

def ownEmpty(+w: R.World, +tx: Nat, +previous: Nat,
  empty: {R.Transaction.nodes(B.transaction(w, tx)) == [] : List<&2, Nat>}) ->
  {Positive.decide(w, tx, previous, 0n) == X.BlockFrame{w, [X.JudgeLanes{tx}, X.RestoreJudge{previous}], False{}} : X.BlockFrame}:
  Equal.cong(B.Bundle<R.World, Bool>, X.BlockFrame, pair => afterOwn(pair, tx, previous), X.blockedBy(w, R.Transaction.nodes(B.transaction(w, tx)), tx, False{}), B.Bundle{w, False{}},
    Equal.trans(B.Bundle<R.World, Bool>, X.blockedBy(w, R.Transaction.nodes(B.transaction(w, tx)), tx, False{}), X.blockedBy(w, [], tx, False{}), B.Bundle{w, False{}},
      Equal.cong(List<&2, Nat>, B.Bundle<R.World, Bool>, nodes => X.blockedBy(w, nodes, tx, False{}), R.Transaction.nodes(B.transaction(w, tx)), [], empty), Lists.emptyList(Nat.add(B.budget(w), 0n), w, tx)))

def head(+w: R.World, +tx: Nat,
  zero: {R.Transaction.open(B.transaction(w, tx)) == 0n : Nat},
  empty: {R.Transaction.nodes(B.transaction(w, tx)) == [] : List<&2, Nat>}) ->
  {X.blockStep(w, [X.JudgeTx{tx}], False{}) == X.BlockFrame{Positive.enter(w, tx), [X.JudgeLanes{tx}, X.RestoreJudge{R.World.judge(w)}], False{}} : X.BlockFrame}:
  +entered = Positive.enter(w, tx)
  Equal.trans(X.BlockFrame, X.blockStep(w, [X.JudgeTx{tx}], False{}), Positive.decide(entered, tx, R.World.judge(w), R.Transaction.open(B.transaction(entered, tx))), X.BlockFrame{entered, [X.JudgeLanes{tx}, X.RestoreJudge{R.World.judge(w)}], False{}}, Positive.expand(w, tx),
    Equal.trans(X.BlockFrame, Positive.decide(entered, tx, R.World.judge(w), R.Transaction.open(B.transaction(entered, tx))), Positive.decide(entered, tx, R.World.judge(w), 0n), X.BlockFrame{entered, [X.JudgeLanes{tx}, X.RestoreJudge{R.World.judge(w)}], False{}},
      Equal.cong(Nat, X.BlockFrame, count => Positive.decide(entered, tx, R.World.judge(w), count), R.Transaction.open(B.transaction(entered, tx)), 0n,
        Equal.trans(Nat, R.Transaction.open(B.transaction(entered, tx)), R.Transaction.open(B.transaction(w, tx)), 0n,
          Equal.cong(R.Transaction, Nat, record => R.Transaction.open(record), B.transaction(entered, tx), B.transaction(w, tx), Positive.readEntered(w, tx)), zero)),
      ownEmpty(entered, tx, R.World.judge(w),
        Equal.trans(List<&2, Nat>, R.Transaction.nodes(B.transaction(entered, tx)), R.Transaction.nodes(B.transaction(w, tx)), [],
          Equal.cong(R.Transaction, List<&2, Nat>, record => R.Transaction.nodes(record), B.transaction(entered, tx), B.transaction(w, tx), Positive.readEntered(w, tx)), empty))))

def lanes(+w: R.World, +tx: Nat, +previous: Nat,
  ordinary: {R.Transaction.lane(B.transaction(w, tx)) == False{} : Bool}) ->
  {X.blockStep(w, [X.JudgeLanes{tx}, X.RestoreJudge{previous}], False{}) == X.BlockFrame{w, [X.NestedMembers{tx, 0n}, X.RestoreJudge{previous}], False{}} : X.BlockFrame}:
  Equal.cong(Bool, X.BlockFrame, lane => B.choose(~X.BlockFrame, lane,
    _ => X.BlockFrame{w, [X.LinkedMembers{tx, R.Transaction.links(B.transaction(w, tx)), 0n}, X.AfterLinked{tx}, X.RestoreJudge{previous}], False{}},
    _ => X.BlockFrame{w, [X.NestedMembers{tx, 0n}, X.RestoreJudge{previous}], False{}}), R.Transaction.lane(B.transaction(w, tx)), False{}, ordinary)

# Exact source NestedMembers decision with just the live-list length abstracted.
def nestedDecision(+w: R.World, +tx: Nat, +previous: Nat, size: Nat) -> X.BlockFrame:
  B.choose(~X.BlockFrame,delay(w,tx),_=>X.BlockFrame{w,[X.RestoreJudge{previous}],True{}},_=>B.choose(~X.BlockFrame, Nat.is_ge(0n, size), _ => X.BlockFrame{w, [X.RestoreJudge{previous}], False{}},
    _ =>
      +lane = B.get(Nat, R.LaneState.live(R.World.laneState(w)), 0n, 0n)
      +pair = X.resolveTx(w, R.Transaction.parent(B.transaction(w, lane)))
      +w = B.first(R.World, Nat, pair)
      B.choose(~X.BlockFrame, Nat.is_ne(B.second(R.World, Nat, pair), tx),
        _ => X.BlockFrame{w, [X.NestedMembers{tx, 1n}, X.RestoreJudge{previous}], False{}},
        _ => X.BlockFrame{w, [X.JudgeTx{lane}, X.ContinueNested{tx, 0n, lane}, X.RestoreJudge{previous}], False{}})) )

def nested(+w: R.World,+tx: Nat,+previous: Nat,noLanes: {R.LaneState.live(R.World.laneState(w)) == [] : List<&2,Nat>}) -> {X.blockStep(w,[X.NestedMembers{tx,0n},X.RestoreJudge{previous}],False{}) == X.BlockFrame{w,[X.RestoreJudge{previous}],delay(w,tx)} : X.BlockFrame}:
  Equal.trans(X.BlockFrame,X.blockStep(w,[X.NestedMembers{tx,0n},X.RestoreJudge{previous}],False{}),nestedDecision(w,tx,previous,0n),X.BlockFrame{w,[X.RestoreJudge{previous}],delay(w,tx)},Equal.cong(Nat,X.BlockFrame,size=>nestedDecision(w,tx,previous,size),B.length(Nat,R.LaneState.live(R.World.laneState(w))),0n,Equal.cong(List<&2,Nat>,Nat,live=>B.length(Nat,live),R.LaneState.live(R.World.laneState(w)),[],noLanes)),chooseRestore(w,previous,delay(w,tx)))

def enteredLive(+w: R.World, +tx: Nat) ->
  {R.LaneState.live(R.World.laneState(Positive.enter(w, tx))) == R.LaneState.live(R.World.laneState(w)) : List<&2, Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match judge:
        case 0n: {==}
        case 1n+p: {==}

def enteredDelay(+w: R.World, +tx: Nat) ->
  {delay(Positive.enter(w,tx),tx) == delay(w,tx) : Bool}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match judge:
        case 0n: {==}
        case 1n+p: {==}

def restore(+w: R.World, +tx: Nat,+result: Bool) ->
  {X.blockStep(Positive.enter(w, tx), [X.RestoreJudge{R.World.judge(w)}], result) == X.BlockFrame{w, [], result} : X.BlockFrame}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match judge:
        case 0n: {==}
        case 1n+p: {==}

def lift(+fuel: Nat, +w: R.World, +task: X.BlockTask, +rest: List<&2, X.BlockTask>, +result: Bool, +next: X.BlockFrame, +answer: B.Bundle<R.World, Bool>,
  healthy: {B.ok(w) == True{} : Bool},
  step: {X.blockStep(w, task <> rest, result) == next : X.BlockFrame},
  tail: {X.blockRun(fuel, next) == answer : B.Bundle<R.World, Bool>}) ->
  {X.blockRun(1n+fuel, X.BlockFrame{w, task <> rest, result}) == answer : B.Bundle<R.World, Bool>}:
  Equal.trans(B.Bundle<R.World, Bool>, X.blockRun(1n+fuel, X.BlockFrame{w, task <> rest, result}), X.blockRun(fuel, X.blockStep(w, task <> rest, result)), answer, Positive.advance(fuel, w, task, rest, result, healthy),
    Equal.trans(B.Bundle<R.World, Bool>, X.blockRun(fuel, X.blockStep(w, task <> rest, result)), X.blockRun(fuel, next), answer,
      Equal.cong(X.BlockFrame, B.Bundle<R.World, Bool>, frame => X.blockRun(fuel, frame), X.blockStep(w, task <> rest, result), next, step), tail))

def run(+w: R.World, +tx: Nat, +extra: Nat,
  +healthy: {B.ok(w) == True{} : Bool},
  zero: {R.Transaction.open(B.transaction(w, tx)) == 0n : Nat},
  empty: {R.Transaction.nodes(B.transaction(w, tx)) == [] : List<&2, Nat>},
  ordinary: {R.Transaction.lane(B.transaction(w, tx)) == False{} : Bool},
  noLanes: {R.LaneState.live(R.World.laneState(w)) == [] : List<&2, Nat>}) ->
  {X.blockRun(4n+extra, X.BlockFrame{w, [X.JudgeTx{tx}], False{}}) == B.Bundle{w, delay(w,tx)} : B.Bundle<R.World, Bool>}:
  +entered = Positive.enter(w, tx)
  +previous = R.World.judge(w)
  +healthyIn = Equal.trans(Bool, B.ok(entered), B.ok(w), True{}, Positive.healthyEntered(w, tx), healthy)
  lift(3n+extra, w, X.JudgeTx{tx}, [], False{}, X.BlockFrame{entered, [X.JudgeLanes{tx}, X.RestoreJudge{previous}], False{}}, B.Bundle{w, delay(w,tx)}, healthy, head(w, tx, zero, empty),
    lift(2n+extra, entered, X.JudgeLanes{tx}, [X.RestoreJudge{previous}], False{}, X.BlockFrame{entered, [X.NestedMembers{tx, 0n}, X.RestoreJudge{previous}], False{}}, B.Bundle{w, delay(w,tx)}, healthyIn,
      lanes(entered, tx, previous, Equal.trans(Bool, R.Transaction.lane(B.transaction(entered, tx)), R.Transaction.lane(B.transaction(w, tx)), False{},
        Equal.cong(R.Transaction, Bool, record => R.Transaction.lane(record), B.transaction(entered, tx), B.transaction(w, tx), Positive.readEntered(w, tx)), ordinary)),
      lift(1n+extra, entered, X.NestedMembers{tx, 0n}, [X.RestoreJudge{previous}], False{}, X.BlockFrame{entered, [X.RestoreJudge{previous}], delay(w,tx)}, B.Bundle{w, delay(w,tx)}, healthyIn,
        Equal.trans(X.BlockFrame,X.blockStep(entered,[X.NestedMembers{tx,0n},X.RestoreJudge{previous}],False{}),X.BlockFrame{entered,[X.RestoreJudge{previous}],delay(entered,tx)},X.BlockFrame{entered,[X.RestoreJudge{previous}],delay(w,tx)},nested(entered,tx,previous,Equal.trans(List<&2,Nat>,R.LaneState.live(R.World.laneState(entered)),R.LaneState.live(R.World.laneState(w)),[],enteredLive(w,tx),noLanes)),Equal.cong(Bool,X.BlockFrame,flag=>X.BlockFrame{entered,[X.RestoreJudge{previous}],flag},delay(entered,tx),delay(w,tx),enteredDelay(w,tx))),
        lift(extra, entered, X.RestoreJudge{previous}, [], delay(w,tx), X.BlockFrame{w, [], delay(w,tx)}, B.Bundle{w, delay(w,tx)}, healthyIn, restore(w, tx,delay(w,tx)), Positive.empty(extra, w,delay(w,tx))))))

def bound(+w: R.World) -> {X.blockBudget(w) == 4n+Nat.sub(X.blockBudget(w), 4n) : Nat}:
  {==}

def public(+w: R.World, +tx: Nat,
  healthy: {B.ok(w) == True{} : Bool},
  zero: {R.Transaction.open(B.transaction(w, tx)) == 0n : Nat},
  empty: {R.Transaction.nodes(B.transaction(w, tx)) == [] : List<&2, Nat>},
  ordinary: {R.Transaction.lane(B.transaction(w, tx)) == False{} : Bool},
  noLanes: {R.LaneState.live(R.World.laneState(w)) == [] : List<&2, Nat>}) ->
  {X.blocked(w, tx) == B.Bundle{w, delay(w,tx)} : B.Bundle<R.World, Bool>}:
  Equal.trans(B.Bundle<R.World, Bool>, X.blocked(w, tx), X.blockRun(4n+Nat.sub(X.blockBudget(w), 4n), X.BlockFrame{w, [X.JudgeTx{tx}], False{}}), B.Bundle{w, delay(w,tx)},
    Equal.cong(Nat, B.Bundle<R.World, Bool>, fuel => X.blockRun(fuel, X.BlockFrame{w, [X.JudgeTx{tx}], False{}}), X.blockBudget(w), 4n+Nat.sub(X.blockBudget(w), 4n), bound(w)), run(w, tx, Nat.sub(X.blockBudget(w), 4n), healthy, zero, empty, ordinary, noLanes))
