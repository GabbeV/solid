import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../observation/tree.bend as T
import ./core.bend as C
import ./scheduler.bend as S
import ./owner.bend as O
import ./construct.bend as N

# One explicit lifetime root for the current host grammar.
def createWorld() -> R.World:
  N.createOwner(B.empty(), 0n, False{})

def nextId(w: R.World) -> Nat:
  B.length(R.Node, R.World.nodes(w))

def createSignalWithOptions(w: R.World, value: R.Value, options: R.NodeOptions) -> R.World:
  N.signal(w, value, options)

def createSignal(w: R.World, value: R.Value, equals: Bool) -> R.World:
  createSignalWithOptions(w, value, R.NodeOptions.with_equals(N.defaults(), equals))

# The explicit-parent facade expresses the same runWithOwner boundary as the
# TS host. The primitive constructor itself does not install/restore an owner.
def createMemoWithOptions(fuel: Nat, +w: R.World, expr: R.Expr, options: R.NodeOptions, +parent: Nat) -> R.World:
  context = R.World.context(w)
  tracking = R.World.tracking(w)
  w = R.World.with_tracking(R.World.with_context(w, parent), False{})
  w = N.computed(fuel, w, expr, options, parent)
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

def createEffectWithOptions(fuel: Nat, w: R.World, expr: R.Expr, user: Bool, target: Nat, scheduled: Bool, deferred: Bool, options: R.NodeOptions, parent: Nat) -> R.World:
  createEffectWithPrograms(fuel, w, expr, user, target, scheduled, deferred, options, parent, 0n, 0n)

def createEffect(fuel: Nat, w: R.World, expr: R.Expr, user: Bool, target: Nat, scheduled: Bool, deferred: Bool, parent: Nat) -> R.World:
  createEffectWithOptions(fuel, w, expr, user, target, scheduled, deferred, N.defaults(), parent)

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

def setSignal(+w: R.World, +id: Nat, +value: R.Value) -> R.World:
  B.choose(~R.World, B.valid(w, id), _ => S.setSignal(w, id, value), _ => R.World.with_fault(w, R.BadId{}))

# Updaters see staged composition; setter returns are preserved by the facade.
def setUpdater(fuel: Nat, +w: R.World, +id: Nat, expr: R.Expr) -> R.World:
  +m = C.eval(fuel, w, expr, B.current(B.node(w, id)))
  B.choose(~R.World, C.healthy(R.World.fault(C.world(m))),
    _ => setSignal(C.world(m), id, resultValue(m)), _ => C.world(m))

# Compatibility facade: invalidation only. Public awaitable refresh is open.
def refresh(+w: R.World, +id: Nat) -> R.World:
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

def dispose(w: R.World, id: Nat) -> R.World:
  O.dispose(w, id)

# Constructor for the proof witness generator. It supplies no scheduling or
# answers: each following transition is core.step and is checked in BendTT.
def flushMachine(w: R.World) -> C.Machine:
  C.Machine{w, [C.Round{}], []}

# Reusable typed callback-program construction; no host scheduler is hidden here.
def emptyProgram() -> R.CleanupProgram:
  R.CleanupProgram{[]}

def programEmit(code: Nat, tail: R.CleanupProgram) -> R.CleanupProgram:
  R.CleanupProgram{R.CleanupEmit{code} <> R.CleanupProgram.actions(tail)}

def programWrite(signal: Nat, value: R.Value, tail: R.CleanupProgram) -> R.CleanupProgram:
  R.CleanupProgram{R.CleanupWrite{signal, value} <> R.CleanupProgram.actions(tail)}

def programDispose(owner: Nat, tail: R.CleanupProgram) -> R.CleanupProgram:
  R.CleanupProgram{R.CleanupDispose{owner} <> R.CleanupProgram.actions(tail)}

def programDisposeCurrent(tail: R.CleanupProgram) -> R.CleanupProgram:
  R.CleanupProgram{R.CleanupDisposeCurrent{} <> R.CleanupProgram.actions(tail)}

def programCleanup(callback: Nat, tail: R.CleanupProgram) -> R.CleanupProgram:
  R.CleanupProgram{R.CleanupRegisterCurrent{callback} <> R.CleanupProgram.actions(tail)}

def programThrow(cause: R.Value, tail: R.CleanupProgram) -> R.CleanupProgram:
  R.CleanupProgram{R.CleanupThrow{cause} <> R.CleanupProgram.actions(tail)}

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
  R.CleanupProgram{R.CleanupPriorEffect{} <> R.CleanupProgram.actions(tail)}
