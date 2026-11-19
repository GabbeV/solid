# Stage 88: continue the audit without blocking on owned optimistic writes

Historical checkpoint: [stage 89](SCALAR-AUDIT-89.md) resolves the owned-frame
timing discrepancy, fixes a related tearing case, and completes classification
of the remaining migration failures. The fresh Loading mount remains a known
implementation bug.

The user questioned whether stage 87's ownedWrite example has a sensible use.
The discrepancy specifically needs a guess made inside a reactive computation;
ordinary nested optimistic declarations do not demonstrate it. No convincing
application example has been established. It remains unresolved, not approved as
an intentional semantic change, and is no longer treated as a blocker for other
scalar work. The prior claim that a ruling was needed before continuing was too
strong.

No runtime implementation changed at this checkpoint. Temporary merge tracing
was removed.

### Provenance of the owned optimistic write test

Git blame and the GitHub commit patch confirm that the test was added in
143c530beaf3d0a9df305c81b315a1862ec2ef30 (2026-10-02), the initial checkpoint
commit of PR https://github.com/solidjs/solid/pull/3774. That PR was merged on
2026-10-04 as 1b9ceb67967178541cfd5dd09f712481b2cf1636.

The PR's design record, documentation/plans/size-reduction-carve-step1.md §17.2,
explicitly lists this case among five lane-hardening tests added during the
2026-10-01 correctness pass. Section 16.1 records the general maintainer ruling
that a lane ends when its parent ends and nesting applies the same rule
recursively. The test deliberately writes during the async landing's pure
derivation to create a child lane; its comment explains that an effect callback
would instead write in the next round.

The introducing commit, design log, and PR discussion provide no linked
application report motivating this particular setter-in-memo pattern. The PR's
four discussion entries retrieved are automated reports. Earlier PR #3479
explains optimistic derivations as overrides and the consistency bugs motivating
that mechanism; it does not introduce this owned-write test or establish an
application need for it. The documented general nesting rule should not be
presented as a separately verified maintainer endorsement of this coding pattern.

### Separate coverage after the user's test-organization approval

The upstream `lane-contract.test.ts` remains unchanged. The new tests separate
two different operations rather than treating one as a replacement for the other:

- `unified-nested-lifetime.test.ts` uses event/action writes with two nested
  optimistic boundaries. While the parent's input is pending, the child waits
  for its own async derivation, publishes, and expires back to the parent's
  override. The parent then corrects when its input answers. Separate scheduled
  bindings assert the visible input, both optimistic outputs, and the result.
- `unified-derived-guess-lifetime.test.ts` characterizes the existing candidate
  behavior of a setter inside a derivation. It tests input-held and action-held
  lifetimes, with both scheduled and unscheduled bindings, and asserts that the
  derived guess never appears even transiently in the badge's publications.
  Its comment explicitly records the input-held difference from next. This is
  provisional characterization, not evidence that the upstream contract was
  accidental or that the user has approved every consequence of changing it.

The practical consequence remains that an owned optimistic write made while an
async optimistic derivation lands can have no visible lifetime, despite the
outer input still being pending. Ordinary event/action nesting is not equivalent
to that implicit inheritance and the new test must not be used to claim otherwise.
No broader lifetime regression was found in the focused six-file run: 29 passed,
14 baseline/legacy comparison cases excluded. This does not establish exhaustive
compatibility. There were no runtime changes or new performance measurements.
The separate owned-frame timing failure below remains unresolved.

## Late readers: a necessary consistency difference

late-reader-input-publication.mjs runs ordinary and latest inputs, with and
without an existing observer of the async derivation. All output bindings use
scheduled render effects. Eight paired production executions are saved under
results/scalar-stage88.

When there is an existing observer, both runtimes retain input=1 while request 2
is pending; a new reader mounts result=1, and all bindings update to 2 together.
When no existing observer holds the request, input=2 has already published. An
ordinary late reader waits for result=2 in both runtimes. With latest, however,
next mounts result=1 beside input=2; the candidate waits for result=2, following
the ordinary rule. This explains F8's unchanged upstream failure and exposes the
consistency problem in retaining its optimistic-specific stale-read rule. It is
category 2 under the existing uniform-publication requirement, not a request for
a new ruling. The original upstream assertion remains unchanged.

## Owned-frame comparison: cleanup is correct, timing needs more investigation

owned-frame-migration.mjs extends the #3698 fixture past its first failed cleanup
count assertion. Both runtimes retain the actually displayed frame throughout
the held replacement, dispose it at publication, and dispose every created
frame exactly once. The candidate creates extra unpublished frames, disposing
them before publication. That extra work remains an optimization issue.

The full trace also exposes a separate timing difference: an independent drag
signal updates an ordinary reader beside the held optimistic output. Next
publishes drag=true immediately; the candidate holds it until the optimistic
request completes. Both are coherent in this comparison. This is not explained
away as merely an extra cleanup count.

unified-owned-migration.test.ts is a new, currently failing comparison for that
upstream timing, with retained-frame and exactly-once cleanup assertions. It is
an investigation target, not a decision that next's timing is necessarily part
of the new model's contract. The existing 430-pass checkpoint must not be quoted
as the current whole unified-update suite being green while this test fails.

Tracing found the join in prepareLayers: it replays a higher update's memo in a
ready lower update before publication, and recompute rejoins the memo's existing
holder. Avoiding that join is not safely achieved by simply skipping the replay:
a memo combining the changed ordinary input with the optimistic output still
needs to remain coherent with the ordinary input. The next investigation must
distinguish replaying against the optimistic output's committed value, preserving
the pending upper calculation, and delaying the lower update. No new exception
or speculative additional result storage has been added.
