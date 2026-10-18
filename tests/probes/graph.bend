import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/construct.bend as N
import ../../runtime/graph.bend as G
import ../../runtime/owner.bend as O
import ../../runtime/extension.bend as E
import ../../runtime/constants.bend as K

def fixture(+op: U32, +auto: Bool, flags: U32, pending: Bool, +hook: U32) -> R.World:
  +w = N.createOwner(B.empty(), 0n, False{})
  +w = N.signal(w, R.Number{7n}, R.NodeOptions.with_unobserved(N.defaults(), 1n))
  +opts = R.NodeOptions.with_lazy(N.defaults(), True{})
  +w = N.computed(0n, w, R.Literal{R.Number{11n}}, R.NodeOptions.with_unobserved(opts, 2n), 1n)
  +w = N.createOwner(w, 3n, False{})
  +w = N.computed(0n, w, R.Literal{R.Number{13n}}, opts, 1n)
  +w = B.store_node(w, 3n, R.Node.with_flags(B.node(w, 3n), flags))
  +w = B.store_node(w, 3n, R.Node.with_config(B.node(w, 3n), B.choose(~U32, auto, _ => K.CONFIG_AUTO_DISPOSE(), _ => 0)))
  +w = B.store_node(w, 3n, R.Node.with_status(B.node(w, 3n), B.choose(~U32, pending, _ => K.STATUS_PENDING(), _ => 0)))
  +w = G.link(w, 2n, 3n)
  +w = B.choose(~R.World, U32.is_eq(op, 3), _ => G.queueDormant(w, 3n), _ => G.link(w, 3n, 5n))
  +w = O.cleanup(w, 3n, 3n)
  +w = R.World.with_cleanupPrograms(w, [R.CleanupProgram{[]},
    R.CleanupProgram{[R.CleanupEmit{101n}]},
    R.CleanupProgram{R.CleanupEmit{102n} <> B.choose(~List<&2, R.CleanupAction>, U32.is_eq(hook, 1),
      _ => [R.CleanupThrow{R.Number{99n}}],
      _ => B.choose(~List<&2, R.CleanupAction>, U32.is_eq(hook, 2), _ => [R.CleanupWrite{2n, R.Number{9n}}], _ => []))},
    R.CleanupProgram{[R.CleanupEmit{103n}]}])
  B.choose(~R.World, U32.is_eq(op, 0), _ => G.clearDeps(w, 5n),
    _ => B.choose(~R.World, U32.is_eq(op, 1),
      _ => G.trimStaleDeps(B.store_node(w, 5n, R.Node.with_depsTail(B.node(w, 5n), 0n)), 5n),
      _ => B.choose(~R.World, U32.is_eq(op, 2), _ => B.first(R.World, Nat, G.unlinkSubs(w, R.Node.deps(B.node(w, 5n)))),
        _ => G.sweepDormant(w))))
