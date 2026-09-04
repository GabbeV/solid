---
"@solidjs/signals": patch
"solid-js": patch
---

Type functional setters for derived signals and optimistic signals with a possibly undefined previous value until the derivation first commits. Direct setter values and signal getters remain the resolved value type; providing `loadingValue` keeps the previous value initialized.
