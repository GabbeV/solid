# Actual expression/read admission into ReadPrepared, before slot selection.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/constants.bend as K
import ./action-body-return.bend as Step
import ./pending-stack-history.bend as Steps
import ./core-run-prefix.bend as Driver

def prepared(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+after: C.Task,lazy: Bool,computed: Bool) -> C.Machine:
  B.choose(~C.Machine,lazy,
    _=>C.Machine{B.store_node(w,id,R.Node.with_flags(B.node(w,id),B.clear(R.Node.flags(B.node(w,id)),K.REACTIVE_LAZY()))),C.Recompute{id,True{}} <> after <> rest,stack},
    _=>B.choose(~C.Machine,Bool.and(computed,B.has(R.Node.flags(B.node(w,id)),K.REACTIVE_DISPOSED())),_=>C.prepareDisposedAt(w,rest,stack,id,after),_=>C.Machine{w,after <> rest,stack}))

def prepareShape(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+after: C.Task) -> {C.prepareComputed(w,rest,stack,id,after) == prepared(w,rest,stack,id,after,B.has(R.Node.flags(B.node(w,id)),K.REACTIVE_LAZY()),B.computed(R.Node.kind(B.node(w,id)))) : C.Machine}:
  {==}

def prepare(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+after: C.Task,signal: {R.Node.kind(B.node(w,id)) == R.Signal{} : R.NodeKind},eager: {B.has(R.Node.flags(B.node(w,id)),K.REACTIVE_LAZY()) == False{} : Bool}) -> {C.prepareComputed(w,rest,stack,id,after) == C.Machine{w,after <> rest,stack} : C.Machine}:
  +lazy = B.has(R.Node.flags(B.node(w,id)),K.REACTIVE_LAZY())
  +computed = B.computed(R.Node.kind(B.node(w,id)))
  +first = Equal.cong(Bool,C.Machine,flag=>prepared(w,rest,stack,id,after,flag,computed),lazy,False{},eager)
  +kind = Equal.cong(R.NodeKind,C.Machine,tag=>prepared(w,rest,stack,id,after,False{},B.computed(tag)),R.Node.kind(B.node(w,id)),R.Signal{},signal)
  Equal.trans(C.Machine,C.prepareComputed(w,rest,stack,id,after),prepared(w,rest,stack,id,after,lazy,computed),C.Machine{w,after <> rest,stack},prepareShape(w,rest,stack,id,after),Equal.trans(C.Machine,prepared(w,rest,stack,id,after,lazy,computed),prepared(w,rest,stack,id,after,False{},computed),C.Machine{w,after <> rest,stack},first,kind))

def read(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,valid: Bool,dispatch: Bool) -> C.Machine:
  B.choose(~C.Machine,valid,_=>B.choose(~C.Machine,dispatch,_=>C.verdictValue(w,rest,stack,id,B.parentComputed(w,R.World.context(w))),_=>C.prepareComputed(w,rest,stack,id,C.ReadPrepared{id})),_=>C.Machine{R.World.with_fault(w,R.BadId{}),[],[]})

def readShape(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat) -> {C.readNode(w,rest,stack,id) == read(w,rest,stack,id,B.valid(w,id),R.VerdictState.dispatch(R.World.verdictState(w))) : C.Machine}:
  {==}

def admission(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,valid: {B.valid(w,id) == True{} : Bool},plain: {R.VerdictState.dispatch(R.World.verdictState(w)) == False{} : Bool},signal: {R.Node.kind(B.node(w,id)) == R.Signal{} : R.NodeKind},eager: {B.has(R.Node.flags(B.node(w,id)),K.REACTIVE_LAZY()) == False{} : Bool}) -> {C.readNode(w,rest,stack,id) == C.Machine{w,C.ReadPrepared{id} <> rest,stack} : C.Machine}:
  +dispatch = R.VerdictState.dispatch(R.World.verdictState(w))
  +first = Equal.cong(Bool,C.Machine,flag=>read(w,rest,stack,id,flag,dispatch),B.valid(w,id),True{},valid)
  +second = Equal.cong(Bool,C.Machine,flag=>read(w,rest,stack,id,True{},flag),dispatch,False{},plain)
  Equal.trans(C.Machine,C.readNode(w,rest,stack,id),read(w,rest,stack,id,B.valid(w,id),dispatch),C.Machine{w,C.ReadPrepared{id} <> rest,stack},readShape(w,rest,stack,id),Equal.trans(C.Machine,read(w,rest,stack,id,B.valid(w,id),dispatch),C.prepareComputed(w,rest,stack,id,C.ReadPrepared{id}),C.Machine{w,C.ReadPrepared{id} <> rest,stack},Equal.trans(C.Machine,read(w,rest,stack,id,B.valid(w,id),dispatch),read(w,rest,stack,id,True{},dispatch),C.prepareComputed(w,rest,stack,id,C.ReadPrepared{id}),first,second),prepare(w,rest,stack,id,C.ReadPrepared{id},signal,eager)))

def start(w: R.World,rest: List<&2,C.Task>,stack: List<&2,R.Value>,id: Nat,previous: R.Value) -> C.Machine:
  C.Machine{w,C.Evaluate{R.Read{id},previous} <> rest,stack}

def middle(w: R.World,rest: List<&2,C.Task>,stack: List<&2,R.Value>,id: Nat) -> C.Machine:
  C.Machine{w,C.ReadNode{id} <> rest,stack}

def target(w: R.World,rest: List<&2,C.Task>,stack: List<&2,R.Value>,id: Nat) -> C.Machine:
  C.Machine{w,C.ReadPrepared{id} <> rest,stack}

def complete(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+previous: R.Value,+healthy: {B.ok(w) == True{} : Bool},valid: {B.valid(w,id) == True{} : Bool},plain: {R.VerdictState.dispatch(R.World.verdictState(w)) == False{} : Bool},signal: {R.Node.kind(B.node(w,id)) == R.Signal{} : R.NodeKind},eager: {B.has(R.Node.flags(B.node(w,id)),K.REACTIVE_LAZY()) == False{} : Bool}) -> {Steps.iterate(2n,start(w,rest,stack,id,previous)) == target(w,rest,stack,id) : C.Machine}:
  +first = Step.healthyStep(w,C.Evaluate{R.Read{id},previous},rest,stack,healthy)
  +second = Equal.trans(C.Machine,C.step(middle(w,rest,stack,id)),C.readNode(w,rest,stack,id),target(w,rest,stack,id),Step.healthyStep(w,C.ReadNode{id},rest,stack,healthy),admission(w,rest,stack,id,valid,plain,signal,eager))
  Driver.appendStep(1n,start(w,rest,stack,id,previous),middle(w,rest,stack,id),target(w,rest,stack,id),first,second)
