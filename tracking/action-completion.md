# Both joined action completions and settled-yield preservation

This extends checkpoint `79165015c2d8440a710ae9cdc4bfb4e6f37ba198`. The runtime,
representation, host, vendored source, source pin and kernel limits are unchanged.
No semantic deviation is active.

## What is checked

`transaction-count-pair.bend` describes the actual allocated pair after its one
initial distinct join. The source retains its original open count and redirects
to the target; the target holds the current count. A count write and the actual
source `schedule` preserve that shape, both original routes, action cells,
live-list state and the entire surrounding World. The public resolver bound comes
from the allocated arena structure, including after the first completion. The
proof does not merge or remove the retired source again.

`action-pair-completion.bend` starts with **two actual `Action.create` / `open`
prefixes** and the actual distinct join, in either direction. It admits either
completion order, with an arbitrary finite list of original-ID lookups and
same-component rejoins before the first completion, between the completions and
after the second. Each list may branch independently between those operations.
Both real `done` prefixes charge the current representative. The resulting group
has zero action debt; its old redirected source still has the stale count one.
Summing every arena record would therefore be the wrong live-debt observation.

The constructed theorem supplies every allocated-slot, captured-ID, count and
resolver-budget premise. Callback expressions are arbitrary unexecuted data;
factory success and terminating admitted body slices remain the domain. This
is not a theorem that an arbitrary factory/generator body terminates.

The full result is an indexed `Completion` certificate containing the **complete
World equality**: actual allocation/opening, one distinct join, the selected
history, both actual completion prefixes and both source scheduling effects.
`equation` extracts that equality and `zeroCertified` proves its zero-debt
corollary for any such certificate. `constructed` constructs the certificate
without an input certificate or supplied transition equation. This packaging
avoids repeatedly unfolding the nested constructors inside a large equality;
the independent pinned kernel checks its field and construction. A directly
unfolded convenience theorem exceeded kernel fuel and is not an active claim.
No checker limit or runtime behavior was changed to accommodate it.

`action-wait-settlement.bend` separately proves a source callback invariant over
arbitrary finite wait lists. Actual `settleWait` marking reaches actual `find`.
Once an existing yielded-value wait is settled, arbitrary finite interleavings
of append and settlement writes cannot reopen it or change the first matching
entry. These are the two writes to `actionWaits` in the runtime. Even appending
an entry with the same observer cannot shadow an earlier settled entry.
After such a history, the actual lookup and duplicate-delivery guard return the
complete current World, continuation and value stack unchanged, for fulfillment
or rejection. The initial lookup's presence is explicit; freshness and reachability
of every observer are not silently assumed.

Seven new active roots cover the pair update/route, constructed completion
certificate and its debt corollary, wait marking, settled-history preservation
and actual duplicate delivery after that history.

## What remains open

This closes the **second completion accounting** gap for the stated prefix/history
family. It does not close the full once-only action protocol: connecting every
callback path, observer freshness, returned iterator-result Promise settlement,
result adoption and generator continuation to an action/flight ledger remains
necessary. A yielded wait staying settled is one dependency of that result.
The pair history admits each action's completion once; it does not establish that
admission rule for every public execution.

Intervening signal writes, flight settlement/disposal, general component joins,
global forest/live-list validity, and renderer publication remain outside this
theorem. Zero action debt does not imply `blocked == false`: nodes and nested
lanes can still block a group. No eventual delivery or fairness claim is added.

## Validation

The three new modules and seven composed roots are checked with the pinned
independent kernel. Existing 48 native-generator/public histories (408 prefixes),
288 private joins, 1,152 exact rejoins, 576 resolver queries, 32 opening controls
and 320 positive-blocker judgments were rechecked. A further 21 native-generator
protocol controls and 67 action histories pass. These are finite supporting
checks, separate from the quantified proofs.

Four focused source mutations are rejected. Configuration is now 587 variants
(469 finite /118 kernel); no fresh complete 587 sweep is claimed. An additional
attempt that bypassed the duplicate guard hit the proof process RSS limit and
was **not** credited as a rejection; a smaller mutation that corrupts the duplicate
World result was independently rejected instead.

Current next remains `cc3ee740`, with no signals drift from the pin. PR
[#4248](https://github.com/solidjs/solid/pull/4248) remains open and separate.
No new Solid bug or semantic workaround was introduced. Exact validation hashes
and logs are recorded in [the receipt](reviews/action-completion-validation.json).
