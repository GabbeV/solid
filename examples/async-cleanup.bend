# Previously displayed resources stay alive during a pending replacement and
# are released when that replacement publishes an error (Solid #4228).
# Expected cleanup counts: shown=0, pending=0, rejected=1; fault=Healthy.
import Base
import ../runtime/api.bend as A
import ../runtime/construct.bend as N
import ../representation/base.bend as B
import ../representation/records.bend as R

type CleanupTiming is Data:
  CleanupTiming{shown: Nat, pending: Nat, rejected: Nat, fault: R.Fault}

def cleanups(events: List<&2, R.TraceEvent>) -> Nat:
  match events:
    case Nil{}:
      0n
    case R.CleanupObserved{callback, code} <> rest:
      Nat.add(B.choose(~Nat, Nat.is_eq(code, 11n), _ => 1n, _ => 0n), cleanups(rest))
    case _ <> rest:
      cleanups(rest)

def body() -> R.Expr:
  A.then(A.onCleanup(A.literal(R.ProgramReference{1n})),
    R.Select{A.source(2n), A.literal(R.AsyncValue{2n}), A.literal(R.AsyncValue{1n})})

def main() -> CleanupTiming:
  +w = A.createSignal(A.createWorld(), R.Number{0n}, True{})
  +w = A.createThenable(A.createThenable(w, True{}), True{})
  +w = A.registerProgram(w, A.programEmit(11n, A.emptyProgram()))
  +w = A.registerProgram(w, A.programEmit(99n, A.emptyProgram()))
  +w = A.createMemo(4096n, w, body(), True{}, False{}, 1n)
  +w = A.createEffectWithHandlers(4096n, w, A.source(3n), True{}, 3n, False{}, False{}, N.defaults(), 1n, 0n, 0n, 2n)
  +w = A.flush(4096n, A.resolveThenable(4096n, A.flush(4096n, w), 1n, False{}, R.Number{10n}))
  +shown = cleanups(R.World.events(w))
  +w = A.flush(4096n, A.setSignal(w, 2n, R.Number{1n}))
  +pending = cleanups(R.World.events(w))
  +w = A.flush(4096n, A.resolveThenable(4096n, w, 2n, True{}, R.Number{21n}))
  CleanupTiming{shown, pending, cleanups(R.World.events(w)), R.World.fault(w)}
