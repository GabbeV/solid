# Store structure review reproductions

- Array push then shrinking input: https://s.olid.uk/id/13a5c949-d084-457c-8c35-5b7b45bce115
- Ordinary nested setter before child's first answer: https://s.olid.uk/id/6dfe2fc6-e78f-4c39-b13e-caa29592f82f

Both use unmodified next dfb18120a407f7b505bfd7cde25c745d8d965932, development mode.
The runtime is bundled from that exact checkout and embedded as a data module in
the playground import map; the commit's normal mirror/CDN artifact returned 404.
No experiment runtime code is included. Hosted Chromium verification checks the
actual import-map URLs and the DOM timeline after the editor's initial rebuilds
settle. Source probes also compare the previous next baseline, production flags,
and relevant open patches. The editor cannot fetch TypeScript declarations from
a data-module URL; this does not affect runtime reproduction.

`issue.md` and `issue-url.txt` contain an unsubmitted ordinary-store bug report
and its prefilled GitHub form. The form was queued for user review, not submitted.
See ../../STORE-STRUCTURE-REVIEW.md for findings and alternatives.
