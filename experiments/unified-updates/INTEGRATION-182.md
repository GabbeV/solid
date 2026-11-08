# Stage 182 — hydration pending subscriptions and completed failure triage

This checkpoint resolves the last two known non-deferred failures across the
signals, Solid, and web suites. Optimistic stores and `until` remain deferred;
this is not a full-API or mergeability claim.

## Hydration pending subscription

A hydration claim correctly answered `isPending(data) === false` for its server
snapshot, but it returned without subscribing to the live pending output.
A deferred refetch can change readiness while retaining its previous value,
so the value subscription alone did not wake the badge after hydration.

The claim now reads the source-owned pending output with a captured `false`
snapshot. Existing snapshot notification and release machinery retains the
claim's readiness during hydration and wakes it afterward. Live readers outside
the claim retain their own readiness. No fields, ordinary-read branches, or
separate snapshot subscriber mechanism were added.

Six new controls cover direct and callback observations: a deferred refetch
before/after scope release, and joining a live pending output first calculated
after snapshot capture began. The existing seven snapshot controls remain green.
The original Solid deferred hydration test passes unchanged.

A rejected trial manually subscribed and marked the reader stale. It lost the
release wake after a non-creation rerun; using the existing snapshot machinery
avoids that separate lifecycle. The receipts preserve the failed trial.

## Show construction versus publication

Closing and reopening a held Show creates an eager private replacement. Its
unscheduled callback may build `en:b` while the attached branch remains `en:a`.
The old test put all construction callbacks into one global log and treated that
log as publication. This is the previously accepted eager-construction rule,
not permission to expose inconsistent attached DOM.

The test now separately pins exact unscheduled and scheduled callback logs.
The scheduled case retains the original publication sequence. Added keyed and
non-keyed JSX controls require the old paragraph's identity and text to remain
attached throughout the hold, including unrelated formatting updates and an
obsolete async close answer; the new branch and data publish together. These
DOM controls also pass on next. No Show runtime change was needed.

## Validation

Full-suite results, compared by failing test identity with stage 181:

| Suite | Passed | Failed | Skipped | New failing identities |
| --- | ---: | ---: | ---: | ---: |
| Signals | 5,779 | 1,953 | 2 | 0 |
| Solid | 904 | 23 | 0 | 0 |
| Web | 1,768 | 115 | 1 | 0 |

All remaining failures are previously classified deferred optimistic-store or
`until` coverage. The two late-live snapshot controls were added after the full
signals run; all thirteen snapshot controls then passed in source and production.
Thus the current suite has two additional validated cases beyond that full-run
count. The production selection passed 165 cases before those additions, with
all thirteen snapshot cases passing afterward (167 distinct production cases).
Next passed the original two Solid test files (10 cases) and all four Show DOM
controls. Type generation, production/observe purity checks, and rules-index
checks pass. The first Solid full run used freshly built but unmangled production
artifacts, producing one packaging assertion failure; the final full run above
used the completed build and resolved it.

Minified / Brotli scalar bundle bytes against next
`4fe75321d61f9e4f1e1c63edc2087d099a36e9e1`:

| Imports | Next | Experiment |
| --- | ---: | ---: |
| Ordinary core | 19,825 / 7,421 | 21,456 / 8,056 |
| Optimism | 30,556 / 11,180 | 37,213 / 13,432 |
| Observed optimism | 35,643 / 12,920 | 43,434 / 15,330 |

The repair adds 104 minified bytes to the observation scenario. Ordinary and
optimism-only scenarios are unchanged. No new throughput claim is made.
The next substantial API work is optimistic stores; `until` remains explicitly
deferred. Further performance/size acceptance and broader adversarial validation
remain necessary before considering the experiment mergeable.
