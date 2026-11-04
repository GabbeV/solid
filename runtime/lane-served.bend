# core/lanes.ts:laneServed. Capture the source Set handle once, then visit live
# slots in insertion order. Removal succeeds before settling that origin through
# the reader. Core's corresponding continuation uses the callback-aware driver.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./pending-state.bend as P
import ./pending.bend as Q

def removeLoop(fuel: Nat, +w: R.World, +reader: Nat, +set: Nat, +index: Nat) -> R.World:
  match fuel:
    case 0n: R.World.with_fault(w, R.Exhausted{})
    case 1n+p:
      B.choose(~R.World, Bool.and(B.ok(w), Nat.is_lt(index, B.length(Nat, B.pendingSlots(w, set)))),
        _ =>
          +source = B.get(Nat, B.pendingSlots(w, set), index, 0n)
          +w = B.choose(~R.World, Nat.is_eq(source, 0n), _ => w,
            _ =>
              +pair = P.removePendingSource(w, reader, source)
              +w = B.first(R.World, Bool, pair)
              B.choose(~R.World, B.second(R.World, Bool, pair), _ => Q.settlePendingSource(w, reader, source), _ => w))
          removeLoop(p, w, reader, set, 1n+index),
        _ => w)

# The raw helper's callback-free pending grammar cannot append to this captured
# Set. Core drives arbitrary admitted cleanup expressions without this bound.
def served(+w: R.World, +reader: Nat, source: Nat) -> R.World:
  +set = R.NodeExtension.pendingSources(B.extension(w, source))
  B.choose(~R.World, Bool.and(Nat.is_ne(set, 0n), Nat.is_ne(R.NodeExtension.pendingSources(B.extension(w, reader)), 0n)),
    _ => removeLoop(1n+B.length(Nat, B.pendingSlots(w, set)), w, reader, set, 0n), _ => w)
