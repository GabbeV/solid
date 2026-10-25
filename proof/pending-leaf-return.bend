# The post-visit suffix of a one-edge subscriber traversal. All private locals
# stay captured. Success and fault unwinding return the exact caller separately.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/pending.bend as Q
import ./owner-continuation.bend as Owner
import ./pending-continuation.bend as Pending
import ./pending-removal-footprint.bend as Health
import ./pending-stack-history.bend as Steps
import ./core-run-prefix.bend as Driver
import ./bounded-core-return.bend as Return
import ./committed-storage-frame.bend as Frame

def input(w: R.World, tasks: List<&2, Q.Task>, visited: List<&2, Nat>, scheduled: Bool, rest: List<&2, C.Task>, stack: List<&2, R.Value>) -> C.Machine:
  C.Machine{w, C.PendingTasks{tasks, visited, [], scheduled} <> C.AsyncWriteSchedule{} <> rest, stack}

def start(w: R.World, +edge: Nat, +root: Nat, visited: List<&2, Nat>, scheduled: Bool, rest: List<&2, C.Task>, stack: List<&2, R.Value>) -> C.Machine:
  input(w, [Q.Walk{0n, root, root}, Q.Next{edge, root, root}, Q.Release{0n}, Q.End{}], visited, scheduled, rest, stack)

def next(w: R.World, edge: Nat, +root: Nat, visited: List<&2, Nat>, scheduled: Bool, rest: List<&2, C.Task>, stack: List<&2, R.Value>) -> C.Machine:
  input(w, [Q.Next{edge, root, root}, Q.Release{0n}, Q.End{}], visited, scheduled, rest, stack)

def zero(w: R.World, +root: Nat, visited: List<&2, Nat>, scheduled: Bool, rest: List<&2, C.Task>, stack: List<&2, R.Value>) -> C.Machine:
  input(w, [Q.Walk{0n, root, root}, Q.Release{0n}, Q.End{}], visited, scheduled, rest, stack)

def release(w: R.World, visited: List<&2, Nat>, scheduled: Bool, rest: List<&2, C.Task>, stack: List<&2, R.Value>) -> C.Machine:
  input(w, [Q.Release{0n}, Q.End{}], visited, scheduled, rest, stack)

def ending(w: R.World, visited: List<&2, Nat>, scheduled: Bool, rest: List<&2, C.Task>, stack: List<&2, R.Value>) -> C.Machine:
  input(w, [Q.End{}], visited, scheduled, rest, stack)

def endWorld(+w: R.World, +scheduled: Bool) -> R.World:
  B.choose(~R.World, scheduled, _ => B.schedule(w), _ => w)

def endHealth(+w: R.World, scheduled: Bool) -> {B.ok(endWorld(w, scheduled)) == B.ok(w) : Bool}:
  match scheduled:
    case True{}: Health.scheduleHealth(w)
    case False{}: {==}

def walkZero(+w: R.World, +tail: List<&2, Q.Task>, +root: Nat, +visited: List<&2, Nat>, +scheduled: Bool, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, healthy: {B.ok(w) == True{} : Bool}) ->
  {C.step(input(w, Q.Walk{0n, root, root} <> tail, visited, scheduled, rest, stack)) == input(w, tail, visited, scheduled, rest, stack) : C.Machine}:
  Equal.trans(C.Machine, C.step(input(w, Q.Walk{0n, root, root} <> tail, visited, scheduled, rest, stack)), C.dispatch(w, C.PendingTasks{Q.Walk{0n, root, root} <> tail, visited, [], scheduled} <> C.AsyncWriteSchedule{} <> rest, stack), input(w, tail, visited, scheduled, rest, stack), Owner.healthyStep(w, C.PendingTasks{Q.Walk{0n, root, root} <> tail, visited, [], scheduled}, C.AsyncWriteSchedule{} <> rest, stack, healthy), {==})

def nextZero(+w: R.World, +edge: Nat, +root: Nat, +visited: List<&2, Nat>, +scheduled: Bool, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, healthy: {B.ok(w) == True{} : Bool}, end: {R.Link.nextSub(B.link(w, edge)) == 0n : Nat}) ->
  {C.step(next(w, edge, root, visited, scheduled, rest, stack)) == zero(w, root, visited, scheduled, rest, stack) : C.Machine}:
  Equal.trans(C.Machine, C.step(next(w, edge, root, visited, scheduled, rest, stack)), C.dispatch(w, C.PendingTasks{[Q.Next{edge, root, root}, Q.Release{0n}, Q.End{}], visited, [], scheduled} <> C.AsyncWriteSchedule{} <> rest, stack), zero(w, root, visited, scheduled, rest, stack), Owner.healthyStep(w, C.PendingTasks{[Q.Next{edge, root, root}, Q.Release{0n}, Q.End{}], visited, [], scheduled}, C.AsyncWriteSchedule{} <> rest, stack, healthy),
    Equal.cong(Nat, C.Machine, next => input(w, [Q.Walk{next, root, root}, Q.Release{0n}, Q.End{}], visited, scheduled, rest, stack), R.Link.nextSub(B.link(w, edge)), 0n, end))

def releases(+w: R.World, +visited: List<&2, Nat>, +scheduled: Bool, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, healthy: {B.ok(w) == True{} : Bool}) ->
  {C.step(release(w, visited, scheduled, rest, stack)) == ending(w, visited, scheduled, rest, stack) : C.Machine}:
  Equal.trans(C.Machine, C.step(release(w, visited, scheduled, rest, stack)), C.dispatch(w, C.PendingTasks{[Q.Release{0n}, Q.End{}], visited, [], scheduled} <> C.AsyncWriteSchedule{} <> rest, stack), ending(w, visited, scheduled, rest, stack), Owner.healthyStep(w, C.PendingTasks{[Q.Release{0n}, Q.End{}], visited, [], scheduled}, C.AsyncWriteSchedule{} <> rest, stack, healthy), {==})

def ends(+w: R.World, +visited: List<&2, Nat>, +scheduled: Bool, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, healthy: {B.ok(w) == True{} : Bool}) ->
  {C.step(ending(w, visited, scheduled, rest, stack)) == input(endWorld(w, scheduled), [], visited, scheduled, rest, stack) : C.Machine}:
  Equal.trans(C.Machine, C.step(ending(w, visited, scheduled, rest, stack)), C.dispatch(w, C.PendingTasks{[Q.End{}], visited, [], scheduled} <> C.AsyncWriteSchedule{} <> rest, stack), input(endWorld(w, scheduled), [], visited, scheduled, rest, stack), Owner.healthyStep(w, C.PendingTasks{[Q.End{}], visited, [], scheduled}, C.AsyncWriteSchedule{} <> rest, stack, healthy), {==})

def schedules(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, healthy: {B.ok(w) == True{} : Bool}) ->
  {C.step(C.Machine{w, C.AsyncWriteSchedule{} <> rest, stack}) == C.Machine{B.schedule(w), rest, stack} : C.Machine}:
  Equal.trans(C.Machine, C.step(C.Machine{w, C.AsyncWriteSchedule{} <> rest, stack}), C.dispatch(w, C.AsyncWriteSchedule{} <> rest, stack), C.Machine{B.schedule(w), rest, stack}, Owner.healthyStep(w, C.AsyncWriteSchedule{}, rest, stack, healthy), {==})

def healthy(+w: R.World, +edge: Nat, +root: Nat, +visited: List<&2, Nat>, +scheduled: Bool, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +ready: {B.ok(w) == True{} : Bool}, end: {R.Link.nextSub(B.link(w, edge)) == 0n : Nat}) ->
  {Steps.iterate(7n, start(w, edge, root, visited, scheduled, rest, stack)) == C.Machine{B.schedule(endWorld(w, scheduled)), rest, stack} : C.Machine}:
  +initial = start(w, edge, root, visited, scheduled, rest, stack)
  +first = walkZero(w, [Q.Next{edge, root, root}, Q.Release{0n}, Q.End{}], root, visited, scheduled, rest, stack, ready)
  +second = Driver.appendStep(1n, initial, next(w, edge, root, visited, scheduled, rest, stack), zero(w, root, visited, scheduled, rest, stack), first, nextZero(w, edge, root, visited, scheduled, rest, stack, ready, end))
  +third = Driver.appendStep(2n, initial, zero(w, root, visited, scheduled, rest, stack), release(w, visited, scheduled, rest, stack), second, walkZero(w, [Q.Release{0n}, Q.End{}], root, visited, scheduled, rest, stack, ready))
  +fourth = Driver.appendStep(3n, initial, release(w, visited, scheduled, rest, stack), ending(w, visited, scheduled, rest, stack), third, releases(w, visited, scheduled, rest, stack, ready))
  +fifth = Driver.appendStep(4n, initial, ending(w, visited, scheduled, rest, stack), input(endWorld(w, scheduled), [], visited, scheduled, rest, stack), fourth, ends(w, visited, scheduled, rest, stack, ready))
  +sixth = Driver.appendStep(5n, initial, input(endWorld(w, scheduled), [], visited, scheduled, rest, stack), C.Machine{endWorld(w, scheduled), C.AsyncWriteSchedule{} <> rest, stack}, fifth, Pending.emptyExact(endWorld(w, scheduled), C.AsyncWriteSchedule{} <> rest, stack, visited, [], scheduled))
  +lastHealthy = Equal.trans(Bool, B.ok(endWorld(w, scheduled)), B.ok(w), True{}, endHealth(w, scheduled), ready)
  Driver.appendStep(6n, initial, C.Machine{endWorld(w, scheduled), C.AsyncWriteSchedule{} <> rest, stack}, C.Machine{B.schedule(endWorld(w, scheduled)), rest, stack}, sixth, schedules(endWorld(w, scheduled), rest, stack, lastHealthy))

def unhealthyStep(+w: R.World, +head: C.Task, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, broken: {B.ok(w) == False{} : Bool}) ->
  {C.step(C.Machine{w, head <> rest, stack}) == C.unwind(w, head <> rest, stack) : C.Machine}:
  Equal.cong(Bool, C.Machine, ready => B.choose(~C.Machine, ready, _ => C.dispatch(w, head <> rest, stack), _ => C.unwind(w, head <> rest, stack)), B.ok(w), False{}, broken)

def faultFirst(+w: R.World, +edge: Nat, +root: Nat, +visited: List<&2, Nat>, +scheduled: Bool, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, broken: {B.ok(w) == False{} : Bool}) ->
  {C.step(start(w, edge, root, visited, scheduled, rest, stack)) == C.Machine{w, C.AsyncWriteSchedule{} <> rest, stack} : C.Machine}:
  Equal.trans(C.Machine, C.step(start(w, edge, root, visited, scheduled, rest, stack)), C.unwind(w, C.PendingTasks{[Q.Walk{0n, root, root}, Q.Next{edge, root, root}, Q.Release{0n}, Q.End{}], visited, [], scheduled} <> C.AsyncWriteSchedule{} <> rest, stack), C.Machine{w, C.AsyncWriteSchedule{} <> rest, stack}, unhealthyStep(w, C.PendingTasks{[Q.Walk{0n, root, root}, Q.Next{edge, root, root}, Q.Release{0n}, Q.End{}], visited, [], scheduled}, C.AsyncWriteSchedule{} <> rest, stack, broken), {==})

def faultLast(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, broken: {B.ok(w) == False{} : Bool}) ->
  {C.step(C.Machine{w, C.AsyncWriteSchedule{} <> rest, stack}) == C.Machine{w, rest, stack} : C.Machine}:
  Equal.trans(C.Machine, C.step(C.Machine{w, C.AsyncWriteSchedule{} <> rest, stack}), C.unwind(w, C.AsyncWriteSchedule{} <> rest, stack), C.Machine{w, rest, stack}, unhealthyStep(w, C.AsyncWriteSchedule{}, rest, stack, broken), {==})

def fault(+w: R.World, +edge: Nat, +root: Nat, +visited: List<&2, Nat>, +scheduled: Bool, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +broken: {B.ok(w) == False{} : Bool}) ->
  {Steps.iterate(2n, start(w, edge, root, visited, scheduled, rest, stack)) == C.Machine{w, rest, stack} : C.Machine}:
  Driver.appendStep(1n, start(w, edge, root, visited, scheduled, rest, stack), C.Machine{w, C.AsyncWriteSchedule{} <> rest, stack}, C.Machine{w, rest, stack}, faultFirst(w, edge, root, visited, scheduled, rest, stack, broken), faultLast(w, rest, stack, broken))

# No health assumption is required by this bounded return certificate. The
# successful path and the preserved fault are explicit source alternatives.
def completeBy(+w: R.World, +edge: Nat, +root: Nat, +visited: List<&2, Nat>, +scheduled: Bool, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, end: {R.Link.nextSub(B.link(w, edge)) == 0n : Nat}, ready: Bool, known: {B.ok(w) == ready : Bool}) ->
  Return.Returned<start(w, edge, root, visited, scheduled, rest, stack), rest, stack, 7n>:
  match ready:
    case True{}:
      Return.ReturnedAt{7n, 0n, B.schedule(endWorld(w, scheduled)), {==}, healthy(w, edge, root, visited, scheduled, rest, stack, known, end)}
    case False{}:
      Return.ReturnedAt{2n, 5n, w, {==}, fault(w, edge, root, visited, scheduled, rest, stack, known)}

def complete(+w: R.World, edge: Nat, root: Nat, visited: List<&2, Nat>, scheduled: Bool, rest: List<&2, C.Task>, stack: List<&2, R.Value>, end: {R.Link.nextSub(B.link(w, edge)) == 0n : Nat}) ->
  Return.Returned<start(w, edge, root, visited, scheduled, rest, stack), rest, stack, 7n>:
  completeBy(w, edge, root, visited, scheduled, rest, stack, end, B.ok(w), {==})

# An early-return visitor omits its leaf zero-walk. That source alternative
# returns in six healthy steps, while preserving the same seven-step upper room.
def nextHealthy(+w: R.World, +edge: Nat, +root: Nat, +visited: List<&2, Nat>, +scheduled: Bool, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +ready: {B.ok(w) == True{} : Bool}, end: {R.Link.nextSub(B.link(w, edge)) == 0n : Nat}) ->
  {Steps.iterate(6n, next(w, edge, root, visited, scheduled, rest, stack)) == C.Machine{B.schedule(endWorld(w, scheduled)), rest, stack} : C.Machine}:
  +original = start(w, edge, root, visited, scheduled, rest, stack)
  +first = walkZero(w, [Q.Next{edge, root, root}, Q.Release{0n}, Q.End{}], root, visited, scheduled, rest, stack, ready)
  Equal.trans(C.Machine, Steps.iterate(6n, next(w, edge, root, visited, scheduled, rest, stack)), Steps.iterate(6n, C.step(original)), C.Machine{B.schedule(endWorld(w, scheduled)), rest, stack},
    Equal.cong(C.Machine, C.Machine, machine => Steps.iterate(6n, machine), next(w, edge, root, visited, scheduled, rest, stack), C.step(original), Equal.sym(C.Machine, C.step(original), next(w, edge, root, visited, scheduled, rest, stack), first)), healthy(w, edge, root, visited, scheduled, rest, stack, ready, end))

def faultPendingFirst(+w: R.World, +tasks: List<&2, Q.Task>, +visited: List<&2, Nat>, +scheduled: Bool, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, broken: {B.ok(w) == False{} : Bool}) ->
  {C.step(input(w, tasks, visited, scheduled, rest, stack)) == C.Machine{w, C.AsyncWriteSchedule{} <> rest, stack} : C.Machine}:
  Equal.trans(C.Machine, C.step(input(w, tasks, visited, scheduled, rest, stack)), C.unwind(w, C.PendingTasks{tasks, visited, [], scheduled} <> C.AsyncWriteSchedule{} <> rest, stack), C.Machine{w, C.AsyncWriteSchedule{} <> rest, stack}, unhealthyStep(w, C.PendingTasks{tasks, visited, [], scheduled}, C.AsyncWriteSchedule{} <> rest, stack, broken), {==})

def nextFault(+w: R.World, +edge: Nat, +root: Nat, +visited: List<&2, Nat>, +scheduled: Bool, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +broken: {B.ok(w) == False{} : Bool}) ->
  {Steps.iterate(2n, next(w, edge, root, visited, scheduled, rest, stack)) == C.Machine{w, rest, stack} : C.Machine}:
  Driver.appendStep(1n, next(w, edge, root, visited, scheduled, rest, stack), C.Machine{w, C.AsyncWriteSchedule{} <> rest, stack}, C.Machine{w, rest, stack}, faultPendingFirst(w, [Q.Next{edge, root, root}, Q.Release{0n}, Q.End{}], visited, scheduled, rest, stack, broken), faultLast(w, rest, stack, broken))

def completeNextBy(+w: R.World, +edge: Nat, +root: Nat, +visited: List<&2, Nat>, +scheduled: Bool, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, end: {R.Link.nextSub(B.link(w, edge)) == 0n : Nat}, ready: Bool, known: {B.ok(w) == ready : Bool}) ->
  Return.Returned<next(w, edge, root, visited, scheduled, rest, stack), rest, stack, 7n>:
  match ready:
    case True{}:
      Return.ReturnedAt{6n, 1n, B.schedule(endWorld(w, scheduled)), {==}, nextHealthy(w, edge, root, visited, scheduled, rest, stack, known, end)}
    case False{}:
      Return.ReturnedAt{2n, 5n, w, {==}, nextFault(w, edge, root, visited, scheduled, rest, stack, known)}

def completeNext(+w: R.World, edge: Nat, root: Nat, visited: List<&2, Nat>, scheduled: Bool, rest: List<&2, C.Task>, stack: List<&2, R.Value>, end: {R.Link.nextSub(B.link(w, edge)) == 0n : Nat}) ->
  Return.Returned<next(w, edge, root, visited, scheduled, rest, stack), rest, stack, 7n>:
  completeNextBy(w, edge, root, visited, scheduled, rest, stack, end, B.ok(w), {==})


def endFrame(+w: R.World, scheduled: Bool) -> {Frame.observe(endWorld(w, scheduled)) == Frame.observe(w) : Frame.View}:
  match scheduled:
    case True{}: Frame.schedule(w)
    case False{}: {==}

def completeByFrame(+w: R.World, +edge: Nat, +root: Nat, +visited: List<&2, Nat>, +scheduled: Bool, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +end: {R.Link.nextSub(B.link(w, edge)) == 0n : Nat}, ready: Bool, +known: {B.ok(w) == ready : Bool}) ->
  {Frame.observe(Return.world(start(w, edge, root, visited, scheduled, rest, stack), rest, stack, 7n, completeBy(w, edge, root, visited, scheduled, rest, stack, end, ready, known))) == Frame.observe(w) : Frame.View}:
  match ready:
    case True{}: Frame.compose(w, endWorld(w, scheduled), B.schedule(endWorld(w, scheduled)), Frame.schedule(endWorld(w, scheduled)), endFrame(w, scheduled))
    case False{}: {==}

def completeFrame(+w: R.World, +edge: Nat, +root: Nat, +visited: List<&2, Nat>, +scheduled: Bool, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +end: {R.Link.nextSub(B.link(w, edge)) == 0n : Nat}) ->
  {Frame.observe(Return.world(start(w, edge, root, visited, scheduled, rest, stack), rest, stack, 7n, complete(w, edge, root, visited, scheduled, rest, stack, end))) == Frame.observe(w) : Frame.View}:
  completeByFrame(w, edge, root, visited, scheduled, rest, stack, end, B.ok(w), {==})

def completeNextByFrame(+w: R.World, +edge: Nat, +root: Nat, +visited: List<&2, Nat>, +scheduled: Bool, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +end: {R.Link.nextSub(B.link(w, edge)) == 0n : Nat}, ready: Bool, +known: {B.ok(w) == ready : Bool}) ->
  {Frame.observe(Return.world(next(w, edge, root, visited, scheduled, rest, stack), rest, stack, 7n, completeNextBy(w, edge, root, visited, scheduled, rest, stack, end, ready, known))) == Frame.observe(w) : Frame.View}:
  match ready:
    case True{}: Frame.compose(w, endWorld(w, scheduled), B.schedule(endWorld(w, scheduled)), Frame.schedule(endWorld(w, scheduled)), endFrame(w, scheduled))
    case False{}: {==}

def completeNextFrame(+w: R.World, +edge: Nat, +root: Nat, +visited: List<&2, Nat>, +scheduled: Bool, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +end: {R.Link.nextSub(B.link(w, edge)) == 0n : Nat}) ->
  {Frame.observe(Return.world(next(w, edge, root, visited, scheduled, rest, stack), rest, stack, 7n, completeNext(w, edge, root, visited, scheduled, rest, stack, end))) == Frame.observe(w) : Frame.View}:
  completeNextByFrame(w, edge, root, visited, scheduled, rest, stack, end, B.ok(w), {==})
