# Stage 48: hidden unanswered work and visible publication

The question from stage 47 arose from an overly conservative reference-model
rule, not from a demonstrated benefit of retaining first=0. The user accepted
preserving next's first=1, second=3 outcome after the child override hides the
unresolved middle calculation. There is no reason established here to make
rendering the override count as rendering its original input. The earlier
ready-answer lifetime ruling remains in force.

Next does have relevant machinery: observed pending frames govern holding;
CONFIG_INPUTS_PUBLISHED distinguishes an obsolete old async result from a valid
committed answer. Once an upstream value publishes, a new ordinary reader must
wait for its current async consequence rather than obtain the previous result.
Saying simply that next has "no mechanism" would obscure that requirement.

## Reference implementation

Render nodes are explicitly marked before their first evaluation. A group can
publish when its affected visible frames and their creating owners are ready.
An unanswered computation with no remaining visible consequence can keep running
without holding that group. Its old frame remains for cleanup, but is unavailable
to ordinary reads after its inputs publish. An arriving answer starts an update;
new readers subscribe and wait; superseded answers remain ignored.

Action lifetime is separate from visibility. An action waiting for a hidden
input answer remains live after its body closes. Once a ready answer arrives it
joins the guessing lifetime, and correction releases through ordinary machinery.
The reference no longer couples an unanswered input to that lifetime merely
because it is pending.

The broader campaign also exposed a preparation bug previously masked by the
all-nodes readiness rule. A speculative read could discover a higher pending
origin after an earlier reader had prepared. Publication could then retain an
old conditional result alongside its new branch signal. The reference now
stabilizes newly discovered origin obligations before checking publication.
The campaign's consistency assertions are unchanged.

Some historical fixtures used bare async memos named holdA/holdB to manufacture
holds. Those now explicitly render those calculations. This preserves the
intended observed holds and every existing expected value. The same fixtures
also pass against their historical scheduler implementations.

## Evidence

`results/observed-holds-stage48/` contains the before/after reference, initial
failures, the conditional-publication diagnostic, final results, and the accessor
adapter's unanswered-input audit. The audit now produces:

| Step | first | second |
| --- | ---: | ---: |
| First guess, middle unanswered | 0 | 0 |
| Child guess, both actions open | 1 | 3 |
| Middle answers 2, both actions open | 1 | 3 |
| Child ends, parent open | 1 | 2 |
| Both end | 0 | 0 |

Baseline next also publishes 1,3 at the second step. It differs at the third:
it replaces the override immediately with 2. That replacement remains rejected
under the already accepted ready-answer lifetime rule.

Validation: 144 reference tests pass (95 consolidated-model tests, 49 historical).
Six new cases cover both traversal orders, a separate ordinary observer retaining
the hold, late input and override readers, pending status of the hidden input,
supersession, rejection/recovery, cleanup, and repeated ordinary/optimistic cycles
without growing subscriptions or leftover update groups. Historical changed
fixtures also pass independently. Existing branch and action campaigns remain
finite evidence, not a universal consistency or termination proof.

No production source changed in this stage. The production coordinator still
uses the earlier implementation; this observer-aware reference has not been
ported. The adapter still lacks real Loading/ErrorBoundary behavior and exposes
unavailable outside reads as an error. Rendering and owner checks here are a
model, not evidence that full scheduled/unscheduled effect semantics are done.
No new performance or size acceptance is claimed: reference performance and
production feature-bundle size deficits remain open. Stores remain paused.

Reproduce:

```sh
UNIFIED=1 node --test experiments/unified-updates/reference/*.test.mjs
node experiments/unified-updates/unanswered-input-audit.mjs \
  experiments/unified-updates/reference/scalar-runtime.mjs
```
