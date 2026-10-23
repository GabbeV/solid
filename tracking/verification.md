# Verification process and trust boundary

Verification distinguishes source correspondence, execution evidence, semantic
proofs and environment assumptions. The shared runtime is the one used by the
host, differential suites and proofs. Tests do not prove arbitrary histories;
helper laws do not automatically establish reachable-state premises.

## Current evidence

Solid is pinned to `225014bf` (rc.18), Bend to 2.0.37, and the independent kernel
and Lean pin are unchanged. No semantic deviation is active.

| Evidence | Current scope |
| --- | --- |
| Public differential corpus | 4,486 histories; restricted admitted callback/value/IO grammar |
| Closed composed regressions | 73 fixed end-to-end Bend executions; separate from quantified proofs |
| Quantified proofs | General helper/frame/representation laws, arbitrary scalar-memo histories/batches, fixed graph/lifecycle families, and certified redirect/rejoin history safety; see [general-properties.md](general-properties.md) |
| New join/action controls | 288 private join fixtures /1,152 rejoins /576 queries; 32 opening frames; 48 native-generator public graph histories /408 prefixes; see [scope](transaction-joins.md) |
| Previous redirect controls | 28 fixtures / 2,268 queries / 252 rejoins; 84 machine completion prefixes; not public histories |
| Configured mutations | 581 = 469 finite + 112 kernel variants after nine new allocation/join variants |
| Complete negative sweep | Frozen wrapped-runtime checkpoint 8353373: 564 named variants, all rejected with sealed inputs unchanged; [receipt](reviews/from-wrapped-complete-negative.json) |
| Later negative evidence | Focused value/frame/invariant variants, separately recorded; no fresh complete 581 sweep claimed |
| Blocked proof | 170-step late-push programme, finite controls pass, independent kernel out-of-fuel; [unverified archive](../experiments/from-async/README.md) |

The [constructed action/join receipt](reviews/joined-action-invariants-validation.json)
records the new quantified contracts, constructed branching prefix, native controls
and nine new negative variants. The proof elaboration normal forms/contracts
change no runtime or kernel limit.

The focused [invariant receipt](reviews/transaction-invariants-validation.json)
records the three independent module verdicts, private controls and four
negative variants. Separately, 21 existing native-generator controls and 45
reusable action-function histories still pass.

Earlier receipts remain tied to their exact pins/checkpoints. The
[previous verification ledger](reviews/verification-through-65e7402.md) preserves
suite-specific observations and historical counts. Its old omissions and totals
are not the current frontier. The current successful composed check is sealed in
tracking/checked.json; it records actual inputs and the kernel verdict, not an
assumed package-completion measure.

## Routine commands

- `npm run build`: generate the active runtime and pinned full-index reference;
  record build input hashes. The reference includes reachable module initialization
  and installed production hooks.
- `npm test`: public/native and direct-machine controls, including the focused
  redirect tests; each suite states what it observes and what it omits.
- `npm run test:alignment`: operation-level source/helper comparison suites,
  including synthetic internal states that are not reachable-public-program claims.
- `npm run mutations`: compile source-changing variants and require assertion or
  independent-kernel rejection. Stale targets, compilation errors, resource failures
  and unrelated errors do not count as successful negative checks.
- `npm run check`: validate pins/deviations and generated artifacts, reject stale
  builds, run the composed independent BendTT kernel, check inputs stayed unchanged,
  and seal the result in build/verification.json. Copy that completed record to
  tracking/checked.json at a checkpoint; every listed input must be Git-tracked and
  hash-identical before synchronization.

Use focused checks while developing. At a coherent checkpoint run the composed
kernel and checks appropriate to the actual changes; broaden tests when changes
or unresolved failures justify it. No runtime/host change is part of the current
proof/documentation checkpoint. Frozen complete sweeps and fresh focused checks
are deliberately distinct evidence.

## What each layer establishes

Source correspondence uses pinned, verbatim files, operation reviews and paired
execution. `upstream:impact` and the correspondence ledger locate affected source
segments; they are not formal equivalence certificates. Native private controls
may expose/reset module state in memory without replacing source function bodies.
Their fixtures establish local branch coverage, not arbitrary reachable-state
invariants. Public generator controls exercise the real `action` API separately.

The kernel checks elaborated Bend proof terms against actual runtime operations.
Witness generators and executable exploration are ordinary untrusted engineering
tools; their proposed equations must be checked. New redirect certificates contain
actual `into`-field equalities, not assumed step equations. The history runner
carries the actual World. Room, allocated references, callback once-only behavior
and observation bridges are separate obligations as documented per theorem.

Backend-generated JS, codecs and host IO connect execution to native controls;
that connection is not a proved compiler/JS semantics theorem. Opaque values retain
per-runtime identity. General JS arithmetic, protocol reflection, native scheduling
fairness and arbitrary callback termination remain outside the admitted contract.
A valid represented function/arena token is not automatically an arbitrary JS input.

## Observation limits worth preserving

- Numeric facade setter returns use the original JS argument; direct machine/stack
  observations are required for an independent machine-return assertion.
- Direct native getter cleanups preserve original callable identity and omit native
  read-trace comparisons they cannot observe. Other admitted observations remain;
  [getter-cleanup.md](getter-cleanup.md) records the exact boundary.
- Reaction/internal application trace omissions are explicit in [reactions.md](reactions.md).
  Compare actual node/edge state, values, errors, returns and cleanup effects rather
  than synthesizing unseen native events.
- A manual flush may leave an already-requested external job queued. Native Promise
  tests and explicit admitted host-event proofs support different timing claims.
- Exact machine equations include source exception/partial-state and exhaustion
  behavior. Kernel out-of-fuel is a proof-checking failure; runtime Exhausted is
  operational behavior. Neither is proof of successful asynchronous progress.

## Trust and reports

The pinned parser/elaborator and independent kernel implementation underlie the
semantic check. Backend code generation, Node/Bun/native IO, codecs and adapter
observations underlie executable comparisons. Source fidelity remains reviewed
and tested. Mathematical theorem premises and source-rule draft questions are
explicit; no TS equivalence, compiler/browser proof or full-package guarantee is
claimed.

Classify significant failures, preserve baseline evidence and reduce to pinned
real Solid before an upstream claim. Relevant current fixes/issues must be checked
before preparing a report. The existing deferred protocol-error defect remains
preserved; this invariant checkpoint adds no new upstream bug or workaround.
Reports/PRs are user-controlled. Feature-branch checkpoint synchronization is
already authorized and remains separate from upstream publication.
