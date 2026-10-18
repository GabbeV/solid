# Concrete source-helper regressions. These exercise pending propagation and
# retirement, not promise registration, event delivery or transaction landing.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/construct.bend as N
import ../runtime/graph.bend as G
import ../runtime/status.bend as A
import ../runtime/pending-state.bend as P
import ../runtime/pending.bend as Q

def node(+w: R.World) -> R.World:
  +id = B.length(R.Node, R.World.nodes(w))
  +w = N.computed(64n, w, R.Literal{R.Number{7n}}, N.defaults(), 1n)
  B.store_node(w, id, R.Node.with_flags(R.Node.with_config(B.node(w, id), 0), 0))

def initial(+otherPath: Bool) -> R.World:
  +w = node(node(node(node(node(N.createOwner(B.empty(), 0n, False{}))))))
  +w = G.link(G.link(G.link(G.link(w, 2n, 3n), 2n, 4n), 3n, 5n), 4n, 5n)
  +w = B.choose(~R.World, otherPath, _ => G.link(w, 6n, 4n), _ => w)
  +w = R.World.with_errorSerial(w, 1n)
  +w = A.notifyStatusWith(w, 2n, 1, R.NotReadyFailure{1n, 6n}, False{})
  +w = B.store_extension(w, 3n, R.NodeExtension.with_blocked(B.extension(w, 3n), R.Present{R.Boolean{True{}}}))
  +w = B.store_extension(w, 4n, R.NodeExtension.with_blocked(B.extension(w, 4n), R.Present{R.Boolean{True{}}}))
  B.store_extension(w, 5n, R.NodeExtension.with_blocked(B.extension(w, 5n), R.Present{R.Boolean{True{}}}))

def settle(otherPath: Bool) -> R.World:
  Q.settlePendingSource(initial(otherPath), 2n, 6n)

type View is Data:
  View{leftSources: R.SourceSet, rightSources: R.SourceSet, leafSources: R.SourceSet,
    leftStatus: U32, rightStatus: U32, leafStatus: U32,
    leftError: R.Value, rightError: R.Value, leafError: R.Value,
    leftBlocked: R.Slot, rightBlocked: R.Slot, leafBlocked: R.Slot,
    scheduled: Bool, fault: R.Fault}

def view(+w: R.World) -> View:
  View{B.pendingSources(w, 3n), B.pendingSources(w, 4n), B.pendingSources(w, 5n),
    R.Node.status(B.node(w, 3n)), R.Node.status(B.node(w, 4n)), R.Node.status(B.node(w, 5n)),
    R.NodeExtension.error(B.extension(w, 3n)), R.NodeExtension.error(B.extension(w, 4n)), R.NodeExtension.error(B.extension(w, 5n)),
    R.NodeExtension.blocked(B.extension(w, 3n)), R.NodeExtension.blocked(B.extension(w, 4n)), R.NodeExtension.blocked(B.extension(w, 5n)),
    R.World.scheduled(w), R.World.fault(w)}

def expectedRetirement() -> View:
  +clear = {R.Present{R.Boolean{False{}}} : R.Slot}
  View{R.NoSources{}, R.NoSources{}, R.NoSources{}, 0, 0, 0, R.Null{}, R.Null{}, R.Null{}, clear, clear, clear, True{}, R.Healthy{}}

def expectedOtherPath() -> View:
  +source = {R.Sources{[6n]} : R.SourceSet}
  +error = {R.NotReadyFailure{1n, 6n} : R.Value}
  +blocked = {R.Present{R.Boolean{True{}}} : R.Slot}
  View{R.NoSources{}, source, source, 0, 1, 1, R.Null{}, error, error, R.Present{R.Boolean{False{}}}, blocked, blocked, True{}, R.Healthy{}}
