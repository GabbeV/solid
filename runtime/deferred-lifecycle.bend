# deferred.ts:createDeferred closure cells and lifecycle segments. State carries
# the module Set's current membership view along with one closure's captured
# locals. A future arena caller must thread that one shared Set across cells.
# These helpers do not install the constructor, cleanup or async callbacks.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./affects-marks.bend as M
import ./pending-state.bend as P
import ./transaction.bend as T
import ./constants.bend as K

def initial(node: Nat, lagging: List<&2, Nat>) -> R.DeferredState:
  R.DeferredState{R.DeferredCell{node, R.Null{}, False{}, False{}}, lagging}

# Set.add keeps existing insertion order; repeated asks replace the flight but
# do not add another Set entry or mark. This is not an ambient affects scope.
def ask(+w: R.World, +state: R.DeferredState, flight: R.Value) -> B.Bundle<R.World, R.DeferredState>:
  +cell = R.DeferredState.cell(state)
  +node = R.DeferredCell.node(cell)
  +cell = R.DeferredCell.with_flight(cell, flight)
  +lagging = R.DeferredState.lagging(state)
  +lagging = B.choose(~List<&2, Nat>, B.contains(lagging, node), _ => lagging, _ => B.append(Nat, lagging, [node]))
  +mark = Bool.and(Bool.not(R.DeferredCell.marked(cell)), Bool.not(B.has(R.Node.flags(B.node(w, node)), K.REACTIVE_REASK())))
  +cell = B.choose(~R.DeferredCell, mark, _ => R.DeferredCell.with_marked(cell, True{}), _ => cell)
  +w = B.choose(~R.World, mark, _ => M.repoll(M.mark(w, node), node), _ => w)
  B.Bundle{w, R.DeferredState{cell, lagging}}

# The held landing scans the FULL dependency list, stops at its FIRST held
# input and resolves that input's transaction before holding this node.
def landHeld(fuel: Nat, +w: R.World, +node: Nat, +edge: Nat) -> R.World:
  match fuel:
    case 0n:
      B.choose(~R.World, Nat.is_eq(edge, 0n), _ => w, _ => R.World.with_fault(w, R.Exhausted{}))
    case 1n+ +p:
      B.choose(~R.World, Nat.is_eq(edge, 0n), _ => w,
        _ =>
          +dep = R.Link.dep(B.link(w, edge))
          B.choose(~R.World, B.has(R.Node.config(B.node(w, dep)), K.CONFIG_HELD()),
            _ =>
              +pair = T.txOf(w, dep)
              +w = B.first(R.World, Nat, pair)
              B.choose(~R.World, B.ok(w), _ => T.holdNode(w, node, B.second(R.World, Nat, pair)), _ => w),
            _ => landHeld(p, w, node, R.Link.nextDep(B.link(w, edge)))))

# Source r === null || flight !== r guard precedes every side effect. Flight
# values admitted here are typed identity objects/errors; B.equal is JS ===
# on those identities (not a structural comparison of object payloads).
def land(+w: R.World, +state: R.DeferredState, +flight: R.Value, held: Bool) -> B.Bundle<R.World, R.DeferredState>:
  +cell = R.DeferredState.cell(state)
  B.choose(~B.Bundle<R.World, R.DeferredState>, Bool.or(B.equal(flight, R.Null{}), Bool.not(B.equal(R.DeferredCell.flight(cell), flight))),
    _ => B.Bundle{w, state},
    _ =>
      +node = R.DeferredCell.node(cell)
      +cell = R.DeferredCell.with_flight(cell, R.Null{})
      +lagging = P.remove(R.DeferredState.lagging(state), node)
      +w = B.choose(~R.World, held, _ => landHeld(B.budget(w), w, node, R.Node.deps(B.node(w, node))), _ => w)
      +wasMarked = R.DeferredCell.marked(cell)
      +cell = B.choose(~R.DeferredCell, Bool.and(wasMarked, B.ok(w)), _ => R.DeferredCell.with_marked(cell, False{}), _ => cell)
      +w = B.choose(~R.World, Bool.and(wasMarked, B.ok(w)),
        _ =>
          +pair = M.unmark(w, node)
          +w = B.first(R.World, Bool, pair)
          B.choose(~R.World, B.ok(w), _ => B.schedule(w), _ => w), _ => w)
      B.Bundle{w, R.DeferredState{cell, lagging}})

# Invoked by the source cleanup closure: ordinary reruns retain their flight;
# only actual node disposal ends it. Registration belongs to the future driver.
def end(+w: R.World, +state: R.DeferredState) -> B.Bundle<R.World, R.DeferredState>:
  +cell = R.DeferredState.cell(state)
  B.choose(~B.Bundle<R.World, R.DeferredState>, B.has(R.Node.flags(B.node(w, R.DeferredCell.node(cell))), K.REACTIVE_DISPOSED()),
    _ => land(w, state, R.DeferredCell.flight(cell), False{}), _ => B.Bundle{w, state})

# Source wrapper after getOwner/CONFIG_REDERIVE/cleanup(end), before calling fn.
# Real answers are sticky. A loadingValue window alone is not a real answer.
def openWindow(+w: R.World, +state: R.DeferredState) -> B.Bundle<R.World, R.DeferredState>:
  +cell = R.DeferredState.cell(state)
  +node = R.DeferredCell.node(cell)
  +n = B.node(w, node)
  +open = Bool.or(R.DeferredCell.answered(cell), Bool.and(Bool.not(B.has(R.Node.status(n), K.STATUS_UNINITIALIZED())), Bool.not(R.Node.loading(n))))
  +cell = R.DeferredCell.with_answered(cell, open)
  +w = B.choose(~R.World, open,
    _ =>
      +n = R.Node.with_loading(n, True{})
      B.store_node(w, node, R.Node.with_config(n, B.set(R.Node.config(n), K.CONFIG_LAGS()))), _ => w)
  B.Bundle{w, R.DeferredState.with_cell(state, cell)}

# This source catch registers an unready-source flight only inside the open
# window; the original exception always reaches recompute's error handler.
def sourceFailed(+w: R.World, +state: R.DeferredState, open: Bool, +error: R.Value) -> B.Bundle<R.World, R.DeferredState>:
  +pair = B.choose(~B.Bundle<R.World, R.DeferredState>, Bool.and(open, P.isNotReady(error)), _ => ask(w, state, error), _ => B.Bundle{w, state})
  B.Bundle{R.World.with_fault(B.first(R.World, R.DeferredState, pair), R.CallbackThrown{error}), B.second(R.World, R.DeferredState, pair)}

# `serve`'s selection AFTER actual handleAsync has returned. The future driver
# must execute handleAsync first, never pass in a fabricated stale answer.
def served(+w: R.World, node: Nat, value: R.Value) -> R.Value:
  +n = B.node(w, node)
  B.choose(~R.Value, Bool.and(B.has(R.Node.config(n), K.CONFIG_HELD()), B.present(R.Node.pending(n))), _ => B.selected(R.Node.pending(n), R.Undefined{}), _ => value)
