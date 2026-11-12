import { expect, it } from "vitest";
import {
  action,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  flush,
  refresh
} from "../src/index.js";

const settle = async () => {
  await Promise.resolve();
  await Promise.resolve();
  await Promise.resolve();
  flush();
};

for (const producer of ["returned", "draft-mutated"] as const) {
  for (const editTitle of [false, true]) {
    it(`${producer} same-key echo retains the selected pushed row${editTitle ? " with a later title edit" : ""}`, async () => {
      type Todo = { id: string; title: string };
      let server: Todo[] = [];
      const fetches: Array<() => void> = [];
      const end = Promise.withResolvers<void>();
      const rendered: string[][] = [];
      const [todos, setTodos, dispose] = createRoot(dispose => {
        const [todos, setTodos] =
          producer === "returned"
            ? createOptimisticStore(
                () =>
                  new Promise<Todo[]>(resolve => {
                    fetches.push(() => resolve(structuredClone(server)));
                  }),
                [] as Todo[],
                { key: "id" }
              )
            : createOptimisticStore(
                async draft => {
                  await new Promise<void>(resolve => {
                    fetches.push(resolve);
                  });
                  const rows = structuredClone(server);
                  for (let i = 0; i < rows.length; i++) draft[i] = rows[i];
                  draft.length = rows.length;
                },
                [] as Todo[],
                { key: "id" }
              );
        createRenderEffect(
          () => todos.map(todo => todo.title),
          value => {
            rendered.push(value);
          }
        );
        return [todos, setTodos, dispose] as const;
      });
      let running: Promise<unknown> | undefined;
      try {
        flush();
        fetches.shift()!();
        await settle();
        running = action(function* () {
          setTodos(d => {
            d.push({ id: "1", title: "Optimistic" });
            if (editTitle) d[0].title = "Edited";
          });
          yield end.promise;
        })();
        flush();
        expect(rendered.at(-1)).toEqual([editTitle ? "Edited" : "Optimistic"]);
        const optimisticRef = todos[0];
        server = [{ id: "1", title: "Saved" }];
        refresh(todos);
        flush();
        fetches.shift()!();
        await settle();
        await settle();
        expect(rendered.at(-1)).toEqual([editTitle ? "Edited" : "Optimistic"]);
        expect(todos.length).toBe(1);
        expect(todos[0]).toBe(optimisticRef);
        end.resolve();
        await running;
        await settle();
        expect(rendered.at(-1)).toEqual(["Saved"]);
        expect(todos[0]).toBe(optimisticRef);
      } finally {
        end.resolve();
        await running;
        dispose();
        flush();
      }
    });
  }
}
