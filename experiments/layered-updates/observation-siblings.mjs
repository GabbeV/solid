import { pathToFileURL } from "node:url";
const {
  createSignal,
  createRoot,
  createMemo,
  createRenderEffect,
  action,
  flush,
  latest,
  isPending
} = await import(pathToFileURL(process.argv[2]));
let finish, answer;
const end = new Promise(r => (finish = r)),
  work = new Promise(r => (answer = r));
const [x, setX] = createSignal(0);
const shown = { x: 0, ahead: 0, label: 0, pending: false };
createRoot(() => {
  const details = createMemo(() => (latest(x) ? work : 0));
  createRenderEffect(x, v => {
    shown.x = v;
  });
  createRenderEffect(
    () => latest(x),
    v => {
      shown.ahead = v;
    }
  );
  createRenderEffect(details, v => {
    shown.label = v;
  });
  createRenderEffect(
    () => isPending(x),
    v => {
      shown.pending = v;
    }
  );
});
flush();
const running = action(function* () {
  setX(1);
  yield end;
})();
flush();
console.log("held", shown);
answer(1);
await new Promise(r => setTimeout(r, 0));
console.log("ready", shown);
finish();
await running;
await new Promise(r => setTimeout(r, 0));
console.log("end", shown);
