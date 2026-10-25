# Typed executable control for the general cycle invariant on actually created
# memo/render nodes. JavaScript provides only payloads/commands/auxiliary data.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./memo-render-fixture.bend as Initial
import ./memo-render-registration-fixture.bend as Input
import ./memo-render-construction.bend as Pair
import ./default-computed-construction.bend as N
import ./memo-render-carrier-cycles.bend as Constructed
import ./pending-command-history.bend as Commands
import ./pending-carrier-state.bend as State
import ./pending-carrier-cycles.bend as Cycles

def initial(+values: List<&2, R.Value>, +sourceExpr: R.Expr, +effectExpr: R.Expr, +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>) -> R.World:
  Input.linked(values, sourceExpr, effectExpr, extensions, sets)

def seed(+values: List<&2, R.Value>, +sourceExpr: R.Expr, +effectExpr: R.Expr, +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>) -> State.CarrierSnapshot<initial(values, sourceExpr, effectExpr, extensions, sets), N.index(Pair.memo(Input.input(values, extensions, sets), sourceExpr)), B.length(R.Node, Initial.nodes(values))>:
  Constructed.seed(Input.input(values, extensions, sets), sourceExpr, effectExpr, 7n, 0n, 0n, B.blank_node(), Initial.nodes(values), B.blank_link(), [], extensions, sets, {==}, {==}, {==}, {==}, {==}, {==})

def run(+values: List<&2, R.Value>, +sourceExpr: R.Expr, +effectExpr: R.Expr, +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>, commands: List<&2, Commands.Command>) -> Cycles.CarrierOutcome<N.index(Pair.memo(Input.input(values, extensions, sets), sourceExpr)), B.length(R.Node, Initial.nodes(values))>:
  Cycles.run(N.index(Pair.memo(Input.input(values, extensions, sets), sourceExpr)), B.length(R.Node, Initial.nodes(values)), commands, initial(values, sourceExpr, effectExpr, extensions, sets), seed(values, sourceExpr, effectExpr, extensions, sets))

def after(+values: List<&2, R.Value>, +sourceExpr: R.Expr, +effectExpr: R.Expr, +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>, commands: List<&2, Commands.Command>) -> R.World:
  Cycles.executeWorld(N.index(Pair.memo(Input.input(values, extensions, sets), sourceExpr)), B.length(R.Node, Initial.nodes(values)), commands, initial(values, sourceExpr, effectExpr, extensions, sets))
