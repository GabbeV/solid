# Nested primitive construction

The user-code expression `MemoRead{compute, options}` denotes the ordinary source
expression `createMemo(compute, options)()`. Each evaluation really allocates a
fresh memo under the current owner. Its accessor does not escape this expression;
general first-class accessor/closure handling is still unfinished. This restriction
is an unfinished input domain, not a replacement allocation or caching algorithm.

`runtime/construct-state.bend` holds the same production literals and the
`setupComputedNode` prefix shared by standalone and callback construction. The
source sequence remains: literal, optional unobserved extension, self `prevHeap`,
owner child link, root-forwarded parent height, then eager recompute unless lazy.
`runtime/construct.bend` supplies the standalone driver boundary. `core.evaluate`
supplies continuations on its existing stack for nested construction, followed by
the ordinary `ReadNode` operation. It introduces no nested interpreter or host
scheduler. Existing caught-error/finally and caller operand-stack handling apply.
Callback arguments captured by the new compute body are bound as user-code data;
`Previous` still refers to that new computation's own previous value.

68 differential histories compare against actual pinned `createMemo` calls:
eager/lazy, transparent/sync combinations, two-level construction, captured
arguments, untracked application callbacks, copied context records, roots forwarding
parentComputed, errors/recovery, unobserved callbacks, and loading/pending settlement
under a retained root. Node fields, heights, known owner/sibling aliases, retired
children, returned/thrown results, event order, screens and reports are compared.
Synthetic nested names only normalize identity observations after execution; the
host never preallocates nodes or installs a dependency/lifetime decision.

A closed Bend law checks a concrete parent rerun: the old child first updates,
then is disposed and detached; a newly allocated child has the original parent and
height and supplies the final text. Three compiled mutations test detached nested
ownership, lost captured arguments and a missing initial eager pass.

Pending children need an appropriate lifetime. A computation that creates a new
async memo every time its previous child settles can continually start fresh async
work. Pending-settlement tests therefore create the child under a retained root;
this does not alter the source's allocation behavior to stabilize the program.

Nested signals/effects, escaping new accessors/setters, arbitrary lexical closures
and expression reads in owner teardown remain unfinished. Custom comparators,
option getters, dev/observe, hydration, external-source and snapshot hooks retain
the constructor restrictions already recorded in the source correspondence.
Both upstream counterexamples and the empty deviation register remain unchanged.
