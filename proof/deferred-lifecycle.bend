# Quantified closure-local lifecycle boundaries; not a constructor theorem.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P
import ../runtime/constants.bend as K
import ../runtime/deferred-lifecycle.bend as D

def nullLand(w: R.World, state: R.DeferredState, held: Bool) -> {D.land(w, state, R.Null{}, held) == B.Bundle{w, state} : B.Bundle<R.World, R.DeferredState>}:
  {==}

def staleLand(w: R.World, node: Nat, marked: Bool, answered: Bool, lagging: List<&2, Nat>, held: Bool) -> {D.land(w, R.DeferredState{R.DeferredCell{node, R.Reference{1n}, marked, answered}, lagging}, R.Reference{2n}, held) == B.Bundle{w, R.DeferredState{R.DeferredCell{node, R.Reference{1n}, marked, answered}, lagging}} : B.Bundle<R.World, R.DeferredState>}:
  {==}

def unmarkedLand(w: R.World, node: Nat, answered: Bool, lagging: List<&2, Nat>) -> {D.land(w, R.DeferredState{R.DeferredCell{node, R.Reference{1n}, False{}, answered}, lagging}, R.Reference{1n}, False{}) == B.Bundle{w, R.DeferredState{R.DeferredCell{node, R.Null{}, False{}, answered}, P.remove(lagging, node)}} : B.Bundle<R.World, R.DeferredState>}:
  {==}

def markedAsk(w: R.World, node: Nat, prior: R.Value, flight: R.Value, answered: Bool, lagging: List<&2, Nat>) -> {D.ask(w, R.DeferredState{R.DeferredCell{node, prior, True{}, answered}, lagging}, flight) == B.Bundle{w, R.DeferredState{R.DeferredCell{node, flight, True{}, answered}, B.choose(~List<&2, Nat>, B.contains(lagging, node), _ => lagging, _ => B.append(Nat, lagging, [node]))}} : B.Bundle<R.World, R.DeferredState>}:
  {==}

def sameChoice(~A: Data, +flag: Bool, +value: A) -> {B.choose(~A, flag, _ => value, _ => value) == value : A}:
  match flag:
    case True{}: {==}
    case False{}: {==}

def idleEnd(+w: R.World, +node: Nat, marked: Bool, answered: Bool, lagging: List<&2, Nat>) -> {D.end(w, R.DeferredState{R.DeferredCell{node, R.Null{}, marked, answered}, lagging}) == B.Bundle{w, R.DeferredState{R.DeferredCell{node, R.Null{}, marked, answered}, lagging}} : B.Bundle<R.World, R.DeferredState>}:
  sameChoice(~B.Bundle<R.World, R.DeferredState>, B.has(R.Node.flags(B.node(w, node)), K.REACTIVE_DISPOSED()), B.Bundle{w, R.DeferredState{R.DeferredCell{node, R.Null{}, marked, answered}, lagging}})

def emptyHeld(+fuel: Nat, w: R.World, node: Nat) -> {D.landHeld(fuel, w, node, 0n) == w : R.World}:
  match fuel:
    case 0n: {==}
    case 1n+p: {==}

def closedFailure(w: R.World, state: R.DeferredState, error: R.Value) -> {D.sourceFailed(w, state, False{}, error) == B.Bundle{R.World.with_fault(w, R.CallbackThrown{error}), state} : B.Bundle<R.World, R.DeferredState>}:
  {==}

def answeredSticky(w: R.World, node: Nat, flight: R.Value, marked: Bool, lagging: List<&2, Nat>) -> {R.DeferredCell.answered(R.DeferredState.cell(B.second(R.World, R.DeferredState, D.openWindow(w, R.DeferredState{R.DeferredCell{node, flight, marked, True{}}, lagging})))) == True{} : Bool}:
  {==}
