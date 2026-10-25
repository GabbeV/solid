# Source capture helpers admitted between action wait transitions. This executes
# the actual helper bodies, not deliveries or an alternative action controller.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/flight.bend as F
import ../runtime/iterator-state.bend as I
import ../runtime/action-state.bend as A
import ./observer-write-frame.bend as Frame
import ./action-wait-allocation.bend as Allocation
import ./action-wait-range.bend as Range
import ./committed-storage-frame.bend as Content


type Operation is Data:
  CaptureFulfilled{observer: Nat,value: R.Value}
  CaptureRejected{observer: Nat,error: R.Value}
  CaptureStream{stream: Nat}
  CaptureIgnored{result: Nat}

def after(w: R.World,operation: Operation) -> R.World:
  match operation:
    case CaptureFulfilled{observer,value}: F.syncFulfilled(w,observer,value)
    case CaptureRejected{observer,error}: F.syncRejected(w,observer,error)
    case CaptureStream{stream}: Frame.stepWorld(w,stream)
    case CaptureIgnored{result}: I.ignoreThen(w,result)

def grows(operation: Operation) -> Bool:
  match operation:
    case CaptureFulfilled{observer,value}: False{}
    case CaptureRejected{observer,error}: False{}
    case CaptureStream{stream}: True{}
    case CaptureIgnored{result}: True{}

def bound(+w: R.World,operation: Operation) -> Nat:
  B.choose(~Nat,grows(operation),_=>Nat.add(Allocation.index(w),1n),_=>Allocation.index(w))

def waits(+w: R.World,+operation: Operation) -> {R.World.actionWaits(after(w,operation)) == R.World.actionWaits(w) : List<&2,R.ActionWait>}:
  match operation:
    case CaptureFulfilled{observer,value}: Frame.storeWaits(w,observer,Frame.fulfilledRecord(w,observer,value))
    case CaptureRejected{observer,error}: Frame.storeWaits(w,observer,Frame.rejectedRecord(w,observer,error))
    case CaptureStream{stream}: Frame.streamWaits(w,stream)
    case CaptureIgnored{result}: Frame.ignoreWaits(w,result)

def size(+w: R.World,+operation: Operation) -> {Allocation.index(after(w,operation)) == bound(w,operation) : Nat}:
  match operation:
    case CaptureFulfilled{observer,value}: Frame.storeSize(w,observer,Frame.fulfilledRecord(w,observer,value))
    case CaptureRejected{observer,error}: Frame.storeSize(w,observer,Frame.rejectedRecord(w,observer,error))
    case CaptureStream{stream}: Frame.streamSize(w,stream)
    case CaptureIgnored{result}: Frame.ignoreSize(w,result)

def content(+w: R.World,+operation: Operation) -> {Content.observe(after(w,operation)) == Content.observe(w) : Content.View}:
  match operation:
    case CaptureFulfilled{observer,value}: Frame.storeContent(w,observer,Frame.fulfilledRecord(w,observer,value))
    case CaptureRejected{observer,error}: Frame.storeContent(w,observer,Frame.rejectedRecord(w,observer,error))
    case CaptureStream{stream}: Frame.streamContent(w,stream)
    case CaptureIgnored{result}: Frame.ignoreContent(w,result)

def grownRange(+entries: List<&2,R.ActionWait>,+bound: Nat,+grows: Bool,valid: {Range.below(entries,bound) == True{} : Bool}) -> {Range.below(entries,B.choose(~Nat,grows,_=>Nat.add(bound,1n),_=>bound)) == True{} : Bool}:
  match grows:
    case False{}: valid
    case True{}: Range.extend(entries,bound,valid)

def range(+w: R.World,+operation: Operation,valid: {Range.below(R.World.actionWaits(w),Allocation.index(w)) == True{} : Bool}) -> {Range.below(R.World.actionWaits(after(w,operation)),Allocation.index(after(w,operation))) == True{} : Bool}:
  Equal.trans(Bool,Range.below(R.World.actionWaits(after(w,operation)),Allocation.index(after(w,operation))),Range.below(R.World.actionWaits(w),Allocation.index(after(w,operation))),True{},Equal.cong(List<&2,R.ActionWait>,Bool,entries=>Range.below(entries,Allocation.index(after(w,operation))),R.World.actionWaits(after(w,operation)),R.World.actionWaits(w),waits(w,operation)),Equal.trans(Bool,Range.below(R.World.actionWaits(w),Allocation.index(after(w,operation))),Range.below(R.World.actionWaits(w),bound(w,operation)),True{},Equal.cong(Nat,Bool,n=>Range.below(R.World.actionWaits(w),n),Allocation.index(after(w,operation)),bound(w,operation),size(w,operation)),grownRange(R.World.actionWaits(w),Allocation.index(w),grows(operation),valid)))

def found(+w: R.World,+operation: Operation,+id: Nat,+record: R.ActionWait,known: {A.find(R.World.actionWaits(w),id) == Some{record} : Maybe<&2,R.ActionWait>}) -> {A.find(R.World.actionWaits(after(w,operation)),id) == Some{record} : Maybe<&2,R.ActionWait>}:
  Equal.trans(Maybe<&2,R.ActionWait>,A.find(R.World.actionWaits(after(w,operation)),id),A.find(R.World.actionWaits(w),id),Some{record},Equal.cong(List<&2,R.ActionWait>,Maybe<&2,R.ActionWait>,entries=>A.find(entries,id),R.World.actionWaits(after(w,operation)),R.World.actionWaits(w),waits(w,operation)),known)

def grownPositive(+bound: Nat,+grows: Bool,valid: {Nat.is_ne(bound,0n) == True{} : Bool}) -> {Nat.is_ne(B.choose(~Nat,grows,_=>Nat.add(bound,1n),_=>bound),0n) == True{} : Bool}:
  match grows:
    case False{}: valid
    case True{}: Range.successorPositive(bound)

def positive(+w: R.World,+operation: Operation,valid: {Nat.is_ne(Allocation.index(w),0n) == True{} : Bool}) -> {Nat.is_ne(Allocation.index(after(w,operation)),0n) == True{} : Bool}:
  Equal.trans(Bool,Nat.is_ne(Allocation.index(after(w,operation)),0n),Nat.is_ne(bound(w,operation),0n),True{},Equal.cong(Nat,Bool,n=>Nat.is_ne(n,0n),Allocation.index(after(w,operation)),bound(w,operation),size(w,operation)),grownPositive(Allocation.index(w),grows(operation),valid))
