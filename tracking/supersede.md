# Internal supersession hook and exact flight slots

The production `core/async.ts:onSupersede` helper is now translated in
`runtime/supersede.bend`. This is an internal helper, not a new signals export.
The guard requires a current computed owner in REACTIVE_RECOMPUTING_DEPS.
A first hook is stored directly; an existing hook is captured in a programme
representing the source prev()/fn() try/finally closure. The existing callback
machine invokes both functions, keeps their order and lets a second throw
override the first. Successful invocation returns undefined to its caller.

Source recompute compares `_x?._inFlight` before/after the computation. That
requires three distinct states: an absent/undefined slot, null, and an active
result identity. NodeExtension.inFlight and PassFrame.oldFlight now use the
Flight sum type. The ordinary identity/truth guards retain their numeric ID
projection; only the self-registration comparison uses the complete slot.
A freshly allocated extension starts null. onSupersede restores undefined only
when it allocated that extension, exactly as the source comment requires.
No scheduler, publication, ownership or async algorithm is substituted.

3,456 private-helper controls call actual unchanged Solid with matching owner,
flags, extension and flight posture. They compare direct versus chained callback
identity, existing active flights, call order, both thrown errors and the return
stack. They include inactive/unowned/root/signal contexts. These are synthetic
helper states and do not increase the 3,952 public-history count.

Fifteen scoped kernel roots quantify flight-slot reflexivity/distinction,
identity projection, absent-slot lookup, ineligible/no-owner preservation,
whole-World chain allocation, its exact identity and finally entry/return/throw/
restore/override/continuation behavior. They do not prove arbitrary graph or
stream progress. All preceding complete programme domains and sufficient
budgets remain unchanged; canonical data are regenerated for the richer slot
representation, and three scalar/chain cut frames now name undefined explicitly.

Five new compiled negative variants target fresh null aliasing, callback order,
first-error loss, the undefined callback return and the slot-distinction theorem.
The preceding complete 534-variant stream checkpoint has its own frozen receipt
in reviews/deferred-stream-complete-negative.json. This checkpoint configures
539 variants (450 finite, 89 kernel); those receipts are not interchanged.

During development the strengthened return-stack assertion exposed a missing
callback-tail continuation in the draft chain. The final path and its generic
continuation theorem retain it. Initial compile/probe/diagnostic attempts are
not credited as evidence. No upstream bug, workaround or deviation is added.
`from` subscription/wrapped-iterable wiring remains the next implementation step;
arbitrary JS callable/protocol bodies, stores, boundaries and snapshots remain
outside the admitted profile.
