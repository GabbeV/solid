# Typed variable-ID node/graph/fresh-registration construction. Auxiliaries and
# existing caches are data; every initial equality premise is checked in Bend.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as Core
import ./memo-render-fixture.bend as Initial
import ./memo-render-construction.bend as Pair
import ./memo-render-registration.bend as Registration
import ./default-computed-construction.bend as N
import ./bounded-core-return.bend as Return
import ./one-edge-settlement-return.bend as Settlement

def input(values: List<&2, R.Value>, extensions: List<&2, R.NodeExtension>, sets: List<&2, List<&2, Nat>>) -> R.World:
  R.World.with_extensions(R.World.with_pendingSets(Initial.input(values), [] <> sets), B.blank_extension() <> extensions)

def linked(+values: List<&2, R.Value>, +sourceExpr: R.Expr, +effectExpr: R.Expr, +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>) -> R.World:
  Pair.linked(input(values, extensions, sets), sourceExpr, effectExpr, 7n, 0n, 0n)

def registered(+values: List<&2, R.Value>, +sourceExpr: R.Expr, +effectExpr: R.Expr, +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>) -> R.World:
  Registration.registered(input(values, extensions, sets), sourceExpr, effectExpr, 7n, 0n, 0n)

def ready(+values: List<&2, R.Value>, +sourceExpr: R.Expr, +effectExpr: R.Expr, +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>) ->
  Registration.Registered<registered(values, sourceExpr, effectExpr, extensions, sets), N.index(input(values, extensions, sets)), N.index(Pair.memo(input(values, extensions, sets), sourceExpr)), 0n>:
  Registration.prepare(input(values, extensions, sets), sourceExpr, effectExpr, 7n, 0n, 0n, B.blank_node(), Initial.nodes(values), B.blank_link(), [], extensions, sets, {==}, {==}, {==}, {==}, {==}, {==})

def complete(+values: List<&2, R.Value>, +sourceExpr: R.Expr, +effectExpr: R.Expr, +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>, +rest: List<&2, Core.Task>, +stack: List<&2, R.Value>) ->
  Return.Returned<Settlement.start(registered(values, sourceExpr, effectExpr, extensions, sets), N.index(input(values, extensions, sets)), rest, stack), rest, stack, 10n>:
  Registration.startReturn(input(values, extensions, sets), sourceExpr, effectExpr, 7n, 0n, 0n, B.blank_node(), Initial.nodes(values), B.blank_link(), [], extensions, sets, {==}, {==}, {==}, {==}, {==}, {==}, rest, stack)
