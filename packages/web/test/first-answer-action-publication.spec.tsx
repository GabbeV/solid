/** @vitest-environment jsdom */
import { expect, it } from "vitest";
import {
  action,
  createEffect,
  createMemo,
  createSignal,
  Errored,
  Loading,
  NotReadyError
} from "solid-js";
import { render } from "../src/index.js";

const tick = () => new Promise(resolve => setTimeout(resolve, 0));

it.each(["answer first", "action first", "reject first"] as const)(
  "the first page answer publishes with its selection (%s)",
  async order => {
    const pages = [Promise.withResolvers<string>(), Promise.withResolvers<string>()];
    const save = Promise.withResolvers<void>();
    const root = document.createElement("div");
    let navigate!: () => Promise<unknown>;
    const dispose = render(() => {
      const [id, setId] = createSignal(0);
      const page = createMemo(() => pages[id()].promise);
      navigate = action(function* () {
        setId(1);
        yield save.promise;
      });
      return (
        <>
          <h2>Page {id()}</h2>
          <p>
            <Errored fallback={() => "Page failed"}>
              <Loading fallback="Loading">{page()}</Loading>
            </Errored>
          </p>
        </>
      );
    }, root);
    const frame = () => [
      root.querySelector("h2")?.textContent,
      root.querySelector("p")?.textContent
    ];
    try {
      await tick();
      expect(frame()).toEqual(["Page 0", "Loading"]);
      const done = navigate();
      await tick();
      if (order === "action first") {
        save.resolve();
        await done;
        await tick();
        expect(frame()).toEqual(["Page 1", "Loading"]);
      }
      if (order === "reject first") pages[1].reject(new Error("page 1"));
      else pages[1].resolve("Content for page 1");
      await tick();
      if (order !== "action first") {
        expect(frame()).toEqual(["Page 0", "Loading"]);
        save.resolve();
        await done;
        await tick();
      }
      expect(frame()).toEqual([
        "Page 1",
        order === "reject first" ? "Page failed" : "Content for page 1"
      ]);
    } finally {
      save.resolve();
      dispose();
    }
  }
);

it.each([
  { reader: "Loading", destination: 2 },
  { reader: "user effect", destination: 2 },
  { reader: "user effect", destination: 0 }
])(
  "superseding the first answer before its reveal ($reader, page $destination)",
  async ({ reader, destination }) => {
    const pages = Array.from({ length: 3 }, () => Promise.withResolvers<string>());
    const save = Promise.withResolvers<void>();
    const root = document.createElement("div");
    const seen: string[] = [];
    let readPage!: () => string;
    let navigate!: () => Promise<unknown>;
    const dispose = render(() => {
      const [id, setId] = createSignal(0);
      const page = createMemo(() => pages[id()].promise);
      readPage = page;
      navigate = action(function* () {
        setId(1);
        yield save.promise;
        setId(destination);
      });
      if (reader === "user effect")
        createEffect(page, value => {
          seen.push(value);
        });
      return (
        <>
          <h2>Page {id()}</h2>
          {reader === "Loading" && (
            <p>
              <Loading fallback="Loading">{page()}</Loading>
            </p>
          )}
        </>
      );
    }, root);
    const check = (id: number, content?: string) => {
      expect(root.querySelector("h2")?.textContent).toBe(`Page ${id}`);
      if (reader === "Loading")
        expect(root.querySelector("p")?.textContent).toBe(content ?? "Loading");
      else expect(seen).toEqual(content ? [content] : []);
    };
    try {
      await tick();
      const done = navigate();
      await tick();
      pages[1].resolve("Page one");
      await tick();
      check(0);
      save.resolve();
      await done;
      await tick();
      check(destination);
      expect(readPage).toThrow(NotReadyError);
      const answer = `Content for page ${destination}`;
      pages[destination].resolve(answer);
      await tick();
      check(destination, answer);
    } finally {
      save.resolve();
      dispose();
    }
  }
);
