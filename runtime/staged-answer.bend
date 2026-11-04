# core/core.ts:servesStaged, reached only by a pending read that would throw.
# Clock zero remains distinct from the optional undefined _served stamp.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./constants.bend as K
import ./extension.bend as E
import ./pending-state.bend as P

def latch(+w: R.World, +reader: Nat) -> B.Bundle<R.World, Bool>:
  +w = E.ext(w, reader)
  +w = B.store_extension(w, reader, R.NodeExtension.with_served(B.extension(w, reader), R.Stamped{R.World.clock(w)}))
  B.Bundle{B.store_node(w, reader, R.Node.with_flags(B.node(w, reader), B.set(R.Node.flags(B.node(w, reader)), K.REACTIVE_MISSED_WAKE()))), True{}}

def servesStaged(+w: R.World, +reader: Nat, +id: Nat, +owner: Nat) -> B.Bundle<R.World, Bool>:
  +eligible = Bool.and(Nat.is_eq(R.World.passLane(w), 0n), Bool.and(B.has(U32.and(R.Node.status(B.node(w, reader)), R.Node.status(B.node(w, owner))), K.STATUS_UNINITIALIZED()), Bool.and(B.present(R.Node.pending(B.node(w, id))), Bool.and(Bool.not(B.has(R.Node.config(B.node(w, id)), B.set(K.CONFIG_HELD(), K.CONFIG_STAGED_ERROR()))), Bool.not(B.effect(R.Node.kind(B.node(w, reader))))))))
  B.choose(~B.Bundle<R.World, Bool>, eligible,
    _ => B.choose(~B.Bundle<R.World, Bool>, B.has(R.Node.flags(B.node(w, reader)), K.REACTIVE_MISSED_WAKE()), _ => B.Bundle{w, True{}},
      _ => B.choose(~B.Bundle<R.World, Bool>, Bool.and(Bool.not(B.present(R.Node.pending(B.node(w, reader)))), Bool.not(B.stampMatches(R.NodeExtension.served(B.extension(w, reader)), R.World.clock(w)))),
        _ => B.choose(~B.Bundle<R.World, Bool>, B.has(R.Node.status(B.node(w, reader)), K.STATUS_PENDING()),
          _ =>
            +pair = P.deletePendingSourceSlot(w, reader, P.notReadySource(R.NodeExtension.error(B.extension(w, owner))))
            +w = B.first(R.World, Bool, pair)
            B.choose(~B.Bundle<R.World, Bool>, B.second(R.World, Bool, pair), _ => latch(w, reader), _ => B.Bundle{w, False{}}),
          _ => latch(w, reader)),
        _ => B.Bundle{w, False{}})),
    _ => B.Bundle{w, False{}})
