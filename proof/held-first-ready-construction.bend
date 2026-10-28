# Real raw graph/create/open/hold constructs every first-controller input fact.
import Base
import ../representation/records.bend as R
import ./ordinary-graph-data.bend as Graph
import ./held-opened-state.bend as State
import ./held-opened-arena.bend as Arena
import ./held-first-controller-fields.bend as Fields
import ./held-opened-profile.bend as Profile
import ./held-opened-facts.bend as Facts
import ./held-first-ready.bend as Ready

def constructed(+value: R.Value,+methods: R.Expr) -> Ready.Ready<State.opened(value,methods),Graph.source(value),methods>:
  Ready.Constructed{Arena.arena(value,methods),Fields.actions(value,methods),Profile.profile(value,methods),Fields.cached(value,methods),Facts.empty(value,methods)}
