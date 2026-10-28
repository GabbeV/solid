# Actual inTransaction slice-end: nested calls restore directly, while a
# healthy, scheduled outer entry queues the real Round before question restore.
# Executing that Round and proving publication are separate obligations.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/question.bend as Q
import ../runtime/cleanup-state.bend as Cleanup
import ./action-body-return.bend as Body
import ./pending-stack-history.bend as Steps
import ./core-run-prefix.bend as Driver

def start(w: R.World,question: R.Question,rest: List<&2,C.Task>,stack: List<&2,R.Value>) -> C.Machine:
  C.Machine{w,C.ActionSliceEnd{question} <> rest,stack}

def selected(+w: R.World,question: R.Question,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,depth: Nat) -> C.Machine:
  +ending = {C.ActionRestoreQuestion{question} <> rest : List<&2,C.Task>}
  B.choose(~C.Machine,Nat.is_eq(depth,0n),_=>C.publicFlush(w,ending,stack),_=>C.Machine{w,ending,stack})

def step(+w: R.World,+question: R.Question,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,healthy: {R.World.fault(w) == R.Healthy{} : R.Fault}) -> {C.step(start(w,question,rest,stack)) == selected(w,question,rest,stack,R.World.actionDepth(w)) : C.Machine}:
  Body.healthyStep(w,C.ActionSliceEnd{question},rest,stack,Body.health(w,healthy))

def nestedFirst(+w: R.World,+question: R.Question,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,healthy: {R.World.fault(w) == R.Healthy{} : R.Fault},depth: {R.World.actionDepth(w) == 1n+offset : Nat}) -> {C.step(start(w,question,rest,stack)) == C.Machine{w,C.ActionRestoreQuestion{question} <> rest,stack} : C.Machine}:
  Equal.trans(C.Machine,C.step(start(w,question,rest,stack)),selected(w,question,rest,stack,R.World.actionDepth(w)),C.Machine{w,C.ActionRestoreQuestion{question} <> rest,stack},step(w,question,rest,stack,healthy),Equal.cong(Nat,C.Machine,n=>selected(w,question,rest,stack,n),R.World.actionDepth(w),1n+offset,depth))

def restore(+w: R.World,+question: R.Question,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,healthy: {R.World.fault(w) == R.Healthy{} : R.Fault}) -> {C.step(C.Machine{w,C.ActionRestoreQuestion{question} <> rest,stack}) == C.Machine{Q.setQuestion(w,question),rest,stack} : C.Machine}:
  Body.healthyStep(w,C.ActionRestoreQuestion{question},rest,stack,Body.health(w,healthy))

def nested(+w: R.World,+question: R.Question,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,+healthy: {R.World.fault(w) == R.Healthy{} : R.Fault},depth: {R.World.actionDepth(w) == 1n+offset : Nat}) -> {Steps.iterate(2n,start(w,question,rest,stack)) == C.Machine{Q.setQuestion(w,question),rest,stack} : C.Machine}:
  Driver.appendStep(1n,start(w,question,rest,stack),C.Machine{w,C.ActionRestoreQuestion{question} <> rest,stack},C.Machine{Q.setQuestion(w,question),rest,stack},nestedFirst(w,question,rest,stack,offset,healthy,depth),restore(w,question,rest,stack,healthy))

def outer(+w: R.World,+question: R.Question,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,healthy: {R.World.fault(w) == R.Healthy{} : R.Fault},depth: {R.World.actionDepth(w) == 0n : Nat}) -> {C.step(start(w,question,rest,stack)) == C.publicFlush(w,C.ActionRestoreQuestion{question} <> rest,stack) : C.Machine}:
  Equal.trans(C.Machine,C.step(start(w,question,rest,stack)),selected(w,question,rest,stack,R.World.actionDepth(w)),C.publicFlush(w,C.ActionRestoreQuestion{question} <> rest,stack),step(w,question,rest,stack,healthy),Equal.cong(Nat,C.Machine,n=>selected(w,question,rest,stack,n),R.World.actionDepth(w),0n,depth))

# The source guard, parameterized only by its observed scalar fields, permits
# small congruence proofs without reducing an arbitrary scheduler World.
def flushChoice(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+depth: Nat,+running: Bool,+halted: Bool,scheduled: Bool) -> C.Machine:
  B.choose(~C.Machine,Bool.or(Nat.is_ne(depth,0n),Bool.or(running,halted)),_=>C.Machine{w,rest,stack},_=>B.choose(~C.Machine,scheduled,_=>C.Machine{w,C.Round{} <> rest,stack},_=>C.Machine{Cleanup.rethrowCleanupError(w,False{}),rest,stack}))

def scheduled(+w: R.World,+question: R.Question,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,healthy: {R.World.fault(w) == R.Healthy{} : R.Fault},+depth: {R.World.actionDepth(w) == 0n : Nat},running: {R.World.running(w) == False{} : Bool},halted: {R.World.halted(w) == False{} : Bool},ready: {R.World.scheduled(w) == True{} : Bool}) -> {C.step(start(w,question,rest,stack)) == C.Machine{w,C.Round{} <> C.ActionRestoreQuestion{question} <> rest,stack} : C.Machine}:
  +ending = {C.ActionRestoreQuestion{question} <> rest : List<&2,C.Task>}
  Equal.trans(C.Machine,C.step(start(w,question,rest,stack)),C.publicFlush(w,ending,stack),C.Machine{w,C.Round{} <> ending,stack},outer(w,question,rest,stack,healthy,depth),Equal.trans(C.Machine,flushChoice(w,ending,stack,R.World.actionDepth(w),R.World.running(w),R.World.halted(w),R.World.scheduled(w)),flushChoice(w,ending,stack,0n,R.World.running(w),R.World.halted(w),R.World.scheduled(w)),C.Machine{w,C.Round{} <> ending,stack},Equal.cong(Nat,C.Machine,n=>flushChoice(w,ending,stack,n,R.World.running(w),R.World.halted(w),R.World.scheduled(w)),R.World.actionDepth(w),0n,depth),Equal.trans(C.Machine,flushChoice(w,ending,stack,0n,R.World.running(w),R.World.halted(w),R.World.scheduled(w)),flushChoice(w,ending,stack,0n,False{},R.World.halted(w),R.World.scheduled(w)),C.Machine{w,C.Round{} <> ending,stack},Equal.cong(Bool,C.Machine,b=>flushChoice(w,ending,stack,0n,b,R.World.halted(w),R.World.scheduled(w)),R.World.running(w),False{},running),Equal.trans(C.Machine,flushChoice(w,ending,stack,0n,False{},R.World.halted(w),R.World.scheduled(w)),flushChoice(w,ending,stack,0n,False{},False{},R.World.scheduled(w)),C.Machine{w,C.Round{} <> ending,stack},Equal.cong(Bool,C.Machine,b=>flushChoice(w,ending,stack,0n,False{},b,R.World.scheduled(w)),R.World.halted(w),False{},halted),Equal.cong(Bool,C.Machine,b=>flushChoice(w,ending,stack,0n,False{},False{},b),R.World.scheduled(w),True{},ready)))))
