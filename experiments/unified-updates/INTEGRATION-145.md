# Input-lifetime fixture migration and rejected early-latest trials

The retained runtime is unchanged from stage 141. Stage 144's accepted branch
publication rule remains in force. No new semantic ruling is needed for this
checkpoint.

## Independent input and override lifetimes

Migrate #4336 to the already accepted stage-120 rule. A posting action guesses
comments for selection 3, then an independent update selects 1. Selection 1 may
publish while the comments output retains the posting override. Resolving the
new input does not replace that override. When the post and its refresh finish,
the output corrects to the new input through ordinary publication.

The same rule applies when the selection itself is optimistic: confirming or
reversing that lower override does not replace the upper posting override.
This deliberately does not rebase the guess onto a different resource identity.
The control where the posting action itself writes the selection still holds
that write until the action completes.

The previous fixture called any old-resource guess beside the new selection
"torn". That crosses the very input/output boundary whose independent lifetime
was authorized. Replace that check in these cases with an ordinary uppercase
memo of the comments output, and assert that each published output/derivation
pair agrees. Keep the exact selection/comments timeline assertions, the
same-action identity checks, and the separate keyed-store identity checks.
The fixture now disposes its roots after each case.

The pending/latest case follows the same existing rules: a new input flight is
pending; its independently committed answer is no longer pending merely because
the posting action is open. Latest observes the selected optimistic output,
not the masked input answer. The post's quiet refresh remains non-pending, as
the existing refresh control already requires. No pending runtime change was
made to obtain these results.

All twelve scalar cases pass, replacing ten prior failures. The parameterized
store forms express the same intended contract but still fail at the explicit
optimistic-store stub; this is not store implementation or validation.

## Early-latest preparation investigation

The duplicate error-fallback callback remains an implementation issue. Selecting
an existing latest output's staged input before reading it repairs that case,
but selecting during arbitrary reads is not yet a safe implementation.

- The initial trial stalled when an owned-child retry reused an auto-disposed
  source observation. The trace showed staging an override before that output's
  normal revival. Excluding disposed outputs removed the stall.
- Early selection then exposed a tracked/untracked context-discovery difference.
  Retrying all reads based on their dependency depth broke publication in other
  layers. Restricting this to memos consuming held proposals, while preserving
  render bindings' committed-frame reads, passed all 684 focused cases,
  including the unchanged error tests and store coherence guards.
- The full candidate run fixed 22 old failures but introduced eight others:
  lost ahead publication, a first-load store exposing undefined, changed
  feedback timelines, and changed calculation/publication sequences. Its
  5,343/2,076 count is a rejected-trial result, not the retained result.
- Separating the changes showed that context retry alone repaired none of
  those old failures. Removing the extra producer pull changed none of the
  eight regressions. Restricting selection to already-held inputs lost all
  22 fixes and retained one regression.

All runtime trial edits were removed. No assertions were weakened to retain
them. The focused failures are useful constraints on a future change to
observation preparation order: preparation must select the output context
before downstream calculation, preserve revival and initial-value handling,
and avoid turning a read into an independent publication/lifetime decision.
Another local guard is not supported by the evidence from this pass. This
remains implementation work rather than a request for a semantic exception.

## Retained validation

- Full signals: **5,339 passed, 2,080 failed, two skipped**. Ten fixture
  migrations; no new failure after mapping renamed #4336 store cases, which
  still fail with the identical deferred-API error.
- Remaining signals inventory: 1,953 deferred API, 111 untriaged,
  twelve calculation expectations, four known implementation bugs. All nine
  previously classified input-lifetime cases have now been migrated; the tenth
  migrated case is the pending/latest case explained above.
- Latest error publication and accepted #4661 JSX controls: **31 passed**
  against rebuilt retained artifacts.
- All build tiers, property mangling, purity checks, declarations, rules index,
  targeted formatting and diff checks pass. Runtime files match the prior
  checkpoint. No performance/size claim, full web run, or hydration run.

Receipts, traces, rejected sources and full reports are preserved in
`checkpoints/integration-stage145.tar.xz`. The full-signal trial report is
`full-signals.json`; the retained report is `full-retained.json`. Only the
latter describes the committed runtime and tests.
