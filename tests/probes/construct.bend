import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/construct.bend as N
import ../../runtime/extension.bend as E
import ../../runtime/constants.bend as K
import ../../runtime/question.bend as J
import ../../runtime/heap.bend as H
import ../../runtime/core.bend as C

def options(+bits: U32, +load: U32, unobserved: Bool) -> R.NodeOptions:
  R.NodeOptions{Bool.not(B.has(bits, 32)), B.has(bits, 1), B.has(bits, 2),
    B.has(bits, 4), B.has(bits, 8), B.has(bits, 16), K.CONFIG_FRESH_READ(),
    B.choose(~R.Slot, U32.is_eq(load, 0), _ => R.Empty{},
      _ => R.Present{B.choose(~R.Value, U32.is_eq(load, 1), _ => R.Number{5n}, _ => R.Undefined{})}),
    B.choose(~Nat, unobserved, _ => 1n, _ => 0n)}

def parents() -> R.World:
  +w = N.createOwner(B.empty(), 0n, False{})
  +w = B.store_node(w, 1n, R.Node.with_scope(B.node(w, 1n), 41n))
  +w = N.computed(0n, w, R.Literal{R.Number{17n}}, R.NodeOptions.with_lazy(N.defaults(), True{}), 1n)
  +w = B.store_node(w, 2n, R.Node.with_height(B.node(w, 2n), 7n))
  N.createOwner(w, 2n, False{})

def fixture(+kind: U32, bits: U32, load: U32, +parentMode: Nat, unobserved: Bool) -> R.World:
  +w = R.World.with_context(parents(), parentMode)
  +opts = options(bits, load, unobserved)
  B.choose(~R.World, U32.is_eq(kind, 6),
    _ => C.world(C.eval(256n, N.signal(w, R.Number{11n}, N.defaults()), R.SignalScope{R.Literal{R.AccessorReference{4n}}, opts, R.Literal{R.Undefined{}}}, R.Undefined{})),
    _ => B.choose(~R.World, U32.is_eq(kind, 0), _ => N.signal(w, R.Number{11n}, opts),
    _ => B.choose(~R.World, U32.is_eq(kind, 5),
      _ => C.world(C.eval(256n, w, R.SignalComputeScope{R.Literal{R.Number{17n}}, opts, R.Literal{R.Undefined{}}}, R.Undefined{})),
    _ => B.choose(~R.World, U32.is_eq(kind, 1),
      _ => N.computed(128n, w, R.Literal{R.Number{17n}}, opts, parentMode),
      _ => B.choose(~R.World, U32.is_eq(kind, 4), _ => N.createOwner(w, parentMode, R.NodeOptions.transparent(opts)),
        _ => N.createEffectNode(w, R.Literal{R.Number{17n}}, B.choose(~R.NodeKind, U32.is_eq(kind, 2), _ => R.Render{}, _ => R.User{}), 0n, opts, parentMode, 0n, 0n))))))

type Allocation is Data:
  Allocation{before: R.World, first: R.World, second: R.World}

def allocation() -> Allocation:
  +w = N.signal(B.empty(), R.Number{11n}, N.defaults())
  +first = E.ext(w, 1n)
  +second = B.store_extension(first, 1n, R.NodeExtension.with_q(B.extension(first, 1n), J.fromNat(19n)))
  Allocation{w, first, E.ext(second, 1n)}

def heapUnderRoot() -> R.World:
  +w = N.computed(0n, parents(), R.Literal{R.Number{17n}}, R.NodeOptions.with_lazy(N.defaults(), True{}), 3n)
  +w = B.store_node(w, 4n, R.Node.with_height(B.node(w, 4n), 0n))
  H.insertIntoHeap(w, 4n)

def readUnderRoot() -> C.Machine:
  +w = N.signal(parents(), R.Number{11n}, N.defaults())
  +w = R.World.with_tracking(R.World.with_context(w, 3n), True{})
  C.run(128n, C.Machine{w, [C.ReadNode{4n}], []})
