import { registerHooks } from 'node:module';
const replacement = new URL('./stable-scheduler.mjs', import.meta.url).href;
registerHooks({
  resolve(specifier, context, nextResolve) {
    if (specifier === './unified-scheduler.mjs' && context.parentURL !== replacement)
      return { url: replacement, shortCircuit: true };
    return nextResolve(specifier, context);
  }
});
