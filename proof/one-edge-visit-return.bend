# Bounded actual return from a one-edge traversal's visitor. Both possible
# source queue shapes are constructed by Control.visit; no output World/health
# or transition result is a premise.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/pending.bend as Q
import ../runtime/constants.bend as K
import ./subscriber-topology-frame.bend as Topology
import ./core-pending-topology.bend as Graph
import ./pending-machine-shape.bend as Fields
import ./pending-visit-control.bend as Control
import ./core-visit-control.bend as Core
import ./pending-leaf-return.bend as Suffix
import ./bounded-core-return.bend as Return
import ./bounded-return-frame.bend as FramedReturn
import ./committed-storage-frame.bend as Frame
import ./core-pending-frame.bend as CoreFrame

def tail(+edge: Nat, +root: Nat) -> List<&2, Q.Task>:
  [Q.Next{edge, root, root}, Q.Release{0n}, Q.End{}]

def outcome(w: R.World, edge: Nat, +root: Nat, id: Nat) -> Q.Machine:
  Q.advance(w, Q.Visit{id, root, root} <> tail(edge, root), [], [], False{})

def input(w: R.World, edge: Nat, +root: Nat, id: Nat, rest: List<&2, C.Task>, stack: List<&2, R.Value>) -> C.Machine:
  Core.input(w, tail(edge, root), [], [], False{}, id, root, root, C.AsyncWriteSchedule{} <> rest, stack)

def actual(w: R.World, edge: Nat, root: Nat, id: Nat, rest: List<&2, C.Task>, stack: List<&2, R.Value>) -> C.Machine:
  C.step(input(w, edge, root, id, rest, stack))

def afterWorld(w: R.World, edge: Nat, root: Nat, id: Nat, rest: List<&2, C.Task>, stack: List<&2, R.Value>) -> R.World:
  C.world(actual(w, edge, root, id, rest, stack))

def retainedEnd(+w: R.World, +edge: Nat, +root: Nat, +id: Nat, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, end: {R.Link.nextSub(B.link(w, edge)) == 0n : Nat}) ->
  {R.Link.nextSub(B.link(afterWorld(w, edge, root, id, rest, stack), edge)) == 0n : Nat}:
  +same = Equal.cong(Topology.View, R.Link, view => B.get(R.Link, Topology.edges(view), edge, B.blank_link()), Topology.observe(afterWorld(w, edge, root, id, rest, stack)), Topology.observe(w),
    Graph.step(w, C.AsyncWriteSchedule{} <> rest, stack, Q.Visit{id, root, root} <> tail(edge, root), [], [], False{}))
  Equal.trans(Nat, R.Link.nextSub(B.link(afterWorld(w, edge, root, id, rest, stack), edge)), R.Link.nextSub(B.link(w, edge)), 0n,
    Equal.cong(R.Link, Nat, link => R.Link.nextSub(link), B.link(afterWorld(w, edge, root, id, rest, stack), edge), B.link(w, edge), same), end)

def fromControl(+w: R.World, +edge: Nat, +root: Nat, +id: Nat, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +healthy: {B.ok(w) == True{} : Bool}, +end: {R.Link.nextSub(B.link(w, edge)) == 0n : Nat},
  control: Control.Next<Control.observe(outcome(w, edge, root, id)), tail(edge, root), [], root, root>) ->
  Return.Returned<input(w, edge, root, id, rest, stack), rest, stack, 8n>:
  match control:
    case Control.Direct{shape}:
      +result = outcome(w, edge, root, id)
      +nextWorld = afterWorld(w, edge, root, id, rest, stack)
      +visits = Fields.visits(result)
      +scheduled = Fields.scheduled(result)
      +lastEdge = retainedEnd(w, edge, root, id, rest, stack, end)
      +middle = Suffix.next(nextWorld, edge, root, visits, scheduled, rest, stack)
      +prefix = Core.normalized(w, C.AsyncWriteSchedule{} <> rest, stack, tail(edge, root), [], [], False{}, id, root, root, tail(edge, root), [], healthy, shape)
      Return.prepend(input(w, edge, root, id, rest, stack), middle, rest, stack, 1n, 7n, prefix, Suffix.completeNext(nextWorld, edge, root, visits, scheduled, rest, stack, lastEdge))
    case Control.Leaf{shape}:
      +result = outcome(w, edge, root, id)
      +nextWorld = afterWorld(w, edge, root, id, rest, stack)
      +visits = Fields.visits(result)
      +scheduled = Fields.scheduled(result)
      +lastEdge = retainedEnd(w, edge, root, id, rest, stack, end)
      +middle = Suffix.start(nextWorld, edge, root, visits, scheduled, rest, stack)
      +prefix = Core.normalized(w, C.AsyncWriteSchedule{} <> rest, stack, tail(edge, root), [], [], False{}, id, root, root, Q.Walk{0n, root, root} <> tail(edge, root), [], healthy, shape)
      Return.prepend(input(w, edge, root, id, rest, stack), middle, rest, stack, 1n, 7n, prefix, Suffix.complete(nextWorld, edge, root, visits, scheduled, rest, stack, lastEdge))

def complete(+w: R.World, +edge: Nat, +root: Nat, +id: Nat, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, healthy: {B.ok(w) == True{} : Bool}, end: {R.Link.nextSub(B.link(w, edge)) == 0n : Nat}, noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}, noAuto: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}) ->
  Return.Returned<input(w, edge, root, id, rest, stack), rest, stack, 8n>:
  fromControl(w, edge, root, id, rest, stack, healthy, end, Control.visit(w, tail(edge, root), [], [], False{}, id, root, root, noSubscribers, noAuto))


def fromControlFrame(+w: R.World, +edge: Nat, +root: Nat, +id: Nat, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +healthy: {B.ok(w) == True{} : Bool}, +end: {R.Link.nextSub(B.link(w, edge)) == 0n : Nat},
  +control: Control.Next<Control.observe(outcome(w, edge, root, id)), tail(edge, root), [], root, root>) ->
  {Frame.observe(Return.world(input(w, edge, root, id, rest, stack), rest, stack, 8n, fromControl(w, edge, root, id, rest, stack, healthy, end, control))) == Frame.observe(w) : Frame.View}:
  match control:
    case Control.Direct{shape}:
      +result = outcome(w, edge, root, id)
      +nextWorld = afterWorld(w, edge, root, id, rest, stack)
      +visits = Fields.visits(result)
      +scheduled = Fields.scheduled(result)
      +lastEdge = retainedEnd(w, edge, root, id, rest, stack, end)
      +middle = Suffix.next(nextWorld, edge, root, visits, scheduled, rest, stack)
      +prefix = Core.normalized(w, C.AsyncWriteSchedule{} <> rest, stack, tail(edge, root), [], [], False{}, id, root, root, tail(edge, root), [], healthy, shape)
      FramedReturn.prepend(input(w, edge, root, id, rest, stack), middle, rest, stack, 1n, 7n, prefix, Suffix.completeNext(nextWorld, edge, root, visits, scheduled, rest, stack, lastEdge), CoreFrame.step(w, C.AsyncWriteSchedule{} <> rest, stack, Q.Visit{id, root, root} <> tail(edge, root), [], [], False{}), Suffix.completeNextFrame(nextWorld, edge, root, visits, scheduled, rest, stack, lastEdge))
    case Control.Leaf{shape}:
      +result = outcome(w, edge, root, id)
      +nextWorld = afterWorld(w, edge, root, id, rest, stack)
      +visits = Fields.visits(result)
      +scheduled = Fields.scheduled(result)
      +lastEdge = retainedEnd(w, edge, root, id, rest, stack, end)
      +middle = Suffix.start(nextWorld, edge, root, visits, scheduled, rest, stack)
      +prefix = Core.normalized(w, C.AsyncWriteSchedule{} <> rest, stack, tail(edge, root), [], [], False{}, id, root, root, Q.Walk{0n, root, root} <> tail(edge, root), [], healthy, shape)
      FramedReturn.prepend(input(w, edge, root, id, rest, stack), middle, rest, stack, 1n, 7n, prefix, Suffix.complete(nextWorld, edge, root, visits, scheduled, rest, stack, lastEdge), CoreFrame.step(w, C.AsyncWriteSchedule{} <> rest, stack, Q.Visit{id, root, root} <> tail(edge, root), [], [], False{}), Suffix.completeFrame(nextWorld, edge, root, visits, scheduled, rest, stack, lastEdge))


def frame(+w: R.World, +edge: Nat, +root: Nat, +id: Nat, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +healthy: {B.ok(w) == True{} : Bool}, +end: {R.Link.nextSub(B.link(w, edge)) == 0n : Nat}, noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}, noAuto: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}) ->
  {Frame.observe(Return.world(input(w, edge, root, id, rest, stack), rest, stack, 8n, complete(w, edge, root, id, rest, stack, healthy, end, noSubscribers, noAuto))) == Frame.observe(w) : Frame.View}:
  fromControlFrame(w, edge, root, id, rest, stack, healthy, end, Control.visit(w, tail(edge, root), [], [], False{}, id, root, root, noSubscribers, noAuto))
