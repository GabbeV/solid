# Deferred flight lifecycle dependencies

Update: the [public data/thenable constructor](deferred.md) now consumes these
helpers, sharing one arena Set and installing cleanup/observer/watch crossings.
The dependency-only descriptions below record the earlier milestone; direct
streams/from/store/boundary profiles remain unfinished.


runtime/deferred-lifecycle.bend follows createDeferred's ask, land and end
closures, its post-cleanup loading-window segment, source-error catch and
post-handleAsync served-value selection. This is a dependency checkpoint:
public construction, callback registration, stream wrapping, cleanup registration
and the watcher's installed lagging hook remain unfinished.

DeferredCell retains the source closure's node, flight identity, marked and
answered locals. DeferredState threads one cell with the shared module Set's
membership view. It is not a per-cell replacement Set: a future arena caller
must pass the current shared membership view through every cell operation.
No World field or existing public expression is added by these helpers.

ask assigns the flight before Set.add, skips repeated insertion, and marks and
repolls only if not already marked and not REACTIVE_REASK. land tests null and
identity before every side effect, clears the flight, removes its membership,
then scans the full dependency list for the first held input. It resolves that
input's transaction before holdNode and drops this closure's one mark afterward,
scheduling even when other independent marks remain. A rerun cleanup retains
the flight; actual node disposal ends it. The sticky answered bit is determined
before opening the loading window; an open loadingValue alone is not an answer.
The source catch keeps the exact exception and only parks NotReady inside an
open window. served is strictly the selection after actual handleAsync returns;
there is no invented stale-value implementation of async processing.

The source closure observer exposes original functions and live captured locals;
it does not replace their bodies. 1,664 native controls cover Set order, flight
replacement and stale/null callbacks, quiet reasks, shared mark counts, error and
loading states, pending undefined/zero, disposal and first-held-input transaction
resolution. The held scan is also tested during recomputation with no validated
dependency prefix: land deliberately scans the full list. Another 120 controls
invoke actual serve and handleAsync before checking its final selection in Bend.
They are private segment comparisons and do not add public histories.

Eight quantified kernel properties establish exact no-op Worlds/cells for null
or superseded landings, exact unmarked completion, already-marked replacement
without another World mutation, idle cleanup, arbitrary-fuel empty held scans,
closed-window original exception preservation and sticky answered state. The
sameChoice lemma is a checked auxiliary, not an alternative runtime. These are
scoped lifecycle boundaries, not an arbitrary createDeferred program theorem.
Existing complete-program proof domains and sufficient budgets are unchanged.

The initial mutation pass exposed a weak oracle: checking only CallbackThrown's
tag missed replacement of its cause. The comparator now checks the exact original
cause. Compiler errors during fixture development and this accepted mutant are
not counted as useful negative rejections; the corrected controls are rerun.

No semantic workaround is active. The two confirmed source-only from defects
and their isolated patches are in the issue register. Their hosted JSX repros
now use the available mizulu/solid2@aece1d44 build and were checked after reopening.
The deferred wrapper's first-pull source bug has not been silently repaired here;
stream wrapping is still outside this checkpoint.

All 25 new variants now fail assertions after correction: 22 finite and three
kernel. Total distinct useful rejections are 480 (406 finite /74 kernel), alongside
the full earlier 455-variant pass on unchanged prior runtime definitions. The
public and alignment suites pass, and all composed properties pass the root kernel.


## b9b6f333 merged catch behavior

The source catch now calls land(flight) unless its full open-and-NotReady guard
holds (#4231). sourceFailed follows that exact else and rethrows the original
value. Core.deferredUnwind clears the active translated fault while the catch
executes; otherwise guarded mark release would be skipped. The old closedFailure
state-preservation conclusion is retired with the source change and replaced by
exact post-land rethrow over the same domain. Two further properties prove
unmarked ordinary-error retirement and the open-NotReady ask, and a general core
continuation property checks the caught-fault boundary. All complete-program
domains and budgets stand. See reviews/solid-b9b6f333.md.
