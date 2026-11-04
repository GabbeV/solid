# Typed constructor integration from a healthy reserved arena plus arbitrary
# finite preexisting cached nodes. Equality evidence is constructed in Bend.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as Core
import ./memo-render-construction.bend as Pair
import ./default-computed-construction.bend as N
import ./bounded-core-return.bend as Return
import ./one-edge-settlement-return.bend as Settlement
import ./memo-render-input.bend as Input

def nodes(values: List<&2, R.Value>) -> List<&2, R.Node>:
  Input.nodes(values)

def input(values: List<&2, R.Value>) -> R.World:
  Input.input(values)

def complete(+values: List<&2, R.Value>, +sourceExpr: R.Expr, +effectExpr: R.Expr, +target: Nat, +program: Nat, +cleanup: Nat, +rest: List<&2, Core.Task>, +stack: List<&2, R.Value>) ->
  Return.Returned<Settlement.start(Pair.linked(input(values), sourceExpr, effectExpr, target, program, cleanup), N.index(input(values)), rest, stack), rest, stack, 14n>:
  Pair.startReturn(input(values), sourceExpr, effectExpr, target, program, cleanup, B.blank_node(), nodes(values), B.blank_link(), [], rest, stack, {==}, {==}, {==}, {==})


def allocated(values: List<&2, R.Value>, sourceExpr: R.Expr, effectExpr: R.Expr, target: Nat, program: Nat, cleanup: Nat) -> R.World:
  Pair.allocated(input(values), sourceExpr, effectExpr, target, program, cleanup)

def linked(values: List<&2, R.Value>, sourceExpr: R.Expr, effectExpr: R.Expr, target: Nat, program: Nat, cleanup: Nat) -> R.World:
  Pair.linked(input(values), sourceExpr, effectExpr, target, program, cleanup)
