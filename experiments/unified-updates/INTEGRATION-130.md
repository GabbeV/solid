# Prepare a published observation's incoming value for waiting consumers

## Runtime repair

The #4544 completion failures exposed a coordination cycle. An incoming session
update mounts a branch. A memo affected by pending/latest has already published
its view of the old session, so the new branch reads “signed out” and suspends
on a request for that case. The coordinator postponed replaying that memo until
the incoming update was ready, while the branch's request kept it unready.

The coordinator can now replay a settled, published memo when a pending render
consumer in the incoming update needs it. The graph walk follows current
subscriptions and stops at active optimistic/observation boundaries. It uses
existing subscriptions and replay lists, adding no persistent node fields or
cache. Unfinished higher proposals remain excluded from early replay. The
ordinary blocker and publication checks are unchanged: this prepares the
incoming proposal; it does not grant permission to publish pending content.

Two broader trials were rejected. Replaying every settled stale memo could
loop. Replaying only when a lower computation directly read the memo missed
consumers already waiting on the old value. Neither trial is retained.

## Observable regression coverage

The new JSX tests use a sign-in button, a pending-derived params memo, a profile
request, and a Show mounting reviews inside Loading. The button's disabled
state observes the same params output. Both direct and wrapped pending reads
are exercised, with synchronous or asynchronous member reviews:

- Initially: `0:guest`, `signed out`, button enabled.
- After clicking: keep the guest frame, button disabled.
- After profile completion: synchronous reviews publish the member frame;
  asynchronous reviews keep the complete guest frame until their own answer.
- Finally: `1:member`, `reviews`, button enabled. A late guest-review answer
  changes nothing.

Before the repair, both synchronous versions remained stuck. They pass on
pinned next `4fe75321`. The asynchronous variants expose a next difference:
next publishes `1:member` with an empty review binding before reviews answer.
The experiment retains the old complete frame. The tests keep the stronger
publication requirement; they do not copy that intermediate next result.

The diagnostic run of all original #4544 scalar timelines now passes every
completion assertion. Ten original scalar assertions and six JSX assertions
still fail on intermediate calculated values. They remain unchanged pending
migration review. This is separate from the fixed completion bug; those tests
are not silently marked passing or skipped.

## Validation and remaining work

- Full signals: **5,204 passed, 2,116 failed, 2 skipped**. No new failures
  against stage 127. Seven repairs are the stage-128 fixtures; two are the
  #4544 latest cases. Six new passing tests are the stage-129 store-seed guards.
- Full web: **1,600 passed, 135 failed, 1 skipped**. No new failures against
  stage 125. Four old failures now pass; eight new tests were added since then.
- All existing unified scalar regressions and #4677 pass. The four new JSX
  cases and both #4677 JSX cases pass against rebuilt signals.
- All build tiers, declaration generation, both production purity checks,
  and the rules index check pass.

The archived failure inventory identifies explicit/dependent deferred APIs,
the known first-proposal bug, and #4544's remaining calculation expectations.
Everything else remains explicitly untriaged, not an accepted semantic change.
The first-proposal/store-ownership issue from stage 129 remains unresolved.
Optimistic stores and until remain deferred. The test matrix is not a proof of
complete scalar correctness.

## Cost

No performance benchmark was run in this correctness pass. The new graph walk
is confined to blocked updates with observation replay work; normal settled
reads acquire no field, branch, map lookup or allocation from this change.
Existing bundle harness, minified / Brotli bytes:

| Import scenario | next `4fe75321` | Experiment |
| --- | ---: | ---: |
| Ordinary core | 19,825 / 7,421 | 21,153 / 7,904 |
| Ordinary store | 43,868 / 15,089 | 45,222 / 15,513 |
| Pending/latest | 33,615 / 12,239 | 35,152 / 12,571 |

Ordinary scenarios are unchanged from stage 125. Pending/latest adds 311
minified / 77 Brotli bytes in this pass. Existing size caps still fail and
were not raised. Active observation cost needs measurement and further
simplification; this checkpoint is not a performance or size acceptance claim.

Receipts and rejected trials are in `results/integration-stage130/` and its
separate checkpoint archive. The JSX tests use the same installed rc.21 native
compiler for the experiment and pinned next.
