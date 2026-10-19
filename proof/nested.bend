# A source-shaped parent creates/reads a fresh owned memo on every pass.
# Updating its signal first refreshes the old child, then retires that child
# while the parent creates a replacement. No alternate publication engine.
import Base
import ../runtime/api.bend as A
import ../runtime/construct.bend as N
import ../runtime/ambient.bend as L
import ../representation/base.bend as B
import ../representation/records.bend as R


def scenario() -> R.World:
  w = A.createSignal(A.createWorld(), R.Number{1n}, True{})
  w = A.createMemo(512n, w,
    R.MemoRead{R.Add{R.Read{2n}, R.Literal{R.Number{2n}}}, N.defaults()},
    True{}, False{}, 1n)
  w = A.attach(w, 1n, 2n)
  w = A.createEffect(512n, w, R.Read{3n}, False{}, 2n, False{}, False{}, 1n)
  A.flush(1024n, A.setSignal(w, 2n, R.Number{4n}))


type View is Data:
  View{oldValue: R.Value, oldDead: Bool, oldDeps: Nat, oldSubs: Nat,
    newValue: R.Value, newParent: Nat, newHeight: Nat, child: Nat,
    size: Nat, screen: R.Value, context: Nat, tracking: Bool, fault: R.Fault}


def view(+w: R.World) -> View:
  View{R.Node.value(B.node(w, 4n)), L.isDisposed(w, 4n),
    R.Node.deps(B.node(w, 4n)), R.Node.subs(B.node(w, 4n)),
    R.Node.value(B.node(w, 6n)), R.Node.parent(B.node(w, 6n)),
    R.Node.height(B.node(w, 6n)), R.Node.firstChild(B.node(w, 3n)),
    B.length(R.Node, R.World.nodes(w)), R.TreeNode.text(B.get(R.TreeNode, R.World.tree(w), 2n, B.blank_tree())),
    R.World.context(w), R.World.tracking(w), R.World.fault(w)}


def expected() -> View:
  View{R.Number{6n}, True{}, 0n, 0n, R.Number{6n}, 3n, 1n, 6n, 7n,
    R.Number{6n}, 0n, False{}, R.Healthy{}}

# createEffect queues its first application; disposing its init root before
# that queue drains skips the application and never installs its returned cleanup.
def visibleEvents(events: List<&2, R.TraceEvent>) -> List<&2, R.TraceEvent>:
  match events:
    case Nil{}:
      []
    case R.Constructed{created} <> rest:
      visibleEvents(rest)
    case event <> rest:
      event <> visibleEvents(rest)


type EffectView is Data:
  EffectView{result: R.Value, initialQueue: List<&2, Nat>,
    events: List<&2, R.TraceEvent>, modified: Bool, previous: R.Value,
    value: R.Value, dead: Bool, child: Nat, context: Nat,
    tracking: Bool, fault: R.Fault}


def effectView(+early: Bool) -> EffectView:
  +m = A.createRoot(512n, A.createWorld(),
    A.nestedEffect(R.Literal{R.Number{5n}}, True{}, 0n, N.defaults(), False{}, False{}, 0n, 0n, 0n),
    1n, False{})
  +before = A.resultWorld(m)
  +after = A.flush(512n, B.choose(~R.World, early, _ => A.dispose(before, 2n), _ => before))
  EffectView{A.resultValue(m), R.World.userQueue(before), visibleEvents(R.World.events(after)),
    R.Node.modified(B.node(after, 3n)), R.Node.prevValue(B.node(after, 3n)),
    R.Node.value(B.node(after, 3n)), L.isDisposed(after, 3n), R.Node.firstChild(B.node(after, 2n)),
    R.World.context(after), R.World.tracking(after), R.World.fault(after)}


def expectedEffect() -> EffectView:
  EffectView{R.Undefined{}, [3n], [R.Invoked{3n}, R.Applied{3n, R.Number{5n}, R.Undefined{}}],
    False{}, R.Number{5n}, R.Number{5n}, False{}, 3n, 0n, False{}, R.Healthy{}}


def expectedEarlyDisposal() -> EffectView:
  EffectView{R.Undefined{}, [3n], [R.Invoked{3n}], True{}, R.Undefined{},
    R.Number{5n}, True{}, 0n, 0n, False{}, R.Healthy{}}
