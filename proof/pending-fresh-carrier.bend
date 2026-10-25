# The actual fresh-node branch constructs its own extension and pending Set.
# Initial valid identity / zero x / reserved auxiliary arenas are representation
# facts, not final carrier or retirement equations.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/extension.bend as E
import ../runtime/pending-state.bend as P
import ./pending-fresh-extension.bend as Ext
import ./extension-laws.bend as Extension
import ./pending-fresh-set.bend as Fresh
import ./pending-carrier-existing.bend as Segment
import ./pending-carrier-roundtrip.bend as RoundTrip
import ./pending-carrier-retirement.bend as Retire
import ./pending-committed-history.bend as Logic


def extended(w: R.World, id: Nat) -> R.World:
  E.ext(w, id)

def nodeRoom(+w: R.World, +id: Nat, valid: {B.valid(w, id) == True{} : Bool}) -> {Nat.is_lt(id, B.length(R.Node, R.World.nodes(w))) == True{} : Bool}:
  Logic.andRight(Nat.is_ne(id, 0n), Nat.is_lt(id, B.length(R.Node, R.World.nodes(w))), valid)

def allocated(+w: R.World, +id: Nat, +extensions: List<&2, R.NodeExtension>,
  valid: {B.valid(w, id) == True{} : Bool}, +empty: {R.Node.x(B.node(w, id)) == 0n : Nat},
  arena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}) ->
  {R.Node.x(B.node(extended(w, id), id)) == 1n+B.length(R.NodeExtension, extensions) : Nat}:
  Equal.trans(Nat, R.Node.x(B.node(extended(w, id), id)), R.Node.x(B.node(Extension.grow(w, id), id)), 1n+B.length(R.NodeExtension, extensions), Equal.cong(R.World, Nat, state => R.Node.x(B.node(state, id)), extended(w, id), Extension.grow(w, id), Ext.exact(w, id, empty)),
    Equal.trans(Nat, R.Node.x(B.node(Extension.grow(w, id), id)), Ext.index(w), 1n+B.length(R.NodeExtension, extensions), Ext.pointer(w, id, nodeRoom(w, id, valid)), Equal.cong(List<&2, R.NodeExtension>, Nat, values => B.length(R.NodeExtension, values), R.World.extensions(w), B.blank_extension() <> extensions, arena)))

def extensionRoom(+w: R.World, +id: Nat, valid: {B.valid(w, id) == True{} : Bool}, empty: {R.Node.x(B.node(w, id)) == 0n : Nat}) ->
  {Nat.is_lt(R.Node.x(B.node(extended(w, id), id)), B.length(R.NodeExtension, R.World.extensions(extended(w, id)))) == True{} : Bool}:
  Equal.trans(Bool, Nat.is_lt(R.Node.x(B.node(extended(w, id), id)), B.length(R.NodeExtension, R.World.extensions(extended(w, id)))), Nat.is_lt(R.Node.x(B.node(Extension.grow(w, id), id)), B.length(R.NodeExtension, R.World.extensions(Extension.grow(w, id)))), True{}, Equal.cong(R.World, Bool, state => Nat.is_lt(R.Node.x(B.node(state, id)), B.length(R.NodeExtension, R.World.extensions(state))), extended(w, id), Extension.grow(w, id), Ext.exact(w, id, empty)), Ext.room(w, id, nodeRoom(w, id, valid)))

def noSources(+w: R.World, +id: Nat, valid: {B.valid(w, id) == True{} : Bool}, empty: {R.Node.x(B.node(w, id)) == 0n : Nat}) ->
  {R.NodeExtension.pendingSources(B.extension(extended(w, id), id)) == 0n : Nat}:
  Equal.trans(Nat, R.NodeExtension.pendingSources(B.extension(extended(w, id), id)), R.NodeExtension.pendingSources(B.extension(Extension.grow(w, id), id)), 0n, Equal.cong(R.World, Nat, state => R.NodeExtension.pendingSources(B.extension(state, id)), extended(w, id), Extension.grow(w, id), Ext.exact(w, id, empty)), Equal.cong(R.NodeExtension, Nat, record => R.NodeExtension.pendingSources(record), B.extension(Extension.grow(w, id), id), B.blank_extension(), Ext.record(w, id, nodeRoom(w, id, valid))))

def setArena(+w: R.World, +id: Nat, +sets: List<&2, List<&2, Nat>>, empty: {R.Node.x(B.node(w, id)) == 0n : Nat}, arena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {R.World.pendingSets(extended(w, id)) == [] <> sets : List<&2, List<&2, Nat>>}:
  Equal.trans(List<&2, List<&2, Nat>>, R.World.pendingSets(extended(w, id)), R.World.pendingSets(Extension.grow(w, id)), [] <> sets, Equal.cong(R.World, List<&2, List<&2, Nat>>, state => R.World.pendingSets(state), extended(w, id), Extension.grow(w, id), Ext.exact(w, id, empty)), Equal.trans(List<&2, List<&2, Nat>>, R.World.pendingSets(Extension.grow(w, id)), R.World.pendingSets(w), [] <> sets, Ext.grownSets(w, id), arena))

def initiallyAbsent(+w: R.World, +id: Nat, +source: Nat, +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>,
  empty: {R.Node.x(B.node(w, id)) == 0n : Nat}, extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}, setsArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {P.hasSource(w, id, source) == False{} : Bool}:
  +record = Extension.readKnown(w, id, 0n, B.blank_extension() <> extensions, empty, extensionArena)
  Fresh.absent(w, id, source, Equal.cong(R.NodeExtension, Nat, value => R.NodeExtension.pendingSources(value), B.extension(w, id), B.blank_extension(), record), Fresh.zero(w, sets, setsArena))

def rawAdd(+w: R.World, +id: Nat, +source: Nat, +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>,
  +valid: {B.valid(w, id) == True{} : Bool}, +empty: {R.Node.x(B.node(w, id)) == 0n : Nat}, extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}, setsArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {P.addPendingSource(w, id, source) == B.Bundle{B.store_pendingSet(Fresh.created(extended(w, id), id), Fresh.index(extended(w, id)), [source]), True{}} : B.Bundle<R.World, Bool>}:
  +next = extended(w, id)
  Equal.trans(B.Bundle<R.World, Bool>, P.addPendingSource(w, id, source), B.choose(~B.Bundle<R.World, Bool>, P.hasSource(w, id, source), _ => B.Bundle{w, False{}}, _ => Segment.addPart(w, id, source)), B.Bundle{B.store_pendingSet(Fresh.created(next, id), Fresh.index(next), [source]), True{}}, Segment.exact(w, id, source),
    Equal.trans(B.Bundle<R.World, Bool>, B.choose(~B.Bundle<R.World, Bool>, P.hasSource(w, id, source), _ => B.Bundle{w, False{}}, _ => Segment.addPart(w, id, source)), Segment.addPart(w, id, source), B.Bundle{B.store_pendingSet(Fresh.created(next, id), Fresh.index(next), [source]), True{}}, Equal.cong(Bool, B.Bundle<R.World, Bool>, flag => B.choose(~B.Bundle<R.World, Bool>, flag, _ => B.Bundle{w, False{}}, _ => Segment.addPart(w, id, source)), P.hasSource(w, id, source), False{}, initiallyAbsent(w, id, source, extensions, sets, empty, extensionArena, setsArena)),
      Equal.trans(B.Bundle<R.World, Bool>, Segment.addPart(w, id, source), Segment.setPart(next, id, source, 0n), B.Bundle{B.store_pendingSet(Fresh.created(next, id), Fresh.index(next), [source]), True{}}, Equal.cong(Nat, B.Bundle<R.World, Bool>, set => Segment.setPart(next, id, source, set), R.NodeExtension.pendingSources(B.extension(next, id)), 0n, noSources(w, id, valid, empty)), Fresh.afterCreated(next, id, source, extensionRoom(w, id, valid, empty)))))

def asExtended(+w: R.World, +id: Nat, +source: Nat, +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>,
  +valid: {B.valid(w, id) == True{} : Bool}, +empty: {R.Node.x(B.node(w, id)) == 0n : Nat}, +extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}, +setsArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {P.addPendingSource(w, id, source) == P.addPendingSource(extended(w, id), id, source) : B.Bundle<R.World, Bool>}:
  +next = extended(w, id)
  +normal = {B.Bundle{B.store_pendingSet(Fresh.created(next, id), Fresh.index(next), [source]), True{}} : B.Bundle<R.World, Bool>}
  Equal.trans(B.Bundle<R.World, Bool>, P.addPendingSource(w, id, source), normal, P.addPendingSource(next, id, source), rawAdd(w, id, source, extensions, sets, valid, empty, extensionArena, setsArena), Equal.sym(B.Bundle<R.World, Bool>, P.addPendingSource(next, id, source), normal, Fresh.add(next, id, source, B.length(R.NodeExtension, extensions), sets, allocated(w, id, extensions, valid, empty, extensionArena), noSources(w, id, valid, empty), extensionRoom(w, id, valid, empty), setArena(w, id, sets, empty, setsArena))))

def contains(+w: R.World, +id: Nat, +source: Nat, +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>,
  +valid: {B.valid(w, id) == True{} : Bool}, +empty: {R.Node.x(B.node(w, id)) == 0n : Nat}, +extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}, +setsArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {P.hasSource(B.first(R.World, Bool, P.addPendingSource(w, id, 1n+source)), id, 1n+source) == True{} : Bool}:
  +next = extended(w, id)
  Equal.trans(Bool, P.hasSource(B.first(R.World, Bool, P.addPendingSource(w, id, 1n+source)), id, 1n+source), P.hasSource(B.first(R.World, Bool, P.addPendingSource(next, id, 1n+source)), id, 1n+source), True{}, Equal.cong(B.Bundle<R.World, Bool>, Bool, pair => P.hasSource(B.first(R.World, Bool, pair), id, 1n+source), P.addPendingSource(w, id, 1n+source), P.addPendingSource(next, id, 1n+source), asExtended(w, id, 1n+source, extensions, sets, valid, empty, extensionArena, setsArena)), Fresh.contains(next, id, source, B.length(R.NodeExtension, extensions), sets, allocated(w, id, extensions, valid, empty, extensionArena), noSources(w, id, valid, empty), extensionRoom(w, id, valid, empty), setArena(w, id, sets, empty, setsArena)))

def retired(+w: R.World, +id: Nat, +source: Nat, +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>,
  +valid: {B.valid(w, id) == True{} : Bool}, +empty: {R.Node.x(B.node(w, id)) == 0n : Nat}, +extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}, +setsArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {P.hasSource(RoundTrip.removed(w, id, 1n+source), id, 1n+source) == False{} : Bool}:
  +next = extended(w, id)
  Equal.trans(Bool, P.hasSource(RoundTrip.removed(w, id, 1n+source), id, 1n+source), P.hasSource(RoundTrip.removed(next, id, 1n+source), id, 1n+source), False{}, Equal.cong(B.Bundle<R.World, Bool>, Bool, pair => P.hasSource(B.first(R.World, Bool, P.removePendingSource(B.first(R.World, Bool, pair), id, 1n+source)), id, 1n+source), P.addPendingSource(w, id, 1n+source), P.addPendingSource(next, id, 1n+source), asExtended(w, id, 1n+source, extensions, sets, valid, empty, extensionArena, setsArena)), RoundTrip.absent(next, id, source, B.length(R.NodeExtension, extensions), sets, allocated(w, id, extensions, valid, empty, extensionArena), noSources(w, id, valid, empty), extensionRoom(w, id, valid, empty), setArena(w, id, sets, empty, setsArena)))


def duplicateAdd(+w: R.World, +id: Nat, +source: Nat, +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>,
  valid: {B.valid(w, id) == True{} : Bool}, empty: {R.Node.x(B.node(w, id)) == 0n : Nat}, extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}, setsArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {P.addPendingSource(RoundTrip.added(w, id, 1n+source), id, 1n+source) == B.Bundle{RoundTrip.added(w, id, 1n+source), False{}} : B.Bundle<R.World, Bool>}:
  Segment.duplicate(RoundTrip.added(w, id, 1n+source), id, 1n+source, contains(w, id, source, extensions, sets, valid, empty, extensionArena, setsArena))

def actualFinal(+w: R.World, +id: Nat, +source: Nat, +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>,
  +valid: {B.valid(w, id) == True{} : Bool}, +empty: {R.Node.x(B.node(w, id)) == 0n : Nat}, +extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}, +setsArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {RoundTrip.removed(w, id, 1n+source) == RoundTrip.finalWorld(extended(w, id), id, 1n+source, sets) : R.World}:
  +next = extended(w, id)
  Equal.trans(R.World, RoundTrip.removed(w, id, 1n+source), RoundTrip.removed(next, id, 1n+source), RoundTrip.finalWorld(next, id, 1n+source, sets), Equal.cong(B.Bundle<R.World, Bool>, R.World, pair => B.first(R.World, Bool, P.removePendingSource(B.first(R.World, Bool, pair), id, 1n+source)), P.addPendingSource(w, id, 1n+source), P.addPendingSource(next, id, 1n+source), asExtended(w, id, 1n+source, extensions, sets, valid, empty, extensionArena, setsArena)), RoundTrip.exact(next, id, source, B.length(R.NodeExtension, extensions), sets, allocated(w, id, extensions, valid, empty, extensionArena), noSources(w, id, valid, empty), extensionRoom(w, id, valid, empty), setArena(w, id, sets, empty, setsArena)))


def retiredPointer(+w: R.World, +id: Nat, +source: Nat, +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>,
  +valid: {B.valid(w, id) == True{} : Bool}, +empty: {R.Node.x(B.node(w, id)) == 0n : Nat}, +extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}, +setsArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {R.NodeExtension.pendingSources(B.extension(RoundTrip.removed(w, id, 1n+source), id)) == 0n : Nat}:
  +next = extended(w, id)
  Equal.trans(Nat, R.NodeExtension.pendingSources(B.extension(RoundTrip.removed(w, id, 1n+source), id)), R.NodeExtension.pendingSources(B.extension(RoundTrip.finalWorld(next, id, 1n+source, sets), id)), 0n, Equal.cong(R.World, Nat, state => R.NodeExtension.pendingSources(B.extension(state, id)), RoundTrip.removed(w, id, 1n+source), RoundTrip.finalWorld(next, id, 1n+source, sets), actualFinal(w, id, source, extensions, sets, valid, empty, extensionArena, setsArena)), Retire.pointer(Fresh.canonical(next, id, 1n+source, sets), id, B.length(List<&2, Nat>, sets), Fresh.canonicalExtRoom(next, id, 1n+source, sets, extensionRoom(w, id, valid, empty))))

def duplicateRemove(+w: R.World, +id: Nat, +source: Nat, +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>,
  valid: {B.valid(w, id) == True{} : Bool}, empty: {R.Node.x(B.node(w, id)) == 0n : Nat}, extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}, setsArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {P.removePendingSource(RoundTrip.removed(w, id, 1n+source), id, 1n+source) == B.Bundle{RoundTrip.removed(w, id, 1n+source), False{}} : B.Bundle<R.World, Bool>}:
  Retire.duplicate(RoundTrip.removed(w, id, 1n+source), id, 1n+source, retired(w, id, source, extensions, sets, valid, empty, extensionArena, setsArena))
