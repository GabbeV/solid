# Actual tracked held-signal read

Two quantified roots extend the read-entry helpers to one actual `Core.step`
whose next task is `ReadPrepared`. The step performs the real tracked graph
link, decides the held read, selects a value and returns to the exact caller.
A second root retains the complete transaction-record arena, including every
group's action obligations. This is a local instruction contract, not a completed
heap/flush or global publication theorem.

## Domain and result

The World, signal value, proposed slot, other arenas, caller tasks and operand
stack remain arbitrary represented data. There is no natural-number payload
restriction. The initial facts are explicit:

- The source is an initialized held signal, with a canonical terminal cached
  group equal to the current flush group.
- The positive reader is a render, allows children, is not a verdict reader,
  and is the current computed context. Tracking is enabled and no lane pass is
  active.
- The initial state is healthy. The signal is not an override and the initial
  unflushed-staging flag is false, selecting the actual fast branch.

`tracked-read-input.Input` contains the cache/posture/health facts. It says
nothing about a successful post-read World. The root's remaining premises select
the actual prepared-signal instruction. A fresh reader can have no extension and
no pending slot: the theorem does not allocate either early or assume it exists.

The result is the source-prescribed choice from the input signal's slots:

| Input | Served value |
| --- | --- |
| No proposal | Committed value |
| Proposal strictly equal **and** SameValue-equal to committed | Committed value |
| Other proposal | Proposed value |

Both equality tests remain in the implementation and theorem. Opposite signed
zeros select the proposal; an accepted NaN remains a proposal too. The actual
World contains the graph link, the render's JOINED mark, and `stagedRead` when
the proposed branch is selected, followed by its ReadValue diagnostic. The
caller task suffix and original operand stack remain exact, with the value
pushed on top. No application callback is executed by this signal-read step.

## Construction and proof structure

`read-entry-metadata` projects the existing unrestricted graph-link footprint.
Induction over arbitrary finite node storage proves that clearing the four link
pointers preserves read metadata and payload slots. Actual graph linking then
retains source/reader fields, extension storage, transaction records, flush/lane
identity and health, including aliases. Flag stores retain the same projection.

`tracked-read-input` transports the initial certificate through the actual link
and JOINED store. The frame-read proof exposes its already-proved Decision-level
equation, allowing composition with `Core.readDecision` rather than assuming the
callback-free raw adapter describes every Core lane-served path. The ordinary
same-flush input constructs a non-forcing decision with no lane-served traversal.
The prior unrestricted frame-read root retains its explicit fault branch.

`fast-staged-choice` connects a proof-only loaded form to the actual selection
helper, derives health through its real flag/lane-collection stores, and proves
the clean slot choice using Boolean identities. `tracked-held-read` composes
those results through the actual tracked getter and prepared-instruction dispatch.
All intermediate metadata and health premises are derived from the input.
The runtime, pinned source and checker limits are unchanged.

## Validation and remaining boundary

The small constructor/write fixture uses actual signal/render allocation,
transaction holding and a signal write. Its initial certificate is checked in
Bend; JavaScript supplies no equality evidence. It demonstrates a fresh-reader,
present-proposal instance of the general theorem. Two separate closed controls
distinguish missing graph linking and forced committed output. These are finite
discrimination checks, separate from quantification over arbitrary Worlds and
payloads. The initially ill-typed test variant is excluded from rejection credit.

The [receipt](reviews/tracked-held-read-validation.json) records completed focused
checks. Only a matching completed independent whole-book seal in `checked.json`
establishes the current composed checkpoint. Resource failures receive no credit.

Construction of this instruction and its initial cache/posture facts from the
body-produced heap/recompute path remains open. So do return through recompute,
publication and the existing parking/landing-scan certificate. This theorem does
not prove arbitrary JS callback reachability, arbitrary async histories, global
forest/live-list/once-only accounting, displayed-output safety or eventual reveal.
The group-record frame can carry the previously derived positive action count
across this read once that caller connection is established.
