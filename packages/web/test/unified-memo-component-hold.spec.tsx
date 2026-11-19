/**
 * @jsxImportSource @solidjs/web
 * @vitest-environment jsdom
 */
import { expect, test } from "vitest";
import {
  createMemo,
  createSignal,
  flush,
  isPending,
  lazy,
  Switch,
  Match,
  type Component
} from "solid-js";
import { render } from "../src/index.js";

const turn = async () => {
  await new Promise<void>(resolve => setTimeout(resolve, 0));
  flush();
};

for (const wrapper of ["none", "memo", "two memos", "cached lazy"] as const)
  for (const pending of ["none", "text", "attribute"] as const)
    for (const ordinary of [false, true])
      test(`a component wrapper preserves its async children's mount hold (${wrapper}, pending=${pending}, ordinary=${ordinary})`, async () => {
        let resolveUser: ((value: string) => void) | undefined;
        let resolveInfo: ((value: string) => void) | undefined;
        const container = document.createElement("div");
        let setOpen!: (value: boolean) => void;
        let asks = 0;
        type Props = { user: string; info: string };
        const Profile: Component<Props> = props => (
          <>
            <h1>{props.user}'s Profile</h1>
            <p>{props.info}</p>
          </>
        );
        const Once: Component<Props> = props =>
          createMemo(() => <Profile user={props.user} info={props.info} />, {
            sync: true
          }) as any;
        const Twice: Component<Props> = props =>
          createMemo(() => <Once user={props.user} info={props.info} />, { sync: true }) as any;
        const Cached = lazy(() => Promise.resolve({ default: Profile }));
        if (wrapper === "cached lazy") await Cached.preload();
        const View =
          wrapper === "none"
            ? Profile
            : wrapper === "memo"
              ? Once
              : wrapper === "two memos"
                ? Twice
                : Cached;
        const dispose = render(() => {
          const [open, write] = createSignal(false);
          setOpen = write;
          const Route = () => {
            const user = createMemo(() => {
              asks++;
              return new Promise<string>(resolve => {
                resolveUser = resolve;
              });
            });
            const info = createMemo(() => {
              user();
              return new Promise<string>(resolve => {
                resolveInfo = resolve;
              });
            });
            return <View user={user()} info={info()} />;
          };
          return (
            <div class={pending === "attribute" ? { pending: isPending(open) } : {}}>
              {ordinary && <b>{open() ? "profile" : "home"}</b>}
              {pending === "text" && <i>{isPending(open) ? "pending" : "idle"}</i>}
              <Switch>
                <Match when={!open()}>
                  <h1>Home</h1>
                </Match>
                <Match when={open()}>
                  <Route />
                </Match>
              </Switch>
            </div>
          );
        }, container);
        const expected = (busy: boolean, ready: boolean) =>
          `${ordinary ? (ready ? "profile" : "home") : ""}${pending === "text" ? (busy ? "pending" : "idle") : ""}${ready ? "Jon's ProfileInfo" : "Home"}`;
        try {
          flush();
          expect(container.textContent).toBe(expected(false, false));
          setOpen(true);
          flush();
          expect(container.textContent).toBe(expected(true, false));
          if (pending === "attribute")
            expect(container.firstElementChild!.classList.contains("pending")).toBe(true);
          expect(asks).toBe(1);
          resolveUser?.("Jon");
          await turn();
          expect(container.textContent).toBe(expected(true, false));
          if (pending === "attribute")
            expect(container.firstElementChild!.classList.contains("pending")).toBe(true);
          resolveInfo?.("Info");
          await turn();
          expect(container.textContent).toBe(expected(false, true));
          expect(asks).toBe(1);
        } finally {
          dispose();
          resolveUser?.("Jon");
          resolveInfo?.("Info");
          await turn();
        }
      });
