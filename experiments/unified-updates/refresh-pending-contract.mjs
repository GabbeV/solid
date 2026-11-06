import { pathToFileURL } from "node:url";
const entry = pathToFileURL(process.argv[2]);
const api = await import(entry);
const { createMemo, createRoot, createRenderEffect, flush, isPending } = api;
// Use the separate audit entry for the prototype; the supported scalar entry
// deliberately excludes refresh. Do not mix separately bundled runtimes.
const { refresh } = api;
if (!refresh) throw new Error("refresh is absent; build the separate refresh audit entry first");
const trace = value => { if (process.env.TRACE_REFRESH) console.error(value); };
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const requests = [], frames = [];
let source, dispose;
const shown = { value: -1, pending: false };
createRoot(d => {
  dispose = d;
  source = createMemo(() => {
    const answer = Promise.withResolvers();
    requests.push(answer);
    return answer.promise;
  });
  createRenderEffect(source, value => { shown.value = value; });
  if (!process.env.SKIP_PENDING)
    createRenderEffect(() => isPending(source), value => { shown.pending = value; });
});
trace("initial root created");
flush(); requests[0].resolve(0); await turn();
trace("initial answer committed");
frames.push({ event: "initial answer", ...shown });
trace("calling refresh");
const refreshed = refresh(source);
trace("refresh called");
flush(); trace("refresh flushed"); await turn();
frames.push({ event: "refresh in flight", ...shown, requests: requests.length });
trace(JSON.stringify(frames));
requests[1].resolve(1);
trace("refresh answer resolved");
const result = await refreshed;
await turn();
frames.push({ event: "refresh answer", result, ...shown });
console.log(JSON.stringify(frames, null, 2));
dispose(); flush();
