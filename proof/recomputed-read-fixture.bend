# The constructor/write input satisfies the generic prepared-render contract;
# this closed instance is not an arbitrary heap/public reachability theorem.
import Base
import ../runtime/core.bend as C
import ./tracked-read-input.bend as I
import ./recomputed-held-read.bend as Read
import ./recomputed-read-data.bend as Data
import ./pending-stack-history.bend as Steps

def input() -> Read.Input<Data.world(),2n,1n,1n>:
  Read.PreparedRenderRead{I.TrackedReadReady{{==},{==},{==},{==},{==},{==},{==},{==},{==},{==}},{==},{==},{==},{==},{==},{==},{==},{==}}

def complete() -> {Steps.iterate(4n,Data.start()) == Read.target(Data.world(),[C.Seam{}],Data.stack(),2n,1n,False{},0n,Data.lane()) : C.Machine}:
  Read.complete(Data.world(),[C.Seam{}],Data.stack(),1n,1n,1n,False{},0n,Data.lane(),input())
