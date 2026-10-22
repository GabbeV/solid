# deferred.ts closure allocation/callback lookup and shared module Set storage.
# IDs defunctionalize only callback identity; lifecycle decisions remain in D.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./deferred-lifecycle.bend as D
import ./deferred-state.bend as Walk

def blank() -> R.DeferredBinding:
  R.DeferredBinding{R.DeferredCell{0n, R.Null{}, False{}, False{}}, 0n}

def binding(w: R.World, id: Nat) -> R.DeferredBinding:
  B.get(R.DeferredBinding, R.DeferredArena.cells(R.World.deferredArena(w)), id, blank())

def cell(w: R.World, id: Nat) -> R.DeferredCell:
  R.DeferredBinding.cell(binding(w, id))

def state(+w: R.World, id: Nat) -> R.DeferredState:
  R.DeferredState{cell(w, id), R.DeferredArena.lagging(R.World.deferredArena(w))}

def store(+w: R.World, +id: Nat, +value: R.DeferredState) -> R.World:
  +arena = R.World.deferredArena(w)
  +old = binding(w, id)
  +cells = List.set(&2, R.DeferredBinding, R.DeferredArena.cells(arena), id, R.DeferredBinding.with_cell(old, R.DeferredState.cell(value)))
  R.World.with_deferredArena(w, R.DeferredArena.with_lagging(R.DeferredArena.with_cells(arena, cells), R.DeferredState.lagging(value)))

def returned(id: Nat, pair: B.Bundle<R.World, R.DeferredState>) -> R.World:
  match pair:
    case B.Bundle{w, state}:
      store(w, id, state)

def allocate(+w: R.World) -> B.Bundle<R.World, Nat>:
  +arena = R.World.deferredArena(w)
  +id = B.length(R.DeferredBinding, R.DeferredArena.cells(arena))
  +end = B.length(R.CleanupProgram, R.World.cleanupPrograms(w))
  +w = R.World.with_cleanupPrograms(w, B.append(R.CleanupProgram, R.World.cleanupPrograms(w), [R.CleanupProgram{[R.DeferredEnd{id}], False{}, 0n}]))
  +new: R.DeferredBinding = R.DeferredBinding{R.DeferredCell{0n, R.Null{}, False{}, False{}}, end}
  B.Bundle{R.World.with_deferredArena(w, R.DeferredArena.with_cells(arena, B.append(R.DeferredBinding, R.DeferredArena.cells(arena), [new]))), id}

def setNode(+w: R.World, +id: Nat, node: Nat) -> R.World:
  +state = state(w, id)
  store(w, id, R.DeferredState.with_cell(state, R.DeferredCell.with_node(R.DeferredState.cell(state), node)))

def openWindow(+w: R.World, +id: Nat) -> R.World:
  returned(id, D.openWindow(w, state(w, id)))

def ask(+w: R.World, +id: Nat, flight: R.Value) -> R.World:
  returned(id, D.ask(w, state(w, id), flight))

def land(+w: R.World, +id: Nat, flight: R.Value, held: Bool) -> R.World:
  returned(id, D.land(w, state(w, id), flight, held))

def end(+w: R.World, +id: Nat) -> R.World:
  returned(id, D.end(w, state(w, id)))

def sourceFailed(+w: R.World, +id: Nat, open: Bool, error: R.Value) -> R.World:
  returned(id, D.sourceFailed(w, state(w, id), open, error))

def served(+w: R.World, id: Nat, value: R.Value) -> R.Value:
  D.served(w, R.DeferredCell.node(cell(w, id)), value)

def registerWait(+w: R.World, observer: Nat, id: Nat, flight: R.Value) -> R.World:
  +arena = R.World.deferredArena(w)
  R.World.with_deferredArena(w, R.DeferredArena.with_waits(arena, B.append(R.DeferredWait, R.DeferredArena.waits(arena), [R.DeferredWait{observer, id, flight}])))

def findWait(items: List<&2, R.DeferredWait>, +observer: Nat) -> Maybe<&2, R.DeferredWait>:
  match items:
    case Nil{}: None{}
    case +wait <> rest:
      B.choose(~Maybe<&2, R.DeferredWait>, Nat.is_eq(R.DeferredWait.observer(wait), observer), _ => Some{wait}, _ => findWait(rest, observer))

def wait(w: R.World, observer: Nat) -> Maybe<&2, R.DeferredWait>:
  findWait(R.DeferredArena.waits(R.World.deferredArena(w)), observer)

def deliver(w: R.World, wait: R.DeferredWait) -> R.World:
  match wait:
    case R.DeferredWait{observer, id, flight}:
      land(w, id, flight, True{})

def lagging(+w: R.World, node: Nat) -> B.Bundle<R.World, Nat>:
  Walk.laggingOf(w, R.DeferredArena.lagging(R.World.deferredArena(w)), node)
