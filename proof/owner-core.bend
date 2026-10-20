# Direct owner/core bridge fixture: an owner program reads a lazy memo while
# the caller has a live arithmetic operand. No public teardown-domain claim.
import Base
import ../runtime/api.bend as A
import ../runtime/construct.bend as N
import ../runtime/owner.bend as O
import ../runtime/ambient.bend as L
import ../representation/base.bend as B
import ../representation/records.bend as R

# Three concrete async cleanup paths. The cleanup performs an actual lazy
# read and write through the same core machine; the released node's owner
# remains alive. Explicit thenable settlement is the external host input.
type AsyncCleanupView is Data:
  AsyncCleanupView{value: R.Value, marker: R.Value, reader: R.Value,
    released: Bool, deps: Nat, disposal: R.Disposal, ownerDead: Bool,
    renders: List<&2, Nat>, users: List<&2, Nat>, intake: List<&2, Nat>,
    context: Nat, tracking: Bool, running: Bool, scheduled: Bool, fault: R.Fault}

def asyncCleanupView(+w: R.World, published: Nat, +released: Nat, marker: Nat, reader: Nat) -> AsyncCleanupView:
  AsyncCleanupView{R.Node.value(B.node(w, published)), R.Node.value(B.node(w, marker)), R.Node.value(B.node(w, reader)),
    L.isDisposed(w, released), R.Node.deps(B.node(w, released)), R.Node.disposal(B.node(w, released)), L.isDisposed(w, 1n),
    R.World.renderQueue(w), R.World.userQueue(w), R.World.pendingNodes(w), R.World.context(w), R.World.tracking(w), R.World.running(w), R.World.scheduled(w), R.World.fault(w)}

def expectedAsyncCleanup() -> AsyncCleanupView:
  AsyncCleanupView{R.Number{8n}, R.Number{7n}, R.Number{7n}, True{}, 0n, R.NoDisposal{}, False{}, [], [], [], 0n, False{}, False{}, False{}, R.Healthy{}}

def asyncAutodispose() -> AsyncCleanupView:
  w = A.createSignal(A.createWorld(), R.Number{0n}, True{})
  w = A.createSignal(w, R.Number{7n}, True{})
  w = A.createMemoWithOptions(1024n, w, R.Read{3n}, R.NodeOptions.with_lazy(N.defaults(), True{}), 0n)
  w = A.createThenable(w, True{})
  w = A.createMemoWithOptions(1024n, w, R.Then{R.OnCleanup{R.Literal{R.ProgramReference{1n}}}, R.Literal{R.AsyncValue{1n}}}, R.NodeOptions.with_lazy(N.defaults(), True{}), 1n)
  w = A.registerProgram(w, A.programWriteExpr(2n, R.Read{4n}, A.emptyProgram()))
  w = A.resultWorld(A.read(1024n, w, 5n))
  w = R.World.with_fault(w, R.Healthy{})
  +done = A.flush(2048n, A.resolveThenable(2048n, w, 1n, False{}, R.Number{8n}))
  asyncCleanupView(done, 5n, 5n, 2n, 4n)

def asyncDependencyTrim() -> AsyncCleanupView:
  w = A.createSignal(A.createWorld(), R.Boolean{False{}}, True{})
  w = A.createSignal(w, R.Number{8n}, True{})
  w = A.createSignal(w, R.Number{0n}, True{})
  w = A.createSignal(w, R.Number{7n}, True{})
  w = A.createMemoWithOptions(1024n, w, R.Read{5n}, R.NodeOptions.with_lazy(N.defaults(), True{}), 0n)
  w = A.createMemoWithOptions(1024n, w, R.Then{R.OnCleanup{R.Literal{R.ProgramReference{1n}}}, R.Read{3n}}, R.NodeOptions.with_lazy(N.defaults(), True{}), 1n)
  w = A.registerProgram(w, A.programWriteExpr(4n, R.Read{6n}, A.emptyProgram()))
  w = A.createThenable(w, True{})
  w = A.createMemoWithOptions(1024n, w, R.Select{R.Read{2n}, R.Literal{R.AsyncValue{1n}}, R.Read{7n}}, N.defaults(), 1n)
  w = A.flush(2048n, A.setSignal(w, 2n, R.Boolean{True{}}))
  +done = A.flush(2048n, A.resolveThenable(2048n, w, 1n, False{}, R.Number{8n}))
  asyncCleanupView(done, 8n, 7n, 4n, 6n)

def pendingDependentCleanup() -> AsyncCleanupView:
  w = A.createSignal(A.createWorld(), R.Number{0n}, True{})
  w = A.createSignal(w, R.Number{7n}, True{})
  w = A.createMemoWithOptions(1024n, w, R.Read{3n}, R.NodeOptions.with_lazy(N.defaults(), True{}), 0n)
  w = A.createThenable(w, True{})
  w = A.createMemoWithOptions(1024n, w, R.Literal{R.AsyncValue{1n}}, N.defaults(), 1n)
  w = A.createMemoWithOptions(1024n, w, R.Then{R.OnCleanup{R.Literal{R.ProgramReference{1n}}}, R.Read{5n}}, R.NodeOptions.with_lazy(N.defaults(), True{}), 1n)
  w = A.registerProgram(w, A.programWriteExpr(2n, R.Read{4n}, A.emptyProgram()))
  w = A.resultWorld(A.read(1024n, w, 6n))
  w = R.World.with_fault(w, R.Healthy{})
  +done = A.flush(2048n, A.resolveThenable(2048n, w, 1n, False{}, R.Number{8n}))
  asyncCleanupView(done, 5n, 6n, 2n, 4n)

type View is Data:
  View{returned: R.Value, input: R.Value, marker: R.Value, memo: R.Value,
    dead: Bool, disposal: R.Disposal, context: Nat, tracking: Bool,
    scheduled: Bool, fault: R.Fault}

def scenario() -> View:
  w = A.createSignal(A.createWorld(), R.Number{1n}, True{})
  w = A.createSignal(w, R.Number{0n}, True{})
  w = A.createMemoWithOptions(2048n, w, R.Add{R.Read{2n}, R.Read{2n}}, R.NodeOptions.with_lazy(N.defaults(), True{}), 0n)
  w = A.registerProgram(w, A.programWriteExpr(3n, R.Add{R.Literal{R.Number{40n}}, R.Read{4n}}, A.emptyProgram()))
  w = A.flush(2048n, A.setSignal(O.cleanup(w, 1n, 1n), 2n, R.Number{3n}))
  +m = A.evaluateExpression(2048n, w, R.Add{R.Literal{R.Number{40n}}, R.Then{R.Invoke{R.Literal{R.RootDisposerReference{1n}}}, R.Literal{R.Number{2n}}}}, R.Undefined{})
  +done = A.flush(2048n, A.resultWorld(m))
  View{A.resultValue(m), R.Node.value(B.node(done, 2n)), R.Node.value(B.node(done, 3n)), R.Node.value(B.node(done, 4n)),
    L.isDisposed(done, 1n), R.Node.disposal(B.node(done, 1n)), R.World.context(done), R.World.tracking(done), R.World.scheduled(done), R.World.fault(done)}

def expected() -> View:
  View{R.Number{42n}, R.Number{3n}, R.Number{46n}, R.Number{6n}, True{}, R.NoDisposal{}, 0n, False{}, False{}, R.Healthy{}}

# Source finally precedence: a trim hook's 9 escapes; the application error 7
# remains the node's stored error and halt report. Trim does not re-enter catch.
type TrimView is Data:
  TrimView{fault: R.Fault, stored: R.Value, status: U32, previous: R.Value,
    modified: Bool, halted: Bool, reports: List<&2, R.Report>, context: Nat,
    tracking: Bool, running: Bool}

def trimScenario() -> TrimView:
  w = A.createSignal(A.createWorld(), R.Boolean{True{}}, True{})
  w = A.createSignal(w, R.Number{1n}, True{})
  w = A.registerProgram(w, A.programThrowExpr(R.Literal{R.Number{9n}}, A.emptyProgram()))
  w = A.registerProgram(w, A.programReturn(R.Select{R.Argument{0n}, R.Literal{R.Undefined{}}, R.Raise{R.Number{7n}}}, A.emptyProgram()))
  w = A.createMemoWithOptions(2048n, w, R.Read{3n}, R.NodeOptions.with_unobserved(N.defaults(), 1n), 1n)
  w = A.createEffectWithHandlers(2048n, w, R.Select{R.Read{2n}, R.Read{4n}, R.Literal{R.Number{0n}}}, False{}, 2n, False{}, False{}, N.defaults(), 1n, 2n, 0n, 0n)
  +done = A.flush(2048n, A.setSignal(w, 2n, R.Boolean{False{}}))
  TrimView{R.World.fault(done), R.NodeExtension.error(B.extension(done, 5n)), R.Node.status(B.node(done, 5n)),
    R.Node.prevValue(B.node(done, 5n)), R.Node.modified(B.node(done, 5n)), R.World.halted(done), R.World.reports(done),
    R.World.context(done), R.World.tracking(done), R.World.running(done)}

def expectedTrim() -> TrimView:
  TrimView{R.CallbackThrown{R.Number{9n}}, R.StatusFailure{1n, 5n, R.Number{7n}, "7"}, 2, R.Number{0n}, False{}, True{},
    [R.RuntimeReport{0, R.Present{R.Number{7n}}}], 0n, False{}, False{}}

# A commit publishes its value before retiring the parked frame. A teardown
# error leaves its list detached and later writes pending in the live intake.
type CommitView is Data:
  CommitView{fault: R.Fault, value: R.Value, pending: R.Slot,
    disposal: R.Disposal, marker: R.Value, proposal: R.Slot,
    intake: List<&2, Nat>, modified: Bool, previous: R.Value,
    running: Bool, context: Nat, tracking: Bool, halted: Bool}

def commitScenario() -> CommitView:
  w = A.createSignal(A.createWorld(), R.Number{0n}, True{})
  w = A.createSignal(w, R.Number{0n}, True{})
  w = A.registerProgram(w, A.programWriteExpr(3n, R.Literal{R.Number{8n}}, A.programThrowExpr(R.Literal{R.Number{9n}}, A.emptyProgram())))
  w = A.createMemoWithOptions(2048n, w, R.Read{2n}, N.defaults(), 1n)
  w = O.cleanup(w, 4n, 1n)
  w = A.createEffect(2048n, w, R.Read{4n}, False{}, 2n, False{}, False{}, 1n)
  +done = A.flush(2048n, A.setSignal(w, 2n, R.Number{1n}))
  CommitView{R.World.fault(done), R.Node.value(B.node(done, 4n)), R.Node.pending(B.node(done, 4n)), R.NodeExtension.pendingDisposal(B.extension(done, 4n)),
    R.Node.value(B.node(done, 3n)), R.Node.pending(B.node(done, 3n)), R.World.pendingNodes(done), R.Node.modified(B.node(done, 5n)), R.Node.prevValue(B.node(done, 5n)),
    R.World.running(done), R.World.context(done), R.World.tracking(done), R.World.halted(done)}

def expectedCommit() -> CommitView:
  CommitView{R.CallbackThrown{R.Number{9n}}, R.Number{1n}, R.Empty{}, R.NoDisposal{}, R.Number{0n}, R.Present{R.Number{8n}},
    [2n, 4n, 3n], True{}, R.Number{0n}, False{}, 0n, False{}, False{}}
