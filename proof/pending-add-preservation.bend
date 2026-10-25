# Concrete instantiations of the generic source-operation frame theorem.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P
import ./pending-add-frame.bend as Generic
import ./committed-storage-frame.bend as Content
import ./pending-source-committed-frame.bend as ContentSource
import ./subscriber-topology-frame.bend as Topology
import ./topology-source-frame.bend as TopologySource
import ./graph-allocation-properties.bend as Storage
import ./pending-add-storage.bend as Aux

def content(+w: R.World, +id: Nat, +source: Nat) ->
  {Content.observe(B.first(R.World, Bool, P.addPendingSource(w, id, source))) == Content.observe(w) : Content.View}:
  Generic.add(Content.View, state => Content.observe(state), Content.worldPendingSets, Content.storeExtension, Content.storePendingSet, ContentSource.ext, w, id, source)

def topology(+w: R.World, +id: Nat, +source: Nat) ->
  {Topology.observe(B.first(R.World, Bool, P.addPendingSource(w, id, source))) == Topology.observe(w) : Topology.View}:
  Generic.add(Topology.View, state => Topology.observe(state), Topology.worldPendingSets, Topology.storeExtension, Topology.storePendingSet, TopologySource.ext, w, id, source)

def storage(+w: R.World, +id: Nat, +source: Nat) ->
  {Storage.storage(B.first(R.World, Bool, P.addPendingSource(w, id, source))) == Storage.storage(w) : Storage.Storage}:
  Generic.add(Storage.Storage, state => Storage.storage(state), Aux.worldPendingSets, Aux.storeExtension, Aux.storePendingSet, Aux.ext, w, id, source)
