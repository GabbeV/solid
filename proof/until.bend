# Closed default-until regression through the public entry and real watcher.
# Delivery of its queued callback is an explicit host input; native promise
# reaction timing, timeout and AbortSignal semantics are not proved here.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/api.bend as A
import ../runtime/constants.bend as K

def created() -> R.World:
  A.untilValue(256n, A.createSignal(A.createWorld(), R.Number{0n}, True{}), R.Read{2n})

def falseDelivered() -> R.World:
  A.deliverWatch(A.clearHostJobs(created()), 1n, False{}, R.Number{0n})

def trueQueued() -> R.World:
  A.flush(256n, A.setSignal(falseDelivered(), 2n, R.Number{7n}))

def trueDelivered() -> R.World:
  # The first queued flush is now a no-op; the watcher queued the value 7.
  A.deliverWatch(A.flush(256n, A.clearHostJobs(trueQueued())), 1n, False{}, R.Number{7n})

type View is Data:
  View{value: R.Value, answer: R.AsyncSettlement, rootDead: Bool,
    watcherDead: Bool, sourceObserved: Bool, outcome: List<&2, R.HostJob>,
    pending: List<&2, Nat>, renders: List<&2, Nat>, users: List<&2, Nat>,
    context: Nat, tracking: Bool, running: Bool, scheduled: Bool, fault: R.Fault}

def view(+w: R.World) -> View:
  View{R.Node.value(B.node(w, 2n)), R.Awaiter.state(B.awaiter(w, 1n)),
    B.has(R.Node.flags(B.node(w, 3n)), K.REACTIVE_DISPOSED()), B.has(R.Node.flags(B.node(w, 4n)), K.REACTIVE_DISPOSED()),
    Nat.is_ne(R.Node.subs(B.node(w, 2n)), 0n), R.World.hostJobs(w), R.World.pendingNodes(w), R.World.renderQueue(w), R.World.userQueue(w),
    R.World.context(w), R.World.tracking(w), R.World.running(w), R.World.scheduled(w), R.World.fault(w)}

def expectedFalse() -> View:
  View{R.Number{0n}, R.Unresolved{}, False{}, False{}, True{}, [], [], [], [], 0n, False{}, False{}, False{}, R.Healthy{}}

def expectedTrue() -> View:
  View{R.Number{7n}, R.Fulfilled{R.Number{7n}}, True{}, True{}, False{}, [R.PromiseOutcome{1n, False{}, R.Number{7n}}], [], [], [], 0n, False{}, False{}, False{}, R.Healthy{}}

# The supplied callback inputs above are exactly the jobs the watcher queued.
type Case is Data:
  Case{queued: List<&2, R.HostJob>, after: View}

def falseCase() -> Case:
  Case{R.World.hostJobs(created()), view(falseDelivered())}

def trueCase() -> Case:
  Case{R.World.hostJobs(trueQueued()), view(trueDelivered())}

def expectedFalseCase() -> Case:
  Case{[R.WatchDelivery{1n, False{}, R.Number{0n}}], expectedFalse()}

def expectedTrueCase() -> Case:
  Case{[R.FlushJob{}, R.WatchDelivery{1n, False{}, R.Number{7n}}], expectedTrue()}
