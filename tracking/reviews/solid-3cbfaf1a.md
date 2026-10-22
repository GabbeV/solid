# Solid next 3cbfaf1a integration

The reference advances from 1c0ff9f8 to 3cbfaf1a, still declaring rc.17.
All 77 recorded Solid inputs are compared byte for byte with Git at the new
commit. Only core/async.ts changes among these inputs. The complete upstream
range also includes server-function build identity (#4215), template-ref
documentation (#4221), and async/from documentation (#4222). Those files sit
outside the signals runtime snapshot; none introduces an omitted non-store
signals operation. The Bend/compiler/kernel pins stay unchanged.

## Source operation and translated continuation

Merged #4228 changes handleAsync's handleError closure. After an error is
actually published through notifyStatus, a non-NotReady rejection calls
disposeChildren(el, false, true). This releases the parked displayed frame as a
successful replacement would. A staged error does not publish yet; a NotReady
rejection transfers a wait. Neither takes the new teardown branch.

Core.handleErrorNotify retains the source's publication decision, calls the
existing notifier, and places OwnerTasks[Enter(id,false,true)] before the
existing time/update/dependent-release remainder. The shared owner/core driver
executes child and registered cleanups, including expression callbacks and the
existing first-error collector. No alternate cleanup walk, new World field or
special scheduler was introduced. Unsupported custom setter/onError and store
branches stay explicit limitations of the existing profile.

Sixteen public histories vary immediate/native promise delivery, success versus
rejection, an intervening never-committed run, and nested child cleanup. They
check native/Bend node state and complete callback traces after every command,
plus explicit child-before-parent cleanup timing and subsequent replacement.
The preceding Bend implementation fails the new reference on rejection:
parkedDisposal remains 1 instead of 0 and the old cleanup is absent. The port
passes. The two unchanged upstream async-cleanup-timing tests also pass. The executable
Bend example `npm run example:cleanup` prints cleanup counts 0 (shown), 0
(replacement pending), 1 (replacement rejected), and Healthy.

Three independent-kernel properties quantify over every typed World, node ID,
error, remaining task list and value stack. They establish the exact new
continuation after notification, preservation on staged errors, and preservation
on pending transfers. A separate complete concrete public-API program proves the executable example's
cleanup counts 0/0/1 and Healthy. Its compiled omitted-retirement mutation is
rejected independently. These do not prove arbitrary async histories or equivalence
to TypeScript. All preceding complete-program theorem domains and sufficient
budgets remain unchanged. Two compiled guard mutations are rejected by these
properties; a separate omitted-cleanup mutation is rejected by the public cases.

## Reported bugs and remaining work

The user has submitted #4231 (deferred synchronous error answer), #4232 (generic
deferred synchronous iterator results) and #4233 (synchronous from unsubscribe
errors). All three were verified open and unmerged when this refresh began.
The #4228 fix does not fix those branches. The translation preserves its admitted
baseline defect; from and open-window stream wrapping remain unfinished.
No candidate patch is installed, and the semantic deviation register is empty.

The final validation receipt distinguishes the full public/private/kernel runs,
the new negative controls, and the complete negative-corpus rerun. Test counts
are progress evidence, not a completion percentage.
