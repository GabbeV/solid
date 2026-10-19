# core/owner.ts:createOwner production literal shared by constructor facades
# and createRoot's callback continuation. No reactive driver is imported here.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./constants.bend as K
import ./owner.bend as O

def createOwner(+w: R.World, +parent: Nat, transparent: Bool) -> R.World:
  +id = B.length(R.Node, R.World.nodes(w))
  n = {R.Node{R.Root{}, R.Undefined{}, R.Empty{}, True{}, B.choose(~U32, transparent, _ => K.CONFIG_TRANSPARENT(), _ => 0),
    K.REACTIVE_NONE(), 0, 0n, R.Unstamped{}, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n,
    parent, 0n, 0n, 0n, R.Literal{R.Undefined{}}, False{}, R.Undefined{}, 0n, False{},
    0n, B.parentComputed(w, parent), R.Node.scope(B.node(w, parent)), 0n, R.NoDisposal{}, 0n, 0n, 0n, 0n} : R.Node}
  +w = R.World.with_nodes(w, B.append(R.Node, R.World.nodes(w), [n]))
  B.choose(~R.World, Nat.is_ne(parent, 0n), _ => O.linkChild(w, parent, id), _ => w)

