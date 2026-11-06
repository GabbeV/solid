import { UnifiedScheduler } from './unified-scheduler.mjs';
import { scenario } from './depth-discovery-audit.mjs';
class CommittedDepth extends UnifiedScheduler {
  inputPosition(boundary, seen = new Set()) {
    return this.layerOf(boundary.input, seen);
  }
}
console.log(JSON.stringify(await Promise.all([false, true].flatMap(actionLifetime => [false, true].map(reverse =>
  scenario({ actionLifetime, reverse, Model: CommittedDepth })))), null, 2));
