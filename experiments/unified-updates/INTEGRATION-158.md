# First-value read assertions and callback timing

No runtime change. Close two failures without relaxing publication consistency.

The #3712 adoption fixture creates a memo of an unpublished store leaf during
an open action. Its imperative plain read already expects NotReady, but its
imperative latest read expected the unpublished first proposal. Apply the
accepted committed-view rule to both reads. After release, assert that both
read 1 and pending is false. The reactive latest/store tests elsewhere in the
same file are unchanged; this does not waive the #4429 reactive first-proposal
bug.

The #4362 first-value matrix used a catch helper that returns the string
`throw:NotReadyError`. An imperative read of its new memo wrapper can itself
throw before that wrapper publishes, so inspect it through the same helper.
The render-effect row now records the read inside the computation rather than
waiting for publication of that artificial string. All nine read shapes still
must report NotReady. Strengthen the neighboring uncaught-read control to
assert that its render callback receives no value at all before an answer.

A trial removing the catch from that row held a newly created tracked effect
in both runtimes, changing the matrix's collection timing. It was not kept.
This is not a deferred tracked-effect API: the tracked row executes and passes
in the retained fixture. The existing catch helper is diagnostic test code,
not a supported application pattern for handling suspension (D-42).

## Validation

- Both full scalar files: **21 passed / one failed**. The sole failure is
  the existing optimistic-store stub; the original run had three failures.
- The two changed #4362 read/publication controls pass on pinned next
  `4fe75321`. The file's two previously migrated error-publication tests still
  differ from next and are unrelated to this pass.
- All three affected controls pass against the rebuilt, mangled production
  package. Runtime/build artifacts remain stage 157.
- No full-suite rerun for assertion-only changes. Relative to stage 157,
  two more known signals failures are closed: 2,020 remain, including 1,953
  deferred APIs. Web is unchanged.

Receipts and the unretained collection-timing trial are in
`checkpoints/integration-stage158.tar.xz`.
