# scheduler.ts:queuePendingNode, shared leaf of write/status/settle paths.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./read-state.bend as V

def queuePendingNode(+w: R.World, id: Nat) -> R.World:
  +w = R.World.with_pendingNodes(w, B.append(Nat, R.World.pendingNodes(w), [id]))
  B.choose(~R.World, Bool.not(R.World.running(w)), _ => V.markUnflushedStaged(w), _ => w)
