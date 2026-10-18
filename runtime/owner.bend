# core/owner.ts production teardown. Tasks preserve recursive return points;
# the next sibling is read AFTER the child's disposal, never pre-collected.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./graph.bend as G
import ./heap.bend as H
import ./constants.bend as K

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
  Finish{id: Nat, self: Bool, zombie: Bool, flags: U32}
  RunDisposal{id: Nat, self: Bool, zombie: Bool}
  DisposalLoop{callbacks: List<&2, Nat>, count: Nat}
  EffectCleanup{id: Nat, self: Bool}
  Invoke{callback: Nat}
  Action{callback: Nat, action: R.CleanupAction}
  Dispose{id: Nat}

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
        _ => B.store_extension(w, id, R.NodeExtension.with_inFlight(B.extension(w, id), 0n)), _ => w)
      B.choose(~R.World, Bool.or(Bool.and(B.has(R.Node.status(B.node(w, id)), K.STATUS_PENDING()),
        Nat.is_ne(R.NodeExtension.transaction(B.extension(w, id)), 0n)), B.has(flags, K.REACTIVE_FRAME_READ())), _ => B.schedule(w), _ => w),
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
      +w = G.clearDeps(w, child)
      +w = B.store_node(w, child, R.Node.with_prevSibling(B.node(w, child), child))
      Machine{w, Enter{child, True{}, False{}} <> AfterChild{id, self, zombie, flags, child} <> rest})

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
      [Invoke{callback}]
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
    _ => Machine{B.store_node(w, id, R.Node.with_cleanup(B.node(w, id), 0n)), Invoke{callback} <> rest}, _ => Machine{w, rest})

def actions(+callback: Nat, xs: List<&2, R.CleanupAction>) -> List<&2, Task>:
  match xs:
    case Nil{}:
      []
    case action <> rest:
      Action{callback, action} <> actions(callback, rest)

def action(+w: R.World, rest: List<&2, Task>, callback: Nat, value: R.CleanupAction) -> Machine:
  match value:
    case R.CleanupEmit{code}:
      Machine{B.event(w, R.CleanupObserved{callback, code}), rest}
    case R.CleanupDispose{id}:
      Machine{w, Dispose{id} <> rest}
    case R.CleanupRegister{owner, cb}:
      Machine{cleanup(w, owner, cb), rest}
    case R.CleanupThrow{cause}:
      Machine{R.World.with_fault(w, R.CallbackThrown{cause}), []}

def disposeStart(+w: R.World, rest: List<&2, Task>, +id: Nat) -> Machine:
  B.choose(~Machine, B.valid(w, id),
    _ =>
      +w = B.choose(~R.World, B.computed(R.Node.kind(B.node(w, id))),
        _ =>
          +w = B.store_node(w, id, R.Node.with_config(B.node(w, id), B.clear(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE())))
          G.clearDeps(H.deleteFromHeap(w, id), id), _ => w)
      Machine{w, Enter{id, True{}, False{}} <> rest}, _ => Machine{R.World.with_fault(w, R.BadId{}), []})

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
    case AfterChild{id, self, zombie, flags, child} <> rest:
      Machine{w, Walk{id, self, zombie, flags, R.Node.nextSibling(B.node(w, child))} <> rest}
    case Finish{id, self, zombie, flags} <> rest:
      finish(w, rest, id, self, zombie, flags)
    case RunDisposal{id, self, zombie} <> rest:
      runDisposal(w, rest, id, self, zombie)
    case DisposalLoop{callbacks, 0n} <> rest:
      Machine{w, rest}
    case DisposalLoop{+callbacks, 1n+ +p} <> rest:
      Machine{w, Invoke{B.get(Nat, callbacks, p, 0n)} <> DisposalLoop{callbacks, p} <> rest}
    case EffectCleanup{id, self} <> rest:
      effectCleanup(w, rest, id, self)
    case Invoke{+callback} <> rest:
      B.choose(~Machine, Bool.and(Nat.is_ne(callback, 0n), Nat.is_lt(callback, B.length(R.CleanupProgram, R.World.cleanupPrograms(w)))),
        _ => Machine{w, B.append(Task, actions(callback, R.CleanupProgram.actions(B.get(R.CleanupProgram, R.World.cleanupPrograms(w), callback, R.CleanupProgram{[]}))), rest)},
        _ => Machine{R.World.with_fault(w, R.Unsupported{6n}), []})
    case Action{callback, value} <> rest:
      action(w, rest, callback, value)
    case Dispose{id} <> rest:
      disposeStart(w, rest, id)

def run(fuel: Nat, m: Machine) -> R.World:
  match fuel m:
    case _ Machine{w, Nil{}}:
      w
    case 0n Machine{w, tasks}:
      R.World.with_fault(w, R.Exhausted{})
    case 1n+p Machine{w, tasks}:
      run(p, dispatch(w, tasks))

# Explicit resource bound; cyclic callbacks can still exhaust it.
def budget(+w: R.World) -> Nat:
  Nat.mul(16n, Nat.add(B.budget(w), B.length(R.CleanupProgram, R.World.cleanupPrograms(w))))

def disposeChildren(+w: R.World, id: Nat, self: Bool, zombie: Bool) -> R.World:
  run(budget(w), Machine{w, [Enter{id, self, zombie}]})

def dispose(+w: R.World, id: Nat) -> R.World:
  run(budget(w), Machine{w, [Dispose{id}]})
