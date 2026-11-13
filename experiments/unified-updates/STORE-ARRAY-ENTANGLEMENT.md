# Next array coordination audit — 2026-11-13

## Current user rulings and implementation status

- Writes before the initial answer discard their proposed values but retain
  update coordination. Immediate discard must not let an incoming answer publish
  ahead of the writing update. This supersedes the immediate-drop recommendation
  in STORE-COORDINATION-REVIEW.md. Existing observedness rules remain applicable;
  this does not require waiting for work with no observers merely to retain a write.
- Unresolved store derivations follow next's pending rule. Implemented here by
  removing the descendant-override bypass of the parent input producer. Parent
  pending remains true while a guessed leaf can publish. Known plain-store changes
  remain granular; deep can be pending while the unchanged parent reference is not.
- A more conservative array coordination policy is under consideration, not yet
  chosen. No array runtime policy was changed by this checkpoint.

Pending fix: 13 affected suites / 66 tests pass, including three new regression
cases. Root independently reran those three assertions. Existing consistency
assertions were not weakened. This is focused validation, not a full-suite result.

Initial-write coordination has a bounded real-core harness trial, not an integrated
setter implementation. Holding the actual input producer in the writing update
keeps an early answer hidden, including when the first reader mounts afterward.
No render-transaction search is needed. Ordinary chained-child writes and optimistic
root writes need separate entry hooks sharing the coordination operation. Chained
array methods reading unresolved length before writing still need integration
coverage. seedLoadingValue is an explicit initial commit, a distinct case.

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

## Conservative options still needing a choice

One candidate is to keep existing-index writes granular until an array structure
change occurs, then join that update with all active edits on the affected array.
Incoming array derivations must also participate when they threaten that structure.
The simpler, more conservative alternative joins every write to the same array.
Neither requires pretending a setter guessed untouched values or replaying setters.
Both are broader than next's actual setter behavior above. Equal writes, pure
row-field updates, same-question refreshes, and nested/chained topology need explicit
tests before claiming a finished rule. No performance/size result is claimed.

Receipts are in the store-array-rules-and-pending checkpoint archive: exact source
hash, source/test paths, matrices, rendered flags, initial-coordination trial,
and pending-fix commands/results.
