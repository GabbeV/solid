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
  Loading,
  Match,
  Show,
  Switch,
  type Component
} from "solid-js";
import { render } from "../src/index.js";

const turn = async () => {
  await new Promise<void>(resolve => setTimeout(resolve, 0));
  flush();
};

test("a retained pending branch does not let another root publish incomplete content", async () => {
  const retained = document.createElement("div");
  const route = document.createElement("div");
  let setPage!: (value: string) => void;
  let resolvePage!: () => void;
  const disposeRetained = render(() => {
    const [page, write] = createSignal("a");
    setPage = write;
    const source = createMemo(() => {
      const value = page();
      return new Promise<string>(resolve => {
        resolvePage = () => resolve(value);
      });
    });
    return (
      <Show when={page()} keyed>
        {value => (
          <Loading fallback="loading">
            <button disabled={isPending(source)}>
              {value}:{source()}
            </button>
          </Loading>
        )}
      </Show>
    );
  }, retained);
  let disposeRoute: (() => void) | undefined;
  let resolveUser: ((value: string) => void) | undefined;
  let resolveInfo: ((value: string) => void) | undefined;
  try {
    resolvePage();
    await turn();
    expect(retained.textContent).toBe("a:a");
    setPage("b");
    flush();
    expect(retained.textContent).toBe("a:a");
    expect((retained.firstElementChild as HTMLButtonElement).disabled).toBe(true);

    let setRoute!: (value: string) => void;
    type Props = { user: string; info: string };
    const Profile: Component<Props> = props => (
      <>
        <h1>{props.user}'s Profile</h1>
        <p>{props.info}</p>
      </>
    );
    const Wrapped: Component<Props> = props =>
      createMemo(() => <Profile user={props.user} info={props.info} />, { sync: true }) as any;
    const ProfileRoute = () => {
      const user = createMemo(
        () =>
          new Promise<string>(resolve => {
            resolveUser = resolve;
          })
      );
      const info = createMemo(() => {
        user();
        return new Promise<string>(resolve => {
          resolveInfo = resolve;
        });
      });
      return <Wrapped user={user()} info={info()} />;
    };
    disposeRoute = render(() => {
      const [page, write] = createSignal("home");
      setRoute = write;
      return (
        <div class={{ pending: isPending(page) }}>
          <Switch>
            <Match when={page() === "home"}>
              <h1>Home</h1>
            </Match>
            <Match when={page() === "profile"}>
              <ProfileRoute />
            </Match>
          </Switch>
        </div>
      );
    }, route);
    expect(route.textContent).toBe("Home");
    setRoute("profile");
    flush();
    expect(route.textContent).toBe("Home");
    expect(route.firstElementChild!.classList.contains("pending")).toBe(true);
    resolveUser!("Jon");
    await turn();
    expect(route.textContent).toBe("Home");
    resolveInfo!("Info");
    await turn();
    expect(route.textContent).toBe("Jon's ProfileInfo");
    expect(retained.textContent).toBe("a:a");
    resolvePage();
    await turn();
    expect(retained.textContent).toBe("b:b");
  } finally {
    disposeRoute?.();
    disposeRetained();
    resolvePage?.();
    resolveUser?.("Jon");
    resolveInfo?.("Info");
    await turn();
  }
});
