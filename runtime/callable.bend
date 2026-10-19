# Canonical callable encoding for init-bound root disposers in owner disposal
# slots. Value identity is the root ID; the existing callback arena needs one
# canonical callable ID for that same function, shared by every registration.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./owner.bend as O

def bound(actions: List<&2, R.CleanupAction>, +root: Nat) -> Bool:
  match actions:
    case R.CleanupBoundRoot{owner} <> Nil{}:
      Nat.is_eq(owner, root)
    case _:
      False{}

def find(programs: List<&2, R.CleanupProgram>, +root: Nat, +index: Nat) -> Nat:
  match programs:
    case Nil{}:
      0n
    case program <> rest:
      B.choose(~Nat, bound(R.CleanupProgram.actions(program), root),
        _ => index, _ => find(rest, root, Nat.add(index, 1n)))

def encode(+w: R.World, +root: Nat) -> B.Bundle<R.World, Nat>:
  +old = find(R.World.cleanupPrograms(w), root, 0n)
  B.choose(~B.Bundle<R.World, Nat>, Nat.is_ne(old, 0n), _ => B.Bundle{w, old},
    _ =>
      +next = B.length(R.CleanupProgram, R.World.cleanupPrograms(w))
      B.Bundle{R.World.with_cleanupPrograms(w, B.append(R.CleanupProgram, R.World.cleanupPrograms(w), [R.CleanupProgram{[R.CleanupBoundRoot{root}]}])), next})

# Source cleanup returns without touching a disposal slot when context is null.
def cleanup(+w: R.World, +owner: Nat, root: Nat) -> R.World:
  B.choose(~R.World, Nat.is_eq(owner, 0n), _ => w,
    _ =>
      +pair = encode(w, root)
      O.cleanup(B.first(R.World, Nat, pair), owner, B.second(R.World, Nat, pair)))

# signals.ts:accessor, read.bind(null,node). The node ID captures the bound
# receiver argument and the refresh target; symbol/property reflection remains
# outside the admitted grammar. Native callable identity is materialized once
# per signal by the host codec; invocation enters core's ordinary read machine.
def accessor(node: Nat) -> R.Value:
  R.AccessorReference{node}

# signals.ts:createSignal binds setSignal for data and setMemo for the
# function overload. Both capture this unique node ID; core selects the actual
# entry for the constructor-selected target. Read and write identities differ.
def setter(node: Nat) -> R.Value:
  R.SetterReference{node}

# A setter has its own canonical callback encoding, separate from root dispose.
def boundSetter(actions: List<&2, R.CleanupAction>, +signal: Nat) -> Bool:
  match actions:
    case R.CleanupBoundSetter{id} <> Nil{}:
      Nat.is_eq(id, signal)
    case _:
      False{}

def findSetter(programs: List<&2, R.CleanupProgram>, +signal: Nat, +index: Nat) -> Nat:
  match programs:
    case Nil{}:
      0n
    case program <> rest:
      B.choose(~Nat, boundSetter(R.CleanupProgram.actions(program), signal),
        _ => index, _ => findSetter(rest, signal, Nat.add(index, 1n)))

def encodeSetter(+w: R.World, +signal: Nat) -> B.Bundle<R.World, Nat>:
  +old = findSetter(R.World.cleanupPrograms(w), signal, 0n)
  B.choose(~B.Bundle<R.World, Nat>, Nat.is_ne(old, 0n), _ => B.Bundle{w, old},
    _ =>
      +next = B.length(R.CleanupProgram, R.World.cleanupPrograms(w))
      B.Bundle{R.World.with_cleanupPrograms(w, B.append(R.CleanupProgram, R.World.cleanupPrograms(w), [R.CleanupProgram{[R.CleanupBoundSetter{signal}]}])), next})

def cleanupSetter(+w: R.World, +owner: Nat, signal: Nat) -> R.World:
  B.choose(~R.World, Nat.is_eq(owner, 0n), _ => w,
    _ =>
      +pair = encodeSetter(w, signal)
      O.cleanup(B.first(R.World, Nat, pair), owner, B.second(R.World, Nat, pair)))
