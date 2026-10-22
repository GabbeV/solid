import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/deferred-state.bend as D
import ./affects-marks.bend as Seed

def zeroConfigs(configs: List<&2, U32>) -> List<&2, U32>:
  match configs:
    case Nil{}: []
    case head <> rest: 0 <> zeroConfigs(rest)

def fixture(op: U32, links: List<&2, R.Link>, +configs: List<&2, U32>, +flags: List<&2, U32>, +statuses: List<&2, U32>, +target: Nat, +lagging: List<&2, Nat>, seen: List<&2, Nat>, tailMode: U32) -> B.Bundle<R.World, Nat>:
  +w = B.first(R.World, Bool, Seed.fixture(0, links, zeroConfigs(configs), flags, statuses, target, 0n, 0n, 0n, [], 0, tailMode, False{}))
  +w = Seed.properties(configs, flags, statuses, w, 1n)
  B.choose(~B.Bundle<R.World, Nat>, U32.is_eq(op, 0), _ => D.lagOf(w, lagging, target, seen), _ => D.laggingOf(w, lagging, target))
