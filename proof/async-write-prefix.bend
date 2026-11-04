# The actual core fulfillment prefix returns a machine with queued trim/release/
# flush work. These tasks are retained, not run or replaced by an atomic commit.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/flight.bend as F
import ../runtime/write.bend as W
import ../runtime/equality.bend as Equality
import ../runtime/constants.bend as K
import ../runtime/owner.bend as O
import ./committed-storage-frame.bend as Frame
import ./flight-committed-frame.bend as Flight
import ./landing-call-metadata.bend as Metadata
import ./setter-committed-frame.bend as Setter

def machineChoice(+condition: Bool, +w: R.World, +left: C.Machine, +right: C.Machine,
  leftFrame: {Frame.observe(C.world(left)) == Frame.observe(w) : Frame.View},
  rightFrame: {Frame.observe(C.world(right)) == Frame.observe(w) : Frame.View}) ->
  {Frame.observe(C.world(B.choose(~C.Machine, condition, _ => left, _ => right))) == Frame.observe(w) : Frame.View}:
  match condition:
    case True{}: leftFrame
    case False{}: rightFrame

def valuesChoice(+condition: Bool, +stack: List<&2, R.Value>, +left: C.Machine, +right: C.Machine,
  leftValues: {C.values(left) == stack : List<&2, R.Value>},
  rightValues: {C.values(right) == stack : List<&2, R.Value>}) ->
  {C.values(B.choose(~C.Machine, condition, _ => left, _ => right)) == stack : List<&2, R.Value>}:
  match condition:
    case True{}: leftValues
    case False{}: rightValues

# Both carried choices are admitted. A stream continuation forces a flush;
# an ordinary carried reaction retains only the already queued host flush.
def ending(+id: Nat,+then: List<&2,C.Task>,+rest: List<&2,C.Task>,carried: Bool) -> List<&2,C.Task>:
  C.AsyncWriteAfterTrim{id} <> C.AsyncWriteSchedule{} <> B.append(C.Task,B.choose(~List<&2,C.Task>,Bool.or(Bool.not(List.is_empty(&2,C.Task,then)),Bool.not(carried)),_=>[C.AsyncFlush{}],_=>[]),B.append(C.Task,then,rest))

def afterValue(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+then: List<&2,C.Task>,+carried: Bool) -> {Frame.observe(C.world(C.asyncWriteAfterValue(w,rest,stack,id,then,carried))) == Frame.observe(w) : Frame.View}:
  +ending = ending(id,then,rest,carried)
  machineChoice(Bool.not(B.present(R.Node.pending(B.node(w,id)))),w,C.Machine{B.store_node(w,id,R.Node.with_loading(B.node(w,id),False{})),C.OwnerTasks{[O.TrimDeps{id}]} <> ending,stack},C.Machine{w,ending,stack},Frame.loading(w,id,False{}),{==})

def afterValues(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+then: List<&2,C.Task>,+carried: Bool) -> {C.values(C.asyncWriteAfterValue(w,rest,stack,id,then,carried)) == stack : List<&2,R.Value>}:
  +ending = ending(id,then,rest,carried)
  valuesChoice(Bool.not(B.present(R.Node.pending(B.node(w,id)))),stack,C.Machine{B.store_node(w,id,R.Node.with_loading(B.node(w,id),False{})),C.OwnerTasks{[O.TrimDeps{id}]} <> ending,stack},C.Machine{w,ending,stack},{==},{==})

def defaultFrame(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+value: R.Value,+then: List<&2,C.Task>,+carried: Bool) -> {Frame.observe(C.world(C.asyncWriteDefault(w,rest,stack,id,value,then,carried))) == Frame.observe(w) : Frame.View}:
  +next = W.setSignal(w,id,value)
  Frame.compose(w,next,C.world(C.asyncWriteDefault(w,rest,stack,id,value,then,carried)),machineChoice(B.ok(next),next,C.asyncWriteAfterValue(next,rest,stack,id,then,carried),C.Machine{next,rest,stack},afterValue(next,rest,stack,id,then,carried),{==}),Setter.setter(w,id,value))

def defaultValues(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+value: R.Value,+then: List<&2,C.Task>,+carried: Bool) -> {C.values(C.asyncWriteDefault(w,rest,stack,id,value,then,carried)) == stack : List<&2,R.Value>}:
  +next = W.setSignal(w,id,value)
  valuesChoice(B.ok(next),stack,C.asyncWriteAfterValue(next,rest,stack,id,then,carried),C.Machine{next,rest,stack},afterValues(next,rest,stack,id,then,carried),{==})

def fastPrepared(+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+value: R.Value,+then: List<&2,C.Task>,posture: F.WritePosture) -> C.Machine:
  match posture:
    case F.WritePosture{+w,accepted,carried}:
      B.choose(~C.Machine,accepted,_=>C.asyncWriteDefault(w,rest,stack,id,value,then,carried),_=>C.Machine{w,rest,stack})

def fast(w: R.World,rest: List<&2,C.Task>,stack: List<&2,R.Value>,+id: Nat,result: Nat,value: R.Value,then: List<&2,C.Task>) -> C.Machine:
  fastPrepared(rest,stack,id,value,then,F.prepareAsyncLanding(w,id,result))

def fastGuard(+w: R.World, +id: Nat,
  custom: {Equality.custom(w, id) == 0n : Nat},
  override: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()) == False{} : Bool}) ->
  {Bool.and(Nat.is_eq(Equality.custom(w, id), 0n), Bool.not(B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()))) == True{} : Bool}:
  Equal.trans(Bool, Bool.and(Nat.is_eq(Equality.custom(w, id), 0n), Bool.not(B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()))), Bool.not(B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE())), True{},
    Equal.cong(Nat, Bool, comparator => Bool.and(Nat.is_eq(comparator, 0n), Bool.not(B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()))), Equality.custom(w, id), 0n, custom),
    Equal.cong(Bool, Bool, override => Bool.not(override), B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()), False{}, override))

# The setter classification is read AFTER preparation, as in the source.
# Metadata transports the original inputs across landStatus; there is no
# assumed equation about a computed poststate in the public contract.
def preparedExact(+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+value: R.Value,+then: List<&2,C.Task>,+posture: F.WritePosture,custom: {Equality.custom(F.landingWorld(posture),id) == 0n : Nat},override: {B.has(R.Node.config(B.node(F.landingWorld(posture),id)),K.CONFIG_OVERRIDE()) == False{} : Bool}) -> {C.asyncWritePrepared(rest,stack,id,value,then,posture) == fastPrepared(rest,stack,id,value,then,posture) : C.Machine}:
  match posture:
    case F.WritePosture{+w,+accepted,+carried}:
      Equal.cong(Bool,C.Machine,ordinary=>B.choose(~C.Machine,accepted,_=>B.choose(~C.Machine,ordinary,_=>C.asyncWriteDefault(w,rest,stack,id,value,then,carried),_=>C.setResolved(w,C.Discard{} <> C.AsyncWriteAfterSetter{id,then,carried} <> rest,stack,id,B.current(B.node(w,id)),value)),_=>C.Machine{w,rest,stack}),Bool.and(Nat.is_eq(Equality.custom(w,id),0n),Bool.not(B.has(R.Node.config(B.node(w,id)),K.CONFIG_OVERRIDE()))),True{},fastGuard(w,id,custom,override))

def exact(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+result: Nat,+value: R.Value,+then: List<&2,C.Task>,custom: {Equality.custom(w,id) == 0n : Nat},override: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_OVERRIDE()) == False{} : Bool}) -> {C.asyncWrite(w,rest,stack,id,result,value,then) == fast(w,rest,stack,id,result,value,then) : C.Machine}:
  +posture = F.prepareAsyncLanding(w,id,result)
  +next = F.landingWorld(posture)
  +comparator = Equal.trans(Nat,Equality.custom(next,id),Equality.custom(w,id),0n,Metadata.comparator(w,id,result),custom)
  +override = Equal.trans(Bool,B.has(R.Node.config(B.node(next,id)),K.CONFIG_OVERRIDE()),B.has(R.Node.config(B.node(w,id)),K.CONFIG_OVERRIDE()),False{},Equal.cong(U32,Bool,config=>B.has(config,K.CONFIG_OVERRIDE()),R.Node.config(B.node(next,id)),R.Node.config(B.node(w,id)),Metadata.config(w,id,result)),override)
  preparedExact(rest,stack,id,value,then,posture,comparator,override)

def preparedFrame(+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+value: R.Value,+then: List<&2,C.Task>,+posture: F.WritePosture) -> {Frame.observe(C.world(fastPrepared(rest,stack,id,value,then,posture))) == Frame.observe(F.landingWorld(posture)) : Frame.View}:
  match posture:
    case F.WritePosture{+w,+accepted,+carried}:
      machineChoice(accepted,w,C.asyncWriteDefault(w,rest,stack,id,value,then,carried),C.Machine{w,rest,stack},defaultFrame(w,rest,stack,id,value,then,carried),{==})

def fastFrame(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+result: Nat,+value: R.Value,+then: List<&2,C.Task>) -> {Frame.observe(C.world(fast(w,rest,stack,id,result,value,then))) == Frame.observe(w) : Frame.View}:
  +posture = F.prepareAsyncLanding(w,id,result)
  Frame.compose(w,F.landingWorld(posture),C.world(fast(w,rest,stack,id,result,value,then)),preparedFrame(rest,stack,id,value,then,posture),Flight.landing(w,id,result))

def observed(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+result: Nat,+value: R.Value,+then: List<&2,C.Task>,custom: {Equality.custom(w,id) == 0n : Nat},override: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_OVERRIDE()) == False{} : Bool}) -> {Frame.observe(C.world(C.asyncWrite(w,rest,stack,id,result,value,then))) == Frame.observe(w) : Frame.View}:
  Equal.trans(Frame.View,Frame.observe(C.world(C.asyncWrite(w,rest,stack,id,result,value,then))),Frame.observe(C.world(fast(w,rest,stack,id,result,value,then))),Frame.observe(w),Equal.cong(C.Machine,Frame.View,machine=>Frame.observe(C.world(machine)),C.asyncWrite(w,rest,stack,id,result,value,then),fast(w,rest,stack,id,result,value,then),exact(w,rest,stack,id,result,value,then,custom,override)),fastFrame(w,rest,stack,id,result,value,then))

def preparedValues(+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+value: R.Value,+then: List<&2,C.Task>,+posture: F.WritePosture) -> {C.values(fastPrepared(rest,stack,id,value,then,posture)) == stack : List<&2,R.Value>}:
  match posture:
    case F.WritePosture{+w,+accepted,+carried}:
      valuesChoice(accepted,stack,C.asyncWriteDefault(w,rest,stack,id,value,then,carried),C.Machine{w,rest,stack},defaultValues(w,rest,stack,id,value,then,carried),{==})

def stack(+w: R.World,+rest: List<&2,C.Task>,+values: List<&2,R.Value>,+id: Nat,+result: Nat,+value: R.Value,+then: List<&2,C.Task>,custom: {Equality.custom(w,id) == 0n : Nat},override: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_OVERRIDE()) == False{} : Bool}) -> {C.values(C.asyncWrite(w,rest,values,id,result,value,then)) == values : List<&2,R.Value>}:
  Equal.trans(List<&2,R.Value>,C.values(C.asyncWrite(w,rest,values,id,result,value,then)),C.values(fast(w,rest,values,id,result,value,then)),values,Equal.cong(C.Machine,List<&2,R.Value>,machine=>C.values(machine),C.asyncWrite(w,rest,values,id,result,value,then),fast(w,rest,values,id,result,value,then),exact(w,rest,values,id,result,value,then,custom,override)),preparedValues(rest,values,id,value,then,F.prepareAsyncLanding(w,id,result)))

def afterExact(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+then: List<&2,C.Task>,+carried: Bool) -> {C.asyncWriteAfterValue(w,rest,stack,id,then,carried) == B.choose(~C.Machine,Bool.not(B.present(R.Node.pending(B.node(w,id)))),_=>C.Machine{B.store_node(w,id,R.Node.with_loading(B.node(w,id),False{})),C.OwnerTasks{[O.TrimDeps{id}]} <> ending(id,then,rest,carried),stack},_=>C.Machine{w,ending(id,then,rest,carried),stack}) : C.Machine}:
  {==}
