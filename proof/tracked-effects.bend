# Actual tracked-effect construction, heap -> user queue -> recompute, and
# lifecycle cleanup through the shared driver. Explicit inputs, not TS equivalence.
import Base
import ../runtime/api.bend as A
import ../runtime/ambient.bend as L
import ../representation/base.bend as B
import ../representation/records.bend as R

type View is Data:
  View{before: R.Value, first: R.Value, second: R.Value, input: R.Value,
    cleanup: R.Value, dead: Bool, context: Nat, tracking: Bool, stale: Bool,
    pending: List<&2, Nat>, renders: List<&2, Nat>, users: List<&2, Nat>,
    scheduled: Bool, fault: R.Fault}

def phase() -> View:
  w = A.createSignal(A.createWorld(), R.Number{0n}, True{})
  w = A.createSignal(w, R.Number{0n}, True{})
  +made = A.createTrackedEffect(1024n, w, R.Then{R.WriteExpr{3n, R.Read{2n}, False{}}, R.Literal{R.Undefined{}}}, 1n)
  +first = A.flush(2048n, A.setSignal(made, 2n, R.Number{7n}))
  +done = A.flush(2048n, A.setSignal(first, 2n, R.Number{9n}))
  View{R.Node.value(B.node(made, 3n)), R.Node.value(B.node(first, 3n)), R.Node.value(B.node(done, 3n)), R.Node.value(B.node(done, 2n)),
    R.Undefined{}, L.isDisposed(done, 1n), R.World.context(done), R.World.tracking(done), R.World.stale(done),
    R.World.pendingNodes(done), R.World.renderQueue(done), R.World.userQueue(done), R.World.scheduled(done), R.World.fault(done)}

def expectedPhase() -> View:
  View{R.Number{0n}, R.Number{7n}, R.Number{9n}, R.Number{9n}, R.Undefined{}, False{},
    0n, False{}, False{}, [], [], [], False{}, R.Healthy{}}

def cleanup() -> View:
  w = A.createSignal(A.createWorld(), R.Number{0n}, True{})
  w = A.createSignal(w, R.Number{0n}, True{})
  w = A.registerProgram(w, A.programUpdateExpr(3n, R.Add{R.Previous{}, R.Literal{R.Number{1n}}}, A.emptyProgram()))
  +made = A.createTrackedEffect(1024n, w, R.Then{R.Read{2n}, R.Literal{R.ProgramReference{1n}}}, 1n)
  +first = A.flush(2048n, made)
  +second = A.flush(2048n, A.setSignal(first, 2n, R.Number{1n}))
  +done = A.flush(2048n, A.dispose(second, 1n))
  View{R.Node.value(B.node(made, 3n)), R.Node.value(B.node(first, 3n)), R.Node.value(B.node(second, 3n)), R.Node.value(B.node(done, 2n)),
    R.Node.value(B.node(done, 3n)), L.isDisposed(done, 1n), R.World.context(done), R.World.tracking(done), R.World.stale(done),
    R.World.pendingNodes(done), R.World.renderQueue(done), R.World.userQueue(done), R.World.scheduled(done), R.World.fault(done)}

def expectedCleanup() -> View:
  View{R.Number{0n}, R.Number{0n}, R.Number{1n}, R.Number{1n}, R.Number{2n}, True{},
    0n, False{}, False{}, [], [], [], False{}, R.Healthy{}}
