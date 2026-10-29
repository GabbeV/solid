# core/lanes.ts identities, routing, borrowed guesses and staging helpers.
# Callback/commit/seam continuations live in core.bend; stores stay excluded.
import Base
import ./truth-state.bend as T
import ./question.bend as Question
import ./extension.bend as E
import ./write.bend as W
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./constants.bend as K
import ./transaction.bend as Tx
import ./pending-state.bend as P
import ./read-state.bend as V

def groups(+w: R.World, id: Nat) -> List<&2, Nat>:
  B.get(List<&2, Nat>, R.LaneState.groups(R.World.laneState(w)), id, [])

def storeGroup(+w: R.World, id: Nat, group: List<&2, Nat>) -> R.World:
  +state = R.World.laneState(w)
  R.World.with_laneState(w, R.LaneState.with_groups(state, List.set(&2, List<&2, Nat>, R.LaneState.groups(state), id, group)))

def newLane(+w: R.World, parent: Nat) -> B.Bundle<R.World, Nat>:
  +pair = Tx.newTransaction(w, True{}, parent)
  +w = B.first(R.World, Nat, pair)
  +id = B.second(R.World, Nat, pair)
  +state = R.World.laneState(w)
  B.Bundle{R.World.with_laneState(w, R.LaneState.with_live(state, B.append(Nat, R.LaneState.live(state), [id]))), id}

def verdictLane(+w: R.World, +parent: Nat) -> B.Bundle<R.World, Nat>:
  +id = R.Transaction.verdict(B.transaction(w, parent))
  B.choose(~B.Bundle<R.World, Nat>, Nat.is_ne(id, 0n), _ => B.Bundle{w, id},
    _ =>
      +pair = newLane(w, parent)
      +w = B.first(R.World, Nat, pair)
      +id = B.second(R.World, Nat, pair)
      B.Bundle{B.store_transaction(w, parent, R.Transaction.with_verdict(B.transaction(w, parent), id)), id})

# scheduler.ts:sameLane compares raw identity/group identity, not redirects.
def sameLane(+w: R.World, +a: Nat, +b: Nat) -> Bool:
  Bool.or(Nat.is_eq(a, b), Bool.and(Nat.is_ne(R.Transaction.links(B.transaction(w, a)), 0n), Nat.is_eq(R.Transaction.links(B.transaction(w, a)), R.Transaction.links(B.transaction(w, b)))))

def underLoop(fuel: Nat, +w: R.World, +t: Nat, +ancestor: Nat) -> B.Bundle<R.World, Bool>:
  match fuel:
    case 0n:
      B.Bundle{R.World.with_fault(w, R.Exhausted{}), False{}}
    case 1n+p:
      B.choose(~B.Bundle<R.World, Bool>, Bool.or(Nat.is_eq(t, 0n), Bool.not(R.Transaction.lane(B.transaction(w, t)))),
        _ => B.Bundle{w, False{}},
        _ => B.choose(~B.Bundle<R.World, Bool>, Nat.is_eq(t, ancestor), _ => B.Bundle{w, True{}},
          _ => underLoop(p, w, R.Transaction.parent(B.transaction(w, t)), ancestor)))

def under(+w: R.World, +lane: Nat, ancestor: Nat) -> B.Bundle<R.World, Bool>:
  underLoop(1n+B.length(R.Transaction, R.World.txArena(w)), w, R.Transaction.parent(B.transaction(w, lane)), ancestor)

def groupLoop(fuel: Nat, +w: R.World, +index: Nat, +ga: Nat, +gb: Nat) -> R.World:
  match fuel:
    case 0n:
      B.choose(~R.World, Nat.is_ge(index, B.length(Nat, groups(w, gb))), _ => w, _ => R.World.with_fault(w, R.Exhausted{}))
    case 1n+p:
      B.choose(~R.World, Nat.is_ge(index, B.length(Nat, groups(w, gb))), _ => w,
        _ =>
          +member = B.get(Nat, groups(w, gb), index, 0n)
          +w = storeGroup(w, ga, B.append(Nat, groups(w, ga), [member]))
          +w = B.store_transaction(w, member, R.Transaction.with_links(B.transaction(w, member), ga))
          groupLoop(p, w, 1n+index, ga, gb))

def linkLanes(+w: R.World, +a: Nat, +b: Nat) -> R.World:
  +ga = R.Transaction.links(B.transaction(w, a))
  +pair = B.choose(~B.Bundle<R.World, Nat>, Nat.is_ne(ga, 0n), _ => B.Bundle{w, ga},
    _ =>
      +ga = B.length(List<&2, Nat>, R.LaneState.groups(R.World.laneState(w)))
      +state = R.World.laneState(w)
      +w = R.World.with_laneState(w, R.LaneState.with_groups(state, B.append(List<&2, Nat>, R.LaneState.groups(state), [[a]])))
      B.Bundle{B.store_transaction(w, a, R.Transaction.with_links(B.transaction(w, a), ga)), ga})
  +w = B.first(R.World, Nat, pair)
  +ga = B.second(R.World, Nat, pair)
  +gb = R.Transaction.links(B.transaction(w, b))
  B.choose(~R.World, Nat.is_eq(gb, ga), _ => w,
    _ => B.choose(~R.World, Nat.is_eq(gb, 0n),
      _ =>
        +w = storeGroup(w, ga, B.append(Nat, groups(w, ga), [b]))
        B.store_transaction(w, b, R.Transaction.with_links(B.transaction(w, b), ga)),
      _ => groupLoop(1n+B.length(Nat, groups(w, gb)), w, 0n, ga, gb)))

def unlink(+w: R.World, +lane: Nat) -> R.World:
  +g = R.Transaction.links(B.transaction(w, lane))
  B.choose(~R.World, Nat.is_eq(g, 0n), _ => w,
    _ =>
      +w = B.choose(~R.World, B.contains(groups(w, g), lane), _ => storeGroup(w, g, P.remove(groups(w, g), lane)), _ => w)
      B.store_transaction(w, lane, R.Transaction.with_links(B.transaction(w, lane), 0n)))

def display(+w: R.World, +id: Nat) -> R.Value:
  +x = B.extension(w, id)
  B.choose(~R.Value, Bool.and(R.Transaction.shown(B.transaction(w, R.NodeExtension.transaction(x))), B.present(R.NodeExtension.lane(x))),
    _ => B.selected(R.NodeExtension.lane(x), R.Undefined{}), _ => R.Node.value(B.node(w, id)))

def enterLane(+w: R.World, +lane: Nat, +reader: Nat) -> R.World:
  +w = B.store_node(w, reader, R.Node.with_flags(B.node(w, reader), B.set(R.Node.flags(B.node(w, reader)), K.REACTIVE_LANE_READ())))
  +p = R.World.passLane(w)
  B.choose(~R.World, Nat.is_eq(p, 0n),
    _ =>
      +w = R.World.with_passLane(w, lane)
      +flags = R.Node.flags(B.node(w, reader))
      B.choose(~R.World, Bool.and(B.has(flags, K.REACTIVE_STAGED_READ()), Bool.or(R.LaneState.guessed(R.World.laneState(w)), B.has(flags, K.REACTIVE_JOINED()))), _ => V.stagedRead(w, reader, 0n), _ => w),
    _ => B.choose(~R.World, sameLane(w, p, lane), _ => R.World.with_passLane(w, lane),
      _ =>
        +pair = under(w, p, lane)
        +w = B.first(R.World, Bool, pair)
        B.choose(~R.World, B.second(R.World, Bool, pair), _ => w,
          _ =>
            +pair = under(w, lane, p)
            +w = B.first(R.World, Bool, pair)
            B.choose(~R.World, B.second(R.World, Bool, pair), _ => R.World.with_passLane(w, lane),
              _ => R.World.with_passLane(linkLanes(w, p, lane), lane)))))

# scheduler.ts:laneDirty. Called after insertSubs; does not enqueue by itself.
def dirtyLoop(fuel: Nat, +w: R.World, +edge: Nat, +lane: Nat) -> R.World:
  match fuel:
    case 0n:
      B.choose(~R.World, Nat.is_eq(edge, 0n), _ => w, _ => R.World.with_fault(w, R.Exhausted{}))
    case 1n+p:
      B.choose(~R.World, Nat.is_eq(edge, 0n), _ => w,
        _ =>
          +reader = R.Link.sub(B.link(w, edge))
          +t = R.NodeExtension.transaction(B.extension(w, reader))
          +eligible = B.choose(~Bool, R.Transaction.lane(B.transaction(w, t)), _ => sameLane(w, t, lane), _ => B.effect(R.Node.kind(B.node(w, reader))))
          +w = B.choose(~R.World, eligible, _ => B.store_node(w, reader, R.Node.with_flags(B.node(w, reader), B.set(R.Node.flags(B.node(w, reader)), K.REACTIVE_LANE_DIRTY()))), _ => w)
          dirtyLoop(p, w, R.Link.nextSub(B.link(w, edge)), lane))

def laneDirty(+w: R.World, +id: Nat, lane: Nat) -> R.World:
  dirtyLoop(B.budget(w), w, R.Node.subs(B.node(w, id)), lane)

# lanes.ts:laneStage. Source errored is false, true, or the pending source
# object; the third case is intentionally not collapsed into true.
type StageError is Data:
  StageAnswered{}
  StageFailed{}
  StagePendingFrom{source: Nat}

def LEFT_SHOWN() -> U32:
  1048576

def stageErrored(error: StageError) -> Bool:
  match error:
    case StageAnswered{}:
      False{}
    case _:
      True{}

def clearStageConfig(+w: R.World, +id: Nat) -> R.World:
  B.store_node(w, id, R.Node.with_config(B.node(w, id), B.clear(R.Node.config(B.node(w, id)), U32.or(K.CONFIG_OVERRIDE(), U32.or(K.CONFIG_HELD(), K.CONFIG_HELD_FRAME())))))

def leaveStageEnd(+w: R.World, +id: Nat, +tx: Nat) -> B.Bundle<R.World, Bool>:
  +w = B.choose(~R.World, Bool.and(Nat.is_ne(tx, 0n), R.Transaction.lane(B.transaction(w, tx))),
    _ => B.store_extension(w, id, R.NodeExtension.with_transaction(B.extension(w, id), 0n)), _ => w)
  +w = B.store_extension(w, id, R.NodeExtension.with_lane(B.extension(w, id), R.Empty{}))
  B.Bundle{clearStageConfig(w, id), False{}}

def leaveStage(+w: R.World, +id: Nat) -> B.Bundle<R.World, Bool>:
  B.choose(~B.Bundle<R.World, Bool>, Nat.is_eq(R.Node.x(B.node(w, id)), 0n), _ => B.Bundle{clearStageConfig(w, id), False{}},
    _ =>
      +tx = R.NodeExtension.transaction(B.extension(w, id))
      +w = B.choose(~R.World, Bool.and(R.Transaction.lane(B.transaction(w, tx)), R.Transaction.shown(B.transaction(w, tx))),
        _ => B.choose(~R.World, Nat.is_eq(R.World.flushTransaction(w), 0n),
          _ => B.store_node(w, id, R.Node.with_flags(B.node(w, id), B.set(R.Node.flags(B.node(w, id)), LEFT_SHOWN()))),
          _ =>
            +pair = Tx.resolveTx(w, R.Transaction.parent(B.transaction(w, tx)))
            +pair = Tx.blocked(B.first(R.World, Nat, pair), B.second(R.World, Nat, pair))
            +w = B.first(R.World, Bool, pair)
            B.choose(~R.World, B.second(R.World, Bool, pair),
              _ => B.store_node(w, id, R.Node.with_value(B.node(w, id), display(w, id))),
              _ => B.store_node(w, id, R.Node.with_flags(B.node(w, id), B.set(R.Node.flags(B.node(w, id)), LEFT_SHOWN()))))), _ => w)
      leaveStageEnd(w, id, tx))

def hasStageLane(+w: R.World, +id: Nat) -> Bool:
  B.choose(~Bool, Nat.is_eq(R.Node.x(B.node(w, id)), 0n), _ => False{},
    _ =>
      +tx = R.NodeExtension.transaction(B.extension(w, id))
      B.choose(~Bool, Nat.is_eq(tx, 0n), _ => False{}, _ => R.Transaction.lane(B.transaction(w, tx))))

def framePending(+w: R.World, +id: Nat, error: StageError) -> Bool:
  match error:
    case StagePendingFrom{source}:
      Bool.and(Bool.not(B.has(R.Node.status(B.node(w, source)), K.STATUS_UNINITIALIZED())),
        Bool.and(Bool.or(B.has(R.Node.config(B.node(w, id)), K.CONFIG_HELD()), B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_RECOMPUTING_DEPS())), Bool.not(hasStageLane(w, id))))
    case _:
      False{}

def effectStage(+w: R.World, +id: Nat, +lane: Nat, +error: StageError) -> B.Bundle<R.World, Bool>:
  B.choose(~B.Bundle<R.World, Bool>, stageErrored(error),
    _ => B.choose(~B.Bundle<R.World, Bool>, framePending(w, id, error), _ => B.Bundle{W.queuePendingNode(w, id), False{}},
      _ =>
        +w = B.store_node(w, id, R.Node.with_flags(B.node(w, id), B.set(R.Node.flags(B.node(w, id)), K.REACTIVE_LANE_DIRTY())))
        B.Bundle{Tx.list(w, id, lane), True{}}),
    _ => B.Bundle{Tx.list(w, id, lane), True{}})

# lanes.ts:rerun walks current subscriber links in source order.
def rerunLoop(fuel: Nat, +w: R.World, +edge: Nat, +lane: Nat) -> R.World:
  match fuel:
    case 0n:
      B.choose(~R.World, Nat.is_eq(edge, 0n), _ => w, _ => R.World.with_fault(w, R.Exhausted{}))
    case 1n+p:
      B.choose(~R.World, Nat.is_eq(edge, 0n), _ => w,
        _ =>
          +w = Tx.staleReader(w, R.Link.sub(B.link(w, edge)), lane)
          rerunLoop(p, w, R.Link.nextSub(B.link(w, edge)), lane))

def rerun(+w: R.World, +id: Nat, lane: Nat) -> R.World:
  rerunLoop(B.budget(w), w, R.Node.subs(B.node(w, id)), lane)

# Source kept array is an ordered stack of five-tuples, not a set.
def take(+w: R.World, +id: Nat, +lane: Nat, +detach: Bool) -> R.World:
  +x = B.extension(w, id)
  +state = R.World.laneState(w)
  +w = R.World.with_laneState(w, R.LaneState.with_kept(state, B.append(R.KeptGuess, R.LaneState.kept(state), [R.KeptGuess{id, R.NodeExtension.lane(x), R.NodeExtension.transaction(x), R.NodeExtension.q(x), lane}])))
  +w = rerun(w, id, lane)
  +mask = B.choose(~U32, detach, _ => U32.or(K.CONFIG_GUESS(), K.CONFIG_OVERRIDE()), _ => K.CONFIG_GUESS())
  +w = B.store_node(w, id, R.Node.with_config(B.node(w, id), B.clear(R.Node.config(B.node(w, id)), mask)))
  B.choose(~R.World, detach,
    _ => B.store_extension(w, id, R.NodeExtension.with_lane(R.NodeExtension.with_transaction(B.extension(w, id), 0n), R.Empty{})),
    _ => Tx.list(w, id, lane))

def markReverted(+w: R.World, +lane: Nat) -> R.World:
  +state = R.World.laneState(w)
  B.choose(~R.World, B.contains(R.LaneState.reverted(state), lane), _ => w,
    _ => R.World.with_laneState(w, R.LaneState.with_reverted(state, B.append(Nat, R.LaneState.reverted(state), [lane]))))

def clearGuessUnlessErrored(+w: R.World, +id: Nat, error: StageError) -> R.World:
  B.choose(~R.World, stageErrored(error), _ => w,
    _ => B.store_node(w, id, R.Node.with_config(B.node(w, id), B.clear(R.Node.config(B.node(w, id)), K.CONFIG_GUESS()))))

def computationStage(+w: R.World, +id: Nat, +lane: Nat, +error: StageError) -> B.Bundle<R.World, Bool>:
  +w = B.choose(~R.World, B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()), _ => w,
    _ =>
      +w = B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Empty{}))
      +w = B.store_node(w, id, R.Node.with_config(B.node(w, id), B.set(B.clear(R.Node.config(B.node(w, id)), U32.or(K.CONFIG_HELD(), K.CONFIG_HELD_FRAME())), K.CONFIG_OVERRIDE())))
      E.ext(w, id))
  +old = R.NodeExtension.transaction(B.extension(w, id))
  +w = B.choose(~R.World, Bool.and(R.LaneState.guessed(R.World.laneState(w)), Bool.and(B.has(R.Node.config(B.node(w, id)), K.CONFIG_GUESS()), R.Transaction.lane(B.transaction(w, old)))),
    _ =>
      +a = Tx.resolveTx(w, R.Transaction.parent(B.transaction(w, old)))
      +b = Tx.resolveTx(B.first(R.World, Nat, a), R.Transaction.parent(B.transaction(B.first(R.World, Nat, a), lane)))
      +w = B.first(R.World, Nat, b)
      B.choose(~R.World, Nat.is_ne(B.second(R.World, Nat, a), B.second(R.World, Nat, b)),
        _ => take(w, id, lane, False{}), _ => clearGuessUnlessErrored(w, id, error)),
    _ => clearGuessUnlessErrored(w, id, error))
  B.Bundle{Tx.list(w, id, lane), True{}}

def laneStage(+w: R.World, +id: Nat, +lane: Nat, create: Bool, +error: StageError) -> B.Bundle<R.World, Bool>:
  B.choose(~B.Bundle<R.World, Bool>, Bool.or(create, Bool.or(stageErrored(error), Bool.or(B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_LANE_READ()), B.has(R.Node.config(B.node(w, id)), K.CONFIG_GUESS())))),
    _ => B.choose(~B.Bundle<R.World, Bool>, B.effect(R.Node.kind(B.node(w, id))), _ => effectStage(w, id, lane, error), _ => computationStage(w, id, lane, error)),
    _ => leaveStage(w, id))

# lanes.ts provenance helpers; stamped answers compare exact question numbers.
def stale(+w: R.World, id: Nat, +question: R.Question) -> Bool:
  Bool.and(Bool.not(Question.isZero(question)), Question.less(question, R.NodeExtension.q(B.extension(w, id))))

def answeredLoop(fuel: Nat, +w: R.World, +edge: Nat, +q: R.Question) -> B.Bundle<R.World, R.Question>:
  match fuel:
    case 0n:
      B.choose(~B.Bundle<R.World, R.Question>, Nat.is_eq(edge, 0n), _ => B.Bundle{w, q}, _ => B.Bundle{R.World.with_fault(w, R.Exhausted{}), q})
    case 1n+p:
      B.choose(~B.Bundle<R.World, R.Question>, Nat.is_eq(edge, 0n), _ => B.Bundle{w, q},
        _ =>
          +dep = R.Link.dep(B.link(w, edge))
          +x = R.Node.x(B.node(w, dep))
          +newer = Bool.and(Nat.is_ne(x, 0n), Bool.and(Question.less(q, R.NodeExtension.q(B.extension(w, dep))), Nat.is_eq(R.Node.time(B.node(w, dep)), R.World.clock(w))))
          +next = B.choose(~R.Question, newer, _ => R.NodeExtension.q(B.extension(w, dep)), _ => q)
          answeredLoop(p, w, R.Link.nextDep(B.link(w, edge)), next))

def answered(+w: R.World, id: Nat) -> B.Bundle<R.World, R.Question>:
  answeredLoop(1n+B.length(R.Link, R.World.links(w)), w, R.Node.deps(B.node(w, id)), R.QuestionZero{})

# lanes.ts pendingGuesses: typed triples retain the source live array/order.
def pendingGuessLoop(+w: R.World, +id: Nat, remaining: Nat) -> R.Slot:
  match remaining:
    case 0n:
      R.Empty{}
    case 1n+ +index:
      +guess = B.get(R.Guess, R.LaneState.pendingGuesses(R.World.laneState(w)), index, R.Guess{0n, R.Undefined{}, R.QuestionZero{}})
      B.choose(~R.Slot, Nat.is_eq(R.Guess.node(guess), id), _ => R.Present{R.Guess.value(guess)}, _ => pendingGuessLoop(w, id, index))

def pendingGuessOf(+w: R.World, +id: Nat) -> R.Slot:
  pendingGuessLoop(w, id, B.length(R.Guess, R.LaneState.pendingGuesses(R.World.laneState(w))))

def guessedValueOf(+w: R.World, +id: Nat) -> R.Value:
  +guess = pendingGuessOf(w, id)
  B.choose(~R.Value, B.present(guess), _ => B.selected(guess, R.Undefined{}),
    _ => B.choose(~R.Value, B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()), _ => T.laneValueOf(w, id), _ => R.Node.value(B.node(w, id))))

# Ordinary node branch; optional store slot-flight resolver is excluded.
def inFlight(w: R.World, id: Nat) -> B.Bundle<R.World, Bool>:
  Tx.laneInFlight(w, id)

def pushGuess(+w: R.World, +id: Nat, +value: R.Value) -> R.World:
  +pair = B.choose(~B.Bundle<R.World, R.Question>, Question.isZero(R.World.question(w)), _ => Question.nextQuestion(w), _ => B.Bundle{w, R.World.question(w)})
  +w = B.first(R.World, R.Question, pair)
  +state = R.World.laneState(w)
  +w = R.World.with_laneState(w, R.LaneState.with_pendingGuesses(state, B.append(R.Guess, R.LaneState.pendingGuesses(state), [R.Guess{id, value, B.second(R.World, R.Question, pair)}])))
  +w = R.World.with_laneState(w, R.LaneState.with_guessing(R.World.laneState(w), True{}))
  +w = R.World.with_laneState(w, R.LaneState.with_guessed(R.World.laneState(w), True{}))
  B.schedule(w)

# Persistent-list representation of entered.pop(): retain the prefix before
# selecting/processing the removed reader, preserving the source store order.
def enteredPrefix(count: Nat, readers: List<&2, Nat>) -> List<&2, Nat>:
  match count readers:
    case 0n _: []
    case _ Nil{}: []
    case 1n+left reader <> tail: reader <> enteredPrefix(left, tail)
