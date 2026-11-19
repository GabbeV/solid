/**
 * @jsxImportSource @solidjs/web
 * @vitest-environment jsdom
 */

// #4341: a memo born in a newly opened <Match> (or <Show>) that reads
// `latest()` of an unrelated memo. The update that opens the branch also
// re-asks a sibling async memo under its own <Loading>, so the frame that
// mounts the branch has a transaction. The memo's first pass is the branch's
// — its creator read the staged condition — so it has no screen of its own:
// it must read the world that created it, or the narrowed accessor sees the
// branch as closed and throws (REACTIVITY_HALTED). Reading `format()`
// instead of `latest(format)` always worked; the order of reads inside the
// memo, or whether the binding has a memo between, must not matter either.
import { afterEach, describe, expect, test, vi } from "vitest";
import {
  createMemo,
  createSignal,
  latest,
  Loading,
  Match,
  resetErrorHalt,
  Show,
  Switch,
  type Accessor
} from "solid-js";
import { render } from "@solidjs/web";

const wait = (ms: number) => new Promise(r => setTimeout(r, ms));

const disposals: (() => void)[] = [];
afterEach(() => {
  for (const dispose of disposals.splice(0)) dispose();
  resetErrorHalt();
  vi.restoreAllMocks();
});

type Label = (zone: Accessor<string>, format: Accessor<string>, s: Accessor<string>) => string;

const labels: [string, Label][] = [
  ["latest(format) first (the issue)", (zone, format, s) => `${latest(format)}:${zone()}:${s()}`],
  ["latest(format) between", (zone, format, s) => `${zone()}:${latest(format)}:${s()}`],
  ["latest(zone)", (zone, format, s) => `${format()}:${latest(zone)}:${s()}`],
  ["plain reads (control)", (zone, format, s) => `${format()}:${zone()}:${s()}`]
];

type Reader = "memo" | "binding" | "memo in an inner <Show>";

async function run(
  kind: "switch" | "show",
  label: Label,
  reader: Reader,
  opener: "staged" | "joined" = "staged"
) {
  const error = vi.spyOn(console, "error").mockImplementation(() => {});
  const el = document.createElement("div");
  const [ready, setReady] = createSignal(false);
  const [gate, setGate] = createSignal(opener === "staged");
  let resolveData!: (value: string) => void;
  const zone = createMemo(() => (ready() ? "ready" : "loading"));
  const format = createMemo(() => "ru");
  function Picker(props: { value: Accessor<string> }) {
    if (reader === "binding") return <span>{label(zone, format, props.value)}</span>;
    const Text = () => {
      const text = createMemo(() => label(zone, format, props.value));
      return <span>{text()}</span>;
    };
    if (reader === "memo") return <Text />;
    return <Show when={format()}>{_ => <Text />}</Show>;
  }
  const dispose = render(() => {
    const data = createMemo(async () => {
      if (zone() !== "ready") return "none";
      return new Promise<string>(resolve => (resolveData = resolve));
    });
    return (
      <>
        {kind === "switch" ? (
          <Switch>
            <Match when={!gate() || zone() === "loading"}>
              <i>loading</i>
            </Match>
            <Match when={gate() && zone() === "ready" && "sel"}>{s => <Picker value={s} />}</Match>
          </Switch>
        ) : (
          <Show when={gate() && zone() === "ready" && "sel"} fallback={<i>loading</i>}>
            {s => <Picker value={s} />}
          </Show>
        )}
        <Loading fallback={<b>wait</b>}>
          <b>{data()}</b>
        </Loading>
      </>
    );
  }, el);
  disposals.push(dispose);
  await wait(5);
  expect(el.textContent).toBe("loadingnone");
  setReady(true);
  await wait(5);
  if (opener === "joined") {
    expect(el.textContent).toBe("loadingnone");
    setGate(true);
    await wait(5);
    expect(el.textContent).toBe("loadingnone");
  }
  resolveData("data");
  await wait(5);
  const text = el.textContent;
  expect(error).not.toHaveBeenCalled();
  return text;
}

describe("a memo born in a newly opened branch may read latest() (#4341)", () => {
  test("the issue's repro: <Switch>/<Match>, latest(format) in the memo", async () => {
    expect(await run("switch", labels[0][1], "memo")).toBe("ru:ready:seldata");
  });

  for (const opener of ["staged", "joined"] as const)
    for (const kind of ["switch", "show"] as const)
      for (const reader of ["memo", "binding", "memo in an inner <Show>"] as const)
        for (const [name, label] of labels)
          test(`${opener}, ${kind}, ${reader}: ${name}`, async () => {
            const text = await run(kind, label, reader, opener);
            expect(text).toBe(
              name.startsWith("latest(format) between") ? "ready:ru:seldata" : "ru:ready:seldata"
            );
          });
});
