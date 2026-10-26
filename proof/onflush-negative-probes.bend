# Compact actual-operation oracles; positive checks precede negative use.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/on-flush.bend as O
import ../runtime/core.bend as C

def body() -> R.Expr:
  R.Literal{R.Number{7n}}

def queues_one_callback_after_flush_request() -> {R.World.hostJobs(O.register(B.empty(),body())) == [R.FlushJob{},R.MicrotaskCallback{body()}] : List<&2,R.HostJob>}:
  {==}

def evaluator_returns_undefined_without_running_callback() -> {C.values(C.evaluate(B.empty(),[],[R.Number{71n}],R.OnFlush{body()},R.Undefined{})) == [R.Undefined{},R.Number{71n}] : List<&2,R.Value>}:
  {==}
