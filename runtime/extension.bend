# core/core.ts:ext. Node.x is a nullable stable identity into World.extensions;
# callback/flight/transaction fields are nullable host identities, not engines.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B

def ext(+w: R.World, +id: Nat) -> R.World:
  B.choose(~R.World, Nat.is_ne(R.Node.x(B.node(w, id)), 0n), _ => w,
    _ =>
      +x = B.length(R.NodeExtension, R.World.extensions(w))
      +w = R.World.with_extensions(w, B.append(R.NodeExtension, R.World.extensions(w), [B.blank_extension()]))
      B.store_node(w, id, R.Node.with_x(B.node(w, id), x)))
