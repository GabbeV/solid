# Snapshot observation repair and pending-test migration

This pass retains one runtime repair and seven test migrations based on the
already accepted source-owned observation model. It does not retain the
attempted held-error publication changes. Receipts, rejected patches and
exploratory programs are in `results/integration-stage125/`.

## Hydration observations

The shared latest output is allocated outside the calling reader's owner.
Consequently a hydration claim could read a captured source value of 1 through
`source()` but a newer client value of 5 through `latest(source)`. The latter
read had moved to a different node that had no copy of the source's snapshot.
The same problem affected pending: a captured, ready server answer must not
report the live client's pending question during the claim.

`observesSnapshot` selects the source's existing ordinary snapshot read when
capture is active and the reader belongs to a snapshot scope. Ordinary `read`
continues to own subscription, stale marking and replay on release. Both direct
accessors and callback observations use this selection. The shared live output
is not changed or given a caller-specific snapshot. No new node fields or
ordinary-read branches are added.

Six additional cases cover direct/callback reads, captured `undefined`, live
readers of the same source during an action, and a server answer captured over
an unfinished client request. The action cases assert the complete frames:

```
claim:   [1, 1, false]
release: [1, 5, true]
commit:  [5, 5, false]
```

The three columns are ordinary source, latest source and pending. The live
reader sees `[5, true]` while the claim sees its server frame. All seven tests
in the expanded snapshot-observation file pass on both the experiment and
unmodified next `4fe75321`. The broader snapshot selection passes 52 tests.
Eight real hydration/consistency tests pass, including #4570's streamed re-arm
and C19's snapshot claims. These use the normal hydratable compiler config plus
the existing local jest-dom setup module: the installed Vite plugin's automatic
external setup path otherwise fails before executing tests. The temporary
config is archived with the receipts; no hydration assertions were modified.

## Pending migrations: intentional differences, not runtime fixes

These follow the user's earlier decisions that pending is a lazily created
source-owned output, its optimistic update reads committed lower inputs, and
ordinary reads do not inherit a special verdict posture.

- #4367: netted source writes publish no pending change. A false-only reader
  stays on one `F`, with or without an identity memo. Readers also displaying
  the source assert exactly `F2, F3`. The original no-stuck-pending checks remain.
  Four old failures were callback-count expectations for redundant `F` frames.
- #4349: the direct reader of `isPending(x)` beside `x()` asserts exactly
  `false:41, true:41, false:42`, including one outstanding fetch and none left
  after completion. Pending can publish beside committed x. The twelve refresh
  and affects scenarios retain their expectations.
- #4485: a false pending output does not lift a reader out of an ordinary held
  flush. The initial netted write's pass publishes at release, just like a
  reader without the observation. Both next and the experiment pass the three
  ordinary-reader controls. The migrated tests compare complete pending and
  ordinary histories, retaining the requirement that pending never becomes true.
  This differs from next's verdict-reader scheduling, not its ordinary updates.

The focused migration, peer-publication, reversal, recovery and rules-index
selection passes all 34 tests. No assertion permits tearing or substitutes a
last-value-only check for a publication history. These seven migrations add no
runtime code.

## Held latest errors: unsuccessful trials, still open

The existing E2 web regression remains: an action makes a memo throw while a
retained child reads latest of it. Next exposes the error; the experiment keeps
old content. Simply selecting the error as an override fixed that publication
but introduced duplicate error callbacks and changed recovery. Trials that
reanchored StatusError at the latest output also changed what an error boundary
waited for and what reset would retry. Changes to boundary pruning and ambient
notification context did not establish a general fix.

All those runtime changes were removed using exact pre-trial copies, preserving
stages 114–124. No ErrorProposal class, error-origin wrapper, boundary-pruning
exception or scheduler notification-context change is retained.

The reduction is not complete: the manual boundary/effect example holds the
error on next, while the JSX example exposes it. Single-core identity checks,
effect sync/transparency options, an enclosing effect, source ownership and a
later action turn did not explain that difference. It must not be attributed
to scheduled effects or treated as permission to loosen either test. The new
async-recovery probe also initially assumed the error would stay displayed;
next instead restores the older ready value when the new question starts.
That provisional assertion is archived, not adopted as a new contract.

## Validation and cost

The full signals run after the runtime fix and before the seven pending test
migrations recorded **5,176 passed, 2,138 failed, 2 skipped**. Against stage 124,
the snapshot failure disappeared; three already-repaired rules-index checks
also pass. There were no new failures. Six snapshot tests were added. The full
run was not repeated after test-only migrations; their focused run passes.

The full web suite records **1,588 passed, 139 failed, 1 skipped**, with exactly
the same failures as stage 122 and four added passing stage-124 tests. The
focused scalar optimistic DOM selection passes all seven tests. Unsupported
optimistic stores and until still account for most signals failures; the
remaining scalar audit is incomplete.

All build tiers, both production purity checks and declaration generation pass.
Production bundle sizes (minified / Brotli bytes), using the existing size
harness and pinned next baseline:

| Import scenario | next `4fe75321` | Experiment |
| --- | ---: | ---: |
| Ordinary core | 19,825 / 7,421 | 21,153 / 7,904 |
| Ordinary store | 43,868 / 15,089 | 45,222 / 15,513 |
| Pending/latest | 33,615 / 12,239 | 34,841 / 12,494 |
| Scalar optimism supplement | 31,722 / 11,561 | 34,248 / 12,487 |

Only the pending/latest scenario changed in this pass: +71 minified / +26
Brotli bytes. Existing caps still fail and have not been raised. No new runtime
performance measurement or claim is made. Ordinary code paths are unchanged;
the new snapshot check is paid by observation calls.
