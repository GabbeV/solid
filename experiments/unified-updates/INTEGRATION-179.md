# Ownership assertions after creator retries

This checkpoint changes tests and their generated rule index only. The runtime
is stage 178, based on next `4fe75321d61f9e4f1e1c63edc2087d099a36e9e1`.
It completes review of fifteen signals failures and five web failures caused
by the accepted creator-context retry rule. These are assertion migrations,
not twenty additional runtime bug fixes.

## Why these expectations change

The user explicitly chose to retry a still-private creator when a child selects
an incompatible optimistic context (stage 172). Next generally keeps that
private creator in the incoming context. This changes which private children
exist before publication and can rebuild a provisional subtree.

- **#4473:** a creator branches on ordinary `y > 0` while an action proposes
  `y=1`, then `y=2`. Its child reads `latest(y)`. The retried creator sees
  committed `y=0` and closes the branch. No child callback runs until the final
  ordinary frame publishes 20. Inline and both memo forms agree. The fixture
  now also verifies one live final frame and exactly-once cleanup of every
  attempted frame.
- **C4 inline/memo parity:** a creator captures `s`, then creates a child reading
  both `s` and `latest(s)`. It retries to capture 0 beside latest 1; the final
  creator captures 1 at ordinary publication. The exact callback sequence is
  asserted, with no completed child mixing captured 1 with ordinary 0. Every
  attempted frame is checked for exactly-once cleanup.
- **#4467 fallback:** the original assertion on one fallback construction hid a
  second, visible difference. The retried mount can show `0:F1`: committed
  ordinary input 0 beside explicit latest 1. It stays there even after content
  finishes and changes to `1:C` when the action closes. All four fallback forms
  assert these checkpoints and exactly two builds, still catching runaway
  reconstruction. The header's description of next's original bug remains
  historical context, not the experiment's private-frame rule.
- **#4284 grouping:** boundary discovery takes four compute attempts rather than
  two. The callback still publishes exactly `1 / 1`, then `5 / 5`. The exact
  attempt count remains pinned; avoiding redundant retries is a performance
  opportunity, not a reason to accept duplicate or inconsistent publication.
- **#3540 keyed Loading:** a latest-context retry adds one provisional mount.
  All visible content and fallback assertions remain unchanged. Both scalar
  and JSX fixtures verify that all three attempted mounts clean up once.
  Reusing a context-compatible provisional subtree remains an optimization
  opportunity; the old #4417 count does not justify keeping incompatible
  creator captures alive.
- **#4544 params:** after separate session and plan writes, a same-node pending
  observation can close the private branch on committed session. Its prior
  private params remain until ordinary preparation resumes. The old signed-out
  DOM stays visible; the eventual branch has complete incoming params. Both
  fixtures now state that exact intermediate private value and keep the final
  params and DOM assertions.
- **Owned first render:** a later latest proposal removes the unpublished
  child after the creator retries to its closed branch. The final ordinary
  frame creates a replacement. The tests still require eager detached DOM
  construction, no early attachment or scheduled callbacks, correct final
  attachment identity, and exactly-once cleanup of every created child.

The review used existing history, including Ryan's #4473 commit `60d6307c`.
Its inline/memo parity and coherent held-frame publication remain constraints;
its old lane-specific private-read exception was superseded by the user's
explicit creator-retry decision. No new exception or diagnostic was added.

## Validation and remaining failures

The full signals run had **5,754 passed, 1,962 failed, 2 skipped**. Fifteen
previous failures are resolved by the reviewed assertions. Its only three new
failures were generated rules-index freshness checks after citation edits.
The index was regenerated and all three checks pass in the focused rerun.
The resulting inventory is **5,757 passing, 1,959 failing, 2 skipped**, comprising
**six non-deferred failures** plus 1,953 deferred optimistic-store/`until` cases.
The immutable full report retains the pre-regeneration counts.

Full web: **1,736 passed, 120 failed, 1 skipped**. Five reviewed failures are
resolved, with no new failing identities. **Five non-deferred failures** remain;
the other 115 are deferred optimistic-store/`until` cases.

The modified signals selection passed 78 tests; the modified web selections
passed 20 plus six owned-render tests. Added cleanup assertions pass. This is
not a full correctness claim, and no performance or size change is claimed:
no shipped implementation changed.

The remaining signals cases are ordinary derived-store/memo equivalence,
callback ordering, and obsolete lane-posture checks in #4491. They still need
individual analysis. The remaining DOM cases are three Loading/route cases and
two serializer cases. The three Loading tests pass in unmodified next with the
same native compiler. In particular, the two route transitions currently expose
incomplete content in the experiment; those assertions remain unchanged and
need a runtime fix.

The initial next comparison failed in Vitest setup because of symlinked
workspace dependencies. The corrected comparison used the same local setup
module as stage 175 and passed all three tests. Temporary baseline files were
removed; the baseline checkout is clean.

`checkpoints/integration-stage179.tar.xz` preserves before-fixtures, diagnostic
timelines, full reports, next comparisons, and the rules-index rerun.
