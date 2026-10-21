# signals.ts:createReaction closure cells and its two callable identities.
# The arena is lexical state, not additional reactive nodes or subscriptions.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./construct-state.bend as N
import ./owner.bend as O

def get(w: R.World, id: Nat) -> R.ReactionState:
  B.get(R.ReactionState, R.World.reactions(w), id, R.ReactionState{0n, 0n, R.Undefined{}, R.Literal{R.Undefined{}}, 0n, N.defaults(), False{}, 0n})

def store(+w: R.World, id: Nat, state: R.ReactionState) -> R.World:
  R.World.with_reactions(w, List.set(&2, R.ReactionState, R.World.reactions(w), id, state))

# cl starts undefined; cleanup closes over the cell, then owner is captured.
# The returned track function is a first-class existing ProgramReference.
def create(+w: R.World, body: R.Expr, errorProgram: Nat, options: R.NodeOptions, scheduled: Bool) -> B.Bundle<R.World, R.Value>:
  +id = B.length(R.ReactionState, R.World.reactions(w))
  +lifecycle = B.length(R.CleanupProgram, R.World.cleanupPrograms(w))
  +track = Nat.add(1n, lifecycle)
  +w = R.World.with_reactions(w, B.append(R.ReactionState, R.World.reactions(w), [R.ReactionState{0n, 0n, R.Undefined{}, body, errorProgram, options, scheduled, track}]))
  +w = R.World.with_cleanupPrograms(w, B.append(R.CleanupProgram, R.World.cleanupPrograms(w), [R.CleanupProgram{[R.ReactionLifecycle{id}], False{}, 0n}, R.CleanupProgram{[R.ReactionTrack{id}], False{}, 1n}]))
  +w = O.cleanup(w, R.World.context(w), lifecycle)
  +w = store(w, id, R.ReactionState.with_owner(get(w, id), R.World.context(w)))
  B.Bundle{w, R.ProgramReference{track}}
