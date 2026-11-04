# rc.21 setPendingError selects the candidate, obtains ext, then selects/stores
# the retained or fresh error. A supplied error naming the source is retained;
# both appearances of the source equality are proved, not evaluated on Nat data.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P
import ../runtime/extension.bend as E
import ./natural-logic.bend as NatLogic

def givenCurrent(+w: R.World,+id: Nat,+source: Nat,+serial: Nat,same: Bool) -> R.World:
  +value = B.choose(~R.Value,same,_=>R.NotReadyFailure{serial,1n+source},_=>R.NodeExtension.error(B.extension(w,id)))
  P.preserveOrCreate(w,id,1n+source,value)

def selected(+w: R.World,+id: Nat,+source: Nat,+serial: Nat,same: Bool) -> R.World:
  +w = E.ext(w,id)
  +pair = B.choose(~B.Bundle<R.World,R.Value>,same,_=>B.Bundle{w,R.NotReadyFailure{serial,1n+source}},_=>P.notReadyError(w,1n+source))
  +w = B.first(R.World,R.Value,pair)
  B.store_extension(w,id,R.NodeExtension.with_error(B.extension(w,id),B.second(R.World,R.Value,pair)))

def retained(+w: R.World,+id: Nat,+source: Nat,+serial: Nat) ->
  {givenCurrent(w,id,source,serial,True{}) == B.store_extension(E.ext(w,id),id,R.NodeExtension.with_error(B.extension(E.ext(w,id),id),R.NotReadyFailure{serial,1n+source})) : R.World}:
  Equal.cong(Bool,R.World,same=>selected(w,id,source,serial,same),Nat.is_eq(1n+source,1n+source),True{},NatLogic.self(1n+source))

def provided(+w: R.World,+id: Nat,+source: Nat,+serial: Nat) ->
  {P.setPendingError(w,id,1n+source,R.NotReadyFailure{serial,1n+source}) == B.store_extension(E.ext(w,id),id,R.NodeExtension.with_error(B.extension(E.ext(w,id),id),R.NotReadyFailure{serial,1n+source})) : R.World}:
  Equal.trans(R.World,P.setPendingError(w,id,1n+source,R.NotReadyFailure{serial,1n+source}),givenCurrent(w,id,source,serial,True{}),B.store_extension(E.ext(w,id),id,R.NodeExtension.with_error(B.extension(E.ext(w,id),id),R.NotReadyFailure{serial,1n+source})),Equal.cong(Bool,R.World,same=>givenCurrent(w,id,source,serial,same),Nat.is_eq(1n+source,1n+source),True{},NatLogic.self(1n+source)),retained(w,id,source,serial))
