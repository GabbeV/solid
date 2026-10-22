# Exact source call/return boundaries in the active common driver. Guards are
# actual source branch predicates, not assumptions about a desired outcome.
import Base
import ../runtime/lanes-state.bend as L
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/equality.bend as E
import ../runtime/constants.bend as K

def rawSelected(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +a: R.Value, +b: R.Value, custom: Bool) -> C.Machine:
  B.choose(~C.Machine, custom,
    _ => C.Machine{w, rest, R.Boolean{E.isSame(w, id, a, b)} <> stack},
    _ => C.Machine{w, C.Evaluate{R.CallWith{E.custom(w, id), R.Literal{a}, R.Literal{b}}, R.Undefined{}} <> rest, stack})

def rawCustom(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +a: R.Value, +b: R.Value,
  known: {Nat.is_eq(E.custom(w, id), 0n) == False{} : Bool}) ->
  {C.rawEquals(w, rest, stack, id, a, b) == C.Machine{w, C.Evaluate{R.CallWith{E.custom(w, id), R.Literal{a}, R.Literal{b}}, R.Undefined{}} <> rest, stack} : C.Machine}:
  Equal.cong(Bool, C.Machine, flag => rawSelected(w, rest, stack, id, a, b, flag), Nat.is_eq(E.custom(w, id), 0n), False{}, known)

# A truth check on a plain node with no staging answers 1 and leaves every
# World field/caller operand untouched. No tree termination claim is inferred.
def truthBranch(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, guess: Bool, staged: Bool, over: Bool) -> C.Machine:
  B.choose(~C.Machine, guess,
    _ => B.choose(~C.Machine, Bool.and(B.present(R.Node.pending(B.node(w, id))), R.Node.equals(B.node(w, id))),
      _ => C.rawEquals(w, rest, stack, id, B.selected(R.NodeExtension.lane(B.extension(w, id)), R.NotPendingToken{}), B.selected(R.Node.pending(B.node(w, id)), R.NotPendingToken{})),
      _ => C.Machine{w, rest, R.Boolean{False{}} <> stack}),
    _ => B.choose(~C.Machine, staged, _ => C.Machine{w, rest, R.Undefined{} <> stack},
      _ => B.choose(~C.Machine, over, _ => C.Machine{w, C.TruthDeps{R.Node.deps(B.node(w, id))} <> rest, stack}, _ => C.Machine{w, rest, R.Number{1n} <> stack})))

def plainTruth(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat,
  g: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_GUESS()) == False{} : Bool},
  p: {B.present(R.Node.pending(B.node(w, id))) == False{} : Bool},
  o: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()) == False{} : Bool}) ->
  {C.truthNode(w, rest, stack, id) == C.Machine{w, rest, R.Number{1n} <> stack} : C.Machine}:
  +guess = B.has(R.Node.config(B.node(w, id)), K.CONFIG_GUESS())
  +pending = B.present(R.Node.pending(B.node(w, id)))
  +over = B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE())
  Equal.trans(C.Machine, truthBranch(w, rest, stack, id, guess, pending, over), truthBranch(w, rest, stack, id, False{}, pending, over), C.Machine{w, rest, R.Number{1n} <> stack},
    Equal.cong(Bool, C.Machine, flag => truthBranch(w, rest, stack, id, flag, pending, over), guess, False{}, g),
    Equal.trans(C.Machine, truthBranch(w, rest, stack, id, False{}, pending, over), truthBranch(w, rest, stack, id, False{}, False{}, over), C.Machine{w, rest, R.Number{1n} <> stack},
      Equal.cong(Bool, C.Machine, flag => truthBranch(w, rest, stack, id, False{}, flag, over), pending, False{}, p),
      Equal.cong(Bool, C.Machine, flag => truthBranch(w, rest, stack, id, False{}, False{}, flag), over, False{}, o)))

# The pending source's absence of value is an actual fall-through token; it
# does not become a fabricated committed/undefined result.
def pendingLanePass(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +reader: Nat, +id: Nat, +lane: Nat) ->
  {C.laneReadEnter(w, rest, stack, reader, id, lane, False{}, K.STATUS_PENDING())
    == C.Machine{L.enterLane(w, lane, reader), rest, R.NotPendingToken{} <> stack} : C.Machine}:
  {==}
