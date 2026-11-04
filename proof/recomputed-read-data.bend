# Closed constructor/write input for discrimination only. Context and tracking
# deliberately start as the caller's, so setup must install both for the body.
import Base
import ../representation/records.bend as R
import ../runtime/core.bend as C
import ./tracked-read-data.bend as Data

def world() -> R.World:
  R.World.with_tracking(R.World.with_context(Data.world(),0n),False{})

def lane() -> C.LanePass:
  C.LanePass{0n,R.MountUnset{},R.MountFalse{},False{},R.Empty{},False{}}

def stack() -> List<&2,R.Value>:
  [R.Number{91n}]

def start() -> C.Machine:
  C.Machine{world(),[C.RecomputePrepared{2n,False{},0n,lane()},C.Seam{}],stack()}
