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
