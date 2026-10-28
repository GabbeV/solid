# Queued observer requests preserve all entry flags and readiness; only host jobs
# change. Health for the actual core drain is derived from the body result.
import Base
import ../representation/records.bend as R
import ../runtime/core.bend as C
import ./action-output-continuation.bend as Queue
import ./action-output-delivery-loop.bend as Loop
import ./action-control-flags.bend as Flags

def flags(+machine: C.Machine,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+form: Queue.Queue<machine,rest,stack>) -> {Flags.observe(Queue.world(machine,rest,stack,form)) == Flags.observe(C.world(machine)) : Flags.View}:
  +after = Queue.world(machine,rest,stack,form)
  +before = C.world(machine)
  Equal.trans(Flags.View,Flags.observe(after),Flags.observe(Loop.outer(after)),Flags.observe(before),Equal.sym(Flags.View,Flags.observe(Loop.outer(after)),Flags.observe(after),Flags.jobMask(after)),Equal.trans(Flags.View,Flags.observe(Loop.outer(after)),Flags.observe(Loop.outer(before)),Flags.observe(before),Equal.cong(R.World,Flags.View,w=>Flags.observe(w),Loop.outer(after),Loop.outer(before),Queue.frame(machine,rest,stack,form)),Flags.jobMask(before)))

def scheduled(+machine: C.Machine,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+form: Queue.Queue<machine,rest,stack>) -> {R.World.scheduled(Queue.world(machine,rest,stack,form)) == R.World.scheduled(C.world(machine)) : Bool}:
  +after = Queue.world(machine,rest,stack,form)
  +before = C.world(machine)
  Equal.trans(Bool,R.World.scheduled(after),R.World.scheduled(Loop.outer(after)),R.World.scheduled(before),Equal.sym(Bool,R.World.scheduled(Loop.outer(after)),R.World.scheduled(after),Flags.scheduledJobs(after)),Equal.trans(Bool,R.World.scheduled(Loop.outer(after)),R.World.scheduled(Loop.outer(before)),R.World.scheduled(before),Equal.cong(R.World,Bool,w=>R.World.scheduled(w),Loop.outer(after),Loop.outer(before),Queue.frame(machine,rest,stack,form)),Flags.scheduledJobs(before)))

def healthy(+machine: C.Machine,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+form: Queue.Queue<machine,rest,stack>,entry: {R.World.fault(C.world(machine)) == R.Healthy{} : R.Fault}) -> {R.World.fault(Queue.world(machine,rest,stack,form)) == R.Healthy{} : R.Fault}:
  +after = Queue.world(machine,rest,stack,form)
  +before = C.world(machine)
  Equal.trans(R.Fault,R.World.fault(after),R.World.fault(Loop.outer(after)),R.Healthy{},Equal.sym(R.Fault,R.World.fault(Loop.outer(after)),R.World.fault(after),Flags.faultJobs(after)),Equal.trans(R.Fault,R.World.fault(Loop.outer(after)),R.World.fault(Loop.outer(before)),R.Healthy{},Equal.cong(R.World,R.Fault,w=>R.World.fault(w),Loop.outer(after),Loop.outer(before),Queue.frame(machine,rest,stack,form)),Equal.trans(R.Fault,R.World.fault(Loop.outer(before)),R.World.fault(before),R.Healthy{},Flags.faultJobs(before),entry)))
