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

# Proof-only post-catch packaging, retaining the original thrown value.
def failed(+pair: B.Bundle<R.World, R.DeferredState>, error: R.Value) -> B.Bundle<R.World, R.DeferredState>:
  B.Bundle{R.World.with_fault(B.first(R.World, R.DeferredState, pair), R.CallbackThrown{error}), B.second(R.World, R.DeferredState, pair)}

# #4231 changes the old state-preserving conclusion to ending any old flight.
# The arbitrary World/state/error domain is retained.
def closedFailure(w: R.World, state: R.DeferredState, error: R.Value) -> {D.sourceFailed(w, state, False{}, error) == failed(D.land(w, state, R.DeferredCell.flight(R.DeferredState.cell(state)), False{}), error) : B.Bundle<R.World, R.DeferredState>}:
  {==}

def cmpSelf(+n: Nat) -> {Nat.cmp(n, n) == EQ{} : Cmp}:
  match n:
    case 0n: {==}
    case 1n+p: cmpSelf(p)

def unmarkedCase(+w: R.World, +node: Nat, flight: Nat, error: Nat, +answered: Bool, +lagging: List<&2, Nat>, order: Cmp) -> B.Bundle<R.World, R.DeferredState>:
  failed(B.choose(~B.Bundle<R.World, R.DeferredState>, Bool.not(Cmp.is_eq(order)),
    _ => B.Bundle{w, R.DeferredState{R.DeferredCell{node, R.Reference{flight}, False{}, answered}, lagging}},
    _ => B.Bundle{w, R.DeferredState{R.DeferredCell{node, R.Null{}, False{}, answered}, P.remove(lagging, node)}}), R.Reference{error})

def plainUnmarkedFailure(w: R.World, node: Nat, +flight: Nat, error: Nat, answered: Bool, lagging: List<&2, Nat>) ->
  {D.sourceFailed(w, R.DeferredState{R.DeferredCell{node, R.Reference{flight}, False{}, answered}, lagging}, True{}, R.Reference{error}) == B.Bundle{R.World.with_fault(w, R.CallbackThrown{R.Reference{error}}), R.DeferredState{R.DeferredCell{node, R.Null{}, False{}, answered}, P.remove(lagging, node)}} : B.Bundle<R.World, R.DeferredState>}:
  Equal.cong(Cmp, B.Bundle<R.World, R.DeferredState>, order => unmarkedCase(w, node, flight, error, answered, lagging, order), Nat.cmp(flight, flight), EQ{}, cmpSelf(flight))

def unreadyFailure(w: R.World, state: R.DeferredState, identity: Nat, source: Nat) ->
  {D.sourceFailed(w, state, True{}, R.NotReadyFailure{identity, source}) == failed(D.ask(w, state, R.NotReadyFailure{identity, source}), R.NotReadyFailure{identity, source}) : B.Bundle<R.World, R.DeferredState>}:
  {==}

def answeredSticky(w: R.World, node: Nat, flight: R.Value, marked: Bool, lagging: List<&2, Nat>) -> {R.DeferredCell.answered(R.DeferredState.cell(B.second(R.World, R.DeferredState, D.openWindow(w, R.DeferredState{R.DeferredCell{node, flight, marked, True{}}, lagging})))) == True{} : Bool}:
  {==}
