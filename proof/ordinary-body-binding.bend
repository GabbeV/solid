# The finite updater-body grammar contains literal data and fixed signal IDs.
# Actual callback argument binding leaves it unchanged for every argument vector.
import Base
import ../representation/records.bend as R
import ../runtime/callback.bend as Callback
import ./ordinary-body-evaluation.bend as Body

def closed(+values: List<&2,R.Value>,+id: Nat,+answer: R.Value,+args: Callback.Arguments) -> {Callback.bindWith(Body.expression(values,id,answer),args) == Body.expression(values,id,answer) : R.Expr}:
  match values:
    case Nil{}: {==}
    case +head <> +tail:
      Equal.cong(R.Expr,R.Expr,rest=>R.Then{R.WriteExpr{id,R.Literal{head},True{}},rest},Callback.bindWith(Body.expression(tail,id,answer),args),Body.expression(tail,id,answer),closed(tail,id,answer,args))
