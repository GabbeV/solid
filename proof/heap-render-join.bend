# Generic source joinPass render arm, from initial node facts only.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ../runtime/constants.bend as K
import ./node-observation-lens.bend as Lens
import ./committed-storage-frame.bend as Content

type Fields is Data:
  Fields{kind: R.NodeKind,status: U32}

def field(node: R.Node) -> Fields:
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      Fields{n_kind,n_status}
def kind(fields: Fields) -> R.NodeKind:
  match fields:
    case Fields{value,status}: value

def status(fields: Fields) -> U32:
  match fields:
    case Fields{kind,value}: value

def kindField(+node: R.Node) -> {kind(field(node)) == R.Node.kind(node) : R.NodeKind}:
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      {==}

def statusField(+node: R.Node) -> {status(field(node)) == R.Node.status(node) : U32}:
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      {==}

def kindSame(+a: R.Node,+b: R.Node,same: {field(a) == field(b) : Fields}) -> {R.Node.kind(a) == R.Node.kind(b) : R.NodeKind}:
  Equal.trans(R.NodeKind,R.Node.kind(a),kind(field(a)),R.Node.kind(b),Equal.sym(R.NodeKind,kind(field(a)),R.Node.kind(a),kindField(a)),Equal.trans(R.NodeKind,kind(field(a)),kind(field(b)),R.Node.kind(b),Equal.cong(Fields,R.NodeKind,view=>kind(view),field(a),field(b),same),kindField(b)))

def statusSame(+a: R.Node,+b: R.Node,same: {field(a) == field(b) : Fields}) -> {R.Node.status(a) == R.Node.status(b) : U32}:
  Equal.trans(U32,R.Node.status(a),status(field(a)),R.Node.status(b),Equal.sym(U32,status(field(a)),R.Node.status(a),statusField(a)),Equal.trans(U32,status(field(a)),status(field(b)),R.Node.status(b),Equal.cong(Fields,U32,view=>status(view),field(a),field(b),same),statusField(b)))

def sameFlags(+node: R.Node,bits: U32) -> {field(R.Node.with_flags(node,bits)) == field(node) : Fields}:
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      {==}

def store(+w: R.World,+id: Nat,+row: R.Node,same: {field(row) == field(B.node(w,id)) : Fields}) -> {Lens.observe(Fields,field,B.store_node(w,id,row)) == Lens.observe(Fields,field,w) : List<&2,Fields>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Lens.set(Fields,field,nodes,id,row,same)

def marked(+w: R.World,+reader: Nat) -> R.World:
  B.store_node(w,reader,R.Node.with_flags(B.node(w,reader),B.set(R.Node.flags(B.node(w,reader)),K.REACTIVE_JOINED())))

def fields(+w: R.World,+reader: Nat,+id: Nat) -> {field(B.node(marked(w,reader),id)) == field(B.node(w,id)) : Fields}:
  Lens.readWorld(Fields,field,w,marked(w,reader),id,store(w,reader,R.Node.with_flags(B.node(w,reader),B.set(R.Node.flags(B.node(w,reader)),K.REACTIVE_JOINED())),sameFlags(B.node(w,reader),B.set(R.Node.flags(B.node(w,reader)),K.REACTIVE_JOINED()))))

def gate(+w: R.World,reader: Nat,source: Nat) -> Bool:
  Bool.or(B.has(R.Node.status(B.node(w,source)),K.STATUS_UNINITIALIZED()),Bool.not(X.isRender(R.Node.kind(B.node(w,reader)))))

def tail(+w: R.World,+reader: Nat,+source: Nat,join: Bool) -> R.World:
  +n = B.node(w,reader)
  B.choose(~R.World,join,
    _=>
      +pair = X.txOf(w,source)
      +w = B.first(R.World,Nat,pair)
      +own = Bool.and(Bool.not(B.effect(R.Node.kind(n))),B.has(R.Node.status(n),K.STATUS_UNINITIALIZED()))
      X.joinPassTx(w,B.second(R.World,Nat,pair),own),_=>w)

def shape(+w: R.World,+reader: Nat,+source: Nat) -> {X.joinPass(w,reader,source) == tail(marked(w,reader),reader,source,gate(marked(w,reader),reader,source)) : R.World}:
  {==}

def noJoin(+w: R.World,+reader: Nat,+source: Nat,rendered: {R.Node.kind(B.node(w,reader)) == R.Render{} : R.NodeKind},initialized: {B.has(R.Node.status(B.node(w,source)),K.STATUS_UNINITIALIZED()) == False{} : Bool}) -> {gate(marked(w,reader),reader,source) == False{} : Bool}:
  +next = marked(w,reader)
  +kindRead = kindSame(B.node(next,reader),B.node(w,reader),fields(w,reader,reader))
  +knownKind = Equal.trans(R.NodeKind,R.Node.kind(B.node(next,reader)),R.Node.kind(B.node(w,reader)),R.Render{},kindRead,rendered)
  +sourceRead = statusSame(B.node(next,source),B.node(w,source),fields(w,reader,source))
  +notUninitialized = Equal.trans(Bool,B.has(R.Node.status(B.node(next,source)),K.STATUS_UNINITIALIZED()),B.has(R.Node.status(B.node(w,source)),K.STATUS_UNINITIALIZED()),False{},Equal.cong(U32,Bool,bits=>B.has(bits,K.STATUS_UNINITIALIZED()),R.Node.status(B.node(next,source)),R.Node.status(B.node(w,source)),sourceRead),initialized)
  Equal.trans(Bool,gate(next,reader,source),Bool.or(B.has(R.Node.status(B.node(next,source)),K.STATUS_UNINITIALIZED()),False{}),False{},Equal.cong(R.NodeKind,Bool,tag=>Bool.or(B.has(R.Node.status(B.node(next,source)),K.STATUS_UNINITIALIZED()),Bool.not(X.isRender(tag))),R.Node.kind(B.node(next,reader)),R.Render{},knownKind),Equal.cong(Bool,Bool,flag=>Bool.or(flag,False{}),B.has(R.Node.status(B.node(next,source)),K.STATUS_UNINITIALIZED()),False{},notUninitialized))

def render(+w: R.World,+reader: Nat,+source: Nat,+rendered: {R.Node.kind(B.node(w,reader)) == R.Render{} : R.NodeKind},initialized: {B.has(R.Node.status(B.node(w,source)),K.STATUS_UNINITIALIZED()) == False{} : Bool}) -> {X.joinPass(w,reader,source) == marked(w,reader) : R.World}:
  Equal.trans(R.World,X.joinPass(w,reader,source),tail(marked(w,reader),reader,source,gate(marked(w,reader),reader,source)),marked(w,reader),shape(w,reader,source),Equal.cong(Bool,R.World,join=>tail(marked(w,reader),reader,source,join),gate(marked(w,reader),reader,source),False{},noJoin(w,reader,source,rendered,initialized)))

def committed(+w: R.World,+reader: Nat,+source: Nat,rendered: {R.Node.kind(B.node(w,reader)) == R.Render{} : R.NodeKind},initialized: {B.has(R.Node.status(B.node(w,source)),K.STATUS_UNINITIALIZED()) == False{} : Bool}) -> {Content.observe(X.joinPass(w,reader,source)) == Content.observe(w) : Content.View}:
  Equal.trans(Content.View,Content.observe(X.joinPass(w,reader,source)),Content.observe(marked(w,reader)),Content.observe(w),Equal.cong(R.World,Content.View,next=>Content.observe(next),X.joinPass(w,reader,source),marked(w,reader),render(w,reader,source,rendered,initialized)),Content.flags(w,reader,B.set(R.Node.flags(B.node(w,reader)),K.REACTIVE_JOINED())))
