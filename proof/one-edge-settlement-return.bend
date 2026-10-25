# Construct a bounded return of the actual after-trim/settlement/schedule tail
# from a one-edge graph's input facts. No helper output, shape equation or
# successful transaction-resolution outcome is an input premise.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/pending.bend as Q
import ../runtime/pending-state.bend as P
import ../runtime/constants.bend as K
import ./owner-continuation.bend as Owner
import ./pending-removal-footprint.bend as Removal
import ./pending-stack-history.bend as Steps
import ./core-run-prefix.bend as Driver
import ./one-edge-visit-return.bend as Visit
import ./bounded-core-return.bend as Return
import ./bounded-return-frame.bend as FramedReturn
import ./committed-storage-frame.bend as Frame
import ./pending-source-committed-frame.bend as SourceFrame
import ../runtime/owner.bend as O

def after(w: R.World, +root: Nat) -> R.World:
  B.first(R.World, Bool, P.removePendingSource(w, root, root))

def start(w: R.World, root: Nat, rest: List<&2, C.Task>, stack: List<&2, R.Value>) -> C.Machine:
  C.Machine{w, C.AsyncWriteAfterTrim{root} <> C.AsyncWriteSchedule{} <> rest, stack}

def walking(w: R.World, edge: Nat, +root: Nat, rest: List<&2, C.Task>, stack: List<&2, R.Value>) -> C.Machine:
  C.Machine{w, C.PendingTasks{[Q.Walk{edge, root, root}, Q.Release{0n}, Q.End{}], [], [], False{}} <> C.AsyncWriteSchedule{} <> rest, stack}

def rootLink(+w: R.World, +root: Nat, +edge: Nat) -> {B.link(after(w, root), edge) == B.link(w, edge) : R.Link}:
  Equal.cong(Removal.View, R.Link, view => B.get(R.Link, Removal.links(view), edge, B.blank_link()), Removal.observe(after(w, root)), Removal.observe(w), Removal.removed(w, root, root))

def afterHealthy(+w: R.World, +root: Nat, healthy: {B.ok(w) == True{} : Bool}) -> {B.ok(after(w, root)) == True{} : Bool}:
  Equal.trans(Bool, B.ok(after(w, root)), B.ok(w), True{}, Removal.health(w, root, root), healthy)

def begins(+w: R.World, +edge: Nat, +root: Nat, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, healthy: {B.ok(w) == True{} : Bool}, head: {R.Node.subs(B.node(w, root)) == 1n+edge : Nat}) ->
  {C.step(start(w, root, rest, stack)) == walking(after(w, root), 1n+edge, root, rest, stack) : C.Machine}:
  +next = after(w, root)
  +headAfter = Equal.trans(Nat, R.Node.subs(B.node(next, root)), R.Node.subs(B.node(w, root)), 1n+edge, Equal.cong(R.Node, Nat, node => R.Node.subs(node), B.node(next, root), B.node(w, root), Removal.node(w, root, root, root)), head)
  Equal.trans(C.Machine, C.step(start(w, root, rest, stack)), C.dispatch(w, C.AsyncWriteAfterTrim{root} <> C.AsyncWriteSchedule{} <> rest, stack), walking(next, 1n+edge, root, rest, stack), Owner.healthyStep(w, C.AsyncWriteAfterTrim{root}, C.AsyncWriteSchedule{} <> rest, stack, healthy),
    Equal.cong(Nat, C.Machine, first => walking(next, first, root, rest, stack), R.Node.subs(B.node(next, root)), 1n+edge, headAfter))

def walks(+w: R.World, +edge: Nat, +root: Nat, +id: Nat, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, healthy: {B.ok(w) == True{} : Bool}, selected: {R.Link.sub(B.link(w, 1n+edge)) == id : Nat}) ->
  {C.step(walking(w, 1n+edge, root, rest, stack)) == Visit.input(w, 1n+edge, root, id, rest, stack) : C.Machine}:
  Equal.trans(C.Machine, C.step(walking(w, 1n+edge, root, rest, stack)), C.dispatch(w, C.PendingTasks{[Q.Walk{1n+edge, root, root}, Q.Release{0n}, Q.End{}], [], [], False{}} <> C.AsyncWriteSchedule{} <> rest, stack), Visit.input(w, 1n+edge, root, id, rest, stack), Owner.healthyStep(w, C.PendingTasks{[Q.Walk{1n+edge, root, root}, Q.Release{0n}, Q.End{}], [], [], False{}}, C.AsyncWriteSchedule{} <> rest, stack, healthy),
    Equal.cong(Nat, C.Machine, leaf => Visit.input(w, 1n+edge, root, leaf, rest, stack), R.Link.sub(B.link(w, 1n+edge)), id, selected))

def prefix(+w: R.World, +edge: Nat, +root: Nat, +id: Nat, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +healthy: {B.ok(w) == True{} : Bool}, head: {R.Node.subs(B.node(w, root)) == 1n+edge : Nat}, selected: {R.Link.sub(B.link(w, 1n+edge)) == id : Nat}) ->
  {Steps.iterate(2n, start(w, root, rest, stack)) == Visit.input(after(w, root), 1n+edge, root, id, rest, stack) : C.Machine}:
  +next = after(w, root)
  +selectedAfter = Equal.trans(Nat, R.Link.sub(B.link(next, 1n+edge)), R.Link.sub(B.link(w, 1n+edge)), id, Equal.cong(R.Link, Nat, link => R.Link.sub(link), B.link(next, 1n+edge), B.link(w, 1n+edge), rootLink(w, root, 1n+edge)), selected)
  Driver.appendStep(1n, start(w, root, rest, stack), walking(next, 1n+edge, root, rest, stack), Visit.input(next, 1n+edge, root, id, rest, stack), begins(w, edge, root, rest, stack, healthy, head), walks(next, edge, root, id, rest, stack, afterHealthy(w, root, healthy), selectedAfter))

def complete(+w: R.World, +edge: Nat, +root: Nat, +id: Nat, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +healthy: {B.ok(w) == True{} : Bool}, head: {R.Node.subs(B.node(w, root)) == 1n+edge : Nat}, selected: {R.Link.sub(B.link(w, 1n+edge)) == id : Nat}, end: {R.Link.nextSub(B.link(w, 1n+edge)) == 0n : Nat}, noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}, noAuto: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}) ->
  Return.Returned<start(w, root, rest, stack), rest, stack, 10n>:
  +next = after(w, root)
  +leaf = Removal.node(w, root, root, id)
  +subscribers = Equal.trans(Nat, R.Node.subs(B.node(next, id)), R.Node.subs(B.node(w, id)), 0n, Equal.cong(R.Node, Nat, node => R.Node.subs(node), B.node(next, id), B.node(w, id), leaf), noSubscribers)
  +automatic = Equal.trans(Bool, B.has(R.Node.config(B.node(next, id)), K.CONFIG_AUTO_DISPOSE()), B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()), False{}, Equal.cong(R.Node, Bool, node => B.has(R.Node.config(node), K.CONFIG_AUTO_DISPOSE()), B.node(next, id), B.node(w, id), leaf), noAuto)
  +ending = Equal.trans(Nat, R.Link.nextSub(B.link(next, 1n+edge)), R.Link.nextSub(B.link(w, 1n+edge)), 0n, Equal.cong(R.Link, Nat, link => R.Link.nextSub(link), B.link(next, 1n+edge), B.link(w, 1n+edge), rootLink(w, root, 1n+edge)), end)
  Return.prepend(start(w, root, rest, stack), Visit.input(next, 1n+edge, root, id, rest, stack), rest, stack, 2n, 8n, prefix(w, edge, root, id, rest, stack, healthy, head, selected), Visit.complete(next, 1n+edge, root, id, rest, stack, afterHealthy(w, root, healthy), ending, subscribers, automatic))


def frame(+w: R.World, +edge: Nat, +root: Nat, +id: Nat, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +healthy: {B.ok(w) == True{} : Bool}, +head: {R.Node.subs(B.node(w, root)) == 1n+edge : Nat}, +selected: {R.Link.sub(B.link(w, 1n+edge)) == id : Nat}, +end: {R.Link.nextSub(B.link(w, 1n+edge)) == 0n : Nat}, +noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}, +noAuto: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}) ->
  {Frame.observe(Return.world(start(w, root, rest, stack), rest, stack, 10n, complete(w, edge, root, id, rest, stack, healthy, head, selected, end, noSubscribers, noAuto))) == Frame.observe(w) : Frame.View}:
  +next = after(w, root)
  +leaf = Removal.node(w, root, root, id)
  +subscribers = Equal.trans(Nat, R.Node.subs(B.node(next, id)), R.Node.subs(B.node(w, id)), 0n, Equal.cong(R.Node, Nat, node => R.Node.subs(node), B.node(next, id), B.node(w, id), leaf), noSubscribers)
  +automatic = Equal.trans(Bool, B.has(R.Node.config(B.node(next, id)), K.CONFIG_AUTO_DISPOSE()), B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()), False{}, Equal.cong(R.Node, Bool, node => B.has(R.Node.config(node), K.CONFIG_AUTO_DISPOSE()), B.node(next, id), B.node(w, id), leaf), noAuto)
  +ending = Equal.trans(Nat, R.Link.nextSub(B.link(next, 1n+edge)), R.Link.nextSub(B.link(w, 1n+edge)), 0n, Equal.cong(R.Link, Nat, link => R.Link.nextSub(link), B.link(next, 1n+edge), B.link(w, 1n+edge), rootLink(w, root, 1n+edge)), end)
  FramedReturn.prepend(start(w, root, rest, stack), Visit.input(next, 1n+edge, root, id, rest, stack), rest, stack, 2n, 8n, prefix(w, edge, root, id, rest, stack, healthy, head, selected), Visit.complete(next, 1n+edge, root, id, rest, stack, afterHealthy(w, root, healthy), ending, subscribers, automatic), SourceFrame.remove(w, root, root), Visit.frame(next, 1n+edge, root, id, rest, stack, afterHealthy(w, root, healthy), ending, subscribers, automatic))


def trimmed(w: R.World, +root: Nat, rest: List<&2, C.Task>, stack: List<&2, R.Value>) -> C.Machine:
  C.Machine{w, C.OwnerTasks{[O.TrimDeps{root}]} <> C.AsyncWriteAfterTrim{root} <> C.AsyncWriteSchedule{} <> rest, stack}

def completeTrimmed(+w: R.World, +edge: Nat, +root: Nat, +id: Nat, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +healthy: {B.ok(w) == True{} : Bool}, head: {R.Node.subs(B.node(w, root)) == 1n+edge : Nat}, selected: {R.Link.sub(B.link(w, 1n+edge)) == id : Nat}, end: {R.Link.nextSub(B.link(w, 1n+edge)) == 0n : Nat}, noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}, noAuto: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}, noStale: {Owner.staleEdge(w, root) == 0n : Nat}) ->
  Return.Returned<trimmed(w, root, rest, stack), rest, stack, 12n>:
  Return.prepend(trimmed(w, root, rest, stack), start(w, root, rest, stack), rest, stack, 2n, 10n, Owner.trimComplete(w, C.AsyncWriteAfterTrim{root} <> C.AsyncWriteSchedule{} <> rest, stack, root, noStale, healthy), complete(w, edge, root, id, rest, stack, healthy, head, selected, end, noSubscribers, noAuto))
