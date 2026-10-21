# Custom equality callbacks

Source: core/core.ts:isSame, setSignal and recompute; core/async.ts:handleAsync's
asyncWrite; core/scheduler.ts:GlobalQueue.settle, at Solid b0ad1df5 (rc.16).
The source pin and semantic deviation register are unchanged.

## Representation and source return points

The existing Node.equals flag retains the strict/default and disabled arms.
A NodeOptions.comparator program ID and World.comparators side arena represent
original custom function identity. Constructors register that identity before
computed setup/evaluation. This metadata does not allocate a source NodeExtension
or alter whether `_x` exists. It is a decomposition of `_equals`, not a new
reactive node or source operation. IDs refer to the same named callback programs
used by other callback positions; the host passes the original cached function
to native Solid without a comparator wrapper.

runtime/core.bend:isSame keeps the default/disabled fast arm. Its custom arm
suspends on CallWith(original callback, old value, new value), retaining caller
operands. EqualityCatch implements the source catch: NotReadyError answers the
actual undefined value, which callers treat as changed. Other throws notify the
node's error status and answer true. An exception from that notification escapes
the comparator catch. Callback results retain their original truthiness; promises
and functions are data, not awaited or invoked as verdicts.

Source call sites resume independently:

- setResolved captures the updater entry value, performs the held join, skips
  comparison for uninitialized/shown-error cases, then SetSignalCompared resumes
  staging with live node fields. Both suppressed and published writes return the
  proposal. Bound setter cleanups use this same continuation.
- publishState and PublishCompared implement recompute's short-circuit gates,
  comparator call and publication/settlement remainder. Publication remains
  outside the computation-body catch. Its errored local is captured before the
  comparator: no additional live-error gate is inserted afterward, even if the
  callback re-errors the node. The original height/self-settlement tail remains.
- asyncWrite retains identity/dirty guards and landStatus before the comparison;
  asyncWriteAfterValue retains trim, scheduling and callback settlement afterward.
  Returned function values remain data at the source constant-wrapper boundary.
- ParkIntake captures the pending intake length. It checks loading/eligibility,
  pending status, parked children and disposal before invoking the comparator.
  ParkCompared then clears equal staging or holds the node/frame, and continues
  from the same captured index. Exceptional exits skip later clears as source does.

The old World-only equality/write/flight/seam helpers remain usable for default
or disabled comparison. When a helper cannot suspend but would need a custom
callback, it fails explicitly (Unsupported 23). Public constructor/read/write/
flush/async/disposal paths use the shared continuation driver. These internal
facades are not claimed as complete public entry points for custom callbacks.

## Evidence and scope

134 public histories compare results, errors, callback traces, state, extension
presence, original comparator identity, dependency order, displays and reports.
They cover truthy/falsy verdicts, arguments, callback reads/writes, pending reads,
ordinary thrown payloads and existing StatusError reuse, memo publication, native
and immediate async landings, held seams and pending owned children, raw function
verdicts and results, no-argument setter cleanup and ignored effect equality.
46 direct comparisons invoke unchanged native isSame against the same callback
programs. They check the raw returned verdict, including undefined for NotReady,
and strict/disabled equality on NaN, signed zero and opaque identities.
The native error observer now labels plain-signal StatusError source pointers
through accessor identity, without installing those nodes in computed probes.

Four closed executions of the actual public Bend APIs check equality suppression,
changed publication, ordinary error status and pending-comparator publication.
Five quantified local laws prove the default fast arm, exact custom-call arguments,
NotReady return, ordinary error routing and preservation of every World field
except registry metadata during registration. These do not prove arbitrary
comparator termination or global graph correctness. Ten compiled mutations
exercise constructor registration, call arguments, pending/error catches, async
landing, seam guards, initialization gates, setter returns and cleanup routing.

The admitted option is `{equals: {callback: 'name'}}` for a previously registered
program. Programs use the existing expression/callback ABI and may read/write
admitted signals. Arbitrary JavaScript closure environments, dynamic comparator
replacement, option getters and comparator functions represented as other native
bound-value families remain unfinished. Active lanes, boundaries, snapshots,
store hooks and dev diagnostics remain outside this milestone. No source bug was
fixed or worked around by this translation.
