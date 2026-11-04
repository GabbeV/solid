# Shared constructor input for memo/render and action books. No proof is
# removed: memo-render-fixture retains its general completion theorem.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B

def nodes(values: List<&2, R.Value>) -> List<&2, R.Node>:
  match values:
    case Nil{}: []
    case value <> tail: R.Node.with_value(B.blank_node(), value) <> nodes(tail)

def input(values: List<&2, R.Value>) -> R.World:
  R.World.with_nodes(B.empty(), B.blank_node() <> nodes(values))
