# Uncredited held-before-resume constructor equation

This is a remaining checker-efficiency dependency, not a proved result. It is
not imported into LAWS/PROOF and no runtime algorithm is changed for it.

The desired raw-family equation is:

```
prepared(holdNode(opened(initial, methods), source1, group1), actor0, ActionEnd)
  = holdNode(ready(initial, methods), source1, group1)
```

`opened/ready` are the actual signal/render/link/action create/open/captured-resume
family. Group1 and source1 are separate arenas. The existing independent equation
normalizes the ready World, and the held-source profile/body-task retirement
result constructs ownership afterward. That result does not assume the equation
above or full public parking/invocation reachability.

Two attempts on the unchanged400M-fuel checker failed with out-of-fuel verdicts:
a direct equation (57.44s), then split create/open and preparation with an
arbitrary method parameter (89.03s). They receive no proof credit. A raw owned
profile passes, and its complete body-task retirement/zero-count composition
passes in75.50s on0847122e, within the existing90s/4GiB probe limits. The896 finite
actual-entry controls check the commutation on sampled bodies; they do not prove
it for arbitrary bodies/Worlds.

Next: prove the shared preparation boundary as a small metadata transform from
captured actor/group facts, then derive its commutation with ownership stores.
Use actual list/extension store lenses and group lookup facts instead of asking
reflexivity to expand both full Worlds repeatedly. Retain all original fields,
mutation order, original capture and caller task/stack obligations. Do not assume
an intermediate healthy profile or increase checker limits to declare success.
