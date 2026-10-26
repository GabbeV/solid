# Actual evaluator call/return boundary for the deferred callback expression.
import Base
import ../representation/records.bend as R
import ../runtime/core.bend as C
import ../runtime/on-flush.bend as O

def source(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+body: R.Expr,+previous: R.Value) -> {C.evaluate(w,rest,stack,R.OnFlush{body},previous) == C.Machine{O.register(w,body),rest,R.Undefined{} <> stack} : C.Machine}:
  {==}
