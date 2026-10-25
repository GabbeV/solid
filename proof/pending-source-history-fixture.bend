# The executable fixture supplies constructor facts internally, then accepts only
# a list of source operations and ordinary data. General theorems live above it.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as Core
import ./memo-render-fixture.bend as Initial
import ./memo-render-construction.bend as Pair
import ./default-computed-construction.bend as N
import ./pending-source-history.bend as History
import ./pending-command-history.bend as Commands
import ./memo-render-source-history.bend as Constructed
import ./bounded-core-return.bend as Return
import ./one-edge-settlement-return.bend as Settlement

def initial(values: List<&2, R.Value>, sourceExpr: R.Expr, effectExpr: R.Expr) -> R.World:
  Pair.linked(Initial.input(values), sourceExpr, effectExpr, 7n, 0n, 0n)

def programme(+values: List<&2, R.Value>, +sourceExpr: R.Expr, +effectExpr: R.Expr, commands: List<&2, Commands.Command>) -> History.History<initial(values, sourceExpr, effectExpr)>:
  Constructed.programme(Initial.input(values), sourceExpr, effectExpr, 7n, 0n, 0n, B.blank_node(), Initial.nodes(values), B.blank_link(), [], {==}, {==}, {==}, {==}, commands)

def after(+values: List<&2, R.Value>, +sourceExpr: R.Expr, +effectExpr: R.Expr, commands: List<&2, Commands.Command>) -> R.World:
  History.run(initial(values, sourceExpr, effectExpr), programme(values, sourceExpr, effectExpr, commands))

def complete(+values: List<&2, R.Value>, +sourceExpr: R.Expr, +effectExpr: R.Expr, +commands: List<&2, Commands.Command>, +rest: List<&2, Core.Task>, +stack: List<&2, R.Value>) ->
  Return.Returned<Settlement.start(after(values, sourceExpr, effectExpr, commands), N.index(Initial.input(values)), rest, stack), rest, stack, 10n>:
  Constructed.startReturn(Initial.input(values), sourceExpr, effectExpr, 7n, 0n, 0n, B.blank_node(), Initial.nodes(values), B.blank_link(), [], {==}, {==}, {==}, {==}, commands, rest, stack)
