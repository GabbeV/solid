# Solid signals translation contract

The user explicitly requires a translation close enough to line by line to
follow future Solid commits. This takes precedence over proof convenience and
prior approaches described in the uploaded restart guide.

- Preserve source function/module boundaries where possible, fields, meaningful
  branches, mutation order, traversal order, flags, and optimizations. Split Bend
  helpers or continuation states must identify their source function and segment.
- Stable IDs, state threading, explicit control flow, and a callback protocol may
  express JavaScript mechanisms. Explain their correspondence. They are not
  permission to substitute a different scheduler or publication algorithm.
- Do not change runtime behavior, discard a source branch, add a correctness gate,
  or weaken a law just to obtain a passing example or proof. A missing source
  operation stays unfinished. A deliberately restricted harness is not a full port.
- Semantic proofs of Bend remain useful. A formal proof of equivalence to the
  TypeScript implementation is not a project requirement. Reviewed operation-level
  correspondence and differential tests support source fidelity without claiming
  machine-checked TS equivalence.
- When source behavior conflicts with a desired guarantee, preserve it in the
  baseline. Explain the concrete program, event order, expected/actual outcomes,
  source operation, and uncertainty to the user. Investigate whether it is a port
  bug, adapter bug, intended behavior, ambiguous contract, or upstream bug.
- Suspected upstream bugs require a reduced reproducible case against the pinned
  source, paired controls, and checks of relevant tests/docs and current upstream
  fixes/issues. Do not label a translation omission as an upstream bug. Do not
  silently patch the baseline. Keep any candidate fix separate and clearly labeled.
- The user may choose to file a report. Do not file issues, publish changes, or
  contact maintainers without explicit authorization.
- Pin upstream sources. Inspect changes with `npm run upstream:impact -- PATH`;
  audit affected Bend definitions/branches and rerun relevant checks before a repin.
  Never edit vendored baseline files or update their hashes to hide drift.
- Keep source accounting, tested behavior, proven properties, limitations and
  adapters separate. Passing tests do not close unreviewed correspondence branches.
- Read tracking/source-fidelity.md and tracking/frontier.md before extending the
  runtime. Repair known algorithmic substitutions before expanding affected paths.
