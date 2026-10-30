# Derive empty sweep queues after arbitrary finite real held setter bodies.
# Preparation, write/cache framing, retirement and observer draining are actual.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../proof/held-first-ready.bend as Ready
import ../proof/held-first-ready-construction.bend as Constructed
import ../proof/held-pair-generic-body.bend as Generic
import ../proof/held-resume-retirement.bend as Resume
import ../proof/action-control-flags.bend as Flags
import ../proof/held-pair-generic-round.bend as Round
import ../proof/held-pair-generic-context.bend as Context
import ../proof/action-body-entry.bend as Entry
import ../proof/transaction-pair.bend as Pair
import ../proof/ordinary-graph-data.bend as Graph
import ../proof/held-opened-state.bend as First
import ./joined-round-heap-frame.bend as HeapFrame
import ./heap-entry-view.bend as Heap
import ./action-heap-entry.bend as Action
import ./sweep-input-frame.bend as Sweep

def generic(+seed: R.World,+id: Nat,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+ready: Ready.Ready<seed,id,Generic.left(Resume.methods(values,id,answer),other,second)>,+known: {Flags.observe(seed) == Flags.Flags{0n,False{},False{}} : Flags.View}) -> {Sweep.observe(Round.world(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known)) == Sweep.observe(seed) : Sweep.View}:
  +input = Generic.world(seed,id,values,answer,other,reverse,second)
  +prepared = Entry.prepared(input,Context.actor(second),R.ActionEnd{})
  +written = HeapFrame.written(seed,id,values,answer,other,reverse,second)
  +after = Round.world(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known)
  +first = Sweep.fromHeap(written,after,HeapFrame.retained(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known))
  +writes = Sweep.written(values,prepared,id,Pair.targetPred([],[],reverse),Round.input(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known))
  +toInput = Sweep.fromHeap(input,prepared,Action.prepared(input,Context.actor(second),R.ActionEnd{}))
  +toSeed = Sweep.fromHeap(seed,input,Action.pair(seed,Generic.right(Resume.methods(values,id,answer),other,second),reverse))
  Equal.trans(Sweep.View,Sweep.observe(after),Sweep.observe(written),Sweep.observe(seed),first,Equal.trans(Sweep.View,Sweep.observe(written),Sweep.observe(prepared),Sweep.observe(seed),writes,Equal.trans(Sweep.View,Sweep.observe(prepared),Sweep.observe(input),Sweep.observe(seed),toInput,toSeed)))

def seed(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+second: Bool) -> R.World:
  First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second))

def world(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,incoming: R.Value,rejected: Bool) -> R.World:
  Round.world(seed(value,values,answer,other,second),Graph.source(value),values,answer,other,reverse,second,rest,stack,incoming,rejected,Constructed.constructed(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Flags.raw(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)))

def constructed(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> {Sweep.observe(world(value,values,answer,other,reverse,second,rest,stack,incoming,rejected)) == Sweep.Lists{[],[]} : Sweep.View}:
  +methods = Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)
  +before = seed(value,values,answer,other,second)
  +same = generic(before,Graph.source(value),values,answer,other,reverse,second,rest,stack,incoming,rejected,Constructed.constructed(value,methods),Flags.raw(value,methods))
  +toGraph = Sweep.fromHeap(Graph.linked(value),before,Action.heldController(value,methods))
  +initial = Equal.trans(Sweep.View,Sweep.observe(Graph.linked(value)),Sweep.ofHeap(Heap.observe(Graph.linked(value))),Sweep.Lists{[],[]},Equal.sym(Sweep.View,Sweep.ofHeap(Heap.observe(Graph.linked(value))),Sweep.observe(Graph.linked(value)),Sweep.heapRead(Graph.linked(value))),Equal.cong(Heap.View,Sweep.View,view=>Sweep.ofHeap(view),Heap.observe(Graph.linked(value)),Heap.HeapEntry{[],[],[0n],0n,0n,[]},Action.graph(value)))
  Equal.trans(Sweep.View,Sweep.observe(world(value,values,answer,other,reverse,second,rest,stack,incoming,rejected)),Sweep.observe(before),Sweep.Lists{[],[]},same,Equal.trans(Sweep.View,Sweep.observe(before),Sweep.observe(Graph.linked(value)),Sweep.Lists{[],[]},toGraph,initial))

def initial(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+second: Bool) -> {Sweep.observe(seed(value,values,answer,other,second)) == Sweep.Lists{[],[]} : Sweep.View}:
  +methods = Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)
  +before = seed(value,values,answer,other,second)
  +toGraph = Sweep.fromHeap(Graph.linked(value),before,Action.heldController(value,methods))
  +initial = Equal.trans(Sweep.View,Sweep.observe(Graph.linked(value)),Sweep.ofHeap(Heap.observe(Graph.linked(value))),Sweep.Lists{[],[]},Equal.sym(Sweep.View,Sweep.ofHeap(Heap.observe(Graph.linked(value))),Sweep.observe(Graph.linked(value)),Sweep.heapRead(Graph.linked(value))),Equal.cong(Heap.View,Sweep.View,view=>Sweep.ofHeap(view),Heap.observe(Graph.linked(value)),Heap.HeapEntry{[],[],[0n],0n,0n,[]},Action.graph(value)))
  Equal.trans(Sweep.View,Sweep.observe(before),Sweep.observe(Graph.linked(value)),Sweep.Lists{[],[]},toGraph,initial)
