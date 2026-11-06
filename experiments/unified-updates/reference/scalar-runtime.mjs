// Executable scalar adapter for the consolidated experiment and cost probes.
// Not a Solid package entry: Loading, callback observation, latest and automatic
// microtask scheduling are deliberately absent. Call flush after writes.
import { UnifiedScheduler } from './unified-scheduler.mjs';
const scheduler = new UnifiedScheduler({ trace: false });
const NODE = Symbol('scalar node');
let root = null, currentAction = null;

function accessor(node) {
  const read = () => {
    if (scheduler.current) return scheduler.activeRead(node);
    if (node.inputsPublished) throw new Error('The current inputs have no published answer yet');
    if (node.frame?.error) throw node.frame.error;
    return node.frame?.value;
  };
  read[NODE] = node;
  return read;
}
function own(node) {
  if (root) root.nodes.add(node);
  if (!node.fn && scheduler.current) scheduler.onCleanup(() => scheduler.dispose(node, false));
  return node;
}
export function createRoot(fn) {
  const previous = root, scope = { nodes: new Set(), cleanups: [], disposed: false };
  root = scope;
  const dispose = () => {
    if (scope.disposed) return;
    scope.disposed = true;
    for (const node of scope.nodes) scheduler.dispose(node, false);
    scope.nodes.clear();
    for (const cleanup of scope.cleanups.splice(0).reverse()) cleanup();
    scheduler.flush();
  };
  try { return fn(dispose); } finally { root = previous; }
}
export function createSignal(value, options = {}) {
  const node = own(scheduler.source('signal', value));
  const read = accessor(node);
  return [read, value => {
    const previous = node.candidate?.ready ? node.candidate.value : node.frame.value;
    const next = typeof value === 'function' ? value(previous) : value;
    const equals = options.equals === false ? null : options.equals || Object.is;
    if (!equals || !equals(previous, next)) scheduler.write(node, next, { group: currentAction });
    return next;
  }];
}
export function createMemo(fn) {
  return accessor(own(scheduler.memo('memo', () => fn())));
}
export function createRenderEffect(fn, publish) {
  own(scheduler.memo('effect', () => {
    const value = fn();
    scheduler.onPublish(() => publish(value));
    return value;
  }, { effect: true }));
}
export function createOptimistic(input) {
  const producer = input[NODE] || createMemo(input)[NODE];
  const output = own(scheduler.optimistic('optimistic', producer));
  return [accessor(output), value => {
    const boundary = scheduler.boundaries.get(output);
    const action = currentAction || (boundary.scope && !boundary.scope.done &&
      [...scheduler.root(boundary.scope).members].find(group => group.ownScopes.size));
    if (!action) throw new Error('This adapter requires a live generator action');
    scheduler.guess(output, value, { action });
    return boundary.value;
  }];
}
export function action(fn) {
  return (...args) => {
    const scope = scheduler.begin();
    let iterator;
    const enter = work => {
      const previous = currentAction; currentAction = scope;
      try { return work(); } finally { currentAction = previous; }
    };
    const resume = (value, failed = false) => {
      let step;
      try { step = enter(() => failed ? iterator.throw(value) : iterator.next(value)); }
      catch (error) { scheduler.close(scope); return Promise.reject(error); }
      if (step.done) { scheduler.close(scope); return Promise.resolve(step.value); }
      return Promise.resolve(step.value).then(value => resume(value), error => resume(error, true));
    };
    try { iterator = enter(() => fn(...args)); }
    catch (error) { scheduler.close(scope); return Promise.reject(error); }
    if (!iterator || typeof iterator.next !== 'function') {
      scheduler.close(scope);
      throw new Error('Only generator actions are implemented by this adapter');
    }
    return resume();
  };
}
export function isPending(input) {
  if (!input[NODE]) throw new Error('Callback observations are not implemented by this adapter');
  return scheduler.isPending(input[NODE]);
}
export function onCleanup(fn) {
  if (scheduler.current) scheduler.onCleanup(fn);
  else if (root) root.cleanups.push(fn);
  else throw new Error('No owner');
}
export function flush(fn) {
  const result = fn?.(); scheduler.flush(); return result;
}
