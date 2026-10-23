# Solid signals translation contract

## Objective and working priorities

Establish increasingly general semantic properties of Solid's reactive system
and use counterexamples to discover upstream bugs. The source-followable Bend
translation is the foundation; formal TS/Bend equivalence is outside scope.

- Prefer reusable operation contracts, reachable-state invariants, observation
  functions and induction over branching permitted event histories. Keep
  representative exact executions as integration proofs; do not make growing
  generated state witnesses the default route to async consistency.
- Choose implementation work that enables the selected theorem or repairs a
  material fidelity gap. Current scope, milestone and dependencies belong in
  tracking/frontier.md; theorem domains/assumptions belong in the existing proof
  documents. Keep current coverage separate from chronological progress records.
- Define observations by reader/posture and source publication rules. Distinguish
  scheduling-group identity, result/flight identity and question provenance;
  intended visibility guarantees are not automatically properties of the source.
- Construction must establish invariant premises and admitted transitions must
  preserve them. Record continuation/stack/ambient obligations at intermediate
  source boundaries; do not assume a stable invariant at every machine task.
- State safety, internal completion and eventual reveal separately. Derive bounds
  from structural facts where possible; identify callback termination, valid
  identities, once-only settlement, host delivery and fairness assumptions.
- Use adversarial event orders and differential exploration alongside proofs.
  Classify failures as translation, adapter, protocol, specification or upstream
  before making a bug claim. Preserve baseline behavior and reduce significant
  cases against real Solid.
- Report new generality, assumptions, remaining obstacle and bugs/specification
  questions. Test counts and exact witness step counts are supporting evidence,
  not an overall completion measure. Refactor witness layouts/bounds when
  justified while retaining meaningful theorem domains and guarantees.


The user explicitly requires a translation close enough to line by line to
follow future Solid commits. This takes precedence over proof convenience and
prior approaches described in the uploaded restart guide.

- Preserve source function/module boundaries where possible, fields, meaningful
  branches, mutation order, traversal order, flags, and optimizations. Split Bend
  helpers or continuation states must identify their source function and segment.
- Stable IDs, state threading, explicit control flow, and a callback protocol may
  express JavaScript mechanisms. Explain their correspondence. They are not
  permission to substitute a different scheduler or publication algorithm.
- Temporary deviations are authorized when needed to unblock progress. Explain
  meaningful changes and register them in tracking/deviations.json before relying
  on them. Record the exact source behavior, changed behavior, reason, affected
  definitions, reproducer, evidence, proof impact and retirement condition.
  A passing proof/example alone is not evidence of source fidelity. Missing source
  operations stay unfinished; the restricted harness is not a full port.
- Semantic proofs of Bend remain useful. A formal proof of equivalence to the
  TypeScript implementation is not a project requirement. Reviewed operation-level
  correspondence and differential tests support source fidelity without claiming
  machine-checked TS equivalence.
- When source behavior conflicts with a desired guarantee, preserve it in the
  pinned reference and reproducible evidence. A registered workaround may run in
  Bend while the source issue is investigated. Explain the concrete program, event
  order, expected/actual outcomes,
  source operation, and uncertainty to the user. Investigate whether it is a port
  bug, adapter bug, intended behavior, ambiguous contract, or upstream bug.
- Suspected upstream bugs require a reduced reproducible case against the pinned
  source, paired controls, and checks of relevant tests/docs and current upstream
  fixes/issues. Do not label a translation omission as an upstream bug. Do not
  silently patch the pinned reference. A candidate fix may be active in the one
  runtime if its delta is isolated/reversible and labeled with a deviation ID.
  Keep baseline parity and workaround correctness evidence distinct.
- The user may choose to file a report. Do not file issues, publish changes, or
  contact maintainers without explicit authorization.
- Pin upstream sources. Inspect changes with `npm run upstream:impact -- PATH`;
  audit affected Bend definitions/branches and rerun relevant checks before a repin.
  Never edit vendored baseline files or update their hashes to hide drift.
- Keep source accounting, tested behavior, proven properties, limitations and
  adapters separate. Passing tests do not close unreviewed correspondence branches.
- Read tracking/source-fidelity.md and tracking/frontier.md before extending the
  runtime. Repair known substitutions before expanding affected paths, or register
  the necessary temporary deviation and its limits. See tracking/deviations.md.
- Revisit active deviations on every repin. Link reports/fixes when available;
  when a fix lands, port the upstream implementation, remove the temporary delta,
  rerun the original repro and affected checks, and retire (never erase) the record.
  No fresh permission is required for every routine deviation within this scope.

## Git checkpoint workflow

The user has authorized regular synchronization of this translation to their
GitHub fork. Work on `feat/solid-signals-bend`, with `origin` set to
`https://github.com/GabbeV/solid.git`. Commit and push completed, verified
checkpoints during sustained work and before ending a continuation. Verify that
the remote branch reaches the local commit. Use normal fast-forward pushes;
inspect unexpected remote changes before integrating them. Local Git bundles are
optional recovery artifacts, not a substitute for GitHub synchronization.
This authorization covers the translation branch, not upstream PRs/issues or
other feature branches.

Before pushing a checkpoint, verify that every input listed in
`tracking/checked.json` is tracked by Git, including newly created proof modules.
