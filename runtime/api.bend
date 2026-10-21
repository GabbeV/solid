import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../observation/tree.bend as T
import ./core.bend as C
import ./scheduler.bend as S
import ./owner.bend as O
import ./construct.bend as N
import ./flight.bend as F
import ./iterator-state.bend as I
import ./signals.bend as J
import ./ambient.bend as L
import ./callback.bend as Z
import ./context.bend as Y

# One explicit lifetime root for the current host grammar.
def createWorld() -> R.World:
  N.createOwner(B.empty(), 0n, False{})

def nextId(w: R.World) -> Nat:
  B.length(R.Node, R.World.nodes(w))

def createSignalWithOptions(w: R.World, value: R.Value, options: R.NodeOptions) -> R.World:
  N.signal(w, value, options)

# Public createSignal input dispatch, including constructor-selected callable
# initializers. The body is user-ABI pair observation only; source ownership and
# recomputation use the same SignalScope machine as nested construction.
def createSignalInput(fuel: Nat, w: R.World, value: R.Value, options: R.NodeOptions) -> R.World:
  C.world(C.eval(fuel, w, R.SignalScope{R.Literal{value}, options, R.Literal{R.Undefined{}}}, R.Undefined{}))

def createSignal(w: R.World, value: R.Value, equals: Bool) -> R.World:
  createSignalWithOptions(w, value, R.NodeOptions.with_equals(N.defaults(), equals))

# The explicit-parent facade expresses the same runWithOwner boundary as the
# TS host. The primitive constructor itself does not install/restore an owner.
def createMemoWithOptions(fuel: Nat, +w: R.World, expr: R.Expr, options: R.NodeOptions, +parent: Nat) -> R.World:
  context = R.World.context(w)
  tracking = R.World.tracking(w)
  +w = R.World.with_tracking(R.World.with_context(w, parent), False{})
  +id = nextId(w)
  +w = N.computed(fuel, w, expr, options, parent)
  w = B.choose(~R.World, B.ok(w), _ => B.event(w, R.AccessorBound{id}), _ => w)
  R.World.with_tracking(R.World.with_context(w, context), tracking)

def createMemo(fuel: Nat, w: R.World, expr: R.Expr, equals: Bool, lazy: Bool, parent: Nat) -> R.World:
  options = R.NodeOptions.with_lazy(R.NodeOptions.with_equals(N.defaults(), equals), lazy)
  createMemoWithOptions(fuel, w, expr, options, parent)

def createEffectWithHandlers(fuel: Nat, +w: R.World, expr: R.Expr, user: Bool, target: Nat, scheduled: Bool, deferred: Bool, options: R.NodeOptions, +parent: Nat, program: Nat, returnedCleanup: Nat, errorProgram: Nat) -> R.World:
  +id = nextId(w)
  context = R.World.context(w)
  tracking = R.World.tracking(w)
  w = R.World.with_tracking(R.World.with_context(w, parent), False{})
  kind = B.choose(~R.NodeKind, user, _ => R.User{}, _ => R.Render{})
  +w = N.createEffectNode(w, expr, kind, target, options, parent, program, returnedCleanup)
  w = B.store_node(w, id, R.Node.with_errorProgram(B.node(w, id), errorProgram))
  w = C.world(C.run(fuel, C.Machine{w, [C.Recompute{id, True{}}, C.InitialEffect{id, scheduled, deferred}], []}))
  R.World.with_tracking(R.World.with_context(w, context), tracking)

def createEffectWithPrograms(fuel: Nat, w: R.World, expr: R.Expr, user: Bool, target: Nat, scheduled: Bool, deferred: Bool, options: R.NodeOptions, parent: Nat, program: Nat, returnedCleanup: Nat) -> R.World:
  createEffectWithHandlers(fuel, w, expr, user, target, scheduled, deferred, options, parent, program, returnedCleanup, 0n)

# The admitted return-valued application closure delegates to the same source
# effect constructor. Its descriptor preserves its body result at application.
def createReturningEffect(fuel: Nat, w: R.World, expr: R.Expr, user: Bool, target: Nat, scheduled: Bool, deferred: Bool, options: R.NodeOptions, parent: Nat, program: Nat, errorProgram: Nat) -> R.World:
  body = {R.CallWith{program, R.Argument{0n}, R.Argument{1n}} : R.Expr}
  +pair = C.inlineProgram(w, R.SomeInlineBody{body, True{}}, 0n)
  createEffectWithHandlers(fuel, B.first(R.World, Nat, pair), expr, user, target, scheduled, deferred, options, parent, B.second(R.World, Nat, pair), 0n, errorProgram)

def createEffectWithOptions(fuel: Nat, w: R.World, expr: R.Expr, user: Bool, target: Nat, scheduled: Bool, deferred: Bool, options: R.NodeOptions, parent: Nat) -> R.World:
  createEffectWithPrograms(fuel, w, expr, user, target, scheduled, deferred, options, parent, 0n, 0n)

def createEffect(fuel: Nat, w: R.World, expr: R.Expr, user: Bool, target: Nat, scheduled: Bool, deferred: Bool, parent: Nat) -> R.World:
  createEffectWithOptions(fuel, w, expr, user, target, scheduled, deferred, N.defaults(), parent)

# signals.ts:createTrackedEffect, production BaseEffectOptions has no behavior knobs.
def createTrackedEffect(fuel: Nat, +w: R.World, body: R.Expr, +parent: Nat) -> R.World:
  +context = R.World.context(w)
  +tracking = R.World.tracking(w)
  +w = R.World.with_tracking(R.World.with_context(w, parent), False{})
  +w = C.world(C.eval(fuel, w, R.TrackedCreate{body}, R.Undefined{}))
  R.World.with_tracking(R.World.with_context(w, context), tracking)

def trackedCreate(body: R.Expr) -> R.Expr:
  R.TrackedCreate{body}

# Presence of loadingValue is independent from its payload being undefined.
def nodeOptions(equals: Bool, transparent: Bool, ownedWrite: Bool, lazy: Bool, sync: Bool, noSnapshot: Bool, loadingPresent: Bool, loadingValue: R.Value, unobserved: Nat) -> R.NodeOptions:
  R.NodeOptions{equals, transparent, ownedWrite, lazy, sync, noSnapshot, 0,
    B.choose(~R.Slot, loadingPresent, _ => R.Present{loadingValue}, _ => R.Empty{}), unobserved}

def read(fuel: Nat, w: R.World, id: Nat) -> C.Machine:
  C.run(fuel, C.Machine{w, [C.ReadNode{id}], []})

def firstValue(xs: List<&2, R.Value>) -> R.Value:
  match xs:
    case Nil{}:
      R.Undefined{}
    case h <> tail:
      h

def resultValue(m: C.Machine) -> R.Value:
  firstValue(C.values(m))

def resultWorld(m: C.Machine) -> R.World:
  C.world(m)

def flush(fuel: Nat, w: R.World) -> R.World:
  C.flush(fuel, w)

def setValue(fuel: Nat, +w: R.World, +id: Nat, value: R.Value) -> C.Machine:
  B.choose(~C.Machine, B.valid(w, id),
    _ => C.run(fuel, C.Machine{w, [C.setterTask(w, id)], [value]}),
    _ => C.Machine{R.World.with_fault(w, R.BadId{}), [], []})

def setSignal(+w: R.World, id: Nat, value: R.Value) -> R.World:
  C.world(setValue(B.budget(w), w, id, value))

# Updaters see staged composition; setter returns are preserved by the facade.
def updateValue(fuel: Nat, w: R.World, id: Nat, expr: R.Expr) -> C.Machine:
  C.eval(fuel, w, R.WriteExpr{id, expr, True{}}, R.Undefined{})

def setUpdater(fuel: Nat, w: R.World, id: Nat, expr: R.Expr) -> R.World:
  C.world(updateValue(fuel, w, id, expr))

# The source invalidation helper is separate from public awaitable refresh.
def markRefresh(+w: R.World, +id: Nat) -> R.World:
  B.choose(~R.World, B.valid(w, id), _ => C.markRefresh(w, id), _ => w)

# Host-boundary constructors: use these exports instead of generated JS tags.
def vUndefined() -> R.Value:
  R.Undefined{}

def vNull() -> R.Value:
  R.Null{}

def vNumber(n: Nat) -> R.Value:
  R.Number{n}

def vReference(id: Nat) -> R.Value:
  R.Reference{id}

def vOwner(id: Nat) -> R.Value:
  R.OwnerReference{id}

def validOwner(+w: R.World, +id: Nat) -> Bool:
  Bool.and(B.valid(w, id), Bool.or(B.root(R.Node.kind(B.node(w, id))), B.computed(R.Node.kind(B.node(w, id)))))

def validRoot(+w: R.World, +id: Nat) -> Bool:
  Bool.and(B.valid(w, id), B.root(R.Node.kind(B.node(w, id))))

def currentOwner() -> R.Expr:
  R.CurrentOwner{}

def currentObserver() -> R.Expr:
  R.CurrentObserver{}

def ownerDisposed(owner: R.Expr) -> R.Expr:
  R.OwnerDisposed{owner}

def withOwner(owner: R.Expr, body: R.Expr) -> R.Expr:
  R.WithOwner{owner, body}

# User ABI for createEffect's selected compute/application/error family.
def nestedEffect(compute: R.Expr, user: Bool, target: Nat, options: R.NodeOptions, scheduled: Bool, deferred: Bool, program: Nat, returnedCleanup: Nat, errorProgram: Nat) -> R.Expr:
  R.EffectCreate{compute, R.EffectSpec{user, target, options, scheduled, deferred, program, returnedCleanup, errorProgram, R.NoInlineBody{}}}

def nestedEffectBody(compute: R.Expr, user: Bool, target: Nat, options: R.NodeOptions, scheduled: Bool, deferred: Bool, body: R.Expr, returnedCleanup: Nat, errorProgram: Nat) -> R.Expr:
  R.EffectCreate{compute, R.EffectSpec{user, target, options, scheduled, deferred, 0n, returnedCleanup, errorProgram, R.SomeInlineBody{body, False{}}}}

def nestedReturningEffect(compute: R.Expr, user: Bool, target: Nat, options: R.NodeOptions, scheduled: Bool, deferred: Bool, body: R.Expr, errorProgram: Nat) -> R.Expr:
  R.EffectCreate{compute, R.EffectSpec{user, target, options, scheduled, deferred, 0n, 0n, errorProgram, R.SomeInlineBody{body, True{}}}}

def signalComputeScope(compute: R.Expr, options: R.NodeOptions, body: R.Expr) -> R.Expr:
  R.SignalComputeScope{compute, options, body}

def signalScope(initial: R.Expr, options: R.NodeOptions, body: R.Expr) -> R.Expr:
  R.SignalScope{initial, options, body}

def vAccessor(signal: Nat) -> R.Value:
  R.AccessorReference{signal}

def vSetter(signal: Nat) -> R.Value:
  R.SetterReference{signal}

def localSetter(depth: Nat) -> R.Expr:
  R.LocalSetter{depth}

def localAccessor(depth: Nat) -> R.Expr:
  R.LocalAccessor{depth}

def localRead(depth: Nat) -> R.Expr:
  R.LocalRead{depth}

def localWrite(depth: Nat, value: R.Expr, updater: Bool) -> R.Expr:
  R.LocalWrite{depth, value, updater}

# User ABI for the source expression createMemo(compute, options)().
def memoAccessor(compute: R.Expr, options: R.NodeOptions) -> R.Expr:
  R.MemoAccessor{compute, options}

def memoRead(compute: R.Expr, options: R.NodeOptions) -> R.Expr:
  R.MemoRead{compute, options}

def rootScope(body: R.Expr, transparent: Bool) -> R.Expr:
  R.RootScope{body, transparent}

def disposeRoot(owner: R.Expr) -> R.Expr:
  R.DisposeRoot{owner}

def evaluateExpression(fuel: Nat, w: R.World, expr: R.Expr, previous: R.Value) -> C.Machine:
  C.eval(fuel, w, expr, previous)

# owner.ts:createRoot's production body, hosted under an explicit parent just
# like the existing constructor facade. The represented init does not inspect
# its bound disposer argument; the host retains the root for later disposal.
def createRoot(fuel: Nat, +w: R.World, expr: R.Expr, +parent: Nat, transparent: Bool) -> C.Machine:
  +oldContext = R.World.context(w)
  +oldTracking = R.World.tracking(w)
  +id = nextId(w)
  w = N.createOwner(L.enterOwner(w, parent), parent, transparent)
  +m = C.eval(fuel, w, R.WithOwner{R.Literal{R.OwnerReference{id}}, Z.bind(expr, R.RootDisposerReference{id}, R.Undefined{})}, R.Undefined{})
  C.Machine{L.restore(C.world(m), oldContext, oldTracking), [], C.values(m)}

# Bookkeeping allowance for the additional core callback/owner steps; this
# remains an explicit implicit resource bound, not a source engine decision.
def invokeRootDisposer(+w: R.World, owner: Nat) -> R.World:
  C.ownerWorld(Nat.mul(8n, O.budget(w)), w, [O.Enter{owner, True{}, False{}}])

def vRootDisposer(owner: Nat) -> R.Value:
  R.RootDisposerReference{owner}

def argument(index: Nat) -> R.Expr:
  R.Argument{index}

def callWith(callback: Nat, first: R.Expr, second: R.Expr) -> R.Expr:
  R.CallWith{callback, first, second}

def invokeWith(callee: R.Expr, value: R.Expr, updater: Bool) -> R.Expr:
  R.InvokeWith{callee, value, updater}

def invoke(callee: R.Expr) -> R.Expr:
  R.Invoke{callee}

def onCleanup(callee: R.Expr) -> R.Expr:
  R.OnCleanup{callee}

def vText(s: String) -> R.Value:
  R.StringValue{s}

def vBoolean(b: Bool) -> R.Value:
  R.Boolean{b}

def vNaN() -> R.Value:
  R.NotANumber{}

def yes() -> Bool:
  True{}

def no() -> Bool:
  False{}

def literal(v: R.Value) -> R.Expr:
  R.Literal{v}

def source(id: Nat) -> R.Expr:
  R.Read{id}

def previous() -> R.Expr:
  R.Previous{}

def add(a: R.Expr, b: R.Expr) -> R.Expr:
  R.Add{a, b}

def multiply(a: R.Expr, b: R.Expr) -> R.Expr:
  R.Multiply{a, b}

def same(a: R.Expr, b: R.Expr) -> R.Expr:
  R.Same{a, b}

def select(condition: R.Expr, yes: R.Expr, no: R.Expr) -> R.Expr:
  R.Select{condition, yes, no}

def untrack(e: R.Expr) -> R.Expr:
  R.Untracked{e}

def throwError(cause: R.Value) -> R.Expr:
  R.Raise{cause}

def attach(w: R.World, parent: Nat, id: Nat) -> R.World:
  T.attach(w, parent, id)

def detach(w: R.World, id: Nat) -> R.World:
  T.detach(w, id)

def displayed(w: R.World, id: Nat) -> R.Value:
  T.text(w, id)

def dispose(+w: R.World, id: Nat) -> R.World:
  C.ownerWorld(Nat.mul(8n, O.budget(w)), w, [O.Dispose{id}])

# Constructor for the proof witness generator. It supplies no scheduling or
# answers: each following transition is core.step and is checked in BendTT.
def flushMachine(w: R.World) -> C.Machine:
  C.Machine{w, [C.Round{}], []}

# Reusable typed callback-program construction; no host scheduler is hidden here.
def emptyProgram() -> R.CleanupProgram:
  R.CleanupProgram{[], False{}}

def programEmit(code: Nat, tail: R.CleanupProgram) -> R.CleanupProgram:
  R.CleanupProgram{R.CleanupEmit{code} <> R.CleanupProgram.actions(tail), False{}}

def programWrite(signal: Nat, value: R.Value, tail: R.CleanupProgram) -> R.CleanupProgram:
  R.CleanupProgram{R.CleanupWrite{signal, value} <> R.CleanupProgram.actions(tail), False{}}

def programDispose(owner: Nat, tail: R.CleanupProgram) -> R.CleanupProgram:
  R.CleanupProgram{R.CleanupDispose{owner} <> R.CleanupProgram.actions(tail), False{}}

def programDisposeCurrent(tail: R.CleanupProgram) -> R.CleanupProgram:
  R.CleanupProgram{R.CleanupDisposeCurrent{} <> R.CleanupProgram.actions(tail), False{}}

def programCleanup(callback: Nat, tail: R.CleanupProgram) -> R.CleanupProgram:
  R.CleanupProgram{R.CleanupRegisterCurrent{callback} <> R.CleanupProgram.actions(tail), False{}}

def programThrow(cause: R.Value, tail: R.CleanupProgram) -> R.CleanupProgram:
  R.CleanupProgram{R.CleanupThrow{cause} <> R.CleanupProgram.actions(tail), False{}}

def programEvaluate(expr: R.Expr, tail: R.CleanupProgram) -> R.CleanupProgram:
  R.CleanupProgram{R.CallbackEvaluate{expr} <> R.CleanupProgram.actions(tail), False{}}

def programReturn(expr: R.Expr, tail: R.CleanupProgram) -> R.CleanupProgram:
  R.CleanupProgram{R.CallbackReturn{expr} <> R.CleanupProgram.actions(tail), False{}}

def programWriteExpr(signal: Nat, expr: R.Expr, tail: R.CleanupProgram) -> R.CleanupProgram:
  R.CleanupProgram{R.CallbackWrite{signal, expr} <> R.CleanupProgram.actions(tail), False{}}

def programUpdateExpr(signal: Nat, expr: R.Expr, tail: R.CleanupProgram) -> R.CleanupProgram:
  R.CleanupProgram{R.CallbackUpdate{signal, expr} <> R.CleanupProgram.actions(tail), False{}}

def programThrowExpr(expr: R.Expr, tail: R.CleanupProgram) -> R.CleanupProgram:
  R.CleanupProgram{R.CallbackThrow{expr} <> R.CleanupProgram.actions(tail), False{}}

def registerProgram(+w: R.World, program: R.CleanupProgram) -> R.World:
  R.World.with_cleanupPrograms(w, B.append(R.CleanupProgram, R.World.cleanupPrograms(w), [program]))

def nextProgramId(w: R.World) -> Nat:
  B.length(R.CleanupProgram, R.World.cleanupPrograms(w))

def callProgram(callback: Nat) -> R.Expr:
  R.CallProgram{callback}

def then(first: R.Expr, second: R.Expr) -> R.Expr:
  R.Then{first, second}

# A thrown host call consumes the exception outcome before the next API call.
def clearException(w: R.World) -> R.World:
  R.World.with_fault(w, R.Healthy{})

def resetErrorHalt(w: R.World) -> R.World:
  R.World.with_haltNotified(R.World.with_halted(w, False{}), False{})

def programPreviousCleanup(tail: R.CleanupProgram) -> R.CleanupProgram:
  R.CleanupProgram{R.CleanupPriorEffect{} <> R.CleanupProgram.actions(tail), False{}}

# PromiseLike host protocol: object identity and settlement are external inputs;
# registration, status, publication and flushing remain Bend engine operations.
def vAsync(id: Nat) -> R.Value:
  R.AsyncValue{id}

def nextAsyncId(w: R.World) -> Nat:
  B.length(R.AsyncObject, R.World.asyncObjects(w))

def createThenable(w: R.World, immediate: Bool) -> R.World:
  B.first(R.World, Nat, F.newThenable(w, immediate, R.Unresolved{}))

def resolveThenable(fuel: Nat, w: R.World, id: Nat, rejected: Bool, value: R.Value) -> R.World:
  C.resolveThenable(fuel, w, id, rejected, value)

def deliver(fuel: Nat, w: R.World, observer: Nat, rejected: Bool, value: R.Value) -> R.World:
  C.deliver(fuel, w, observer, rejected, value)

def clearHostJobs(w: R.World) -> R.World:
  R.World.with_hostJobs(w, [])

# Typed external iterator descriptors. No reactive decisions live in the host.
def emptyNexts() -> List<&2, R.NextInput>:
  []

def bareNext(done: Bool, value: R.Value, tail: List<&2, R.NextInput>) -> List<&2, R.NextInput>:
  R.BareNext{done, value} <> tail

def promiseNext(result: Nat, tail: List<&2, R.NextInput>) -> List<&2, R.NextInput>:
  R.PromiseNext{result} <> tail

def throwNext(error: R.Value, tail: List<&2, R.NextInput>) -> List<&2, R.NextInput>:
  R.ThrowNext{error} <> tail

def createStream(w: R.World, steps: List<&2, R.NextInput>, hasReturn: Bool, throws: Bool, error: R.Value, returned: Nat) -> R.World:
  I.newIterable(w, steps, hasReturn, B.choose(~R.Slot, throws, _ => R.Present{error}, _ => R.Empty{}), returned)

def vStepResult(done: Bool, value: R.Value) -> R.Value:
  R.StepResult{done, value}

def nextAwaiterId(w: R.World) -> Nat:
  B.length(R.Awaiter, R.World.awaiters(w))

def resolveValue(fuel: Nat, w: R.World, expr: R.Expr) -> R.World:
  J.resolve(fuel, w, expr)

def refresh(w: R.World, target: Nat) -> R.World:
  J.refresh(w, target)

def refreshValue(w: R.World, target: Nat) -> R.World:
  refresh(w, target)

def startRefresh(fuel: Nat, w: R.World, id: Nat) -> R.World:
  J.startRefresh(fuel, w, id)

def deliverWatch(w: R.World, id: Nat, rejected: Bool, value: R.Value) -> R.World:
  J.deliver(w, id, rejected, value)

def hostJobKind(job: R.HostJob) -> U32:
  match job:
    case R.FlushJob{}:
      0
    case R.DeliveryJob{observer, rejected, value}:
      1
    case R.WatchStart{awaiter}:
      2
    case R.WatchDelivery{awaiter, rejected, value}:
      3
    case R.PromiseOutcome{awaiter, rejected, value}:
      4
    case R.StartTimeout{awaiter, delay}:
      5
    case R.CancelTimeout{awaiter}:
      6
    case R.ListenAbort{awaiter, signal}:
      7
    case R.UnlistenAbort{awaiter, signal}:
      8

def untilValue(fuel: Nat, w: R.World, expr: R.Expr) -> R.World:
  J.until(fuel, w, expr)

def untilWithOptions(fuel: Nat, w: R.World, expr: R.Expr, timed: Bool, delay: Nat, signal: Nat) -> R.World:
  J.untilOptions(fuel, w, expr, timed, delay, signal)

def timeoutUntil(w: R.World, id: Nat) -> R.World:
  J.timeoutUntil(w, id)

def abortUntil(w: R.World, id: Nat) -> R.World:
  J.abortUntil(w, id)

def nextAbortId(w: R.World) -> Nat:
  B.length(R.AbortInput, R.World.abortInputs(w))

def createAbortInput(+w: R.World) -> R.World:
  R.World.with_abortInputs(w, B.append(R.AbortInput, R.World.abortInputs(w), [R.AbortInput{False{}, R.Undefined{}}]))

# External AbortSignal property snapshot, installed before its host dispatch.
def setAbortInput(+w: R.World, +id: Nat, reason: R.Value) -> R.World:
  +input = B.get(R.AbortInput, R.World.abortInputs(w), id, R.AbortInput{False{}, R.Undefined{}})
  B.choose(~R.World, R.AbortInput.aborted(input), _ => w,
    _ => R.World.with_abortInputs(w, List.set(&2, R.AbortInput, R.World.abortInputs(w), id, R.AbortInput{True{}, reason})))

def vTimeout(identity: Nat) -> R.Value:
  R.TimeoutFailure{identity}

def vExternalError(id: Nat, explicit: Bool, kind: U32, name: String, message: String, native: Bool, code: Nat) -> R.Value:
  R.ExternalError{id, explicit, kind, name, message, native, code}


def nextContextId(w: R.World) -> Nat:
  B.length(R.ContextKey, R.World.contextKeys(w))

def createContext(w: R.World, value: R.Value, description: R.Slot) -> R.World:
  Y.createContext(w, value, description)

def contextGet(key: Nat, owner: R.Expr) -> R.Expr:
  R.ContextGet{key, owner}

def contextSet(key: Nat, value: R.Expr, owner: R.Expr) -> R.Expr:
  R.ContextSet{key, value, owner}

def noDescription() -> R.Slot:
  R.Empty{}

def contextDescription(description: String) -> R.Slot:
  R.Present{R.StringValue{description}}

def vContextFailure(identity: Nat, kind: U32) -> R.Value:
  R.ContextFailure{identity, kind}

# Named callback function values retain the program's own two user arguments.
def vProgram(callback: Nat) -> R.Value:
  R.ProgramReference{callback}

def invokeArguments(callee: R.Expr, first: R.Expr, second: R.Expr) -> R.Expr:
  R.InvokeArguments{callee, first, second}

# Public onSettled entry runs under the caller-selected actual owner.
def onSettled(fuel: Nat, +w: R.World, body: R.Expr, +parent: Nat) -> R.World:
  +context = R.World.context(w)
  +tracking = R.World.tracking(w)
  +w = R.World.with_tracking(R.World.with_context(w, parent), False{})
  +w = C.world(C.eval(fuel, w, R.OnSettled{body}, R.Undefined{}))
  R.World.with_tracking(R.World.with_context(w, context), tracking)

def settled(body: R.Expr) -> R.Expr:
  R.OnSettled{body}

# createReaction returns its original first-class track closure. Its effect
# arms are constructed by the same core driver, under the captured owner.
def createReaction(fuel: Nat, +w: R.World, body: R.Expr, errorProgram: Nat, options: R.NodeOptions, scheduled: Bool, +parent: Nat) -> C.Machine:
  +context = R.World.context(w)
  +tracking = R.World.tracking(w)
  +w = R.World.with_tracking(R.World.with_context(w, parent), False{})
  +m = C.eval(fuel, w, R.ReactionCreate{body, errorProgram, options, scheduled}, R.Undefined{})
  C.Machine{R.World.with_tracking(R.World.with_context(C.world(m), context), tracking), [], C.values(m)}

def reactionCreate(body: R.Expr, errorProgram: Nat, options: R.NodeOptions, scheduled: Bool) -> R.Expr:
  R.ReactionCreate{body, errorProgram, options, scheduled}

def reactionArm(callee: R.Expr, tracking: R.Expr) -> R.Expr:
  R.ReactionArm{callee, tracking}
