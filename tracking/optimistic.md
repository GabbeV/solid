# Public optimistic constructor and bound setter

Solid 5b1b7776 (rc.17). The admitted production expression grammar now executes
createOptimistic's data and function overloads through the same core driver.
The lane read/write/pass/flush dependencies are connected before this admission.
latest/isPending windows, boundaries, stores/folded lanes and ambient mark
release remain unfinished. No semantic deviation is active.

## Source correspondence

Data input calls signal. A callable input, including an admitted first-class
accessor/setter/program/disposer, calls computed; the expression compute form
uses that same constructor. Eager/lazy setup is retained and AUTO_DISPOSE is
cleared only for the function overload, after computed returns. The accessor
is ordinary read.bind(null,node). The setter is optimisticWrite.bind(null,node),
so a write does not replace the original computation as a setMemo call would.

That bound function uses the existing canonical callback arena: one
OptimisticSetter action, arity one, per returned constructor pair. This is
callable representation, not an invented node mode/config bit. It preserves
identity, raw argument invocation, cleanup registration, callable initializer
use, and evaluation of all supplied arguments before ignoring extras. Lexical
bindAs carries the actual setter value through nested closure binding; ordinary
signals retain their existing bind entry. Callback and action-argument binders
capture optimistic scopes with the source shadowing depth.

## Port defect caught by the public crossing

A held async optimistic result exposed a missing entry guard in our async
fast path. Without a custom comparator, it called the restricted World-only
setSignal facade and bypassed the override/lane write hook. Visible truth
finally matched, but an effect applied the old guess an extra time, and node
timestamps/generations differed. The fast path now also requires no override;
covered landings use the existing setResolved/laneWrite continuation. This
matches source asyncWrite -> setSignal and fixes our port, not upstream.

## Evidence and proof limits

64 new public histories compare native constructors and actual callbacks,
source node/ownership fields, setter results/identity/arity, traces, effect
screens, async/action outcomes, errors and ambient restoration. They include
all admitted payload kinds, eager/lazy functions retaining their derivation,
composed queued updaters, nested bindings, cleanup calls, raw comparators,
owner disposal, extra arguments, held flights and action-backed guesses.
Public histories total 3,233. A setup initially tried to read an accessor saved
in a signal before its flush; both engines correctly served the old undefined.
The meaningful saved-accessor scenarios now flush that harness write first.

A complete data optimistic program is independently proved for every natural
initial value, both natural proposed values, and every step budget >=56. It
constructs with equals:false, calls both actual bound setters, flushes without
a held transaction, and reads the authoritative initial value. The theorem
covers the exact final Machine/World/caller stack; a value corollary follows.
It does not prove async/action lane histories or default comparator cases.
16 separate native/canonical controls compare all 56 transitions and exact
final Machines at three sufficient budgets. Generated paths are data; each
step and composition is checked by the unchanged independent kernel.

Opaque run/stack transport lemmas prevent the kernel from expanding a whole
concrete run while checking conversions. Two attempted compositions exhausted
conversion fuel before that refactor; those attempts are not positive evidence.
Runtime semantics, proof domains and sufficient budgets were not weakened.
The existing scalar/memo/history/chain guarantees remain intact.

Eleven new variants bring the cumulative mutation count to 394 (336 finite,
58 proof assertions). A surviving nested-binding mutant exposed a missing
fixture, now covered by optimistic scopes under ordinary bindings. An attempted
mutation of a redundant owner-action arm was unreachable through the public
callback encoding; that arm and variant were removed. Neither is credited.
The 72 composed closed regressions are unchanged; the new program is quantified.
Arbitrary JavaScript functions/protocols and dev/observe behavior remain outside
the admitted grammar. This is incremental public support, not a complete port.
