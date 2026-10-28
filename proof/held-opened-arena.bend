# Exact arena layout of the real raw held-source constructor. This only
# observes transaction storage; it is not a full-World normalization premise.
import Base
import ../representation/records.bend as R
import ./ordinary-graph-data.bend as Graph
import ./held-opened-state.bend as State
import ./held-controller-data.bend as Data

def record(id: Nat) -> R.Transaction:
  Data.group(id)

def arena(+value: R.Value,+methods: R.Expr) -> {R.World.txArena(State.opened(value,methods)) == [R.Transaction{[],[],[],[],0n,0n,False{},0n,0n,False{},0n,False{},False{},R.NoIds{}},record(Graph.source(value))] : List<&2,R.Transaction>}:
  {==}
