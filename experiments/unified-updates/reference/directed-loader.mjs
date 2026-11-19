// Run existing scalar contracts against the isolated alternative. Historical
// archived schedulers are deliberately not redirected.
import { registerHooks } from 'node:module';
registerHooks({
  resolve(specifier, context, next) {
    if (specifier === './unified-scheduler.mjs')
      return next(new URL('./directed-scheduler.mjs', import.meta.url).href, context);
    return next(specifier, context);
  }
});
