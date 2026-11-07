# Select an existing latest proposal before continuing its reader

An initialized latest output could still supply its old value while its reader
was already evaluating the input's held proposal. Four staged-error recovery
fixtures exposed the mixed calculation or a duplicate fallback callback. Three
existing overlapping-action fixtures exposed duplicate requests from the same
late selection.

Prepare an existing latest output at the read when the input's hold is already
known, or an open action owns the current pass. Leave first answers, unflushed
writes, dormant outputs and retiring observations on their existing paths.
Tracked proposal reads select the whole calculation context before its next
ordinary read, just as untracked observation reads already do. If selection
moves a running render binding, retry in its actual selected update, rather
than allocating a different update at the same depth.

This uses existing transactions and retry machinery. It adds no node field,
cache or persistent version history. The ordinary path without an installed
observation coordinator is unchanged. Active observation costs have not been
benchmarked; no speed or size improvement is claimed.

## Structural preparation

The first trial passed the full signals suite but wedged the web generator's
#4405 recovery/remount replay. A structural boundary reader was being prepared
alternately for two ready updates. Each pass registered a replay against the
other update, so neither could finish preparation.

Structural boundary readers now retain their existing post-publication replay,
as direct render bindings do. Value derivations still prepare their incoming
work before publication. The scheduler's existing replay and callback queues
remain responsible for completing the structural frame. No sibling callback
order, error exception or new publication rule is introduced.

Simply suppressing tracked context discovery avoided the loop but lost the
complete fix. Suppressing discovery only during preparation or on structural
readers did not repair it. Those trials and their traces are archived. An
initial full web run and its repeat were terminated without JSON reports;
they are not counted as passing validation.

## Validation

- Full signals: **5,497 passed / 2,033 failed / two skipped**. Seven old failures
  fixed, no new failures and no collection errors relative to stage 154.
- Full web: **1,691 passed / 127 failed / one skipped**, identical failures to
  stage 152. The three existing generated recovery cases complete. No test
  expectation was changed in this stage.
- Final production-source controls: **685 passed**. Public-API-only controls
  against the rebuilt and property-mangled production package: **332 passed**.
- Six recovery JSX controls pass against the final rebuilt development package.
- All build tiers, property mangling, purity checks, declaration generation,
  rules-index and diff checks pass.

An attempted built-package run of all unified fixtures mixed their direct
internal source imports with the built package (455 pass, 208 fail, collection
errors). That is an invalid two-runtime configuration, not a runtime verdict.
The complete set was rerun consistently from production-defined source; the
332 built controls import only the public package. Both selections and reports
are retained so these validation scopes remain explicit.

The seven fixes are all four `error-staged-recovery` cases and all three #4399
pair/split/value request-count cases in `latest-first-one-pass-4402`.
Other one-pass failures, first-proposal ownership (#4429), deferred APIs and
untriaged failures remain. This checkpoint does not establish scalar completion.

Receipts: `checkpoints/integration-stage155.tar.xz`.
