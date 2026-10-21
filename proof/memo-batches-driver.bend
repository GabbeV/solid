# Actual public programs used by finite native/canonical controls.
import Base
import ../runtime/api.bend as A
import ../representation/records.bend as R
import ./memo-initial-driver.bend as Constructor
import ./memo-batches.bend as H

def seed(initial: Nat, first: Nat, rest: List<&2, Nat>, constructorExtra: Nat, firstExtra: Nat) -> R.World:
  A.flush(Nat.add(40n, firstExtra), H.writes(rest, A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), Constructor.expr(), False{}, False{}, 1n), 2n, R.Number{first})))

def program(initial: Nat, first: Nat, rest: List<&2, Nat>, constructorExtra: Nat, firstExtra: Nat, batches: List<&2, H.Batch>) -> R.World:
  H.run(batches, seed(initial, first, rest, constructorExtra, firstExtra))
