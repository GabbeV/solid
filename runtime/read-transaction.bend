# core/core.ts:frameRead, stagedScreen and their read call-site entry gate.
# The decision cut ends immediately before laneServed. Core runs that segment
# through its callback-aware pending/owner continuations. The raw adapter shares
# the same decision and uses the pending helper's admitted callback-free driver.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./constants.bend as K
import ./transaction.bend as X
import ./verdict-staging.bend as Staging
import ./lane-served.bend as Served

type Decision is Data:
  Decision{world: R.World, committed: Bool, serve: Bool}

def world(decision: Decision) -> R.World:
  match decision:
    case Decision{w, committed, serve}: w

def committed(decision: Decision) -> Bool:
  match decision:
    case Decision{w, answer, serve}: answer

def serves(decision: Decision) -> Bool:
  match decision:
    case Decision{w, committed, answer}: answer

def joined(w: R.World, reader: Nat, id: Nat) -> Decision:
  Decision{X.joinPass(w, reader, id), False{}, False{}}

# The lane's over is resolved at the source site, even when !verdict, which
# follows it in the source conjunction, will subsequently refuse that arm.
def overAnswer(+w: R.World, +lane: Bool, +t: Nat, verdict: Bool) -> B.Bundle<R.World, Bool>:
  +over = R.Transaction.over(B.transaction(w, R.World.passLane(w)))
  B.choose(~B.Bundle<R.World, Bool>, Bool.and(lane, Nat.is_ne(over, 0n)),
    _ =>
      +pair = X.resolveTx(w, over)
      B.Bundle{B.first(R.World, Nat, pair), Bool.and(Nat.is_eq(B.second(R.World, Nat, pair), t), Bool.not(verdict))},
    _ => B.Bundle{w, False{}})

# Source captured locals are explicit at this cut; holdStaging may change the
# live ambient lane later, without changing these two entry-local booleans.
def frameReadFlags(+w: R.World,+reader: Nat,+id: Nat,+verdict: Bool,+lane: Bool) -> Decision:
  +hold = B.choose(~B.Bundle<R.World, Bool>, verdict, _ => Staging.holdStaging(w, reader, id), _ => B.Bundle{w, False{}})
  +w = B.first(R.World, Bool, hold)
  +cold = Bool.and(Bool.or(Bool.not(lane), Bool.and(B.has(R.Node.status(B.node(w, reader)), K.STATUS_UNINITIALIZED()), B.has(R.Node.status(B.node(w, id)), K.STATUS_PENDING()))), Bool.and(Bool.not(verdict), Bool.or(Bool.not(B.has(R.Node.config(B.node(w, reader)), K.CONFIG_FRAME())), B.has(R.Node.config(B.node(w, id)), K.CONFIG_INPUTS_PUBLISHED()))))
  B.choose(~Decision, B.ok(w),
    _ => B.choose(~Decision, Bool.or(B.second(R.World, Bool, hold), cold), _ => joined(w, reader, id),
      _ =>
        +pair = X.txOf(w, id)
        +w = B.first(R.World, Nat, pair)
        +t = B.second(R.World, Nat, pair)
        +over = overAnswer(w, lane, t, verdict)
        +w = B.first(R.World, Bool, over)
        # The matching-over early return bypasses joinPass (source #4643).
        B.choose(~Decision, B.second(R.World, Bool, over), _ => Decision{w, False{}, False{}},
          _ => B.choose(~Decision, Bool.and(Nat.is_eq(t, R.World.flushTransaction(w)), Bool.and(Bool.not(lane), Bool.not(verdict))), _ => joined(w, reader, id),
            _ =>
              +pair = X.bornInto(w, reader, t)
              +w = B.first(R.World, Bool, pair)
              B.choose(~Decision, B.second(R.World, Bool, pair), _ => joined(w, reader, id),
                _ => Decision{X.staleReader(w, reader, t), True{}, Bool.or(lane, verdict)})))),
    _ => Decision{w, False{}, False{}})

def frameReadDecision(+w: R.World,+reader: Nat,+id: Nat) -> Decision:
  frameReadFlags(w,reader,id,B.has(R.Node.config(B.node(w,reader)),K.CONFIG_VERDICT()),Nat.is_ne(R.World.passLane(w),0n))

def finishDecision(+decision: Decision, reader: Nat, id: Nat) -> B.Bundle<R.World, Bool>:
  match decision:
    case Decision{+w, answer, serve}:
      B.Bundle{B.choose(~R.World, serve, _ => Served.served(w, reader, id), _ => w), answer}

def frameRead(w: R.World, +reader: Nat, +id: Nat) -> B.Bundle<R.World, Bool>:
  finishDecision(frameReadDecision(w, reader, id), reader, id)

def stagedScreenAfterHold(+w: R.World, +reader: Nat, +t: Nat) -> B.Bundle<R.World, Bool>:
  B.choose(~B.Bundle<R.World, Bool>, Bool.and(Nat.is_eq(t, R.VerdictState.latestOpened(R.World.verdictState(w))), Bool.and(Nat.is_eq(R.World.passLane(w), 0n), Bool.and(B.has(R.Node.config(B.node(w, reader)), K.CONFIG_VERDICT()), Bool.not(B.has(R.Node.status(B.node(w, reader)), K.STATUS_UNINITIALIZED()))))),
    _ =>
      +state = R.World.laneState(w)
      B.Bundle{R.World.with_laneState(w, R.LaneState.with_stagedReaders(state, B.append(Nat, R.LaneState.stagedReaders(state), [reader]))), False{}},
    _ => B.Bundle{X.staleReader(w, reader, t), True{}})

def stagedScreenFor(+w: R.World, +reader: Nat, +id: Nat) -> B.Bundle<R.World, Bool>:
  +t = R.World.flushTransaction(w)
  B.choose(~B.Bundle<R.World, Bool>, Nat.is_eq(t, 0n), _ => B.Bundle{w, False{}},
    _ =>
      +born = X.bornInto(w, reader, t)
      +w = B.first(R.World, Bool, born)
      B.choose(~B.Bundle<R.World, Bool>, Bool.or(B.second(R.World, Bool, born), Bool.and(Nat.is_ne(id, 0n), U32.is_eq(U32.and(R.Node.config(B.node(w, id)), B.set(K.CONFIG_HELD(), K.CONFIG_OVERRIDE())), K.CONFIG_HELD()))), _ => B.Bundle{w, False{}},
        _ =>
          +hold = Staging.holdStaging(w, reader, id)
          +w = B.first(R.World, Bool, hold)
          B.choose(~B.Bundle<R.World, Bool>, Bool.or(Bool.not(B.ok(w)), B.second(R.World, Bool, hold)), _ => B.Bundle{w, False{}}, _ => stagedScreenAfterHold(w, reader, t))))

# Omission occurs only in the excluded store crossing; non-store callers supply id.
def stagedScreen(w: R.World, reader: Nat) -> B.Bundle<R.World, Bool>:
  stagedScreenFor(w, reader, 0n)

def enterReadDecision(+w: R.World, +reader: Nat, +id: Nat, +slow: Bool) -> Decision:
  +eligible = Bool.and(Nat.is_ne(reader, 0n), Bool.and(B.has(R.Node.config(B.node(w, id)), K.CONFIG_HELD()), Bool.and(Bool.not(B.has(R.Node.config(B.node(w, reader)), K.CONFIG_CHILDREN_FORBIDDEN())), Bool.not(Bool.and(slow, B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()))))))
  B.choose(~Decision, eligible,
    _ => B.choose(~Decision, Bool.and(slow, B.has(R.Node.status(B.node(w, id)), K.STATUS_UNINITIALIZED())), _ => joined(w, reader, id), _ => frameReadDecision(w, reader, id)),
    _ => Decision{w, False{}, False{}})

def enterRead(w: R.World, +reader: Nat, +id: Nat, slow: Bool) -> B.Bundle<R.World, Bool>:
  finishDecision(enterReadDecision(w, reader, id, slow), reader, id)
