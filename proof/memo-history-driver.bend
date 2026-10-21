# IO-free actual public entry points for finite correspondence controls.
import Base
import ../runtime/api.bend as A
import ../representation/records.bend as R
import ./memo-initial-driver.bend as Constructor
import ./memo-history-public.bend as H
import ./memo-history-states.bend as M

def seed(initial: Nat, first: Nat, constructorExtra: Nat, firstExtra: Nat) -> R.World:
  A.flush(Nat.add(40n, firstExtra), A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), Constructor.expr(), False{}, False{}, 1n), 2n, R.Number{first}))

def program(initial: Nat, first: Nat, constructorExtra: Nat, firstExtra: Nat, updates: List<&2, H.Update>) -> R.World:
  H.run(updates, seed(initial, first, constructorExtra, firstExtra))

def update(tick: Nat, previous: Nat, input: Nat, events: List<&2, R.TraceEvent>, jobs: List<&2, R.HostJob>, extra: Nat) -> R.World:
  A.flush(Nat.add(40n, extra), A.setSignal(M.origin(tick, previous, events, jobs), 2n, R.Number{input}))
