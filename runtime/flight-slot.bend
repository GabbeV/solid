# core/async.ts:clearInFlight, shared by owner/loading/disposed-pass sites.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B

def clearInFlight(+w: R.World, +id: Nat) -> R.World:
  B.choose(~R.World, Nat.is_ne(R.Node.x(B.node(w, id)), 0n),
    _ => B.store_extension(w, id, R.NodeExtension.with_inFlight(B.extension(w, id), R.FlightEmpty{})), _ => w)
