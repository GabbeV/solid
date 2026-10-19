# Function-value operation review

Reviewed on 2026-10-20 (Europe/Stockholm) against Solid
`d2ad8b288886a5c7171e6746ccc019ad1d08d8ab`. This is an operation-level review
for the admitted production callback/value domain, not a full-package or
machine-checked TS/Bend equivalence certificate. The inventory's general branch
reviews remain open; restricted mappings remain restricted/partial.

## Exact source units

Line numbers are in `upstream/solid/packages/signals/src`. Implementation hashes
use the source-inventory scanner; overload declaration hashes remain in the full
inventory. File-level imports, constants, installed hooks and module initialization
must also be reviewed for any repin.

| Source unit | Lines | Implementation SHA-256 |
| --- | --- | --- |
| `signals.ts:createSignal` | 405–420 | `5f5723fb24c6a365ce85703ebe41e9d2454eaa1928aa372b29730d4f172e333b` |
| `signals.ts:accessor` | 132–136 | `e2924f66fa69ba303b0e68f432366bb23e4aebc642129708541129c540a982f6` |
| `core/core.ts:setSignal` | 2044–2126 | `782b215d3522498565add7e52cfbffd9863303ca47d7c4e3d08b7f86cfcd8e16` |
| `core/core.ts:setMemo` | 2139–2163 | `7c11d592ff09bcbde29e36295a5f7aa69e29ff6690c254ec984463344acc7ea0` |
| `signals.ts:onCleanup` | 91–120 | `1d6ffea63cac1e421b0f4857f36edb44776feac727a86e6b6721aa4f72bd8103` |
| `core/owner.ts:cleanup` | 306–312 | `b80cdf7c6a04660283083ad7f9329b0f638e454f2fd4706503ed1361c5695db4` |
| `core/owner.ts:runDisposal` | 179–208 | `65528c170935d390cd3046b43fd7e042b5a1014f7ff03dcb0ba6e2e2198f37c4` |

## Reviewed operation order

| Source operation | Bend return point or representation | Scope and evidence |
| --- | --- | --- |
| createSignal distinguishes a data initializer from a function. | SignalScope/CreateSignal versus SignalComputeScope. | Explicit admitted user-code forms; general first-class callable initializers are rejected rather than stored under the wrong overload. |
| Function form calls computed before clearing AUTO_DISPOSE, then binds read/setMemo. | Shared construct-state.computed, eager/lazy setup, MemoSignalReady, Local.bind. | 1,536 additional constructor probes check all option/parent/loading combinations; no early bit clear. |
| Data form allocates the source signal and binds read/setSignal. | Shared construct-state.signal and constructor-selected SetterReference. | Existing constructor/data histories remain unchanged. Nonproduction registration is outside the profile. |
| accessor captures node in read.bind and attaches its refresh target. | callable.accessor, AccessorReference, core.invokeValue/ReadNode. | Bound identity and read target are retained. JS symbol/property reflection is unfinished; this row does not claim that literal property store is ported. |
| Setter reads entry currentValue, then invokes a function argument once. | setSignalArgument/resolveSignalArgument and signalUpdater. | Reentrant histories reject a post-callback slot reread. Active write/lane/snapshot hooks and arbitrary comparators remain unfinished. |
| After the callback, held joins precede equality using the entry local; changed values then stage, promote, update time and walk/schedule as the source does. | SetSignalResolved plus write.setResolved. | Default/disabled equality, throw partial state, internal resolved-value and owner bound-disposer paths retain this order. |
| setMemo short-circuits held, non-manual, then txOf versus flushTransaction. | memo-write.held. | txOf only runs on the eligible arm. 4,096 actual setMemo probes include manual/non-held/joined/staged/undefined states. |
| A held updater pre-runs on committed _value; its answer enters setSignal unchanged. | memoUpdater or memoRawArgument, then SetMemoForward. | This deliberately retains the pinned function-result bug. Sixteen bound-function histories and a negative actual-flight law supplement the original source report. |
| Non-held updater uses the ordinary setter's entry previous value. | signalUpdater, then SetMemoAfter(false). | No committed-frame override is borrowed for the ordinary branch. |
| Successful held write clears CHECK, sets DIRTY, inserts the node, then schedules; other staged writes mark MANUAL_WRITE. | memo-write.finish. | Exact heap pointers/logical bucket map/flags/schedules compare to source. Exceptions unwind before the remainder. |
| onCleanup in production delegates to cleanup and returns the original function. | onCleanupValue, callable.cleanup/cleanupSetter, owner.cleanup. | Selected root-disposer/setter families preserve no-owner return and canonical aliases; getters/general callback bodies remain unfinished. |
| cleanup stores one callback, then an array, then pushes into it. | owner.addDisposal/cleanup and canonical arena IDs. | 24 original bound-disposer and 42 setter-cleanup histories compare list shape and cross-owner identity. Arena lookup is representation of function identity, not a source scheduling algorithm. |
| runDisposal detaches live/parked lists before callbacks; arrays run in reverse with callable as receiver and no arguments. | Existing owner detach/invocation tasks, CleanupBoundRoot/CleanupBoundSetter. | Bound receiver/target survives the call. A selected setter receives undefined; a memo uses setMemo(undefined). The existing zombie/frame machinery is reused, not replaced. |
| A throw stops the detached walk; source cleanup ordering and earlier writes survive. | Existing owner fault return points and caller catches/finally. | Reentry, interrupted lists, repeated disposal and held writes compare to production source. General read-capable owner suspension remains open. |

## Deliberate boundaries

Callback programs, constant lexical bindings and canonical native-function caches
represent host functions/closures in the admitted grammar. They do not replace the
source graph, heap, publication, owner walk or transaction algorithm. Binding
events name actual returned functions and are removed from reactive traces.
Function allocation, reflection, memory/performance equality and arbitrary JS
closure semantics are not claimed.

The source adapter does not derive a getter's value from a held memo setter's
final return, since the pinned extra function invocation can change that return.
Those internal getter combinations have native result/node/lifetime controls;
complete internal read traces remain an explicit observation gap. Full-history
counts exclude those controls. No runtime rule is changed to make them pass.

Both closed source-failure laws preserve their baseline and are labeled negative.
No semantic deviation or vendored-source edit is active.

## Existing PR checkout impact rehearsal

The read-only impact tool was also run against the existing PR #4163 checkout at
`82c89dab837f1f71f8391dd6323861261147afc8`, based on
`1ddd68df16b6aec1edc1c87982eb0944d0ea8831`. This is a specific local candidate,
not a claim about the latest remote next. [Recorded report](function-values-impact.json).

The tool finds changes in setMemo, setSignal and createSignal and points to the
new Bend mappings. Manual inspection confirms three relevant differences:

- The PR wraps the held updater answer before delegating to setSignal. A future
  audited repin must update SetMemoForward, retain the pre-call location, and
  replace the negative result law with the accepted upstream behavior. No fix
  has been applied to the pinned runtime in this session.
- The candidate's write hook receives the target node. Active hook support and
  its caller ABI need review; an inactive-hook test does not prove that support.
- Its data constructor calls signalHook before returning the pair. That new
  installer path must remain explicit in a repin audit, alongside related
  module/flag/initializer changes.

Other changed files and units in the recorded report also require review. This
rehearsal verifies that future changes can locate these definitions; it does not
approve or perform a source repin.
