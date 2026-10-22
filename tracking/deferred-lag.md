# Deferred lag dependency walk

Update: the [public data/thenable constructor](deferred.md) now consumes these
helpers, sharing one arena Set and installing cleanup/observer/watch crossings.
The dependency-only descriptions below record the earlier milestone; direct
streams/from/store/boundary profiles remain unfinished.


This is an internal dependency checkpoint, not public createDeferred support.
The constructor's loading window, ask/serve/land callbacks, flight marks,
stream-first-yield lifetime, disposal and watcher integration are still unfinished.
Nothing installs the lagging hook into the admitted public engine yet.

runtime/deferred-state.bend follows deferred.ts lagOf and the installed
GlobalQueue._lagging arrow for non-store nodes. An explicit membership list is
the module Set's view supplied by its future lifecycle caller. The walk returns
the first lagging node identity, not merely a pending boolean. Membership
precedes the shared seen guard; dependencies run depth first in source order.
Only the validated prefix is visited during recomputation. A zero validated
tail means no dependencies, while outside recomputation the full chain is used.
Ordinary errors do not stop this walk (unlike mark coverage). Slot-family
recursion remains an explicit Unsupported86 refusal when that branch is reached;
empty-module, direct-membership and seen short-circuits precede it.

4,210 actual source function/installed-hook comparisons cover chains, diamonds,
multiple lagging candidates, cycles, repeated visits, error nodes, dependency
prefixes and store-flagged short-circuits. Every successful comparison also
checks that the complete World is unchanged. These are private helper controls;
they do not increase the 3,378 public-history count or prove deferred lifetimes.

Eight exported quantified properties check empty work, empty module state,
explicit budget exhaustion, direct identity, membership-before-seen, exact tail
cutoff, empty dependency return and the general World frame. The last is proved
by fuel induction for arbitrary typed Worlds, graphs, lagging sets, work lists
and seen sets: every World field except the fault result is preserved, including
on exhaustion or refusal. It does not prove sufficient budgets or traversal
correctness/termination for arbitrary source graphs. Choice-frame and fault-frame
lemmas are checked auxiliaries; no alternate runtime traversal is supplied.

Twelve new compiled variants bring totals to 449 (378 finite and 71 kernel
assertion rejections). They target direct identity, order, cycles, prefixes,
error traversal and whole-World preservation. Existing public, closed and
complete-program proof domains remain unchanged. No upstream bug or semantic
workaround was introduced by this dependency checkpoint.

examples/pending.bend is an executable consumer of the already admitted
signal/latest/isPending/affects APIs. It prints false, true, 41, false, 41 and
Healthy. It demonstrates mark-before/after-flush behavior, not createDeferred.
