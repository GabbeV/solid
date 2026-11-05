# Stage 63: deferred joins and read-time retries in the real core

This retained implementation supersedes the unresolved runtime findings in
READ-RETRY-62.md. It is not a declaration of scalar acceptance.

The twelve read/retry expected failures and the stale ordinary-request expected
failure now pass without weakening their publication or cleanup assertions.
The retry matrix also covers async generators: their first `next()` executes
inside the calculation context, so an invalidated initial body cannot register
its iterator flight before arbitration. Discarded iterator flights are closed.

## Mechanism

The coordinator defers **merging** a calculation's consumed pending updates until
its synchronous attempt is accepted. It records these reads only on the active
coordination path. Discovering an observation that requires a higher context
throws before that read returns, discards the attempt's children and flight, and
retries in the selected context. Ordinary settled reads acquire no journal.

An owned child's tentative reads are passed to its currently evaluating parent.
An accepted ordinary calculation still merges its consumed peer proposals.
An aborted lower-context attempt does not irreversibly merge those proposals.
The four `layered-deferred-joins.test.ts` cases check this distinction by finishing
one of two independent actions after disposing their shared reader.

Observation outputs select their initial context before they can inherit the
calling calculation's lower proposal. Source-owned identity and normal disposal
remain; no permanent subscriber is added to hide revival loops.

For an action holding x=1 over committed x=0:

```ts
const pair = createMemo(() => {
  const first = x();
  const pending = isPending(x);
  const last = x();
  return [first, pending, last];
});
```

Every **completed** body and publication is `[0, true, 0]`. The rejected attempt
stops at the observation read; its first x read is allowed to have used 1.
The same check covers latest, synchronous/async/async-generator bodies, and
observations reached through zero, one, or three owned memos. Tests bound retries
and fail on nonconvergence rather than treating disposal as success.

## Removed bookkeeping

The coordinator no longer retains a parent set for each update or a cached
reachability result for each reader. Stable update positions and the current
dependency prefix determine context arbitration. Removing the cache also removes
dependency-epoch tracking from the ordinary graph's link/unlink operations.
These deletions do not change the accepted stable-position semantics.

The sparse committed-dependency journal is still present: an unpublished
replacement does not erase the dependencies of the old frame still on screen.
The speculative coordinator and its downstream ownership walk have not all
been eliminated. No claim of final code-size acceptance follows from these
particular deletions.

## Validation

Before the ownership work in stage 64:

- Full suite: 5,495 pass, 22 expected failures, two skips, 326 files.
- Expanded scalar-only campaigns: 83 pass in six files, 100 seeds each for
  pending, branches, overlap, and latest; no legacy lane engine compiled in.
- Declaration type check and scalar production build pass (the build also emits
  the pre-existing diagnostics from unrelated test files).
- Production F5b retains 1 in existing and late readers until 2's consequence
  is ready. The ordinary lazy-mount audit starts only the current request.
- Production async owned observation audit completes in two attempts, publishes
  `[0, true, 0]`, and cleans every discarded/final owner exactly once.

One fixture previously rejected a promise for a stale request that no longer
starts. It now asserts that request never starts and handles only that unused
fixture promise. Rejection handling for flights actually consumed by the runtime
remains tested.

Artifacts: `results/deferred-joins-stage63/`. Performance snapshots there describe
their exact build variants; use the newer stage-64 report for current comparisons
against pinned next. No comparison to an older experimental runtime is an
acceptance argument.
