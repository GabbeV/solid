# Stage 41: lower joins and revisable pending membership

This checkpoint was reconstructed after the workspace interruption. The local
code and audit results survived. The full reference suite was rerun successfully
when the workspace returned.

The accepted c-above-a-and-b rule was first implemented by preparing fresh lower
work before committing to an apparent upper peer join (`scheduler.mjs`). That
handled the synchronous discovery case, but not a lower connection revealed by
an async answer after an upper peer join had already occurred.

`revisable-scheduler.mjs` retains original pending identities and join records,
then reconstructs lower membership before replaying higher joins. This supports
replacement of an unpublished q=12 calculation with q=10 after a lower a/b
connection becomes known. It keeps one eligible candidate per node, cleans up
superseded owned children and releases stale tokens' coordination payloads.
The original scheduler tests, finite conditional/diamond campaigns, actual owned
children, errors and open scope identities were exercised. The models are
scan-based research code; no production performance or bundle claim follows.

The crossed-child audit then exposed a larger problem with inferring hierarchy
from active joins. Without an a/b join, c+b and d+a could attach one child to the
other parent, allowing only one child to publish early. The user subsequently
ruled that BOTH children should publish using committed parents, independent of
whether a and b have entangled. This supersedes the open question at the end of
that investigation. It motivates testing a direct layer-position model rather
than adding more conditions to provisional join replay.

See [stage 42](COORDINATION-42.md) for the next experiment. The production runtime
was not modified by either reference-model stage.
