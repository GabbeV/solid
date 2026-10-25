# core/owner.ts production teardown. Tasks preserve recursive return points;
# the next sibling is read AFTER the child's disposal, never pre-collected.
import Base
import ./deferred-runtime.bend as Deferred
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./graph-state.bend as G
import ./heap.bend as H
import ./constants.bend as K
import ./extension.bend as E
import ./write.bend as W
import ./memo-write.bend as MW
import ./iterator-state.bend as I
import ./cleanup-state.bend as Cleanup

def linkChild(+w: R.World, +parent: Nat, +id: Nat) -> R.World:
  +head = R.Node.firstChild(B.node(w, parent))
  +w = B.store_node(w, id, R.Node.with_prevSibling(B.node(w, id), 0n))
  +w = B.store_node(w, id, R.Node.with_nextSibling(B.node(w, id), head))
  +w = B.choose(~R.World, Nat.is_ne(head, 0n),
    _ => B.store_node(w, head, R.Node.with_prevSibling(B.node(w, head), id)), _ => w)
  B.store_node(w, parent, R.Node.with_firstChild(B.node(w, parent), id))

# core/owner.ts:cleanup, with owner explicit at the callback boundary.
def addDisposal(disposal: R.Disposal, callback: Nat) -> R.Disposal:
  match disposal:
    case R.NoDisposal{}:
      R.OneDisposal{callback}
    case R.OneDisposal{old}:
      R.ManyDisposals{[old, callback]}
    case R.ManyDisposals{callbacks}:
      R.ManyDisposals{B.append(Nat, callbacks, [callback])}

def cleanup(+w: R.World, +owner: Nat, callback: Nat) -> R.World:
  B.choose(~R.World, Nat.is_eq(owner, 0n), _ => w,
    _ => B.store_node(w, owner, R.Node.with_disposal(B.node(w, owner), addDisposal(R.Node.disposal(B.node(w, owner)), callback))))

type Task is Data:
  Enter{id: Nat, self: Bool, zombie: Bool}
  AfterPark{id: Nat, self: Bool, zombie: Bool, flags: U32}
  Walk{id: Nat, self: Bool, zombie: Bool, flags: U32, child: Nat}
  AfterChild{id: Nat, self: Bool, zombie: Bool, flags: U32, child: Nat}
  PrepareChild{id: Nat, self: Bool, zombie: Bool, flags: U32, child: Nat}
  Finish{id: Nat, self: Bool, zombie: Bool, flags: U32}
  RunDisposal{id: Nat, self: Bool, zombie: Bool}
  DisposalLoop{callbacks: List<&2, Nat>, count: Nat}
  EffectCleanup{id: Nat, self: Bool}
  Invoke{callback: Nat}
  RunCleanup{callback: Nat}
  CleanupFinally{}
  RootEnd{}
  Action{callback: Nat, action: R.CleanupAction}
  WriteValue{signal: Nat, current: R.Value, value: R.Value}
  WriteForward{signal: Nat, value: R.Value}
  WriteMemoFinish{signal: Nat, held: Bool}
  Dispose{id: Nat}
  MarkChildren{id: Nat}
  MarkChild{child: Nat}
  MarkNext{child: Nat}
  ClearDeps{id: Nat}
  ClearDepSlots{id: Nat}
  TrimDeps{id: Nat}
  TrimDepSlots{id: Nat, tail: Nat}
  UnlinkLoop{edge: Nat}
  UnlinkOnce{edge: Nat}
  AfterUnobservedHook{id: Nat}
  Unobserved{id: Nat}
  SweepDormant{index: Nat}
  ClearDormant{}

type Machine is Data:
  Machine{world: R.World, tasks: List<&2, Task>}

def parked(+w: R.World, +id: Nat) -> Bool:
  Bool.and(Nat.is_ne(R.Node.x(B.node(w, id)), 0n), Bool.or(Nat.is_ne(R.NodeExtension.pendingFirstChild(B.extension(w, id)), 0n),
    Bool.not(B.noDisposal(R.NodeExtension.pendingDisposal(B.extension(w, id))))))

def enter(+w: R.World, +rest: List<&2, Task>, +id: Nat, +self: Bool, +zombie: Bool) -> Machine:
  +flags = R.Node.flags(B.node(w, id))
  B.choose(~Machine, B.has(flags, K.REACTIVE_DISPOSED()), _ => Machine{w, rest},
    _ => B.choose(~Machine, Bool.and(zombie, Nat.is_eq(R.Node.x(B.node(w, id)), 0n)),
      _ => Machine{R.World.with_fault(w, R.Unsupported{5n}), []},
      _ =>
        +next = {AfterPark{id, self, zombie, flags} <> rest : List<&2, Task>}
        B.choose(~Machine, Bool.and(self, Bool.and(Bool.not(zombie), parked(w, id))),
          _ => Machine{w, Enter{id, False{}, True{}} <> next}, _ => Machine{w, next})))

def afterPark(+w: R.World, rest: List<&2, Task>, +id: Nat, +self: Bool, +zombie: Bool, +flags: U32) -> Machine:
  +w = B.choose(~R.World, self, _ => B.store_node(w, id, R.Node.with_flags(B.node(w, id), B.set(flags, K.REACTIVE_DISPOSED()))), _ => w)
  +w = B.choose(~R.World, Bool.and(self, B.computed(R.Node.kind(B.node(w, id)))),
    _ =>
      +w = B.choose(~R.World, Nat.is_ne(R.Node.x(B.node(w, id)), 0n),
        _ => B.store_extension(w, id, R.NodeExtension.with_inFlight(B.extension(w, id), R.FlightEmpty{})), _ => w)
      B.choose(~R.World, Bool.or(Bool.or(Bool.and(B.has(R.Node.status(B.node(w, id)), K.STATUS_PENDING()),
        Nat.is_ne(R.NodeExtension.transaction(B.extension(w, id)), 0n)), B.has(flags, K.REACTIVE_FRAME_READ())),
        Bool.not(List.is_empty(&2, Nat, R.World.pendingNodes(w)))), _ => B.schedule(w), _ => w),
    _ => w)
  +child = B.choose(~Nat, zombie, _ => R.NodeExtension.pendingFirstChild(B.extension(w, id)), _ => R.Node.firstChild(B.node(w, id)))
  +w = B.choose(~R.World, zombie,
    _ => B.store_extension(w, id, R.NodeExtension.with_pendingFirstChild(B.extension(w, id), 0n)),
    _ => B.store_node(w, id, R.Node.with_firstChild(B.node(w, id), 0n)))
  Machine{w, Walk{id, self, zombie, flags, child} <> rest}

def walk(+w: R.World, +rest: List<&2, Task>, +id: Nat, +self: Bool, +zombie: Bool, +flags: U32, +child: Nat) -> Machine:
  B.choose(~Machine, Nat.is_eq(child, 0n), _ => Machine{w, Finish{id, self, zombie, flags} <> rest},
    _ =>
      +w = B.store_node(w, child, R.Node.with_config(B.node(w, child), B.clear(R.Node.config(B.node(w, child)), K.CONFIG_AUTO_DISPOSE())))
      +w = H.deleteFromHeap(w, child)
      Machine{w, ClearDeps{child} <> PrepareChild{id, self, zombie, flags, child} <> rest})

def splice(+w: R.World, +id: Nat) -> R.World:
  +n = B.node(w, id)
  +prev = R.Node.prevSibling(n)
  +next = R.Node.nextSibling(n)
  +w = B.choose(~R.World, Nat.is_ne(prev, 0n),
    _ => B.store_node(w, prev, R.Node.with_nextSibling(B.node(w, prev), next)),
    _ => B.store_node(w, R.Node.parent(n), R.Node.with_firstChild(B.node(w, R.Node.parent(n)), next)))
  +w = B.choose(~R.World, Nat.is_ne(next, 0n),
    _ => B.store_node(w, next, R.Node.with_prevSibling(B.node(w, next), prev)), _ => w)
  B.store_node(w, id, R.Node.with_prevSibling(B.node(w, id), 0n))

def finish(+w: R.World, rest: List<&2, Task>, +id: Nat, +self: Bool, +zombie: Bool, flags: U32) -> Machine:
  +w = B.choose(~R.World, Bool.not(zombie), _ => B.store_node(w, id, R.Node.with_childCount(B.node(w, id), 0n)), _ => w)
  +parent = R.Node.parent(B.node(w, id))
  +w = B.choose(~R.World, Bool.and(self, Bool.and(Bool.not(zombie), Bool.and(Bool.not(B.has(flags, K.REACTIVE_ZOMBIE())),
    Bool.and(Nat.is_ne(parent, 0n), Bool.not(B.has(R.Node.flags(B.node(w, parent)), K.REACTIVE_DISPOSED())))))), _ => splice(w, id), _ => w)
  Machine{w, RunDisposal{id, self, zombie} <> rest}

def disposalTasks(disposal: R.Disposal) -> List<&2, Task>:
  match disposal:
    case R.NoDisposal{}:
      []
    case R.OneDisposal{callback}:
      [RunCleanup{callback}]
    case R.ManyDisposals{+callbacks}:
      [DisposalLoop{callbacks, B.length(Nat, callbacks)}]

def runDisposal(+w: R.World, rest: List<&2, Task>, +id: Nat, self: Bool, +zombie: Bool) -> Machine:
  +disposal = B.choose(~R.Disposal, zombie, _ => R.NodeExtension.pendingDisposal(B.extension(w, id)), _ => R.Node.disposal(B.node(w, id)))
  +w = B.choose(~R.World, B.noDisposal(disposal), _ => w,
    _ => B.choose(~R.World, zombie,
      _ => B.store_extension(w, id, R.NodeExtension.with_pendingDisposal(B.extension(w, id), R.NoDisposal{})),
      _ => B.store_node(w, id, R.Node.with_disposal(B.node(w, id), R.NoDisposal{}))))
  Machine{w, B.append(Task, disposalTasks(disposal), EffectCleanup{id, self} <> rest)}

def effectCleanup(+w: R.World, +rest: List<&2, Task>, +id: Nat, self: Bool) -> Machine:
  +callback = R.Node.cleanup(B.node(w, id))
  B.choose(~Machine, Bool.and(self, Nat.is_ne(callback, 0n)),
    _ => Machine{B.store_node(w, id, R.Node.with_cleanup(B.node(w, id), 0n)), RunCleanup{callback} <> rest}, _ => Machine{w, rest})

def actions(+callback: Nat, xs: List<&2, R.CleanupAction>) -> List<&2, Task>:
  match xs:
    case Nil{}:
      []
    case action <> rest:
      Action{callback, action} <> actions(callback, rest)

# setSignal's typeof-function updater branch for the admitted bound disposer.
# Its throw skips the write; a successful bound disposer returns undefined.
def writeDataValue(+w: R.World, +rest: List<&2, Task>, +signal: Nat, value: R.Value) -> Machine:
  match value:
    case R.RootDisposerReference{owner}:
      Machine{w, Enter{owner, True{}, False{}} <> RootEnd{} <> WriteValue{signal, B.current(B.node(w, signal)), R.Undefined{}} <> rest}
    case R.AccessorReference{source}:
      Machine{R.World.with_fault(w, R.Unsupported{9n}), rest}
    case R.ProgramReference{callback}:
      Machine{R.World.with_fault(w, R.Unsupported{9n}), rest}
    case R.SetterReference{target}:
      Machine{R.World.with_fault(w, R.Unsupported{9n}), rest}
    case other:
      Machine{W.setSignal(w, signal, other), rest}

# A named callback retains the constructor-selected setter too. Held setMemo
# invokes its raw function before the setSignal entry captures currentValue.
# The admitted root disposer ignores its previous-value argument; getter/setter
# arguments still require the unfinished owner/core read boundary.
def writeHeldValue(+w: R.World, +rest: List<&2, Task>, +signal: Nat, value: R.Value) -> Machine:
  match value:
    case R.RootDisposerReference{owner}:
      Machine{w, Enter{owner, True{}, False{}} <> RootEnd{} <> WriteForward{signal, R.Undefined{}} <> rest}
    case R.AccessorReference{source}:
      Machine{R.World.with_fault(w, R.Unsupported{9n}), rest}
    case R.ProgramReference{callback}:
      Machine{R.World.with_fault(w, R.Unsupported{9n}), rest}
    case R.SetterReference{target}:
      Machine{R.World.with_fault(w, R.Unsupported{9n}), rest}
    case other:
      Machine{W.setSignal(MW.recover(w, signal), signal, other), rest}

def writeValueKind(+w: R.World, +rest: List<&2, Task>, +signal: Nat, +value: R.Value, kind: R.NodeKind) -> Machine:
  match kind:
    case R.Memo{}:
      +pair = MW.held(w, signal)
      +w = B.first(R.World, Bool, pair)
      +held = B.second(R.World, Bool, pair)
      +ending = {WriteMemoFinish{signal, held} <> rest : List<&2, Task>}
      B.choose(~Machine, held, _ => writeHeldValue(w, ending, signal, value), _ => writeDataValue(MW.recover(w, signal), ending, signal, value))
    case _:
      writeDataValue(w, rest, signal, value)

def writeValue(+w: R.World, rest: List<&2, Task>, +signal: Nat, value: R.Value) -> Machine:
  writeValueKind(w, rest, signal, value, R.Node.kind(B.node(w, signal)))

# runDisposal invokes bound functions with no arguments. Their captured node
# and entry (setSignal versus setMemo) survive the callback's call receiver.
def clearSetterKind(+w: R.World, +signal: Nat, kind: R.NodeKind) -> R.World:
  match kind:
    case R.Memo{}:
      MW.clear(w, signal)
    case _:
      W.setSignal(w, signal, R.Undefined{})

def clearSetter(+w: R.World, +signal: Nat) -> R.World:
  clearSetterKind(w, signal, R.Node.kind(B.node(w, signal)))

def action(+w: R.World, +rest: List<&2, Task>, callback: Nat, value: R.CleanupAction) -> Machine:
  match value:
    case R.CleanupEmit{code}:
      Machine{B.event(w, R.CleanupObserved{callback, code}), rest}
    case R.CleanupDispose{id}:
      Machine{w, Dispose{id} <> rest}
    case R.CleanupRegister{owner, cb}:
      Machine{cleanup(w, owner, cb), rest}
    case R.CleanupWrite{id, value}:
      writeValue(w, rest, id, value)
    case R.CleanupRegisterCurrent{cb}:
      Machine{cleanup(w, R.World.context(w), cb), rest}
    case R.CleanupDisposeCurrent{}:
      Machine{w, Dispose{R.World.context(w)} <> rest}
    case R.CleanupPriorEffect{}:
      +id = R.World.callbackEffect(w)
      +cb = R.Node.cleanup(B.node(w, id))
      +w = B.store_node(w, id, R.Node.with_cleanup(B.node(w, id), 0n))
      Machine{w, B.choose(~List<&2, Task>, Nat.is_ne(cb, 0n), _ => Invoke{cb} <> rest, _ => rest)}
    case R.DeferredEnd{cell}:
      Machine{Deferred.end(w, cell), rest}
    case R.CleanupCloseIterator{stream}:
      Machine{I.close(w, stream), rest}
    case R.CleanupBoundRoot{owner}:
      Machine{w, Enter{owner, True{}, False{}} <> RootEnd{} <> rest}
    case R.CleanupBoundProgram{callback}:
      Machine{w, Invoke{callback} <> rest}
    case R.CleanupBoundSetter{signal}:
      Machine{clearSetter(w, signal), rest}
    case R.CleanupThrow{cause}:
      Machine{R.World.with_fault(w, R.CallbackThrown{cause}), rest}
    # Expression-bearing callbacks currently run on core's read continuation
    # machine. Teardown reads need an owner/core suspension boundary first.
    case _:
      Machine{R.World.with_fault(w, R.Unsupported{9n}), []}

def disposeStart(+w: R.World, +rest: List<&2, Task>, +id: Nat) -> Machine:
  B.choose(~Machine, B.valid(w, id),
    _ => B.choose(~Machine, B.computed(R.Node.kind(B.node(w, id))),
      _ =>
        +w = B.store_node(w, id, R.Node.with_config(B.node(w, id), B.clear(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE())))
        Machine{w, Unobserved{id} <> rest},
      _ => Machine{w, Enter{id, True{}, False{}} <> RootEnd{} <> rest}),
    _ => Machine{R.World.with_fault(w, R.BadId{}), []})

# graph.ts:unlinkSubs after its captured pointer reads and stores.
def unlinkOnce(+w: R.World, +rest: List<&2, Task>, +edge: Nat) -> Machine:
  +link = B.link(w, edge)
  +id = R.Link.dep(link)
  +last = Bool.and(Nat.is_eq(R.Link.prevSub(link), 0n), Nat.is_eq(R.Link.nextSub(link), 0n))
  +w = B.first(R.World, Nat, G.unlinkSubs(w, edge))
  B.choose(~Machine, last,
    _ => B.choose(~Machine, B.has(R.Node.config(B.node(w, id)), K.CONFIG_SLOT_NODE()),
      _ => Machine{R.World.with_fault(w, R.Unsupported{8n}), []},
      _ =>
        +callback = R.NodeExtension.unobserved(B.extension(w, id))
        +todo = B.choose(~List<&2, Task>, Nat.is_ne(callback, 0n), _ => [RunCleanup{callback}], _ => [])
        Machine{w, B.append(Task, todo, AfterUnobservedHook{id} <> rest)}),
    _ => Machine{w, rest})

def dispatch(+w: R.World, tasks: List<&2, Task>) -> Machine:
  match tasks:
    case Nil{}:
      Machine{w, []}
    case Enter{id, self, zombie} <> rest:
      enter(w, rest, id, self, zombie)
    case AfterPark{id, self, zombie, flags} <> rest:
      afterPark(w, rest, id, self, zombie, flags)
    case Walk{id, self, zombie, flags, child} <> rest:
      walk(w, rest, id, self, zombie, flags, child)
    case PrepareChild{+id, +self, +zombie, +flags, +child} <> rest:
      Machine{B.store_node(w, child, R.Node.with_prevSibling(B.node(w, child), child)), Enter{child, True{}, False{}} <> AfterChild{id, self, zombie, flags, child} <> rest}
    case AfterChild{id, self, zombie, flags, child} <> rest:
      Machine{w, Walk{id, self, zombie, flags, R.Node.nextSibling(B.node(w, child))} <> rest}
    case Finish{id, self, zombie, flags} <> rest:
      finish(w, rest, id, self, zombie, flags)
    case RunDisposal{id, self, zombie} <> rest:
      runDisposal(w, rest, id, self, zombie)
    case DisposalLoop{callbacks, 0n} <> rest:
      Machine{w, rest}
    case DisposalLoop{+callbacks, 1n+ +p} <> rest:
      Machine{w, RunCleanup{B.get(Nat, callbacks, p, 0n)} <> DisposalLoop{callbacks, p} <> rest}
    case EffectCleanup{id, self} <> rest:
      effectCleanup(w, rest, id, self)
    case RunCleanup{callback} <> rest:
      Machine{w, Invoke{callback} <> CleanupFinally{} <> rest}
    case CleanupFinally{} <> rest:
      Machine{w, rest}
    case RootEnd{} <> rest:
      Machine{Cleanup.disposeRootSelfEnd(w), rest}
    case Invoke{+callback} <> rest:
      B.choose(~Machine, Bool.and(Nat.is_ne(callback, 0n), Nat.is_lt(callback, B.length(R.CleanupProgram, R.World.cleanupPrograms(w)))),
        _ => Machine{w, B.append(Task, actions(callback, R.CleanupProgram.actions(B.get(R.CleanupProgram, R.World.cleanupPrograms(w), callback, R.CleanupProgram{[], False{}, 0n}))), rest)},
        _ => Machine{R.World.with_fault(w, R.Unsupported{6n}), []})
    case Action{callback, value} <> rest:
      action(w, rest, callback, value)
    case WriteValue{signal, current, value} <> rest:
      Machine{W.setResolved(w, signal, current, value), rest}
    case WriteForward{+signal, value} <> rest:
      Machine{W.setSignal(MW.recover(w, signal), signal, value), rest}
    case WriteMemoFinish{signal, held} <> rest:
      Machine{MW.finish(w, signal, held), rest}
    case Dispose{id} <> rest:
      disposeStart(w, rest, id)
    case MarkChildren{id} <> rest:
      Machine{w, MarkChild{R.Node.firstChild(B.node(w, id))} <> rest}
    case MarkChild{+child} <> +rest:
      B.choose(~Machine, Nat.is_eq(child, 0n), _ => Machine{w, rest},
        _ => Machine{B.store_node(w, child, R.Node.with_flags(B.node(w, child), B.set(R.Node.flags(B.node(w, child)), K.REACTIVE_ZOMBIE()))),
          MarkChildren{child} <> MarkNext{child} <> rest})
    case MarkNext{child} <> rest:
      Machine{w, MarkChild{R.Node.nextSibling(B.node(w, child))} <> rest}
    case ClearDeps{+id} <> +rest:
      +edge = R.Node.deps(B.node(w, id))
      B.choose(~Machine, Nat.is_eq(edge, 0n), _ => Machine{w, rest},
        _ => Machine{w, UnlinkLoop{edge} <> ClearDepSlots{id} <> rest})
    case ClearDepSlots{+id} <> rest:
      Machine{B.store_node(w, id, R.Node.with_depsTail(R.Node.with_deps(B.node(w, id), 0n), 0n)), rest}
    case TrimDeps{+id} <> +rest:
      +tail = R.Node.depsTail(B.node(w, id))
      +edge = B.choose(~Nat, Nat.is_ne(tail, 0n), _ => R.Link.nextDep(B.link(w, tail)), _ => R.Node.deps(B.node(w, id)))
      B.choose(~Machine, Nat.is_eq(edge, 0n), _ => Machine{w, rest},
        _ => Machine{w, UnlinkLoop{edge} <> TrimDepSlots{id, tail} <> rest})
    case TrimDepSlots{+id, +tail} <> rest:
      +w = B.choose(~R.World, Nat.is_ne(tail, 0n), _ => B.store_link(w, tail, R.Link.with_nextDep(B.link(w, tail), 0n)),
        _ => B.store_node(w, id, R.Node.with_deps(B.node(w, id), 0n)))
      Machine{w, rest}
    case UnlinkLoop{+edge} <> +rest:
      B.choose(~Machine, Nat.is_eq(edge, 0n), _ => Machine{w, rest},
        _ => Machine{w, UnlinkOnce{edge} <> UnlinkLoop{R.Link.nextDep(B.link(w, edge))} <> rest})
    case UnlinkOnce{edge} <> rest:
      unlinkOnce(w, rest, edge)
    case AfterUnobservedHook{+id} <> +rest:
      +n = B.node(w, id)
      dormant = Bool.and(B.computed(R.Node.kind(n)), Bool.and(B.has(R.Node.config(n), K.CONFIG_AUTO_DISPOSE()),
        Bool.and(Bool.not(B.has(R.Node.flags(n), K.REACTIVE_ZOMBIE())), Bool.not(B.has(R.Node.status(n), K.STATUS_PENDING())))))
      B.choose(~Machine, dormant,
        _ => B.choose(~Machine, Nat.is_ne(R.World.deferredReleases(w), 0n),
          _ => Machine{G.deferRelease(w, id), rest}, _ => Machine{w, Unobserved{id} <> rest}),
        _ => Machine{w, rest})
    case Unobserved{+id} <> rest:
      Machine{H.deleteFromHeap(w, id), ClearDeps{id} <> Enter{id, True{}, False{}} <> rest}
    case SweepDormant{+index} <> +rest:
      B.choose(~Machine, Nat.is_ge(index, B.length(Nat, R.World.dormantNodes(w))), _ => Machine{w, ClearDormant{} <> rest},
        _ =>
          +id = B.get(Nat, R.World.dormantNodes(w), index, 0n)
          +n = B.node(w, id)
          eligible = Bool.and(Nat.is_eq(R.Node.subs(n), 0n), Bool.and(B.has(R.Node.config(n), K.CONFIG_AUTO_DISPOSE()),
            Bool.and(Bool.not(B.has(R.Node.status(n), K.STATUS_PENDING())), Bool.not(B.has(R.Node.flags(n), B.set(K.REACTIVE_DISPOSED(), K.REACTIVE_ZOMBIE()))))))
          +todo = B.choose(~List<&2, Task>, eligible, _ => [Unobserved{id}], _ => [])
          Machine{w, B.append(Task, todo, SweepDormant{1n+index} <> rest)})
    case ClearDormant{} <> rest:
      Machine{R.World.with_dormantNodes(w, []), rest}

# runCleanup's catch skips only the remainder of this callback, then resumes
# the captured teardown. Raw Invoke remains unguarded for non-cleanup callers.
def unwind(+w: R.World, tasks: List<&2, Task>) -> Machine:
  match tasks:
    case Nil{}:
      Machine{w, []}
    case CleanupFinally{} <> rest:
      Machine{Cleanup.runCleanupCatch(w, R.World.fault(w)), rest}
    case task <> rest:
      Machine{w, rest}

def run(fuel: Nat, m: Machine) -> R.World:
  match fuel m:
    case _ Machine{w, Nil{}}:
      w
    case 0n Machine{w, tasks}:
      R.World.with_fault(w, R.Exhausted{})
    case 1n+ +p Machine{+w, +tasks}:
      B.choose(~R.World, B.ok(w), _ => run(p, dispatch(w, tasks)), _ => run(p, unwind(w, tasks)))

# Explicit resource bound; cyclic callbacks can still exhaust it.
def budget(+w: R.World) -> Nat:
  Nat.mul(16n, Nat.add(B.budget(w), B.length(R.CleanupProgram, R.World.cleanupPrograms(w))))

def disposeChildren(+w: R.World, id: Nat, self: Bool, zombie: Bool) -> R.World:
  run(budget(w), Machine{w, [Enter{id, self, zombie}]})

def dispose(+w: R.World, id: Nat) -> R.World:
  run(budget(w), Machine{w, [Dispose{id}]})

def invoke(+w: R.World, callback: Nat) -> R.World:
  run(budget(w), Machine{w, [Invoke{callback}]})

# One imperative statement in a core callback; nested disposal still runs the
# same owner continuation machine, including callback identity and reentry.
def invokeAction(+w: R.World, callback: Nat, value: R.CleanupAction) -> R.World:
  run(budget(w), Machine{w, [Action{callback, value}]})

# core/owner.ts:markDisposal and core/core.ts:parkChildren.
def markDisposal(+w: R.World, id: Nat) -> R.World:
  run(budget(w), Machine{w, [MarkChildren{id}]})

def parkChildren(+w: R.World, +id: Nat) -> R.World:
  +w = markDisposal(w, id)
  +w = E.ext(w, id)
  +w = B.store_extension(w, id, R.NodeExtension.with_pendingDisposal(B.extension(w, id), R.Node.disposal(B.node(w, id))))
  +w = B.store_extension(w, id, R.NodeExtension.with_pendingFirstChild(B.extension(w, id), R.Node.firstChild(B.node(w, id))))
  +w = B.store_node(w, id, R.Node.with_disposal(B.node(w, id), R.NoDisposal{}))
  +w = B.store_node(w, id, R.Node.with_firstChild(B.node(w, id), 0n))
  B.store_node(w, id, R.Node.with_childCount(B.node(w, id), 0n))

# core/async.ts:releaseFlightTeardown, through the same callback protocol.
def releaseFlightTeardown(+w: R.World, +id: Nat) -> R.World:
  +callback = R.NodeExtension.flightTeardown(B.extension(w, id))
  B.choose(~R.World, Nat.is_ne(callback, 0n),
    _ => invoke(B.store_extension(w, id, R.NodeExtension.with_flightTeardown(B.extension(w, id), 0n)), callback), _ => w)

# graph.ts operations share this continuation machine with source owner calls.
def clearDeps(+w: R.World, id: Nat) -> R.World:
  run(budget(w), Machine{w, [ClearDeps{id}]})

def trimStaleDeps(+w: R.World, id: Nat) -> R.World:
  run(budget(w), Machine{w, [TrimDeps{id}]})

def unlinkSubs(+w: R.World, edge: Nat) -> R.World:
  run(budget(w), Machine{w, [UnlinkOnce{edge}]})

def unobserved(+w: R.World, id: Nat) -> R.World:
  run(budget(w), Machine{w, [Unobserved{id}]})

def sweepDormant(+w: R.World) -> R.World:
  B.choose(~R.World, List.is_empty(&2, Nat, R.World.dormantNodes(w)), _ => w,
    _ => run(budget(w), Machine{w, [SweepDormant{0n}]}))

# Domain check for selected callback function values at the unfinished owner
# expression boundary. It is not a source cleanup decision.
def rawTeardownValue(value: R.Value) -> Bool:
  match value:
    case R.AccessorReference{signal}:
      False{}
    case R.SetterReference{signal}:
      False{}
    case R.ProgramReference{callback}:
      False{}
    case _:
      True{}

def admittedAction(action: R.CleanupAction) -> Bool:
  match action:
    case R.CallbackEvaluate{expr}:
      False{}
    case R.ActionFunction{factory, methods, previous}:
      False{}
    case R.FlattenChildren{results, skip}:
      False{}
    case R.CallbackReturn{expr}:
      False{}
    case R.CallbackWrite{signal, expr}:
      False{}
    case R.CallbackUpdate{signal, expr}:
      False{}
    case R.CallbackThrow{expr}:
      False{}
    case R.CleanupPriorEffect{}:
      False{}
    case R.CleanupWrite{signal, value}:
      rawTeardownValue(value)
    case _:
      True{}

def admittedActions(actions: List<&2, R.CleanupAction>) -> Bool:
  match actions:
    case Nil{}:
      True{}
    case action <> rest:
      Bool.and(admittedAction(action), admittedActions(rest))

def admittedProgram(+w: R.World, +callback: Nat) -> Bool:
  Bool.and(Bool.and(Nat.is_ne(callback, 0n), Nat.is_lt(callback, B.length(R.CleanupProgram, R.World.cleanupPrograms(w)))),
    admittedActions(R.CleanupProgram.actions(B.get(R.CleanupProgram, R.World.cleanupPrograms(w), callback, R.CleanupProgram{[], False{}, 0n}))))
