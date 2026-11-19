# Pending mounts retain their creator's publication hold

This checkpoint repairs an ownership-scope bug in the real core, migrates one
Loading assertion under the accepted creator-retry rule, and corrects a local
dependency mismatch. The comparison remains next
`4fe75321d61f9e4f1e1c63edc2087d099a36e9e1`.

## Failure and repair

A retained pending Loading branch kept the optional coordinator active. In
another root, a route mounted a component wrapped in a synchronous memo. Its
user and info bindings suspended, but the wrapper's local calculation restored
the outer update after acquiring its own hold. The wrapper itself had consumed
no proposal, so it published its DOM value immediately. The route could then
attach `"'s Profile"` with neither user nor info ready, instead of retaining Home.
Without the other active root, the ordinary ambient scheduling path held it.

An uncaught first render binding now marks its actively computing creator as
joined when that creator's active ancestry consumed unpublished inputs. The
existing value staging, transaction hold, and proposal read machinery then carry
the mount's hold out of the local scope. Loading catches pending before this
path, preserving its deliberate boundary. Initial setup without unpublished
inputs remains eager: an initial trial marked every creator, which broke the
untracked initial error-boundary construction in #4639. That trial was narrowed
using the existing `creatorReads` check; the twelve #4639 cases pass.

The check is gated by the optional coordinator and runs only on uncaught
pending notifications. It adds no node fields, allocations, global registry, or
ordinary settled-read work. It does not forward observedness through optimism
or merge unrelated roots. The new JSX regression completes the route while the
first root remains pending, then completes that first root independently.
Twenty-four additional JSX controls cover direct, memo, two-memo, and cached-lazy
component wrappers, with optional pending text/attribute and ordinary text.

## Other reviewed failures

The Loading navigation assertion now retains page A with its button disabled
until page B's data is ready. Its new pending observation retries the private
keyed creator on committed page A, matching the accepted creator-retry rule.
The final B content and enabled button remain required. The test now disposes
its root even when an assertion fails. Previously its leaked pending root
exposed the separate route defect in two later tests; fixing cleanup alone
would have concealed that defect. The new regression deliberately retains a
live pending root and verifies the repair directly.

Both serializer failures reproduced unchanged on next. The installed workspace
links selected Seroval/seroval-plugins 1.6.7, while the checked-in manifests and
lockfile require 1.7.0. Correcting the local dependency links to 1.7.0 resolves
both failures in both checkouts. No serializer implementation, test assertion,
manifest, or lockfile changed. The archive records old/new dependency links and
the next control, whose route setup uses next's existing fallback behavior.

## Validation

- Full signals: **5,757 passed, 1,959 failed, 2 skipped**. Six non-deferred
  failures remain in #4491; 1,953 require deferred optimistic stores or `until`.
  No new failing identities after narrowing the creator check.
- Full web with the required Seroval version: **1,766 passed, 115 failed,
  1 skipped**. All remaining failures require deliberately deferred APIs.
- Next control with corrected dependencies: **46 passed**, including the
  independent route and serializer cases. Temporary baseline fixtures removed.
- Production DOM controls: **25 passed** against built production signals,
  Solid, and web. An initial configuration mixed development Solid with
  production signals and failed during setup; that is not a test result.
- Type generation and both bundle purity checks pass.

The full runs precede the final optional-coordinator guard, which removes the
new branch entirely from ordinary-only bundles. Focused source and production
controls validate that final guard. No throughput claim is made. The pending
path reuses existing ownership traversal; sync paths remain unchanged.

Shipped scalar scenarios (minified / Brotli bytes):

| Imports | Next | Experiment |
| --- | ---: | ---: |
| Ordinary core | 19,825 / 7,421 | 21,456 / 8,056 |
| Optimism | 30,556 / 11,180 | 37,186 / 13,425 |
| Observed optimism | 35,643 / 12,920 | 43,303 / 15,293 |

The ordinary-only scenario is byte-for-byte the previous checkpoint's size;
the optional pending repair adds 72 minified / 8 Brotli bytes to optimism and
70 / 32 to observed optimism. These are still larger than next, not acceptance
claims.

Six signals failures still need analysis: three callback-order comparisons,
one superseded intermediate publication, one obsolete verdict-flag assertion,
and one equal-result callback comparison. These are descriptions of the current
differences, not permission to discard their consistency requirements.

`checkpoints/integration-stage180.tar.xz` preserves trials, traces, full reports,
dependency correction controls, production checks, and bundle measurements.
