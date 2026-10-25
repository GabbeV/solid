# Action waits through other observer clients

The constructed action wait invariant now admits four additional actual source
helpers between registration/mark transitions: `flight.syncFulfilled`,
`flight.syncRejected`, `iterator-state.newStepObserver`, and
`iterator-state.ignoreThen`. They write captured results, allocate a stream-step
closure, or subscribe to a returned thenable only to swallow rejection. The
existing quantified history/constructor/duplicate/catch roots range over this
larger event datatype. Every earlier three-operation history remains admitted.

`observer-write-frame.bend` proves arbitrary existing-slot observer record writes
retain the entire wait list and arena size; append extends the size exactly once
and retains committed content. Actual stream-step allocation returns the current
fresh arena index and captures the current stream's node/result/stream identities.
The ignored-return proof includes both immediacies and unresolved/fulfilled/
rejected results, including its queued rejection job. `observer-capture-history`
connects those facts to source helper calls, source counter results and retained
wait-range/lookup/committed observation.

The constructed wait therefore stays findable as settled through arbitrary finite
mixed histories. Duplicate **kind-zero yielded-value** callbacks retain the exact
current World, caller tasks and value stack; this includes other observers'
updated records, queued ignored-return jobs and all transaction counts. The
synchronous post-callback throw catch keeps its existing source policy. No final
World, fresh index, range, lookup or ready/settled conclusion is supplied by JS.

This does not execute the first callback or generator body, prove a complete
once-only action/flight debt ledger, admit all other observer clients as whole
operations, or execute the eventual flush/reveal. The initial mark is still a
separate operation here. Primitive record-write/append facts support other client
compositions, but `from` and deferred wrapping controllers are not added by that
fact alone. Iterator-result/final-result arms retain their different protocol.

Finite controls keep the old368 cases and six native repeated-action sequences.
408 new orders include every seven-helper prefix order through length three and
long histories up to64; 816 stale callback guards and408 caught throws pass. These
use the reserved stream-zero fallback for some unconditional helper checks and do
not assert those private states are public stream programs. Twelve separate raw
client constructions use a real iterator factory/nonzero stream and cover all six
immediacy/settlement combinations for ignored returns. They check current capture
records, subscription order, queued rejection jobs and exact stale Machines.

Seven new roots extend595 to602 while the existing helper-history domains expand.
Three compact kernel faults reject discarded wait entries and reused stream
observer identity. The full664 receipt remains pinned to fb4dd44b; the seven later
focused faults (four status/footprint plus three capture) are separate. Runtime,
source, host, execution budgets and checker limits are unchanged.
