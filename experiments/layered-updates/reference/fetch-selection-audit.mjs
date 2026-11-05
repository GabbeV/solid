import { scenario } from './depth-discovery-audit.mjs';
console.log(JSON.stringify(await Promise.all([false, true].flatMap(actionLifetime => [false, true].map(reverse =>
  scenario({ actionLifetime, reverse, fetches: true })))), null, 2));
