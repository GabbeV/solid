# Explicit latest inside pending callbacks

These probes run the unchanged next 4fe75321 development build (same runtime
source as 45648f78). They reuse the order-audit graph and controlled timeline.
No proposed runtime change is implemented by these files.

- `direct.mjs` wraps the direct sync/async callback reads in `latest`. Both
  capture 1/1/false during the revision rerun and publish that result. The
  unmodified observation wrapper still gives its outer reader 1/0/true.
- `all.mjs` applies the same explicit latest window to the inner observation
  wrapper. Its outer reader then also captures and publishes 1/1/false.
  This changes what the wrapper observes: a ready proposal instead of the
  displayed input. The separately rendered ordinary isPending(id) remains
  true during the hold.
- `conditional.mjs` extends the direct callback to select left() when id=0,
  or data() when id=1, inside that same latest window. Data's committed value
  is 0; its replacement promise will resolve to 1. At the revision rerun,
  both direct callbacks capture value=1, inside=1, sampled=false, leaf=0.
  The source is still unresolved. The sync reader replays at completion and
  publishes leaf=1; the async reader publishes the retained leaf=0. Merely
  selecting latest cannot supply an async answer that does not yet exist,
  and next's held-reader exception still suppresses pending in this case.

The leaf is captured to inspect the callback's input view. In real callback
control flow it could select another dependency instead. The probe does not
establish a general alternative contract for that case or for crossing updates.
A coherent proposed-view design would need to distinguish ready proposals from
unresolved work, and specify which update's view is being observed. A globally
latest-based query would also change the meaning of independent pending badges.
