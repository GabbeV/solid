# The landing scan retains a group with action debt

This extends the empty-group eligibility checkpoint
`f56f9387043bbd538ab5489a59368d11e2597155`. No runtime, representation, host,
source pin, kernel limit or semantic deviation changes.

`action-landing-scan.bend` proves the actual `Core.landTransactions` decision for
a selected nonzero healthy transaction with a positive current open count. It returns the
**same complete World**, caller stack and seam frame, and continues the scan with
`LandTransactions(frame, index)`. It neither removes the selected group nor starts
its landing/preparation/commit callbacks. Other scan entries may still proceed
according to the source; this does not assert that independent work is blocked.

The second root constructs a `Retained` certificate for the real two-action group
after either first completion, including arbitrary finite original-ID lookups and
same-group rejoins before that completion. The positive count and blocker result
come from the earlier checked constructors/completion, not supplied premises.
The certificate contains the exact machine equality for this source helper call.

The selected live-list lookup **is an explicit premise** in both contracts.
The general active root takes the group as `1 + predecessor`, excluding the
zero fallback returned by an out-of-range list lookup. The constructed target
is already nonzero by allocation. A
complete reachable live-list/forest invariant is still missing, and these roots
do not silently assume it. Initial health means `B.ok == true`; neither a scheduler
progress claim nor external host fairness follows. This is one actual helper
boundary, not a complete public flush/rendered-publication theorem.

## Validation and limits

The independent kernel checks both new roots and the existing composed proof set.
Private controls now invoke the actual Bend landing scan 288 times with held
positive groups, asymmetric work vectors, arbitrary frames and nonempty caller
stacks. Every call retains the whole World and correct next scan task. These
fixtures already have paired native blocker/join observations, but the additional
scan calls are Bend helper controls, not public native histories or direct native
scan equivalence tests.

Another 48 existing paired empty-group fixtures execute the actual Bend false
branch: it removes the selected live group and enters `LandNodes`, preserving
other World fields and the caller stack. These are **finite supporting controls**.
A direct general theorem that selects the empty landing/preparation branch hit
kernel fuel while expanding the preparation call; it is not active or credited.
The checked general empty-group eligibility result remains unchanged. Completing
this landing path and then handling nonempty owned nodes/flights are still needed.

A mutation that removes a still-blocked group is rejected by the independent
kernel. Configuration is 589 variants (469 finite /120 kernel); there is no fresh
complete 589 sweep. No resource failure is counted as a semantic rejection.

Current next is `b4d8e6bb0b838170ddc38dad512958d0b3683244`; the new commits add the
canvas example and change no signals sources. A fresh `upstream:impact` comparison
against its fetched source snapshot reports zero changed signals files. PR
[#4248](https://github.com/solidjs/solid/pull/4248) remains open and separate.
No new Solid bug or semantic workaround was introduced.

Exact hashes/logs are in [the receipt](reviews/action-landing-scan-validation.json).
