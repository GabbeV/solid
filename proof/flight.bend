# Concrete promise-like loading/landing through the actual public construction,
# callback delivery, heap, status helpers, flush and mechanical text tree.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/api.bend as A
import ../runtime/construct.bend as N

def waiting() -> R.World:
  w = A.createThenable(A.createWorld(), True{})
  options = R.NodeOptions.with_loading(N.defaults(), R.Present{R.Number{0n}})
  w = A.createMemoWithOptions(256n, w, R.Literal{R.AsyncValue{1n}}, options, 1n)
  w = A.attach(w, 1n, 2n)
  A.flush(256n, A.createEffect(256n, w, R.Read{2n}, False{}, 2n, False{}, False{}, 1n))

def landed() -> R.World:
  A.resolveThenable(512n, waiting(), 1n, False{}, R.Number{6n})

type View is Data:
  View{value: R.Value, pending: R.Slot, loading: Bool, status: U32,
    flight: Nat, text: R.Value, renders: List<&2, Nat>, users: List<&2, R.QueueEntry>,
    intake: List<&2, Nat>, running: Bool, scheduled: Bool, context: Nat,
    tracking: Bool, fault: R.Fault}

def view(+w: R.World) -> View:
  View{R.Node.value(B.node(w, 2n)), R.Node.pending(B.node(w, 2n)), R.Node.loading(B.node(w, 2n)), R.Node.status(B.node(w, 2n)),
    R.NodeExtension.inFlight(B.extension(w, 2n)), A.displayed(w, 2n), R.World.renderQueue(w), R.World.userQueue(w), R.World.pendingNodes(w),
    R.World.running(w), R.World.scheduled(w), R.World.context(w), R.World.tracking(w), R.World.fault(w)}

def expectedWait() -> View:
  View{R.Number{0n}, R.Empty{}, True{}, 0, 1n, R.Number{0n}, [], [], [], False{}, False{}, 0n, False{}, R.Healthy{}}

def expectedLand() -> View:
  View{R.Number{6n}, R.Empty{}, False{}, 0, 1n, R.Number{6n}, [], [], [], False{}, False{}, 0n, False{}, R.Healthy{}}

# A superseding body asks a different external object. The first object's
# later callback must leave the new question's seed/text untouched.
def replaced() -> R.World:
  w = A.createThenable(A.createThenable(A.createWorld(), True{}), True{})
  w = A.createSignal(w, R.Boolean{True{}}, True{})
  options = R.NodeOptions.with_loading(N.defaults(), R.Present{R.Number{0n}})
  w = A.createMemoWithOptions(512n, w, R.Select{R.Read{2n}, R.Literal{R.AsyncValue{1n}}, R.Literal{R.AsyncValue{2n}}}, options, 1n)
  w = A.attach(w, 1n, 2n)
  w = A.createEffect(512n, w, R.Read{3n}, False{}, 2n, False{}, False{}, 1n)
  A.flush(512n, A.setSignal(w, 2n, R.Boolean{False{}}))

def staleCallback() -> R.World:
  A.resolveThenable(512n, replaced(), 1n, False{}, R.Number{99n})

def newestCallback() -> R.World:
  A.resolveThenable(512n, staleCallback(), 2n, False{}, R.Number{6n})

def replacementView(+w: R.World) -> View:
  View{R.Node.value(B.node(w, 3n)), R.Node.pending(B.node(w, 3n)), R.Node.loading(B.node(w, 3n)), R.Node.status(B.node(w, 3n)),
    R.NodeExtension.inFlight(B.extension(w, 3n)), A.displayed(w, 2n), R.World.renderQueue(w), R.World.userQueue(w), R.World.pendingNodes(w),
    R.World.running(w), R.World.scheduled(w), R.World.context(w), R.World.tracking(w), R.World.fault(w)}

def expectedStale() -> View:
  View{R.Number{0n}, R.Empty{}, True{}, 0, 2n, R.Number{0n}, [], [], [], False{}, False{}, 0n, False{}, R.Healthy{}}

def expectedNewest() -> View:
  View{R.Number{6n}, R.Empty{}, False{}, 0, 2n, R.Number{6n}, [], [], [], False{}, False{}, 0n, False{}, R.Healthy{}}

# No seed: pending propagates through a real diamond, then one external
# fulfillment retires it and publishes all four memo values and attached text.
def diamondWaiting() -> R.World:
  w = A.createThenable(A.createWorld(), True{})
  w = A.createMemoWithOptions(512n, w, R.Literal{R.AsyncValue{1n}}, N.defaults(), 1n)
  w = A.createMemoWithOptions(512n, w, R.Add{R.Read{2n}, R.Literal{R.Number{1n}}}, N.defaults(), 1n)
  w = A.createMemoWithOptions(512n, w, R.Add{R.Read{2n}, R.Literal{R.Number{2n}}}, N.defaults(), 1n)
  w = A.createMemoWithOptions(512n, w, R.Add{R.Read{3n}, R.Read{4n}}, N.defaults(), 1n)
  w = A.attach(w, 1n, 2n)
  A.flush(512n, A.createEffect(512n, w, R.Read{5n}, False{}, 2n, False{}, False{}, 1n))

def diamondLanded() -> R.World:
  A.resolveThenable(1024n, diamondWaiting(), 1n, False{}, R.Number{6n})

type DiamondView is Data:
  DiamondView{source: R.Value, left: R.Value, right: R.Value, joined: R.Value,
    text: R.Value, sourceStatus: U32, leftStatus: U32, rightStatus: U32,
    joinedStatus: U32, renderStatus: U32, live: List<&2, Nat>,
    intake: List<&2, Nat>, renders: List<&2, Nat>, users: List<&2, R.QueueEntry>,
    running: Bool, scheduled: Bool, context: Nat, tracking: Bool, fault: R.Fault}

def diamondView(+w: R.World) -> DiamondView:
  DiamondView{R.Node.value(B.node(w, 2n)), R.Node.value(B.node(w, 3n)), R.Node.value(B.node(w, 4n)), R.Node.value(B.node(w, 5n)),
    A.displayed(w, 2n), R.Node.status(B.node(w, 2n)), R.Node.status(B.node(w, 3n)), R.Node.status(B.node(w, 4n)), R.Node.status(B.node(w, 5n)), R.Node.status(B.node(w, 6n)),
    R.World.transactions(w), R.World.pendingNodes(w), R.World.renderQueue(w), R.World.userQueue(w), R.World.running(w), R.World.scheduled(w), R.World.context(w), R.World.tracking(w), R.World.fault(w)}

def expectedDiamond() -> DiamondView:
  DiamondView{R.Number{6n}, R.Number{7n}, R.Number{8n}, R.Number{15n}, R.Number{15n}, 0, 0, 0, 0, 0, [], [], [], [], False{}, False{}, 0n, False{}, R.Healthy{}}
