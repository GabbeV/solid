# Correctness verification before optimization

The user requests fixing correctness issues first, using supervised Sol agents
at medium reasoning for discovery and implementation, with semantic decisions
reserved for the user. Starting checkpoint: cf6f20b00.

The previous investigation demonstrated failures of hypothetical optimizations,
not newly confirmed defects in the retained runtime. Do not describe those
rejected algorithms as current bugs. Establish a public-API failure before a
runtime fix; otherwise add only meaningful missing regression coverage.

## Tasks

1. Observation lifecycle: turn the collection/reentrancy concern into a bounded
   runtime scenario. Check the current live worklist under observation creation
   during a comparator, retirement, and disposal. Distinguish supported behavior
   from a semantic question; do not silently forbid comparator reads.
2. Creator retry and publication: verify relevant guards on retained/current
   code using existing tests plus one discriminating timeline if needed. Focus
   accepted private work, retained children, request reuse and cleanup. Do not
   implement the proposed simplifications.
3. Upstream repro controls: exercise the four just-filed scenarios on this branch
   with controlled gates/public APIs, asserting actual published snapshots and
   completed request arguments. Report unexpected differences before classifying
   them as a semantic change.

Each discovery agent owns a uniquely named test file and scratch directory.
Run only focused source tests, maxWorkers=1. No shared builds, dependency installs,
benchmarks, broad suites, commits or pushes. Send a compact checkpoint before
runtime edits. Primary reviews failure and proposed fix, assigns exclusive source
ownership, and asks the user about consequential semantic decisions. Cross-review
accepted fixes and complete focused production/adjacent validation serially.
Primary handles commits/pushes; the installed repository-wide formatter hook
must not be run. Preserve unrelated work and keep optimizations deferred.
