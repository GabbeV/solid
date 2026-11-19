# Held latest errors: a concrete publication choice

No runtime or test expectations changed in this stage. A JSX diagnostic probe
compared actual DOM text on the retained experiment and pinned next `4fe75321`.
Its source, compiler config, logs and extracted timelines are archived.

The program has an ordinary version binding and an Errored around a Show whose
span reads `latest(data)`. Version 0 returns `ready`. An action sets version 1
and stays open. Version 1 either returns `changed` or throws `failed`. One
variant keeps the Show mounted; another proposes hiding it at version 1.

While the action stays open:

| Proposal        | Show remains mounted: next / experiment | Show removal proposed: next / experiment |
| --------------- | --------------------------------------- | ---------------------------------------- |
| Value `changed` | `0changed` / `0changed`                 | `0changed` / `0changed`                  |
| Error `failed`  | `0ready` / `0ready`                     | `0failed` / `0ready`                     |

The same probe then starts async recovery within the held action. Next keeps
whichever of these frames it showed; the experiment keeps `0ready`. Both show
`0recovered` when that answer lands, then `2recovered` when the action ends.
These are recorded timelines, not newly accepted intermediate assertions.

This narrows stage 125's unexplained manual/JSX difference to a concrete
structural distinction. It does not establish that every earlier reduction
has this cause, or that either retained intermediate behavior is intended.

## Evidence and unresolved choice

D-41 says errors are answers, staged like values, and latest throws the proposed
error as the explicit early-observation path. PR #4456 intentionally repairs
latest-through-derivation error propagation. PR #4406 repairs recovery and
records held error/recovery behavior. Their descriptions and relevant retrieved
comments are AI-authored; I found no human explanation there requiring the
specific Show-dependent difference above. The distinction must not be inferred
as an intentional contract merely because one generated test asserts it.

Proposed ruling: latest should be able to publish the proposed error through
its output update in both shapes, as it publishes the proposed value. Its
ordinary consumers and error fallback must still publish coherently. This
would change next's retained-branch case as well as repair the experiment's
removing-branch case. The alternative is to hold the error/fallback until the
input update commits in both shapes, making latest's error publication differ
from its value publication. Preserving next's structural difference would need
a specific semantic rationale.

Awaiting the user's decision before changing this publication contract. Reset,
recovery, fallback ownership and ordinary error holding must be validated with
any implementation. Prior stage-125 trials are not a completed solution.

## Checkpoint

The runtime remains stage 132. Stage 133's 26 store guards and all unified
suites pass (608 tests), and the guards pass on next. The last full signals
inventory remains 2,114 failures, mostly deferred optimistic stores/until;
first-proposal/store ownership and other scalar failures remain unresolved.
No new performance or bundle-size claim is made.
