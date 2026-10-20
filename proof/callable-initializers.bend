# Passing an escaped getter to createSignal selects a writable computed node,
# tracks the input, accepts manual writes, and freezes at its owner's disposal.
import Base
import ../runtime/api.bend as A
import ../runtime/construct.bend as N
import ../runtime/ambient.bend as L
import ../representation/base.bend as B
import ../representation/records.bend as R

type View is Data:
  View{returned: R.Value, kind: R.NodeKind, parent: Nat, config: U32,
    manual: R.Value, rederived: R.Value, frozen: R.Value, input: R.Value,
    dead: Bool, context: Nat, tracking: Bool, fault: R.Fault}

def scenario() -> View:
  w = A.createSignal(A.createWorld(), R.Number{1n}, True{})
  expr = {R.SignalScope{R.Literal{R.AccessorReference{2n}}, N.defaults(), R.LocalAccessor{0n}} : R.Expr}
  +m = A.createRoot(2048n, w, expr, 1n, False{})
  +first = A.resultWorld(m)
  +manual = A.flush(2048n, A.setSignal(first, 4n, R.Number{7n}))
  +next = A.resultWorld(A.read(2048n, A.flush(2048n, A.setSignal(manual, 2n, R.Number{3n})), 4n))
  +done = A.resultWorld(A.read(2048n, A.flush(2048n, A.setSignal(A.dispose(next, 3n), 2n, R.Number{9n})), 4n))
  View{A.resultValue(m), R.Node.kind(B.node(first, 4n)), R.Node.parent(B.node(first, 4n)), R.Node.config(B.node(first, 4n)),
    R.Node.value(B.node(manual, 4n)), R.Node.value(B.node(next, 4n)), R.Node.value(B.node(done, 4n)), R.Node.value(B.node(done, 2n)),
    L.isDisposed(done, 4n), R.World.context(done), R.World.tracking(done), R.World.fault(done)}

def expected() -> View:
  View{R.AccessorReference{4n}, R.Memo{}, 3n, 0, R.Number{7n}, R.Number{3n}, R.Number{3n}, R.Number{9n},
    True{}, 0n, False{}, R.Healthy{}}
