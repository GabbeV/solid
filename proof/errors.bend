# Closed error -> same-value recovery regression through the active engine.
import Base
import ../runtime/api.bend as A
import ../representation/base.bend as B
import ../representation/records.bend as R

def initial() -> R.World:
  w = A.createSignal(A.createWorld(), R.Boolean{True{}}, True{})
  w = A.createMemo(256n, w, R.Select{R.Read{2n}, R.Literal{R.Number{7n}}, R.Raise{R.Number{99n}}}, True{}, False{}, 1n)
  w = A.createMemo(256n, w, R.Read{3n}, True{}, False{}, 1n)
  A.flush(256n, A.createEffect(256n, w, R.Read{4n}, True{}, 0n, False{}, False{}, 1n))

def errored() -> R.World:
  A.flush(512n, A.setSignal(initial(), 2n, R.Boolean{False{}}))

def recovered() -> R.World:
  A.flush(512n, A.setSignal(errored(), 2n, R.Boolean{True{}}))

type View is Data:
  View{first: R.Value, second: R.Value, user: R.Value, prev: R.Value,
    firstStatus: U32, secondStatus: U32, userStatus: U32,
    firstError: R.Value, secondError: R.Value, userError: R.Value,
    modified: Bool, halted: Bool, pending: List<&2, Nat>, users: List<&2, R.QueueEntry>,
    context: Nat, tracking: Bool, running: Bool, scheduled: Bool, reports: List<&2, R.Report>, fault: R.Fault}

def view(+w: R.World) -> View:
  View{R.Node.value(B.node(w, 3n)), R.Node.value(B.node(w, 4n)), R.Node.value(B.node(w, 5n)), R.Node.prevValue(B.node(w, 5n)),
    R.Node.status(B.node(w, 3n)), R.Node.status(B.node(w, 4n)), R.Node.status(B.node(w, 5n)),
    R.NodeExtension.error(B.extension(w, 3n)), R.NodeExtension.error(B.extension(w, 4n)), R.NodeExtension.error(B.extension(w, 5n)),
    R.Node.modified(B.node(w, 5n)), R.World.halted(w), R.World.pendingNodes(w), R.World.userQueue(w),
    R.World.context(w), R.World.tracking(w), R.World.running(w), R.World.scheduled(w), R.World.reports(w), R.World.fault(w)}

def expectedError() -> View:
  +error = {R.StatusFailure{1n, 3n, R.Number{99n}, "99"} : R.Value}
  View{R.Number{7n}, R.Number{7n}, R.Number{7n}, R.Number{7n}, 2, 2, 2, error, error, error,
    False{}, False{}, [], [], 0n, False{}, False{}, False{}, [R.RuntimeReport{2, R.Present{R.Number{99n}}}], R.Healthy{}}

def expectedRecovery() -> View:
  View{R.Number{7n}, R.Number{7n}, R.Number{7n}, R.Number{7n}, 0, 0, 0, R.Null{}, R.Null{}, R.Null{},
    False{}, False{}, [], [], 0n, False{}, False{}, False{}, [R.RuntimeReport{2, R.Present{R.Number{99n}}}], R.Healthy{}}
