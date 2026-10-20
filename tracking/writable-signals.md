# Function-initializer signals and setMemo

`SignalComputeScope(compute,options,body)` represents the common const-pair form
`const [get,set] = createSignal(previous => expression, options)`. The initializer
is an admitted callback expression closing over enclosing arguments/locals;
its new const pair binds only in body. Selected first-class bound function initializers now also enter this overload;
see [callable-initializers.md](callable-initializers.md). Self/TDZ references,
arbitrary callable/closure values and reflective options remain unfinished.

## Construction and binding

The source overload calls computed(first,second), then clears CONFIG_AUTO_DISPOSE,
then returns accessor(node) and setMemo.bind(null,node). The port runs the shared
computed constructor and its eager/lazy setup first. MemoSignalReady clears that
bit at the source return point and binds the actual pair. It does not turn the
computed into an unowned data signal. Data and computed constructors keep their
separate literal, ownership and flag behavior.

An initial compute error is usually stored on the computed: the constructor can
still return its pair, whose getter then throws the stored error. The tests check
that distinction from an enclosing callback throwing after construction. Source
lazy activation is preserved too: a write before the first lazy accessor call
can be followed by that first derivation. No stronger write-wins rule is imposed.

AccessorBound and SetterBound are user-ABI allocation observations, not new
reactive decisions or source node fields. They name the functions actually bound
at the constructor return point, for canonical native aliases and symbolic token
round trips. A read-only memo has no setter token. These events are excluded from
public reactive traces. The TypeScript adapter retains the real native functions
and reads their existing target metadata only for identity/state observation.

LocalWrite now calls the actual bound function value through InvokeWith, so a
local function-initializer signal cannot accidentally use the data setter.
SetterReference captures a unique constructor-selected target: data nodes enter
setSignal, admitted writable memo nodes enter setMemo. Read-only memo setters
are never constructed by the admitted API. Getter and setter identities remain
separate even for the same node.

## Source setMemo policy

`runtime/memo-write.bend:held` keeps the source short-circuit order: CONFIG_HELD,
not REACTIVE_MANUAL_WRITE, then txOf versus flushTransaction. It does not allocate
an extension or resolve a transaction on the inactive arms. The core callback
continuations preserve the updater call sites:

- A held derivation's updater runs first against the committed value, before
  delegating to setSignal. Its answer is passed as the source passes it.
- Other updaters delegate to the ordinary setter's captured entry-value path.
- A successful held write clears CHECK, sets DIRTY, inserts the actual node into
  the dirty heap and schedules. Other successful writes mark MANUAL_WRITE when
  staging is present. A throw skips that remainder.
- An async landing still uses the original internal value setter; it does not
  become a user proposal by calling setMemo.

The pre-call's returned function is invoked again by setSignal on the pinned
source. The port deliberately preserves this reported failure, including an
unexpected bound-disposer invocation/throw. See SOLID-HELD-FUNCTION-VALUE-003 and
PR #4163. There is no wrapper fix, local patch or active deviation in this runtime.

## Evidence and limits

Eighty-one complete differential histories compare the pinned package: values,
eager/lazy construction, options, captures, manual writes, rerun previous values,
unobserved/revival, owner disposal, writes to dead targets, stored initialization
errors, pending construction, native/immediate flights, streaming updates/close,
function data and the held committed-frame policy. Sixteen of those histories are
paired bound-function counterexamples/controls for the reported function-result
bug. They explicitly assert its setter result, selected previous frame and
unexpected root disposal; arbitrary replacement functions in the original twelve
source-only controls remain outside this selected Bend function family.

Additional native controls compare aliases/token round trips, stored-error pair
availability, read-only setter rejection, caller failure after construction and
nested getter/function results. Complete read traces for accessors invoked inside
setMemo are not yet observed by the reference adapter. In a held call the final
setter result may differ from that accessor's result, so the adapter does not
fabricate a read value from the final return. Those combinations have direct
native result/node/lifetime controls and are not counted as complete histories.
No reactive decisions or runtime behavior are changed to satisfy that observer.

4,096 new probes call the actual TypeScript setMemo with raw/identity/constant
updaters across held/non-held, manual flags, staged/undefined values, statuses,
joined flushes, contexts and queues. They compare exact heap pointers, schedules
and logical bucket entries in addition to node/transaction state. Sparse JS holes
and explicit Bend empty slots normalize to the same logical bucket map. The old
4,096 held probes remain separate and now also compare those heap fields.

Constructor comparisons now include 1,536 actual createSignal(fn) cases (10,752
constructors total), including options, loading presence, parents and the exact
auto-dispose clearing point. Existing restricted source branches remain open for
individual review; these probes do not close them automatically.

One closed kernel law follows a manual proposal of 10 into rederivation with input
3, displaying 13 through a real writable constructor and render. It checks bound
identities, owner/dependency links, the cleared auto-dispose/manual bits, slots,
queues and ambient restoration. Another law is explicitly negative: a real held
flight makes an updater-returned disposer unexpectedly kill its target. It checks
that pinned failure, not desired function-storage correctness. The two negative
laws in the suite are upstream baseline evidence, not successful guarantees.

Six added mutations check scope shadowing, auto-dispose clearing, committed-frame
updaters, an unregistered function-result workaround, manual flags and the actual
held heap insertion. Existing mutation targets follow the shared updater helper.
Active hooks/lanes/snapshots, general function values and expression-capable owner
teardown remain unfinished. Source pins and the empty deviation register are
unchanged.

Selected writable-memo setters can now be registered with onCleanup; their
no-argument call runs the same source held/manual policy in the existing owner
machine. General getter/expression teardown remains open. See
[setter-cleanup.md](setter-cleanup.md).

Selected first-class getter/setter/root-disposer initializers now take the real
function overload and share writable-computed construction and selected setter
policy; see [callable-initializers.md](callable-initializers.md). Arbitrary
functions and read-capable owner teardown remain unfinished.
