# Nested primitive construction

`MemoRead{compute, options}` denotes `createMemo(compute, options)()`. Every
evaluation allocates a fresh memo under the current owner. Its accessor does not
escape this expression; general first-class accessor/closure handling is still
unfinished. This is a restricted input domain, not a caching or allocation change.

`EffectCreate{compute, spec}` denotes `createEffect` or `createRenderEffect` with
admitted compute/application/error programs and static returned cleanup. It
returns undefined only after the source call completes. Both expression families
capture callback arguments as user-code data; `Previous` refers to the new compute
body's own previous value.

`runtime/construct-state.bend` contains the production literals and shared
`setupComputedNode` prefix. Source order remains: literal, optional unobserved
extension, self prevHeap, owner child link, root-forwarded height, then eager
recompute unless lazy. The standalone facade and nested continuations share these
definitions. Nested effects use the ordinary initial recompute and source
pending-slot/defer/lane gate before the render-versus-user queue choice. Existing
catch/finally frames and caller operand-stack handling apply throughout.

Render output-target attachment is mechanical user-ABI instrumentation, as in the
top-level facade. Construction observations label actual node identities after
execution and are filtered from the callback trace. Source labels are assigned at
the matching actual create calls. These annotations introduce no host allocator,
dependency rule, owner boundary or scheduler. In particular, immediate render
application retains the creator's actual context/tracking; queued application
runs in the source queue's ambient scope.

158 differential histories compare actual pinned create calls:

- 68 memo histories cover eager/lazy, transparent/sync, two-level construction,
  captured arguments, application callbacks, copied contexts, root parentComputed,
  errors/recovery, unobserved callbacks and pending/loading under a retained root.
- 90 effect histories cover user/render, schedule/defer, initial queue order,
  parent reruns, disposal before initial application, arguments, error/logging/
  recovery, cleanup, async compute, nested memo children and held creators.

Comparisons include node fields, heights, known owner/sibling aliases, retired
children, returned/thrown results, callback order, screens, reports and ambient
restoration. Three closed Bend laws check concrete child replacement/retirement,
queued first application and disposal before that application. Seven compiled
mutations check nested ownership, captured arguments, initial eager execution,
inherited tracking and the staged first-application gate.

Pending children need an appropriate lifetime. Recreating an async child whenever
its previous instance settles can continually start fresh async work. Pending memo
settlement tests retain their child under a root; the runtime preserves source
allocation behavior rather than stabilizing such a recreating program.

Nested signals, escaping new accessors/setters, arbitrary lexical closures,
dynamic returned cleanup selection and expression reads in owner teardown remain
unfinished. Custom comparators, option getters, dev/observe, hydration, external
and snapshot hooks retain the constructor restrictions in the correspondence.
Both upstream counterexamples and the empty deviation register remain unchanged.
