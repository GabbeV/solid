# Failure audit: latest preparation and writes before first load

Follow-up: [stage 124](INTEGRATION-124.md) records the user's decision to support
scalar guesses before the first input answer, without the dev diagnostic.

This audit starts from stage 122. Runtime changes tried here were removed;
the retained change promotes the already-fixed pending-only #4469 expected
failure to a normal test and strengthens its complete publication history.
The combined value/pending expected failure remains unchanged.

Of stage 122's 2,143 signals failures, 1,861 directly report unsupported
optimistic stores and 55 directly report deferred `until`. Some remaining
assertions also depend on those APIs. The other 227 are not all established
implementation bugs: several pin legacy observation posture or mounting rules.
The existing rejected-first-read fixture was already classified in stage 118;
its supported Error/Loading-boundary replacements pass.

## Rejected latest trial

A synchronous ordinary write can run a reader of both latest and the ordinary
input three times. Two changes were tried together:

1. Let an existing latest output compute an unheld flushed proposal immediately,
   using the existing unflushed-value filter.
2. Avoid creating an override when that output already matches the unheld
   proposal.

This fixed twenty existing assertions covering one-pass synchronous readers and
batched staged reads. However, twelve previously passing async-request checks
then failed. A calculation reading both latest and ordinary inputs could ask a
question in the lower context, be restarted in the higher context, and ask the
original question again after the input committed. The rejected trial's request
trace includes `m0:23 -> m0:22 -> m0:23` and duplicate `m0b:1100` requests.

The failure is a context-selection/adoption problem, not evidence that it is
safe to remove request-count assertions. The trial was removed. Its patch and
reports remain under `results/integration-stage123/` for further investigation.
No duplicate graph, request cache or ordinary-node bookkeeping was added.

## Decision needed: a guess before the first input answer

Next's dev guard `devGuardOptimisticBeforeLoad` implements #4656's explicit
rule: writing an optimistic source before its first answer throws
`OPTIMISTIC_WRITE_BEFORE_LOAD`. The split implementation does not currently
invoke that guard.

The controlled public-API comparison produces:

| Event | Experiment | Pinned next `4fe75321`, dev |
| --- | --- | --- |
| Initial request pending | loading | loading |
| An action guesses 1 | 1 | loading; action rejects with the diagnostic |
| Initial input answers 0 while action remains open | 1 | 0 |
| Action ends | 0 | 0 |

The local probe uses a normal Loading boundary and separate input/action gates.
Both runtime logs and the probe source are saved alongside the reports.

Connecting the existing dev guard to the output fixes two upstream assertions,
but fails thirteen experiment cases that intentionally guess over a never-loaded
input. Those cases test unpublished children, first publication, replacement
and cleanup. They are substantive coverage, not tests to delete without deciding
the supported input domain. The diagnostic trial was therefore removed pending
the user's decision. No production behavior or cost was changed.

The core can represent the override without a previously published input value.
Keeping next's dev error is an API choice, not necessary for the split storage
model. If retained for compatibility, first-publication coverage should be
reworked around unpublished ordinary/async child outputs where possible, while
keeping explicit tests of the rejected optimistic write. This would not justify
weakening publication consistency assertions.

### Origin of the restriction

Read-only history/discussion audit: the guard arrived in merged PR
[#4656](https://github.com/solidjs/solid/pull/4656), fixing optimistic-list
corruption reported in [#4642](https://github.com/solidjs/solid/issues/4642).
That issue included adding a row before the initial list loaded: the eventual
list duplicated server rows instead of retaining the added row. The first PR
version attempted to support this case. The merged commit and PR description
explicitly say that banning it allowed removal of a first-run effect branch in
`dissolveLane` and a staging reset in `laneSet` needed only for first-load frames.

The generated PR description and D-34 quote the maintainer: “if it hadn't
landed it isn't optimistic, its loading”; “Write before load in the non
optimistic case gets squashed.. optimistic is odd one because its visible.
Idd be ok with it erroring I think”. They suggest an outbox or disabling the
input. These are recorded quotations, not a separately available transcript in
the public PR comments. The restriction explicitly narrowed an older
write-before-initialization allowance. Production was left unspecified and
unchanged to avoid setter-path bytes.

This supports both a deliberate scope choice and concrete implementation
pressure; it does not establish a fundamental consistency impossibility or
prove that shared input/output storage was the sole cause. An absolute scalar
guess has no unknown list base to patch and is already represented by the split
prototype. Recommendation after this audit: allow that scalar case if the user
chooses to revisit the rule; do not infer store draft/rebase semantics from it.
The user has asked for the rationale, not yet decided this API question.

## Retained verification

The pending-only #4469 test now requires exactly `[[true], [false]]` and no
additional landing callback. Its expected-failure marker had become the sole
reason that case failed. The focused recovery and owned-context selection has
31 passing tests after both runtime trials were removed. The final strengthened
recovery test was rerun separately. No fresh full-suite or runtime performance
claim is made; stage 122 remains the runtime checkpoint. No external changes
were made.
