---
"@solidjs/signals": patch
---

Let a ready scalar optimistic guess reveal after navigation has committed, then revert it without waiting for the previous request. A suspended preview can publish while its own action is still open.
