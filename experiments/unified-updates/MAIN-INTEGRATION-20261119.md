# Upstream integration pass

The integration tree starts at solidjs/solid main `b884d6ea8`. The original experiment checkpoint is `7f13137f8`. The common ancestor is `4fe75321d`. The trial applies the net experiment changes on top of main in a separate worktree.

An unmodified main Signals run passed 7,237 tests with two skips. Running main's newly added Signals tests against the pre-integration experiment gave 238 passes and 231 failures. Those counts measure differences that preceded the port. They are not a validation result for the integration tree.

Four variants of the new async read-ahead matrix reproduce a consistency failure in the integration tree. With a memo containing just `latest(id)` and a second memo fetching its result, the display reaches id 1 beside the answer for 0. The same four fail on the original experiment checkpoint. Keep the upstream consistency assertions.

A separate compatibility decision concerns an imperative latest read during correction. Start from 0, display guess 5 and its completed detail, finish the action body and let its refresh answer 6. While detail(6) is outstanding, both production builds display 5 and detail(5), and a standalone reactive latest binding displays 6. An imperative latest read at this point returns 5 on main and 6 on the original experiment. One guess suffices. Original upstream tests use two overlapping guesses. The accepted experiment behavior is 6. Lazy allocation should be invisible. Ordinary readers still publish 6 together with its detail.

The integration is provisional. Keep the published branch as the recovery point until the port and its test differences have been reviewed. Defer until as before.

## First-use verification

An isolated production probe allocated and read the normal latest companion early, without adding a downstream subscriber. The cold control first read latest at the observation point. For a first async answer 1 held by another reader, the cold path threw NotReady and the early companion returned 1, both before and after a re-ask. The input had retained the answer. The revised first-read guard allows that existing staging to initialize the companion.

In a separate action, an initialized memo with published value 100 produced either 101 or error E1. A new question arrived before publication. Both early and cold companions retained 101 across the re-ask. Both returned 100 after the staged E1 was cleared. Upstream main still throws E1 there. The failing held-error T2 regression in lean.test.ts tracks this distinct loss of error history. No performance benchmark was run for this verification.
