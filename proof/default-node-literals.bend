# Exact default constructor literals, tied to the actual source operations.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/construct-state.bend as N
import ../runtime/constants.bend as K

def effectRecord(+w: R.World, expr: R.Expr, target: Nat, program: Nat, returnedCleanup: Nat) -> R.Node:
  {R.Node{R.Render{}, R.Undefined{}, R.Empty{}, False{}, K.CONFIG_FRAME(),
    K.REACTIVE_LAZY(), K.STATUS_UNINITIALIZED(), R.World.clock(w), R.Unstamped{},
    0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n,
    expr, False{}, R.Undefined{}, target, False{},
    0n, 0n, R.Node.scope(B.node(w, 0n)), 0n, R.NoDisposal{}, 0n, program, returnedCleanup, 0n} : R.Node}

def effect(+w: R.World, +expr: R.Expr, +target: Nat, +program: Nat, +returnedCleanup: Nat) ->
  {N.createEffectNode(w, expr, R.Render{}, target, N.defaults(), 0n, program, returnedCleanup) == N.setupComputedNode(N.append(w, effectRecord(w, expr, target, program, returnedCleanup)), B.length(R.Node, R.World.nodes(w))) : R.World}:
  {==}

def signalRecord(w: R.World, value: R.Value) -> R.Node:
  {R.Node{R.Signal{}, value, R.Empty{}, True{}, 0,
    0, 0, R.World.clock(w), R.Unstamped{}, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n,
    0n, 0n, 0n, 0n, R.Literal{R.Undefined{}}, False{}, R.Undefined{}, 0n, False{},
    0n, 0n, 0n, 0n, R.NoDisposal{}, 0n, 0n, 0n, 0n} : R.Node}

def signal(+w: R.World, +value: R.Value) ->
  {N.signal(w, value, N.defaults()) == N.append(w, signalRecord(w, value)) : R.World}:
  {==}


def memoRecord(+w: R.World, expr: R.Expr) -> R.Node:
  {R.Node{R.Memo{}, R.Undefined{}, R.Empty{}, True{}, K.CONFIG_AUTO_DISPOSE(),
    0, K.STATUS_UNINITIALIZED(),
    R.World.clock(w), R.Unstamped{}, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n,
    0n, 0n, 0n, 0n, expr, False{}, R.Undefined{}, 0n, False{},
    0n, 0n, R.Node.scope(B.node(w, 0n)), 0n, R.NoDisposal{}, 0n, 0n, 0n, 0n} : R.Node}

def memo(+w: R.World, +expr: R.Expr) ->
  {N.computed(w, expr, N.defaults(), 0n) == N.setupComputedNode(N.append(w, memoRecord(w, expr)), B.length(R.Node, R.World.nodes(w))) : R.World}:
  {==}
