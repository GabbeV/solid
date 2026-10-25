# Canonical list ABI correction

`HARNESS-LIST-ABI-001` is a private-control harness defect, not a Solid bug or a
Bend source algorithm change. Four control files hand-built `$: "Cons"` lists;
the pinned emitter's actual constructor is `$: "Con"`. The old decoder accepted
anything with `head`/`tail`. Some emitted functions test only for Nil and happened
to traverse the malformed records; the core dispatcher tests for Con and treated
the malformed task list as empty. A new independent-application probe exposed it
by recording no application at all.

The host now derives list tags from actual emitted constructors, supplies one
`encodeList` helper and rejects wrong tags or missing list fields when decoding.
All four controls use that encoder and the strict decoder. No runtime, vendored
source, kernel/toolchain setting or theorem domain changed. Malformed JS records
are outside the typed Bend list domain. This is not a semantic workaround.

The new ABI controls check actual constructor tags, payload round-trip, a real
emitted first-value read, empty lists and malformed tags/tails. The corrected
actual `Core.step` probe now records an independent application and retains the
selected text/application observation. Public history logic remains paired with
the unchanged native source.

The full default public suite and full native-alignment command pass after the
correction. Corrected transaction controls retain all their fixture/query/join/
completion counts. The 160 fulfillment prefixes still execute 1,360 steps with
canonical nonempty caller stacks. The independent probe adds 80 actual application
steps; the 240 existing public scenarios now also check both distinct mechanical
text targets against the native renderer results at all 2,280 observed prefixes.
The independent target is explicitly 3 instead of sharing the main target 2.
Earlier trace checks were valid; they did not establish tree-target independence.

## Evidence qualification

The complete frozen608 receipt still records its actual named outcomes and frozen
hashes, with a subsequent caveat listing the affected private-control files and
mutation variants. That private-list evidence is superseded by the corrected
controls and a fresh frozen sweep. The typed kernel proofs use proper Bend lists
and are unaffected. Public histories constructed through the emitted API are also
unaffected; the malformed lists were in private fixture arguments/overlays.
No resource or infrastructure failure is counted as semantic rejection.

See [the validation receipt](reviews/rendered-observation-validation.json) and
[the selected observation contracts](rendered-observation.md). A fresh complete
sweep is run on the corrected checkpoint; until its receipt exists, the old608
result must not be represented as complete current validation without its caveat.
