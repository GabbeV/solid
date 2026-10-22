# Public verdict windows and cold reads

Solid 5b1b7776 (rc.17). Production latest/isPending expression thunks now use
actual window entry, read dispatch, source try/catch/finally and lane hooks.
This follows full lane read/lifecycle/answer/guess/pass/flush integration; no
entry-only public window is admitted. Source remains pinned and no semantic
deviation is active. Boundaries/fresh mounts, stores/folded lanes, snapshots,
spectating and arbitrary host protocols remain excluded.

## Read and callback order

Window entry marks the real tracked reader, including root forwarding, before
capturing globals. latest changes only latestActive and dispatch; isPending
changes only probing, probeFound and dispatch. Their finally stores restore the
captured fields while retaining other live fields. isPending returns the live
found flag, ignores its thunk result, contains ordinary user errors, and only
rethrows loading NotReady when nothing pending was found and context is owned.
Internal adapter refusal faults remain refusals rather than user errors.

read prepares computed nodes first, then dispatches the cold verdict path before
the ordinary fast/slow choice. verdictValue captures owned/tracked posture,
links, and disables verdict dispatch around a tracked pull; successful return
sets it back to the verdict reader. That source return point has no invented
finally. Windows restore their caller's dispatch on unwinding. A shared pull
helper retains source height/update order; the plain read's F-6 verdict carry
is a separate return choice and is omitted on the verdict path. Existing
ordinary constructor/drain task budgets remain unchanged.

The read checks the active marks hook before override classification. Guesses
serve their raw slot and use raw comparisons against held truth; derived lanes
choose screen versus latest with their own flight guard. Held reads preserve
the blocked-verdict render screen, verdict lane routing, raw held-finality call,
proposal selection and imperative action joins. Born-held stagings, provisional
seam verdicts, unflushed late-linkers, pending/loading linking and raw error
throws retain their source order. staged errors do not become ordinary values.
Folded callbacks and spectating cannot be installed by this non-store grammar;
they remain explicit exclusions, not replacements of their source behavior.

## Evidence

104 new public histories bring the total to 3,337. They compare payloads,
compute/read/apply order, source node fields, effect screens, reports, action
outcomes and ambient/window restoration. Cases include nested windows, loading
inside/outside owners, pending/error landings, lazy pulls, root forwarding,
readers born after writes, callback/local binding, optimistic guesses and
imperative reads between overlapping actions. Untracked loading still links its
reader and wakes it when the source lands.

5,322 actual verdictValue programs compare the complete read return and node,
heap, lane, queue and transaction mutations. Eight dirty-memo cases additionally
compare the actual body-entry dispatcher: the source _fn records its installed
reader and Bend pauses at that same Evaluate boundary. 44 separate comparator
controls cover raw truthy/falsey results, arguments, identity, writes/reads,
NotReady and ordinary throws without isSame containment. These private controls
are not counted as public histories or whole lifecycle theorems.

Seven quantified whole-World laws cover normal/throwing latest restoration,
probe return, numeric ordinary errors and the owned/unowned/already-found
loading policies, preserving the caller stack and unrelated fields. A complete
data-signal program is separately proved for every natural initial/write pair
and all budgets >=53: construct, write, latest before flush, public flush and
nested latest/isPending reads, with exact final Machine/World and value
corollary. It uses equals:false and does not prove async or arbitrary graph
histories. Sixteen canonical/native controls check all 53 transitions and exact
final Machines at three sufficient budgets. The unchanged independent kernel
also checks the existing complete signal/memo/history/chain guarantees with
the same domains and budgets. The 72 composed closed regressions are unchanged.

## Corrections and limits

Native comparisons caught a draft call to the raw marked helper that omitted
the installed hook's global active-count guard; it now calls covered. Source
review also found that reusing the plain height helper would perform the extra
F-6 carry. A dedicated control failed before the return paths were separated.
A surviving pull mutation exposed that output-only examples had not forced a
memo body through that pull: the body-entry controls now reject it. One negative
variant initially duplicated a linear binder; its annotation was fixed before
crediting rejection. None is an upstream bug or a semantic workaround.

24 additional compiled variants bring the cumulative count to 418 (353 finite,
65 kernel assertion rejections). Target validation distinguishes stale controls
from semantic rejections. There is no claim of TS equivalence, full lane
progress, arbitrary async histories, boundary/store/mark-scope APIs or dev/
observe semantics. Public affects/createDeferred, store/folded behavior,
snapshots, boundary/reveal mounting and external source protocols remain next.
