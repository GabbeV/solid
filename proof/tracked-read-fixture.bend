# These initial facts are checked in Bend, not supplied by the JS test driver.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/graph-state.bend as G
import ./tracked-read-data.bend as Data
import ./tracked-read-input.bend as I
import ./tracked-held-read.bend as Read
import ./fast-staged-choice.bend as Choice
import ./heap-render-join.bend as Join
import ./read-entry-metadata.bend as M

def ready() -> I.Input<Data.world(),2n,1n,1n>:
  I.TrackedReadReady{{==},{==},{==},{==},{==},{==},{==},{==},{==},{==}}

def complete() -> {C.step(C.Machine{Data.world(),[C.ReadPrepared{1n}],[R.Number{91n}]}) == Choice.output(Join.marked(G.link(Data.world(),1n,2n),2n),[],[R.Number{91n}],1n,2n,M.node(B.node(Data.world(),1n))) : C.Machine}:
  Read.complete(Data.world(),[],[R.Number{91n}],1n,1n,1n,ready(),{==},{==},{==},{==},{==})
