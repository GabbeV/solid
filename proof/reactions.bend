# Actual createReaction closure, arm replacement, callbacks and cleanup. A
# separate negative fixture retains the pinned source's pending-arm hole.
import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../runtime/constants.bend as K
import ../runtime/construct-state.bend as N
import ../runtime/reaction-state.bend as Reaction
import ../representation/base.bend as B
import ../representation/records.bend as R

def arm(+w: R.World, callee: R.Value, body: R.Expr) -> R.World:
  C.world(C.eval(4096n, w, R.ReactionArm{R.Literal{callee}, body}, R.Undefined{}))

type View is Data:
  View{first: R.Value, second: R.Value, third: R.Value, cleaned: R.Value,
    oldDead: Bool, currentDead: Bool, oldDeps: Nat, currentDeps: Nat, arm: Nat,
    context: Nat, tracking: Bool, pending: List<&2, Nat>, users: List<&2, R.QueueEntry>, scheduled: Bool, fault: R.Fault}

def lifecycle() -> View:
  w = A.createSignal(A.createWorld(), R.Number{0n}, True{})
  w = A.createSignal(w, R.Number{0n}, True{})
  w = A.createSignal(w, R.Number{0n}, True{})
  w = A.createSignal(w, R.Number{0n}, True{})
  w = A.registerProgram(w, A.programUpdateExpr(5n, R.Add{R.Previous{}, R.Literal{R.Number{1n}}}, A.emptyProgram()))
  +made = A.createReaction(2048n, w, R.Then{R.WriteExpr{4n, R.Add{R.Read{4n}, R.Literal{R.Number{1n}}}, False{}}, R.Literal{R.ProgramReference{1n}}}, 0n, N.defaults(), False{}, 1n)
  +track = A.resultValue(made)
  w = arm(A.resultWorld(made), track, R.Read{2n})
  w = arm(w, track, R.Read{3n})
  +replaced = A.flush(4096n, A.setSignal(w, 2n, R.Number{1n}))
  +first = A.flush(4096n, A.setSignal(replaced, 3n, R.Number{1n}))
  w = arm(first, track, R.Read{3n})
  +second = A.flush(4096n, A.setSignal(w, 3n, R.Number{2n}))
  +done = A.flush(4096n, A.dispose(second, 1n))
  View{R.Node.value(B.node(replaced, 4n)), R.Node.value(B.node(first, 4n)), R.Node.value(B.node(second, 4n)), R.Node.value(B.node(done, 5n)),
    B.has(R.Node.flags(B.node(done, 6n)), K.REACTIVE_DISPOSED()), B.has(R.Node.flags(B.node(done, 8n)), K.REACTIVE_DISPOSED()), R.Node.deps(B.node(done, 6n)), R.Node.deps(B.node(done, 8n)), R.ReactionState.arm(Reaction.get(done, 0n)),
    R.World.context(done), R.World.tracking(done), R.World.pendingNodes(done), R.World.userQueue(done), R.World.scheduled(done), R.World.fault(done)}

def expectedLifecycle() -> View:
  View{R.Number{0n}, R.Number{1n}, R.Number{2n}, R.Number{2n}, True{}, True{}, 0n, 0n, 0n, 0n, False{}, [], [], False{}, R.Healthy{}}

type PendingView is Data:
  PendingView{obsoleteFires: R.Value, currentFires: R.Value, pendingArm: Nat, liveAfterReplacement: Bool, fault: R.Fault}

def pendingReplacement(+seeded: Bool) -> PendingView:
  w = A.createThenable(A.createWorld(), True{})
  w = A.createSignal(w, R.Number{0n}, True{})
  w = A.createSignal(w, R.Number{0n}, True{})
  opts = B.choose(~R.NodeOptions, seeded, _ => R.NodeOptions.with_loading(N.defaults(), R.Present{R.Number{0n}}), _ => N.defaults())
  w = A.createMemoWithOptions(2048n, w, R.Literal{R.AsyncValue{1n}}, opts, 1n)
  +made = A.createReaction(2048n, w, R.Then{R.WriteExpr{3n, R.Add{R.Read{3n}, R.Literal{R.Number{1n}}}, False{}}, R.Literal{R.Undefined{}}}, 0n, N.defaults(), False{}, 1n)
  +track = A.resultValue(made)
  +pending = arm(A.resultWorld(made), track, R.Read{4n})
  +replaced = arm(pending, track, R.Read{2n})
  +obsolete = A.flush(8192n, A.resolveThenable(8192n, replaced, 1n, False{}, R.Number{7n}))
  +current = A.flush(8192n, A.setSignal(obsolete, 2n, R.Number{1n}))
  PendingView{R.Node.value(B.node(obsolete, 3n)), R.Node.value(B.node(current, 3n)), R.ReactionState.arm(Reaction.get(pending, 0n)), Bool.not(B.has(R.Node.flags(B.node(replaced, 5n)), K.REACTIVE_DISPOSED())), R.World.fault(current)}

# This intentionally states the failure, not the desired replacement property.
def expectedPendingBug() -> PendingView:
  PendingView{R.Number{1n}, R.Number{2n}, 0n, True{}, R.Healthy{}}

def expectedSeededControl() -> PendingView:
  PendingView{R.Number{0n}, R.Number{1n}, 5n, False{}, R.Healthy{}}
