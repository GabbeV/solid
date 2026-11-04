# Data shared by the first completed update and steady-pass specialization.
import Base
import ../representation/records.bend as R

def events(initial: Nat,first: Nat) -> List<&2,R.TraceEvent>:
  [R.Invoked{3n},R.ReadValue{3n,2n,R.Number{initial}},R.AccessorBound{3n},R.Invoked{3n},R.ReadValue{3n,2n,R.Number{first}}]

def jobs() -> List<&2,R.HostJob>:
  [R.FlushJob{}]
