# Typed registration integration on compact graph states. Extra auxiliary slots
# are arbitrary; source/node IDs are fixed only in this executable fixture.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as Core
import ../runtime/graph-state.bend as G
import ../runtime/pending-state.bend as P
import ./graph-link-construction.bend as Graph
import ./graph-allocation-construction.bend as Shape
import ./pending-add-one-edge.bend as Preserved
import ./pending-fresh-carrier.bend as Fresh
import ./bounded-core-return.bend as Return
import ./one-edge-settlement-return.bend as Settlement
import ./pending-carrier-roundtrip.bend as RoundTrip

def initial(+value: R.Value, recomputing: Bool, extensions: List<&2, R.NodeExtension>, sets: List<&2, List<&2, Nat>>) -> R.World:
  +source = R.Node.with_kind(R.Node.with_value(B.blank_node(), value), R.Memo{})
  +leaf = R.Node.with_flags(R.Node.with_kind(R.Node.with_value(B.blank_node(), value), R.Render{}), B.choose(~U32, recomputing, _ => 4, _ => 0))
  +w = R.World.with_nodes(B.empty(), [B.blank_node(), source, leaf])
  +w = R.World.with_extensions(w, B.blank_extension() <> extensions)
  R.World.with_pendingSets(w, [] <> sets)

def linked(value: R.Value, recomputing: Bool, extensions: List<&2, R.NodeExtension>, sets: List<&2, List<&2, Nat>>) -> R.World:
  G.link(initial(value, recomputing, extensions, sets), 1n, 2n)

def registered(value: R.Value, recomputing: Bool, extensions: List<&2, R.NodeExtension>, sets: List<&2, List<&2, Nat>>) -> R.World:
  B.first(R.World, Bool, P.addPendingSource(linked(value, recomputing, extensions, sets), 2n, 1n))

def certificate(+value: R.Value, +recomputing: Bool, +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>) -> Shape.OneEdge<linked(value, recomputing, extensions, sets), 1n, 2n, 0n>:
  Graph.build(initial(value, recomputing, extensions, sets), 1n, 2n, B.blank_link(), [], {==}, {==}, {==}, {==}, {==}, {==}, {==}, {==}, {==}, {==}, {==})

def complete(+value: R.Value, +recomputing: Bool, +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>, +rest: List<&2, Core.Task>, +stack: List<&2, R.Value>) ->
  Return.Returned<Settlement.start(registered(value, recomputing, extensions, sets), 1n, rest, stack), rest, stack, 10n>:
  Preserved.startReturn(linked(value, recomputing, extensions, sets), 2n, 1n, 1n, 2n, 0n, rest, stack, certificate(value, recomputing, extensions, sets))

def member(+value: R.Value, +recomputing: Bool, +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>) ->
  {P.hasSource(registered(value, recomputing, extensions, sets), 2n, 1n) == True{} : Bool}:
  match recomputing:
    case True{}: Fresh.contains(linked(value, True{}, extensions, sets), 2n, 0n, extensions, sets, {==}, {==}, {==}, {==})
    case False{}: Fresh.contains(linked(value, False{}, extensions, sets), 2n, 0n, extensions, sets, {==}, {==}, {==}, {==})

def retired(+value: R.Value, +recomputing: Bool, +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>) ->
  {P.hasSource(RoundTrip.removed(linked(value, recomputing, extensions, sets), 2n, 1n), 2n, 1n) == False{} : Bool}:
  match recomputing:
    case True{}: Fresh.retired(linked(value, True{}, extensions, sets), 2n, 0n, extensions, sets, {==}, {==}, {==}, {==})
    case False{}: Fresh.retired(linked(value, False{}, extensions, sets), 2n, 0n, extensions, sets, {==}, {==}, {==}, {==})
