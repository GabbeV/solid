# Held signal staging and snapshot preservation

This closes held-entry/staging dependencies of finite setter bodies. Runtime,
source pin, host grammar and checker remain unchanged. It does not extend the
ordinary-body theorem to arbitrary held bodies or establish publication.

The ordinary profile excludes `CONFIG_HELD`. Actual held setters first resolve
and join the source group. Already-staged writes outside a running pass also
call `stashFlushed`. Treating that path as ordinary would miss both operations.

## Quantified operation contracts

`held-setter-entry` follows actual `txOf`, its cache store, resolution, `joinFuture`
and the same-component merge guard. If a source cache already names a positive
terminal group equal to the current flush group, the operation equals the normal
conditional scheduling step. The full World is otherwise unchanged, including
all group counts. This is an explicit canonical-cache/current-group domain;
redirecting caches or distinct-component merges remain separate compositions.

`held-stash-frame` observes the complete World after clearing only the selected
extension's `flushed`/`flushedAt` fields and `unflushedStaged`. It retains every
other extension, in-flight identity, error, pending-source count, provenance,
group cache, nodes, queues, actor/wait record and fault. For a nonzero extension
pointer, actual `stashFlushed` preserves this observation. This safety claim does
not turn an out-of-range list store into a successful snapshot write.

`extension-store-lenses` derives successful reads and retained membership from
an initially valid extension slot. `held-stash-snapshot` uses them to prove that
the saving branch stores the actual pending slot and current clock. If the
snapshot already matches the clock, the actual helper is exactly the original
World. No final snapshot, count or successful-store premise is supplied.

`held-stage-intake` covers both queueing the first pending write and the held
snapshot branch. It retains actual nodes and links and derives the next budget.
`held-stage-health` then constructs a subscriber path for the post-intake World
from its unchanged link storage. The existing real tail/heap/walk contracts apply
to that World, retaining fault and all outer controls while permitting the two
snapshot fields to change. Input facts are a valid plain signal, context zero,
inactive recursive marking, a finite actual subscriber path with sufficient
arena budget and a nonzero extension pointer. Successful traversal/health is not
an input premise. Assigned values range over all represented `R.Value`.

`held-stage-topology` separately retains kind/configuration/subscriber shape and
links. `pointer-store-frame`, `pointer-heap-frame` and
`pointer-notification-frame` prove that every extension identity survives the
actual node/heap/notification stores, including bounded exhausted walks. These
are separate from the earlier shape observer, whose allocation domains still
permit extension pointers to change. No old domain was strengthened silently.

The held outer observation masks the ordinary ten staging/scheduling fields and
only the selected extension's two flushed fields. It retains the full transaction,
action and wait arenas. A snapshot save therefore cannot conceal a lost flight,
changed error or wrongly retired obligation behind this observation.

## Evidence and limits

Six composed roots extend the preceding668-root book to674; the fresh independent
whole-book verdict and exact input hashes in `tracking/checked.json` establish
checkpoint credit. The eleven operation modules individually pass the unchanged
independent checker in approximately1–2.3 seconds, within the existing90-second
and4GiB probe limits. No checker/runtime modification or resource-stop credit is
involved in this extension.

Finite controls cover1,352 helper combinations across13 represented payloads,
first/already-staged input, running/idle and cached/new snapshot branches. They
include676 new snapshot saves and676 exact cached identities. Thirty-two
independently authored native Solid/port joined-action programs cover both
completion orders, caught rejection,0/1/4/16 resumed writes and an optional live
rendered flight. They execute336 writes after resumption. These finite public
controls do not prove the admitted private states are all publicly reachable.

Seven runtime-only kernel fault probes check flight preservation, pending rather
than committed snapshot data, clock stamping, group debt, join scheduling,
canonical transaction cache and extension identity during heap insertion. The
unchanged oracle must pass, every mutant must compile and every rejection must
be a semantic failure. Configured712 variants and earlier complete frozen sweeps
are distinct scopes; see [verification.md](verification.md).

Still open: preserved held-body certificates through repeated setters and real
method return, construction from public invocation/parking, redirecting caches
and distinct group joins, source-wide forest bounds, the global once-only
flight/action ledger, disposal/supersession and rendered publication. The ordinary
finite-body result retains its original domain.
