# Direct owner/core bridge fixture: an owner program reads a lazy memo while
# the caller has a live arithmetic operand. No public teardown-domain claim.
import Base
import ../runtime/api.bend as A
import ../runtime/construct.bend as N
import ../runtime/owner.bend as O
import ../runtime/ambient.bend as L
import ../representation/base.bend as B
import ../representation/records.bend as R

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
