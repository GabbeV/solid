import { pathToFileURL } from 'node:url';
const { action, createRoot, createSignal, createOptimistic, createMemo, createRenderEffect, flush } =
  await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const enabledGate = Promise.withResolvers(), deepGate = Promise.withResolvers(), peerGate = Promise.withResolvers(), end = Promise.withResolvers();
const inputRequests = [], requests = [], displayed = {}, checkpoints = [], actions = [];
let guessFirst, guessDeep, guessPeer, guessView, setTrigger, dispose;
createRoot(cleanup => {
  dispose = cleanup;
  const [base] = createSignal(0), [trigger, changeTrigger] = createSignal(false);
  const [first, writeFirst] = createOptimistic(base), [deep, writeDeep] = createOptimistic(first);
  const [peer, writePeer] = createOptimistic(base);
  const enabled = createMemo(() => trigger() ? enabledGate.promise : false);
  const input = createMemo(() => {
    const value = enabled() ? deep() : 0;
    const gate = Promise.withResolvers(); inputRequests.push({ value, ...gate }); return gate.promise;
  });
  const [view, writeView] = createOptimistic(input);
  const holdDeep = createMemo(() => deep() === 2 ? deepGate.promise : deep());
  const holdPeer = createMemo(() => peer() === 20 ? peerGate.promise : peer());
  const pair = createMemo(() => [view(), peer()]);
  const label = createMemo(() => {
    const key = pair().join(':');
    if (key === '0:0') return key;
    const gate = Promise.withResolvers(); requests.push({ key, ...gate }); return gate.promise;
  });
  for (const [name, node] of Object.entries({ trigger, enabled, first, deep, peer, input, view, holdDeep, holdPeer, pair, label }))
    createRenderEffect(node, value => { displayed[name] = value; });
  [guessFirst, guessDeep, guessPeer, guessView, setTrigger] = [writeFirst, writeDeep, writePeer, writeView, changeTrigger];
});
inputRequests[0].resolve(0); await turn(); flush();
const start = (write, value) => { actions.push(action(function* () { write(value); yield end.promise; })()); flush(); };
const record = phase => checkpoints.push({ phase, requests: requests.map(request => request.key), displayed: { ...displayed } });
start(guessFirst, 1); start(guessDeep, 2); start(guessPeer, 20); start(setTrigger, true); start(guessView, 10);
record('all proposals started; enabling input unresolved');
enabledGate.resolve(true); await turn(); flush();
record('input discovers deep dependency; no action or other request completed');
dispose(); end.resolve(); await Promise.all(actions); await turn(); flush();
console.log(JSON.stringify(checkpoints, null, 2));
