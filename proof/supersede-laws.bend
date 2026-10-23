# The actual internal helper and core finally continuations. No graph/stream
# progress theorem is claimed by these local all-World properties.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/supersede.bend as S
import ../runtime/core.bend as C
import ../runtime/constants.bend as K

def sameNat(+n: Nat) -> {Nat.is_eq(n, n) == True{} : Bool}:
  match n:
    case 0n: {==}
    case 1n+p: sameNat(p)

def reflexive(+slot: R.Flight) -> {B.sameFlight(slot, slot) == True{} : Bool}:
  match slot:
    case R.FlightUndefined{}: {==}
    case R.FlightEmpty{}: {==}
    case R.FlightActive{result}: sameNat(result)

def undefinedNotNull() -> {B.sameFlight(R.FlightUndefined{}, R.FlightEmpty{}) == False{} : Bool}:
  {==}

def nullNotUndefined() -> {B.sameFlight(R.FlightEmpty{}, R.FlightUndefined{}) == False{} : Bool}:
  {==}

def activeIdentity(result: Nat) -> {B.flightId(R.FlightActive{result}) == result : Nat}:
  {==}

def absent(+w: R.World, +id: Nat, known: {R.Node.x(B.node(w, id)) == 0n : Nat}) ->
  {B.flight(w, id) == R.FlightUndefined{} : R.Flight}:
  Equal.cong(Nat, R.Flight, x => B.choose(~R.Flight, Nat.is_eq(x, 0n),
    _ => R.FlightUndefined{}, _ => R.NodeExtension.inFlight(B.extension(w, id))), R.Node.x(B.node(w, id)), 0n, known)

def ineligible(+w: R.World, +callback: Nat, known: {S.eligible(w) == False{} : Bool}) ->
  {S.register(w, callback) == w : R.World}:
  Equal.cong(Bool, R.World, yes => B.choose(~R.World, yes, _ => S.registerEligible(w, callback), _ => w), S.eligible(w), False{}, known)

def unowned(+w: R.World, +callback: Nat, known: {R.World.context(w) == 0n : Nat}) ->
  {S.register(w, callback) == w : R.World}:
  ineligible(w, callback, Equal.cong(Nat, Bool, id => Bool.and(Nat.is_ne(id, 0n), Bool.and(B.computed(R.Node.kind(B.node(w, id))), B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_RECOMPUTING_DEPS()))), R.World.context(w), 0n, known))

def chainWorld(+w: R.World, before: Nat, after: Nat) ->
  {B.first(R.World, Nat, S.chain(w, before, after)) == R.World.with_cleanupPrograms(w, B.append(R.CleanupProgram, R.World.cleanupPrograms(w), [R.CleanupProgram{[R.SupersedeChain{before, after}], False{}, 0n}])) : R.World}:
  {==}

def chainIdentity(w: R.World, before: Nat, after: Nat) ->
  {B.second(R.World, Nat, S.chain(w, before, after)) == B.length(R.CleanupProgram, R.World.cleanupPrograms(w)) : Nat}:
  {==}

def finallyEntry(+w: R.World, rest: List<&2, C.Task>, callback: Nat, +saved: List<&2, R.Value>) ->
  {C.supersedeFinally(w, rest, callback, saved) == C.Machine{R.World.with_fault(w, R.Healthy{}), C.Evaluate{R.CallProgram{callback}, R.Undefined{}} <> C.SupersedeRestore{R.World.fault(w), saved} <> rest, saved} : C.Machine}:
  {==}

def finallyReturn(w: R.World, rest: List<&2, C.Task>, stack: List<&2, R.Value>, callback: Nat, saved: List<&2, R.Value>) ->
  {C.dispatch(w, C.SupersedeFinally{callback, saved} <> rest, stack) == C.supersedeFinally(w, rest, callback, saved) : C.Machine}:
  {==}

def finallyThrow(w: R.World, rest: List<&2, C.Task>, stack: List<&2, R.Value>, callback: Nat, saved: List<&2, R.Value>) ->
  {C.unwind(w, C.SupersedeFinally{callback, saved} <> rest, stack) == C.supersedeFinally(w, rest, callback, saved) : C.Machine}:
  {==}

def restoreSuccess(w: R.World, rest: List<&2, C.Task>, stack: List<&2, R.Value>, prior: R.Fault, saved: List<&2, R.Value>) ->
  {C.dispatch(w, C.SupersedeRestore{prior, saved} <> rest, stack) == C.Machine{R.World.with_fault(w, prior), rest, saved} : C.Machine}:
  {==}

def overrideFailure(w: R.World, rest: List<&2, C.Task>, stack: List<&2, R.Value>, prior: R.Fault, saved: List<&2, R.Value>) ->
  {C.unwind(w, C.SupersedeRestore{prior, saved} <> rest, stack) == C.Machine{w, rest, saved} : C.Machine}:
  {==}

# The captured closure must also return undefined through the ordinary
# callback tail; its callers discard that actual returned value.
def chainContinuation(w: R.World, rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +tail: List<&2, R.CleanupAction>, +first: R.Value, +second: R.Value, before: Nat, after: Nat) ->
  {C.callbackAction(w, rest, stack, id, tail, first, second, R.SupersedeChain{before, after}) == C.Machine{w, C.Evaluate{R.CallProgram{before}, R.Undefined{}} <> C.SupersedeFinally{after, stack} <> C.Callback{id, tail, first, second} <> rest, stack} : C.Machine}:
  {==}
