# Public non-store affects scopes

Solid 5b1b7776 (rc.17), production. `affects` now runs through the shared core
with its mark/read/transaction/flush dependencies connected. No source changes
or semantic workaround are active. Store targets/keys, slot-flight/family hooks,
proxy or metadata getters, arbitrary host objects and dev diagnostics remain
outside this grammar. `createDeferred` is still unfinished.

## Correspondence

Target and optional key evaluate left-to-right before registration, including
invalid targets and throwing keys. AccessorReference carries the source's
$REFRESH node identity; opaque numbers/functions have no such metadata. The
production invalid-target arm does nothing. The ordinary accessor path marks,
records its scope, repolls, then schedules, returning undefined.

World.ambientMarks is the module ambient list. Registration captures the current
flush transaction: zero appends ambiently; otherwise resolveTx selects the
recipient and appends to its OptionalIds scope. Duplicates are retained. Marks
never add nodes to transaction membership or hold work. Scheduler.merge appends
to a separate recipient array; an explicit three-transaction native control
confirms later recipient appends leave the retired sender list unchanged.

Landing releases after reruns and before node commits. Each non-store unmark
uses the shared last-mark repoll operation, then the present scope becomes empty
(SomeIds[]), retaining source null-versus-empty behavior. The ambient hook runs
after captured live-transaction selection and before queue stashing. A parked
frame receives the marks; otherwise a live indexed compaction keeps nodes with
their own STATUS_PENDING flight and releases the rest. No user/store callback
can run in this admitted release loop; the live-list control points are kept.
A store slot without STATUS_PENDING explicitly refuses instead of assuming its
unported slot-flight hook returns false.

## Evidence and limits

41 public histories compare counts, node fields, pending verdicts, effect
screens/order, action outcomes, reports and ambient/window restoration. They
cover repeated declarations, action rejection and resumed slices, overlapping
scopes and merges, quiet refreshes, ambient parking, unobserved own flights,
mixed-list compaction, lexical/callback targets and argument side effects.
Public histories total 3,378. Separate private controls compare one merge
sequence and 24 actual declarations with ambient/transaction routing, redirects
and duplicate lists; they are not public lifecycle histories.

Seven scoped quantified laws preserve exact World/list frames for invalid numeric
targets, absent/present scope append, empty release, absent transaction release,
pending-flight short-circuit and empty ambient release. A complete program is
proved for every natural initial value and every budget >=51: construct a data
signal, declare its mark, probe true, flush, probe false and read the original
value. The theorem checks the exact final Machine/World; an array-result
corollary exposes [true,false,initial]. Sixteen native/canonical controls compare
all 51 transitions and exact final Machines at three sufficient budgets.
This does not prove arbitrary async mark lifetimes, graph progress, store behavior
or TypeScript equivalence. Existing complete program domains/budgets remain
unchanged; 72 composed closed regressions are unchanged.

Nineteen additional compiled variants bring the cumulative count to 437 (369
finite-oracle and 68 kernel assertion rejections). A public-only mutation survived
because the action cases did not distinguish direct scope routing from eventual
ambient parking; actual scope comparisons now reject it. Two draft negative
variants failed to compile (type inference and a linear binder); corrected variants
were compiled and semantically rejected before being credited. No adapter refusal,
resource stop or compilation failure counts as a useful rejection.
