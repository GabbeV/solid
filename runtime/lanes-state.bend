# core/lanes.ts identities and routing. Seams/staging/corrections are separate
# unfinished engine crossings, not approximated by these helpers.
import Base
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
      B.choose(~R.World, Bool.and(B.has(flags, K.REACTIVE_JOINED()), B.has(flags, K.REACTIVE_STAGED_READ())), _ => V.stagedRead(w, reader, 0n), _ => w),
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
