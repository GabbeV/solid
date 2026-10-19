# Public promise watchers: resolve and refresh

The pinned production `signals.ts:watch`, `resolve` and `refresh` now execute for
expression callbacks and accessor targets. This is a restricted port, not full
public API parity: store targets, arbitrary JS callbacks, active lanes/guesses,
deferred-truth hooks, and native promise assimilation of a returned thenable are
outside the admitted protocol.

## Correspondence

`runtime/signals.bend` preserves the public constructor/owner boundary:

- resolve constructs its promise machinery and root/watcher immediately. Escaping
  creation exceptions reach its promise executor catch; ordinary expression errors
  are watch answers. Resolve disposes its captured root on delivery.
- refresh calls markRefresh synchronously, captures flushTransaction, then emits
  a WatchStart microtask. The fresh watcher is created under a new root with
  CONFIG_FRESH_READ | CONFIG_AUTHORITATIVE set for its first pass. This preserves
  same-tick coalescing. It captures its own node before its first read, even if that
  read suspends. Delivery disposes the watcher node. Invalid targets resolve
  undefined in the admitted production branch.
- watch sets CONFIG_REDERIVE only after the constructor's eager pass. The truthRead
  and truthConfirmed installer stores are retained as stable known-function tags;
  their active lane/guess calls remain an unfinished scope.

Core WatchExpr / WatchFinish represent the actual watch callback body. The active
user expression executes through the same expression machine and callback protocol.
NotReady rethrows to core's pending catch. Other errors are unwrapped once, then
follow the same frame rule as success. A partial expression's value stack is
restored on the catch edge. Refresh's guessed-target check is retained; the full
truth interpretation of active guessed/lane inputs is not admitted yet.

`watch-state.queueAnswer` retains the joined-frame rule before either answer:
mainline/foreign-frame readers call staleReader and wait for commit, while the
reader of its own transaction may deliver. Redirects resolve in source order;
FRAME_READ prevents duplicate rerun registration. No wait-for-all barrier replaces
this decision. The field `own` is captured at the public source sites.

WatchDelivery is a queueMicrotask request. PromiseOutcome is synchronous native
Promise resolve/reject IO, emitted BEFORE disposal. The host performs that outcome
while draining the IO outbox, without inserting an extra microtask; native `.then`
reactions then run normally. Queued duplicate callbacks still dispose their target,
while the native promise's first answer wins. This ordering includes cleanup throws
and cleanup writes that schedule a later flush.

## Evidence

158 public histories, including 96 seeded generated schedules, compare returns,
throws, node state, traces/text, native promise observer delivery, screen state at
that observer, reports, host callback failures, and ambient restoration after every
operation. Cases cover nullish/false/NaN/reference answers, raw/status errors,
loading seeds, lazy targets with no external observer, rooted pending watchers,
multiple/superseded/equal-value flights, same-tick refresh calls, dead targets,
stream landings and both immediate/deferred settlement. They observe microtask
turns without awaiting unresolved external promises.

6,144 focused watch-body comparisons call the actual captured TS watch closure
and the matching Bend body continuation. Synthetic own/flush/pass transactions,
redirect chains, JOINED/FRAME_READ combinations and six answer/error classes cover
the delivery gate, unwrap and NotReady branches. Source functions are not rewritten:
tests append a private export/reset only, and capture queueMicrotask as host IO for
this direct body probe. This is not an end-to-end action API claim.

24 additional read comparisons check the source's post-pull CONFIG_VERDICT bit
store into a memo reader's FLAGS (including the source numeric bit), and its absence
for render/user effects or untracked reads. This repairs a previously listed port
omission; it does not implement verdict windows or lanes.

The reference host uses native promise reactions and queueMicrotask. Its scoped
job observer catches exceptions escaping source microtask callbacks, matching
Bend's explicit host outcomes without changing the engine body or job ordering.
This lets a rejection that halts a render be compared without terminating Node.
The user promise may already have resolved before cleanup throws; that result is
retained on both sides. Two new mutation checks reject eager refresh-watcher
creation and delivering a watch promise directly from the pass: ten broken variants
are rejected overall.

## Interface and limitations

`api.markRefresh` is the internal invalidation helper; `api.refresh` / refreshValue
is the public deferred watcher entry. The host's refresh is fire-and-forget, and
awaitRefresh(name,target) records the returned native promise by name. awaitValue
likewise records resolve(fn)'s promise. promise(name) returns it. Host async IO must
be enabled (`BendRuntime({async:true})`) to deliver jobs.

Public helper results are admitted payloads. A returned external thenable would
require the native Promise resolution procedure, including interleaving its then
subscription with the engine's observers. That richer host protocol remains open;
the adapter explicitly refuses it instead of returning a thenable token as the
settled answer. Accessor reads of ordinary async memos resolve their payloads and
are covered. Arbitrary store targets, timeout/abort/until, inPass callbacks and
active truth/lagging scopes remain unfinished.

No new async semantic proof was added. Existing composed kernel laws still check
through this runtime. These tests and source-operation mappings support fidelity;
they do not establish formal TypeScript/Bend equivalence or general progress.
