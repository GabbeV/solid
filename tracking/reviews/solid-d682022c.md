# Solid pin update: b0ad1df5 to d682022c

Reviewed on 2026-10-21. The clean candidate is
`d682022c21eb863edc1a1abac687b2353c55ab6f` (still rc.16), nine commits after the
previous pin. The full previous translation checkpoint is preserved at
`baseline/solid-b0ad1df5` (`523673d`). Work remains on
`integrate/solid-next-fixes`; the Bend/Lean toolchain and empty semantic deviation
register are unchanged.

[Impact](solid-d682022c-impact.json) was generated before copying the candidate.
[Validation](solid-d682022c-validation.json) records source revisions, native
before/after controls and log hashes. All 76 vendored Solid files were compared
with the clean candidate; eight changed source files were copied verbatim. No
local source patch or altered snapshot was used to obtain the reference result.

## Operation review

| Source change | Treatment and limits |
| --- | --- |
| #4195 / #4189 adds `!(el as any).fam` to stageError's in-pass staged-read guard. | Projection derives now publish an in-flush error immediately through their family. The admitted Bend nodes have no projection family and no projection constructor; the new predicate is always true within that domain. The reduced production guard remains identical, with an explicit source comment and open correspondence restriction. Implementing projections must add the actual family-aware branch. Both original upstream cases and additional native controls are source-only evidence, not Bend projection coverage. |
| #4200 / #4178 adds halt diagnostic location storage, `haltReactivityAt`, and development call-site routing from effects/boundaries. | Production call sites still call `haltReactivity(cause)` unchanged. New module cells are used by development diagnostics; no source hook is installed by their declaration. Diagnostic subjects, paths, locations and the new wrapper remain unported. Production halt/report state, effect catches and restoration remain unchanged and are revalidated. |
| #4201 / #4181 remembers explicitly undefined context defaults and produces more specific ContextNotFoundError messages. | New default bookkeeping and constructor arguments are dev-only. Production createContext/getContext and the zero-argument empty-message constructor preserve the existing operations. Existing context/error histories and proofs are revalidated; descriptive development messages remain unported. Constructor overload declarations were reviewed separately from executable bodies. |
| #4194 / #4179 warns on ignored store writes, with once-per-target/key memory and an internal graph-registration guard. | Warning calls are dev-only; the existing production early returns remain identical. The observe registration wrapper is also gated by dev. Store APIs and diagnostic state remain unported. Import/module initialization was reviewed: no new installer changes the admitted production profile. |
| #4197 / #4184 documents equal-compute effect application and cleanup. | No runtime change. Twelve paired histories exercise both effect kinds, scheduled/ordinary creation, direct constant-result computes, a memo that absorbs equality and a custom comparator. These agree on old/new pins and preserve the existing effect/comparator driver. |
| #4202 form-input/draft/rejected-input documentation; compiler fixes #4196/#4199; server-function live GET #4190. | Outside the production signals-engine translation. No compiler, DOM input or server-function behavior is claimed by this repin. |

All changed imports, module declarations and initializer reachability were reviewed,
including the actual full signals index and its store/lane hook imports. An
installed hook is not treated as an active projection/lane. The reduction above
requires the currently admitted node kinds and inactive family/lane/store scopes.
The inventory includes the new unported dev wrapper; unmapped diagnostic and store
branches remain open. No source-fidelity or proof claim was broadened by the repin.

## Native before/after evidence

The candidate's two new regression files were copied unchanged to the clean old
checkout only for the controls, then removed. The old checkout was verified clean
again afterward. Each was run in development, production and observe profiles.

| Control | b0ad1df5 | d682022c |
| --- | --- | --- |
| Projection rejection, direct read | Pass | Pass |
| Projection rejection, nested render read under loading/error boundaries | Fails: screen is the span with undefined text | Pass: `errored: failed` |
| Equal-compute effect/cleanup and memo suppression | All six pass | All six pass |

The candidate's unchanged package builds all three JavaScript tiers and source
 declarations. Its full signals suite passes **330 files / 5,432 tests**, with
three expected failures and two skips. Dependency tool installations are reused
from the prior clean checkout; no lockfile or dependency policy was changed.
The full repository/example/compiler build is not part of these package checks.

Twelve new paired histories cover the admitted equal-compute behavior. Two native
projection controls retain the source fix in the regular test command without
claiming a Bend implementation. Existing empty-flatten, staged-error-recovery and
held-function-value fixes are revalidated; the deferred-release collector leak
and pending-reaction replacement counterexamples remain deliberately unchanged.
The current source/output seal and complete Bend validation are in
`tracking/checked.json` and the validation record.
