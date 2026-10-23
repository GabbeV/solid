# core/async.ts:onSupersede. Captured callbacks use the existing callable
# programme IDs; a chained programme represents the source try/finally closure.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./extension.bend as E
import ./constants.bend as K

def eligible(+w: R.World) -> Bool:
  +id = R.World.context(w)
  Bool.and(Nat.is_ne(id, 0n), Bool.and(B.computed(R.Node.kind(B.node(w, id))), B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_RECOMPUTING_DEPS())))

def chain(+w: R.World, before: Nat, after: Nat) -> B.Bundle<R.World, Nat>:
  +callback = B.length(R.CleanupProgram, R.World.cleanupPrograms(w))
  B.Bundle{R.World.with_cleanupPrograms(w, B.append(R.CleanupProgram, R.World.cleanupPrograms(w), [R.CleanupProgram{[R.SupersedeChain{before, after}], False{}, 0n}])), callback}

def registerEligible(+w: R.World, +callback: Nat) -> R.World:
  +id = R.World.context(w)
  +fresh = Nat.is_eq(R.Node.x(B.node(w, id)), 0n)
  +w = E.ext(w, id)
  +x = B.extension(w, id)
  +w = B.choose(~R.World, fresh,
    _ => B.store_extension(w, id, R.NodeExtension.with_inFlight(x, R.FlightUndefined{})), _ => w)
  +previous = R.NodeExtension.flightTeardown(B.extension(w, id))
  +pair = B.choose(~B.Bundle<R.World, Nat>, Nat.is_eq(previous, 0n),
    _ => B.Bundle{w, callback}, _ => chain(w, previous, callback))
  +w = B.first(R.World, Nat, pair)
  B.store_extension(w, id, R.NodeExtension.with_flightTeardown(B.extension(w, id), B.second(R.World, Nat, pair)))

def register(+w: R.World, +callback: Nat) -> R.World:
  B.choose(~R.World, eligible(w), _ => registerEligible(w, callback), _ => w)
