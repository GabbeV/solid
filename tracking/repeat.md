# Typed arrays and repeat

Current rc.17 policy is documented in [the integration review](reviews/solid-5b1b7776.md):
cleanup errors are collected while teardown continues, then rethrown at the
public root/flush boundary. Map/repeat fallback retry uses output length and
retains successful falsy values. Older pin-specific implementation notes below
are superseded at those operations; other profile restrictions remain.

At Solid `a2a5b6f8` (rc.16), `repeat` / `updateRepeat` now execute through the
same Bend core used by signals, memos, effects and teardown. This implements the
production helper underlying `<Repeat>` within the typed callback/natural-number
profile. JSX compilation and the component wrapper are not ported. `mapArray`
now has separate [positional](map-index.md), [identity-keyed/small-move](map-keyed.md)
and [extracted-key/index-accessor](map-modes.md) paths; repeat does not substitute them.

## Source return points

| Pinned `src/map.ts` operation | Bend location and representation |
| --- | --- |
| `repeat`: internal owner/data before computed construction | `runtime/map.bend:repeat`; stable RepeatState ID, original data fields, array identity for `_mappings`, owner IDs for `_nodes` |
| `computed(updateRepeat.bind(data))`, eager pass, clear AUTO_DISPOSE, accessor | `core.repeatCreate`, existing computed/recompute driver, `RepeatReady`; captured RepeatRead ID expresses the bound data receiver |
| `_owner._parentComputed = getOwner()`, count, optional from | `map.updateParent`, `core.repeatRead/repeatCount/repeatFrom`; count/from remain tracked, before internal owner entry |
| `runWithOwner(_owner, ...)` | `core.repeatBegin` and RestoreContext; existing owner entry disables tracking and restores ambient state even on exceptions |
| Nonempty to empty | OwnerTasks child-only disposal, then `map.clear` stores nodes, mappings, len and offset in source order, then fallback |
| Empty/fallback path | `core.repeatEmptyBody/repeatFallbackCreate/repeatFallbackBody`; dispose old attempt, install new owner before callback, store slot only after success |
| Capture bounds and allocate staged arrays | RepeatFrame captures newLen/from/to/prevTo/keepStart/keepEnd, fresh array ID and hole-filled owner slots |
| Copy retained overlap | `core.repeatCopy` copies node then mapping at each global index; original row owners and result values survive |
| Create missing rows | `core.repeatRows` stores each fresh owner before calling the original mapper with the global numeric index, through existing callable/argument machinery |
| Mapper catch | `RepeatMapped` exceptional edge restores the caller stack, then `repeatAbort` disposes only newly created owners in source index order and rethrows; guarded cleanup failures are collected and the original mapper error is rethrown |
| Commit after mapper catch | `repeatCommit/repeatLeaving` disposes prior fallback or exiting rows; this is outside the mapper catch, so commit errors do not trigger temporary-row abort cleanup |
| Publish successful stage | `map.publish` stores mappings, nodes, offset, len in source order; `RepeatReturn` returns the live mappings array |

Captured bounds stay fixed for the pass. State fields read after callbacks remain
live lookups, including the offset used to select an exiting node. No alternate
scheduler, callback engine, eager publication or rollback is introduced. Arrays
and row-owner vectors express source allocation; runtime arena storage is not a
claim of JavaScript allocation cost or memory reclamation parity.

## Array representation and host boundary

`runtime/arrays.bend` implements stable array IDs, length, indexed reads and
indexed stores. `ArrayData` stores `Slot`s: a hole is Empty, while a present
undefined element is Present(Undefined). Fresh output arrays retain holes until
a successful mapper assignment. Array identity participates in strict equality;
all arrays, including empty ones, are truthy. Dense array expressions evaluate
members left to right. Arrays can carry admitted values and nested arrays and
can flow through signals, callback arguments, return values and raw imperative
throws.

`host/arrays.mjs` materializes one native array per Bend ID and synchronizes its
slots after engine operations. This keeps observed aliases live when the source
mutates a retained mappings array. It does not choose rows, run callbacks or
make scheduling decisions. External mutations are rejected; the test host is
not an alternative implementation of the collection helper.

The admitted surface is deliberately narrower than JavaScript arrays:

- Dense literal construction, natural numeric indexing and length are available.
  Arbitrary input arrays, external mutation, user sparse literals, methods,
  prototypes, getters, property descriptors and reflection are unfinished.
- `count` and a truthy `from` must be natural numbers; falsy `from` values take
  the source `|| 0` arm. Fractional/negative counts and offsets and general
  numeric/coercion behavior are outside this profile.
- Mapper values use the existing admitted callable ABI. Count/from/fallback
  expressions retain callback, action-parameter and lexical signal captures.
  Arbitrary JavaScript closure environments remain unfinished.
- Array-to-string coercion needed when wrapping a reactive array error in
  StatusError is unfinished and explicitly refuses with Unsupported(81).
  This boundary must not silently produce an object message. Raw imperative
  array throws retain identity. Cyclic array observations are explicitly refused.
- Dev strict-read naming/diagnostics, observe attribution, stores and active
  lane/boundary/verdict behavior remain unfinished. The helper uses the existing
  production core profile, not an emulation of these active engines.

These are incomplete representation/API domains, not source fixes or semantic
workarounds. The semantic deviation register remains empty.

## Evidence and proof limits

`tests/arrays.mjs` adds 22 paired histories for values, identity, evaluation
order, callbacks/local captures, staged reads and signal equality.
`tests/repeat.mjs` adds 54 paired histories for window growth/shrink/shift and
disjoint windows, empty transitions, fallback results, owned/detached entry,
retained array/owner/accessor identities, exact owner trees and computed fields,
mapper errors, pending retries, cleanup-error partial states, nested helpers,
tracking and argument/local capture. They invoke native pinned Solid's actual
`repeat`, comparing values, traces, screens, errors and relevant internal state.
These are finite comparisons, not quantified proofs or fuzzing.

Seven compiled mutation assertions target lost parentComputed, recreated overlap,
skipped leaving-row disposal, retained-row disposal on abort, silently applying
the unmerged fallback fix, array equality and array truthiness. The mutation
oracles are separate from positive proof evidence.

The existing 68 closed semantic regressions and quantified signal/memo/history/
helper properties are rechecked after extending World with array/repeat arenas.
Concrete witnesses were regenerated with empty new arenas; generic World
patterns and reconstruction preserve arbitrary new arenas. There is no new
closed repeat execution or general repeat theorem in this checkpoint. No kernel,
axiom, proof budget or source pin was changed to admit this implementation.

## Integrated fallback retention

At rc.17 the source tests `!this._mappings.length`. A completed fallback owns
an output entry even for undefined, null, false, zero or an empty string. Empty
to empty updates retain it; interrupted attempts still retry. The Bend guard and
paired histories follow merged #4211. SOLID-EMPTY-FALLBACK-006 is integrated;
the mutation now reintroduces the old truthiness guard. The old behavior remains
in the bb82345 checkpoint for comparison.
