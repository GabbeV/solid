# Dynamic application returns replace the previous callable in source order.
# Both setters are unowned; root teardown invokes the last selected one.
import Base
import ../runtime/api.bend as A
import ../runtime/construct.bend as N
import ../runtime/ambient.bend as L
import ../representation/base.bend as B
import ../representation/records.bend as R

type View is Data:
  View{first: Nat, second: Nat, a: R.Value, b: R.Value, finalA: R.Value,
    finalB: R.Value, cleanup: Nat, modified: Bool, rootDead: Bool,
    context: Nat, tracking: Bool, scheduled: Bool, fault: R.Fault}

def scenario() -> View:
  w = A.createSignal(A.createWorld(), R.Number{1n}, True{})
  w = A.createSignal(w, R.Number{2n}, True{})
  w = A.createSignal(w, R.Number{0n}, True{})
  expr = {R.Select{R.Argument{0n}, R.Literal{R.SetterReference{3n}}, R.Literal{R.SetterReference{2n}}} : R.Expr}
  w = A.registerProgram(w, A.programReturn(expr, A.emptyProgram()))
  +before = A.createReturningEffect(1024n, w, R.Read{4n}, False{}, 2n, False{}, False{}, N.defaults(), 1n, 1n, 0n)
  +next = A.flush(1024n, A.setSignal(before, 4n, R.Number{1n}))
  +done = A.flush(1024n, A.dispose(next, 1n))
  View{R.Node.cleanup(B.node(before, 5n)), R.Node.cleanup(B.node(next, 5n)),
    R.Node.value(B.node(next, 2n)), R.Node.value(B.node(next, 3n)),
    R.Node.value(B.node(done, 2n)), R.Node.value(B.node(done, 3n)),
    R.Node.cleanup(B.node(done, 5n)), R.Node.modified(B.node(done, 5n)), L.isDisposed(done, 1n),
    R.World.context(done), R.World.tracking(done), R.World.scheduled(done), R.World.fault(done)}

def expected() -> View:
  View{3n, 4n, R.Undefined{}, R.Number{2n}, R.Undefined{}, R.Undefined{},
    0n, False{}, True{}, 0n, False{}, False{}, R.Healthy{}}
