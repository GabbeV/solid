# A compositional execution lemma, checked once for arbitrary states. Keeping
# the run opaque at concrete call sites prevents exponential kernel expansion.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/api.bend as A
import ./chain.bend as Chain

type Path<-start: C.Machine, -end: C.Machine> is Data:
  PathEnd{world: R.World, stack: List<&2, R.Value>, atStart: {start == C.Machine{world, [], stack} : C.Machine}, atEnd: {end == C.Machine{world, [], stack} : C.Machine}}
  PathStep{next: C.Machine, transition: {C.step(start) == next : C.Machine}, rest: Path<next, end>}

def length(-start: C.Machine, -end: C.Machine, path: Path<start, end>) -> Nat:
  match path:
    case PathEnd{w, stack, atStart, atEnd}:
      0n
    case PathStep{next, transition, rest}:
      1n+length(next, end, rest)

def idle_run(fuel: Nat, +w: R.World, +stack: List<&2, R.Value>) ->
  {C.run(fuel, C.Machine{w, [], stack}) == C.Machine{w, [], stack} : C.Machine}:
  match fuel:
    case 0n:
      {==}
    case 1n+p:
      {==}

def run_step(+fuel: Nat, m: C.Machine) ->
  {C.run(1n+fuel, m) == C.run(fuel, C.step(m)) : C.Machine}:
  match m:
    case C.Machine{+w, tasks, +stack}:
      match tasks:
        case Nil{}:
          Equal.sym(C.Machine, C.run(fuel, C.Machine{w, [], stack}), C.Machine{w, [], stack}, idle_run(fuel, w, stack))
        case h <> t:
          {==}

def realizes(-s: C.Machine, -end: C.Machine, path: Path<s, end>,
  +extra: Nat, +start: C.Machine, connected: {start == s : C.Machine}) ->
  {C.run(Nat.add(length(s, end, path), extra), start) == end : C.Machine}:
  match path:
    case PathEnd{+w, +stack, atStart, atEnd}:
      %Equal.sym(C.Machine, start, C.Machine{w, [], stack}, Equal.trans(C.Machine, start, s, C.Machine{w, [], stack}, connected, atStart)) : {C.run(extra, _) == end : C.Machine}
      Equal.trans(C.Machine, C.run(extra, C.Machine{w, [], stack}), C.Machine{w, [], stack}, end,
        idle_run(extra, w, stack), Equal.sym(C.Machine, end, C.Machine{w, [], stack}, atEnd))
    case PathStep{+next, transition, +rest}:
      %Equal.sym(C.Machine, C.run(1n+Nat.add(length(next, end, rest), extra), start), C.run(Nat.add(length(next, end, rest), extra), C.step(start)), run_step(Nat.add(length(next, end, rest), extra), start)) : {_ == end : C.Machine}
      %Equal.sym(C.Machine, C.step(start), next, Equal.trans(C.Machine, C.step(start), C.step(s), next,
        Equal.cong(C.Machine, C.Machine, m => C.step(m), start, s, connected), transition)) : {C.run(Nat.add(length(next, end, rest), extra), _) == end : C.Machine}
      realizes(next, end, rest, extra, next, {==})

def flush_eq(+fuel: Nat, +w: R.World,
  guard: {Bool.or(R.World.halted(w), Bool.or(R.World.running(w), Bool.not(R.World.scheduled(w)))) == False{} : Bool}) ->
  {C.flush(fuel, w) == C.world(C.run(fuel, C.Machine{w, [C.Round{}], []})) : R.World}:
  %Equal.sym(Bool, Bool.or(R.World.halted(w), Bool.or(R.World.running(w), Bool.not(R.World.scheduled(w)))), False{}, guard) : {B.choose(~R.World, _, _ => w, _ => C.world(C.run(fuel, C.Machine{w, [C.Round{}], []}))) == C.world(C.run(fuel, C.Machine{w, [C.Round{}], []})) : R.World}
  {==}

def fuel_transport(-a: Nat, -b: Nat, -m: C.Machine, e: {a == b : Nat}) ->
  {C.run(a, m) == C.run(b, m) : C.Machine}:
  %e : {C.run(a, m) == C.run(_, m) : C.Machine}
  {==}

def world_transport(-a: C.Machine, -b: C.Machine, e: {a == b : C.Machine}) ->
  {C.world(a) == C.world(b) : R.World}:
  %e : {C.world(a) == C.world(_) : R.World}
  {==}

def driver_transport(-a: C.Machine, -b: C.Machine, e: {a == b : C.Machine}) ->
  {C.world(C.run(256n, a)) == C.world(C.run(256n, b)) : R.World}:
  %e : {C.world(C.run(256n, a)) == C.world(C.run(256n, _)) : R.World}
  {==}

def flush_transport(-a: R.World, -b: R.World, e: {a == b : R.World}) ->
  {A.flush(256n, a) == A.flush(256n, b) : R.World}:
  %e : {A.flush(256n, a) == A.flush(256n, _) : R.World}
  {==}

def write_transport(-a: R.World, -b: R.World, -x: Nat, e: {a == b : R.World}) ->
  {A.flush(256n, A.setSignal(a, 2n, R.Number{x})) == A.flush(256n, A.setSignal(b, 2n, R.Number{x})) : R.World}:
  %e : {A.flush(256n, A.setSignal(a, 2n, R.Number{x})) == A.flush(256n, A.setSignal(_, 2n, R.Number{x})) : R.World}
  {==}

def observe_transport(-a: R.World, -b: R.World, e: {a == b : R.World}) ->
  {Chain.view(a) == Chain.view(b) : Chain.View}:
  %e : {Chain.view(a) == Chain.view(_) : Chain.View}
  {==}
