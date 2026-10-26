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
the same original fuel budget. The declarative conversion relation and theory are unchanged; the bounded
checker can finish conversions that previously exhausted fuel. No new axiom,
equality rule, runtime operation or admission
is added. The patch also updates `conv_sound`; the complete Lean development,
including checker soundness and consistency, checks successfully. Axiom audits
for `conv_sound`, `book_check` and `consistent` retain only `propext`,
`Classical.choice` and `Quot.sound`.

## Reproducible profiles and current integration state

The vendored Bend 2.0.37 snapshot stays byte-identical. `tools/kernel-profile.mjs`
applies a hash-pinned patch to an isolated build copy, checks the resulting source
hash, compiles the whole Lean file and audits the named theorems. It records
compiler identities and source, audit-log and executable hashes; cache reuse
revalidates those artifacts. `baseline` remains available separately.

At this candidate checkpoint, the default profile and active 622-root seal still
use the baseline kernel. Candidate-module successes are not silently substituted
into that seal. Build and exercise the candidate explicitly:

```sh
node tools/kernel-profile.mjs same-head-congruence-v1
node tests/kernel-congruence.mjs
```

The test invokes the actual independently built kernel on emitted BendTT. It
accepts six positive cases, including fallback after a failed argument comparison,
and rejects three false equations introduced after frontend checking. Resource
stops do not count as rejections. The candidate checks the existing 622 composed
roots and the formerly blocked general delivery equation. The complete 678-variant
negative sweep is running on a frozen 27f8defb checkout and has not yet received
completion credit. The [candidate receipt](reviews/kernel-congruence-candidate.json)
keeps these scopes separate. Timings there are diagnostic runs, not controlled
performance comparisons.

An independent proof dependency improvement moves terminal-retirement corollaries
from `action-helper-context.bend` to `action-retirement-context.bend`. Generic
callback-table frames no longer import retirement/output proofs. All existing
composed theorem names and domains are retained. This changes proof dependencies,
not source implementation boundaries or scheduler behavior.
