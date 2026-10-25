# Actual notifyStatus local pending stores construct status/error/membership
# together. This is before effect notification and dependent propagation.
import Base
import ./pending-notification-operations.bend as Operations
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/status.bend as A
import ../runtime/pending-state.bend as P
import ../runtime/constants.bend as K
import ./pending-carrier-state.bend as State
import ./single-carrier-frame.bend as Single
import ./carrier-status-writes.bend as Write
import ./pending-command-history.bend as Commands
import ./pending-add-preservation.bend as Add
import ./graph-allocation-properties.bend as Storage
import ./pending-one-edge-transport.bend as Transport
import ./pending-fresh-carrier.bend as Fresh
import ./node-store-lookup.bend as Store
import ./pending-auxiliary-lookup.bend as Aux
import ./committed-storage-frame.bend as Content
import ./pending-source-committed-frame.bend as PendingContent

def error(serial: Nat, source: Nat) -> R.Value:
  Operations.error(serial,source)


def carried(+w: R.World,+node: Nat) -> U32:
  Operations.carried(w,node)


def flags(w: R.World,node: Nat) -> U32:
  Operations.flags(w,node)


def statused(+w: R.World,+node: Nat) -> R.World:
  Operations.statused(w,node)


def finish(+w: R.World,+node: Nat,+source: Nat,+serial: Nat) -> R.World:
  Operations.finish(w,node,source,serial)


def choice(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,show: Bool) -> R.World:
  Operations.choice(w,node,source,serial,show)


def notified(w: R.World,node: Nat,source: Nat,serial: Nat) -> R.World:
  Operations.notified(w,node,source,serial)


def exact(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,noError: {B.has(R.Node.status(B.node(w,node)),K.STATUS_ERROR()) == False{} : Bool}) ->
  {notified(w,node,source,serial) == finish(State.addWorld(w,node,source),node,source,serial) : R.World}:
  Equal.cong(Bool,R.World,show=>choice(w,node,source,serial,show),B.has(R.Node.status(B.node(w,node)),K.STATUS_ERROR()),False{},noError)

def addedSingle(+w: R.World,+node: Nat,+source: Nat,+snapshot: State.CarrierSnapshot<w,node,source>) -> Single.Single<State.addWorld(w,node,source),node,source>:
  Single.fromSnapshot(State.addWorld(w,node,source),node,source,State.step(w,node,source,snapshot,Commands.AddLeaf{}),State.stepPresent(w,node,source,snapshot,Commands.AddLeaf{}))

def statusSingle(+w: R.World,+node: Nat,+source: Nat,single: Single.Single<w,node,source>) -> Single.Single<statused(w,node),node,source>:
  Single.move(w,statused(w,node),node,source,Write.status(w,node,flags(w,node)),single)

def finishExact(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,+single: Single.Single<w,node,source>) ->
  {finish(w,node,source,serial) == B.store_extension(statused(w,node),node,R.NodeExtension.with_error(B.extension(statused(w,node),node),error(serial,source))) : R.World}:
  Write.provided(statused(w,node),node,source,serial,statusSingle(w,node,source,single))

def finishSingle(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,+single: Single.Single<w,node,source>) -> Single.Single<finish(w,node,source,serial),node,source>:
  +next = statused(w,node)
  +prior = statusSingle(w,node,source,single)
  +stored = B.store_extension(next,node,R.NodeExtension.with_error(B.extension(next,node),error(serial,source)))
  Single.shift(stored,finish(w,node,source,serial),node,source,Equal.sym(R.World,finish(w,node,source,serial),stored,finishExact(w,node,source,serial,single)),Single.move(next,stored,node,source,Write.error(next,node,error(serial,source),Single.room(next,node,source,prior)),prior))

def single(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,+snapshot: State.CarrierSnapshot<w,node,source>,noError: {B.has(R.Node.status(B.node(w,node)),K.STATUS_ERROR()) == False{} : Bool}) -> Single.Single<notified(w,node,source,serial),node,source>:
  +added = State.addWorld(w,node,source)
  Single.shift(finish(added,node,source,serial),notified(w,node,source,serial),node,source,Equal.sym(R.World,notified(w,node,source,serial),finish(added,node,source,serial),exact(w,node,source,serial,noError)),finishSingle(added,node,source,serial,addedSingle(w,node,source,snapshot)))

def member(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,snapshot: State.CarrierSnapshot<w,node,source>,noError: {B.has(R.Node.status(B.node(w,node)),K.STATUS_ERROR()) == False{} : Bool}) ->
  {P.hasSource(notified(w,node,source,serial),node,1n+source) == True{} : Bool}:
  Single.member(notified(w,node,source,serial),node,source,single(w,node,source,serial,snapshot,noError))

def errorField(+record: R.NodeExtension,+value: R.Value) -> {R.NodeExtension.error(R.NodeExtension.with_error(record,value)) == value : R.Value}:
  match record:
    case R.NodeExtension{inFlight,flightTeardown,error,blocked,pendingSources,unobserved,snapshotValue,pendingFirstChild,pendingDisposal,transaction,reask,flushed,flushedAt,q,lane,marks,shownError}: {==}

def statusField(+record: R.Node,+flags: U32) -> {R.Node.status(R.Node.with_status(record,flags)) == flags : U32}:
  Operations.statusField(record,flags)


def finishError(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,+single: Single.Single<w,node,source>) ->
  {R.NodeExtension.error(B.extension(finish(w,node,source,serial),node)) == error(serial,source) : R.Value}:
  +next = statused(w,node)
  +record = R.NodeExtension.with_error(B.extension(next,node),error(serial,source))
  Equal.trans(R.Value,R.NodeExtension.error(B.extension(finish(w,node,source,serial),node)),R.NodeExtension.error(record),error(serial,source),
    Equal.trans(R.Value,R.NodeExtension.error(B.extension(finish(w,node,source,serial),node)),R.NodeExtension.error(B.extension(B.store_extension(next,node,record),node)),R.NodeExtension.error(record),Equal.cong(R.World,R.Value,state=>R.NodeExtension.error(B.extension(state,node)),finish(w,node,source,serial),B.store_extension(next,node,record),finishExact(w,node,source,serial,single)),Equal.cong(R.NodeExtension,R.Value,value=>R.NodeExtension.error(value),B.extension(B.store_extension(next,node,record),node),record,Aux.extensionRead(next,node,record,Single.room(next,node,source,statusSingle(w,node,source,single))))),errorField(B.extension(next,node),error(serial,source)))

def finishStatus(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,+single: Single.Single<w,node,source>,valid: {B.valid(w,node) == True{} : Bool}) ->
  {R.Node.status(B.node(finish(w,node,source,serial),node)) == flags(w,node) : U32}:
  +next = statused(w,node)
  +record = R.NodeExtension.with_error(B.extension(next,node),error(serial,source))
  Equal.trans(U32,R.Node.status(B.node(finish(w,node,source,serial),node)),R.Node.status(B.node(next,node)),flags(w,node),
    Equal.trans(U32,R.Node.status(B.node(finish(w,node,source,serial),node)),R.Node.status(B.node(B.store_extension(next,node,record),node)),R.Node.status(B.node(next,node)),Equal.cong(R.World,U32,state=>R.Node.status(B.node(state,node)),finish(w,node,source,serial),B.store_extension(next,node,record),finishExact(w,node,source,serial,single)),Equal.cong(R.Node,U32,value=>R.Node.status(value),B.node(B.store_extension(next,node,record),node),B.node(next,node),Write.extensionNode(next,node,record,node))),
    Equal.trans(U32,R.Node.status(B.node(next,node)),R.Node.status(R.Node.with_status(B.node(w,node),flags(w,node))),flags(w,node),Equal.cong(R.Node,U32,value=>R.Node.status(value),B.node(next,node),R.Node.with_status(B.node(w,node),flags(w,node)),Store.nodeSame(w,node,R.Node.with_status(B.node(w,node),flags(w,node)),Fresh.nodeRoom(w,node,valid))),statusField(B.node(w,node),flags(w,node))))

def errorResult(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,+snapshot: State.CarrierSnapshot<w,node,source>,noError: {B.has(R.Node.status(B.node(w,node)),K.STATUS_ERROR()) == False{} : Bool}) ->
  {R.NodeExtension.error(B.extension(notified(w,node,source,serial),node)) == error(serial,source) : R.Value}:
  Equal.trans(R.Value,R.NodeExtension.error(B.extension(notified(w,node,source,serial),node)),R.NodeExtension.error(B.extension(finish(State.addWorld(w,node,source),node,source,serial),node)),error(serial,source),Equal.cong(R.World,R.Value,state=>R.NodeExtension.error(B.extension(state,node)),notified(w,node,source,serial),finish(State.addWorld(w,node,source),node,source,serial),exact(w,node,source,serial,noError)),finishError(State.addWorld(w,node,source),node,source,serial,addedSingle(w,node,source,snapshot)))

def statusResult(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,+snapshot: State.CarrierSnapshot<w,node,source>,noError: {B.has(R.Node.status(B.node(w,node)),K.STATUS_ERROR()) == False{} : Bool},valid: {B.valid(w,node) == True{} : Bool}) ->
  {R.Node.status(B.node(notified(w,node,source,serial),node)) == flags(State.addWorld(w,node,source),node) : U32}:
  +added = State.addWorld(w,node,source)
  Equal.trans(U32,R.Node.status(B.node(notified(w,node,source,serial),node)),R.Node.status(B.node(finish(added,node,source,serial),node)),flags(added,node),Equal.cong(R.World,U32,state=>R.Node.status(B.node(state,node)),notified(w,node,source,serial),finish(added,node,source,serial),exact(w,node,source,serial,noError)),finishStatus(added,node,source,serial,addedSingle(w,node,source,snapshot),Transport.valid(w,added,node,Add.storage(w,node,1n+source),valid)))

def finishContent(+w: R.World,+node: Nat,+source: Nat,+serial: Nat) -> {Content.observe(finish(w,node,source,serial)) == Content.observe(w) : Content.View}:
  Content.compose(w,statused(w,node),finish(w,node,source,serial),PendingContent.setError(statused(w,node),node,1n+source,error(serial,source)),Content.status(w,node,flags(w,node)))

def content(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,noError: {B.has(R.Node.status(B.node(w,node)),K.STATUS_ERROR()) == False{} : Bool}) -> {Content.observe(notified(w,node,source,serial)) == Content.observe(w) : Content.View}:
  Equal.trans(Content.View,Content.observe(notified(w,node,source,serial)),Content.observe(finish(State.addWorld(w,node,source),node,source,serial)),Content.observe(w),Equal.cong(R.World,Content.View,state=>Content.observe(state),notified(w,node,source,serial),finish(State.addWorld(w,node,source),node,source,serial),exact(w,node,source,serial,noError)),Content.compose(w,State.addWorld(w,node,source),finish(State.addWorld(w,node,source),node,source,serial),finishContent(State.addWorld(w,node,source),node,source,serial),Add.content(w,node,1n+source)))
