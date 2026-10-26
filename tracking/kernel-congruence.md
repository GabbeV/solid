# Checking composition without expanding matching calls

The pinned BendTT kernel tries weak-head reduction before congruence, except for
already identical syntax. A small open-term reproduction in
`experiments/checker-congruence/repro.bend.txt` exhausts its 400,000,000-step budget:
two calls have the same function and convertible arguments, but the checker
expands the function before checking those arguments. The analogous action
delivery/resume equality expands the symbolic transaction join and stops too.
Replacing the join with an identity in an isolated diagnostic copy removes the
cost. No such substitution was applied to the runtime or counted as proof evidence.

`tools/kernel/congruence.patch` first tries congruence for calls with the same
reference or variable head. It checks all corresponding parts and falls back to
the existing reduction algorithm when that attempt fails. Both attempts consume
the same original fuel budget. The declarative conversion relation and theory
are unchanged; the bounded checker can finish conversions that previously exhausted fuel. No new axiom,
equality rule, runtime operation or admission is added. The patch also updates `conv_sound`; the complete Lean development,
including checker soundness and consistency, checks successfully. Axiom audits
for `conv_sound`, `book_check` and `consistent` retain only `propext`,
`Classical.choice` and `Quot.sound`.

## Reproducible profiles and current integration state

The vendored Bend 2.0.37 snapshot stays byte-identical. `tools/kernel-profile.mjs`
applies a hash-pinned patch to an isolated build copy, checks the resulting source
hash, compiles the whole Lean file and audits the named theorems. It records
compiler identities and source, audit-log and executable hashes; cache reuse
revalidates those artifacts. `baseline` remains available separately.

The current default is `same-head-congruence-v1`. Both `tools/check.mjs` and
selected-module verification choose it explicitly and revalidate its artifacts.
The composed seal records the profile, complete build receipt and selected source
hash. It checks exact equality of composed law and filled-proof name sets, rather
than trusting a count alone. The baseline622-root seal remains at checkpoint
`6b76b664`; new general dispatch roots need the optimized checker. The standalone
pinned CLI is unchanged. `BEND_KERNEL_PROFILE=baseline` selects the original kernel
in repository verification tools and may still exhaust fuel on new compositions.

```sh
node tools/kernel-profile.mjs same-head-congruence-v1
node tests/kernel-congruence.mjs
npm run check
```

The raw-kernel controls accept six positive cases, including fallback after a
failed argument comparison, and reject three false equations introduced after
frontend checking. Resource stops do not count as rejections. The candidate
checked all622 previous roots. [The complete678 receipt](reviews/complete-678-congruence-negative.json)
now verifies484 finite and194 kernel variants on frozen27f8 with all1009 sealed
inputs unchanged and Git-tracked. Its declared optimized executable is byte-identical
to the managed build. That frozen checkout's original positive seal still used
baseline; the receipt explicitly records the optimized checker as an extra input.
Four newer focused variants are separate; current682 is not claimed as a fresh
complete sweep. [The candidate receipt](reviews/kernel-congruence-candidate.json)
retains the earlier research stage and timings, which are diagnostic rather than
controlled performance comparisons.

The recovered [first-callback composition](action-method-first.md) is now active.
No previously stopped proof was assumed true. Further pending-status/controller
recoveries remain isolated until separately integrated and sealed.

No upstream Bend issue or PR was filed. When upstream provides equivalent
conversion efficiency, recheck the same statements and negative controls against
that version before retiring the local overlay; preserve these receipts.

An independent proof dependency improvement moves terminal-retirement corollaries
from `action-helper-context.bend` to `action-retirement-context.bend`. Generic
callback-table frames no longer import retirement/output proofs. All existing
composed theorem names and domains are retained. This changes proof dependencies,
not source implementation boundaries or scheduler behavior.
