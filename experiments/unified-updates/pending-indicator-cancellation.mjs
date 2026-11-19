// A spinner's delayed hide is superseded when new foreground work starts.
// Controlled gates stand in for the network and a 300 ms exit delay.
import { pathToFileURL } from "node:url";
const {
  createMemo,
  createEffect,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  onCleanup
} = await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const results = {};
for (const mode of ["memo", "effect"]) {
  const requests = [],
    timers = [],
    events = [],
    snapshots = [],
    shown = {};
  let write, dispose;
  createRoot(cleanup => {
    dispose = cleanup;
    const [id, setId] = createSignal(0);
    write = setId;
    const data = createMemo(() => {
      const value = id();
      if (!value) return 0;
      const gate = Promise.withResolvers();
      requests.push({ value, gate });
      events.push(`request ${value}`);
      return gate.promise.then(() => value * 10);
    });
    let indicator;
    if (mode === "memo") {
      indicator = createMemo(previous => {
        if (isPending(data)) return true;
        if (!previous) return false;
        const timer = { gate: Promise.withResolvers(), fired: false, cancelled: false };
        timers.push(timer);
        events.push("schedule hide");
        onCleanup(() => {
          if (!timer.fired) {
            timer.cancelled = true;
            events.push("cancel hide");
          }
        });
        return timer.gate.promise.then(() => {
          timer.fired = true;
          return false;
        });
      });
    } else {
      const [visible, setVisible] = createSignal(false);
      indicator = visible;
      createEffect(
        () => isPending(data),
        pending => {
          if (pending) {
            setVisible(true);
            return;
          }
          if (!visible()) return;
          const timer = { gate: Promise.withResolvers(), fired: false, cancelled: false };
          timers.push(timer);
          events.push("schedule hide");
          timer.gate.promise.then(() => {
            timer.fired = true;
            if (!timer.cancelled) setVisible(false);
          });
          // Equivalent to clearTimeout for this controlled timer.
          return () => {
            if (!timer.fired) {
              timer.cancelled = true;
              events.push("cancel hide");
            }
          };
        }
      );
    }
    for (const [key, read] of Object.entries({
      id,
      data,
      indicator,
      pending: () => isPending(data)
    }))
      createRenderEffect(
        read,
        value => {
          shown[key] = value;
        },
        { schedule: true }
      );
  });
  const snapshot = phase => snapshots.push({ phase, shown: { ...shown }, events: [...events] });
  flush();
  write(1);
  flush();
  await turn();
  snapshot("first request");
  requests.find(request => request.value === 1).gate.resolve();
  await turn();
  snapshot("first answer; hide delayed");
  write(2);
  flush();
  await turn();
  snapshot("second request during hide delay");
  // A late timer callback must not hide the indicator for the newer request.
  for (const timer of [...timers]) timer.gate.resolve();
  await turn();
  snapshot("old hide callback");
  for (const request of requests) if (request.value === 2) request.gate.resolve();
  await turn();
  snapshot("second answer");
  for (const timer of timers) timer.gate.resolve();
  await turn();
  snapshot("final hide");
  results[mode] = {
    snapshots,
    requests: requests.map(request => request.value),
    timers: timers.map(({ fired, cancelled }) => ({ fired, cancelled }))
  };
  dispose();
  flush();
}
console.log(JSON.stringify(results, null, 2));
