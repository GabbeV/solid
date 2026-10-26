# Solid next 1d6c40fb (rc.18), operation review

All77 recorded Solid inputs match1d6c40fb459735ecbeebfaa6be8b8c142597fd34
byte for byte.15 recorded source files change after4ea2f498; the package still
declares rc.18. The isolated native source tree is clean. All three signals JS
tiers and declarations build.350 upstream test files /5,606 tests pass, with two
expected failures and two skips. An earlier run lacked dist artifacts and gets
no semantic failure credit. The package's Vitest binary was run directly after
pnpm refused a symlinked task-run directory; it tested this checkout's source.

## Admitted operation change

#4275/#4281 fixes a tracked render that first entered a verdict lane through
latest(), then read a never-shown pending flight. The render branch now computes
never-shown status before outside-lane selection; if its current lane is its
parent's verdict lane it first clears passLane. The later read follows the
ordinary pending path instead of publishing an empty slot. Bend preserves this
order in laneReadRender/laneReadOutside. Untracked, forbidden, guessed, error and
ordinary final-enter branches retain their source behavior.3,258 native helper
cases include verdict-parent fixtures, with720 question controls. The new generic
operation theorem gives the exact reset World/token/continuation/stack from
initial slot and verdict-pointer facts. It is not mounted-Show reachability.

The general positive theorem passes. Its first mutated broad oracle hit4GiB and
is not credited as a rejection. A compact actual-branch oracle passes unchanged
and rejects removal of the reset. The general theorem domain is not narrowed.

## Reviewed profile and exclusions

#4295's new optional-hook guards fold away for this full production engine:
the public index initializes lane and marks hooks. Moving the lane queue store
inside that installed-hook guard leaves this profile's queue order unchanged.
Bend includes those engines; optional-engine absence and physical module tree
shaking are not modeled. Sharing the HALTED string changes source size, not error
routing. No replacement queue or halt policy is introduced.

#4263/#4288 documents refresh/until after await in a yielded helper: it runs
outside the action slice and can wait on its own action's commit. No source
runtime operation changed; the existing typed action/host boundary remains.

#4269/#4278 clears INPUTS_PUBLISHED in the supplied derived-store setter branch,
outside this non-store handleAsync profile. This differs from supported raw
comparator callbacks. #4271/#4280 forwards status to derived-store families;
non-store nodes have no fam callback. #4262/#4264 container replacement reporting
and the remaining store refinements stay excluded. #4270/#4277 error-boundary
fallback rerouting and #4268/#4282 Loading fallback ownership are mounted-boundary
changes, also excluded. Compiler/web changes are outside signals scope.

#4292 adds onFlush: schedule(); queueMicrotask(callback). This is an explicit
unported unit in this intermediate repin and the next API target. It is not
silently represented as onSettled or synchronous flush. No semantic workaround
is active. Frontend/backend pins, checker profile, budgets and earlier property
domains remain unchanged.
