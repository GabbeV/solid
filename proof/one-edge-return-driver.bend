# Concrete driver/bound corollaries use the constructed one-edge certificate,
# never a caller-supplied final-machine or successful-driver equation.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/constants.bend as K
import ./one-edge-settlement-return.bend as Edge
import ./bounded-core-return.bend as Return

def driver(+w: R.World, +edge: Nat, +root: Nat, +id: Nat, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +healthy: {B.ok(w) == True{} : Bool}, +head: {R.Node.subs(B.node(w, root)) == 1n+edge : Nat}, +selected: {R.Link.sub(B.link(w, 1n+edge)) == id : Nat}, +end: {R.Link.nextSub(B.link(w, 1n+edge)) == 0n : Nat}, +noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}, +noAuto: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}, +remaining: Nat) ->
  {C.run(Nat.add(Return.steps(Edge.start(w, root, rest, stack), rest, stack, 10n, Edge.complete(w, edge, root, id, rest, stack, healthy, head, selected, end, noSubscribers, noAuto)), remaining), Edge.start(w, root, rest, stack)) == C.run(remaining, C.Machine{Return.world(Edge.start(w, root, rest, stack), rest, stack, 10n, Edge.complete(w, edge, root, id, rest, stack, healthy, head, selected, end, noSubscribers, noAuto)), rest, stack}) : C.Machine}:
  Return.driver(Edge.start(w, root, rest, stack), rest, stack, 10n, Edge.complete(w, edge, root, id, rest, stack, healthy, head, selected, end, noSubscribers, noAuto), remaining)

def room(+w: R.World, +edge: Nat, +root: Nat, +id: Nat, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +healthy: {B.ok(w) == True{} : Bool}, +head: {R.Node.subs(B.node(w, root)) == 1n+edge : Nat}, +selected: {R.Link.sub(B.link(w, 1n+edge)) == id : Nat}, +end: {R.Link.nextSub(B.link(w, 1n+edge)) == 0n : Nat}, +noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}, +noAuto: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}) ->
  {Nat.add(Return.steps(Edge.start(w, root, rest, stack), rest, stack, 10n, Edge.complete(w, edge, root, id, rest, stack, healthy, head, selected, end, noSubscribers, noAuto)), Return.slack(Edge.start(w, root, rest, stack), rest, stack, 10n, Edge.complete(w, edge, root, id, rest, stack, healthy, head, selected, end, noSubscribers, noAuto))) == 10n : Nat}:
  Return.bounded(Edge.start(w, root, rest, stack), rest, stack, 10n, Edge.complete(w, edge, root, id, rest, stack, healthy, head, selected, end, noSubscribers, noAuto))
