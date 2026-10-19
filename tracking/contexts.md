# Owner context records

`runtime/context.bend` translates production core/context.ts createContext,
getContext and setContext. The older ambient owner/tracking helpers now live in
runtime/ambient.bend. They are separate source concerns: context.ts operates on
an owner's `_context` data record; runWithOwner installs an ambient owner.

ContextKey arena identities represent fresh native Symbol keys. Defaults and
optional string descriptions are retained. Context keys are immutable in this
ABI and referenced by stable host names; arbitrary Context object reflection,
mutable properties/default getters and general symbol values are unfinished.
Descriptions do not determine identity. `ContextRecord` IDs represent the actual
spread-created objects. Every successful write allocates a fresh record, even
for an equal value. Other symbol entries preserve value identity and insertion
order. Node.scope is the inherited record pointer used by roots/computeds; a
parent's later write does not update existing children. A child override leaves
its parent and siblings unchanged. Signals' inert owner fields remain unused.

The source rules remain explicit: a missing owner throws before record lookup;
only undefined falls back to a default (null remains a provided value); a still
undefined read throws ContextNotFoundError; a write of undefined uses the default.
An omitted or explicitly undefined owner parameter resolves to the current owner,
whereas null means no owner. Set arguments evaluate value before owner. Context
writes perform no reactive scheduling; user expression reads still track normally.
A context value can itself be async data or an admitted bound disposer function.

NoOwnerError and ContextNotFoundError have distinct fresh identities and native
Error subclasses with production empty messages. Runtime allocation, wrapping,
message capture, thrown cause/data identity and host materialization are separate.
Dev diagnostics/stack cost and arbitrary error property mutation are unfinished.
The host's callable/error codecs do not implement context lookup or publication.

52 differential histories compare public source calls, returns/throws, all named
owners' actual symbol entries/order and pairwise record aliasing, inherited
computed state, default/null/undefined rules, argument order, pending values,
function data and repair/re-entry. Independent checks assert fresh native errors
and fresh record identity even on an equal write. Stable host context names are
unique; this is an input binding restriction, not a restriction on native context
descriptions or fresh key allocation.

Two closed laws, context_records_are_snapshots and
context_child_override_is_isolated, construct actual roots through the runtime,
write/read the real context module and check record identities and values. The
old child retains 11 after its parent changes to 13; a new child receives 13;
overriding the old child with null leaves parent and sibling at 13. They also
check empty pending work and ambient restoration. These concrete executions do
not prove a general context/ownership/TS-equivalence theorem. Four compiled
mutations cover null fallback, in-place records, dropped inheritance and a
missing-owner read that wrongly succeeds.

Local data signal/memo/effect construction now executes; see [locals.md](locals.md).
High-level component/provider APIs, escaping accessors/setters,
teardown expression suspension and active boundary/lane/snapshot scopes remain
unfinished. No semantic deviation or source workaround is active.
