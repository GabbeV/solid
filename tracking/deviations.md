# Temporary deviations

Source fidelity remains the default. The user permits deviations when necessary
to continue progress, with strict tracking so bugs can be reported and upstream
fixes integrated later. This permission does not require a new approval for each
routine deviation. Explain meaningful deviations when introducing them.

The machine-readable register is deviations.json. It currently has no active
entries. That does NOT mean the existing port is fully source-aligned: known
alignment debt is listed in source-fidelity.md. Those gaps are not upstream bug
claims or automatically accepted permanent design choices. Before expanding a
path that deliberately relies on one, repair it or register the necessary delta.

## Required record

Assign a stable ID (DEV-0001, DEV-0002, ...). Record:

- The original Solid commit and exact source units/branches; retain the observed
  source behavior, minimal program, event schedule and paired controls.
- The changed Bend behavior, affected files/definitions, why it unblocks work,
  and the exact scope in which it is used. Mark the code with the deviation ID.
- A regression/reproducer file with separate baseline and deviating expectations.
  Deliberate differences are not silently normalized out of parity comparisons.
- Classification, evidence and uncertainty: a suspected upstream bug is not a
  confirmed bug, and a Bend limitation or missing translation is not a Solid bug.
- Issue/PR/fix links and commits as they become known. Null means not filed or
  not known; do not manufacture a link or imply that a proposal has landed.
- Effects on proof statements, assumptions and execution profiles. Passing
  workaround proofs establish properties of the deviating runtime, not Solid.
- A retirement trigger and concrete checks: port the landed upstream operations,
  remove the temporary delta, rerun the original regression and relevant parity/
  kernel checks, and record the resulting source pin.

Keep the pinned TS snapshot immutable. A temporary patch may live in the one
active Bend runtime with a clear boundary or reversible delta; another permanent
runtime is not required. Maintain reproducible baseline evidence (and a replayable
patch/profile where needed). Do not freeze a workaround into the architecture.

## Entry shape

```json
{
  "id": "DEV-0001",
  "title": "Concrete problem being worked around",
  "kind": "upstream-workaround",
  "status": "active",
  "lastReviewedPin": "40-character current Solid commit",
  "source": {
    "commit": "40-character original Solid commit",
    "units": ["core/module.ts:function and affected branch"],
    "behavior": "Observed baseline result and callback/publication order"
  },
  "change": {
    "bendFiles": ["runtime/module.bend"],
    "behavior": "The exact changed result or order",
    "reason": "What this unblocks",
    "scope": "Supported executions and limits"
  },
  "evidence": {
    "reproFile": "tests/deviations/DEV-0001.mjs",
    "baselineResult": "Expected result against the pinned reference",
    "deviatingResult": "Expected result with the delta applied",
    "classification": "suspected-upstream-bug",
    "uncertainty": "What has and has not been established"
  },
  "upstream": {"issue": null, "fix": null, "fixCommit": null},
  "proofImpact": ["Affected law, assumption or scope; use none if none"],
  "retirement": {
    "trigger": "Upstream condition that makes the delta unnecessary",
    "checks": ["Replay the original repro", "Port the landed source and rerun affected verification"]
  }
}
```

This is a template, not an assertion that DEV-0001 exists. A port-specific
workaround uses kind port-workaround. Classification may remain under-investigation;
progress does not need to wait until a suspected upstream bug is confirmed.

## Lifecycle and repins

Statuses: proposed -> active -> reported -> fix-landed -> retired. Reporting and
upstream acceptance are optional; a port-workaround can go directly to retired.
A proposal is not active. An active/reported/fix-landed entry must have a complete
record and current lastReviewedPin. Reported requires an issue link; fix-landed
requires a fix commit. Keep retired records and their retirement.result; do not
erase the history or reuse an ID.

On every repin, review all active entries and the matching source changes. A
landed fix is a prompt to integrate and retest, not automatic evidence that a
workaround is obsolete. Retire only after source alignment is restored and the
checks succeed. If the fix differs from our candidate, translate the actual landed
implementation and explain any remaining difference.

npm run check validates the register and seals its hash and active IDs with the
verification record. npm run upstream:impact lists active deviations for review,
even when no indexed source changes are detected. It never auto-retires them.
Bug filing, publishing and contacting maintainers still require explicit user
instructions; preparation of a repro/report does not.
