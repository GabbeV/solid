# Held latest errors: publication context, not a demonstrated storage limit

Investigation only. The retained runtime remains stage 132. No semantic ruling,
runtime fix or test expectation change is retained.

## Original audit coverage

PR #3886 explicitly tested early latest error publication in
`error-held-reveal.test.ts` at its head `7b5d641e`: “keeps latest outcomes in their
reveal lane instead of holding them with ordinary effects”. During the held
sibling request it asserts ordinary=1, latest=failure, sibling=1. This is an
effect-callback test, not the Show/Errored DOM pair reduced in stage 134.
The audit document explicitly selects proposed failures through latest.
The closest extracted issue, #4106, tests outside latest reads through a
memo and was closed as fixed by #4129. It does not cover this boundary swap.
Thus this is remaining coverage of the original intended symmetry, not evidence
that upstream deliberately rejected it.

## Trace on unmodified next plus instrumentation

Copied next `4fe75321` built artifacts into scratch and instrumented boundary
catch/fallback and scheduler hold/commit. The source checkout and its built
artifacts were untouched. Reused all four stage-134 JSX timelines.

In both error shapes the span's latest read throws and the boundary catches the
proposed error. The original source still has committed `ready` and a staged
StatusError. No overwritten error slot is needed to explain the difference.

- Retained branch: caught in the verdict lane while the ordinary action's flush
  transaction is active. The boundary output reruns without that lane context.
  The scheduler's settle holds its fallback proposal in the ordinary transaction.
  DOM remains `0ready`.
- Proposed branch removal: caught in a later verdict round, with no ordinary
  flush transaction active. The boundary output reruns without lane context too,
  but its fallback commits in this round. DOM becomes `0failed`.

This is lost publication context at the boundary conversion, dependent on which
processing round encounters the error. It is not an error failing to reach the
boundary. The boundary also records StatusError.source as its recovery/reset
source; that is distinct from which update should publish the fallback.

## Rejected minimal trial

In the scratch build only, remember `passLane` in `b._lane` when catching an
error. Existing fallback code enters that lane. No new fields or storage.
This makes both error shapes publish `0failed` during the open action. However,
the retained-branch recovery stays `0failed` after `recovered` is ready, until
the action ends. Baseline next shows `0recovered` at that earlier point. The
removing-branch recovery remains unchanged. This is an incomplete trial, not a
fix: moving the initial fallback is insufficient to repair its recovery lifecycle.
The four diagnostic tests assert only initial/final frames; their passing status
does not approve changed intermediate frames. Full histories are in the logs.

## Experiment implication and limits

Our latest sampler explicitly returns NOT_PENDING for both staged and status
errors, so unlike a successful proposal it does not start a higher output update
for that error. Its fallback forwards the original StatusError. The two-node
representation already gives input and output separate ordinary outcome storage,
but error selection/publication across that boundary is incomplete. Stage 125's
rejected trials also found recovery/reset consequences when changing the source
named by the error.

The evidence supports a publication/coordination bug in the reduced next case,
not a proof that arbitrary lane error histories need no additional representation.
A complete fix must handle initial error publication, held recovery, reset,
ordinary readers and fallback children together. No new performance or size claim.
