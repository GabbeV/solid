# Actual wait registration constructs the fresh lookup and retained range needed
# by the source's yielded-value guard; no final entry/lookup is an input.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ../runtime/core.bend as Core
import ./action-wait-range.bend as Range
import ./action-wait-allocation.bend as Allocation
import ./action-wait-settlement.bend as Wait
import ./pending-carrier-existing.bend as NatEq


def appendedFind(+waits: List<&2,R.ActionWait>,+id: Nat,+action: Nat,+kind: U32,missing: {A.find(waits,id) == None{} : Maybe<&2,R.ActionWait>}) -> {A.find(B.append(R.ActionWait,waits,[R.ActionWait{id,action,kind,False{}}]),id) == Some{R.ActionWait{id,action,kind,False{}}} : Maybe<&2,R.ActionWait>}:
  +entry = {R.ActionWait{id,action,kind,False{}} : R.ActionWait}
  Equal.trans(Maybe<&2,R.ActionWait>,A.find(B.append(R.ActionWait,waits,[entry]),id),Wait.prefer(A.find(waits,id),A.find([entry],id)),Some{entry},Wait.findAppend(waits,[entry],id),Equal.trans(Maybe<&2,R.ActionWait>,Wait.prefer(A.find(waits,id),A.find([entry],id)),A.find([entry],id),Some{entry},Equal.cong(Maybe<&2,R.ActionWait>,Maybe<&2,R.ActionWait>,found=>Wait.prefer(found,A.find([entry],id)),A.find(waits,id),None{},missing),Equal.cong(Bool,Maybe<&2,R.ActionWait>,same=>B.choose(~Maybe<&2,R.ActionWait>,same,_=>Some{entry},_=>None{}),Nat.is_eq(id,id),True{},NatEq.self(id))))

def found(+w: R.World,+action: Nat,+result: Nat,+kind: U32,valid: {Range.below(R.World.actionWaits(w),Allocation.index(w)) == True{} : Bool}) -> {A.find(R.World.actionWaits(Allocation.after(w,action,result,kind)),Allocation.index(w)) == Some{R.ActionWait{Allocation.index(w),action,kind,False{}}} : Maybe<&2,R.ActionWait>}:
  Equal.trans(Maybe<&2,R.ActionWait>,A.find(R.World.actionWaits(Allocation.after(w,action,result,kind)),Allocation.index(w)),A.find(B.append(R.ActionWait,R.World.actionWaits(w),[R.ActionWait{Allocation.index(w),action,kind,False{}}]),Allocation.index(w)),Some{R.ActionWait{Allocation.index(w),action,kind,False{}}},Equal.cong(List<&2,R.ActionWait>,Maybe<&2,R.ActionWait>,waits=>A.find(waits,Allocation.index(w)),R.World.actionWaits(Allocation.after(w,action,result,kind)),B.append(R.ActionWait,R.World.actionWaits(w),[R.ActionWait{Allocation.index(w),action,kind,False{}}]),Allocation.waits(w,action,result,kind)),appendedFind(R.World.actionWaits(w),Allocation.index(w),action,kind,Range.absent(R.World.actionWaits(w),Allocation.index(w),valid)))

def bounded(+w: R.World,+action: Nat,+result: Nat,+kind: U32,valid: {Range.below(R.World.actionWaits(w),Allocation.index(w)) == True{} : Bool}) -> {Range.below(R.World.actionWaits(Allocation.after(w,action,result,kind)),Allocation.index(Allocation.after(w,action,result,kind))) == True{} : Bool}:
  +next = Allocation.after(w,action,result,kind)
  +waits = B.append(R.ActionWait,R.World.actionWaits(w),[R.ActionWait{Allocation.index(w),action,kind,False{}}])
  Equal.trans(Bool,Range.below(R.World.actionWaits(next),Allocation.index(next)),Range.below(waits,Allocation.index(next)),True{},Equal.cong(List<&2,R.ActionWait>,Bool,entries=>Range.below(entries,Allocation.index(next)),R.World.actionWaits(next),waits,Allocation.waits(w,action,result,kind)),Equal.trans(Bool,Range.below(waits,Allocation.index(next)),Range.below(waits,Nat.add(Allocation.index(w),1n)),True{},Equal.cong(Nat,Bool,bound=>Range.below(waits,bound),Allocation.index(next),Nat.add(Allocation.index(w),1n),Allocation.size(w,action,result,kind)),Range.append(R.World.actionWaits(w),[R.ActionWait{Allocation.index(w),action,kind,False{}}],Nat.add(Allocation.index(w),1n),Range.extend(R.World.actionWaits(w),Allocation.index(w),valid),Range.freshFits(Allocation.index(w),action,kind))))

def marked(+w: R.World,+action: Nat,+result: Nat,+observer: Nat) -> R.World:
  R.World.with_actionWaits(Allocation.after(w,action,result,0),A.settleWait(R.World.actionWaits(Allocation.after(w,action,result,0)),observer))

def markedFound(+w: R.World,+action: Nat,+result: Nat,valid: {Range.below(R.World.actionWaits(w),Allocation.index(w)) == True{} : Bool}) -> {A.find(R.World.actionWaits(marked(w,action,result,Allocation.index(w))),Allocation.index(w)) == Some{R.ActionWait{Allocation.index(w),action,0,True{}}} : Maybe<&2,R.ActionWait>}:
  +registered = Allocation.after(w,action,result,0)
  +entries = A.settleWait(R.World.actionWaits(registered),Allocation.index(w))
  Equal.trans(Maybe<&2,R.ActionWait>,A.find(R.World.actionWaits(marked(w,action,result,Allocation.index(w))),Allocation.index(w)),A.find(entries,Allocation.index(w)),Some{R.ActionWait{Allocation.index(w),action,0,True{}}},Equal.cong(List<&2,R.ActionWait>,Maybe<&2,R.ActionWait>,rows=>A.find(rows,Allocation.index(w)),R.World.actionWaits(marked(w,action,result,Allocation.index(w))),entries,Allocation.waitsStored(registered,entries)),Wait.findsSettled(R.World.actionWaits(registered),Allocation.index(w),R.ActionWait{Allocation.index(w),action,0,False{}},found(w,action,result,0,valid)))

def duplicateYield(+w: R.World,+action: Nat,+result: Nat,+rest: List<&2,Core.Task>,+stack: List<&2,R.Value>,+rejected: Bool,+value: R.Value,valid: {Range.below(R.World.actionWaits(w),Allocation.index(w)) == True{} : Bool}) -> {Core.asyncActionDelivery(marked(w,action,result,Allocation.index(w)),rest,stack,Allocation.index(w),rejected,value,A.find(R.World.actionWaits(marked(w,action,result,Allocation.index(w))),Allocation.index(w))) == Core.Machine{marked(w,action,result,Allocation.index(w)),rest,stack} : Core.Machine}:
  +registered = Allocation.after(w,action,result,0)
  +next = marked(w,action,result,Allocation.index(w))
  +entries = A.settleWait(R.World.actionWaits(registered),Allocation.index(w))
  Equal.trans(Core.Machine,Core.asyncActionDelivery(next,rest,stack,Allocation.index(w),rejected,value,A.find(R.World.actionWaits(next),Allocation.index(w))),Core.asyncActionDelivery(next,rest,stack,Allocation.index(w),rejected,value,A.find(entries,Allocation.index(w))),Core.Machine{next,rest,stack},Equal.cong(List<&2,R.ActionWait>,Core.Machine,rows=>Core.asyncActionDelivery(next,rest,stack,Allocation.index(w),rejected,value,A.find(rows,Allocation.index(w))),R.World.actionWaits(next),entries,Allocation.waitsStored(registered,entries)),Wait.duplicate(registered,rest,stack,Allocation.index(w),action,False{},rejected,value,found(w,action,result,0,valid)))

def oldLookup(+w: R.World,+action: Nat,+result: Nat,+kind: U32,+observer: Nat,+entry: R.ActionWait,found: {A.find(R.World.actionWaits(w),observer) == Some{entry} : Maybe<&2,R.ActionWait>}) -> {A.find(R.World.actionWaits(Allocation.after(w,action,result,kind)),observer) == Some{entry} : Maybe<&2,R.ActionWait>}:
  Equal.trans(Maybe<&2,R.ActionWait>,A.find(R.World.actionWaits(Allocation.after(w,action,result,kind)),observer),A.find(B.append(R.ActionWait,R.World.actionWaits(w),[R.ActionWait{Allocation.index(w),action,kind,False{}}]),observer),Some{entry},Equal.cong(List<&2,R.ActionWait>,Maybe<&2,R.ActionWait>,waits=>A.find(waits,observer),R.World.actionWaits(Allocation.after(w,action,result,kind)),B.append(R.ActionWait,R.World.actionWaits(w),[R.ActionWait{Allocation.index(w),action,kind,False{}}]),Allocation.waits(w,action,result,kind)),Wait.appendKeeps(R.World.actionWaits(w),[R.ActionWait{Allocation.index(w),action,kind,False{}}],observer,entry,found))
