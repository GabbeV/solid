# affects propagates to a derived store's upstream input

Standalone reproduction using released Solid 2.0.0-rc.22. One button marks only
the derived list for 1000ms. Both the original person's and list's pending
indicators become true while the row identity comparison remains false.
Chromium 154 verified initial, held and released DOM states with no page errors.

url.txt contains the playground's supported gzip/base64url embedded-state share
link; no upload was needed. Its payload roundtrips through the playground codec.
The hosted page could not be tested because Cloudflare blocks this environment;
the identical JSX was compiled with the rc.22 compiler and run locally against
rc.22 browser packages. Tailwind disabled in the playground state.

issue-url.txt opens the GitHub bug template with fields from issue-fields.json.
Browser opening was queued for user review. The agent has not submitted an issue.
The issue text is standalone and contains no reference to the implementation
experiment. No runtime code was changed for this report.
