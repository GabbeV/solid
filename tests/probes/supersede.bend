import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/construct.bend as N
import ../../runtime/core.bend as C
import ../../runtime/extension.bend as E
import ../../runtime/supersede.bend as S

type Probe is Data:
  Probe{registered: R.World, final: C.Machine}

def program(+code: Nat, +error: Nat) -> R.CleanupProgram:
  R.CleanupProgram{B.choose(~List<&2, R.CleanupAction>, Nat.is_eq(error, 0n),
    _ => [R.CleanupEmit{code}], _ => [R.CleanupEmit{code}, R.CleanupThrow{R.Reference{error}}]), False{}, 0n}

def flight(code: U32) -> R.Flight:
  match code:
    case 0: R.FlightUndefined{}
    case 1: R.FlightEmpty{}
    case _: R.FlightActive{7n}

def probe(+context: Nat, flags: U32, hasExt: Bool, slot: U32, previous: Bool, +count: Nat, e1: Nat, e2: Nat, e3: Nat, invoke: Bool) -> Probe:
  +w = N.createOwner(B.empty(), 0n, False{})
  +w = N.signal(w, R.Number{0n}, N.defaults())
  +w = N.computed(0n, w, R.Literal{R.Number{1n}}, R.NodeOptions.with_lazy(N.defaults(), True{}), 1n)
  +w = B.store_node(w, 3n, R.Node.with_flags(B.node(w, 3n), flags))
  +w = R.World.with_cleanupPrograms(w, [R.CleanupProgram{[], False{}, 0n}, program(1n, e1), program(2n, e2), program(3n, e3)])
  +w = B.choose(~R.World, hasExt,
    _ =>
      +w = E.ext(w, 3n)
      B.store_extension(w, 3n, R.NodeExtension.with_flightTeardown(R.NodeExtension.with_inFlight(B.extension(w, 3n), flight(slot)), B.choose(~Nat, previous, _ => 1n, _ => 0n))), _ => w)
  +w = R.World.with_context(w, context)
  +w = B.choose(~R.World, Nat.is_ge(count, 1n), _ => S.register(w, 2n), _ => w)
  +w = B.choose(~R.World, Nat.is_ge(count, 2n), _ => S.register(w, 3n), _ => w)
  +cb = R.NodeExtension.flightTeardown(B.extension(w, context))
  Probe{w, B.choose(~C.Machine, Bool.and(invoke, Nat.is_ne(cb, 0n)),
    _ => C.eval(128n, w, R.CallProgram{cb}, R.Undefined{}), _ => C.Machine{w, [], []})}
