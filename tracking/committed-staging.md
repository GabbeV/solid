# Staging and ordinary setters preserve committed observations

This extends `cd4e33dacca1b654a90a51c8f9c35aad10fe7115` without runtime, host,
representation, source, toolchain, kernel-limit or semantic-deviation changes.

The new observation is a pure projection of **all stored committed node values,
the complete rendered text tree and the complete event trace**. Pending values,
notifications, queues, extensions, scheduling requests/reports and faults may
change. This is not a public accessor read: reader posture may select pending
data, pull computations or join work. The projection does not assert that every
node value alone determines the visible frame; the tree and trace are retained
explicitly.

## Source operations covered

Six roots, with reusable field/storage contracts, establish:

- Actual intrusive mark traversal preserves that observation for every finite
  work list, World and fuel, including exhausted paths. Heap insertion, bucket/
  pointer updates and subscriber notification use the same checked contracts.
- Actual `Write.stageResolved` preserves it for every represented payload and
  finite node/link storage. Existing staged-value stashing, promoted-write
  bookkeeping, pending replacement, clock/notification/heap and schedule branches
  are included rather than replaced by a single pending-slot assignment.
- Actual direct `Write.setResolved` preserves it, including held joins and default
  equality suppression/staging. Its explicit unsupported-custom-comparator fault
  is part of this helper's domain, not a model of a user comparator callback.
- The active core **post-updater ordinary setter branch**, with no lane override
  and zero custom comparator, preserves the observation and returns the actual
  resolved argument on its machine value stack. The caller continuation and
  preceding stack remain as stated by the exact machine contract.
- An arbitrary finite sequence of actual stage/resolved-setter helper events
  preserves the observation while carrying the real World between events.

Payloads are arbitrary `R.Value`, including opaque/function/async tokens as data;
no arithmetic or natural-number stand-in is used. This does not validate arbitrary
arena tokens or execute arbitrary JavaScript functions. The frame laws apply even
to malformed/exhausted storage: they prove preservation, not well-formedness,
success, callback termination or eventual publication. No loop bound was raised.

`committed-storage-frame.bend` proves existing-slot/list observation preservation
against the generated record setters. `heap-committed-frame.bend` handles the
actual finite mark/heap paths. `staging-committed-frame.bend` covers the source
staging locals and return points. `setter-committed-frame.bend` includes actual
redirect/merge/allocation/held-join steps. `ordinary-setter-frame.bend` supplies
the active machine bridge, and `staging-write-history.bend` gives list induction.
These proof decompositions are checked against unchanged source operations; they
are not another scheduler or execution witness dump.

## Relation to the held-action target

The [pending graph contracts](rendered-list-construction.md) prove when a group
is retained. This extension proves the complementary local fact that writes and
notification bookkeeping do not themselves publish committed content. It does
not yet prove preservation of the full pending-graph/membership invariant through
those writes, execution of queued flushes, coordinated final commit, the complete
action/flight/result protocol, or fairness. Custom comparator callbacks, updater
execution before this boundary and lane/override writes remain separate paths.
The finite history does not silently drain a host job between its source-helper
events.

## Validation

All new modules and composed roots pass the independent kernel. The existing 203
differential graph/write scenarios and 68 native Promise histories pass; these are
retained evidence, not new history-count credit. Two kernel negatives corrupting
committed values in actual pending/flag record stores and a finite control that
commits an action proposal during staging are rejected. Configuration is 600
(475 finite /125 kernel), without a fresh complete sweep. No new Solid bug or
semantic workaround was introduced. Exact evidence is in
[the receipt](reviews/committed-staging-validation.json).
