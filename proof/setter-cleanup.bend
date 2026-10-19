# A returned setter is the same callable in two disposal slots. Owner teardown
# calls it with no arguments, clearing the surviving unowned signal once staged.
import Base
import ../runtime/api.bend as A
import ../runtime/ambient.bend as L
import ../representation/base.bend as B
import ../representation/records.bend as R


def register(w: R.World) -> R.World:
  A.resultWorld(A.evaluateExpression(512n, w,
    R.WithOwner{R.Literal{R.OwnerReference{1n}}, R.OnCleanup{R.Literal{R.SetterReference{2n}}}}, R.Undefined{}))


type View is Data:
  View{returned: R.Value, registered: R.Disposal, callables: Nat, rootDead: Bool,
    signalDead: Bool, parent: Nat, proposal: R.Slot, previous: R.Value,
    settled: R.Value, pending: R.Slot, disposal: R.Disposal,
    scheduled: Bool, context: Nat, tracking: Bool, fault: R.Fault}


def scenario() -> View:
  w = A.createSignal(A.createWorld(), R.Number{1n}, True{})
  +m = A.evaluateExpression(512n, register(w),
    R.WithOwner{R.Literal{R.OwnerReference{1n}}, R.OnCleanup{R.Literal{R.SetterReference{2n}}}}, R.Undefined{})
  +before = A.resultWorld(m)
  +after = A.dispose(before, 1n)
  +settled = A.flush(512n, after)
  View{A.resultValue(m), R.Node.disposal(B.node(before, 1n)), B.length(R.CleanupProgram, R.World.cleanupPrograms(before)),
    L.isDisposed(after, 1n), L.isDisposed(after, 2n), R.Node.parent(B.node(after, 2n)),
    R.Node.pending(B.node(after, 2n)), R.Node.value(B.node(after, 2n)), R.Node.value(B.node(settled, 2n)),
    R.Node.pending(B.node(settled, 2n)), R.Node.disposal(B.node(after, 1n)),
    R.World.scheduled(settled), R.World.context(settled), R.World.tracking(settled), R.World.fault(settled)}


def expected() -> View:
  View{R.SetterReference{2n}, R.ManyDisposals{[1n, 1n]}, 2n, True{}, False{}, 0n,
    R.Present{R.Undefined{}}, R.Number{1n}, R.Undefined{}, R.Empty{}, R.NoDisposal{},
    False{}, 0n, False{}, R.Healthy{}}
