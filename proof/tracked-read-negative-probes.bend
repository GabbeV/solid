# Closed semantic counterchecks keep failing-mutation diagnostics bounded.
# The generic actual-instruction theorem is in tracked-held-read.bend.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ./tracked-read-data.bend as Data

def returned() -> C.Machine:
  C.step(C.Machine{Data.world(),[C.ReadPrepared{1n}],[R.Number{91n}]})

def linksReader() -> {R.Node.deps(B.node(C.world(returned()),2n)) == 1n : Nat}:
  {==}

def servesProposalAndCaller() -> {C.values(returned()) == [R.Number{8n},R.Number{91n}] : List<&2,R.Value>}:
  {==}
