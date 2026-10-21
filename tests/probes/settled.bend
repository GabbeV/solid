import Base
import ../../runtime/api.bend as A
import ../../runtime/core.bend as C
import ../../runtime/transaction.bend as X
import ../../representation/records.bend as R
import ../../representation/base.bend as B

def fires(copies: Nat) -> List<&2, C.Task>:
  match copies:
    case 0n:
      []
    case 1n+p:
      C.FireSettled{1n} <> fires(p)

def fixture(copies: Nat, minimum: Nat, maximum: Nat, lane: Bool) -> R.World:
  w = A.createSignal(A.createWorld(), R.Number{0n}, True{})
  w = A.onSettled(1024n, w, R.Then{R.Read{2n}, R.WriteExpr{2n, R.Literal{R.Number{7n}}, False{}}}, 0n)
  +pair = X.newTransaction(w, True{}, 0n)
  +w = B.first(R.World, Nat, pair)
  w = R.World.with_userQueue(w, [])
  w = R.World.with_scheduled(w, False{})
  w = R.World.with_passLane(w, B.choose(~Nat, lane, _ => B.second(R.World, Nat, pair), _ => 0n))
  w = R.World.with_minimum(R.World.with_maximum(w, maximum), minimum)
  C.world(C.run(4096n, C.Machine{w, fires(copies), []}))
