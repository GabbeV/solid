# Solid pin update: 0222d684 to a2a5b6f8

Fetched/reviewed on 2026-10-21. The clean detached candidate is
`a2a5b6f8f54addab694a1040721a86208349b8ea`, the fetched next tip, still rc.16.
The complete previous pin/proof checkpoint is 8032b84 in feature-branch history.
Bend/Lean pins and the empty semantic deviation register are unchanged.

Only one commit is new: #4209 adds the solid-js documentation changeset for
#4183 and re-records the compiled CSR size cap after #4188/#4207/#4176. The final
Git diff has exactly two paths: `.changeset/docs-from-deferred-settled.md` and
`scripts/size/scenarios.js`. Neither enters the signals reference bundle.
No signals runtime, tests, package version, imports or module initialization
changes in the final tree.

[The impact report](solid-a2a5b6f8-impact.json) has zero changed source files.
All 76 vendored Solid inputs were compared with the clean candidate and match
their existing hashes byte for byte. No vendored file, runtime definition or
function mapping was changed, and the source inventory is unchanged. The pin
metadata advances to the reviewed commit; all existing executable and formal
evidence concerns the identical program. The ordinary test suite and independent
kernel are checked again with the new proof checkpoint. Rebuilding/rerunning
upstream's full package suite is unnecessary for this metadata-only commit and
is not claimed. [Validation](solid-a2a5b6f8-validation.json) records the review.

The squashed commit message also describes a tentative drain of lazy releases
collected before a throwing cleanup, then its explicit revert for a size decision.
That tentative runtime patch is absent from the final tree. The translation keeps
#4176's collector restoration and the source's existing exceptional teardown
behavior; no extra drain is inferred from the commit message or silently added.

User-submitted #4211 remains a separate proposed fix. The pinned map guards still
reproduce the successful-falsy-fallback remount. Its helpers remain unported in
Bend, and no temporary workaround or semantic deviation is active.
