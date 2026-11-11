import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  latest
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

it("#4776 a latest memo and its ordinary consumer publish the same proposal", async () => {
  const end = Promise.withResolvers<void>();
  const [id, setId] = createSignal(1),
    [filter, setFilter] = createSignal(0);
  const screen = { id: 0, filter: -1, proposed: 0, pair: "" };
  const dispose = createRoot(dispose => {
    const proposed = createMemo(() => latest(id));
    const pair = createMemo(() => `${proposed()} / ${filter()}`);
    createRenderEffect(
      id,
      value => {
        screen.id = value;
      },
      { schedule: true }
    );
    createRenderEffect(
      filter,
      value => {
        screen.filter = value;
      },
      { schedule: true }
    );
    createRenderEffect(
      proposed,
      value => {
        screen.proposed = value;
      },
      { schedule: true }
    );
    createRenderEffect(
      pair,
      value => {
        screen.pair = value;
      },
      { schedule: true }
    );
    return dispose;
  });
  flush();
  const running = action(function* () {
    setId(2);
    setFilter(1);
    yield end.promise;
  })();
  try {
    flush();
    expect(screen).toEqual({ id: 1, filter: 0, proposed: 2, pair: "2 / 0" });
    end.resolve();
    await running;
    await turn();
    expect(screen).toEqual({ id: 2, filter: 1, proposed: 2, pair: "2 / 1" });
  } finally {
    dispose();
    end.resolve();
    await running;
    flush();
  }
});

it("#4778 previously async direct and memo-wrapped pending presentations agree", async () => {
  const end = Promise.withResolvers<void>();
  const [id, setId] = createSignal(0);
  const requests: { value: boolean; answer: ReturnType<typeof Promise.withResolvers<boolean>> }[] =
    [];
  const screen = {
    id: -1,
    pending: false,
    direct: undefined as boolean | undefined,
    wrapped: undefined as boolean | undefined
  };
  const request = (value: boolean) => {
    const answer = Promise.withResolvers<boolean>();
    requests.push({ value, answer });
    return answer.promise;
  };
  const dispose = createRoot(dispose => {
    const pending = createMemo(() => isPending(id));
    const direct = createMemo(async () => await request(isPending(id)));
    const wrapped = createMemo(async () => await request(pending()));
    createRenderEffect(
      id,
      value => {
        screen.id = value;
      },
      { schedule: true }
    );
    createRenderEffect(
      () => isPending(id),
      value => {
        screen.pending = value;
      },
      { schedule: true }
    );
    createRenderEffect(
      direct,
      value => {
        screen.direct = value;
      },
      { schedule: true }
    );
    createRenderEffect(
      wrapped,
      value => {
        screen.wrapped = value;
      },
      { schedule: true }
    );
    return dispose;
  });
  const settle = async () => {
    for (const { value, answer } of requests) answer.resolve(value);
    await turn();
    flush();
  };
  flush();
  await settle();
  expect(screen).toEqual({ id: 0, pending: false, direct: false, wrapped: false });
  const running = action(function* () {
    setId(1);
    yield end.promise;
  })();
  try {
    flush();
    expect(screen).toEqual({ id: 0, pending: false, direct: false, wrapped: false });
    await settle();
    expect(screen).toEqual({ id: 0, pending: true, direct: true, wrapped: true });
  } finally {
    dispose();
    end.resolve();
    await running;
    await settle();
    flush();
  }
});
