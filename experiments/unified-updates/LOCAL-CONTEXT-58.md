# Can local retries be a sound foundation?

This is a candidate model, not a claim that the existing reference or production
prototype implements it. No coordinator changed in this investigation.

## Evidence from next

The stage-57 audit now repeats the ordinary read after the optimistic read.
During ordinary-first preparation, pinned next executes the body with
`x() = 1`, `view() = 10`, then `x() = 0`. Its seam subsequently repairs the
calculation. Only the corrected `(0,10)` answer publishes in this fixture,
but the mixed execution reaches user code and starts `(1,10)` work. Reversing
the initial read order avoids that attempt. The reference avoids the mixed
execution in this test; it still fails the separate stage-56 discovery audit.

Next history also contains a concrete repair-loop bug, fixed in b2bec734
(#3969/#3980). Entering a lane after reading a freshly created, held memo asked
the reader to retry against a committed value that did not exist. The retry
repeated until the loop guard. The fix distinguishes staged reads with a
committed alternative from born-held reads. The actual regression is in
`packages/web/test/hmr-spinner-loop-3969.spec.tsx`.

The design plan's section 28, implementation detail 8, explicitly describes
reading unparked staging speculatively and repairing if the flush parks. Its
motivation is avoiding needless passes/child cleanup on the synchronous path.
These facts do not show that global reinterpretation of origin relationships
is necessary. Nor do they establish that all next retries affect only a single
node: owned children, normal downstream propagation and publication groups can
also be affected.

## Candidate separation

1. An update proposal has a stable read relationship to other proposals for its
   lifetime. Learning a subscriber cannot promote or reparent the producer's
   existing proposal. Numeric ranks are one possible encoding, not yet chosen.
2. A computation discovers which of those existing contexts it must calculate
   in. If a new read invalidates earlier selections, abandon that attempt at
   the read and restart the computation under the learned context. Do not keep
   executing with a mixture of versions. A pending read waits for its answer;
   absence of a committed fallback cannot be repaired by repeatedly retrying.
3. Same-context peer joins may extend publication obligations, without changing
   the input versions selected for other already-started work. A genuine new
   source proposal may supersede work, as usual.
4. An active optimistic output is a cut in value/context propagation. Discovering
   hidden input dependencies may change input work and forwarded demand, but
   must not retroactively reclassify an unchanged output override. Its action
   lifetime and observation forwarding remain distinct from value selection.
5. Once an attempt has read its inputs successfully and started async work,
   unrelated dependency discovery cannot invalidate that selection. Publication
   still checks coherence, and real input changes propagate normally. This does
   not promise exactly-once invocation of side effects before a later read throws.

The important locality is causal: recalculating a reader (and work whose inputs
actually change) versus using its discovery to reinterpret producer proposals
and thereby cancel other work that already had its inputs. Local retries do not
mean disabling downstream propagation or memo entanglement.

## Unresolved design gate

Stable proposal context assignment remains unsolved for an optimistic boundary
whose input is suspended before discovering a deeper optimistic dependency.
Freezing the old implementation's number is not enough: stage 55 already showed
overholding when pending ancestry was simply omitted. The output's active
override must truly isolate input context, with a coherent handoff at correction
or expiration. Inactive transparency, unknown initial inputs, genuine nested
guesses and sibling combinations must all work. This is the next falsification
target, not a reason to restore global revisions by default.

Artifacts: `results/local-context-stage58/{next,reference}.json`. No performance
or size claim; no broad correctness claim from these small traces.
