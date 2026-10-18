import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/construct.bend as N
import ../../runtime/status.bend as A
import ../../runtime/graph.bend as G
import ../../runtime/extension.bend as E
import ../../runtime/constants.bend as K

def metadata(+w: R.World, +id: Nat, +value: R.Value, sources: Bool) -> R.World:
  +w = E.ext(w, id)
  +w = B.store_extension(w, id, R.NodeExtension.with_error(B.extension(w, id), value))
  +w = B.store_extension(w, id, R.NodeExtension.with_blocked(B.extension(w, id), R.Present{R.Boolean{True{}}}))
  B.setPendingSources(w, id, B.choose(~R.SourceSet, sources, _ => R.Sources{[id]}, _ => R.NoSources{}))

def fixture(+op: U32, +kind: U32, status: U32, config: U32, +value: R.Value, sources: Bool) -> R.World:
  +w = N.createOwner(R.World.with_clock(B.empty(), 5n), 0n, False{})
  +opts = R.NodeOptions.with_lazy(N.defaults(), True{})
  +w = B.choose(~R.World, U32.is_eq(kind, 0), _ => N.computed(0n, w, R.Literal{R.Number{7n}}, opts, 1n),
    _ => N.createEffectNode(w, R.Literal{R.Number{7n}}, B.choose(~R.NodeKind, U32.is_eq(kind, 1), _ => R.User{}, _ => R.Render{}), 2n, opts, 1n, 0n, 0n))
  +w = N.computed(0n, w, R.Literal{R.Number{11n}}, opts, 1n)
  +w = N.computed(0n, w, R.Literal{R.Number{13n}}, opts, 1n)
  +w = G.link(G.link(G.link(w, 2n, 3n), 3n, 4n), 2n, 4n)
  +w = B.store_node(w, 2n, R.Node.with_status(B.node(w, 2n), status))
  +w = B.store_node(w, 3n, R.Node.with_config(B.node(w, 3n), config))
  +w = metadata(w, 2n, value, sources)
  +w = R.World.with_clock(w, 5n)
  B.choose(~R.World, U32.is_eq(op, 0), _ => A.clearStatus(w, 2n, False{}),
    _ => B.choose(~R.World, U32.is_eq(op, 1), _ => A.clearStatus(w, 2n, True{}),
      _ => B.choose(~R.World, U32.is_eq(op, 2), _ => A.notifyStatus(w, 2n, value),
        _ => A.notifyStatusWith(w, 2n, B.choose(~U32, U32.is_eq(op, 3), _ => K.STATUS_ERROR(), _ => K.STATUS_PENDING()), value, True{}))))

def value(code: U32) -> R.Value:
  match code:
    case 0:
      R.Undefined{}
    case 1:
      R.Null{}
    case 2:
      R.Boolean{False{}}
    case _:
      R.Number{42n}

def run(op: U32, kind: U32, status: U32, config: U32, code: U32, sources: Bool) -> R.World:
  fixture(op, kind, status, config, value(code), sources)
