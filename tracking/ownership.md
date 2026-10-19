# Ownership and context milestone

The active callback machine now executes production `runWithOwner`, `getOwner`,
`getObserver`, `isDisposed`, and callback-based `createRoot`. The root literal is
shared in `runtime/owner-state.bend`; `construct.createOwner` delegates to it so
constructor probes and nested callback allocation execute the same definition.
Source field defaults, parent link, nearest-computed forwarding, context and
transparent configuration remain in their original order. Hydration IDs and
dev/observe hooks remain outside the production grammar.

`WithOwner` evaluates its owner argument before entering the scope. EnterOwner
saves the old owner/tracking and installs the new owner with tracking false;
RestoreContext runs on both normal and exceptional return. RootScope allocates a
real child of the ambient owner and invokes its initializer through that same
scope boundary. A null ambient owner detaches it. Inline root bodies retain the
enclosing compute's previous value as lexical data, rather than as an init
argument. Initializers now receive their real bound disposer argument, represented as a
selected function family; see [arguments.md](arguments.md). Arbitrary closure
capture remains unfinished. A typed root
handle can separately invoke its actual dispose method (`disposeRootSelf`,
self=true), through the existing owner teardown machine.

`OwnerReference(id)` represents native owner object identity separately from
opaque application references. Only owner/observer access, equality, truthiness,
storage, error causes, runWithOwner and the admitted root disposal operation are
exposed. Arbitrary property/method reflection is not implemented. Host codecs
retain each runtime's object identity. Known owner names normalize observations;
anonymous inline-root observations normalize by first observation. Alias tests
also assert actual within-runtime object identity. Raw native Error objects with
an opaque user `owner` property remain native errors.

The host exposes named root construction and optional owner selection for memo
and effect constructor calls. Source calls use real public APIs. A lazy memo's
name can be associated with its actual newly linked native node by read-only
parent-head observation, before the body first calls getOwner. No source field or
function body is rewritten. The read trace now observes the actual ambient
nearest-computed owner; the former callback-origin label was inaccurate once
runWithOwner changed the ambient context. This is an observation repair, not an
engine behavior change.

73 differential histories compare return/throw values, roots' actual fields and
links, callback order, computed node state/height, cleanup attachment, data/error
owner identity, pending owner arguments, inline-root pending reads, detached
lifetimes, nested root forwarding and exceptional ambient restoration. The
`captured_root_disposes` closed law runs real root allocation, captures its owner
in a signal, flushes, invokes its dispose method and checks exactly one cleanup,
parent unlinking, cleared disposal and restored ambient state. It is one concrete
execution, not a general ownership/lifetime/progress theorem. Three compiled
mutations exercise tracking restoration, observer gating and root attachment.

Nested signal/memo/effect construction inside callbacks, arbitrary functions,
teardown expression suspension, arbitrary callbacks and active context-provider /
boundary / lane / snapshot scopes remain unfinished. The deviation register is
unchanged and empty; both upstream counterexamples remain baseline-preserved.
