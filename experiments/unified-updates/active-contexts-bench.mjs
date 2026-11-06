// Adapt the existing nested-override worker to the three-runtime comparison
// harness without duplicating its fixture, warm-up, or publication assertions.
process.argv.splice(2, 0, "--worker");
const print = console.log;
console.log = value => print(JSON.stringify({ timings: JSON.parse(value) }));
await import("./measure-active-contexts.mjs");
