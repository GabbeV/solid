---
"@solidjs/signals": patch
"solid-js": patch
---

Give plain stores the same nested wrapper isolation as derived stores. Nested writes and `affects` declarations stay within the targeted store; upstream writes and marks still propagate into its views. Separate stores over one raw object now have separate proxy identities.
