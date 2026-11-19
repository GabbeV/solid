# Next array coordination audit — 2026-11-13

## Current user rulings and implementation status

The user approved rule A: existing-index value edits remain independent; structural
changes join active direct edits on the affected array, and later direct edits join
that structural update. Incoming structural answers participate too. This is full
update coordination, not merely extending optimistic overrides. No setter replay or
implicit endorsement of unguessed values is introduced.

Writes before the initial answer discard their values but retain update coordination.
The input producer cannot publish its first answer ahead of the writing update.
Existing observedness rules remain; unobserved work is not a universal lifetime
blocker. `seedLoadingValue` is an explicit initial commit and a separate case.

Unresolved store derivations follow next's pending rule. The strict input producer
remains the pending authority. A selected descendant can keep a published parent
traversable without falsely clearing pending or exposing an uncommitted input error.
This supersedes the earlier implementation that enforced pending by making published
child values inaccessible.

Implementation checkpoint: setter/incoming structural coordination, single selected
length, pending-selector separation, and initial-write integration are implemented.
Focused receipts are described in STORE-ARRAY-POLICY-A.md. This is unfinished:
`latest` can still combine a lower incoming removal with an active append and expose
a hole; an initial-write regression also finds inconsistent imperative reads after
a held first answer. Neither is an accepted semantic exception. Full acceptance
and performance/size measurement have not been rerun for this checkpoint.

## Pinned upstream evidence

Actual upstream next: 4de85c2b86053b933c3a8268ac5e114e2f85f84e.
66 two-action recording probes (60 matrix cases plus six guards), and 36 incoming
update/mount/chaining probes. The latter 36 have zero changed timelines relative
to edeb5db09. Independent rendered ordinary saved flags distinguish a whole-action
join from retained optimistic values. These are current-behavior receipts, not
proof that the behavior satisfies the user's consistency requirement.

## Setter versus setter

Assume A's guess already published before B starts, with ordinary array iteration
as the reader and no additional reactive graph causing entanglement.

| Operations | Whole action updates join? |
| --- | --- |
| Both change the same existing index | Yes |
| Change different existing indices | No |
| Both grow length, including two pushes | Yes |
| Both change length by truncation | Yes |
| B truncates away an index A guessed | Yes |
| B truncates but keeps A's guessed index | No |
| B grows the array while A guessed a different existing index | No |
| A creates index1 in []; B fills hole0 without changing length | No |
| Delete different indices without changing length | No |
| B computes its guess from A's guessed primitive | Yes |
| Change different fields on an existing row | No |

Thus an actual structural change does not inherently join all live array edits.
Shared changed/deleted keys, including length, explain the basic write conflicts.
Consuming another guess and then writing joins the updates too; latest #4820
extends detection through presence, enumeration, and replaced children. Reads
alone are not themselves the joining write.

A preexisting tracked deep(array) broadens joins: disjoint existing indices,
hole fills, disjoint deletions and fields on the same existing row join in the
tested cases. Writes touch the shared deep notification node. Ordinary iteration
does not have the same effect. The experiment's previously approved independent
deep behavior is not silently reversed by documenting next here.

## Retention is not entanglement

Example: input [a,b], A guesses index0=M, B guesses index2=N. When A ends first,
next can retain M in B's displayed array while A's ordinary saved flag publishes.
The actions did not join; B's stored array retained A's value. This is exactly the
kind of implicit endorsement of an unguessed value the user rejected. It cannot
be justified by a test asserting only that both optimistic values remain visible.

#4814 suppresses borrowed-key fallthrough for key/length changes. Its structural
regression asserts retained list contents but not ordinary sibling writes or both
finish orders. The stronger claim that all structural guesses therefore entangle
does not follow: hole-fill and disjoint-deletion receipts show independent flags.

The audit also records imperative-versus-rendered differences. They are not called
on-screen tearing without testing two ordinary published readers; next has outside
read exceptions. Descendant edits disappearing with a removed/replaced guessed row
are recorded separately and need their own semantic review.

## Incoming derivation versus existing guesses

In the ordinary observed direct-array shape, next joins a changed incoming array
with live index guesses, even for same-length value changes. Nested row-field edits
and disjoint object fields remain independent in the controls. That joining is
reader-driven: no-subscriber and chained-array cases do not provide the same
guarantee. Actual latest repeats all prior 36 timelines. A robust replacement must
establish coordination before input publication, including later mounting and
chained inputs; copying the current read-dependent seam is insufficient.

## Selected policy

Rule A above is broader than next's setter behavior. Same-length key-identity changes
and permutations are structural; same-key content changes remain leaf edits. Pure
nested row-field writes remain governed by their object/property dependencies.
Internal comparison snapshots detect input structure changes; they are never used
as guesses of untouched values. Structural ownership and selected length use the
existing update machinery.

The previous all-writes-to-one-array alternative was rejected as unnecessarily
conservative. Changes to these boundaries need a new explicit ruling.

Upstream audit receipts remain in the store-array-rules-and-pending checkpoint;
implementation receipts are in the subsequent policy-A checkpoint.
