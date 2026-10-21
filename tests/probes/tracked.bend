import Base
import ../../runtime/api.bend as A
import ../../runtime/core.bend as C
import ../../runtime/constants.bend as K
import ../../representation/records.bend as R
import ../../representation/base.bend as B

def runs(copies: Nat) -> List<&2, C.Task>:
  match copies:
    case 0n:
      []
    case 1n+p:
      C.RunTracked{4n} <> runs(p)


def fixture(+copies: Nat, modified: Bool, dead: Bool, stale: Bool) -> R.World:
  w = A.createSignal(A.createWorld(), R.Number{7n}, True{})
  w = A.createSignal(w, R.Number{0n}, True{})
  w = R.World.with_stale(w, stale)
  +w = A.createTrackedEffect(1024n, w, R.Then{R.WriteExpr{3n, R.Read{2n}, False{}}, R.Literal{R.Undefined{}}}, 1n)
  +w = B.store_node(w, 4n, R.Node.with_modified(B.node(w, 4n), modified))
  +w = B.choose(~R.World, dead, _ => B.store_node(w, 4n, R.Node.with_flags(B.node(w, 4n), B.set(R.Node.flags(B.node(w, 4n)), K.REACTIVE_DISPOSED()))), _ => w)
  C.world(C.run(4096n, C.Machine{w, runs(copies), []}))
