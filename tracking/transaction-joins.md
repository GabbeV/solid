# Action opening, distinct joins and the first completion

This checkpoint extends the shared runtime's semantic proofs. Runtime, host,
vendored Solid and Bend/kernel limits are unchanged. Solid remains pinned to
225014bf (rc.18); a fresh impact check finds no signals source drift against
current next@cc3ee740. The user submitted deferred protocol-error PR
[#4248](https://github.com/solidjs/solid/pull/4248); its patch remains separate.
No semantic deviation is active.

## What is now established

The new [active laws](../LAWS.bend) and their [proofs](../PROOF.bend) cover:

1. **Real action allocation and opening prefixes.** `Action.create` appends the
   result Promise and a new action cell. Once the factory has returned successfully,
   `Action.open` appends a nonzero transaction, records one outstanding obligation
   and the acted marker, and captures that identity and a fresh question in the
   allocated cell. Complete World equations preserve the other state and the
   action's methods/result identity. No initial debt or capture equation is given
   as a premise for the composed constructor theorem.
2. **A distinct ordinary join at arbitrary allocated positions.** For arbitrary
   prefix/gap/suffix transaction lists, two selected ordinary root records are
   genuinely allocated, distinct and nonzero. Actual `merge` redirects the source,
   adds open counts and the action marker, appends target work before source work
   in nodes/render/user/rerun/mark vectors, and retires the source from the live
   list. The entire surrounding World and all other arena slots are retained.
   The retired source keeps its old count and vectors: these are not live debt.
3. **Resolution and arbitrary finite rejoins after that join.** The newly created
   source-to-target route is constructed from actual fields. Public resolution
   through either identity returns the target and preserves the World. Its real
   arena-sized budget is derived from the allocated structure, not supplied as a
   room premise. Any finite mixture of lookups and rejoins through the two original
   IDs preserves the exact post-join World and records only the live representative.
4. **Two constructed actions through their first completion.** Two actual
   allocation/opening prefixes create two distinct transaction slots, then an
   actual join in either direction has exactly two obligations. Either action may
   finish first, using its actual captured ID, after any finite history described
   above. The result is exactly source scheduling after changing the representative
   count to one. No capture, resolver, positive-count or traversal-room equation
   is supplied as a premise for this composed theorem.
5. **Scheduling preserves ledger storage.** Across ordinary, already scheduled,
   nested/running and halted scheduling branches, transaction records, live IDs
   and action cells are unchanged. The frame theorem does not erase requested
   jobs, diagnostics or other permitted scheduling effects.

These properties quantify over arbitrary surrounding Worlds, finite list sizes,
source/target records, action method expressions and permitted history lengths,
with the restrictions below. They use the real runtime operations; the history
runner passes the evolving World between those calls. They are not a generated
collection of exact executions.

## Domains and remaining obligations

The constructor domain is the source allocation/opening prefix after a successful
factory return. It does not execute arbitrary factory/generator methods or prove
an entire public action invocation, Promise delivery, return adoption or rejection.
Reserved transaction/action slots are explicit in the initial representation;
new IDs come from real appends. Other referenced arenas still need their own
validity contracts before this becomes a global reachable-state invariant.

The distinct-join theorem supplies the two selected allocated ordinary roots by
structural list splits. It does not assert that every transaction in an arbitrary
background arena is valid, acyclic or live. The full World equation follows the
actual live-list removal, including its existing missing-source behavior; global
membership/unique-live-list preservation is a separate obligation. Existing
mutable-JavaScript protocol and callback restrictions remain in force.

The composed history admits one distinct join, any finite number of queries and
same-component rejoins, then at most one action completion. Both join directions
and either first completion are covered. Repeated completion of the same action,
the second completion, intervening writes/settlements/disposal, and general
multi-component forests are not covered. The constructors do not execute the
method expressions; the completion event models the source `done` prefix after
that action's successful terminating body slice. Callback at-most-once delivery
has not been proved by making this event once-only in the theorem.

This is accounting and identity safety at named helper boundaries. It does not
prove the renderer's held-content observation, absence of all blockers when the
count reaches zero, internal publication completion, or eventual reveal under
host delivery/fairness. Flight/result/question authority remains distinct from
transaction grouping. Formal TS/Bend equivalence is outside scope.

## Source correspondence and independent evidence

The relevant source anchors remain `core/action.ts`'s allocation/open/done prefix
and `core/scheduler.ts`'s `newTransaction`, `resolveTx`, `merge` and scheduling.
No source function body is replaced in native controls.

- 288 private source-helper fixtures cover arbitrary slot positions/directions,
  asymmetric metadata and nonempty work vectors, absent versus empty marks, 1,152
  exact rejoins and 576 resolver queries. Another 32 Bend opening-frame controls
  check actual action allocation/opening. These are not public histories.
- 48 public differential histories use independently authored native generators
  and the same Bend runtime: both creation/completion orders, text/nullable/opaque
  reference payloads, optional resumed writes and disjoint rendered work. All 408
  observed prefixes agree. Ordinary content stays committed until both actions
  finish; independent content may publish during the hold. This is finite evidence
  for the selected rendered-graph target, not its missing theorem.
- Nine focused source mutations are rejected by the independent kernel, covering
  lost/reversed work, marks, retirement, stale source count, unrelated slots,
  question allocation, result identity and decrementing twice. Configured totals
  are 581 (469 finite /112 kernel); no fresh complete 581 sweep is claimed.

The [validation receipt](reviews/joined-action-invariants-validation.json) records
commands, verdicts and hashes. Earlier frozen mutation sweeps retain their own
checkpoints and counts.

## Proof elaboration adjustment

The first nested two-action specification exhausted elaborator memory. A compact
expected-World normal form was proved equal to the source-indexed constructor
contract. The next version reached the independent kernel but ran out of fuel in
`joinShape`. Factoring the join/count/read/completion equations at an opaque World
boundary lets the actual constructor certificates be composed without repeatedly
expanding both constructors inside every operand. The final module and active
composed roots check with the existing pinned toolchain and limits. No runtime
algorithm, theorem domain or kernel limit was changed to obtain these results.
