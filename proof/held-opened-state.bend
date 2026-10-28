# Actual raw create/open/hold constructor. Its source/control proofs are separate.
import Base
import ../representation/records.bend as R
import ../runtime/transaction.bend as X
import ./action-constructor-state.bend as Action
import ./ordinary-graph-data.bend as Graph

def opened(+initial: R.Value,methods: R.Expr) -> R.World:
  X.holdNode(Action.opened(initial,methods),Graph.source(initial),1n)
