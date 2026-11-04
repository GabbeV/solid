# Signed-zero staged reads: upstream fix integrated

The user submitted [#4538](https://github.com/solidjs/solid/pull/4538) for a
staged read returning the committed opposite signed zero after an accepted
signal write. The report's original base was
`6bde511b9e1bcdd10f52a3d855bc4f742caaab93`. The earlier ecf30116 translation
retained its pinned strict-only netting behavior; see its source review and the
historical deferred-payload contract delta.

The fix merged as `50dec1b3a6ff9a8429b704669c990f0d6d00a028`. The current
rc.21 target additionally contains `6b2a19eddde751bc38e61d43093bd66052959004`
(strict equality plus SameValue through staged netting) and
`7d88dd5309d9f1ec265529dd528d740176de9b87` (snapshot reader replay). The
non-store read/verdict branches now follow that source. Snapshot replay remains
outside the admitted snapshot grammar; vendoring the fix is not a claim to have
translated that entire subsystem.

`tests/negative-zero.mjs` now creates real render effects and asserts both
accepted zero directions on observed memo output with equality disabled on both
signal and memo. Disabling the memo comparator matters: its default strict
equality legitimately absorbs equal zero outputs. The earlier invalid `render`
harness command is corrected and does not receive historical observed-render
coverage credit. The generic ordinary deferred payload controls independently
expect the proposed value, including opposite zeros; their proof uses the
source's exact strict-and-SameValue selection.

No local workaround is active. Current verification and its precise scope belong
to the rc.21 migration receipt and matching completed `tracking/checked.json`.
