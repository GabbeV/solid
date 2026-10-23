# Read the actual factory/owner-binding return point before any outer iterator
# consumer overwrites the supersession slot with its own close callback.
import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/construct.bend as N
import ../../runtime/core.bend as C
import ../../runtime/from-state.bend as F
import ../../runtime/extension.bend as E
import ../../runtime/constants.bend as K

type Probe is Data:
  Probe{world: R.World, iterator: Nat, finish: Nat, returned: C.Machine}

def slot(code: U32) -> R.Flight:
  match code:
    case 0: R.FlightUndefined{}
    case 1: R.FlightEmpty{}
    case _: R.FlightActive{7n}

def iterator(value: R.Value) -> Nat:
  match value:
    case R.IteratorReference{iterator}: iterator
    case _: 0n

def closeThroughHook(+w: R.World, id: Nat) -> C.Machine:
  +callback = R.NodeExtension.flightTeardown(B.extension(w, R.World.context(w)))
  +w = B.choose(~R.World, Nat.is_eq(callback, 0n), _ => w,
    _ => C.world(C.eval(128n, w, R.CallProgram{callback}, R.Undefined{})))
  C.run(128n, C.Machine{w, [C.IteratorReturn{id, R.Empty{}}], []})

def opened(+machine: C.Machine) -> Probe:
  +w = C.world(machine)
  +id = iterator(B.get(R.Value, C.values(machine), 0n, R.Undefined{}))
  +plan = R.ExternalIterator.plan(B.iterator(w, id))
  Probe{w, id, R.FromSubscription.finish(F.subscription(w, plan)), closeThroughHook(w, id)}

def probe(+context: Nat, flags: U32, forbidden: Bool, hasExt: Bool, flight: U32, previous: Bool, thrown: Bool) -> Probe:
  +w = N.createOwner(B.empty(), 0n, False{})
  +w = N.computed(0n, w, R.Literal{R.Number{1n}}, R.NodeOptions.with_lazy(N.defaults(), True{}), 1n)
  +w = B.store_node(w, 2n, R.Node.with_flags(B.node(w, 2n), flags))
  +w = B.choose(~R.World, Nat.is_ne(context, 0n),
    _ => B.store_node(w, context, R.Node.with_config(B.node(w, context), B.choose(~U32, forbidden, _ => K.CONFIG_CHILDREN_FORBIDDEN(), _ => 0))), _ => w)
  +w = R.World.with_cleanupPrograms(w, [R.CleanupProgram{[], False{}, 0n}, R.CleanupProgram{[R.CleanupEmit{1n}], False{}, 0n}, R.CleanupProgram{B.choose(~List<&2, R.CleanupAction>, thrown, _ => [R.CleanupEmit{2n}, R.CleanupThrow{R.Number{99n}}], _ => [R.CleanupEmit{2n}]), False{}, 0n}, R.CleanupProgram{[R.CallbackReturn{R.Literal{R.ProgramReference{2n}}}], False{}, 3n}])
  +w = B.choose(~R.World, Bool.and(hasExt, Nat.is_ne(context, 0n)),
    _ =>
      +w = E.ext(w, context)
      B.store_extension(w, context, R.NodeExtension.with_flightTeardown(R.NodeExtension.with_inFlight(B.extension(w, context), slot(flight)), B.choose(~Nat, previous, _ => 1n, _ => 0n))), _ => w)
  +w = R.World.with_context(w, context)
  +pair = F.create(w, R.FromFunction{R.ProgramReference{3n}})
  opened(C.run(256n, C.Machine{B.first(R.World, Nat, pair), [C.FromOpen{B.second(R.World, Nat, pair)}], []}))
