# Concrete end-to-end lifecycle controls for signals.ts:onSettled. This uses
# actual construction, queue/heap driver, commits and owner disposal.
import Base
import ../runtime/api.bend as A
import ../representation/base.bend as B
import ../representation/records.bend as R

type View is Data:
  View{before: R.Value, first: R.Value, second: R.Value, cleaned: R.Value,
    nodes: Nat, initialQueue: List<&2, R.QueueEntry>, callbacks: Nat,
    context: Nat, tracking: Bool, stale: Bool, users: List<&2, R.QueueEntry>,
    pending: List<&2, Nat>, scheduled: Bool, fault: R.Fault}

def scenario(+owned: Bool) -> View:
  w = A.createSignal(A.createWorld(), R.Number{0n}, True{})
  w = A.createSignal(w, R.Number{0n}, True{})
  w = A.createSignal(w, R.Number{0n}, True{})
  w = A.registerProgram(w, A.programUpdateExpr(4n, R.Add{R.Previous{}, R.Literal{R.Number{1n}}}, A.emptyProgram()))
  +made = A.onSettled(1024n, w, R.Then{R.WriteExpr{3n, R.Read{2n}, False{}}, R.Literal{R.ProgramReference{1n}}}, B.choose(~Nat, owned, _ => 1n, _ => 0n))
  +first = A.flush(2048n, A.setSignal(made, 2n, R.Number{7n}))
  +second = A.flush(2048n, A.setSignal(first, 2n, R.Number{9n}))
  +done = A.flush(2048n, A.dispose(second, 1n))
  View{R.Node.value(B.node(made, 3n)), R.Node.value(B.node(first, 3n)), R.Node.value(B.node(second, 3n)), R.Node.value(B.node(done, 4n)),
    B.length(R.Node, R.World.nodes(made)), R.World.userQueue(made), B.length(R.Expr, R.World.settledCallbacks(made)),
    R.World.context(done), R.World.tracking(done), R.World.stale(done), R.World.userQueue(done), R.World.pendingNodes(done), R.World.scheduled(done), R.World.fault(done)}

def expectedOwned() -> View:
  View{R.Number{0n}, R.Number{7n}, R.Number{7n}, R.Number{1n}, 6n, [], 1n,
    0n, False{}, False{}, [], [], False{}, R.Healthy{}}

def expectedUnowned() -> View:
  View{R.Number{0n}, R.Number{7n}, R.Number{7n}, R.Number{0n}, 5n, [R.SettledFire{1n}], 2n,
    0n, False{}, False{}, [], [], False{}, R.Healthy{}}
