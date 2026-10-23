# Actual early blocker judgment for a healthy World with a positive current
# representative count. The full World, including the previous judge, survives.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X

def enter(+w: R.World, tx: Nat) -> R.World:
  B.choose(~R.World, Nat.is_eq(R.World.judge(w), 0n), _ => R.World.with_judge(w, tx), _ => w)

def decide(+w: R.World, +tx: Nat, +previous: Nat, count: Nat) -> X.BlockFrame:
  +pair = B.choose(~B.Bundle<R.World, Bool>, Nat.is_ne(count, 0n), _ => B.Bundle{w, True{}}, _ => X.blockedBy(w, R.Transaction.nodes(B.transaction(w, tx)), tx, False{}))
  +w = B.first(R.World, Bool, pair)
  B.choose(~X.BlockFrame, B.second(R.World, Bool, pair), _ => X.BlockFrame{w, [X.RestoreJudge{previous}], True{}}, _ => X.BlockFrame{w, [X.JudgeLanes{tx}, X.RestoreJudge{previous}], False{}})

def expand(+w: R.World, +tx: Nat) ->
  {X.blockStep(w, [X.JudgeTx{tx}], False{}) == decide(enter(w, tx), tx, R.World.judge(w), R.Transaction.open(B.transaction(enter(w, tx), tx))) : X.BlockFrame}:
  {==}

def readEntered(+w: R.World, +tx: Nat) ->
  {B.transaction(enter(w, tx), tx) == B.transaction(w, tx) : R.Transaction}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match judge:
        case 0n: {==}
        case 1n+p: {==}

def healthyEntered(+w: R.World, +tx: Nat) -> {B.ok(enter(w, tx)) == B.ok(w) : Bool}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match judge:
        case 0n: {==}
        case 1n+p: {==}

def restore(+w: R.World, +tx: Nat) ->
  {X.blockStep(enter(w, tx), [X.RestoreJudge{R.World.judge(w)}], True{}) == X.BlockFrame{w, [], True{}} : X.BlockFrame}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match judge:
        case 0n: {==}
        case 1n+p: {==}

def positiveStep(+w: R.World, +tx: Nat, +remaining: Nat,
  positive: {R.Transaction.open(B.transaction(w, tx)) == 1n+remaining : Nat}) ->
  {X.blockStep(w, [X.JudgeTx{tx}], False{}) == X.BlockFrame{enter(w, tx), [X.RestoreJudge{R.World.judge(w)}], True{}} : X.BlockFrame}:
  Equal.trans(X.BlockFrame, X.blockStep(w, [X.JudgeTx{tx}], False{}), decide(enter(w, tx), tx, R.World.judge(w), R.Transaction.open(B.transaction(enter(w, tx), tx))), X.BlockFrame{enter(w, tx), [X.RestoreJudge{R.World.judge(w)}], True{}}, expand(w, tx),
    Equal.cong(Nat, X.BlockFrame, count => decide(enter(w, tx), tx, R.World.judge(w), count), R.Transaction.open(B.transaction(enter(w, tx), tx)), 1n+remaining,
      Equal.trans(Nat, R.Transaction.open(B.transaction(enter(w, tx), tx)), R.Transaction.open(B.transaction(w, tx)), 1n+remaining,
        Equal.cong(R.Transaction, Nat, record => R.Transaction.open(record), B.transaction(enter(w, tx), tx), B.transaction(w, tx), readEntered(w, tx)), positive)))

def advance(+fuel: Nat, +w: R.World, +task: X.BlockTask, +rest: List<&2, X.BlockTask>, +result: Bool,
  healthy: {B.ok(w) == True{} : Bool}) ->
  {X.blockRun(1n+fuel, X.BlockFrame{w, task <> rest, result}) == X.blockRun(fuel, X.blockStep(w, task <> rest, result)) : B.Bundle<R.World, Bool>}:
  Equal.cong(Bool, B.Bundle<R.World, Bool>, ok => B.choose(~B.Bundle<R.World, Bool>, ok, _ => X.blockRun(fuel, X.blockStep(w, task <> rest, result)), _ => B.Bundle{w, result}), B.ok(w), True{}, healthy)

def empty(+fuel: Nat, +w: R.World, +result: Bool) ->
  {X.blockRun(fuel, X.BlockFrame{w, [], result}) == B.Bundle{w, result} : B.Bundle<R.World, Bool>}:
  match fuel:
    case 0n: {==}
    case 1n+p: {==}

def drainRestore(+w: R.World, +tx: Nat, +extra: Nat) ->
  {X.blockRun(extra, X.blockStep(enter(w, tx), [X.RestoreJudge{R.World.judge(w)}], True{})) == B.Bundle{w, True{}} : B.Bundle<R.World, Bool>}:
  Equal.trans(B.Bundle<R.World, Bool>, X.blockRun(extra, X.blockStep(enter(w, tx), [X.RestoreJudge{R.World.judge(w)}], True{})), X.blockRun(extra, X.BlockFrame{w, [], True{}}), B.Bundle{w, True{}},
    Equal.cong(X.BlockFrame, B.Bundle<R.World, Bool>, frame => X.blockRun(extra, frame), X.blockStep(enter(w, tx), [X.RestoreJudge{R.World.judge(w)}], True{}), X.BlockFrame{w, [], True{}}, restore(w, tx)), empty(extra, w, True{}))

def run(+w: R.World, +tx: Nat, +remaining: Nat, +extra: Nat,
  +healthy: {B.ok(w) == True{} : Bool},
  positive: {R.Transaction.open(B.transaction(w, tx)) == 1n+remaining : Nat}) ->
  {X.blockRun(2n+extra, X.BlockFrame{w, [X.JudgeTx{tx}], False{}}) == B.Bundle{w, True{}} : B.Bundle<R.World, Bool>}:
  Equal.trans(B.Bundle<R.World, Bool>, X.blockRun(2n+extra, X.BlockFrame{w, [X.JudgeTx{tx}], False{}}), X.blockRun(1n+extra, X.BlockFrame{enter(w, tx), [X.RestoreJudge{R.World.judge(w)}], True{}}), B.Bundle{w, True{}},
    Equal.trans(B.Bundle<R.World, Bool>, X.blockRun(2n+extra, X.BlockFrame{w, [X.JudgeTx{tx}], False{}}), X.blockRun(1n+extra, X.blockStep(w, [X.JudgeTx{tx}], False{})), X.blockRun(1n+extra, X.BlockFrame{enter(w, tx), [X.RestoreJudge{R.World.judge(w)}], True{}}), advance(1n+extra, w, X.JudgeTx{tx}, [], False{}, healthy),
      Equal.cong(X.BlockFrame, B.Bundle<R.World, Bool>, frame => X.blockRun(1n+extra, frame), X.blockStep(w, [X.JudgeTx{tx}], False{}), X.BlockFrame{enter(w, tx), [X.RestoreJudge{R.World.judge(w)}], True{}}, positiveStep(w, tx, remaining, positive))),
    Equal.trans(B.Bundle<R.World, Bool>, X.blockRun(1n+extra, X.BlockFrame{enter(w, tx), [X.RestoreJudge{R.World.judge(w)}], True{}}), X.blockRun(extra, X.blockStep(enter(w, tx), [X.RestoreJudge{R.World.judge(w)}], True{})), B.Bundle{w, True{}},
      advance(extra, enter(w, tx), X.RestoreJudge{R.World.judge(w)}, [], True{}, Equal.trans(Bool, B.ok(enter(w, tx)), B.ok(w), True{}, healthyEntered(w, tx), healthy)),
      drainRestore(w, tx, extra)))

def bound(+w: R.World) -> {X.blockBudget(w) == 2n+Nat.sub(X.blockBudget(w), 2n) : Nat}:
  {==}

def public(+w: R.World, +tx: Nat, +remaining: Nat,
  healthy: {B.ok(w) == True{} : Bool},
  positive: {R.Transaction.open(B.transaction(w, tx)) == 1n+remaining : Nat}) ->
  {X.blocked(w, tx) == B.Bundle{w, True{}} : B.Bundle<R.World, Bool>}:
  Equal.trans(B.Bundle<R.World, Bool>, X.blocked(w, tx), X.blockRun(2n+Nat.sub(X.blockBudget(w), 2n), X.BlockFrame{w, [X.JudgeTx{tx}], False{}}), B.Bundle{w, True{}},
    Equal.cong(Nat, B.Bundle<R.World, Bool>, fuel => X.blockRun(fuel, X.BlockFrame{w, [X.JudgeTx{tx}], False{}}), X.blockBudget(w), 2n+Nat.sub(X.blockBudget(w), 2n), bound(w)), run(w, tx, remaining, Nat.sub(X.blockBudget(w), 2n), healthy, positive))
