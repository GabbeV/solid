# A restricted composed execution, using the same runtime entry points and
# callback evaluator as differential tests. No supplied render-result adapter.
import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R
import ../observation/tree.bend as T

def initial() -> R.World:
  w = A.createWorld()
  w = A.createSignal(w, R.Number{0n}, False{})
  w = A.createMemo(256n, w, R.Add{R.Read{2n}, R.Literal{R.Number{1n}}}, False{}, False{}, 1n)
  w = A.createMemo(256n, w, R.Multiply{R.Read{3n}, R.Literal{R.Number{2n}}}, False{}, False{}, 1n)
  w = A.attach(w, 1n, 2n)
  A.createEffect(256n, w, R.Add{R.Read{4n}, R.Read{2n}}, False{}, 2n, False{}, False{}, 1n)

def write(w: R.World, x: Nat) -> R.World:
  A.flush(256n, A.setSignal(w, 2n, R.Number{x}))

def once(x: Nat) -> R.World:
  write(initial(), x)

def twice(x: Nat, y: Nat) -> R.World:
  write(once(x), y)

def answer(+x: Nat) -> R.Value:
  R.Number{Nat.add(Nat.mul(Nat.add(x, 1n), 2n), x)}

type View is Data:
  View{source: R.Value, first: R.Value, second: R.Value, text: R.Value,
    attached: Bool, scheduled: Bool, running: Bool, context: Nat, tracking: Bool,
    pending: Nat, renders: Nat, users: Nat, fault: R.Fault,
    unflushed: Bool, promoted: Nat, extensions: Nat}

def view(+w: R.World) -> View:
  View{R.Node.value(B.node(w, 2n)), R.Node.value(B.node(w, 3n)),
    R.Node.value(B.node(w, 4n)), A.displayed(w, 2n), T.visible(4n, w, 2n),
    R.World.scheduled(w), R.World.running(w), R.World.context(w), R.World.tracking(w),
    B.length(Nat, R.World.pendingNodes(w)), B.length(Nat, R.World.renderQueue(w)),
    B.length(Nat, R.World.userQueue(w)), R.World.fault(w),
    R.World.unflushedStaged(w), B.length(Nat, R.World.promotedWrites(w)),
    B.length(R.NodeExtension, R.World.extensions(w))}

def expected(+x: Nat) -> View:
  View{R.Number{x}, R.Number{Nat.add(x, 1n)}, R.Number{Nat.mul(Nat.add(x, 1n), 2n)}, answer(x),
    True{}, False{}, False{}, 0n, False{}, 0n, 0n, 0n, R.Healthy{}, False{}, 0n, 1n}
