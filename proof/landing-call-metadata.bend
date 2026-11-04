# Fulfillment's callback-free source prefix. Dependent release, owner cleanup,
# the queued flush and final publication are not executed by these contracts.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P
import ../runtime/pending.bend as Q
import ../runtime/status.bend as S
import ../runtime/flight.bend as F
import ../runtime/write.bend as W
import ../runtime/constants.bend as K
import ./landing-metadata-frame.bend as Frame
import ./landing-source-metadata.bend as Pending
import ./landing-status-metadata.bend as Status
import ../runtime/equality.bend as Equality

def remainingTail(+w: R.World, +id: Nat, +clearUninitialized: Bool, +remaining: Nat) -> R.World:
  +w = B.store_extension(w, id, R.NodeExtension.with_blocked(B.extension(w, id), R.Present{R.Boolean{False{}}}))
  +w = B.choose(~R.World, clearUninitialized, _ => B.store_node(w, id, R.Node.with_status(B.node(w, id), K.STATUS_PENDING())), _ => w)
  P.setPendingError(w, id, remaining, R.Undefined{})

def remainingFrame(+w: R.World, +id: Nat, +clearUninitialized: Bool, +remaining: Nat) ->
  {Frame.observe(remainingTail(w, id, clearUninitialized, remaining)) == Frame.observe(w) : Frame.View}:
  +record = R.NodeExtension.with_blocked(B.extension(w, id), R.Present{R.Boolean{False{}}})
  +blocked = B.store_extension(w, id, record)
  +next = B.choose(~R.World, clearUninitialized, _ => B.store_node(blocked, id, R.Node.with_status(B.node(blocked, id), K.STATUS_PENDING())), _ => blocked)
  Frame.compose(w, blocked, remainingTail(w, id, clearUninitialized, remaining),
    Frame.compose(blocked, next, remainingTail(w, id, clearUninitialized, remaining), Pending.setError(next, id, remaining, R.Undefined{}), Frame.choice(clearUninitialized, blocked, B.store_node(blocked, id, R.Node.with_status(B.node(blocked, id), K.STATUS_PENDING())), blocked, Frame.status(blocked, id, K.STATUS_PENDING()), {==})), Frame.storeExtension(w, id, record))

def landed(+w: R.World, +id: Nat, +clearUninitialized: Bool) ->
  {Frame.observe(Q.landStatus(w, id, clearUninitialized)) == Frame.observe(w) : Frame.View}:
  +next = B.choose(~R.World, S.hasSources(B.pendingSources(w, id)), _ => B.first(R.World, Bool, P.removePendingSource(w, id, id)), _ => w)
  +remaining = B.get(Nat, P.items(B.pendingSources(next, id)), 0n, 0n)
  Frame.compose(w, next, Q.landStatus(w, id, clearUninitialized),
    Frame.choice(Nat.is_ne(remaining, 0n), next, remainingTail(next, id, clearUninitialized, remaining), S.clearStatus(next, id, clearUninitialized), remainingFrame(next, id, clearUninitialized, remaining), Status.clear(next, id, clearUninitialized)),
    Frame.choice(S.hasSources(B.pendingSources(w, id)), w, B.first(R.World, Bool, P.removePendingSource(w, id, id)), w, Pending.remove(w, id, id), {==}))

def preparationBy(+w: R.World,+id: Nat,+ignored: Bool) -> {Frame.observe(F.landingWorld(B.choose(~F.WritePosture,ignored,_=>F.WritePosture{w,False{},False{}},_=>F.WritePosture{Q.landStatus(w,id,False{}),B.ok(Q.landStatus(w,id,False{})),F.carriedStaging(w,R.World.pendingNodes(w))}))) == Frame.observe(w) : Frame.View}:
  match ignored:
    case True{}: {==}
    case False{}: landed(w,id,False{})

def prepare(+w: R.World,+id: Nat,+result: Nat) -> {Frame.observe(F.landingWorld(F.prepareAsyncLanding(w,id,result))) == Frame.observe(w) : Frame.View}:
  preparationBy(w,id,Bool.or(Nat.is_ne(B.flightId(R.NodeExtension.inFlight(B.extension(w,id))),result),Bool.and(B.has(R.Node.flags(B.node(w,id)),K.REACTIVE_DIRTY()),Bool.not(B.has(R.Node.status(B.node(w,id)),K.STATUS_UNINITIALIZED())))))

def comparator(+w: R.World,+id: Nat,+result: Nat) -> {Equality.custom(F.landingWorld(F.prepareAsyncLanding(w,id,result)),id) == Equality.custom(w,id) : Nat}:
  Equal.cong(List<&2,R.ComparatorBinding>,Nat,bindings=>Equality.find(bindings,id),R.World.comparators(F.landingWorld(F.prepareAsyncLanding(w,id,result))),R.World.comparators(w),Equal.cong(Frame.View,List<&2,R.ComparatorBinding>,view=>Frame.comparatorBindings(view),Frame.observe(F.landingWorld(F.prepareAsyncLanding(w,id,result))),Frame.observe(w),prepare(w,id,result)))

def configuration(value: Frame.Shape) -> U32:
  match value:
    case Frame.Shape{kind,config,subscribers}: config

def config(+w: R.World,+id: Nat,+result: Nat) -> {R.Node.config(B.node(F.landingWorld(F.prepareAsyncLanding(w,id,result)),id)) == R.Node.config(B.node(w,id)) : U32}:
  Equal.cong(Frame.Shape,U32,value=>configuration(value),Frame.shape(B.node(F.landingWorld(F.prepareAsyncLanding(w,id,result)),id)),Frame.shape(B.node(w,id)),Frame.read(w,F.landingWorld(F.prepareAsyncLanding(w,id,result)),id,prepare(w,id,result)))
