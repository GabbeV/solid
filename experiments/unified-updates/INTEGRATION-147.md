# Park node-less store writes before changing update context

An untracked ordinary store property with neither a property node nor a
container node could read the lower update's uncommitted value while a pending
observation selected a higher update. Signals and stores with nodes selected the
committed value. The published pending view was therefore `true/1` while the
outside count still read 0.

The store parking hook used to run only at the later scheduler seam. Move it
into the common operation that parks the entire ambient update, before another
context executes. This gives node-less staged backings their existing container
home at the same point scalar proposals acquire an owner. Scoped computation
suffixes still park only their own nodes; they must not adopt unrelated ambient
store writes. No new node field or ordinary read-path condition is introduced.
This can scan store folds earlier during active coordination; its performance
has not been measured here.

## Regression and expectation migration

Twelve new tests cover pending-first and count-first reads over signals,
untracked signals, and four store subscription arrangements. They assert the
complete render-publication sequence:

```
data=0, pending=false, count=0
data=0, pending=true,  count=0  // data's replacement is suspended
data=1, pending=false, count=1 // after the controlled answer
```

The two node-less store cases failed before the runtime change; all twelve
pass after it. Outside reads are also checked during and after the hold.

Migrate the 23 S9 parity assertions to the already accepted whole-computation
context rule (stage 141). Reading an observation through a memo and reading it
inline select the same update. Pending can publish above its held input and
uses committed lower count=0. Keep complete calculation traces and exact
publication sequences, plus the checks that the intended store nodes really
are absent. The last five cases now assert the entire frame sequence rather
than only one trace substring. This does not waive the separate remaining
calculation-count failures.

## Validation

- Full signals before expectation migration: 5,356 passed / 2,075 failed /
  two skipped, including the twelve new tests. Identical old failure set.
- Full signals after migration: **5,379 passed / 2,052 failed / two skipped**.
  Exactly the 23 S9 failures are removed; no new failures.
- Focused runtime trial: **692 passed**, including all 654 unified-update
  cases and the 26 derived-store/manual-write guards.
- Production-mode source tests: **83 passed / five deferred optimistic-store
  failures** across the new tests, parity file and store guards.
- Normal build, property mangling, purity checks, declaration compilation,
  rules-index validation and diff checks pass.

- Full web against the rebuilt artifacts: **1,680 passed / 129 failed / one
  skipped**, with the same failure set as stage 146.
- Remaining signals inventory: 1,953 deferred API cases, 83 untriaged,
  twelve calculation expectations and four implementation bugs. Web remains
  115 deferred API, eight untriaged and six calculation expectations.

No new semantic ruling, performance result, bundle-size claim, or optimistic
store implementation is included. Receipts are preserved in
`checkpoints/integration-stage147.tar.xz`.
