# Fulfillment prefix retains committed content and continuation state

This extends `8f26b5eb6b628913eb5f7d98cb1cf024dab7380a` without runtime, host,
representation, upstream source, toolchain, kernel-limit or deviation changes.

The [staging observation](committed-staging.md) is now preserved through the
actual callback-free asynchronous fulfillment prefix, including pending-source
removal, error/status clearing, effect-notifier queue/halt bookkeeping and the
held/default setter. Seven roots cover:

- Actual `Pending.landStatus` and `Flight.beginAsyncWrite` preserve all committed
  node values, the complete tree and the complete event trace for arbitrary
  represented values and finite storage.
- A result whose identity differs from the node's current flight is ignored by
  actual `prepareAsyncWrite`, preserving the exact whole World and returning false.
  Result identity is not inferred from scheduling-group identity.
- The active core `asyncWrite` default/no-override branch selects its actual fast
  path, preserves the committed observation and caller value stack.
- Its after-value boundary constructs the exact source task order: optional owner
  dependency trim, after-trim settlement, scheduling, flush, captured `then` tasks,
  then the caller's remaining work. The whole machine/task-list equality is
  checked separately from the observation projection.

The resulting machine contains real queued work. **Those tasks are not executed
by these theorems.** A retained value/stack is not a completed trim/release/flush
or a guarantee of final reveal. Pending status may clear and pending data may
advance; the full pending-graph invariant is not asserted unchanged during arrival.

## Domains and source boundaries

`pending-source-committed-frame.bend` covers actual local source/error/extension
bookkeeping. `status-committed-frame.bend` covers the clear/notifier/queue-or-halt
segments without invoking a queued effect or owner cleanup. `flight-committed-frame.bend`
composes those with actual prepare/write guards. `async-write-prefix.bend` gives
the active machine, stack and exact continuation contracts.

These laws quantify over arbitrary Worlds, storage and `R.Value`; error/fault
and unsupported direct-helper outcomes are retained, not claimed successful.
The active core bridge explicitly requires no override and a zero custom
comparator. Custom comparator callbacks, lane writes, dependent/owner release,
queued host delivery/flush, coordinated publication and fairness remain separate.
Physical identity validity and full once-only action/result/flight protocol are
not established by a projection frame.

A generic proof-only Bundle projection helper hit the pinned kernel's unsupported
runtime-dependent-template restriction. It was specialized to a Bool-result
projection, the actual result type at these boundaries. World/payload/history
domains are unchanged, and no runtime or kernel limit was altered. This is proof
organization, not a semantic workaround or an active source deviation.

## Validation

The existing 144 native-generator/Bend rendered-flight histories and all six
arrival/completion orders remain passing. On 48 zero-action-debt pending
snapshots from those public programmes, 96 forked actual core fulfillment calls
cover changed and equal results; all are accepted and 24 queue an owner trim.
They retain independently captured committed snapshots and nonempty caller
stacks, preserve their input World, and return the exact queued tail. These are
additional finite Bend boundary controls, not additional public histories or
native private-prefix equivalence. The real native/public history is not modified
or drained by the forked probes.

Two kernel negatives that drop the queued flush or clear the caller stack are
rejected. Configuration is 602 (475 finite /127 kernel); no fresh complete sweep
is claimed. No new Solid bug or semantic workaround was found. See
[the validation receipt](reviews/async-write-prefix-validation.json).
