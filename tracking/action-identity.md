# HARNESS-ACTION-IDENTITY-001

This is a private fixture/claim defect, not a Solid bug, runtime deviation or false
kernel proof. `B.empty()` starts the action arena empty. The first actual
`Action.create` returns action **0**. The typed wait fixture constructed/opened that
action but then forced action **1** into `Action.wait`. Index1 was unallocated.
Observer identity1 and transaction identity1 were valid; their separate arenas do
not imply that the action has identity1. Zero is a valid action index.

The gap appeared when the next theorem tried to execute the first callback and
retire its obligation. The malformed wait invoked the fallback action cell,
leaving the real action's group open and its output unresolved. A finite wrong-
alias control retains that diagnostic: after `ActionStepReturn`, the real group's
count stays1 and its output stays unresolved. Using the returned action0 closes
that group to0 and settles its output, as real Solid does.

## Correction and historical scope

`action-wait-fixture.bend` now retains actual create/open/new-thenable results and
derives both action and input-result IDs. New roots establish allocated actor
room and registration capture, then the corrected range/nonzero/settled/duplicate
history contracts. Private suites verify allocated actor room before and after
every sampled prefix. The old four helper equations are preserved with their
original logical domains in `action-wait-legacy-fixture.bend` and explicitly named
`legacy_unallocated_alias_...` roots. They are true properties of malformed helper
inputs, not constructor-to-valid-actor or first-callback/debt proofs.

The constructor-to-actor wording in checkpoints fb4dd44b through5219e071 and their
wait/capture receipts is therefore qualified. The actual observer allocation,
wait-list lookup/range, committed frames, settled duplicate guards and then-catch
statements remain valid on their stated domains. Their six native public action
controls remain valid independently. The full664 named rejection receipt is
unchanged and still records a real sweep of its frozen inputs; it did not prove
the missing allocated-actor association. Earlier native source/ABI results are
unaffected. No historical receipt or root domain is silently erased.

The corrected suites pass368 old orders and408 expanded orders, six repeated-
action native sequences,12 raw client constructions,66 actual first-delivery/
retirement cases,33 deliberate wrong-alias traps and22 native terminal-generator
controls. Four focused runtime faults reject a wrong capture, omitted mark,
unretired debt and adoption of a thenable rejection reason. Runtime, source,
host codecs, execution budgets and kernel limits are unchanged.

## Actor context across helper histories

[The outer-context invariant](action-helper-context.md) masks only the four actual
callback tables and retains every other World field through arbitrary finite
helper histories. Allocated actor room and the full captured cell now follow
after each permitted constructor prefix, and actual terminal retirement's zero
count survives later helper suffixes. Four roots extend618 to622; stronger finite
outer-World observations pass. Three new context corruptions and a fresh run of
all14 later faults are rejected. Full664 remains a separately frozen receipt;
current678 is not claimed as a complete sweep. Runtime/source/host/limits remain
unchanged. General pre-arrival controller composition and full ledger/flush/
reveal remain open.
