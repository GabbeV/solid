# Retain an optimistic scope's own input flight without readers

The user chose next's behavior after locating the explicit last-observer ruling
in PR #3347. Removing the last rendered reader need not complete an existing
update early. This supersedes the observer-removal exception retained in stage
79 and resolves stage 113's own-input lifetime question. Baseline remains next
`4fe75321`.

## Evidence and decision

The original report changes an ordinary signal, starts an async memo, and removes
its only rendered reader after 500 ms. The source remains held until the request
finishes at 1500 ms:

- [Original report and JSX](https://github.com/solidjs/solid/pull/3347#issuecomment-5625014277)
- [User's conclusion that early release is optional](https://github.com/solidjs/solid/pull/3347#issuecomment-5625179393)
- [Response from Ryan's account, signed Claude via Cursor](https://github.com/solidjs/solid/pull/3347#issuecomment-5626413374)

The response says: "Releasing the update early when its last reader leaves would
be an optimization with no coherence benefit, and it is not one we want to take
on here."

Our current optimistic reproduction has a different graph but demonstrates the
same optional early-release question. The user explicitly chose to follow next,
keeping this orthogonal lifetime behavior outside the experiment's changes.
The prepared issue is abandoned and was never submitted. Its saved form and
playground receipts are historical evidence, not an outstanding filing task.

## Implementation

`pendingScope` checks the scope's guessed inputs for pending work without testing
whether their outputs still have rendered readers. It adds no state and removes
an observedness traversal from this readiness check. Ordinary synchronous paths
are unchanged; no new performance or bundle-size claim is made.

The existing disposal test now requires the source to remain at 0 after the
reader is disposed, then publish 1 when the input answers. It also verifies the
disposed reader is not called again. This changes the lifetime assertion; it
does not relax publication consistency. Overrides still cut input demand, and
obsolete downstream optimistic work is still superseded rather than awaited.

Validation receipts are in `results/integration-stage114/`.

## Validation

- The 13 focused signals tests pass, including pending feedback and the revised
  closed-action disposal case.
- The complete signals run has 5,083 passing results, 2,179 failures, and two
  skips. Compared with stage 112's last complete run, two existing #4690
  failures now pass, stage 113's four added feedback tests pass, and the renamed
  disposal test passes with its approved expectation. No other status changes.
  All 15 scalar #4690 cases pass; its 30 optimistic-store cases remain failing.
  Existing failures remain visible and are not classified away by this change.
- A new JSX test reproduces the no-action playground: `setId(1); guess(3)`,
  remove the `Show` reader, then resolve the input. It verifies guess 3 / source
  0, reader absent / source 0, then reader absent / source 1. It passes with the
  actual built experiment runtime and the repository's web test configuration.
- All signals build tiers, property mangling, pure checks, and declarations
  pass. `git diff --check` passes.

The installed workspace compiler lacked its native binary. The JSX check used
the already downloaded rc.21 native compiler binary through a temporary symlink
in that compiler package, removed after the run. No compiler or dependency
changes are retained. Vitest was invoked directly because `pnpm exec` attempted
an install and rejected the workspace's shared dependency-directory symlinks.
