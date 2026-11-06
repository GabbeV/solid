// ../layered-baseline/packages/signals/dist/dev-shared.js
var NotReadyError = class extends Error {
  source;
  constructor(source) {
    super();
    this.source = source;
  }
};
var StatusError = class extends Error {
  source;
  constructor(source, original) {
    super(original instanceof Error ? original.message : String(original), {
      cause: original
    });
    this.source = source;
  }
};
function unwrapStatusError(error) {
  return error instanceof StatusError ? error.cause : error;
}
var REACTIVE_NONE = 0;
var REACTIVE_CHECK = 1 << 0;
var REACTIVE_DIRTY = 1 << 1;
var REACTIVE_RECOMPUTING_DEPS = 1 << 2;
var REACTIVE_IN_HEAP = 1 << 3;
var REACTIVE_IN_HEAP_HEIGHT = 1 << 4;
var REACTIVE_ZOMBIE = 1 << 5;
var REACTIVE_DISPOSED = 1 << 6;
var REACTIVE_JOINED = 1 << 7;
var REACTIVE_SNAPSHOT_STALE = 1 << 8;
var REACTIVE_LAZY = 1 << 9;
var REACTIVE_MANUAL_WRITE = 1 << 10;
var REACTIVE_FRAME_READ = 1 << 11;
var REACTIVE_MISSED_WAKE = 1 << 12;
var REACTIVE_REASK = 1 << 13;
var REACTIVE_STAGED_READ = 1 << 14;
var REACTIVE_PROBED = 1 << 15;
var REACTIVE_LANE_DIRTY = 1 << 16;
var REACTIVE_LANE_READ = 1 << 17;
var REACTIVE_SCREEN_READ = 1 << 18;
var REACTIVE_PROBE_UNANSWERED = 1 << 19;
var CONFIG_OWNED_WRITE = 1 << 0;
var CONFIG_NO_SNAPSHOT = 1 << 1;
var CONFIG_TRANSPARENT = 1 << 2;
var CONFIG_IN_SNAPSHOT_SCOPE = 1 << 3;
var CONFIG_CHILDREN_FORBIDDEN = 1 << 4;
var CONFIG_AUTO_DISPOSE = 1 << 5;
var CONFIG_SYNC = 1 << 6;
var CONFIG_STAGED = 1 << 7;
var CONFIG_HELD = 1 << 8;
var CONFIG_INPUTS_PUBLISHED = 1 << 10;
var CONFIG_OVERRIDE = 1 << 11;
var CONFIG_SLOT_NODE = 1 << 12;
var CONFIG_MANUAL_WRITE = 1 << 18;
var CONFIG_GUESS = 1 << 13;
var CONFIG_VERDICT = 1 << 14;
var CONFIG_REDERIVE = 1 << 15;
var CONFIG_AUTHORITATIVE = 1 << 17;
var CONFIG_HAS_SNAPSHOT = 1 << 9;
var CONFIG_FRESH_READ = 1 << 16;
var CONFIG_PROMOTED = 1 << 22;
var CONFIG_PLUMBING = 1 << 25;
var CONFIG_WIDE = 1 << 26;
var CONFIG_SUPERSEDES = 1 << 27;
var STATUS_PENDING = 1 << 0;
var STATUS_ERROR = 1 << 1;
var STATUS_UNINITIALIZED = 1 << 2;
var EFFECT_RENDER = 1;
var EFFECT_USER = 2;
var EFFECT_TRACKED = 3;
var NOT_PENDING = {};
var NO_SNAPSHOT = {};
var defaultContext = {};
var $REFRESH = /* @__PURE__ */ Symbol("refresh");
var attrHooks = null;
function withInteraction(ref, fn) {
  const hooks2 = attrHooks;
  if (hooks2 === null) return fn();
  hooks2.interactionStart(ref);
  let returned;
  try {
    return returned = fn();
  } finally {
    hooks2.interactionEnd(returned);
  }
}
function withOrigin(ref, fn) {
  const hooks2 = attrHooks;
  if (hooks2 === null) return fn();
  hooks2.originStart(ref);
  try {
    return fn();
  } finally {
    hooks2.originEnd();
  }
}
function currentOrigin() {
  const hooks2 = attrHooks;
  return hooks2 === null ? void 0 : hooks2.currentOrigin();
}
var GRAPH_SIZE_WARN_AT = 2e3;
var GRAPH_SIZE_WARN_EVERY = 500;
var hooks = {};
var diagnosticListeners = /* @__PURE__ */ new Set();
var diagnosticCaptures = /* @__PURE__ */ new Set();
var diagnosticSequence = 0;
var consoleFooter;
var footeredCodes = /* @__PURE__ */ new Set();
function setConsoleFooter(footer) {
  consoleFooter = footer;
  footeredCodes.clear();
}
var diagnostics = {
  subscribe(listener) {
    diagnosticListeners.add(listener);
    return () => diagnosticListeners.delete(listener);
  },
  emit(event, subject = null) {
    return emitDiagnostic(event, subject);
  },
  capture() {
    const events = [];
    diagnosticCaptures.add(events);
    return {
      get events() {
        return events;
      },
      clear() {
        events.length = 0;
      },
      stop() {
        diagnosticCaptures.delete(events);
        return [...events];
      }
    };
  }
};
var attributionSlot = {
  get installed() {
    return attrHooks;
  },
  withInteraction,
  withOrigin,
  currentOrigin
};
var RECORDS = /* @__PURE__ */ Symbol.for("@solidjs/signals/observe/records");
function recordsChannel() {
  const g = globalThis;
  if (g[RECORDS]) return g[RECORDS];
  const listeners = /* @__PURE__ */ new Map();
  const bodyListeners = /* @__PURE__ */ new Map();
  return g[RECORDS] = {
    subscribe(type, listener, options) {
      const current = listeners.get(type);
      if (current === void 0 || !current.includes(listener)) {
        listeners.set(type, current === void 0 ? [listener] : [...current, listener]);
        if (options !== void 0 && options.bodies) {
          let wanting = bodyListeners.get(type);
          if (wanting === void 0) bodyListeners.set(type, wanting = /* @__PURE__ */ new Set());
          wanting.add(listener);
        }
      }
      return () => {
        const list2 = listeners.get(type);
        if (list2 === void 0 || !list2.includes(listener)) return;
        const next = list2.filter((l) => l !== listener);
        if (next.length > 0) listeners.set(type, next);
        else listeners.delete(type);
        const wanting = bodyListeners.get(type);
        if (wanting !== void 0 && wanting.delete(listener) && wanting.size === 0)
          bodyListeners.delete(type);
      };
    },
    observed(type, facet) {
      return facet === "bodies" ? bodyListeners.has(type) : listeners.has(type);
    },
    emit(type, event, live) {
      const list2 = listeners.get(type);
      if (list2 === void 0) return;
      for (let i = 0; i < list2.length; i++) {
        try {
          list2[i](event, live);
        } catch (error) {
          console.error(error);
        }
      }
    }
  };
}
var OBSERVE = {
  diagnostics,
  records: recordsChannel(),
  attribution: attributionSlot,
  // Replaced by solid-js's server entry (see `ServerObserve`); on the
  // client the slot stays this placeholder. The cast: the interface is
  // empty HERE and gains its members by augmentation downstream.
  server: {},
  exclude(owner) {
    markedOwners.set(owner, true);
    hasExclusions = true;
  },
  include(owner) {
    markedOwners.set(owner, false);
  },
  isExcluded,
  ownerPath
};
var markedOwners = /* @__PURE__ */ new WeakMap();
var hasExclusions = false;
var suppressedEvents = /* @__PURE__ */ new WeakSet();
function isExcluded(subject) {
  if (!hasExclusions || !subject) return false;
  let owner = "_parent" in subject ? subject : subject._owner ?? null;
  for (; owner !== null; owner = owner._parent) {
    const marked2 = markedOwners.get(owner);
    if (marked2 !== void 0) return marked2;
  }
  return false;
}
var GUIDE_URL = "https://github.com/solidjs/solid/blob/main/packages/solid/skills/reactivity-diagnostics/SKILL.md";
var DEV = {
  hooks,
  getChildren,
  getSignals,
  getParent,
  getSources,
  getObservers,
  report: reportDiagnostic,
  guideUrl(code) {
    return `${GUIDE_URL}#${code.toLowerCase()}`;
  }
};
function assertInvariant(condition, name, message) {
  if (condition) return;
  const full = `[INVARIANT_VIOLATION] ${name}: ${message}`;
  const entry = emitDiagnostic({
    code: "INVARIANT_VIOLATION",
    kind: "error",
    severity: "error",
    message: full,
    data: { invariant: name }
  });
  reportDiagnostic(entry);
}
function ownerPath(subject) {
  if (!subject) return void 0;
  let owner = "_parent" in subject ? subject : subject._owner ?? null;
  const path = [];
  for (; owner !== null; owner = owner._parent) {
    const name = owner._name;
    if (typeof name === "string" && name.length) path.push(name);
  }
  return path.length ? path.reverse() : void 0;
}
function emitDiagnostic(event, subject = context) {
  const entry = {
    sequence: ++diagnosticSequence,
    ...event
  };
  if (isExcluded(subject)) {
    suppressedEvents.add(entry);
    return entry;
  }
  if (entry.ownerPath === void 0) {
    const path = ownerPath(subject);
    if (path) entry.ownerPath = path;
  }
  const live = subject ?? void 0;
  if (live !== void 0) eventSubjects.set(entry, live);
  for (const listener of diagnosticListeners) listener(entry, live);
  for (const capture of diagnosticCaptures) capture.push(entry);
  if (entry.severity === "error" && consoleFooter && !footeredCodes.has(entry.code)) {
    queueMicrotask(() => {
      const footer = takeFooter(entry);
      if (footer) console.warn(footer);
    });
  }
  return entry;
}
function takeFooter(entry) {
  if (!consoleFooter || footeredCodes.has(entry.code)) return void 0;
  footeredCodes.add(entry.code);
  return consoleFooter(entry);
}
var eventSubjects = /* @__PURE__ */ new WeakMap();
function reportDiagnostic(entry) {
  if (suppressedEvents.has(entry)) return;
  let text = entry.message;
  if (entry.ownerPath) text += `
  in ${entry.ownerPath.join(" \u203A ")}`;
  const footer = takeFooter(entry);
  if (footer) text += `
${footer}`;
  const element = eventSubjects.get(entry)?._devElement;
  const args = element !== void 0 ? [text, element] : [text];
  entry.severity === "error" ? console.error(...args) : console.warn(...args);
}
function throwPendingUntrackedRead(strictReadLabel, fields) {
  const message = `[PENDING_ASYNC_UNTRACKED_READ] Reading a pending async value directly in ${strictReadLabel}. Async values must be read within a tracking scope (JSX, a memo, or an effect's compute function).`;
  emitDiagnostic({
    code: "PENDING_ASYNC_UNTRACKED_READ",
    kind: "async",
    severity: "error",
    message,
    ...fields,
    data: { strictRead: strictReadLabel }
  });
  throw new Error(message);
}
function warnStrictReadUntracked(strictReadLabel, fields) {
  const nodeName = fields?.nodeName;
  const named = nodeName !== void 0 && nodeName !== "signal" && nodeName !== "computed";
  const message = `[STRICT_READ_UNTRACKED] Reactive value${named ? ` "${nodeName}"` : ""} read directly in ${strictReadLabel} will not update. Move it into a tracking scope (JSX, a memo, or an effect's compute function).`;
  reportDiagnostic(
    emitDiagnostic({
      code: "STRICT_READ_UNTRACKED",
      kind: "strict-read",
      severity: "warn",
      message,
      data: { strictRead: strictReadLabel },
      ...fields
    })
  );
}
function registerGraph(value, owner) {
  value._owner = owner;
  {
    if (owner) {
      if (!owner._signals) owner._signals = [];
      owner._signals.push(value);
    }
    DEV.hooks.onGraph?.(value, owner);
  }
}
function clearSignals(node) {
  node._signals = void 0;
}
var liveRoots = /* @__PURE__ */ new Set();
var rootRefs = /* @__PURE__ */ new WeakMap();
var rootReaper = typeof FinalizationRegistry === "function" ? new FinalizationRegistry((ref) => liveRoots.delete(ref)) : null;
function registerRoot(owner) {
  if (typeof WeakRef !== "function") return;
  const ref = new WeakRef(owner);
  rootRefs.set(owner, ref);
  liveRoots.add(ref);
  rootReaper?.register(owner, ref, ref);
}
function unregisterRoot(owner) {
  const ref = rootRefs.get(owner);
  if (ref === void 0) return;
  rootRefs.delete(owner);
  liveRoots.delete(ref);
  rootReaper?.unregister(ref);
}
function getChildren(owner) {
  const children = [];
  let child = owner._firstChild;
  while (child) {
    children.push(child);
    child = child._nextSibling;
  }
  return children;
}
function getSignals(owner) {
  return owner._signals ? [...owner._signals] : [];
}
function getParent(owner) {
  return owner._parent;
}
function getSources(computation) {
  const sources = [];
  let link2 = computation._deps;
  while (link2) {
    sources.push(link2._dep);
    link2 = link2._nextDep;
  }
  return sources;
}
function getObservers(node) {
  const observers = [];
  let link2 = node._subs;
  while (link2) {
    observers.push(link2._sub);
    link2 = link2._nextSub;
  }
  return observers;
}
var graphSizeWarnedAt = /* @__PURE__ */ new WeakMap();
function shouldWarnGraphSize(node, count) {
  const last = graphSizeWarnedAt.get(node);
  if (last !== void 0 && count < last + GRAPH_SIZE_WARN_EVERY) return false;
  graphSizeWarnedAt.set(node, count);
  return true;
}
function noteFanOut(node, count, write) {
  if (!shouldWarnGraphSize(node, count)) return;
  const name = node._name;
  const message = `[HUGE_FAN_OUT] ${name ? `Signal "${name}"` : "A signal"} changed with ${count} subscribers \u2014 every one re-runs this flush. If many independent computations read the same value (for example every row of a list comparing against one selected id), prefer a per-key store or projection so only the items whose result flipped update.`;
  reportDiagnostic(
    emitDiagnostic(
      {
        code: "HUGE_FAN_OUT",
        kind: "graph",
        severity: "warn",
        message,
        nodeName: name,
        ownerId: node.id,
        ownerName: name,
        data: write === void 0 ? { count } : { count, write }
      },
      node
    )
  );
}
function noteFanIn(node, count) {
  if (!shouldWarnGraphSize(node, count)) return;
  const name = node._name;
  const message = `[HUGE_FAN_IN] ${name ? `Computation "${name}"` : "A computation"} tracked ${count} sources. It will re-run when any of them change. Narrow the read or split the derivation so each computation tracks only what it needs.`;
  reportDiagnostic(
    emitDiagnostic(
      {
        code: "HUGE_FAN_IN",
        kind: "graph",
        severity: "warn",
        message,
        nodeName: name,
        ownerId: node.id,
        ownerName: name,
        data: { count }
      },
      node
    )
  );
}
var asyncTailFlights = 0;
var tailFlights = /* @__PURE__ */ new Map();
var warnedTailReads = /* @__PURE__ */ new WeakMap();
var tailFlightId = 0;
var TAIL_FRAME = /^__solidAsyncCompute_(\d+)$/;
function watchAsyncTail(el, flight) {
  if (!(flight instanceof Promise) || flight.constructor !== Promise) return flight;
  return {
    then(onFulfilled, onRejected) {
      const id = ++tailFlightId;
      const name = `__solidAsyncCompute_${id}`;
      const done = () => {
        if (tailFlights.delete(id)) asyncTailFlights--;
      };
      if (tailFlights.size >= nextTailSweep) sweepTailFlights();
      asyncTailFlights++;
      tailFlights.set(id, { el: new WeakRef(el), flight: new WeakRef(flight) });
      ({
        async [name]() {
          let value;
          try {
            value = await flight;
          } catch (error) {
            done();
            return onRejected(error);
          }
          done();
          onFulfilled(value);
        }
      })[name]();
      return void 0;
    }
  };
}
function checkPostAwaitRead(dep, holder, key, nodeName, throwsPending) {
  if (context !== null) return;
  if (callbackDepth !== 0) return;
  if (disposalDepth !== 0) {
    if (!disposalHealQueued) {
      disposalHealQueued = true;
      queueMicrotask(healDisposalDepth);
    }
    return;
  }
  let id = windowFlight;
  if (id === void 0) {
    id = windowFlight = attributedFlight();
    queueMicrotask(resetWindowFlight);
  } else if (id !== 0) id = attributedFlight();
  if (id === 0) return;
  const entry = tailFlights.get(id);
  const el = entry?.el.deref();
  if (!el || throwsPending || el === dep) return;
  const flight = entry.flight.deref();
  if (!flight || el._x?._inFlight !== flight) return;
  if (dep !== void 0) {
    for (let d = el._deps; d !== null; d = d._nextDep) if (d._dep === dep) return;
  }
  let byHolder = warnedTailReads.get(el);
  if (!byHolder) warnedTailReads.set(el, byHolder = /* @__PURE__ */ new WeakMap());
  let keys = byHolder.get(holder);
  if (!keys) byHolder.set(holder, keys = /* @__PURE__ */ new Set());
  if (keys.has(key)) return;
  keys.add(key);
  reportDiagnostic(
    emitDiagnostic(
      {
        code: "UNTRACKED_READ_AFTER_AWAIT",
        kind: "async",
        severity: "warn",
        message: `[UNTRACKED_READ_AFTER_AWAIT] ${nodeName ? `"${nodeName}"` : "A reactive value"} was first read after an \`await\` in an async computation, so it is not a dependency: the computation will not re-run when it changes. Read it before the first \`await\`, or wrap the read in untrack() if a one-time value is intended.`,
        ownerId: el.id,
        ownerName: el._name,
        nodeName
      },
      el
    )
  );
}
var nextTailSweep = 64;
function sweepTailFlights() {
  for (const [id, { el, flight }] of tailFlights) {
    const node = el.deref();
    const current = flight.deref();
    if (!node || !current || node._x?._inFlight !== current) {
      tailFlights.delete(id);
      asyncTailFlights--;
    }
  }
  nextTailSweep = Math.max(64, tailFlights.size * 2);
}
var windowFlight;
function resetWindowFlight() {
  windowFlight = void 0;
}
var disposalHealQueued = false;
function healDisposalDepth() {
  disposalHealQueued = false;
  if (disposalDepth !== 0) resetDisposalDepth();
}
function attributedFlight() {
  const V8Error = Error;
  if (!V8Error.captureStackTrace) return 0;
  const prevPrepare = V8Error.prepareStackTrace;
  const prevLimit = V8Error.stackTraceLimit;
  const target = {};
  let sites;
  V8Error.prepareStackTrace = (_, callSites) => callSites;
  V8Error.stackTraceLimit = 50;
  try {
    V8Error.captureStackTrace(target, attributedFlight);
    sites = target.stack;
  } finally {
    V8Error.prepareStackTrace = prevPrepare;
    V8Error.stackTraceLimit = prevLimit;
  }
  if (!Array.isArray(sites)) return 0;
  for (const site of sites) {
    const match = TAIL_FRAME.exec(site.getFunctionName?.() ?? "");
    if (match) return +match[1];
  }
  return 0;
}
function devCheckQuiescent(isQueuedForCommit) {
  return;
}
var transactions = [];
var holding = false;
function newTransaction(lane, parent = null) {
  const t = {
    _nodes: [],
    _queues: [[], []],
    _reruns: [],
    _into: null,
    _parent: parent,
    _lane: lane,
    _verdict: null,
    _open: 0,
    _acted: false,
    _links: null,
    _shown: false,
    _held: false,
    _marks: null
  };
  if (!lane) transactions.push(t);
  return t;
}
var passLane = null;
function setPassLane(l) {
  passLane = l;
}
var flushTransaction = null;
var passTx = null;
function joinPassTx(t, own) {
  if (globalQueue._running && !own || flushTransaction !== null) return joinFuture(t);
  if (passTx === null) passTx = resolveTx(t);
  else merge(resolveTx(t), passTx);
  schedule();
}
function txOf(n) {
  return n._x._transaction = resolveTx(n._x._transaction);
}
function liveTx(t) {
  t = resolveTx(t);
  return transactions.indexOf(t) !== -1 ? t : null;
}
function resolveTx(t) {
  while (t._into !== null) t = t._into;
  return t;
}
function joinFuture(t) {
  const f = flushTransaction;
  if (f === null) {
    flushTransaction = t === null ? newTransaction(false) : resolveTx(t);
  } else if (t !== null) merge(resolveTx(t), f);
  if (!globalQueue._running) schedule();
}
function merge(t, f) {
  t = resolveTx(t);
  f = resolveTx(f);
  if (t === f || t._lane || f._lane) return;
  if (attrHooks !== null) attrHooks.transitionMerged(f, t);
  t._into = f;
  f._open += t._open;
  f._acted ||= t._acted;
  append(f._nodes, t._nodes);
  append(f._queues[0], t._queues[0]);
  append(f._queues[1], t._queues[1]);
  append(f._reruns, t._reruns);
  if (t._marks !== null) append(f._marks ??= [], t._marks);
  transactions.splice(transactions.indexOf(t), 1);
}
function blocked(t) {
  const prev = judge;
  judge ??= t;
  const r = t._open !== 0 || blockedBy(t._nodes, t) || !!GlobalQueue._lanesBlocked && GlobalQueue._lanesBlocked(t);
  judge = prev;
  return r;
}
var judge = null;
function ownFlights(t) {
  return blockedBy(t._nodes, t, true);
}
function ownSource(n, t) {
  const sources = n._x?._pendingSources;
  if (sources === void 0) return true;
  for (const s of sources) {
    const u = s._x?._transaction;
    if (u == null || resolveTx(u) === t) return true;
  }
  return false;
}
function blockedBy(nodes, owner, own = false) {
  for (let i = 0; i < nodes.length; i++) {
    const n = nodes[i];
    if (!(n._statusFlags & STATUS_PENDING) || n._flags & REACTIVE_DISPOSED || n._config & CONFIG_GUESS || n._x._transaction !== null && txOf(n) !== owner || own && !ownSource(n, owner))
      continue;
    if (n._type === EFFECT_RENDER) {
      if (onScreen(n, judge ?? owner)) return true;
      continue;
    }
    for (let s = n._subs; s !== null; s = s._nextSub) {
      const r = s._sub;
      if ((r._type === EFFECT_RENDER && r._statusFlags & STATUS_PENDING || r._flags & REACTIVE_FRAME_READ || r._config & CONFIG_REDERIVE && r._statusFlags === STATUS_PENDING) && (s._gen === r._depGen || r._x?._error != null) && !(r._flags & REACTIVE_DISPOSED) && onScreen(r, judge ?? owner))
        return true;
    }
  }
  return false;
}
function onScreen(r, t) {
  return !(r._flags & REACTIVE_ZOMBIE && removalStagedBy(r, t)) && !(GlobalQueue._hidden && GlobalQueue._hidden(r));
}
function removalStagedBy(r, t) {
  let o = r;
  while (o !== null && o._flags & REACTIVE_ZOMBIE) o = o._parent;
  return o !== null && (o._config & CONFIG_HELD) !== 0 && o._x?._transaction != null && txOf(o) === resolveTx(t);
}
var heldTrims = [];
function heldTrim(el) {
  heldTrims.push(el);
}
var deferredZombies = [];
function deferZombie(el) {
  deleteFromHeap(el, dirtyQueue);
  el._flags &= -4;
  deferredZombies.push(el);
}
function holdNode(n, t) {
  n._config |= CONFIG_HELD;
  list(n, t);
}
function list(n, t) {
  const x = ext(n);
  if (x._transaction === t) return;
  x._transaction = t;
  t._nodes.push(n);
}
function holdFrame(owner, t) {
  for (let c = owner._firstChild; c !== null; c = c._nextSibling) {
    if (c._x?._transaction?._lane) continue;
    if (c._fn !== void 0 && !(c._config & CONFIG_HELD)) holdNode(c, t);
    holdFrame(c, t);
  }
}
var dirtyQueue = {
  _heap: new Array(2e3).fill(void 0),
  _marked: false,
  _min: 0,
  _max: 0
};
var clock = 0;
var scheduled = false;
var halted = false;
var haltNotified = false;
var syncDepth = 0;
var inTrackedQueueCallback = false;
var _enforceLoadingBoundary = false;
var _hitUnhandledAsync = false;
var _reportedUnhandledAsync = false;
function resetUnhandledAsync() {
  _hitUnhandledAsync = false;
  if (_reportedUnhandledAsync) return false;
  _reportedUnhandledAsync = true;
  return true;
}
function enforceLoadingBoundary(enabled) {
  _enforceLoadingBoundary = enabled;
  if (enabled) _reportedUnhandledAsync = false;
}
var actionDepth = 0;
var question = 0;
var questions = 0;
function nextQuestion() {
  return ++questions;
}
var MAINLINE_QUESTION = 2147483647;
var inEffectCallback = false;
function setEffectCallback(value) {
  inEffectCallback = value;
}
function schedule() {
  if (halted) {
    notifyHalted();
    return;
  }
  if (scheduled) return;
  scheduled = true;
  if (!syncDepth && !globalQueue._running) {
    queueMicrotask(flush);
  }
}
var ROOT_ERROR_HOOK = /* @__PURE__ */ Symbol.for("solid-js/root-error-hook");
function haltReactivity(cause) {
  if (halted) return;
  halted = true;
  let message = "[REACTIVITY_HALTED]";
  {
    message += " An uncaught error halted the reactive system. No further updates will be processed. Handle errors with <Errored> or treat this as a crash.";
    emitDiagnostic({
      code: "REACTIVITY_HALTED",
      kind: "error",
      severity: "error",
      message
    });
  }
  const report = cause !== void 0 && globalThis.reportError;
  report || cause === void 0 ? console.error(message) : console.error(message, cause);
  report && report(cause);
}
function notifyHalted() {
  if (haltNotified) return;
  haltNotified = true;
  console.error(
    "[REACTIVITY_HALTED] Update ignored: the reactive system was halted by an earlier uncaught error."
  );
}
function resetErrorHalt() {
  halted = false;
  haltNotified = false;
}
var GlobalQueue = class _GlobalQueue {
  _queues = [[], []];
  _running = false;
  flush() {
    if (this._running) return;
    this._running = true;
    resyncUnflushedCompanions();
    passLane = null;
    passTx = null;
    try {
      sweepDormant();
      runHeap(dirtyQueue, _GlobalQueue._update);
      this.settle();
      clock++;
      scheduled = dirtyQueue._max >= dirtyQueue._min || pendingNodes.length !== 0;
      this.run(EFFECT_RENDER);
      this.run(EFFECT_USER);
      if (holding) {
        holding = false;
        attrHooks.holdEnd();
      }
      if (!scheduled) {
        devCheckQuiescent(
          (n) => pendingNodes.includes(n) || (n._config & (CONFIG_HELD | CONFIG_OVERRIDE)) !== 0
        );
      }
      if (true) DEV.hooks.onUpdate?.();
    } finally {
      this._running = false;
      passTx = null;
    }
  }
  /** L2 — the seam: end of the pure phase. Commit this flush's staged nodes,
   * or park them with the transaction the flush joined; then land every
   * transaction no frame is waiting on. The landing flush is an ordinary
   * flush: the settle walk (async.ts) re-ran the parked readers in its pure
   * phase, and here no flight the transaction holds has a frame deriving
   * from it (`blocked`). */
  settle() {
    if (_GlobalQueue._laneCorrections?.()) runHeap(dirtyQueue, _GlobalQueue._update);
    const joined = flushTransaction;
    flushTransaction = null;
    _GlobalQueue._applyGuesses?.(joined);
    const t = joined !== null && !joined._lane ? resolveTx(joined) : null;
    if (t !== null) {
      const count = pendingNodes.length;
      for (let i = 0; i < count; i++) {
        const n = pendingNodes[i];
        if (!(n._config & (CONFIG_HELD | CONFIG_OVERRIDE)) && (n._x === null || n._x._transaction === null || !n._x._transaction._lane)) {
          if (n._pendingValue === NOT_PENDING && n._statusFlags & STATUS_UNINITIALIZED && n._type !== EFFECT_RENDER)
            continue;
          if (n._pendingValue !== NOT_PENDING && !(n._statusFlags & (STATUS_PENDING | STATUS_UNINITIALIZED)) && n._equals && n._equals(n._value, n._pendingValue) && n._x?._pendingFirstChild == null && n._x?._pendingDisposal == null) {
            n._pendingValue = NOT_PENDING;
            n._config &= ~CONFIG_STAGED;
            continue;
          }
          holdNode(n, t);
        }
        if (n._config & CONFIG_STAGED) holdFrame(n, t);
      }
      pendingNodes.length = 0;
      _GlobalQueue._storePark?.(t);
      const zombies = deferredZombies.splice(0).sort((a, b) => a._height - b._height);
      for (let i = 0; i < zombies.length; i++)
        if ((zombies[i]._flags & (REACTIVE_DISPOSED | REACTIVE_ZOMBIE)) === REACTIVE_ZOMBIE && zombies[i]._config & CONFIG_VERDICT)
          recompute(zombies[i]);
    } else {
      commitPendingNodes();
      for (let i = 0; i < heldTrims.length; i++) {
        const t2 = heldTrims[i];
        if (t2._x?._error == null && !t2._modified) trimStaleDeps(t2);
      }
    }
    if (heldTrims.length) heldTrims.length = 0;
    const own = this._queues;
    const lanes2 = this._queues = [[], []];
    _GlobalQueue._laneSeams?.(t !== null ? stagedReaders : null);
    if (stagedReaders.length) stagedReaders.length = 0;
    this._queues = [[], []];
    for (let k = transactions.length - 1; k >= 0; k--) {
      const u = transactions[k];
      if (blocked(u)) continue;
      transactions.splice(k, 1);
      _GlobalQueue._endLanes?.(u);
      land(u);
      k = transactions.length;
    }
    _GlobalQueue._storeCommit?.();
    const live = t && liveTx(t);
    _GlobalQueue._releaseAmbientMarks?.(live);
    const parked = live !== null;
    if (parked && attrHooks !== null) {
      attrHooks.holdStart(live);
      holding = true;
    }
    for (let i = 0; i < 2; i++) {
      if (parked) append(live._queues[i], own[i]);
      this._queues[i] = parked || lanes2[i].length || this._queues[i].length ? lanes2[i].concat(parked ? [] : own[i], this._queues[i]) : own[i];
    }
    if (deferredZombies.length !== 0) {
      const zombies = deferredZombies.splice(0).sort((a, b) => a._height - b._height);
      for (let i = 0; i < zombies.length; i++) {
        if (!(zombies[i]._flags & REACTIVE_DISPOSED)) recompute(zombies[i]);
      }
    }
    _GlobalQueue._boundarySeam?.();
  }
  run(type) {
    const effects = this._queues[type - 1];
    if (effects.length) {
      this._queues[type - 1] = [];
      runQueue(effects, type);
    }
  }
  enqueue(type, fn, lane = passLane) {
    if (type) (lane !== null ? lane : this)._queues[type - 1].push(fn);
    schedule();
  }
  /** Status reaching the root: pending is absorbed (the root mount defers —
   * dev records it for the ASYNC_OUTSIDE_LOADING_BOUNDARY FYI); an error is
   * unhandled (`false` → the caller halts).
   *
   * L2: this is where a transaction is registered. Pending that reaches an
   * observer (a render effect: the frame) is a frame that cannot show — the
   * flush parks, and the transaction waits on the flight while a frame
   * derives from it (`blocked`). Pending nobody observes holds nothing: a
   * memo in flight that no frame reads is not a frame waiting. (Base: the
   * queue's `_asyncReporters`, INV-3's one registration site.)
   *
   * A boundary between the observer and the root (boundaries.ts) is asked
   * first: a fallback catches what is not ready under it, and the root
   * never hears of it. */
  notify(node, mask, flags, error) {
    if (_GlobalQueue._catch && _GlobalQueue._catch(node, flags & mask, error)) return true;
    if (mask & STATUS_PENDING) {
      if (flags & STATUS_PENDING) {
        if (_enforceLoadingBoundary) _hitUnhandledAsync = true;
        if (passLane === null) joinFuture(null);
      }
      return true;
    }
    return false;
  }
};
function reruns(u) {
  for (let i = 0; i < u._reruns.length; i++) {
    const r = u._reruns[i];
    if (r._flags & REACTIVE_DISPOSED || r._statusFlags & STATUS_ERROR) continue;
    if (r._flags & REACTIVE_FRAME_READ || r._config & CONFIG_VERDICT) {
      r._flags &= ~REACTIVE_FRAME_READ;
      r._modified = false;
      for (let c = r._firstChild; c !== null; c = c._nextSibling) if (c._type) c._modified = false;
      enqueueSub(r);
    }
  }
  u._reruns.length = 0;
}
function land(u) {
  if (attrHooks !== null) attrHooks.transitionSettled(u);
  reruns(u);
  if (u._marks !== null) GlobalQueue._releaseMarks(u._marks);
  for (let i = 0; i < u._nodes.length; i++) {
    const n = u._nodes[i];
    if (n._x._transaction === null || txOf(n) !== u) continue;
    n._x._transaction = null;
    commitPendingNode(n);
  }
  releaseQueues(u);
}
function releaseQueues(u) {
  for (let i = 0; i < 2; i++) {
    append(globalQueue._queues[i], u._queues[i]);
    u._queues[i] = [];
  }
}
function append(a, b) {
  for (let i = 0; i < b.length; i++) a.push(b[i]);
}
var pendingNodes = [];
var stagedReaders = [];
function staleReader(c, t) {
  if (!(c._flags & REACTIVE_FRAME_READ)) {
    c._flags |= REACTIVE_FRAME_READ;
    t._reruns.push(c);
  }
}
function queuePendingNode(node) {
  lastStagedNodeName = node._name ?? null;
  pendingNodes.push(node);
  if (!globalQueue._running) markUnflushedStaged();
}
var lastStagedNodeName = null;
var notifyEpoch = 0;
function bumpNotifyEpoch() {
  notifyEpoch++;
}
function insertSubs(node) {
  node._notifiedAt = notifyEpoch;
  const cfg = node._config;
  const hasSnapshot = (cfg & CONFIG_HAS_SNAPSHOT) !== 0 && node._x?._snapshotValue !== void 0;
  let fanOut = 0;
  for (let s = node._subs; s !== null; s = s._nextSub) {
    const sub = s._sub;
    fanOut++;
    if (sub._flags & REACTIVE_RECOMPUTING_DEPS && s._gen === sub._depGen && s !== sub._depsTail)
      sub._flags |= REACTIVE_MISSED_WAKE;
    if (hasSnapshot && sub._config & CONFIG_IN_SNAPSHOT_SCOPE) {
      sub._flags |= REACTIVE_SNAPSHOT_STALE;
      continue;
    }
    enqueueSub(sub);
  }
  if (fanOut >= GRAPH_SIZE_WARN_AT) noteFanOut(node, fanOut);
}
function laneDirty(node, l) {
  for (let s = node._subs; s !== null; s = s._nextSub) {
    const t = s._sub._x?._transaction;
    if (t?._lane ? sameLane(t, l) : s._sub._type) s._sub._flags |= REACTIVE_LANE_DIRTY;
  }
}
function sameLane(a, b) {
  return a === b || a._links !== null && a._links === b._links;
}
function commitPendingNode(n) {
  const c = n;
  if (!c._fn) {
    n._config &= -385;
    if (n._pendingValue !== NOT_PENDING) {
      n._value = n._pendingValue;
      n._pendingValue = NOT_PENDING;
    }
    return;
  }
  const inFlight2 = n._pendingValue === NOT_PENDING && (c._statusFlags & STATUS_PENDING) !== 0;
  n._config = inFlight2 ? n._config & ~CONFIG_HELD | CONFIG_INPUTS_PUBLISHED : n._config & -1409;
  if (n._pendingValue !== NOT_PENDING) {
    n._value = n._pendingValue;
    n._pendingValue = NOT_PENDING;
    c._statusFlags &= ~STATUS_UNINITIALIZED;
    if (c._x != null) c._x._reask = false, c._x._flushed = NOT_PENDING;
    if (n._type && n._type !== EFFECT_TRACKED) {
      n._modified = true;
      globalQueue.enqueue(n._type, n._boundRunEffect ??= GlobalQueue._runEffect.bind(null, c));
    }
  }
  c._loading = false;
  c._flags &= ~REACTIVE_MANUAL_WRITE;
  if (c._x?._error == null) trimStaleDeps(c);
  if (!(c._statusFlags & STATUS_PENDING)) c._statusFlags &= ~STATUS_UNINITIALIZED;
  if (!inFlight2 && c._x != null && (c._x._pendingFirstChild !== null || c._x._pendingDisposal !== null))
    GlobalQueue._dispose(c, false, true);
}
function commitPendingNodes() {
  for (let i = 0; i < pendingNodes.length; i++) {
    const n = pendingNodes[i];
    if (!(n._config & (CONFIG_OVERRIDE | CONFIG_HELD))) commitPendingNode(n);
  }
  pendingNodes.length = 0;
}
var globalQueue = new GlobalQueue();
function flush(fn) {
  if (actionDepth > 0) {
    {
      throw new Error(
        "[FLUSH_IN_ACTION] flush() inside an action body is not allowed. An action's writes are held in its transaction and commit when the action settles: flush() cannot reveal them, and draining here would detach the writes that follow from the transaction. Remove the flush(); to observe the result, read after the action resolves."
      );
    }
  }
  if (fn) {
    syncDepth++;
    try {
      return fn();
    } finally {
      try {
        flush();
      } finally {
        syncDepth--;
      }
    }
  }
  if (globalQueue._running) {
    if (inTrackedQueueCallback) {
      throw new Error(
        "Cannot call flush() from inside onSettled or createTrackedEffect. flush() is not reentrant there. Writes made here are processed in the same flush's continuation; to force a drain afterwards, defer it: queueMicrotask(() => flush())."
      );
    }
    if (inEffectCallback) {
      const message = "[FLUSH_IN_EFFECT_CALLBACK] flush() called from inside an effect callback is a no-op: the flush that runs effects is already in progress. Writes made here are processed in the same flush's continuation; to force a drain afterwards, defer it: queueMicrotask(() => flush()).";
      reportDiagnostic(
        emitDiagnostic({
          code: "FLUSH_IN_EFFECT_CALLBACK",
          kind: "lifecycle",
          severity: "warn",
          message
        })
      );
    }
    return;
  }
  if (halted) return;
  let count = 0;
  let drained = false;
  if (attrHooks !== null && scheduled) attrHooks.flushStart();
  while (scheduled) {
    if (++count === 1e5) {
      throw new Error(
        `Potential Infinite Loop Detected. Kept alive by scheduled work${lastStagedNodeName ? `; last staged node: ${lastStagedNodeName}` : ""}`
      );
    }
    globalQueue.flush();
    drained = true;
  }
  if (drained && attrHooks !== null) attrHooks.flushEnd();
}
function runQueue(queue, type) {
  for (let i = 0; i < queue.length; i++) queue[i](type);
}
function enqueueSub(node) {
  if (dirtyQueue._min > node._height) dirtyQueue._min = node._height;
  insertIntoHeap(node, dirtyQueue);
}
function actualInsertIntoHeap(n, heap) {
  const parentHeight = (n._parent?._root ? n._parent._parentComputed?._height : n._parent?._height) ?? -1;
  if (parentHeight >= n._height) n._height = parentHeight + 1;
  const height = n._height;
  const heapAtHeight = heap._heap[height];
  if (heapAtHeight === void 0) heap._heap[height] = n;
  else {
    const tail = heapAtHeight._prevHeap;
    tail._nextHeap = n;
    n._prevHeap = tail;
    heapAtHeight._prevHeap = n;
  }
  if (height > heap._max) heap._max = height;
}
function insertIntoHeap(n, heap) {
  let flags = n._flags;
  if (flags & (REACTIVE_IN_HEAP | REACTIVE_RECOMPUTING_DEPS)) return;
  if (flags & REACTIVE_CHECK) {
    n._flags = flags & -4 | REACTIVE_DIRTY | REACTIVE_IN_HEAP;
  } else {
    n._flags = flags | REACTIVE_IN_HEAP;
    if (heap._marked) markNode(n);
  }
  if (!(flags & REACTIVE_IN_HEAP_HEIGHT)) actualInsertIntoHeap(n, heap);
}
function insertIntoHeapHeight(n, heap) {
  let flags = n._flags;
  if (flags & (REACTIVE_IN_HEAP | REACTIVE_RECOMPUTING_DEPS | REACTIVE_IN_HEAP_HEIGHT)) return;
  n._flags = flags | REACTIVE_IN_HEAP_HEIGHT;
  actualInsertIntoHeap(n, heap);
}
function deleteFromHeap(n, heap) {
  const flags = n._flags;
  if (!(flags & (REACTIVE_IN_HEAP | REACTIVE_IN_HEAP_HEIGHT))) return;
  n._flags = flags & -25;
  const height = n._height;
  if (n._prevHeap === n) heap._heap[height] = void 0;
  else {
    const next = n._nextHeap;
    const dhh = heap._heap[height];
    const end = next ?? dhh;
    if (n === dhh) heap._heap[height] = next;
    else n._prevHeap._nextHeap = next;
    end._prevHeap = n._prevHeap;
  }
  n._prevHeap = n;
  n._nextHeap = void 0;
}
function markHeap(heap) {
  if (heap._marked) return;
  heap._marked = true;
  for (let i = 0; i <= heap._max; i++) {
    for (let el = heap._heap[i]; el !== void 0; el = el._nextHeap) {
      if (el._flags & REACTIVE_IN_HEAP) markNode(el);
    }
  }
}
function markNode(el, newState = REACTIVE_DIRTY) {
  const flags = el._flags;
  if ((flags & (REACTIVE_CHECK | REACTIVE_DIRTY)) >= newState) return;
  el._flags = flags & -4 | newState;
  for (let link2 = el._subs; link2 !== null; link2 = link2._nextSub) {
    markNode(link2._sub, REACTIVE_CHECK);
  }
}
function runHeap(heap, recompute2) {
  heap._marked = false;
  for (heap._min = 0; heap._min <= heap._max; heap._min++) {
    let el = heap._heap[heap._min];
    while (el !== void 0) {
      if (el._flags & REACTIVE_IN_HEAP) recompute2(el);
      else adjustHeight(el, heap);
      el = heap._heap[heap._min];
    }
  }
  heap._max = 0;
}
function adjustHeight(el, heap) {
  deleteFromHeap(el, heap);
  let newHeight = el._height;
  for (let d = el._deps; d; d = d._nextDep) {
    const dep = d._dep;
    if (dep._fn && dep._height >= newHeight) newHeight = dep._height + 1;
  }
  if (el._height !== newHeight) {
    el._height = newHeight;
    for (let s = el._subs; s !== null; s = s._nextSub) insertIntoHeapHeight(s._sub, heap);
  }
}
function markDisposal(el) {
  let child = el._firstChild;
  while (child) {
    child._flags |= REACTIVE_ZOMBIE;
    markDisposal(child);
    child = child._nextSibling;
  }
}
function disposeChildren(node, self = false, zombie) {
  const flags = node._flags;
  if (flags & REACTIVE_DISPOSED) return;
  if (self && !zombie && node._x !== null && (node._x._pendingFirstChild !== null || node._x._pendingDisposal !== null))
    disposeChildren(node, false, true);
  if (self) {
    node._flags = flags | REACTIVE_DISPOSED;
    if (node._parent === null && node._root) unregisterRoot(node);
  }
  if (self && true) clearSignals(node);
  if (self && node._fn) {
    if (node._x !== null) node._x._inFlight = null;
    if (node._statusFlags & STATUS_PENDING && node._x?._transaction != null || flags & REACTIVE_FRAME_READ)
      schedule();
  }
  let child = zombie ? node._x._pendingFirstChild : node._firstChild;
  if (zombie) node._x._pendingFirstChild = null;
  else node._firstChild = null;
  while (child) {
    const n = child;
    n._config &= ~CONFIG_AUTO_DISPOSE;
    deleteFromHeap(n, dirtyQueue);
    clearDeps(n);
    child._prevSibling = child;
    disposeChildren(child, true);
    child = child._nextSibling;
  }
  if (!zombie) node._childCount = 0;
  if (self && !zombie && !(flags & REACTIVE_ZOMBIE) && node._parent !== null && !(node._parent._flags & REACTIVE_DISPOSED)) {
    const prev = node._prevSibling;
    const next = node._nextSibling;
    assertInvariant(
      prev !== null || node._parent._firstChild === node,
      "owner-chain-head",
      "head node is not parent._firstChild \u2014 a node was spliced while flagged live but not in the chain (see #3543)"
    );
    if (prev !== null) prev._nextSibling = next;
    else node._parent._firstChild = next;
    if (next !== null) next._prevSibling = prev;
    node._prevSibling = null;
  }
  runDisposal(node, zombie);
  if (self && node._cleanup) {
    const effectCleanup = node._cleanup;
    node._cleanup = void 0;
    enterDisposal();
    effectCleanup();
    exitDisposal();
  }
}
function linkChild(parent, node) {
  const head = parent._firstChild;
  node._prevSibling = null;
  node._nextSibling = head;
  if (head !== null) head._prevSibling = node;
  parent._firstChild = node;
}
function runDisposal(node, zombie) {
  const disposal = zombie ? node._x._pendingDisposal : node._disposal;
  if (!disposal) return;
  if (zombie) node._x._pendingDisposal = null;
  else node._disposal = null;
  enterDisposal();
  if (Array.isArray(disposal)) {
    for (let i = disposal.length - 1; i >= 0; i--) {
      const callable = disposal[i];
      callable.call(callable);
    }
  } else {
    disposal.call(disposal);
  }
  exitDisposal();
}
function childId(owner, consume) {
  let counter = owner;
  while (counter._config & CONFIG_TRANSPARENT && counter._parent) counter = counter._parent;
  if (counter.id != null)
    return formatId(counter.id, consume ? counter._childCount++ : counter._childCount);
  throw new Error("Cannot get child id from owner without an id");
}
function getNextChildId(owner) {
  return childId(owner, true);
}
function inheritId(options, transparent, parent) {
  return options?.id ?? (transparent ? parent?.id : parent?.id != null ? getNextChildId(parent) : void 0);
}
function formatId(prefix, id) {
  const num = id.toString(36), len = num.length - 1;
  return prefix + (len ? String.fromCharCode(64 + len) : "") + num;
}
function getObserver() {
  return tracking ? context : null;
}
function getOwner() {
  return context;
}
function cleanup(fn) {
  if (!context) return fn;
  if (!context._disposal) context._disposal = fn;
  else if (Array.isArray(context._disposal)) context._disposal.push(fn);
  else context._disposal = [context._disposal, fn];
  return fn;
}
function disposeRootSelf(self = true) {
  disposeChildren(this, self);
}
function createOwner(options) {
  const parent = context;
  const transparent = options?.transparent ?? false;
  const owner = {
    id: inheritId(options, transparent, parent),
    _config: transparent ? CONFIG_TRANSPARENT : 0,
    _root: true,
    _parentComputed: parent?._root ? parent._parentComputed : parent,
    _firstChild: null,
    _nextSibling: null,
    _prevSibling: null,
    _disposal: null,
    _context: parent?._context || defaultContext,
    _childCount: 0,
    _x: null,
    _parent: parent,
    dispose: disposeRootSelf,
    _name: void 0
  };
  if (parent && parent._config & CONFIG_CHILDREN_FORBIDDEN) {
    emitDiagnostic({
      code: "PRIMITIVE_IN_FORBIDDEN_SCOPE",
      kind: "lifecycle",
      severity: "error",
      message: PRIMITIVE_IN_FORBIDDEN_SCOPE_MESSAGE,
      ownerId: parent.id,
      ownerName: parent._name
    });
    throw new Error(PRIMITIVE_IN_FORBIDDEN_SCOPE_MESSAGE);
  }
  assertNotInEffectCallback();
  if (parent) linkChild(parent, owner);
  else registerRoot(owner);
  DEV.hooks.onOwner?.(owner);
  return owner;
}
function createRoot(init, options) {
  const owner = createOwner(options);
  return runWithOwner(owner, () => init(() => owner.dispose()));
}
var slotUnobservedHook;
function setSlotUnobserved(fn) {
  slotUnobservedHook = fn;
}
function unlinkSubs(link2) {
  const dep = link2._dep;
  const nextDep = link2._nextDep;
  const nextSub = link2._nextSub;
  const prevSub = link2._prevSub;
  if (nextSub !== null) nextSub._prevSub = prevSub;
  else dep._subsTail = prevSub;
  if (prevSub !== null) prevSub._nextSub = nextSub;
  else {
    dep._subs = nextSub;
    if (nextSub === null) {
      if (dep._config & CONFIG_SLOT_NODE) slotUnobservedHook(dep);
      else dep._x?._unobserved?.();
      const c = dep;
      c._fn && c._config & CONFIG_AUTO_DISPOSE && !(c._flags & REACTIVE_ZOMBIE) && !(c._statusFlags & STATUS_PENDING) && unobserved(c);
    }
  }
  return nextDep;
}
function trimStaleDeps(el) {
  const depsTail = el._depsTail;
  let toRemove = depsTail !== null ? depsTail._nextDep : el._deps;
  if (toRemove !== null) {
    do {
      toRemove = unlinkSubs(toRemove);
    } while (toRemove !== null);
    if (depsTail !== null) depsTail._nextDep = null;
    else el._deps = null;
  }
}
function clearDeps(el) {
  let dep = el._deps;
  if (!dep) return;
  do {
    dep = unlinkSubs(dep);
  } while (dep !== null);
  el._deps = null;
  el._depsTail = null;
}
function unobserved(el) {
  deleteFromHeap(el, dirtyQueue);
  clearDeps(el);
  disposeChildren(el, true);
}
var dormantNodes = /* @__PURE__ */ new Set();
function sweepDormant() {
  if (dormantNodes.size === 0) return;
  for (const el of dormantNodes) {
    if (!el._subs && el._config & CONFIG_AUTO_DISPOSE && !(el._statusFlags & STATUS_PENDING) && !(el._flags & (REACTIVE_DISPOSED | REACTIVE_ZOMBIE))) {
      unobserved(el);
    }
  }
  dormantNodes.clear();
}
function link(dep, sub) {
  const prevDep = sub._depsTail;
  if (prevDep !== null && prevDep._dep === dep) return;
  let nextDep = null;
  const isRecomputing = sub._flags & REACTIVE_RECOMPUTING_DEPS;
  if (isRecomputing) {
    nextDep = prevDep !== null ? prevDep._nextDep : sub._deps;
    if (nextDep !== null && nextDep._dep === dep) {
      nextDep._gen = sub._depGen;
      sub._depsTail = nextDep;
      return;
    }
  }
  const prevSub = dep._subsTail;
  if (prevSub !== null && prevSub._sub === sub && (!isRecomputing || prevSub._gen === sub._depGen))
    return;
  const newLink = sub._depsTail = dep._subsTail = {
    _dep: dep,
    _sub: sub,
    _nextDep: nextDep,
    _prevSub: prevSub,
    _nextSub: null,
    _gen: sub._depGen
  };
  if (prevDep !== null) prevDep._nextDep = newLink;
  else sub._deps = newLink;
  if (prevSub !== null) prevSub._nextSub = newLink;
  else dep._subs = newLink;
  bumpNotifyEpoch();
}
function addPendingSource(el, source) {
  if (el._x?._pendingSources?.has(source)) return false;
  (ext(el)._pendingSources ??= /* @__PURE__ */ new Set()).add(source);
  return true;
}
function removePendingSource(el, source) {
  const sources = el._x?._pendingSources;
  if (!sources?.delete(source)) return false;
  if (!sources.size) el._x._pendingSources = void 0;
  return true;
}
function clearPendingSources(el) {
  if (el._x !== null) el._x._pendingSources = void 0;
}
function retryReaches(el, source) {
  for (let d = el._deps; d; d = d._nextDep) {
    const dep = d._dep;
    if (dep === source || dep._x?._pendingSources?.has(source)) return true;
  }
  return false;
}
function parkLoadingWindow(el, e) {
  ext(el)._blocked = true;
  if (e.source) addPendingSource(el, e.source);
  if (!(el._statusFlags & STATUS_ERROR)) setPendingError(el, e.source, e);
}
function setPendingError(el, source, error) {
  if (!source) {
    if (el._x !== null) el._x._error = null;
    return;
  }
  if (error instanceof NotReadyError && error.source === source) {
    ext(el)._error = error;
    return;
  }
  const current = el._x?._error;
  if (!(current instanceof NotReadyError) || current.source !== source) {
    ext(el)._error = new NotReadyError(source);
  }
}
function forEachDependent(el, fn) {
  for (let s = el._subs; s !== null; s = s._nextSub) fn(s._sub, s);
}
function releaseIfSettledUnobserved(node) {
  node._fn && node._config & CONFIG_AUTO_DISPOSE && !node._subs && !(node._flags & REACTIVE_ZOMBIE) && !(node._statusFlags & STATUS_PENDING) && unobserved(node);
}
function releaseSettledDependents(el) {
  let candidates;
  const visited = /* @__PURE__ */ new Set();
  const visit = (node) => {
    if (visited.has(node)) return;
    visited.add(node);
    if (!node._subs && node._config & CONFIG_AUTO_DISPOSE) (candidates ??= []).push(node);
    forEachDependent(node, visit);
  };
  forEachDependent(el, visit);
  if (candidates) for (const node of candidates) releaseIfSettledUnobserved(node);
}
function settleErroredDependents(el, error) {
  let scheduled2 = false;
  const visited = /* @__PURE__ */ new Set();
  const visit = (node) => {
    if (visited.has(node)) return;
    visited.add(node);
    if (node._x?._error === error) {
      enqueueSub(node);
      scheduled2 = true;
    }
    forEachDependent(node, visit);
  };
  forEachDependent(el, visit);
  if (scheduled2) schedule();
}
function settlePendingSource(el, source = el) {
  {
    const sources = el._x?._pendingSources;
    if (el._statusFlags & STATUS_UNINITIALIZED && el._pendingValue === NOT_PENDING && !el._x?._error && !((el._config & (CONFIG_OVERRIDE | CONFIG_GUESS)) === CONFIG_OVERRIDE && el._x._lane !== NOT_PENDING) && // A replacement source makes this a cleanup-only transfer: removing
    // self leaves the source and every propagated dependent parked. No
    // sources (or self alone) would release readers without truth.
    !(sources?.size && (sources.size > 1 || !sources.has(el)))) {
      reportDiagnostic(
        emitDiagnostic(
          {
            code: "SETTLE_WALK_UNINITIALIZED_SOURCE",
            kind: "lifecycle",
            severity: "error",
            message: "[SETTLE_WALK_UNINITIALIZED_SOURCE] settlePendingSource was called on a source that never produced a value. Settling parked readers requires truth to reveal \u2014 an uninitialized source waking its dependents serves them its initial face instead of settled data.",
            ownerId: el.id,
            ownerName: el._name
          },
          el
        )
      );
    }
  }
  removePendingSource(el, source);
  let scheduled2 = false;
  let released;
  const visited = /* @__PURE__ */ new Set();
  const settle = (node) => {
    if (visited.has(node) || // A conditional dropped this source, but another dependency can still
    // carry it. Only retire pending state inherited through the recovered
    // branch. Deliberately NOT marked visited on this early return: the
    // carrying dependency may itself be a later branch of this same walk
    // (two unchanged memos converging), and its visit must be free to
    // re-examine this node once that branch has retired the source.
    source !== el && retryReaches(node, source) || !removePendingSource(node, source))
      return node._config & CONFIG_VERDICT && enqueueSub(node);
    visited.add(node);
    node._time = clock;
    const remaining = node._x?._pendingSources?.values().next().value;
    const errored = node._statusFlags & STATUS_ERROR;
    if (remaining) {
      if (!errored) setPendingError(node, remaining);
    } else {
      node._statusFlags &= ~STATUS_PENDING;
      if (!errored) setPendingError(node);
      if (node._config & CONFIG_HELD) joinFuture(txOf(node));
      if (node._x?._blocked) {
        enqueueSub(node);
        scheduled2 = true;
      }
      if (node._x !== null) node._x._blocked = false;
      if (!node._subs && node._config & CONFIG_AUTO_DISPOSE) (released ??= []).push(node);
    }
    forEachDependent(node, settle);
  };
  forEachDependent(el, settle);
  if (released) for (const node of released) releaseIfSettledUnobserved(node);
  if (scheduled2) schedule();
}
function isThenable(value) {
  return value != null && typeof value === "object" && typeof value.then === "function";
}
function releaseFlightTeardown(el) {
  const teardown = el._x?._flightTeardown;
  if (teardown != null) {
    el._x._flightTeardown = null;
    teardown();
  }
}
function handleAsync(el, result, setter, onError) {
  let iterator = false;
  let thenable = false;
  if (typeof result === "object" && result !== null) {
    untrack(() => {
      iterator = result[Symbol.asyncIterator];
      thenable = !iterator && isThenable(result);
    });
  }
  if (!thenable && !iterator) {
    if (el._x !== null) el._x._inFlight = null;
    el._loading = false;
    return result;
  }
  if (el._config & CONFIG_SYNC) {
    const message = `[SYNC_NODE_RECEIVED_ASYNC] A computed/effect created with \`sync: true\` returned ${thenable ? "a Promise" : "an AsyncIterable"}. The value would be stored as-is and never awaited in production; remove \`sync: true\` to use async-aware behavior, or unwrap the value before returning.`;
    emitDiagnostic({
      code: "SYNC_NODE_RECEIVED_ASYNC",
      kind: "lifecycle",
      severity: "error",
      message,
      ownerId: el.id,
      ownerName: el._name
    });
    throw new Error(message);
  }
  ext(el)._inFlight = result;
  el._x._q = question || MAINLINE_QUESTION;
  el._x._pendingSources = void 0;
  if (attrHooks !== null) attrHooks.flightStart(el, result);
  let syncValue;
  const handleError = (error) => {
    if (el._x?._inFlight !== result) return;
    let stillPending = error instanceof NotReadyError;
    if (stillPending && !retryReaches(el, error.source)) {
      stillPending = false;
      error = new Error(
        "Read of an unresolved async source after an `await`. Reads inside async computations only register as dependencies before the first `await`; a source first read after it cannot retry when it settles. Read it before the first `await` (or restructure so the value is an input)."
      );
    }
    if (stillPending && el._loading) {
      if (el._x !== null) el._x._inFlight = null;
      parkLoadingWindow(el, error);
      el._time = clock;
      return;
    }
    notifyStatus(el, stillPending ? STATUS_PENDING : STATUS_ERROR, error);
    if (stillPending) settlePendingSource(el);
    el._time = clock;
    if (!stillPending) releaseSettledDependents(el);
    onError?.(error, stillPending);
  };
  const asyncWrite = (value, then) => {
    if (el._x?._inFlight !== result) return;
    if (el._flags & REACTIVE_DIRTY) return;
    const wasUninitialized = !!(el._statusFlags & STATUS_UNINITIALIZED);
    landStatus(el);
    if (attrHooks !== null) attrHooks.asyncStart(el);
    if (setter) {
      try {
        setter(value);
      } catch (error) {
        handleError(error);
        return;
      }
      if (wasUninitialized) landStatus(el, true);
      if (attrHooks !== null) attrHooks.asyncEnd(el, void 0, value, true);
    } else {
      try {
        setSignal(el, () => value);
      } catch (e) {
        notifyStatus(el, STATUS_ERROR, e);
      }
      if (attrHooks !== null) attrHooks.asyncEnd(el, void 0, value, false);
    }
    if (el._pendingValue === NOT_PENDING) {
      el._loading = false;
      trimStaleDeps(el);
    }
    settlePendingSource(el);
    schedule();
    flush();
    then?.();
  };
  const settleAutodispose = () => {
    if (el._config & CONFIG_AUTO_DISPOSE && !el._subs && !(el._statusFlags & STATUS_PENDING)) {
      unobserved(el);
      return true;
    }
    return false;
  };
  const consumeIterator = (source, registerClose) => {
    const it = source[Symbol.asyncIterator]();
    let hadValue = false;
    let completed = false;
    let initialRead = !registerClose;
    const close = () => {
      if (completed) return;
      completed = true;
      try {
        const returned = it.return?.();
        if (isThenable(returned)) returned.then(void 0, () => {
        });
      } catch {
      }
    };
    registerClose ? registerClose(close) : cleanup(close);
    ext(el)._flightTeardown = close;
    const iterateOrRelease = () => {
      if (!settleAutodispose()) iterate();
    };
    const iterate = () => {
      let syncResult, syncError, resolved = false, rejected = false, isSync = true;
      const step = it.next();
      const settled = isThenable(step) ? step : { then: (onSettle) => void onSettle(step) };
      settled.then(
        (r) => {
          if (isSync && initialRead) {
            syncResult = r;
            resolved = true;
            if (r.done) completed = true;
          } else if (el._x?._inFlight !== result) {
            return;
          } else if (!r.done) {
            hadValue = true;
            asyncWrite(r.value, iterateOrRelease);
          } else {
            completed = true;
            if (hadValue) {
              schedule();
              flush();
            } else {
              asyncWrite(void 0);
            }
            settleAutodispose();
          }
        },
        (e) => {
          if (isSync && initialRead) {
            syncError = e;
            rejected = true;
          } else if (el._x?._inFlight === result) {
            completed = true;
            handleError(e);
            settleAutodispose();
          }
        }
      );
      isSync = false;
      if (rejected) {
        completed = true;
        handleError(syncError);
        if (initialRead) throw syncError;
        return true;
      }
      if (resolved && !syncResult.done) {
        syncValue = syncResult.value;
        hadValue = true;
        return iterate();
      }
      return resolved && syncResult.done;
    };
    const immediatelyDone = iterate();
    initialRead = false;
    return hadValue || immediatelyDone;
  };
  let liveLanded = null;
  const flattenIfIterable = (value, registerClose) => {
    let innerIterator = false;
    if (typeof value === "object" && value !== null) {
      untrack(() => {
        innerIterator = value[Symbol.asyncIterator];
      });
    }
    if (!innerIterator) return false;
    const landed = consumeIterator(value, registerClose);
    if (!registerClose) liveLanded = landed;
    return true;
  };
  if (thenable) {
    let resolved = false, rejected = false, syncError, isSync = true;
    const registerDeferredClose = (fn) => {
      if (!el._disposal) el._disposal = fn;
      else if (Array.isArray(el._disposal)) el._disposal.push(fn);
      else el._disposal = [el._disposal, fn];
    };
    watchAsyncTail(el, result).then(
      (v) => {
        if (isSync) {
          syncValue = v;
          resolved = true;
        } else if (el._x?._inFlight === result && !(el._flags & REACTIVE_DISPOSED) && flattenIfIterable(v, registerDeferredClose)) ;
        else {
          asyncWrite(v);
          settleAutodispose();
        }
      },
      (e) => {
        if (isSync) {
          syncError = e;
          rejected = true;
        } else {
          handleError(e);
          settleAutodispose();
        }
      }
    );
    isSync = false;
    if (rejected) {
      handleError(syncError);
      throw syncError;
    } else if (!resolved) {
      if (el._loading) return el._value;
      throw new NotReadyError(context);
    } else if (!flattenIfIterable(syncValue)) {
      el._loading = false;
    }
  }
  if (iterator) flattenIfIterable(result);
  if (liveLanded !== null) {
    if (!liveLanded) {
      if (el._loading) return el._value;
      throw new NotReadyError(context);
    }
    el._loading = false;
  }
  return syncValue;
}
function clearStatus(el, clearUninitialized = false) {
  if (el._x?._pendingSources) clearPendingSources(el);
  if (el._x?._blocked) {
    if (el._x !== null) el._x._blocked = false;
  }
  el._statusFlags = clearUninitialized ? 0 : el._statusFlags & STATUS_UNINITIALIZED;
  if (el._x?._error) setPendingError(el);
  const notify = statusNotifierOf(el);
  if (notify) notify.call(el);
}
function landStatus(el, clearUninitialized = false) {
  const sources = el._x?._pendingSources;
  if (sources && (sources.delete(el), sources.size)) {
    el._x._blocked = false;
    if (clearUninitialized) el._statusFlags = STATUS_PENDING;
    setPendingError(el, sources.values().next().value);
  } else clearStatus(el, clearUninitialized);
}
function notifyStatus(el, status, error, blockStatus) {
  if (status === STATUS_ERROR && !(error instanceof StatusError) && !(error instanceof NotReadyError))
    error = new StatusError(el, error);
  const pendingSource = status === STATUS_PENDING && error instanceof NotReadyError ? error.source : void 0;
  {
    if (status === STATUS_PENDING && pendingSource) {
      addPendingSource(el, pendingSource);
      el._statusFlags = STATUS_PENDING | el._statusFlags & STATUS_UNINITIALIZED;
      setPendingError(el, pendingSource, error);
    } else {
      clearPendingSources(el);
      el._statusFlags = status | (status !== STATUS_ERROR ? el._statusFlags & STATUS_UNINITIALIZED : 0);
      ext(el)._error = error;
    }
  }
  if (status === STATUS_PENDING && el._config & CONFIG_GUESS) {
    if (passLane === null) joinFuture(null);
    return;
  }
  const elNotify = statusNotifierOf(el);
  if (elNotify) {
    {
      elNotify.call(el);
    }
    return;
  }
  propagateStatus(el, status, error);
}
function propagateStatus(el, status, error, downstreamBlockStatus) {
  const pendingSource = status === STATUS_PENDING && error instanceof NotReadyError ? error.source : void 0;
  forEachDependent(el, (sub, link2) => {
    sub._time = clock;
    if (sub._config & (CONFIG_REDERIVE | CONFIG_VERDICT) || status === STATUS_PENDING && link2._gen !== sub._depGen) {
      enqueueSub(sub);
      schedule();
      return;
    }
    if (status === STATUS_PENDING && pendingSource && sub._x?._pendingSources?.has(pendingSource)) {
      if (passLane === null && (sub._config & (CONFIG_HELD | CONFIG_OVERRIDE)) === CONFIG_HELD && globalQueue._running)
        joinFuture(txOf(sub));
      return;
    }
    if (status === STATUS_PENDING && pendingSource || status !== STATUS_PENDING && (sub._x?._error !== error || sub._x?._pendingSources)) {
      {
        if (passLane !== null) GlobalQueue._laneStage(sub, passLane, true, el);
        else {
          queuePendingNode(sub);
          if (status === STATUS_PENDING && (sub._config & (CONFIG_HELD | CONFIG_OVERRIDE)) === CONFIG_HELD && !sub._type)
            joinFuture(txOf(sub));
        }
      }
      notifyStatus(sub, status, error);
    }
  });
}
GlobalQueue._update = (el) => {
  if (el._type === EFFECT_TRACKED) {
    deleteFromHeap(el, dirtyQueue);
    el._modified = true;
    globalQueue.enqueue(EFFECT_USER, el._run);
  } else if (el._flags & REACTIVE_ZOMBIE && !(el._flags & REACTIVE_LANE_DIRTY)) deferZombie(el);
  else recompute(el);
};
GlobalQueue._dispose = disposeChildren;
var PRIMITIVE_IN_FORBIDDEN_SCOPE_MESSAGE = "[PRIMITIVE_IN_FORBIDDEN_SCOPE] Cannot create reactive primitives inside createTrackedEffect or owner-backed onSettled";
var PRIMITIVE_IN_EFFECT_CALLBACK_MESSAGE = "[PRIMITIVE_IN_EFFECT_CALLBACK] Cannot create a memo, effect or root with no owner inside an effect callback. The effect phase runs with no ambient owner, so a computation created here belongs to nobody: it is never disposed and never held. Create it in the compute (a flow component owns its children), or parent it explicitly with runWithOwner.";
function assertNotInEffectCallback() {
  if (inEffectCallback && context === null) {
    emitDiagnostic({
      code: "PRIMITIVE_IN_EFFECT_CALLBACK",
      kind: "lifecycle",
      severity: "error",
      message: PRIMITIVE_IN_EFFECT_CALLBACK_MESSAGE
    });
    throw new Error(PRIMITIVE_IN_EFFECT_CALLBACK_MESSAGE);
  }
}
var REACTIVE_WRITE_IN_OWNED_SCOPE_SIGNAL_MESSAGE = "[REACTIVE_WRITE_IN_OWNED_SCOPE] Writing to reactive state inside an owned scope (component, computation) is not allowed. Move the write outside or set the `ownedWrite` option if this is intentional.";
var tracking = false;
var context = null;
var snapshotCaptureActive = false;
var snapshotSources = null;
function ownerInSnapshotScope(owner) {
  while (owner) {
    if (owner._snapshotScope) return true;
    owner = owner._parent;
  }
  return false;
}
function recompute(el, create2 = false) {
  bumpNotifyEpoch();
  const isEffect = el._type;
  const prevLane = passLane;
  setPassLane(
    (el._flags & REACTIVE_LANE_DIRTY || (el._config & (CONFIG_OVERRIDE | CONFIG_GUESS)) === CONFIG_OVERRIDE) && el._x?._transaction?._lane ? el._x._transaction : (
      // Loose `!=`: false with no creator lane (undefined == null).
      create2 && prevLane?._parent._verdict != prevLane && (creatorPass(context)?._flags ?? 0) & REACTIVE_RECOMPUTING_DEPS ? prevLane : null
    )
  );
  let devChanged = false;
  {
    el._devWindows = 0;
    if (attrHooks !== null) attrHooks.recomputeStart(el, create2);
  }
  if (!create2) {
    deleteFromHeap(el, dirtyQueue);
    if (el._x !== null) {
      el._x._inFlight = null;
      releaseFlightTeardown(el);
    }
    if (el._statusFlags & STATUS_PENDING) el._config &= ~CONFIG_VERDICT;
    if (el._config & CONFIG_HELD) {
      const tx = txOf(el);
      if (tx._lane) ;
      else if (isEffect !== EFFECT_RENDER && !(el._config & CONFIG_VERDICT)) joinPassTx(tx);
      else if (tx !== flushTransaction && !(el._statusFlags & STATUS_UNINITIALIZED)) {
        el._pendingValue = NOT_PENDING;
        if (isEffect === EFFECT_RENDER) el._config &= ~CONFIG_HELD;
      }
    }
    if (isEffect === EFFECT_TRACKED || el._config & CONFIG_STAGED) disposeChildren(el);
    else if (el._firstChild !== null || el._disposal !== null) parkChildren(el);
    clearSignals(el);
  }
  const wasUninitialized = !!(el._statusFlags & STATUS_UNINITIALIZED);
  const outgoingError = el._statusFlags & STATUS_ERROR ? el._x?._error : void 0;
  const wasPending = (el._statusFlags & STATUS_PENDING) !== 0;
  const outgoingPendingSources = wasPending ? el._x?._pendingSources : void 0;
  const wasPendingSource = el._x?._pendingSources?.has(el);
  const reask = (el._flags & REACTIVE_REASK) !== 0 && !(el._statusFlags & STATUS_PENDING && el._x !== null && !el._x._reask);
  const oldcontext = context;
  context = el;
  el._depsTail = null;
  el._depGen++;
  el._flags = REACTIVE_RECOMPUTING_DEPS | el._flags & REACTIVE_ZOMBIE;
  el._time = clock;
  let value = el._pendingValue !== NOT_PENDING ? el._pendingValue : el._config & CONFIG_OVERRIDE && el._x._lane !== NOT_PENDING ? el._x._lane : el._value;
  let oldHeight = el._height;
  let missedWake = false;
  let joined = false;
  let prevTracking = tracking;
  let prevStrictRead = false;
  {
    prevStrictRead = strictRead;
    strictRead = false;
  }
  tracking = true;
  try {
    if (false) ;
    else {
      const prevInFlight = el._x?._inFlight;
      const fnResult = el._fn(value);
      const isAsyncResult = typeof fnResult === "object" && fnResult !== null;
      const selfRegistered = el._x?._inFlight !== prevInFlight;
      value = selfRegistered || !isAsyncResult ? fnResult : handleAsync(el, fnResult);
      if (!selfRegistered && !isAsyncResult) {
        if (el._x !== null) el._x._inFlight = null;
        el._loading = false;
      }
    }
    if (el._statusFlags !== 0 || el._x !== null) clearStatus(el, create2);
  } catch (e) {
    const notReady = e instanceof NotReadyError;
    if (notReady && el._loading) {
      parkLoadingWindow(el, e);
    } else {
      if (notReady) ext(el)._blocked = true;
      notifyStatus(el, notReady ? STATUS_PENDING : STATUS_ERROR, e);
      if (notReady && wasPendingSource && !el._x?._inFlight) settlePendingSource(el);
      if (notReady && outgoingPendingSources) {
        for (const source of outgoingPendingSources)
          if (source !== el && !el._x?._pendingSources?.has(source))
            settlePendingSource(el, source);
      }
    }
  } finally {
    tracking = prevTracking;
    strictRead = prevStrictRead;
    missedWake = (el._flags & REACTIVE_MISSED_WAKE) !== 0;
    joined = (el._flags & REACTIVE_JOINED) !== 0;
    if (!(el._flags & REACTIVE_PROBED)) el._config &= ~CONFIG_VERDICT;
    el._flags = el._flags & (REACTIVE_ZOMBIE | REACTIVE_DISPOSED | REACTIVE_FRAME_READ | REACTIVE_STAGED_READ | REACTIVE_LANE_READ | REACTIVE_SCREEN_READ | REACTIVE_PROBE_UNANSWERED) | (create2 ? el._flags & REACTIVE_SNAPSHOT_STALE : 0);
    context = oldcontext;
    if (el._x !== null) el._x._reask = reask && (el._statusFlags & STATUS_PENDING) !== 0;
  }
  if (el._flags & REACTIVE_DISPOSED) {
    clearDeps(el);
    if (el._x !== null) el._x._inFlight = null;
    if (attrHooks !== null) attrHooks.recomputeEnd(el, create2, false, false, false, false);
    setPassLane(prevLane);
    return;
  }
  let lane = passLane;
  const errored = !!el._x?._error;
  if (lane !== null) {
    if (GlobalQueue._laneStage(el, lane, create2, errored)) setPassLane(lane);
    else lane = null;
  }
  if (!el._x?._error) {
    {
      let fanIn = 0;
      for (let d = el._deps; d !== null; d = d._nextDep) {
        fanIn++;
        if (d === el._depsTail) break;
      }
      if (fanIn >= GRAPH_SIZE_WARN_AT) noteFanIn(el, fanIn);
    }
    const compareValue = el._pendingValue !== NOT_PENDING ? el._pendingValue : el._config & CONFIG_OVERRIDE && el._x._lane !== NOT_PENDING ? el._x._lane : el._value;
    let valueChanged = false;
    try {
      valueChanged = !isEffect && wasUninitialized || !el._equals || !el._equals(compareValue, value);
    } catch (e) {
      notifyStatus(el, STATUS_ERROR, e);
    }
    if (attrHooks !== null) {
      devChanged = valueChanged && !el._x?._error;
      if (devChanged && !isEffect && !create2) attrHooks.derivedChanged(el);
    }
    if (isEffect && valueChanged && // A stale reader of a lane (REACTIVE_SCREEN_READ) that computed what it
    // last applied owes no run (lanes.ts).
    !(el._flags & REACTIVE_SCREEN_READ && !el._modified && Object.is(el._prevValue, value)) && // A re-staging pass owes no run: the commit replays the effect (#3802).
    el._pendingValue === NOT_PENDING) {
      el._modified = !el._x?._error;
      if (!create2 || lane !== null)
        globalQueue.enqueue(
          isEffect,
          el._boundRunEffect ??= GlobalQueue._runEffect.bind(null, el),
          lane
        );
    }
    if (!create2 && lane === null && el._config & CONFIG_GUESS && GlobalQueue._laneOutcome(el, value, errored)) ;
    else if (errored) ;
    else if (valueChanged) {
      if (lane !== null) {
        if (isEffect && el._pendingValue === NOT_PENDING) el._value = value;
        else if (isEffect || lane._shown) el._pendingValue = value;
        else el._x._lane = value;
      } else if (create2 ? !((flushTransaction !== null || passTx !== null) && (joined || prevLane && el._flags & REACTIVE_STAGED_READ || (creatorPass(oldcontext)?._flags ?? 0) & REACTIVE_JOINED)) : isEffect && el._pendingValue === NOT_PENDING) {
        el._value = value;
      } else {
        el._pendingValue = value;
        if (create2) {
          holdNode(el, flushTransaction ?? passTx);
          el._statusFlags |= STATUS_UNINITIALIZED;
          GlobalQueue._fresh?.(el);
        }
      }
      if (el._subs !== null) {
        insertSubs(el);
        if (lane !== null) laneDirty(el, lane);
      }
    } else if (el._height != oldHeight) {
      for (let s = el._subs; s !== null; s = s._nextSub) insertIntoHeapHeight(s._sub, dirtyQueue);
    }
    if (!valueChanged && !el._x?._error) {
      if (outgoingError !== void 0) settleErroredDependents(el, outgoingError);
      if (outgoingPendingSources) {
        for (const source of outgoingPendingSources)
          if (source !== el) settlePendingSource(el, source);
      }
    }
    if (wasPendingSource && !(el._statusFlags & (STATUS_PENDING | STATUS_UNINITIALIZED)))
      settlePendingSource(el);
  }
  if (create2 && lane === null && (joined || prevLane && el._flags & REACTIVE_STAGED_READ) && el._statusFlags & STATUS_PENDING) {
    const t = flushTransaction ?? passTx;
    if (t !== null && !t._lane && !GlobalQueue._fresh?.(el)) holdNode(el, t);
  }
  if (!el._x?._error && el._pendingValue === NOT_PENDING && !(isEffect && el._modified)) {
    if (create2 || isEffect === EFFECT_TRACKED) trimStaleDeps(el);
    else heldTrim(el);
  }
  if (attrHooks !== null)
    attrHooks.recomputeEnd(
      el,
      create2,
      devChanged,
      lane !== null,
      flushTransaction !== null || passTx !== null || (el._config & CONFIG_HELD) !== 0,
      el._pendingValue !== NOT_PENDING
    );
  if (el._pendingValue !== NOT_PENDING || el._x !== null && (el._x._pendingFirstChild !== null || el._x._pendingDisposal !== null) || (el._statusFlags & (STATUS_PENDING | STATUS_UNINITIALIZED)) !== 0 && (!create2 || (el._statusFlags & STATUS_PENDING) !== 0)) {
    el._config |= CONFIG_STAGED;
    if (lane === null) queuePendingNode(el);
  }
  setPassLane(prevLane);
  if (missedWake) {
    enqueueSub(el);
    schedule();
  }
}
function updateIfNecessary(el) {
  if (el._flags & (REACTIVE_RECOMPUTING_DEPS | REACTIVE_DISPOSED)) return;
  if (el._flags & REACTIVE_CHECK) {
    for (let d = el._deps; d; d = d._nextDep) {
      const dep = d._dep;
      if (dep._fn) {
        updateIfNecessary(dep);
      }
      if (el._flags & REACTIVE_DIRTY) {
        break;
      }
    }
  }
  if (el._flags & REACTIVE_DIRTY || el._x?._error && el._time < clock && !el._x?._inFlight) {
    recompute(el);
  }
  el._flags = el._flags & (REACTIVE_SNAPSHOT_STALE | REACTIVE_IN_HEAP | REACTIVE_IN_HEAP_HEIGHT | REACTIVE_ZOMBIE | REACTIVE_DISPOSED | REACTIVE_MANUAL_WRITE | REACTIVE_FRAME_READ | REACTIVE_STAGED_READ | REACTIVE_LANE_READ | REACTIVE_SCREEN_READ | REACTIVE_PROBE_UNANSWERED);
}
function computed(fn, options) {
  const transparent = options?.transparent ?? false;
  const loading = options !== null && typeof options === "object" && "loadingValue" in options;
  const self = {
    id: inheritId(options, transparent, context),
    _config: (transparent ? CONFIG_TRANSPARENT : 0) | (options?.ownedWrite ? CONFIG_OWNED_WRITE : 0) | (!context || options?.lazy ? CONFIG_AUTO_DISPOSE : 0) | (options?.sync ? CONFIG_SYNC : 0) | (options?._noSnapshot ? CONFIG_NO_SNAPSHOT : 0) | // Plumbing is an observe-tier notion (a name and records to
    // withhold); the prod literal never carries the bit.
    (options?._plumbing ? CONFIG_PLUMBING : 0) | (options?._extraConfig ?? 0) | (snapshotCaptureActive && ownerInSnapshotScope(context) ? CONFIG_IN_SNAPSHOT_SCOPE : 0),
    _equals: options?.equals ?? isEqual,
    _disposal: null,
    _context: context?._context ?? defaultContext,
    _childCount: 0,
    _fn: fn,
    _value: loading ? options.loadingValue : void 0,
    _height: 0,
    _nextHeap: void 0,
    _prevHeap: null,
    _deps: null,
    _depsTail: null,
    _depGen: 0,
    _subs: null,
    _subsTail: null,
    _parent: context,
    _nextSibling: null,
    _prevSibling: null,
    _firstChild: null,
    _flags: options?.lazy ? REACTIVE_LAZY : REACTIVE_NONE,
    _statusFlags: loading ? 0 : STATUS_UNINITIALIZED,
    _time: clock,
    _pendingValue: NOT_PENDING,
    _notifiedAt: -1,
    _loading: loading,
    _x: null,
    // The slot is always present (hidden class); plumbing leaves it
    // unset, which `ownerPath` skips.
    _name: options?._plumbing ? void 0 : options?.name ?? "computed",
    // Observe: the verdict windows this pass entered (verdict.ts) — a
    // slot, so the stamp is never a write after construction.
    _devWindows: 0
  };
  if (options?.unobserved) ext(self)._unobserved = options.unobserved;
  if (options?._supersedes) self._config |= CONFIG_SUPERSEDES;
  setupComputedNode(self, options);
  return self;
}
function ext(el) {
  return el._x ??= {
    _inFlight: null,
    _flightTeardown: null,
    _error: void 0,
    _blocked: void 0,
    _pendingSources: void 0,
    _unobserved: void 0,
    _snapshotValue: void 0,
    _pendingFirstChild: null,
    _pendingDisposal: null,
    _transaction: null,
    _reask: false,
    _flushed: NOT_PENDING,
    _flushedAt: -1,
    _q: 0,
    _lane: NOT_PENDING,
    _marks: 0
  };
}
function joinPass(c, el) {
  c._flags |= REACTIVE_JOINED;
  if (el._statusFlags & STATUS_UNINITIALIZED || c._type !== EFFECT_RENDER)
    joinPassTx(
      txOf(el),
      !c._type && c._statusFlags & STATUS_UNINITIALIZED || GlobalQueue._fresh?.(c)
    );
}
function frameRead(c, el) {
  const verdict2 = c._config & CONFIG_VERDICT;
  if ((passLane === null || c._statusFlags & STATUS_UNINITIALIZED && el._statusFlags & STATUS_PENDING) && !verdict2 && (c._type !== EFFECT_RENDER || el._config & CONFIG_INPUTS_PUBLISHED))
    return false;
  const t = txOf(el);
  if (t === flushTransaction && passLane === null && !verdict2 || c._statusFlags & STATUS_UNINITIALIZED && c._config & CONFIG_HELD && txOf(c) === t)
    return false;
  staleReader(c, t);
  return true;
}
function creatorPass(owner) {
  return owner !== null && owner._root ? owner._parentComputed : owner;
}
function parkChildren(el) {
  markDisposal(el);
  const x = ext(el);
  x._pendingDisposal = el._disposal;
  x._pendingFirstChild = el._firstChild;
  el._disposal = null;
  el._firstChild = null;
  el._childCount = 0;
}
function createEffectNode(fn, effectFn, errorFn, type, options) {
  const transparent = options?.transparent ?? false;
  const self = {
    id: inheritId(options, transparent, context),
    _config: (transparent ? CONFIG_TRANSPARENT : 0) | (options?.ownedWrite ? CONFIG_OWNED_WRITE : 0) | (options?.sync ? CONFIG_SYNC : 0) | (options?._extraConfig ?? 0) | (snapshotCaptureActive && ownerInSnapshotScope(context) ? CONFIG_IN_SNAPSHOT_SCOPE : 0),
    _equals: false,
    _disposal: null,
    _context: context?._context ?? defaultContext,
    _childCount: 0,
    _fn: fn,
    _value: void 0,
    _height: 0,
    _nextHeap: void 0,
    _prevHeap: null,
    _deps: null,
    _depsTail: null,
    _depGen: 0,
    _subs: null,
    _subsTail: null,
    _parent: context,
    _nextSibling: null,
    _prevSibling: null,
    _firstChild: null,
    _flags: REACTIVE_LAZY,
    _statusFlags: STATUS_UNINITIALIZED,
    _time: clock,
    _pendingValue: NOT_PENDING,
    _notifiedAt: -1,
    _loading: false,
    _modified: false,
    _prevValue: void 0,
    _effectFn: effectFn,
    _errorFn: errorFn,
    _cleanup: void 0,
    _type: type,
    _x: null,
    _name: options?.name ?? "effect",
    _devWindows: 0
  };
  if (options?.unobserved) ext(self)._unobserved = options.unobserved;
  if (options?._wide) self._config |= CONFIG_WIDE;
  setupComputedNode(self, lazyOptions);
  return self;
}
var effectStatusNotify = null;
function setEffectStatusNotify(fn) {
  effectStatusNotify = fn;
}
function statusNotifierOf(el) {
  return el._type ? effectStatusNotify ?? void 0 : void 0;
}
var lazyOptions = { lazy: true };
function setupComputedNode(self, options) {
  self._prevHeap = self;
  const parent = context?._root ? context._parentComputed : context;
  if (context && context._config & CONFIG_CHILDREN_FORBIDDEN) {
    emitDiagnostic({
      code: "PRIMITIVE_IN_FORBIDDEN_SCOPE",
      kind: "lifecycle",
      severity: "error",
      message: PRIMITIVE_IN_FORBIDDEN_SCOPE_MESSAGE,
      ownerId: context.id,
      ownerName: context._name
    });
    throw new Error(PRIMITIVE_IN_FORBIDDEN_SCOPE_MESSAGE);
  }
  assertNotInEffectCallback();
  if (context) linkChild(context, self);
  DEV.hooks.onOwner?.(self);
  if (parent) self._height = parent._height + 1;
  GlobalQueue._wireExternalSource?.(self);
  !options?.lazy && recompute(self, true);
  if (snapshotCaptureActive && !options?.lazy) {
    if (!(self._statusFlags & STATUS_PENDING) && !(self._config & CONFIG_NO_SNAPSHOT)) {
      ext(self)._snapshotValue = self._value === void 0 ? NO_SNAPSHOT : self._value;
      self._config |= CONFIG_HAS_SNAPSHOT;
      snapshotSources.add(self);
    }
  }
}
function signal(v, options) {
  const s = {
    _equals: options?.equals ?? isEqual,
    _config: (options?.ownedWrite ? CONFIG_OWNED_WRITE : 0) | (options?._noSnapshot ? CONFIG_NO_SNAPSHOT : 0),
    _value: v,
    _subs: null,
    _subsTail: null,
    _time: clock,
    _pendingValue: NOT_PENDING,
    _notifiedAt: -1,
    _x: null,
    _name: options?.name ?? "signal",
    _owner: null
  };
  s._internal = false;
  if (options?.unobserved) ext(s)._unobserved = options.unobserved;
  if (snapshotCaptureActive && !(s._config & CONFIG_NO_SNAPSHOT)) {
    ext(s)._snapshotValue = v === void 0 ? NO_SNAPSHOT : v;
    s._config |= CONFIG_HAS_SNAPSHOT;
    snapshotSources.add(s);
  }
  return s;
}
function isEqual(a, b) {
  return a === b;
}
function slotSignal(v, equals, host, key, acc) {
  const s = {
    _equals: equals,
    _config: CONFIG_OWNED_WRITE | CONFIG_SLOT_NODE,
    _value: v,
    _subs: null,
    _subsTail: null,
    _time: clock,
    _pendingValue: NOT_PENDING,
    _notifiedAt: -1,
    _x: null,
    _host: host,
    _key: key,
    acc,
    px: void 0,
    pxv: void 0,
    _name: "signal",
    _owner: null
  };
  s._internal = false;
  return s;
}
var verdict = null;
function setVerdict(fn) {
  verdict = fn;
}
var strictRead = false;
var untrackDepth = 0;
var callbackDepth = 0;
function enterCallback() {
  callbackDepth++;
}
function exitCallback() {
  callbackDepth--;
}
var disposalDepth = 0;
function enterDisposal() {
  disposalDepth++;
}
function exitDisposal() {
  disposalDepth--;
}
function resetDisposalDepth() {
  disposalDepth = 0;
}
function setStrictRead(v) {
  const prev = strictRead;
  strictRead = v;
  return prev;
}
function untrack(fn, strictReadLabel) {
  if (GlobalQueue._externalUntrack === null && !tracking && !strictRead && !strictReadLabel && asyncTailFlights === 0)
    return fn();
  const prevTracking = tracking;
  const prevStrictRead = strictRead;
  tracking = false;
  {
    strictRead = strictReadLabel || false;
    untrackDepth++;
  }
  try {
    if (GlobalQueue._externalUntrack) return GlobalQueue._externalUntrack(fn);
    return fn();
  } finally {
    tracking = prevTracking;
    {
      strictRead = prevStrictRead;
      untrackDepth--;
    }
  }
}
var spectating = false;
function prepareComputed(comp, refresh2) {
  if (comp._flags & REACTIVE_LAZY) {
    comp._flags &= ~REACTIVE_LAZY;
    recompute(comp, true);
  } else if (comp._flags & REACTIVE_DISPOSED) {
    if (comp._config & CONFIG_AUTO_DISPOSE) {
      const parent = comp._parent;
      if (parent !== null) {
        if (parent._flags & REACTIVE_DISPOSED) {
          comp._config &= ~CONFIG_AUTO_DISPOSE;
          return;
        }
        if (!(comp._flags & REACTIVE_ZOMBIE)) linkChild(parent, comp);
      }
      recompute(comp, true);
    }
  } else ;
}
function readerSeesCommitted(el, c) {
  return !!(!c || el._pendingValue === NOT_PENDING || c._config & CONFIG_CHILDREN_FORBIDDEN);
}
var unflushedStaged = false;
function markUnflushedStaged() {
  unflushedStaged = true;
}
function unflushedValue(el) {
  if (globalQueue._running || el._pendingValue === NOT_PENDING || el._config & CONFIG_PROMOTED)
    return NOT_PENDING;
  if (el._config & CONFIG_HELD) return el._x._flushedAt === clock ? el._x._flushed : NOT_PENDING;
  return el._value;
}
function stashFlushed(el) {
  const x = el._x;
  if (x._flushedAt !== clock) {
    x._flushed = el._pendingValue;
    x._flushedAt = clock;
    unflushedStaged = true;
  }
}
var promotedWrites = [];
function markLateLinker(c) {
  c._flags |= REACTIVE_MISSED_WAKE;
  return true;
}
function resyncUnflushedCompanions() {
  unflushedStaged = false;
  if (promotedWrites.length !== 0) {
    for (const el of promotedWrites) el._config &= ~CONFIG_PROMOTED;
    promotedWrites.length = 0;
  }
}
function pullComputed(owner, c) {
  if (owner._height >= dirtyQueue._min) {
    markNode(c);
    markHeap(dirtyQueue);
    updateIfNecessary(owner);
  } else if (c._config & CONFIG_FRESH_READ) updateIfNecessary(owner);
  const height = owner._height;
  if (height >= c._height && owner._parent !== c) c._height = height + 1;
}
function read(el) {
  if (asyncTailFlights !== 0 && !tracking && untrackDepth === 0)
    checkPostAwaitRead(
      el,
      el,
      void 0,
      el._name,
      (el._statusFlags & (STATUS_PENDING | STATUS_UNINITIALIZED)) === (STATUS_PENDING | STATUS_UNINITIALIZED)
    );
  let c = context;
  if (c?._root) c = c._parentComputed;
  const computed2 = el;
  const owner = el;
  if (typeof computed2._fn === "function") prepareComputed(el);
  if (verdict !== null) return verdict(el, c);
  if (!computed2._fn && el._x?._snapshotValue === void 0 && !snapshotCaptureActive && (!unflushedStaged || el._pendingValue === NOT_PENDING) && // A28, see readNodeFast
  !(el._config & CONFIG_OVERRIDE) && // lanes: the slow path's one arm
  !strictRead) {
    if (c) {
      if (tracking) link(el, c);
      if (el._config & CONFIG_HELD && !(c._config & CONFIG_CHILDREN_FORBIDDEN)) {
        if (frameRead(c, el)) return el._value;
        joinPass(c, el);
      }
    }
    if (!c || el._pendingValue === NOT_PENDING || c._config & CONFIG_CHILDREN_FORBIDDEN)
      return el._value;
    if (c._config & CONFIG_VERDICT && stagedScreen(c)) return el._value;
    stagedRead(c);
    return el._pendingValue;
  }
  if (strictRead && owner._statusFlags & STATUS_PENDING)
    throwPendingUntrackedRead(strictRead, {
      ownerId: c?.id,
      ownerName: c?._name,
      nodeName: owner?._name
    });
  let committed2 = false;
  if (c) {
    if (tracking) {
      link(el, c);
      if (owner._fn) pullComputed(owner, c);
    }
    if (el._config & CONFIG_HELD && !(el._config & CONFIG_OVERRIDE) && !(c._config & CONFIG_CHILDREN_FORBIDDEN)) {
      if (owner._statusFlags & STATUS_UNINITIALIZED || !frameRead(c, el)) joinPass(c, el);
      else committed2 = true;
    }
  }
  if (el._config & CONFIG_OVERRIDE) {
    const v = GlobalQueue._laneRead(c, el);
    if (v !== NOT_PENDING) return v;
  }
  if (owner._statusFlags & STATUS_PENDING && !committed2 && !(el._config & CONFIG_OVERRIDE) && !(owner._statusFlags & STATUS_UNINITIALIZED)) {
    if (passLane !== null && !(c?._statusFlags & STATUS_UNINITIALIZED)) committed2 = true;
    else if (c !== null && c._config & CONFIG_VERDICT)
      committed2 = GlobalQueue._observeFlight(c, owner);
  }
  if (owner._statusFlags & STATUS_PENDING && !committed2) {
    if (c) {
      if (c._config & CONFIG_CHILDREN_FORBIDDEN) {
        const message = "[PENDING_ASYNC_FORBIDDEN_SCOPE] Reading a pending async value inside createTrackedEffect or onSettled serves the committed value (and throws while uninitialized). Use createEffect instead which supports async-aware reactivity.";
        reportDiagnostic(
          emitDiagnostic(
            {
              code: "PENDING_ASYNC_FORBIDDEN_SCOPE",
              kind: "async",
              severity: "warn",
              message,
              ownerId: c.id,
              ownerName: c._name,
              nodeName: owner?._name
            },
            c
          )
        );
      }
      if (!(c._config & CONFIG_CHILDREN_FORBIDDEN) || owner._statusFlags & STATUS_UNINITIALIZED) {
        if (!tracking && !spectating && el !== c) link(el, c);
        throw owner._x?._error;
      }
    } else if (owner._statusFlags & STATUS_UNINITIALIZED) {
      throw owner._x?._error;
    }
  }
  if (owner._fn && owner._statusFlags & STATUS_ERROR) {
    if (tracking && owner._time < clock) {
      recompute(owner);
      return read(el);
    } else throw owner._x?._error;
  }
  if (strictRead)
    warnStrictReadUntracked(strictRead, {
      ownerId: c?.id,
      ownerName: c?._name,
      nodeName: owner?._name
    });
  if (snapshotCaptureActive && c && c._config & CONFIG_IN_SNAPSHOT_SCOPE) {
    const sv = el._x?._snapshotValue;
    if (sv !== void 0) {
      const snapshot2 = sv === NO_SNAPSHOT ? void 0 : sv;
      const current = el._pendingValue !== NOT_PENDING ? el._pendingValue : el._value;
      if (current !== snapshot2) c._flags |= REACTIVE_SNAPSHOT_STALE;
      return snapshot2;
    }
  }
  if (committed2) return el._value;
  const value = serve(el, c);
  if (!c && typeof computed2._fn === "function" && el._config & CONFIG_AUTO_DISPOSE && !(owner._statusFlags & STATUS_PENDING) && !el._subs) {
    dormantNodes.add(el);
    schedule();
  }
  return value;
}
function serve(el, c) {
  if (el._pendingValue !== NOT_PENDING && el._statusFlags & STATUS_UNINITIALIZED && (!c || spectating || c._config & CONFIG_CHILDREN_FORBIDDEN))
    throw new NotReadyError(null);
  const u = c && unflushedStaged ? unflushedValue(el) : NOT_PENDING;
  if (u !== NOT_PENDING) {
    markLateLinker(c);
    return u;
  }
  if (readerSeesCommitted(el, c)) return el._value;
  if (c._config & CONFIG_VERDICT && !(el._statusFlags & STATUS_UNINITIALIZED) && stagedScreen(c))
    return el._value;
  stagedRead(c, el);
  return el._pendingValue;
}
function stagedRead(c, el) {
  if (!(el?._statusFlags & STATUS_UNINITIALIZED)) {
    c._flags |= REACTIVE_STAGED_READ;
    if (passLane !== null) stagedReaders.push(c);
  }
}
function stagedScreen(c) {
  if (flushTransaction === null) return false;
  staleReader(c, flushTransaction);
  return true;
}
function ownedScopeWriteMessage(owner) {
  const name = owner._name;
  return name ? `${REACTIVE_WRITE_IN_OWNED_SCOPE_SIGNAL_MESSAGE} (in ${name})` : REACTIVE_WRITE_IN_OWNED_SCOPE_SIGNAL_MESSAGE;
}
function notePromotedWrite(el) {
  if (globalQueue._running || el._config & CONFIG_PROMOTED) return;
  el._config |= CONFIG_PROMOTED;
  promotedWrites.push(el);
}
function captureWriteSnapshot(el, current) {
  if (el._config & CONFIG_NO_SNAPSHOT || el._fn !== void 0 || el._x?._snapshotValue !== void 0)
    return;
  ext(el)._snapshotValue = current === void 0 ? NO_SNAPSHOT : current;
  el._config |= CONFIG_HAS_SNAPSHOT;
  snapshotSources.add(el);
}
function setSignal(el, v) {
  if (!(el._config & CONFIG_OWNED_WRITE) && !(context && context._config & CONFIG_CHILDREN_FORBIDDEN) && context) {
    emitDiagnostic({
      code: "REACTIVE_WRITE_IN_OWNED_SCOPE",
      kind: "write",
      severity: "error",
      message: REACTIVE_WRITE_IN_OWNED_SCOPE_SIGNAL_MESSAGE,
      ownerId: context.id,
      ownerName: context._name,
      nodeName: el._name,
      data: { operation: "setSignal" }
    });
    throw new Error(ownedScopeWriteMessage(context));
  }
  const currentValue = el._pendingValue === NOT_PENDING ? el._value : el._pendingValue;
  if (typeof v === "function") v = v(currentValue);
  if (el._config & CONFIG_OVERRIDE) return GlobalQueue._laneWrite(el, v);
  if (el._config & CONFIG_HELD) joinFuture(txOf(el));
  const valueChanged = !!(el._statusFlags & STATUS_UNINITIALIZED) || !el._equals || !el._equals(currentValue, v);
  if (!valueChanged) return v;
  if (attrHooks !== null) attrHooks.write(el, currentValue, v);
  if (snapshotCaptureActive) captureWriteSnapshot(el, currentValue);
  const wasStaged = el._pendingValue !== NOT_PENDING;
  if (!wasStaged) queuePendingNode(el);
  else if (el._config & CONFIG_HELD && !globalQueue._running) stashFlushed(el);
  el._pendingValue = v;
  if (context !== null) notePromotedWrite(el);
  if (el._fn !== void 0) el._time = clock;
  if (wasStaged && el._notifiedAt === notifyEpoch) return v;
  insertSubs(el);
  schedule();
  return v;
}
function setMemo(el, v) {
  const held = el._config & CONFIG_HELD && !(el._flags & REACTIVE_MANUAL_WRITE) && txOf(el) !== flushTransaction;
  if (held && typeof v === "function") v = v(el._value);
  const result = setSignal(el, v);
  if (held) {
    el._flags = el._flags & ~REACTIVE_CHECK | REACTIVE_DIRTY;
    insertIntoHeap(el, dirtyQueue);
    schedule();
  } else if (el._pendingValue !== NOT_PENDING) el._flags |= REACTIVE_MANUAL_WRITE;
  return result;
}
function runWithOwner(owner, fn) {
  if (owner && owner._flags & REACTIVE_DISPOSED) {
    const message = "[RUN_WITH_DISPOSED_OWNER] runWithOwner called with a disposed owner. Children created inside will never be disposed.";
    reportDiagnostic(
      emitDiagnostic(
        {
          code: "RUN_WITH_DISPOSED_OWNER",
          kind: "owner",
          severity: "warn",
          message,
          ownerId: owner.id,
          ownerName: owner._name
        },
        owner
      )
    );
  }
  const oldContext = context;
  const prevTracking = tracking;
  context = owner;
  tracking = false;
  try {
    return fn();
  } finally {
    context = oldContext;
    tracking = prevTracking;
  }
}

// ../layered-baseline/packages/signals/dist/dev.js
var lanes = [];
var LEFT_SHOWN = 1 << 20;
function newLane(parent) {
  const l = newTransaction(true, parent);
  lanes.push(l);
  return l;
}
function laneValueOf(el) {
  if (!(el._config & CONFIG_GUESS) && el._pendingValue !== NOT_PENDING) return el._pendingValue;
  const v = el._x._lane;
  return v !== NOT_PENDING ? v : el._value;
}
function display(el) {
  const v = el._x._lane;
  return el._x._transaction._shown && v !== NOT_PENDING ? v : el._value;
}
var pendingGuesses = [];
function guessedValueOf(n) {
  const g = pendingGuessOf(n);
  if (g !== NOT_PENDING) return g;
  return n._config & CONFIG_OVERRIDE ? laneValueOf(n) : n._value;
}
function pendingGuessOf(n) {
  for (let i = pendingGuesses.length - 3; i >= 0; i -= 3)
    if (pendingGuesses[i] === n) return pendingGuesses[i + 1];
  return NOT_PENDING;
}
function optimisticWrite(n, v) {
  const prev = guessedValueOf(n);
  if (typeof v === "function") v = v(prev);
  if (n._equals && n._equals(prev, v) && !(n._config & CONFIG_GUESS)) return v;
  pendingGuesses.push(n, v, question || nextQuestion());
  schedule();
  return v;
}
function inFlight$1(n) {
  return (n._statusFlags & STATUS_PENDING) !== 0 || (n._config & CONFIG_SLOT_NODE) !== 0 && GlobalQueue._slotFlight?.(n) === true;
}
function applyGuesses(parent) {
  let lane = null;
  for (let i = 0; i < pendingGuesses.length; i += 3) {
    const n = pendingGuesses[i];
    const v = pendingGuesses[i + 1];
    let changed = true;
    if (n._config & CONFIG_OVERRIDE) {
      changed = !n._equals || !n._equals(laneValueOf(n), v);
      if (!(n._config & CONFIG_GUESS)) {
        n._pendingValue = NOT_PENDING;
        n._config |= CONFIG_GUESS;
      }
      n._x._lane = v;
      const holder = txOf(n)._parent;
      if (parent !== null && holder !== null) merge(parent, holder);
    } else {
      let l;
      if (n._config & CONFIG_HELD) l = newLane(txOf(n));
      else {
        if (parent === null && inFlight$1(n)) parent = newTransaction(false);
        if (parent === null) continue;
        l = lane ??= newLane(parent);
      }
      ext(n)._lane = v;
      n._config |= CONFIG_OVERRIDE | CONFIG_GUESS;
      list(n, l);
    }
    ext(n)._q = pendingGuesses[i + 2];
    if (changed) {
      insertSubs(n);
      laneDirty(n, txOf(n));
    }
  }
  pendingGuesses.length = 0;
}
function enterLane(l, c) {
  c._flags |= REACTIVE_LANE_READ;
  const p = passLane;
  if (p === null) {
    setPassLane(l);
    if (c._flags & REACTIVE_JOINED && c._flags & REACTIVE_STAGED_READ) stagedRead(c);
    return;
  }
  if (sameLane(p, l)) return setPassLane(l);
  if (under(p, l)) return;
  if (under(l, p)) return setPassLane(l);
  linkLanes(p, l);
  setPassLane(l);
}
function under(l, a) {
  for (let t = l._parent; t !== null && t._lane; t = t._parent) if (t === a) return true;
  return false;
}
function linkLanes(a, b) {
  const ga = a._links ?? (a._links = [a]);
  const gb = b._links;
  if (gb === ga) return;
  if (gb === null) {
    ga.push(b);
    b._links = ga;
  } else
    for (let i = 0; i < gb.length; i++) {
      ga.push(gb[i]);
      gb[i]._links = ga;
    }
}
function linkBlocked(l) {
  const g = l._links;
  if (g !== null)
    for (let i = 0; i < g.length; i++) {
      const k = g[i];
      if (k !== l && (k._open !== 0 || ownFlights(k) || nestedBlocked(k))) return true;
    }
  return false;
}
function unlink(l) {
  const g = l._links;
  if (g === null) return;
  const k = g.indexOf(l);
  if (k !== -1) g.splice(k, 1);
  l._links = null;
}
function verdictLane(t) {
  return t._verdict ??= newLane(t);
}
function laneStage(el, l, create2, errored) {
  if (!(create2 || errored || el._flags & REACTIVE_LANE_READ || el._config & CONFIG_GUESS)) {
    const x = el._x;
    if (x !== null) {
      const tx = x._transaction;
      if (tx?._shown && !blocked(resolveTx(tx._parent))) el._flags |= LEFT_SHOWN;
      if (tx?._lane) x._transaction = null;
      x._lane = NOT_PENDING;
    }
    el._config &= -2305;
    return false;
  }
  if (!el._type) {
    if (!(el._config & CONFIG_OVERRIDE)) {
      el._pendingValue = NOT_PENDING;
      el._config = el._config & ~CONFIG_HELD | CONFIG_OVERRIDE;
      ext(el);
    }
    if (!errored) el._config &= ~CONFIG_GUESS;
  } else if (errored) {
    if (errored !== true && !(errored._statusFlags & STATUS_UNINITIALIZED) && (el._config & CONFIG_HELD || el._flags & REACTIVE_RECOMPUTING_DEPS) && !el._x?._transaction?._lane) {
      queuePendingNode(el);
      return false;
    }
    el._flags |= REACTIVE_LANE_DIRTY;
  }
  list(el, l);
  return true;
}
var reverting = false;
function supersede(n, value, changed) {
  const l = txOf(n);
  const parent = resolveTx(l._parent ?? l);
  if (changed && n._config & CONFIG_SLOT_NODE && GlobalQueue._echoes?.(n._x._lane, value))
    changed = false;
  if (changed) {
    if (l._shown && attrHooks !== null)
      attrHooks.optimisticReverted(n, n._x._lane, value, reverting ? "reverted" : "superseded");
    dissolveLane(l, parent, n);
    if (l._shown) n._value = n._x._lane;
    n._config &= -10241;
    n._x._lane = NOT_PENDING;
    holdNode(n, parent);
    if (n._subs !== null) insertSubs(n);
  } else {
    n._config |= CONFIG_HELD;
    GlobalQueue._confirmed?.(l);
  }
  n._pendingValue = value;
  joinFuture(parent);
}
function dissolveLane(l, into, except) {
  const k = lanes.indexOf(l);
  if (k !== -1) lanes.splice(k, 1);
  unlink(l);
  const v = l._verdict;
  if (v !== null) {
    l._verdict = null;
    if (lanes.indexOf(v) !== -1) dissolveLane(v, null);
  }
  for (let i = 0; i < l._nodes.length; i++) {
    const n = l._nodes[i];
    const x = n._x;
    if (n === except || x._transaction !== l) continue;
    const effect3 = n._type;
    const guess = n._config & CONFIG_GUESS;
    const slot = x._lane;
    const shown2 = l._shown && !effect3 ? slot : n._value;
    const latest2 = laneValueOf(n);
    x._lane = NOT_PENDING;
    n._config &= -10241;
    if (into === null) {
      if (guess && l._shown && attrHooks !== null) {
        const truth = n._pendingValue !== NOT_PENDING ? n._pendingValue : n._value;
        if (truth !== slot)
          attrHooks.optimisticReverted(
            n,
            slot,
            truth,
            n._pendingValue !== NOT_PENDING ? "superseded" : "reverted"
          );
      }
      x._transaction = null;
      if (!effect3 && !guess) n._pendingValue = latest2;
      commitPendingNode(n);
      if (!effect3) {
        if (n._flags & (REACTIVE_IN_HEAP | REACTIVE_DIRTY | REACTIVE_CHECK) || n._statusFlags & STATUS_PENDING)
          n._config |= CONFIG_INPUTS_PUBLISHED;
        if (shown2 !== NOT_PENDING && (!n._equals || !n._equals(shown2, n._value))) insertSubs(n);
      }
    } else if (guess) {
      if (n._pendingValue === NOT_PENDING) n._pendingValue = covered(n);
      if (l._shown) n._value = slot;
      holdNode(n, into);
      insertSubs(n);
    } else {
      x._transaction = null;
      if (!effect3) {
        if (shown2 !== NOT_PENDING && l._shown) n._pendingValue = shown2;
        if (n._statusFlags & STATUS_PENDING) {
          x._inFlight = null;
          enqueueSub(n);
        }
      }
      if (l._shown) {
        commitPendingNode(n);
        if (!effect3) n._config |= CONFIG_INPUTS_PUBLISHED;
      } else {
        if (x._pendingFirstChild !== null || x._pendingDisposal !== null)
          GlobalQueue._dispose(n, false, true);
        n._config &= -385;
      }
    }
  }
  if (into === null || l._shown && !l._held) releaseQueues(l);
  else l._queues[0].length = l._queues[1].length = 0;
}
function laneRead(c, el) {
  const guess = el._config & CONFIG_GUESS;
  if (c !== null && c._config & CONFIG_AUTHORITATIVE) return GlobalQueue._truth(el);
  if (c === null) return laneValueOf(el);
  const l = txOf(el);
  const status = el._statusFlags;
  if (!tracking || c._config & CONFIG_CHILDREN_FORBIDDEN) {
    if (passLane === null || c._config & CONFIG_CHILDREN_FORBIDDEN) return display(el);
    enterLane(l, c);
    if (!guess && status & STATUS_PENDING) return NOT_PENDING;
    return laneValueOf(el);
  }
  if (c._type === EFFECT_RENDER && (passLane === null || !sameLane(passLane, l))) {
    if (!guess) {
      if (status & STATUS_PENDING && el._x._lane === NOT_PENDING) return NOT_PENDING;
      if (el._pendingValue !== NOT_PENDING && c._config & CONFIG_HELD && flushTransaction !== null && resolveTx(flushTransaction) === txOf(c))
        return el._pendingValue;
    }
    if (l._held || !guess && status & STATUS_PENDING) {
      if (!guess && !l._shown && status & STATUS_UNINITIALIZED) throw new NotReadyError(null);
      if (!(c._flags & REACTIVE_SCREEN_READ)) {
        c._flags |= REACTIVE_FRAME_READ | REACTIVE_SCREEN_READ;
        l._reruns.push(c);
      }
      return display(el);
    }
  }
  enterLane(l, c);
  if (!guess && status & STATUS_PENDING) return NOT_PENDING;
  return laneValueOf(el);
}
function covered(n) {
  return n._config & CONFIG_SLOT_NODE && GlobalQueue._slotCovered !== void 0 ? GlobalQueue._slotCovered(n) : n._value;
}
function guessFlights(l) {
  for (let i = 0; i < l._nodes.length; i++) {
    const n = l._nodes[i];
    if (n._config & CONFIG_GUESS && n._x._transaction === l && inFlight$1(n)) return true;
  }
  return false;
}
function laneCorrections() {
  let judged2 = false;
  const live = lanes.slice();
  for (let k = 0; k < live.length; k++) {
    const l = live[k];
    if (lanes.indexOf(l) === -1) continue;
    const p = resolveTx(l._parent);
    if (!p._acted || p._open !== 0 || p._lane || ownFlights(p) || guessFlights(l)) continue;
    judged2 = true;
    for (let i = 0; i < l._nodes.length && lanes.indexOf(l) !== -1; i++) {
      const n = l._nodes[i];
      if (n._config & CONFIG_GUESS && n._x._transaction === l) {
        const truth = n._pendingValue !== NOT_PENDING ? n._pendingValue : covered(n);
        reverting = n._pendingValue === NOT_PENDING;
        supersede(n, truth, !n._equals || !n._equals(n._x._lane, truth));
        reverting = false;
      }
    }
  }
  return judged2;
}
function laneSeam(l, leaked) {
  if (leaked || blocked(l)) {
    l._held = true;
    return;
  }
  l._held = false;
  l._shown = true;
  reruns(l);
  for (let i = 0; i < l._nodes.length; i++) {
    const n = l._nodes[i];
    if (n._flags & LEFT_SHOWN) {
      n._flags ^= LEFT_SHOWN;
      insertSubs(n);
    }
    const x = n._x;
    if (x._transaction !== l) continue;
    if (!(n._config & CONFIG_GUESS) && !n._type && n._pendingValue !== NOT_PENDING) {
      x._lane = n._pendingValue;
      n._pendingValue = NOT_PENDING;
    }
    if (x._pendingFirstChild !== null || x._pendingDisposal !== null)
      GlobalQueue._dispose(n, false, true);
    n._config &= ~CONFIG_STAGED;
  }
  releaseQueues(l);
}
function endLanes(u) {
  for (let k = lanes.length - 1; k >= 0; k--) {
    const l = lanes[k];
    if (resolveTx(l._parent) !== u) continue;
    endLanes(l);
    dissolveLane(l, null);
  }
}
function lanesBlocked(t) {
  return t._lane && linkBlocked(t) || nestedBlocked(t);
}
function nestedBlocked(t) {
  for (let i = 0; i < lanes.length; i++) {
    const l = lanes[i];
    if (resolveTx(l._parent) !== t) continue;
    if (blocked(l) || guessFlights(l)) return true;
  }
  return false;
}
function laneWrite(el, v) {
  if (el._config & CONFIG_GUESS) {
    if (stale(el, question)) {
      el._pendingValue = v;
      el._config |= CONFIG_HELD;
      GlobalQueue._laneRebase?.(el, v);
      schedule();
      return v;
    }
    supersede(el, v, !el._equals || !el._equals(el._x._lane, v));
  } else {
    const l = txOf(el);
    if (el._equals && el._equals(laneValueOf(el), v)) return v;
    if (l._shown) el._pendingValue = v;
    else el._x._lane = v;
    if (el._fn !== void 0) el._time = clock;
    insertSubs(el);
    laneDirty(el, l);
  }
  schedule();
  return v;
}
function laneOutcome(el, value, errored) {
  if (errored) return true;
  if (stale(el, answered(el))) {
    el._pendingValue = value;
    el._config |= CONFIG_HELD;
    return true;
  }
  supersede(el, value, !el._equals || !el._equals(el._x._lane, value));
  return true;
}
function stale(el, q) {
  return q !== 0 && q < el._x._q;
}
function answered(el) {
  let q = 0;
  for (let l = el._deps; l !== null; l = l._nextDep) {
    const d = l._dep;
    if (d._x !== null && d._x._q > q && d._time === clock) q = d._x._q;
  }
  return q;
}
GlobalQueue._laneRead = laneRead;
GlobalQueue._laneStage = laneStage;
GlobalQueue._laneOutcome = laneOutcome;
GlobalQueue._laneWrite = laneWrite;
var judged = 0;
GlobalQueue._applyGuesses = (parent) => {
  judged = lanes.length;
  if (pendingGuesses.length !== 0) applyGuesses(parent);
};
GlobalQueue._laneSeams = (leaks) => {
  const leaked = [];
  if (leaks !== null)
    for (let i = 0; i < leaks.length; i++) {
      const r = leaks[i];
      const l = r._x?._transaction;
      if (r._flags & REACTIVE_DISPOSED || l != null && l._parent?._verdict === l && (r._config & CONFIG_VERDICT ? !(r._flags & REACTIVE_PROBE_UNANSWERED) : !blocked(l._parent)))
        continue;
      enqueueSub(r);
      if (l != null && l._lane && leaked.indexOf(l) === -1) leaked.push(l);
    }
  for (let k = Math.min(judged, lanes.length) - 1; k >= 0; k--)
    laneSeam(lanes[k], leaked.indexOf(lanes[k]) !== -1);
};
GlobalQueue._laneCorrections = () => lanes.length !== 0 && laneCorrections();
GlobalQueue._endLanes = endLanes;
GlobalQueue._laneGuesses = (t) => {
  const out = [];
  for (let i = 0; i < lanes.length; i++) {
    const l = lanes[i];
    if (resolveTx(l._parent) !== t) continue;
    for (let j = 0; j < l._nodes.length; j++)
      if (l._nodes[j]._config & CONFIG_GUESS && l._nodes[j]._x._transaction === l)
        out.push(l._nodes[j]);
  }
  return out;
};
GlobalQueue._lanesBlocked = lanesBlocked;
GlobalQueue._verdictLane = verdictLane;
function watchVerdict(c, unanswered = false) {
  if (unanswered) c._flags |= REACTIVE_PROBE_UNANSWERED;
  stagedReaders.push(c);
}
function route(c, t) {
  if (passLane === null && !(c._flags & (REACTIVE_JOINED | REACTIVE_STAGED_READ)))
    setPassLane(verdictLane(t));
  c._flags |= REACTIVE_LANE_READ;
}
function observeFlight(c, el) {
  if (el._config & CONFIG_INPUTS_PUBLISHED) return false;
  if (globalQueue._running) {
    joinFuture(null);
    if (!(el._config & CONFIG_HELD)) queuePendingNode(el);
    verdictRead(c, flushTransaction, true);
  }
  return true;
}
var latestActive = false;
var probing = false;
var probeFound = false;
function verdictRead(c, t, plain) {
  route(c, t);
  if (plain) staleReader(c, t);
  else if (probing && t._reruns[t._reruns.length - 1] !== c) t._reruns.push(c);
}
function provisionalVerdict(c, notFinal) {
  if (!probing) {
    joinFuture(null);
    verdictRead(c, flushTransaction);
    return;
  }
  if (flushTransaction !== null) {
    if (notFinal) probeFound = true;
    verdictRead(c, flushTransaction);
    if (c._flags & REACTIVE_STAGED_READ) watchVerdict(c);
    return;
  }
  watchVerdict(c, notFinal);
}
function quietPending(el) {
  const x = el._x;
  if (x === null) return false;
  if (x._pendingSources !== void 0) {
    for (const source of x._pendingSources) if (!source._x?._reask) return false;
    return true;
  }
  return x._reask;
}
function heldNotFinal(owner) {
  if ((owner._statusFlags & STATUS_PENDING) !== 0 && !quietPending(owner)) return true;
  return owner._pendingValue !== NOT_PENDING && !latestActive && !owner._x._reask && !(owner._statusFlags & STATUS_UNINITIALIZED) && (!owner._equals || !owner._equals(owner._value, owner._pendingValue));
}
function pendingVerdict(c, el) {
  if (el._statusFlags & STATUS_UNINITIALIZED) return;
  if (probing && !quietPending(el)) probeFound = true;
  if (c !== null && tracking) {
    if (el._config & CONFIG_HELD) verdictRead(c, txOf(el));
    else if (globalQueue._running) provisionalVerdict(c, false);
  }
}
function markVerdictReader(window2) {
  let c = context;
  if (c?._root) c = c._parentComputed;
  if (c !== null && tracking) {
    c._config |= CONFIG_VERDICT;
    c._flags |= REACTIVE_PROBED;
    c._devWindows = (c._devWindows ?? 0) | window2;
  }
}
function isPending(fn) {
  markVerdictReader(1);
  const prevProbing = probing;
  const prevFound = probeFound;
  const prevVerdict = verdict;
  probing = true;
  probeFound = false;
  setVerdict(verdictValue);
  try {
    fn();
    return probeFound;
  } catch (e) {
    if (e instanceof NotReadyError && !probeFound && context !== null) throw e;
    return probeFound;
  } finally {
    probing = prevProbing;
    probeFound = prevFound;
    setVerdict(prevVerdict);
  }
}
function heldLatest(el, c) {
  const u = unflushedValue(el);
  if (u === NOT_PENDING) return el._pendingValue;
  if (c !== null) markLateLinker(c);
  return u;
}
function verdictValue(el, c) {
  const owner = el;
  const owned = c !== null && !(c._config & CONFIG_CHILDREN_FORBIDDEN);
  const tracked = owned && tracking;
  if (c !== null && tracking) {
    link(el, c);
    if (owner._fn !== void 0) {
      setVerdict(null);
      pullComputed(owner, c);
      setVerdict(verdictValue);
    }
  }
  if (probing && GlobalQueue._marked !== void 0 && GlobalQueue._marked(owner)) {
    probeFound = true;
    if (tracked && flushTransaction !== null) verdictRead(c, flushTransaction);
  }
  if (el._config & CONFIG_OVERRIDE) {
    const l = txOf(el);
    if (tracked) verdictRead(c, l._parent ?? l);
    const flying = (owner._statusFlags & STATUS_PENDING) !== 0 && !quietPending(owner);
    if (el._config & CONFIG_GUESS) {
      if (probing && (flying || el._pendingValue !== NOT_PENDING && (!el._equals || !el._equals(el._x._lane, el._pendingValue))))
        probeFound = true;
      return el._x._lane;
    }
    if (probing && flying) probeFound = true;
    return latestActive && !flying ? laneValueOf(el) : display(el);
  }
  if (strictRead)
    warnStrictReadUntracked(strictRead, {
      ownerId: c?.id,
      ownerName: c?._name,
      nodeName: owner?._name
    });
  const uninitialized = (owner._statusFlags & STATUS_UNINITIALIZED) !== 0;
  if (el._config & CONFIG_HELD) {
    if (!uninitialized) {
      const t = txOf(el);
      if (tracked && !probing && c._type === EFFECT_RENDER && passLane === null && t._verdict !== null && t._verdict._held && flushTransaction !== t) {
        staleReader(c, t._verdict);
        return el._value;
      }
      if (tracked) verdictRead(c, t);
      if (probing && heldNotFinal(owner)) probeFound = true;
      if (latestActive && el._pendingValue !== NOT_PENDING) {
        if (!tracked && flushTransaction !== null && !globalQueue._running) joinFuture(txOf(el));
        return heldLatest(el, tracked ? c : null);
      }
      return el._value;
    }
    if (el._pendingValue !== NOT_PENDING && !(owner._statusFlags & STATUS_PENDING)) {
      if (probing && owned) joinPass(c, el);
      return el._pendingValue;
    }
  } else if (el._pendingValue !== NOT_PENDING) {
    if (owner._statusFlags & STATUS_PENDING && !uninitialized)
      pendingVerdict(tracked ? c : null, owner);
    else if (tracked && globalQueue._running)
      provisionalVerdict(c, !latestActive && !uninitialized);
    else if (tracked && probing) watchVerdict(c);
    if (latestActive) {
      if (globalQueue._running) return el._pendingValue;
      if (c !== null) markLateLinker(c);
    }
    return el._value;
  }
  if (owner._statusFlags & STATUS_PENDING) {
    if (!uninitialized) {
      pendingVerdict(tracked ? c : null, owner);
      return el._value;
    }
    if (c !== null && !tracking && !spectating && el !== c) link(el, c);
    throw owner._x?._error;
  }
  if (owner._fn !== void 0 && owner._statusFlags & STATUS_ERROR) throw owner._x._error;
  return el._value;
}
GlobalQueue._observeFlight = observeFlight;
GlobalQueue._witnessMark = () => {
  if (probing) probeFound = true;
};
function effect(compute, effect3, error, options) {
  const isUser = !!options?.user;
  const node = createEffectNode(
    compute,
    effect3,
    error,
    isUser ? EFFECT_USER : EFFECT_RENDER,
    options
  );
  recompute(node, true);
  !options?.defer && node._pendingValue === NOT_PENDING && !node._x?._transaction?._lane && (node._type === EFFECT_USER || options?.schedule ? globalQueue.enqueue(node._type, runEffect.bind(null, node)) : runEffect(node, node._type));
  if (!node._parent) {
    const message = "[NO_OWNER_EFFECT] Effects created outside a reactive context will never be disposed";
    reportDiagnostic(
      emitDiagnostic(
        {
          code: "NO_OWNER_EFFECT",
          kind: "lifecycle",
          severity: "warn",
          message,
          ownerId: node.id,
          ownerName: node._name,
          data: { effectType: "effect" }
        },
        node
      )
    );
  }
}
function notifyEffectStatus(status, error) {
  const actualStatus = status !== void 0 ? status : this._statusFlags;
  const actualError = error !== void 0 ? error : this._x?._error;
  if (actualStatus & STATUS_ERROR) {
    globalQueue.notify(this, STATUS_PENDING, 0);
    if (this._type === EFFECT_USER) {
      if (this._statusFlags & STATUS_ERROR) {
        this._modified = true;
        globalQueue.enqueue(this._type, this._boundRunEffect ??= runEffect.bind(null, this));
      }
      return;
    }
    if (!globalQueue.notify(this, STATUS_ERROR, STATUS_ERROR)) {
      haltReactivity(unwrapStatusError(actualError));
      throw actualError;
    }
  } else if (this._type === EFFECT_RENDER) {
    globalQueue.notify(this, STATUS_PENDING | STATUS_ERROR, actualStatus, actualError);
    if (_hitUnhandledAsync && resetUnhandledAsync()) {
      const message = "[ASYNC_OUTSIDE_LOADING_BOUNDARY] An async value was read outside a Loading boundary. The root mount will be deferred until all pending async settles.";
      reportDiagnostic(
        emitDiagnostic(
          {
            code: "ASYNC_OUTSIDE_LOADING_BOUNDARY",
            kind: "async",
            severity: "warn",
            message,
            ownerId: this.id,
            ownerName: this._name
          },
          this
        )
      );
    }
  }
}
function runEffect(node, type) {
  if (!node._modified || node._flags & REACTIVE_DISPOSED) return;
  if (GlobalQueue._heldRun && GlobalQueue._heldRun(node)) return;
  if (node._statusFlags & STATUS_ERROR && node._type === EFFECT_USER) {
    const err = unwrapStatusError(node._x?._error);
    node._prevValue = node._value;
    node._modified = false;
    try {
      node._errorFn ? node._errorFn(err, () => {
        const prevCleanup2 = node._cleanup;
        node._cleanup = void 0;
        prevCleanup2?.();
      }) : console.error(err);
    } catch (error) {
      if (!globalQueue.notify(node, STATUS_ERROR, STATUS_ERROR)) {
        haltReactivity(error);
        throw error;
      }
    }
    return;
  }
  const cleanPass = node._x?._error == null;
  let prevStrictRead = false;
  {
    prevStrictRead = setStrictRead("an effect callback");
    setEffectCallback(true);
    enterCallback();
  }
  if (attrHooks !== null) attrHooks.effectRunStart(node);
  const prevCleanup = node._cleanup;
  node._cleanup = void 0;
  try {
    prevCleanup?.();
    const nextCleanup = node._effectFn(node._value, node._prevValue);
    if (nextCleanup !== void 0 && typeof nextCleanup !== "function") {
      throw new Error(
        `${node._name || "effect"} callback returned an invalid cleanup value. Return a cleanup function or undefined.`
      );
    }
    node._cleanup = nextCleanup;
  } catch (error) {
    ext(node)._error = new StatusError(node, error);
    node._statusFlags |= STATUS_ERROR;
    if (!globalQueue.notify(node, STATUS_ERROR, STATUS_ERROR)) {
      haltReactivity(error);
      throw error;
    }
  } finally {
    {
      setStrictRead(prevStrictRead);
      setEffectCallback(false);
      exitCallback();
    }
    node._prevValue = node._value;
    node._modified = false;
    if (cleanPass) trimStaleDeps(node);
  }
  if (attrHooks !== null) attrHooks.effectRunEnd(node);
}
GlobalQueue._runEffect = runEffect;
setEffectStatusNotify(notifyEffectStatus);
var ambientHook;
var reported = /* @__PURE__ */ new WeakSet();
function hookFor(owner) {
  for (let o = owner; o; o = o._parent) {
    const hook = o[ROOT_ERROR_HOOK];
    if (hook !== void 0) return hook;
  }
  return ambientHook;
}
function labels(owner) {
  const path = [];
  for (let o = owner; o; o = o._parent) {
    const name = o._name;
    if (typeof name === "string" && name.length) path.push(name);
  }
  return path.length ? path.reverse() : void 0;
}
function reportClientError(error, owner, thrower) {
  const isObject = error !== null && (typeof error === "object" || typeof error === "function");
  if (isObject) {
    if (reported.has(error)) return;
    reported.add(error);
  }
  const hook = hookFor(owner);
  if (hook === void 0) return;
  const context2 = {};
  const boundary = labels(owner);
  const path = labels(thrower) ?? boundary;
  if (path !== void 0) context2.ownerPath = path;
  if (boundary !== void 0) context2.boundaryPath = boundary;
  try {
    hook(error, context2);
  } catch (hookError) {
    console.error(hookError);
  }
}
function accessor(node) {
  const fn = read.bind(null, node);
  fn[$REFRESH] = node;
  return fn;
}
function createSignal(first, second) {
  if (typeof first === "function") {
    const node2 = computed(first, second);
    node2._config &= ~CONFIG_AUTO_DISPOSE;
    return [accessor(node2), setMemo.bind(null, node2)];
  }
  const node = signal(first, second);
  registerGraph(node, getOwner());
  return [accessor(node), setSignal.bind(null, node)];
}
function createMemo(compute, options) {
  return accessor(computed(compute, options));
}
function createRenderEffect(compute, effectFn, options) {
  effect(compute, effectFn, void 0, options);
}
var $OWNER = /* @__PURE__ */ Symbol("STORE_OWNER");
var storeLookup = /* @__PURE__ */ new WeakMap();
function setLookup(raw, t) {
  (t.fam?.map ?? storeLookup).set(raw, t);
}
function isOwned(raw) {
  return raw[$OWNER] !== void 0;
}
function lookupTarget(raw, fam) {
  const owner = raw[$OWNER];
  return owner !== void 0 && owner.fam === fam ? owner : (fam?.map ?? storeLookup).get(raw);
}
function devAssertNeverUserMutation(target) {
  return;
}
function markDescendants(target) {
  let t = target;
  while (t && !t.d) {
    t.d = true;
    t = t.u;
  }
}
var storeOwners = /* @__PURE__ */ new WeakMap();
var $TRACK = /* @__PURE__ */ Symbol("STORE_TRACK");
var $TARGET = /* @__PURE__ */ Symbol("STORE_TARGET");
var $PROXY = /* @__PURE__ */ Symbol("STORE_PROXY");
var $RECORD = /* @__PURE__ */ Symbol("VIEW_RECORD");
var rawValues = /* @__PURE__ */ new WeakSet();
var rawValuesUsed = false;
function isRawValue(value) {
  return rawValuesUsed && rawValues.has(value);
}
function markRawOne(v) {
  if (isWrappable(v)) {
    if (v[$TARGET] !== void 0) return;
    if (lookupTarget(v, null) !== void 0)
      throw new Error(
        "shallow store: an ingested record is already tracked as a deep store \u2014 one value cannot present both wrapped and raw"
      );
    rawValuesUsed = true;
    rawValues.add(v);
  }
}
var OBJECT_PROTO = Object.prototype;
var wrappableProtos = /* @__PURE__ */ new WeakMap();
function isWrappable(obj) {
  if (obj == null || typeof obj !== "object" || Object.isFrozen(obj)) return false;
  const proto = Object.getPrototypeOf(obj);
  if (proto === OBJECT_PROTO || proto === null) return true;
  if (Array.isArray(obj)) return true;
  let wrappable = wrappableProtos.get(proto);
  if (wrappable === void 0) {
    wrappable = Object.prototype.toString.call(obj) === "[object Object]" && (typeof Node === "undefined" || !(obj instanceof Node));
    wrappableProtos.set(proto, wrappable);
  }
  return wrappable;
}
var writeOverride = false;
var optHooks = null;
function installOptHooks(hooks2) {
  optHooks = hooks2;
}
var affectsHooks = null;
var $DEEP = /* @__PURE__ */ Symbol("STORE_DEEP");
function TargetShape() {
  this.v = void 0;
  this.ch = void 0;
  this.pb = void 0;
  this.n = void 0;
  this.h = void 0;
  this.k = void 0;
  this.dk = void 0;
  this.u = void 0;
  this.pk = void 0;
  this.px = void 0;
  this.d = void 0;
  this.a = void 0;
  this.sc = void 0;
  this.kc = void 0;
  this.nc = void 0;
  this.fam = void 0;
  this.s = void 0;
  this.ovl = void 0;
  this.del = void 0;
  this.wk = void 0;
}
TargetShape.prototype = Object.prototype;
function createTarget(value, parent, parentKey, fam = parent?.fam ?? null) {
  const t = Array.isArray(value) ? [] : new TargetShape();
  t.v = value;
  t.ch = value[$TARGET] !== void 0;
  t.pb = null;
  t.n = null;
  t.h = null;
  t.k = null;
  t.dk = null;
  t.wk = null;
  t.u = parent;
  t.pk = parentKey;
  t.px = null;
  t.d = false;
  t.a = false;
  t.sc = 0;
  t.kc = 0;
  t.nc = 0;
  t.fam = fam;
  t.s = false;
  t.ovl = false;
  t.del = null;
  t.px = new Proxy(t, traps);
  setLookup(value, t);
  return t;
}
function wrap(value, parent = null, parentKey = null, fam = parent?.fam ?? null) {
  if (rawValuesUsed && isRawValue(value)) return value;
  const existing = lookupTarget(value, fam);
  if (existing !== void 0) return existing.px;
  const t = value[$TARGET];
  if (t !== void 0 && t.px === value) {
    if (fam === null || t.fam === fam) return value;
    return createTarget(value, parent, parentKey, fam).px;
  }
  return createTarget(value, parent, parentKey, fam).px;
}
function unwrapValue(v) {
  if (v == null || typeof v !== "object") return v;
  const t = v[$TARGET];
  if (t !== void 0 && (t.px === v || lookupTarget(v, t.fam) === t) && t.v !== void 0) {
    if (t.ovl) materializePB(t);
    return t.pb ?? t.v;
  }
  return v;
}
var slotNodeEquals = function(a, b) {
  return isEqual(a, b) || sameLogicalSlot(this._host, a, b);
};
function sameKey(a, b) {
  return a === b || a !== a && b !== b;
}
var LaneView = class {
  rows;
  base;
  removed;
  constructor(rows, base, removed = null) {
    this.rows = rows;
    this.base = base;
    this.removed = removed;
  }
};
function asBacking(v) {
  return v instanceof LaneView ? v.base : v;
}
var containerEquals = function(a, b) {
  return a === b || optHooks !== null && optHooks.arrangement(this._host, a, b);
};
function sameLogicalSlot(target, a, b) {
  if (a === null || typeof a !== "object" || b === null || typeof b !== "object") return false;
  const at = lookupTarget(a, target.fam);
  return at !== void 0 && at === lookupTarget(b, target.fam);
}
var deferredReleases = /* @__PURE__ */ new Set();
function releaseSlot(node) {
  const t = node._host;
  const key = node._key;
  if (key === $TRACK) {
    if (t.k === node) t.k = null;
  } else if (key === $DEEP) {
    if (t.dk === node) t.dk = null;
  } else if (t.n !== null && t.n[key] === node) {
    delete t.n[key];
    t.nc--;
  } else if (t.h !== null && t.h[key] === node) delete t.h[key];
  if (t.fam !== null && t.nc === 0 && t.k === null && t.dk === null && (t.h === null || Reflect.ownKeys(t.h).length === 0))
    t.fam.live.delete(t);
}
function noteNode(target, node, key) {
  if (target.fam !== null) target.fam.live.add(target);
  markDescendants(target);
  if (affectsHooks !== null) affectsHooks._born(target, node, key);
}
setSlotUnobserved((node) => {
  if (node._pendingValue !== NOT_PENDING || node._config & CONFIG_OVERRIDE)
    deferredReleases.add(node);
  else releaseSlot(node);
});
function bornStaged(target, node, staged, key) {
  if (node._equals && node._equals(node._value, staged)) return;
  queuePendingNode(node);
  node._pendingValue = staged;
  const k = target.k;
  if (k === null) return;
  if ((k._config & (CONFIG_HELD | CONFIG_OVERRIDE)) === CONFIG_HELD && heldKeyChanged(target, key))
    holdNode(node, txOf(k));
  if (k._config & CONFIG_PROMOTED) notePromotedWrite(node);
}
function getNode(target, key, accKnown = -1) {
  const nodes = target.n ??= /* @__PURE__ */ Object.create(null);
  let node = nodes[key];
  if (node === void 0) {
    const pb = target.pb;
    const created = node = slotSignal(
      committed(target)[key],
      slotNodeEquals,
      target,
      key,
      accKnown === -1 ? isOwnAccessor(pb ?? target.v, key) : accKnown === 1
    );
    if (pb !== null && !created.acc)
      bornStaged(
        target,
        created,
        target.del !== null && target.del.has(key) ? void 0 : pb[key],
        key
      );
    if (attrHooks !== null) {
      created._name = storeLabel(target) + "." + String(key);
      stampNodeOwner(created, target);
    }
    nodes[key] = node;
    target.nc++;
    noteNode(target, created, key);
  }
  return node;
}
function getHasNode(target, key) {
  const nodes = target.h ??= /* @__PURE__ */ Object.create(null);
  let node = nodes[key];
  if (node === void 0) {
    const created = node = slotSignal(key in committed(target), isEqual, target, key, false);
    const pb = target.pb;
    if (pb !== null)
      bornStaged(target, created, key in pb && !(target.del !== null && target.del.has(key)), key);
    if (attrHooks !== null) stampNodeOwner(created, target);
    nodes[key] = node;
    noteNode(target, created, key);
  }
  return node;
}
function getContainerNode(target) {
  let k = target.k;
  if (k === null) {
    k = target.k = slotSignal(target.v, containerEquals, target, $TRACK, false);
    if (attrHooks !== null) stampNodeOwner(k, target);
    noteNode(target, k, $TRACK);
    if (target.pb !== null && !directCommit) {
      k._value = preBatch(target);
      k._pendingValue = target.pb;
      queuePendingNode(k);
    }
  }
  return k;
}
function stageOn(target, pb) {
  if (target.k === null && passLane === null && (context === null || globalQueue._running) && !deriveHolds(target))
    return;
  const k = getContainerNode(target);
  if (k._pendingValue === NOT_PENDING) queuePendingNode(k);
  k._pendingValue = pb;
  if (context !== null) notePromotedWrite(k);
  if (target.fam !== null) holdWithDerive(target, k);
}
function deriveHolds(target) {
  const fw = target.fam?.node;
  return fw != null && !userWrite && (fw._config & CONFIG_HELD) !== 0;
}
GlobalQueue._storePark = (t) => {
  for (let i = 0; i < foldList.length; i++) {
    const target = foldList[i];
    if (target.k === null && target.pb !== null) holdNode(getContainerNode(target), t);
  }
};
function bumpDeep(t) {
  if (t.dk !== null) setSignal(t.dk, 1);
}
function notifyContainer(k, pb) {
  if (k._config & CONFIG_OVERRIDE) setSignal(k, pb);
  else {
    if (k._config & CONFIG_HELD) joinFuture(txOf(k));
    insertSubs(k);
    schedule();
  }
}
function storeRoot(target) {
  let root = target;
  while (root.u !== null) root = root.u;
  return root;
}
function storeRootOwner(target) {
  return storeOwners.get(storeRoot(target));
}
function stampNodeOwner(created, target) {
  created._owner = storeRootOwner(target) ?? null;
}
var storeNames = /* @__PURE__ */ new WeakMap();
function storeLabel(target) {
  return storeNames.get(storeRoot(target)) ?? "store";
}
var hasOwn$1 = Object.prototype.hasOwnProperty;
var lookupGetter = Object.prototype.__lookupGetter__;
var lookupSetter = Object.prototype.__lookupSetter__;
var propertyIsEnumerable$1 = Object.prototype.propertyIsEnumerable;
function isOwnAccessor(src, key) {
  return hasOwn$1.call(src, key) && (lookupGetter.call(src, key) !== void 0 || lookupSetter.call(src, key) !== void 0);
}
function cloneRaw(source, t) {
  t.sc || scanAccessorsOnce(t);
  if (t.sc === 2) {
    const clone2 = { ...source };
    clone2[$OWNER] = t;
    return clone2;
  }
  const descs = Object.getOwnPropertyDescriptors(source);
  for (const key of Reflect.ownKeys(descs)) {
    const d = descs[key];
    if (key === "length" && Array.isArray(source)) continue;
    d.configurable = true;
    if (!d.get && !d.set) d.writable = true;
    else t.a = true;
  }
  const clone = Array.isArray(source) ? Object.defineProperties([], descs) : Object.create(Object.getPrototypeOf(source), descs);
  clone[$OWNER] = t;
  return clone;
}
function wideClone(source, t) {
  const clone = /* @__PURE__ */ Object.create(null);
  for (const key of Reflect.ownKeys(source)) clone[key] = source[key];
  Object.setPrototypeOf(clone, Object.prototype);
  clone[$OWNER] = t;
  return clone;
}
function copyOwn(to, from, key) {
  const d = Object.getOwnPropertyDescriptor(from, key);
  if (d.get || d.set || !d.enumerable || !d.writable || !d.configurable)
    Object.defineProperty(to, key, d);
  else to[key] = d.value;
}
function scanAccessorsOnce(target) {
  const src = target.v;
  const keys = Reflect.ownKeys(src);
  let plain = Object.getPrototypeOf(src) === Object.prototype;
  for (const key of keys) {
    if (lookupGetter.call(src, key) !== void 0 || lookupSetter.call(src, key) !== void 0) {
      target.a = true;
      plain = false;
      break;
    }
    if (plain && !propertyIsEnumerable$1.call(src, key)) plain = false;
  }
  target.sc = plain ? 2 : 1;
  target.kc = keys.length;
  return !target.a;
}
var OVERLAY_MIN_KEYS = 32;
var OVERLAY_REBUILD_MAX_KEYS = 1024;
var OVERLAY_REBUILD_MIN_ADDS = 16;
var WK_ALL = /* @__PURE__ */ new Set();
var plainProto = (o) => {
  const p = Object.getPrototypeOf(o);
  return p === Object.prototype || p === Array.prototype || p === null;
};
function overlayRebuilds(t, pb) {
  if (t.kc > OVERLAY_REBUILD_MAX_KEYS) return false;
  if (t.del !== null && t.del.size !== 0) return true;
  const wk = t.wk;
  if (wk !== null && wk !== WK_ALL && wk.size <= OVERLAY_REBUILD_MIN_ADDS) return false;
  const v = t.v;
  let adds = 0;
  for (const key of Reflect.ownKeys(pb))
    if (!hasOwn$1.call(v, key) && ++adds > OVERLAY_REBUILD_MIN_ADDS) return true;
  return false;
}
function materializePB(target) {
  const pb = target.pb;
  if (!target.ovl) return pb;
  const clone = target.sc === 2 ? wideClone(target.v, target) : cloneRaw(target.v, target);
  if (target.del !== null) {
    for (const key of target.del) delete clone[key];
    target.kc -= target.del.size;
    target.del = null;
  }
  for (const key of Reflect.ownKeys(pb))
    target.sc === 2 ? clone[key] = pb[key] : copyOwn(clone, pb, key);
  target.pb = clone;
  target.ovl = false;
  if (target.k !== null && target.k._pendingValue === pb) target.k._pendingValue = clone;
  return clone;
}
function ensurePB(target) {
  let pb = target.pb;
  if (userWrite && target.fam?.opt === true && !pendingNotify.has(target))
    return target.pb = optHooks.draft(target);
  if (pb !== null && !isOwned(pb)) {
    pb = target.pb = cloneRaw(pb, target);
    const k = target.k;
    if (k !== null && !(k._config & CONFIG_HELD)) k._pendingValue = pb;
  } else if (pb === null) {
    const v = target.v;
    if (!directCommit) queueFold(target);
    if (!target.ch && !Array.isArray(v) && (target.sc !== 0 ? !target.a : scanAccessorsOnce(target)) && target.kc > OVERLAY_MIN_KEYS && isOwned(v)) {
      pb = target.pb = Object.create(v);
      target.ovl = true;
    } else pb = target.pb = cloneRaw(v, target);
    if (!directCommit) stageOn(target, pb);
  }
  return pb;
}
function privatizeCommitted(target) {
  if (isOwned(target.v)) return;
  const before = target.v;
  const clone = cloneRaw(before, target);
  target.v = clone;
  target.ch = false;
  if (target.u) {
    privatizeCommitted(target.u);
    devAssertNeverUserMutation(target.u.v);
    const pv = target.u.v;
    const slot = parentSlotKey(target, before);
    if (pv[slot] === before) pv[slot] = target.v;
  }
}
function parentSlotKey(target, expected) {
  const pk = target.pk;
  const pv = target.u.v;
  if (pv[pk] === expected || pv[pk] === target.v || !Array.isArray(pv)) return pk;
  const at = pv.indexOf(expected);
  if (at === -1) return pk;
  target.pk = at;
  return at;
}
function flattenOverlay(t, pb) {
  privatizeCommitted(t);
  const v = t.v;
  for (const key of Reflect.ownKeys(pb)) t.sc === 2 ? v[key] = pb[key] : copyOwn(v, pb, key);
  if (t.del !== null) {
    for (const key of t.del) delete v[key];
    t.kc -= t.del.size;
    t.del = null;
  }
  t.pb = null;
  t.ovl = false;
  t.wk = null;
}
var foldList = [];
var foldOlds = [];
var foldSpare = [];
var foldOldsSpare = [];
var foldIndex = null;
function queueFold(target) {
  if (target.pb !== null) return;
  schedule();
  if (foldIndex !== null) foldIndex.set(target, foldList.length);
  foldList.push(target);
  foldOlds.push(target.v);
}
function preBatch(t) {
  if (foldIndex === null) {
    foldIndex = /* @__PURE__ */ new Map();
    for (let i = 0; i < foldList.length; i++) foldIndex.set(foldList[i], i);
  }
  const at = foldIndex.get(t);
  return at === void 0 ? t.v : foldOlds[at];
}
function drainFolds() {
  if (foldList.length !== 0) {
    const list2 = foldList;
    const olds = foldOlds;
    foldList = foldSpare;
    foldOlds = foldOldsSpare;
    foldSpare = list2;
    foldOldsSpare = olds;
    foldIndex = null;
    for (let i = 0; i < list2.length; i++) {
      const t = list2[i];
      if (t.pb === null) continue;
      const k = t.k;
      if (k !== null && k._pendingValue !== NOT_PENDING) {
        foldList.push(t);
        foldOlds.push(olds[i]);
      } else foldTarget(t, olds[i]);
    }
    list2.length = 0;
    olds.length = 0;
  }
  if (deferredReleases.size !== 0) {
    for (const node of deferredReleases) {
      if (node._pendingValue === NOT_PENDING && !(node._config & CONFIG_OVERRIDE) && node._subs === null) {
        deferredReleases.delete(node);
        releaseSlot(node);
      }
    }
  }
}
GlobalQueue._slotFlight = (n) => {
  const fam = n._host?.fam;
  return fam != null && fam.node !== null && (fam.node._statusFlags & STATUS_PENDING) !== 0;
};
GlobalQueue._slotCovered = (n) => {
  const t = n._host;
  if (t.ch) {
    const key = n._key;
    const inner = t.v;
    if (t.h !== null && t.h[key] === n) n._value = untrack(() => key in inner);
    else if (t.n !== null && t.n[key] === n) n._value = untrack(() => unwrapValue(inner[key]));
  }
  return n._value;
};
GlobalQueue._storeCommit = () => {
  drainFolds();
  optHooks?.sweep();
};
GlobalQueue._storeNode = getNode;
GlobalQueue._storeWrappable = isWrappable;
var directCommit = false;
function foldTarget(t, old) {
  {
    {
      const k = t.k;
      const pb = t.pb;
      if (pb !== null) {
        if (pb === t.v) {
          t.pb = null;
          t.wk = null;
        } else if (t.ovl && (t.v !== old || !overlayRebuilds(t, pb))) {
          flattenOverlay(t, pb);
        } else if (t.v !== old) {
          privatizeCommitted(t);
          const v = t.v;
          const wk = t.wk;
          if (wk !== null && wk !== WK_ALL) {
            for (const key of wk) {
              if (hasOwn$1.call(pb, key)) copyOwn(v, pb, key);
              else delete v[key];
            }
          } else {
            for (const key of Reflect.ownKeys(pb)) {
              const d = Object.getOwnPropertyDescriptor(pb, key);
              if (d.get || d.set || !d.enumerable || !d.writable || !d.configurable)
                Object.defineProperty(v, key, d);
              else if (d.value !== old[key] || !hasOwn$1.call(old, key)) v[key] = d.value;
            }
            for (const key of Reflect.ownKeys(old)) {
              if (!hasOwn$1.call(pb, key)) delete v[key];
            }
          }
          t.pb = null;
          t.wk = null;
        } else {
          t.v = t.ovl ? materializePB(t) : pb;
          t.ch = t.v[$TARGET] !== void 0;
          t.pb = null;
          t.wk = null;
        }
      }
      if (k !== null) {
        if (k._subs === null) t.k = null;
        else if (k._value instanceof LaneView) k._value.base = t.v;
        else k._value = t.v;
      }
      if (t.v !== old && t.u) {
        const slot = parentSlotKey(t, old);
        if (t.u.v[slot] === old) {
          privatizeCommitted(t.u);
          devAssertNeverUserMutation(t.u.v);
          t.u.v[slot] = t.v;
        }
      }
    }
  }
}
function storePathOf(t) {
  let path = "";
  for (let cur = t; cur !== null; cur = cur.u)
    path = cur.pk === null ? "store" + path : "." + String(cur.pk) + path;
  return path;
}
var REPLACED_CENSUS_MAX = 64;
function sameLeaf(a, b) {
  if (a === b) return true;
  if (a === null || b === null || typeof a !== "object" || typeof b !== "object") return false;
  return unwrapValue(a) === unwrapValue(b) || targetsEqual(a, b);
}
function reportReplacedContainers(t, old, pb, writtenKeys) {
  const keys = writtenKeys ?? Reflect.ownKeys(pb);
  const isArray = Array.isArray(pb);
  const owner = storeRootOwner(t);
  for (const key of keys) {
    if (isArray && key === "length" || key === $OWNER) continue;
    if (t.del !== null && t.del.has(key)) continue;
    const ov = unwrapValue(old[key]);
    const nv = unwrapValue(pb[key]);
    if (ov === null || nv === null || typeof ov !== "object" || typeof nv !== "object" || ov === nv || targetsEqual(ov, nv))
      continue;
    const isArr = Array.isArray(nv);
    if (isArr !== Array.isArray(ov)) continue;
    let total;
    let unchanged = 0;
    if (isArr) {
      total = nv.length;
      if (total > REPLACED_CENSUS_MAX) continue;
      const oldItems = /* @__PURE__ */ new Set();
      for (const item of ov) oldItems.add(unwrapValue(item));
      for (const item of nv) if (oldItems.has(unwrapValue(item))) unchanged++;
    } else {
      const nkeys = Object.keys(nv);
      total = nkeys.length;
      if (total > REPLACED_CENSUS_MAX) continue;
      for (const k of nkeys) if (sameLeaf(ov[k], nv[k])) unchanged++;
    }
    attrHooks.storeReplaced(
      storePathOf(t) + "." + String(key),
      isArr,
      total,
      unchanged,
      isArr ? ov.length : Object.keys(ov).length,
      owner
    );
  }
}
var heldDerivationHit = false;
var userWrite = false;
function heldDerivation(t, node, key) {
  if (t.fam === null || !userWrite) return false;
  if (node !== void 0)
    return (node._config & (CONFIG_HELD | CONFIG_MANUAL_WRITE)) === CONFIG_HELD && txOf(node) !== flushTransaction;
  const k = t.k;
  return k !== null && (k._config & CONFIG_HELD) !== 0 && txOf(k) !== flushTransaction && heldKeyChanged(t, key);
}
function notifyWrites(t) {
  let pb = t.pb;
  if (pb === null) return;
  if (userWrite && t.fam?.opt === true) {
    t.pb = null;
    t.wk = null;
    t.pb = optHooks.writes(t, pb);
    return;
  }
  const old = t.v;
  if (DEV.hooks.onStoreNodeUpdate) {
    if (t.ovl) materializePB(t);
    pb = t.pb;
    for (const key of Reflect.ownKeys(pb)) {
      if (Array.isArray(pb) && key === "length" || key === $OWNER) continue;
      const ov = old[key];
      const nv = pb[key];
      if (!isEqual(ov, nv)) DEV.hooks.onStoreNodeUpdate(t.px, key, nv, ov);
    }
    for (const key of Reflect.ownKeys(old)) {
      if (key in pb || key === $OWNER) continue;
      DEV.hooks.onStoreNodeUpdate(t.px, key, void 0, old[key]);
    }
  }
  const nodes = t.n;
  const wk0 = t.wk;
  const writtenKeys = wk0 === WK_ALL || t.a === true || !plainProto(t.ovl ? t.v : pb) ? null : wk0;
  if (attrHooks !== null) reportReplacedContainers(t, old, pb, writtenKeys);
  if (t.fam !== null && !heldDerivationHit && writtenKeys !== null) {
    for (const key of writtenKeys)
      if (heldDerivation(t, nodes?.[key], key)) {
        heldDerivationHit = true;
        break;
      }
  }
  if (nodes !== null) {
    const keys = writtenKeys ?? Reflect.ownKeys(nodes);
    for (const key of keys) {
      const node = nodes[key];
      if (node === void 0) continue;
      if (node.acc === true || hasOwn$1.call(pb, key) && lookupGetter.call(pb, key) !== void 0) {
        node.acc = isOwnAccessor(pb, key);
        const od = Object.getOwnPropertyDescriptor(old, key);
        const nd = Object.getOwnPropertyDescriptor(pb, key);
        if (!nd || nd.get || nd.set) {
          if (od?.get !== nd?.get || od?.set !== nd?.set || od?.value !== nd?.value)
            setSignal(node, () => FORCE);
          continue;
        }
        if (od?.get || od?.set || !isEqual(od?.value, nd.value)) setSignal(node, () => nd.value);
        continue;
      }
      const nv = t.del !== null && t.del.has(key) ? void 0 : pb[key];
      setSignal(node, () => nv);
      if (t.fam !== null) {
        if (!userWrite) {
          node._config &= ~CONFIG_MANUAL_WRITE;
          holdWithDerive(t, node);
        } else node._config |= CONFIG_MANUAL_WRITE;
      }
    }
  }
  const has = t.h;
  if (has !== null) {
    const keys = writtenKeys ?? Reflect.ownKeys(has);
    for (const key of keys) {
      const node = has[key];
      if (node !== void 0) {
        setSignal(node, key in pb && !(t.del !== null && t.del.has(key)));
        if (t.fam !== null) holdWithDerive(t, node);
      }
    }
  }
  if (t.dk !== null) {
    if (t.del !== null && t.del.size !== 0) bumpDeep(t);
    else
      for (const key of writtenKeys ?? Reflect.ownKeys(pb)) {
        if (key === $OWNER) continue;
        const nv = pb[key];
        const ov = old[key];
        if (nv !== null && typeof nv === "object" ? !targetsEqual(ov, nv) : !isEqual(ov, nv)) {
          bumpDeep(t);
          break;
        }
      }
  }
  const k = t.k;
  if (k !== null && (k._subs !== null || k._config & CONFIG_OVERRIDE)) {
    let changed;
    if (t.ovl) {
      changed = t.del !== null && t.del.size !== 0;
      if (!changed) {
        for (const key of Reflect.ownKeys(pb)) {
          if (!hasOwn$1.call(old, key)) {
            changed = true;
            break;
          }
        }
      }
    } else {
      changed = Array.isArray(pb) && Array.isArray(old) ? arrayStructureChanged(old, pb) : membershipChanged(old, pb);
    }
    if (changed) notifyContainer(k, pb);
  }
}
var FORCE = /* @__PURE__ */ Symbol();
function targetsEqual(ov, nv) {
  if (ov === null || typeof ov !== "object" || nv === null || typeof nv !== "object") return false;
  const ot = lookupTarget(ov, null);
  return ot !== void 0 && ot === lookupTarget(nv, null);
}
function arrayStructureChanged(old, neu) {
  if (old.length !== neu.length) return true;
  for (let i = 0; i < neu.length; i++) {
    const ov = old[i];
    const nv = neu[i];
    if (!isEqual(ov, nv) && !targetsEqual(ov, nv)) return true;
  }
  return false;
}
function membershipChanged(old, neu) {
  const nk = Reflect.ownKeys(neu);
  if (Reflect.ownKeys(old).length - +isOwned(old) !== nk.length - +isOwned(neu)) return true;
  for (const key of nk) if (key !== $OWNER && !(key in old)) return true;
  return false;
}
var writeScopes = null;
var pendingNotify = /* @__PURE__ */ new Set();
function scopeKey(target) {
  if (target.fam !== null) return target.fam;
  let t = target;
  while (t.u !== null) t = t.u;
  return t;
}
function inDraft(target) {
  return writeScopes !== null && writeScopes.has(scopeKey(target));
}
function serveShallow(target, key, v) {
  if (v !== null && typeof v === "object" && v[$TARGET] !== void 0)
    return draftServe(target, wrap(v, target, key));
  return v;
}
function draftServe(target, proxy) {
  if (writeScopes !== null && inDraft(target)) {
    const ct = proxy?.[$TARGET];
    if (ct !== void 0 && ct.v !== void 0) writeScopes.add(scopeKey(ct));
  }
  return proxy;
}
function committed(t) {
  const k = t.k;
  if (k !== null) return k._pendingValue !== NOT_PENDING ? asBacking(k._value) : t.v;
  return t.pb !== null ? preBatch(t) : t.v;
}
function stagingReader() {
  let c = context;
  if (c === null) return null;
  if (c._root) c = c._parentComputed ?? null;
  return c === null || c._config & CONFIG_CHILDREN_FORBIDDEN ? null : c;
}
function readSource(target, key, shape = false) {
  if (userWrite && target.fam !== null && target.fam.opt === true && !pendingNotify.has(target) && inDraft(target)) {
    const draft = ensurePB(target);
    pendingNotify.add(target);
    return draft;
  }
  const pb = target.pb;
  if (pb === null) return target.v;
  if (inDraft(target) || writeOverride) {
    if (writeOverride && !userWrite) {
      const leaf = key !== void 0 ? target.n?.[key] : void 0;
      if (leaf !== void 0) {
        if ((leaf._config & (CONFIG_HELD | CONFIG_OVERRIDE)) === CONFIG_HELD)
          joinPassTx(txOf(leaf));
      } else {
        const k2 = target.k;
        if (k2 !== null && (k2._config & (CONFIG_HELD | CONFIG_OVERRIDE)) === CONFIG_HELD && (key === void 0 || heldKeyChanged(target, key)))
          joinPassTx(txOf(k2));
      }
    }
    return pb;
  }
  const k = target.k;
  if (key !== void 0) {
    const leaf = target.n?.[key];
    if (leaf !== void 0 && leaf._config & CONFIG_OVERRIDE) return committed(target);
  }
  const held = k !== null && (k._config & CONFIG_HELD) !== 0;
  if (held && key !== void 0 && !heldKeyChanged(target, key, shape)) return pb;
  const c = stagingReader();
  if (c === null) {
    if (getObserver() !== null) return pb;
    if (familyAhead(target)) return pb;
    if (verdict === null || !held && key !== void 0 && !keyChanged(target, key, shape))
      return held ? asBacking(k._value) : target.v;
    return k === null ? committed(target) : asBacking(read(k));
  }
  if (!held) {
    if (c._flags & REACTIVE_STAGED_READ && !(c._config & (CONFIG_VERDICT | CONFIG_CHILDREN_FORBIDDEN)))
      return pb;
    if (key !== void 0 && !keyChanged(target, key, shape)) return committed(target);
    if (k === null) {
      if (c._config & CONFIG_VERDICT && stagedScreen(c)) return committed(target);
      stagedRead(c);
      return pb;
    }
  }
  return asBacking(untrack(() => read(k)));
}
function heldKeyChanged(target, key, shape = true) {
  return changedBetween(target, target.k._value, target.k._pendingValue, key, shape);
}
function familyAhead(target) {
  return target.fam !== null && context === null && !(target.k !== null && target.k._config & CONFIG_HELD);
}
function keyChanged(target, key, shape = true) {
  return changedBetween(target, committed(target), target.pb, key, shape);
}
function changedBetween(target, v, pb, key, shape) {
  if (target.ch || pb[$TARGET] !== void 0 || Object.getPrototypeOf(pb) !== Object.getPrototypeOf(v) || !plainProto(v))
    return true;
  if (target.del !== null && target.del.has(key)) return key in v;
  const inNew = hasOwn$1.call(pb, key) || target.ovl && hasOwn$1.call(target.v, key);
  if (inNew !== hasOwn$1.call(v, key)) return true;
  if (!inNew) return false;
  if ((shape || target.a) && (isOwnAccessor(v, key) || isOwnAccessor(pb, key) || propertyIsEnumerable$1.call(v, key) !== propertyIsEnumerable$1.call(pb, key)))
    return true;
  const nv = pb[key];
  const ov = v[key];
  return !isEqual(ov, nv) && !sameLogicalSlot(target, ov, nv);
}
function nodeValue(node, backing, target) {
  let v = read(node);
  if (node._pendingValue !== NOT_PENDING && !(node._config & CONFIG_HELD) && context === null && target.fam !== null)
    v = node._pendingValue;
  return v === FORCE ? backing : v;
}
function serveDataKey(target, key, backingValue, src, node, accKnown = -1) {
  const chained = target.ch && src === target.v;
  let v = backingValue;
  if (!inDraft(target) && !writeOverride) {
    if (node === void 0 && getObserver() !== null) node = getNode(target, key, accKnown);
    if (node !== void 0) {
      const nv = nodeValue(node, backingValue, target);
      if (chained) {
        node._value = backingValue;
        if (node._config & CONFIG_OVERRIDE) v = nv;
      } else v = nv;
    }
  }
  if (target.s) return serveShallow(target, key, v);
  if (target.ch && !chained && v !== null && typeof v === "object" && v[$TARGET]?.px !== v)
    v = resolveChainedRaw(target, key, v);
  if (node !== void 0) {
    if (node.pxv === v && v !== void 0) return draftServe(target, node.px);
    if (!isWrappable(v)) return v;
    const p = wrap(v, target, key);
    node.px = p;
    node.pxv = v;
    return draftServe(target, p);
  }
  if (!isWrappable(v)) return v;
  return draftServe(target, wrap(v, target, key));
}
function linkedTo(c, n) {
  for (let d = c._deps; d !== null; d = d._nextDep) if (d._dep === n) return true;
  return false;
}
function pullFamily(target) {
  const fw = target.fam.node;
  if (fw === null || writeOverride || inDraft(target)) return;
  if (fw._statusFlags & (STATUS_PENDING | STATUS_ERROR)) {
    const c = context;
    if (c !== null && c._type === EFFECT_RENDER && !(fw._statusFlags & STATUS_ERROR) && fw._config & CONFIG_HELD && flushTransaction !== txOf(fw) && !linkedTo(c, fw))
      return;
    const overlaid2 = target.fam.overlaid;
    if (verdict === null && fw._statusFlags & STATUS_PENDING && overlaid2 !== void 0 && overlaid2.size !== 0)
      return;
    read(fw);
  } else untrack(() => read(fw));
}
function holdWithDerive(target, node) {
  const fw = target.fam?.node;
  if (fw !== void 0 && fw !== null && !userWrite && // the derive's own write (its draft or landing), not a user setter's
  fw._config & CONFIG_HELD && node._pendingValue !== NOT_PENDING && // A node carrying a guess is the lane's: its staging is the truth beneath
  // the guess (`setSignal` → `laneWrite`), never re-homed by the store.
  !(node._config & (CONFIG_HELD | CONFIG_OVERRIDE))) {
    holdNode(node, txOf(fw));
    node._x._reask = fw._x._reask;
  }
}
function resolveChainedRaw(target, key, v) {
  const innerT = target.v[$TARGET];
  if (innerT.ch) {
    const iv = resolveChainedRaw(innerT, key, v);
    return iv === v ? v : wrap(iv, innerT, key);
  }
  const owned = lookupTarget(v, innerT.fam);
  if (owned !== void 0) return owned.px;
  if ((innerT.v[key] === v || innerT.pb?.[key] === v) && isWrappable(v))
    return wrap(v, innerT, key);
  return v;
}
function enumerationSource(target) {
  if (!inDraft(target) && !writeOverride && getObserver() !== null) {
    const base = asBacking(read(getContainerNode(target)));
    return target.fam?.opt === true ? optHooks.view(target, base) : base;
  }
  const src = readSource(target);
  return optRead(target) ? optHooks.view(target, src) : src;
}
function optRead(target) {
  return target.fam !== null && target.fam.opt === true && !inDraft(target) && !writeOverride;
}
var UNSAFE_KEYS = /* @__PURE__ */ new Set(["__proto__", "prototype", "constructor"]);
var traps = {
  get(target, key, receiver) {
    if (typeof key !== "string") {
      if (key === $TARGET) return target;
      if (key === $PROXY) return receiver;
      if (key === $OWNER) return void 0;
      if (key === $RECORD) return void 0;
      if (key === $REFRESH) return target.fam?.node ?? void 0;
      if (key === $TRACK) {
        if (target.fam !== null) pullFamily(target);
        if (!inDraft(target) && getObserver() !== null) {
          read(getContainerNode(target));
          const srcT = readSource(target);
          if (srcT[$TARGET] !== void 0) srcT[$TRACK];
        }
        return void 0;
      }
    }
    if (verdict !== null && affectsHooks !== null && getObserver() === null)
      affectsHooks._witness(target, key);
    if (target.fam !== null) pullFamily(target);
    const node0 = target.n?.[key];
    if (writeScopes === null && !writeOverride) {
      const nodeH = node0;
      if (nodeH !== void 0 && nodeH.acc !== true && (!target.ch || nodeH._config & CONFIG_OVERRIDE)) {
        const nv = nodeValue(nodeH, void 0, target);
        if (nv === null || typeof nv !== "object") return nv;
        if (target.s) return serveShallow(target, key, nv);
        if (nodeH.pxv === nv) return nodeH.px;
        if (isWrappable(nv)) {
          const p = wrap(nv, target, key);
          nodeH.px = p;
          nodeH.pxv = nv;
          return p;
        }
        return nv;
      }
    }
    const src = readSource(target, key);
    if (target.del !== null && src === target.pb && target.del.has(key)) {
      if (!inDraft(target) && getObserver() !== null) read(getNode(target, key));
      return void 0;
    }
    if (asyncTailFlights !== 0 && untrackDepth === 0 && !inDraft(target) && typeof key === "string" && key !== "then" && getObserver() === null && // Own data keys only: a pending backing inherits unrewritten keys from `v`.
    (hasOwn$1.call(src, key) || hasOwn$1.call(target.v, key)))
      checkPostAwaitRead(target.n?.[key], storeRoot(target), void 0, key, false);
    if (strictRead && !inDraft(target) && typeof key === "string" && key !== "then" && getObserver() === null) {
      warnStrictReadUntracked(strictRead, {
        nodeName: key,
        data: { strictRead, property: key, source: "store" }
      });
    }
    let accProbe = -1;
    {
      let acc;
      if (node0 !== void 0) acc = node0.acc === true;
      else if (!inDraft(target) && getObserver() !== null) {
        acc = isOwnAccessor(src, key);
        if (src === (target.pb ?? target.v)) accProbe = acc ? 1 : 0;
      } else acc = false;
      if (acc) {
        if (!inDraft(target) && getObserver() !== null)
          read(node0 ?? getNode(target, key, accProbe));
        const v2 = Reflect.get(src, key, receiver);
        if (target.s) return serveShallow(target, key, v2);
        return isWrappable(v2) ? draftServe(target, wrap(v2, target, key)) : v2;
      }
    }
    const viewOvl = target.ovl && src === target.pb;
    if ((key === "constructor" || key === "__proto__" || key === "prototype") && !hasOwn$1.call(src, key) && !(viewOvl && hasOwn$1.call(target.v, key)))
      return void 0;
    let v = src[key];
    if (v === void 0 ? !hasOwn$1.call(src, key) && !(viewOvl && hasOwn$1.call(target.v, key)) : false) {
      v = Reflect.get(src, key, receiver);
      if (typeof v === "function") return v;
      if (target.ch && src === target.v) return serveDataKey(target, key, v, src, node0, accProbe);
      if (v === void 0 && !inDraft(target)) {
        if (getObserver() !== null) read(getNode(target, key, accProbe));
        const node = target.n?.[key];
        if (node) {
          const nv = nodeValue(node, void 0, target);
          if (target.s) return serveShallow(target, key, nv);
          return isWrappable(nv) ? draftServe(target, wrap(nv, target, key)) : nv;
        }
      }
      if (target.s) return serveShallow(target, key, v);
      return isWrappable(v) ? draftServe(target, wrap(v, target, key)) : v;
    }
    if (typeof v === "function" && !hasOwn$1.call(src, key) && !(viewOvl && hasOwn$1.call(target.v, key)))
      return v;
    return serveDataKey(target, key, v, src, node0, accProbe);
  },
  has(target, key) {
    if (key === $TARGET || key === $PROXY || key === $TRACK) return true;
    if (key === $OWNER || key === $RECORD) return false;
    if (verdict !== null && affectsHooks !== null && getObserver() === null)
      affectsHooks._witness(target, key);
    if (target.fam !== null) pullFamily(target);
    const src = readSource(target, key);
    if (!inDraft(target) && !writeOverride) {
      if (getObserver() !== null) {
        const node = getHasNode(target, key);
        const nv = read(node);
        if (!target.ch || src !== target.v) return !!nv;
        const present = key in src;
        node._value = present;
        if (node._config & CONFIG_OVERRIDE) return !!nv;
        return present;
      } else if (optRead(target)) {
        const guessed = optHooks.has(target, key);
        if (guessed !== void 0) return guessed;
      }
    }
    return key in src && !(target.del !== null && src === target.pb && target.del.has(key));
  },
  ownKeys(target) {
    if (verdict !== null && affectsHooks !== null && getObserver() === null)
      affectsHooks._witness(target, void 0);
    if (target.fam !== null) pullFamily(target);
    return visibleKeys(target, enumerationSource(target));
  },
  getOwnPropertyDescriptor(target, key) {
    if (key === $OWNER || key === $RECORD) return void 0;
    const obs = getObserver();
    if (verdict !== null && affectsHooks !== null && obs === null)
      affectsHooks._witness(target, key);
    if (target.fam !== null) pullFamily(target);
    const plain = obs !== null && !inDraft(target) && !writeOverride;
    const enumerating = plain && observerHoldsContainer(target, obs);
    let src;
    if (enumerating) src = enumerationSource(target);
    else if (plain) {
      const node = getHasNode(target, key);
      const present = read(node);
      src = readSource(target, key, true);
      if (!present && (!target.ch || node._config & CONFIG_OVERRIDE || !(key in src)))
        return void 0;
    } else src = readSource(target, key, true);
    let desc;
    if (!enumerating && optRead(target)) {
      const guessed = optHooks.descriptor(target, key);
      if (guessed === null) return void 0;
      desc = guessed;
    }
    desc ??= visibleDescriptor(target, src, key);
    if (desc === void 0) return void 0;
    if (!(key === "length" && Array.isArray(target))) desc.configurable = true;
    return desc;
  },
  set(target, key, value) {
    const draft = inDraft(target);
    const override = !draft && writeOverride;
    if (!draft && !override) return true;
    if (key === "__proto__") return true;
    const uv = target.s ? value : unwrapValue(value);
    const pb = ensurePB(target);
    pendingNotify.add(target);
    if (Array.isArray(pb)) {
      if (key === "length") target.wk = WK_ALL;
      else if (target.wk !== WK_ALL) {
        const wk = target.wk ??= /* @__PURE__ */ new Set();
        wk.add(key);
        wk.add("length");
      }
    } else {
      if (target.wk !== WK_ALL) (target.wk ??= /* @__PURE__ */ new Set()).add(key);
      if (!(key in pb)) target.kc++;
    }
    if (UNSAFE_KEYS.has(key)) {
      Object.defineProperty(pb, key, {
        value: uv,
        writable: true,
        enumerable: true,
        configurable: true
      });
      if (target.del !== null) target.del.delete(key);
      return true;
    }
    if (target.ovl && target.sc !== 2 && !hasOwn$1.call(pb, key)) {
      Object.defineProperty(pb, key, {
        value: uv,
        writable: true,
        enumerable: true,
        configurable: true
      });
    } else pb[key] = uv;
    if (target.del !== null) target.del.delete(key);
    if (target.s && uv !== null && typeof uv === "object") markRawOne(uv);
    if (override) notifyWrites(target);
    return true;
  },
  defineProperty(target, key, desc) {
    const draft = inDraft(target);
    const override = !draft && writeOverride;
    if (!draft && !override) return true;
    if (key === "__proto__") return true;
    if (desc.get || desc.set) target.a = true;
    if ("value" in desc) desc = { ...desc, value: unwrapValue(desc.value) };
    const pb = ensurePB(target);
    if (target.a || !(desc.enumerable && desc.writable && desc.configurable)) target.sc = 1;
    pendingNotify.add(target);
    if (target.wk !== WK_ALL) (target.wk ??= /* @__PURE__ */ new Set()).add(key);
    Object.defineProperty(pb, key, desc);
    if (target.del !== null) target.del.delete(key);
    if (override) notifyWrites(target);
    return true;
  },
  deleteProperty(target, key) {
    const draft = inDraft(target);
    const override = !draft && writeOverride;
    if (!draft && !override) return true;
    const pb = ensurePB(target);
    pendingNotify.add(target);
    if (target.wk !== WK_ALL) (target.wk ??= /* @__PURE__ */ new Set()).add(key);
    delete pb[key];
    if (target.ovl && hasOwn$1.call(target.v, key)) (target.del ??= /* @__PURE__ */ new Set()).add(key);
    if (override) notifyWrites(target);
    return true;
  }
};
function observerHoldsContainer(target, obs) {
  const k = target.k;
  if (k === null) return false;
  const l = k._subsTail;
  return l !== null && l._sub === obs && (!(obs._flags & REACTIVE_RECOMPUTING_DEPS) || l._gen === obs._depGen);
}
function visibleKeys(target, src) {
  let keys;
  if (target.ovl && src === target.pb) {
    keys = Reflect.ownKeys(target.v);
    const del = target.del;
    if (del !== null && del.size !== 0) keys = keys.filter((key) => !del.has(key));
    for (const key of Reflect.ownKeys(src)) {
      if (!hasOwn$1.call(target.v, key)) keys.push(key);
    }
  } else keys = Reflect.ownKeys(src);
  for (let i = keys.length - 1; i >= 0 && typeof keys[i] === "symbol"; i--) {
    if (keys[i] === $OWNER) {
      keys.splice(i, 1);
      break;
    }
  }
  return keys;
}
function visibleDescriptor(target, src, key) {
  let desc = Object.getOwnPropertyDescriptor(src, key);
  if (target.ovl && src === target.pb) {
    if (target.del !== null && target.del.has(key)) return void 0;
    if (desc === void 0) desc = Object.getOwnPropertyDescriptor(target.v, key);
  }
  return desc;
}
var hasOwn = Object.prototype.hasOwnProperty;
var optStaged = /* @__PURE__ */ new Map();
function writerBacking(t) {
  const base = committed(t);
  const inner = base[$TARGET];
  return inner === void 0 ? base : optimisticView(inner, writerBacking(inner), laneValueOf, true);
}
function optimisticDraft(t) {
  if (t.pb !== null) optStaged.set(t, t.pb);
  return cloneRaw(optimisticView(t, writerBacking(t), laneValueOf, true), t);
}
function notifyOptimisticWrites(t, pb) {
  const base = writerBacking(t);
  const old = optimisticView(t, base, laneValueOf, true);
  const isArr = Array.isArray(pb);
  const inner = t.ch ? t.v : null;
  const guess = (node, key, presence, nv) => {
    if (inner !== null) node._value = presence ? key in base : unwrapValue(base[key]);
    optimisticWrite(node, () => nv);
  };
  let structural = false;
  for (const key of Reflect.ownKeys(pb)) {
    if (isArr && key === "length" || key === $OWNER) continue;
    const raw = pb[key];
    const nv = unwrapValue(inner && raw ? resolveChainedRaw(t, key, raw) : raw);
    if (!(key in old)) {
      guess(getNode(t, key), key, false, nv);
      guess(getHasNode(t, key), key, true, true);
      structural = true;
    } else {
      const previous = old[key];
      const ov = unwrapValue(inner && previous ? resolveChainedRaw(t, key, previous) : previous);
      if (!isEqual(ov, nv) && !targetsEqual(ov, nv)) {
        guess(getNode(t, key), key, false, nv);
        if (isArr) structural = true;
      }
    }
  }
  for (const key of Reflect.ownKeys(old)) {
    if (isArr && key === "length" || key === $OWNER) continue;
    if (key in pb) continue;
    guess(getNode(t, key), key, false, void 0);
    guess(getHasNode(t, key), key, true, false);
    structural = true;
  }
  if (isArr && old.length !== pb.length) {
    guess(getNode(t, "length"), "length", false, pb.length);
    structural = true;
  }
  if (structural) {
    const rows = isArr ? pb.map(unwrapValue) : shallowKeys(pb);
    let removed = null;
    const keyFn = t.fam.key;
    if (isArr && keyFn !== null && keyFn !== void 0) {
      const kept = /* @__PURE__ */ new Set();
      for (let i = 0; i < rows.length; i++) {
        const k = isWrappable(rows[i]) ? keyFn(rows[i]) : void 0;
        if (k !== void 0) kept.add(k);
      }
      for (let i = 0; i < old.length; i++) {
        const r = unwrapValue(old[i]);
        const k = isWrappable(r) ? keyFn(r) : void 0;
        if (k !== void 0 && !kept.has(k)) (removed ??= /* @__PURE__ */ new Set()).add(k);
      }
    }
    optimisticWrite(getContainerNode(t), new LaneView(rows, base, removed));
  }
  if (t.dk !== null) optimisticWrite(t.dk, {});
  markOverlaid(t);
  const staged = optStaged.get(t);
  if (staged === void 0) return null;
  optStaged.delete(t);
  return staged;
}
function arrangement(t, a, b) {
  const av = a instanceof LaneView;
  const bv = b instanceof LaneView;
  if (!av && !bv) return false;
  return arrangementEqual(av ? a.rows : a, bv ? b.rows : b, t.fam?.key ?? null);
}
function rowSame(a, b, keyFn) {
  if (isEqual(a, b) || targetsEqual(a, b)) return true;
  if (keyFn === null || !isWrappable(a) || !isWrappable(b)) return false;
  const ka = keyFn(unwrapValue(a));
  const kb = keyFn(unwrapValue(b));
  if (ka === void 0 && kb === void 0) return true;
  return ka !== void 0 && sameKey(ka, kb);
}
function echoes(a, b) {
  if (a === b) return true;
  if (!isWrappable(a) || !isWrappable(b)) return false;
  a = unwrapValue(a);
  b = unwrapValue(b);
  const ak = Object.keys(a);
  if (Array.isArray(a) !== Array.isArray(b) || ak.length !== Object.keys(b).length) return false;
  for (const k of ak) if (!hasOwn.call(b, k) || !echoes(a[k], b[k])) return false;
  return true;
}
GlobalQueue._echoes = (a, b) => {
  try {
    return echoes(a, b);
  } catch {
    return false;
  }
};
function arrangementEqual(a, b, keyFn) {
  if (Array.isArray(a) !== Array.isArray(b)) return false;
  if (Array.isArray(a)) {
    if (a.length !== b.length) return false;
    for (let i = 0; i < a.length; i++) if (!rowSame(a[i], b[i], keyFn)) return false;
    return true;
  }
  const ak = Reflect.ownKeys(a).filter((k) => k !== $OWNER);
  const bk = Reflect.ownKeys(b).filter((k) => k !== $OWNER);
  if (ak.length !== bk.length) return false;
  for (const k of ak) if (!(k in b)) return false;
  return true;
}
function reconcileDraft(draft, incoming, keyFn) {
  if (Array.isArray(incoming)) {
    const n = draft.length;
    const prev = new Array(n);
    for (let i = 0; i < n; i++) prev[i] = draft[i];
    let byKey = null;
    if (keyFn !== null) {
      byKey = /* @__PURE__ */ new Map();
      for (let i = 0; i < n; i++) {
        const raw = unwrapValue(prev[i]);
        if (!isWrappable(raw)) continue;
        const k = keyFn(raw);
        if (k !== void 0 && !byKey.has(k)) byKey.set(k, prev[i]);
      }
    }
    for (let i = 0; i < incoming.length; i++) {
      const nv = incoming[i];
      let match;
      if (isWrappable(nv)) {
        if (byKey !== null) {
          const k = keyFn(nv);
          if (k !== void 0) match = byKey.get(k);
        } else if (i < n && isWrappable(unwrapValue(prev[i]))) match = prev[i];
      }
      if (match !== void 0) {
        if (unwrapValue(match) !== nv) reconcileDraft(match, nv, keyFn);
        if (draft[i] !== match) draft[i] = match;
      } else if (unwrapValue(draft[i]) !== nv) draft[i] = nv;
    }
    if (draft.length !== incoming.length) draft.length = incoming.length;
    return;
  }
  for (const k of Object.keys(incoming)) {
    const nv = incoming[k];
    const cur = draft[k];
    const curRaw = unwrapValue(cur);
    if (isWrappable(nv) && isWrappable(curRaw) && Array.isArray(nv) === Array.isArray(curRaw) && (keyFn === null || Array.isArray(nv) || sameKey(keyFn(nv), keyFn(curRaw)))) {
      if (curRaw !== nv) reconcileDraft(cur, nv, keyFn);
    } else if (curRaw !== nv) draft[k] = nv;
  }
  for (const k of Object.keys(draft)) if (!(k in incoming)) delete draft[k];
}
GlobalQueue._laneRebase = (el, truth) => {
  const t = el._host;
  if (t === void 0 || el._key !== $TRACK) return;
  const view = el._x._lane;
  if (!(view instanceof LaneView)) return;
  if (!Array.isArray(truth) || !Array.isArray(view.rows)) {
    view.base = truth;
    return;
  }
  const keyFn = t.fam?.key ?? null;
  if (keyFn === null) return;
  const byKey = /* @__PURE__ */ new Map();
  for (let i = 0; i < truth.length; i++) {
    const r = truth[i];
    const k = isWrappable(r) ? keyFn(r) : void 0;
    if (k !== void 0 && !byKey.has(k)) byKey.set(k, r);
  }
  const used = /* @__PURE__ */ new Set();
  const rows = [];
  const guessed = view.rows;
  for (let i = 0; i < guessed.length; i++) {
    const g = guessed[i];
    const k = isWrappable(g) ? keyFn(g) : void 0;
    const tr = k !== void 0 ? byKey.get(k) : void 0;
    if (tr !== void 0) {
      rows.push(tr);
      used.add(k);
    } else rows.push(g);
  }
  const removed = view.removed;
  for (let i = 0; i < truth.length; i++) {
    const r = truth[i];
    const k = isWrappable(r) ? keyFn(r) : void 0;
    if (k !== void 0 && !used.has(k) && (removed === null || !removed.has(k))) rows.push(r);
  }
  view.rows = rows;
  view.base = rows;
  const lane = txOf(el);
  const base = committed(t);
  const nodes = t.n;
  for (let i = 0; i < rows.length; i++) {
    const node = nodes?.[i];
    if (node === void 0) {
      if (!sameRow(base[i], rows[i], keyFn)) laneSet(getNode(t, i), rows[i], lane);
    } else if (!sameRow(node._config & CONFIG_OVERRIDE ? node._x._lane : base[i], rows[i], keyFn))
      laneSet(node, rows[i], lane);
  }
  if (nodes !== null) {
    for (let i = rows.length; ; i++) {
      const node = nodes[i];
      if (node === void 0) break;
      laneSet(node, void 0, lane);
    }
    const len = nodes.length;
    if (len !== void 0 && (len._config & CONFIG_OVERRIDE || base.length !== rows.length))
      laneSet(len, rows.length, lane);
  }
};
function sameRow(a, b, keyFn) {
  if (a === b) return true;
  if (!isWrappable(a) || !isWrappable(b)) return false;
  const ka = keyFn(unwrapValue(a));
  return ka !== void 0 && sameKey(ka, keyFn(unwrapValue(b)));
}
function laneSet(node, value, lane) {
  const x = ext(node);
  if (!(node._config & CONFIG_OVERRIDE)) {
    node._config |= CONFIG_OVERRIDE;
    list(node, lane);
  } else if (x._lane === value) return;
  x._lane = value;
  if (node._subs !== null) {
    insertSubs(node);
    laneDirty(node, lane);
  }
}
installOptHooks({
  draft: optimisticDraft,
  writes: notifyOptimisticWrites,
  arrangement,
  reconcile: reconcileDraft,
  view: (t, src, writer = false) => writer ? optimisticView(t, src, laneValueOf, true) : optimisticView(t, src),
  has: optimisticHas,
  descriptor: optimisticOwnDescriptor,
  sweep: sweepOverlaid
});
function shallowKeys(o) {
  const out = {};
  for (const k of Reflect.ownKeys(o)) if (k !== $OWNER) out[k] = unwrapValue(o[k]);
  return out;
}
var overlaidFamilies = /* @__PURE__ */ new Set();
function markOverlaid(t) {
  const fam = t.fam;
  (fam.overlaid ??= /* @__PURE__ */ new Set()).add(t);
  overlaidFamilies.add(fam);
}
function sweepOverlaid() {
  if (overlaidFamilies.size === 0) return;
  for (const fam of overlaidFamilies) {
    const set = fam.overlaid;
    for (const t of set)
      if (!carriesLane(t)) {
        set.delete(t);
        if (t.ch) rebaseChained(t);
        const k = t.k;
        if (k !== null && k._value instanceof LaneView) k._value = k._value.base;
      }
    if (set.size === 0) overlaidFamilies.delete(fam);
  }
}
function rebaseChained(t) {
  const inner = t.v;
  let changed = false;
  const nodes = t.n;
  if (nodes !== null)
    for (const key of Reflect.ownKeys(nodes)) {
      const node = nodes[key];
      const cur = untrack(() => unwrapValue(inner[key]));
      if (node._equals && node._equals(node._value, cur)) continue;
      node._value = cur;
      if (node._subs !== null && node._notifiedAt !== notifyEpoch) {
        insertSubs(node);
        changed = true;
      }
    }
  const has = t.h;
  if (has !== null)
    for (const key of Reflect.ownKeys(has)) {
      const node = has[key];
      const cur = untrack(() => key in inner);
      if (node._value === cur) continue;
      node._value = cur;
      if (node._subs !== null && node._notifiedAt !== notifyEpoch) {
        insertSubs(node);
        changed = true;
      }
    }
  const k = t.k;
  if (k !== null && k._subs !== null && k._value instanceof LaneView && k._notifiedAt !== notifyEpoch) {
    const rows = Array.isArray(inner) ? untrack(() => inner.map(unwrapValue)) : inner;
    if (!arrangementEqual(k._value.rows, rows, t.fam?.key ?? null)) {
      insertSubs(k);
      changed = true;
    }
  }
  if (changed) schedule();
}
function carriesLane(t) {
  if (t.k !== null && t.k._config & CONFIG_OVERRIDE) return true;
  if (t.dk !== null && t.dk._config & CONFIG_OVERRIDE) return true;
  const nodes = t.n;
  if (nodes !== null) {
    for (const key of Reflect.ownKeys(nodes)) if (nodes[key]._config & CONFIG_OVERRIDE) return true;
  }
  const has = t.h;
  if (has !== null) {
    for (const key of Reflect.ownKeys(has)) if (has[key]._config & CONFIG_OVERRIDE) return true;
  }
  return false;
}
function overlaid(t) {
  const fam = t.fam;
  return fam !== null && fam.opt === true && fam.overlaid !== void 0 && fam.overlaid.has(t);
}
var shown = (n) => untrack(() => read(n));
function optimisticHas(t, key) {
  if (!overlaid(t)) return void 0;
  const h = t.h?.[key];
  if (h !== void 0 && h._config & CONFIG_OVERRIDE) return !!shown(h);
  const n = t.n?.[key];
  if (n !== void 0 && n._config & CONFIG_OVERRIDE) return shown(n) !== void 0;
  return void 0;
}
function optimisticOwnDescriptor(t, key) {
  const present = optimisticHas(t, key);
  if (present === void 0) return void 0;
  if (!present) return null;
  const n = t.n?.[key];
  const value = n !== void 0 && n._config & CONFIG_OVERRIDE ? shown(n) : t.v[key];
  if (key === "length" && Array.isArray(t.v))
    return { value, writable: true, enumerable: false, configurable: false };
  return { value, writable: true, enumerable: true, configurable: true };
}
function optimisticView(t, src, pick = shown, writer = false) {
  if (!writer && !overlaid(t)) return src;
  let out = null;
  const ensure = () => out ??= Array.isArray(src) ? [...src] : { ...src };
  const nodes = t.n;
  if (nodes !== null) {
    for (const key of Reflect.ownKeys(nodes)) {
      const node = nodes[key];
      let ov;
      if (node._config & CONFIG_OVERRIDE) ov = pick(node);
      else if (!writer || (ov = pendingGuessOf(node)) === NOT_PENDING) continue;
      if (key === "length" && Array.isArray(src)) {
        if (src.length !== ov) ensure().length = ov;
      } else if (!isEqual(src[key], ov) || !hasOwn.call(src, key)) {
        ensure()[key] = ov;
      }
    }
  }
  const has = t.h;
  if (has !== null) {
    for (const key of Reflect.ownKeys(has)) {
      const node = has[key];
      let pv;
      if (node._config & CONFIG_OVERRIDE) pv = pick(node);
      else if (!writer || (pv = pendingGuessOf(node)) === NOT_PENDING) continue;
      const present = !!pv;
      const view = out ?? src;
      if (!present && key in view) delete ensure()[key];
    }
  }
  return out ?? src;
}
var EMPTY = Object.freeze({});
var scopes = /* @__PURE__ */ new Map();
function releaseMarkScope(carrier) {
  const entry = scopes.get(carrier);
  if (entry === void 0) return;
  scopes.delete(carrier);
  GlobalQueue._releaseMarks(entry._inherited);
}
var active = 0;
var ambient = [];
function repoll(node, seen = /* @__PURE__ */ new Set()) {
  for (let s = node._subs; s !== null; s = s._nextSub) {
    const sub = s._sub;
    if (seen.has(sub)) continue;
    seen.add(sub);
    if (sub._config & CONFIG_VERDICT) enqueueSub(sub);
    if (!sub._type) repoll(sub, seen);
  }
}
function marked(el, seen) {
  if (el._x !== null && el._x._marks !== 0) return true;
  const c = el;
  if (c._statusFlags & STATUS_ERROR || seen.has(el)) return false;
  seen.add(el);
  const tail = c._flags & REACTIVE_RECOMPUTING_DEPS ? c._depsTail : void 0;
  if (tail !== null)
    for (let d = c._deps ?? null; d !== null; d = d._nextDep) {
      if (marked(d._dep, seen)) return true;
      if (d === tail) break;
    }
  return false;
}
function release$1(nodes) {
  for (let i = 0; i < nodes.length; i++) {
    const n = nodes[i];
    active--;
    if (--n._x._marks === 0) {
      repoll(n);
      releaseMarkScope(n);
    }
  }
  nodes.length = 0;
}
function mark(node) {
  ext(node)._marks++;
  active++;
}
GlobalQueue._marked = (el) => active !== 0 && marked(el, /* @__PURE__ */ new Set());
GlobalQueue._mark = mark;
GlobalQueue._releaseMarks = release$1;
GlobalQueue._releaseAmbientMarks = (parked) => {
  if (ambient.length === 0) return;
  if (parked !== null) {
    const list2 = parked._marks ??= [];
    for (let i = 0; i < ambient.length; i++) list2.push(ambient[i]);
    ambient.length = 0;
    return;
  }
  let kept = 0;
  const done = [];
  for (let i = 0; i < ambient.length; i++) {
    const n = ambient[i];
    if (inFlight(n)) ambient[kept++] = n;
    else done.push(n);
  }
  ambient.length = kept;
  if (done.length !== 0) release$1(done);
};
function inFlight(n) {
  return (n._statusFlags & STATUS_PENDING) !== 0 || (n._config & CONFIG_SLOT_NODE) !== 0 && GlobalQueue._slotFlight?.(n) === true;
}
function flatten(children, options) {
  if (typeof children === "function" && !children.length) {
    if (options?.doNotUnwrap) return children;
    do {
      children = children();
    } while (typeof children === "function" && !children.length);
  }
  if (options?.skipNonRendered && (children == null || children === true || children === false || children === ""))
    return;
  if (Array.isArray(children)) {
    let results = [];
    if (flattenArray(children, results, options)) {
      return () => {
        let nested = [];
        flattenArray(results, nested, { ...options, doNotUnwrap: false });
        return nested;
      };
    }
    return results;
  }
  return children;
}
function flattenArray(children, results = [], options) {
  let notReady = null;
  let needsUnwrap = false;
  for (let i = 0; i < children.length; i++) {
    try {
      let child = children[i];
      if (typeof child === "function" && !child.length) {
        if (options?.doNotUnwrap) {
          results.push(child);
          needsUnwrap = true;
          continue;
        }
        do {
          child = child();
        } while (typeof child === "function" && !child.length);
      }
      if (Array.isArray(child)) {
        needsUnwrap = flattenArray(child, results, options) || needsUnwrap;
      } else if (options?.skipNonRendered && (child == null || child === true || child === false || child === "")) {
      } else results.push(child);
    } catch (e) {
      if (!(e instanceof NotReadyError)) throw e;
      notReady = e;
    }
  }
  if (notReady) throw notReady;
  return needsUnwrap;
}
var BOUNDARY = /* @__PURE__ */ Symbol("boundary");
var revealHooks = null;
function setRevealHooks(h) {
  revealHooks = h;
}
var collecting = /* @__PURE__ */ new Set();
var boundaryOf = (node) => node._context[BOUNDARY];
var isCollecting = (b) => b._type === STATUS_ERROR || !b._initialized || b._armed;
function caught(b, node, error) {
  if (b._type === STATUS_ERROR) {
    error ??= node._x?._error;
    node = error?.source ?? node;
    const caught2 = unwrapStatusError(error);
    setSignal(b._error, caught2);
    reportClientError(caught2, b._owner, node);
  }
  b._readers.add(node);
  collecting.add(b);
  if (b._armed) flip(b);
  if (!b._fallback) redraw(b);
  if (b._reveal !== null) revealHooks._changed(b._reveal);
}
function flip(b) {
  b._initialized = false;
  b._lane = b._armLane;
  if (b._lane !== null && b._output !== null)
    GlobalQueue._laneStage(b._output, b._lane, true, false);
}
function redraw(b) {
  if (b._output !== null && !(b._output._flags & (REACTIVE_DISPOSED | REACTIVE_ZOMBIE))) {
    enqueueSub(b._output);
    schedule();
  }
}
function catchStatus(node, flags, error) {
  if (flags === 0) {
    if (collecting.size !== 0) {
      for (let b = boundaryOf(node); b !== void 0; b = b._parent ?? void 0)
        if (!(node._statusFlags & unsettled(b)) && b._readers.delete(node) && b._readers.size === 0) {
          if (b._fallback) redraw(b);
          if (b._reveal !== null) revealHooks._changed(b._reveal);
        }
    }
    return false;
  }
  for (let b = boundaryOf(node); b !== void 0; b = b._parent ?? void 0) {
    if (!(b._type & flags)) continue;
    if (isCollecting(b)) {
      caught(b, node, error);
      return true;
    }
    b._readers.add(node);
    collecting.add(b);
  }
  return false;
}
function hiddenBy(r) {
  for (let b = boundaryOf(r); b !== void 0; b = b._parent ?? void 0)
    if (b._fallback) return b;
  return void 0;
}
function hidden(r) {
  return hiddenBy(r) !== void 0;
}
function heldRun(node) {
  const b = hiddenBy(node);
  if (b === void 0) return false;
  (b._runs ??= /* @__PURE__ */ new Set()).add(node);
  return true;
}
var unsettled = (b) => b._type === STATUS_ERROR ? STATUS_ERROR | STATUS_PENDING : STATUS_PENDING;
function prune(b, pass) {
  const mask = unsettled(b);
  for (const r of b._readers) {
    if (r._flags & REACTIVE_DISPOSED) b._readers.delete(r);
    else if (!(r._statusFlags & mask)) {
      if (r !== b._tree && (r._config & (CONFIG_HELD | CONFIG_OVERRIDE)) === CONFIG_HELD) {
        if (!pass || !b._initialized) continue;
        joinFuture(txOf(r));
      }
      b._readers.delete(r);
    }
  }
  return b._readers.size;
}
function boundarySeam() {
  for (const b of collecting) {
    const flags = b._output._flags;
    if (flags & REACTIVE_DISPOSED) {
      collecting.delete(b);
      continue;
    }
    if (flags & REACTIVE_ZOMBIE) continue;
    prune(b, false);
    if (b._armed && !b._initialized && !b._ahead) reportOutsideHold(b);
    b._armed = false;
    if (b._readers.size === 0) {
      collecting.delete(b);
      if (b._fallback) redraw(b);
      if (b._reveal !== null) revealHooks._changed(b._reveal);
    }
  }
}
function reportOutsideHold(b) {
  const outside = (reader, hop) => {
    if (!(reader._statusFlags & STATUS_PENDING) || reader._flags & REACTIVE_DISPOSED) return false;
    if (reader._type !== EFFECT_RENDER && boundaryOf(reader)?._tree !== reader) {
      if (hop) {
        for (let s = reader._subs; s !== null; s = s._nextSub)
          if (outside(s._sub, false)) return true;
      }
      return false;
    }
    if (hidden(reader)) return false;
    for (let o = boundaryOf(reader); o !== void 0; o = o._parent ?? void 0)
      if (o === b) return false;
    return true;
  };
  for (const r of b._readers) {
    const sources = r._x?._pendingSources;
    if (sources === void 0) continue;
    for (const source of sources) {
      for (let s = source._subs; s !== null; s = s._nextSub) {
        if (!outside(s._sub, true)) continue;
        const name = source._name;
        reportDiagnostic(
          emitDiagnostic(
            {
              code: "LOADING_ON_OUTSIDE_HOLD",
              kind: "async",
              severity: "warn",
              message: `[LOADING_ON_OUTSIDE_HOLD] \`on\` re-armed a Loading boundary, but ${name ? `\`${name}\`` : "a source it is waiting on"} is also read outside it and holds the frame: the fallback can never be seen \u2014 the frame waits on the very source the boundary is waiting on. Move the outside read under the boundary so one hold owns the data. (Reading \`latest()\` in \`on\` shows the fallback now, beside the held frame.)`,
              nodeName: name,
              data: { source: name }
            },
            b._owner
          )
        );
        return;
      }
    }
  }
}
GlobalQueue._catch = catchStatus;
GlobalQueue._fresh = (node) => node._statusFlags & STATUS_UNINITIALIZED && catchStatus(node, STATUS_PENDING);
GlobalQueue._hidden = hidden;
GlobalQueue._boundarySeam = boundarySeam;
GlobalQueue._heldRun = heldRun;
setRevealHooks({
  _register: (controller, b) => controller._register(b),
  _unregister: (controller, b) => controller._unregister(b),
  _changed: (controller) => controller._evaluate()
});
var OBSERVE2 = OBSERVE;
var DEV2 = DEV;

// ../pr3886/next/packages/solid/dist/solid.dev.js
var $DEVCOMP = /* @__PURE__ */ Symbol("COMPONENT_DEV");
function createConsoleTask(name) {
  const createTask = console.createTask;
  return typeof createTask === "function" ? createTask.call(console, name) : void 0;
}
function observedComponent(Comp, props, name) {
  if (typeof Comp !== "function") {
    throw new Error(`createComponent: expected a component function but got ${Comp === null ? "null" : typeof Comp}. A JSX tag resolved to a non-function value \u2014 check the import: a missing or misnamed export resolves to undefined.`);
  }
  name ||= Comp.name;
  const label = `<${name || "Anonymous"}>`;
  return createRoot(() => {
    const owner = getOwner();
    owner._name = label;
    {
      const record = {
        fn: Comp,
        props,
        name,
        task: OBSERVE2.attribution.installed !== null ? createConsoleTask(label) : void 0
      };
      owner._component = record;
      Object.assign(Comp, {
        [$DEVCOMP]: true
      });
      return untrack(() => Comp(props), label);
    }
  }, {
    transparent: true
  });
}
var sharedConfig = {
  hydrating: false,
  registry: void 0,
  done: false
};
var _createRoot;
var _createMemo;
var _createSignal;
var _createRenderEffect;
var createMemo2 = (...args) => {
  return (_createMemo || createMemo)(...args);
};
var createSignal2 = (...args) => {
  return (_createSignal || createSignal)(...args);
};
var createRoot2 = (...args) => (_createRoot || createRoot)(...args);
var createRenderEffect2 = (...args) => (_createRenderEffect || createRenderEffect)(...args);
function createComponent(Comp, props, name) {
  return observedComponent(Comp, props || {}, name);
}
var SKILLS_URL = "https://github.com/solidjs/solid/blob/main/packages";
function installConsoleFooter() {
  const guideUrl = DEV2.guideUrl;
  setConsoleFooter((event) => {
    const base = `[${event.code}] repair guide: node_modules/solid-js/skills/reactivity-diagnostics/SKILL.md \u2014 ${guideUrl(event.code)}`;
    return event.kind === "perf" || event.kind === "graph" || event.kind === "responsiveness" ? base + `
[${event.code}] deeper evidence: import { attribution } from "solid-js/attribution"; attribution.enable() explains every re-run \u2014 why-chains, costs(), feedback(), history("hold" | "waterfall") \u2014 agent loop: node_modules/@solidjs/diagnostics/skills/agent-loops/SKILL.md \u2014 ${SKILLS_URL}/diagnostics/skills/agent-loops/SKILL.md` : base;
  });
}
var OBSERVE3 = OBSERVE2;
var DEV3 = DEV2;
if (globalThis) {
  if (!globalThis.Solid$$) globalThis.Solid$$ = true;
  else console.warn("You appear to have multiple instances of Solid. This can lead to unexpected behavior.");
}
installConsoleFooter();

// ../pr3886/next/packages/solid/dist/internal.js
var sharedConfig2 = sharedConfig;

// ../pr3886/next/packages/web/dist/web.dev.js
var $$SLOT = /* @__PURE__ */ Symbol("slot");
var $$HOST = /* @__PURE__ */ Symbol("host");
var transparentOptions = {
  transparent: true,
  sync: true
};
var spreadName;
var bindingEffect = null;
function tagElement(node) {
  if (bindingEffect !== null && bindingEffect._devElement === void 0) bindingEffect._devElement = node;
}
function effect2(fn, effectFn, options) {
  if (spreadName !== void 0 && (options === void 0 || options.name === void 0)) options = {
    ...options,
    name: spreadName + ".spread"
  };
  const nodeOptions = options ? {
    sync: true,
    ...options,
    transparent: !options.scope
  } : transparentOptions;
  {
    let node = null;
    createRenderEffect2((prev) => {
      node = getOwner();
      return fn(prev);
    }, (value, prev) => {
      const outer = bindingEffect;
      bindingEffect = node;
      try {
        return effectFn(value, prev);
      } finally {
        bindingEffect = outer;
      }
    }, nodeOptions);
    return;
  }
}
function reconcileArrays(parentNode, a, b, marker) {
  let bLength = b.length, aEnd = a.length, bEnd = bLength, aStart = 0, bStart = 0, tail = a[aEnd - 1], tailTag = tail[$$SLOT], after = tail.parentNode === parentNode && (!tailTag || tailTag === marker) ? tail.nextSibling : marker || null, map = null, anchor, anchorTag;
  const isLive = (n) => {
    if (!n) return false;
    const tag = n[$$SLOT];
    return n.parentNode === parentNode && (!tag || tag === marker);
  };
  while (aStart < aEnd || bStart < bEnd) {
    if (a[aStart] === b[bStart] && isLive(a[aStart])) {
      aStart++;
      bStart++;
      continue;
    }
    while (a[aEnd - 1] === b[bEnd - 1] && isLive(a[aEnd - 1])) {
      aEnd--;
      bEnd--;
    }
    if (aEnd === aStart) {
      let node;
      if (bEnd < bLength) {
        if (bStart) {
          const prev = b[bStart - 1];
          const prevTag = prev[$$SLOT];
          node = prev.parentNode === parentNode && (!prevTag || prevTag === marker) ? prev.nextSibling : after;
        } else node = b[bEnd - bStart];
      } else node = after;
      while (bStart < bEnd) {
        const n = b[bStart++];
        parentNode.insertBefore(n, node);
        if (marker) n[$$SLOT] = marker;
      }
    } else if (bEnd === bStart) {
      while (aStart < aEnd) {
        const n = a[aStart++];
        if (!map || !map.has(n)) {
          const tag = n[$$SLOT];
          if (n.parentNode === parentNode && (!tag || tag === marker)) n.remove();
        }
      }
    } else if ((anchor = a[aStart]) === b[bEnd - 1] && b[bStart] === a[aEnd - 1] && anchor.parentNode === parentNode && (!(anchorTag = anchor[$$SLOT]) || anchorTag === marker)) {
      if (marker) {
        do {
          const n = a[--aEnd];
          parentNode.insertBefore(n, anchor);
          n[$$SLOT] = marker;
          bStart++;
          if (aStart >= aEnd - 1 || bStart >= bEnd) break;
        } while (a[aStart] === b[bEnd - 1] && b[bStart] === a[aEnd - 1]);
      } else {
        do {
          parentNode.insertBefore(a[--aEnd], anchor);
          bStart++;
          if (aStart >= aEnd - 1 || bStart >= bEnd) break;
        } while (a[aStart] === b[bEnd - 1] && b[bStart] === a[aEnd - 1]);
      }
    } else {
      if (!map) {
        map = /* @__PURE__ */ new Map();
        let i = bStart;
        while (i < bEnd) map.set(b[i], i++);
      }
      const index = map.get(a[aStart]);
      if (index != null) {
        if (bStart < index && index < bEnd) {
          let i = aStart, sequence = 1, t;
          while (++i < aEnd && i < bEnd) {
            if ((t = map.get(a[i])) == null || t !== index + sequence) break;
            sequence++;
          }
          if (sequence > index - bStart) {
            const head = a[aStart];
            const headTag = head[$$SLOT];
            const node = head.parentNode === parentNode && (!headTag || headTag === marker) ? head : after;
            while (bStart < index) {
              const n = b[bStart++];
              parentNode.insertBefore(n, node);
              if (marker) n[$$SLOT] = marker;
            }
          } else {
            const oldNode = a[aStart++];
            const newNode = b[bStart++];
            const oldTag = oldNode[$$SLOT];
            if (oldNode.parentNode === parentNode && (!oldTag || oldTag === marker)) {
              parentNode.replaceChild(newNode, oldNode);
            } else {
              parentNode.insertBefore(newNode, after);
            }
            if (marker) newNode[$$SLOT] = marker;
          }
        } else aStart++;
      } else {
        const n = a[aStart++];
        const nTag = n[$$SLOT];
        if (n.parentNode === parentNode && (!nTag || nTag === marker)) n.remove();
      }
    }
  }
}
function emitFinding(finding, subject = getOwner()) {
  if (OBSERVE3 === void 0) return;
  const entry = OBSERVE3.diagnostics.emit(finding, subject);
  if (DEV3 !== void 0) DEV3.report(entry);
}
function devCheck(finding, subject) {
  emitFinding(finding, subject);
}
function unscopedHoleAllocatedIds(before, after, site, subject) {
  const fn = site.name ? `\`${site.name}\`` : "a function";
  const where = site.registered !== void 0 ? `the server evaluated it at ${before} (\u2192 ${after}), after the scoped holes that follow it had reserved theirs, but it was registered at ${site.registered}, where the client builds it in place` : `the client built it in place at ${before} (\u2192 ${after}) and its content missed its server-rendered keys, because the server evaluates it after the scoped holes that follow it`;
  devCheck({
    code: "UNSCOPED_HOLE_ALLOCATED_IDS",
    kind: "render",
    severity: "warn",
    message: `[UNSCOPED_HOLE_ALLOCATED_IDS] A JSX hole received ${fn} instead of a value, and calling it built hydratable content. The hole is unscoped, so that content took ids from the enclosing scope's counter: ${where}. The hydration keys of this hole's content and of the holes after it permute between server and client. Pass the built value \u2014 call it at the hole (\`{${site.name || "render"}()}\`) or assign the result first \u2014 rather than the function; a function is not a JSX.Element, so this shape is reached only from JavaScript or through a cast.`,
    data: {
      before,
      after,
      ...site
    }
  }, subject);
}
var EVENT_KEY = "_$$";
var $$EVENT_OWNER = "_$SOLID_EVENT_OWNER";
var INNER_OWNED = {};
var delegatedEvents = /* @__PURE__ */ new Set();
var delegatedContainers = /* @__PURE__ */ new Map();
function render(code, element, init, options = {}) {
  if (!element) {
    throw new Error("The `element` passed to `render(..., element)` doesn't exist. Make sure `element` exists in the document.");
  }
  resetErrorHalt();
  enforceLoadingBoundary(true);
  let disposer;
  registerDelegatedRoot(element);
  try {
    createRoot2((dispose2) => {
      disposer = dispose2;
      if (options.onError) getOwner()[ROOT_ERROR_HOOK] = options.onError;
      if (element === document) {
        const tree = code();
        effect2(() => flatten(tree), () => {
        });
      } else {
        const tree = code();
        insert(element, () => tree, element.firstChild ? null : void 0, init, {
          ...options.insertOptions,
          schedule: true
        });
      }
    }, {
      id: options.renderId
    });
    flush();
  } catch (err) {
    if (disposer) disposer();
    unregisterDelegatedRoot(element);
    throw err;
  } finally {
    enforceLoadingBoundary(false);
  }
  return () => {
    disposer();
    unregisterDelegatedRoot(element);
    element.textContent = "";
  };
}
function create(html, bypassGuard, flag) {
  if (isHydrating() && !bypassGuard) throw new Error("Failed attempt to create new DOM elements during hydration. Check that the libraries you are using support hydration.");
  if (/^<(html|head|body)[\s>]/i.test(html)) throw new Error("Document shell templates (<html>, <head>, <body>) cannot be client-created: a <template> parse strips those tags. Render this component through hydrate(), where the document shell already exists.");
  const t = document.createElement("template");
  t.innerHTML = html;
  return flag === 2 ? t.content.firstChild.firstChild : t.content.firstChild;
}
function template(html, flag) {
  let node;
  const fn = flag === 1 ? (bypassGuard) => document.importNode(node || (node = create(html, bypassGuard, flag)), true) : (bypassGuard) => (node || (node = create(html, bypassGuard, flag))).cloneNode(true);
  fn._html = flag === 2 ? html.replace(/^<[^>]+>/, "") : html;
  return fn;
}
function delegateEvents(eventNames) {
  for (let i = 0, l = eventNames.length; i < l; i++) {
    const name = eventNames[i];
    if (!delegatedEvents.has(name)) {
      delegatedEvents.add(name);
      delegatedContainers.forEach((state, container) => attachDelegatedEvent(name, container, state));
    }
  }
}
function registerDelegatedRoot(root) {
  const state = registerDelegatedContainer(root, root);
  if (state) state.roots = (state.roots || 0) + 1;
}
function unregisterDelegatedRoot(root) {
  const state = delegatedContainers.get(root);
  if (state) state.roots > 1 ? state.roots-- : delete state.roots;
  unregisterDelegatedContainer(root, root);
}
function registerDelegatedContainer(container, owner = container) {
  if (!container || !owner) return;
  let state = delegatedContainers.get(container);
  if (!state) delegatedContainers.set(container, state = {
    owners: /* @__PURE__ */ new Map(),
    handlers: /* @__PURE__ */ new Map()
  });
  state.owners.set(owner, (state.owners.get(owner) || 0) + 1);
  delegatedEvents.forEach((name) => attachDelegatedEvent(name, container, state));
  return state;
}
function unregisterDelegatedContainer(container, owner = container) {
  const state = delegatedContainers.get(container);
  if (!state) return;
  const count = state.owners.get(owner);
  if (count > 1) state.owners.set(owner, count - 1);
  else state.owners.delete(owner);
  if (state.owners.size) return;
  state.handlers.forEach((handler, name) => container.removeEventListener(name, handler));
  delegatedContainers.delete(container);
}
function attachDelegatedEvent(name, container, state) {
  if (state.handlers.has(name)) return;
  const handler = (e) => dispatchAsInteraction(e, () => eventHandler(e, container, state));
  state.handlers.set(name, handler);
  container.addEventListener(name, handler);
}
function describeEventTarget(target) {
  if (!target || typeof target.tagName !== "string") return void 0;
  const tag = target.tagName.toLowerCase();
  let out = tag;
  if (target.id) out += `#${target.id}`;
  else if (typeof target.name === "string" && target.name) out += `[name=${target.name}]`;
  if (tag !== "input" && tag !== "textarea" && tag !== "select") {
    const text = (target.textContent || "").trim().replace(/\s+/g, " ");
    if (text) out += ` "${text.length > 30 ? text.slice(0, 29) + "\u2026" : text}"`;
  }
  return out;
}
function interactionStart(e) {
  const at = e.timeStamp;
  return typeof at === "number" && at >= 0 && at <= performance.now() ? at : void 0;
}
function dispatchAsInteraction(e, fn) {
  return OBSERVE3.attribution.withInteraction({
    type: e.type,
    target: describeEventTarget(e.target),
    at: interactionStart(e),
    event: e
  }, fn);
}
function findOwner(target, state) {
  let node = target;
  let distance = 0;
  while (node) {
    if (state.owners.has(node)) return {
      owner: node,
      distance
    };
    distance++;
    node = node._$host || node.parentNode || node.host;
  }
}
var SCOPE_OPTIONS = {
  scope: true
};
var unscopedByDesign = null;
var reportedHoleSites = null;
var hydrationKeyMisses = 0;
function unscopedHoleSnapshot(accessor2, parent) {
  if (accessor2.$s || !sharedConfig2.hydrating || parent === unscopedByDesign || sharedConfig2.devPeekNextContextId === void 0) return void 0;
  return {
    next: sharedConfig2.devPeekNextContextId(),
    misses: hydrationKeyMisses
  };
}
function checkUnscopedHole(snapshot2, accessor2, parent) {
  if (snapshot2 === void 0 || hydrationKeyMisses === snapshot2.misses) return;
  const after = sharedConfig2.devPeekNextContextId();
  if (after === snapshot2.next) return;
  let site = parent.nodeName + "|" + accessor2.name;
  for (let o = getOwner(); o !== null; o = o._parent) if (o._name) site = o._name + "|" + site;
  if ((reportedHoleSites || (reportedHoleSites = /* @__PURE__ */ new Set())).has(site)) return;
  reportedHoleSites.add(site);
  unscopedHoleAllocatedIds(snapshot2.next, after, accessor2.name ? {
    name: accessor2.name
  } : {});
}
var hydrationRt = null;
function insert(parent, accessor2, marker, initial, options) {
  if (spreadName !== void 0 && (options === void 0 || options.name === void 0)) options = {
    ...options,
    name: spreadName + ".children"
  };
  const multi = marker !== void 0;
  const host = options && options.host;
  if (multi && !initial) initial = [];
  if (hydrationRt !== null) initial = hydrationRt.claimInitial(parent, multi, initial);
  if (typeof accessor2 !== "function") {
    accessor2 = normalize(accessor2, initial, multi, true);
    if (typeof accessor2 !== "function") {
      insertExpression(parent, accessor2, initial, marker);
      host && tagHost(accessor2, host);
      return;
    }
  }
  if (multi && initial.length === 0) {
    const placeholder = document.createTextNode("");
    parent.insertBefore(placeholder, marker);
    initial = [placeholder];
  }
  let current = initial;
  effect2(
    (prev) => {
      if (hydrationRt !== null) current = hydrationRt.reclaimRegion(current, parent, marker);
      const devNext = unscopedHoleSnapshot(accessor2, parent);
      const value = normalize(accessor2(), current, multi, true);
      checkUnscopedHole(devNext, accessor2, parent);
      if (typeof value !== "function") return value;
      const innerOptions = prev !== void 0 && !(options && options.schedule) ? {
        ...options,
        schedule: true
      } : options;
      effect2(() => (hydrationRt !== null && (current = hydrationRt.reclaimRegion(current, parent, marker)), normalize(value, current, multi)), (inner) => {
        current = insertExpression(parent, inner, current, marker);
        host && tagHost(current, host);
      }, {
        ...innerOptions,
        _wide: true
      });
      checkUnscopedHole(devNext, accessor2, parent);
      return INNER_OWNED;
    },
    (value) => {
      if (value === INNER_OWNED) return;
      current = insertExpression(parent, value, current, marker);
      host && tagHost(current, host);
    },
    accessor2.$s ? options ? {
      ...options,
      scope: true
    } : SCOPE_OPTIONS : options
  );
}
function isHydrating(node) {
  if (!sharedConfig2.hydrating) return false;
  if (sharedConfig2.isClaiming && !sharedConfig2.isClaiming()) return false;
  if (!node || node.isConnected) return true;
  return serverComponentClaims !== null && serverComponentClaims.claimed(node);
}
var serverComponentClaims = null;
function eventHandler(e, container, state) {
  if (hydrationRt !== null && hydrationRt.dedupEvent(e)) return;
  const prev = e[$$EVENT_OWNER];
  let resumeNode;
  if (prev) {
    if (prev === true || prev === container || !container.contains(prev)) return;
    resumeNode = prev;
  }
  const owner = state && (state.owners.size === 1 && state.owners.has(container) ? container : findOwner(e.target, state)?.owner);
  if (state && !owner) return;
  if (owner && owner === resumeNode) return;
  e[$$EVENT_OWNER] = owner || true;
  let node = resumeNode || e.target;
  const key = EVENT_KEY + e.type;
  const oriTarget = e.target;
  const boundary = owner || container || e.currentTarget;
  const retarget = (value) => Object.defineProperty(e, "target", {
    configurable: true,
    value
  });
  const handleNode = () => {
    const handler = node[key];
    if (handler && !node.disabled) {
      const data = node[`${key}Data`];
      data !== void 0 ? handler.call(node, data, e) : typeof handler === "function" ? handler.call(node, e) : handler.handleEvent(e);
      if (e.cancelBubble) return;
    }
    node.host && typeof node.host !== "string" && !node.host._$host && node.contains(e.target) && retarget(node.host);
    return true;
  };
  const walkUpTree = () => {
    while (node && handleNode()) {
      if (node === boundary || node.parentNode === boundary) break;
      node = node._$host || node.parentNode || node.host;
    }
  };
  Object.defineProperty(e, "currentTarget", {
    configurable: true,
    get() {
      return node || boundary || document;
    }
  });
  if (resumeNode) {
    if (resumeNode === e.target) node = resumeNode._$host || resumeNode.parentNode || resumeNode.host;
    if (node && node !== boundary) walkUpTree();
  } else if (e.composedPath) {
    const path = e.composedPath();
    if (path.length) {
      retarget(path[0]);
      for (let i = 0; i < path.length; i++) {
        node = path[i];
        if (!handleNode()) break;
        if (node._$host) {
          node = node._$host;
          walkUpTree();
          break;
        }
        if (node === boundary || node.parentNode === boundary) {
          break;
        }
      }
    } else walkUpTree();
  } else walkUpTree();
  retarget(oriTarget);
}
function insertExpression(parent, value, current, marker) {
  tagElement(parent);
  if (hydrationRt !== null && isHydrating(parent)) {
    if (value && value !== current) {
      const arr = Array.isArray(value);
      for (const n of arr ? value : [value]) {
        if (n && n.nodeType) {
          if (!isHydrating(n)) return current;
        } else if (arr && (typeof n === "string" || typeof n === "number")) {
          return current;
        }
      }
    }
    return value;
  }
  if (value === current) return value;
  if (hydrationRt !== null && sharedConfig2.hydrating && current == null && value && [].concat(value).every((n) => n?.parentNode === parent) && value.length !== 0) return value;
  const t = typeof value, multi = marker !== void 0;
  if (t === "string" || t === "number") {
    const tc = typeof current;
    if (tc === "string" || tc === "number") {
      parent.firstChild.data = value;
    } else {
      if (ownsAllChildren(parent, current)) parent.textContent = value;
      else {
        removeOwnedChildren(parent, current);
        parent.insertBefore(document.createTextNode(value), parent.firstChild);
      }
    }
  } else if (value === void 0) {
    cleanChildren(parent, current, marker);
  } else if (value.nodeType) {
    if (Array.isArray(current)) {
      cleanChildren(parent, current, multi ? marker : null, value);
    } else if (current != null && current.nodeType) {
      current.parentNode === parent ? parent.replaceChild(value, current) : parent.appendChild(value);
    } else if (current != null && parent.firstChild) {
      parent.replaceChild(value, parent.firstChild);
    } else {
      parent.appendChild(value);
    }
    if (marker) value[$$SLOT] = marker;
  } else if (Array.isArray(value)) {
    const currentArray = Array.isArray(current);
    for (let i = 0, len = value.length; i < len; i++) {
      const item = value[i], t2 = typeof item;
      if (t2 === "string" || t2 === "number") {
        const prev = currentArray ? current[i] : void 0;
        if (prev && prev.nodeType === 3) {
          if (prev.data !== "" + item) prev.data = item;
          value[i] = prev;
        } else value[i] = document.createTextNode(item);
      }
    }
    if (value.length === 0) {
      cleanChildren(parent, current, marker);
    } else if (currentArray) {
      if (current.length === 0) {
        appendNodes(parent, value, marker);
      } else reconcileArrays(parent, current, value, marker);
    } else {
      if (current != null) cleanChildren(parent, current);
      appendNodes(parent, value);
    }
  } else devCheck({
    code: "UNRECOGNIZED_INSERT_VALUE",
    kind: "render",
    severity: "warn",
    message: `[UNRECOGNIZED_INSERT_VALUE] Unrecognized value. Skipped inserting (${typeof value}).`,
    data: {
      type: typeof value,
      value
    }
  });
  selectInsert && selectInsert(parent);
  return value;
}
var selectInsert;
function normalize(value, current, multi, doNotUnwrap) {
  value = flatten(value, {
    skipNonRendered: true,
    doNotUnwrap
  });
  if (doNotUnwrap && typeof value === "function") return value;
  if (multi && !Array.isArray(value)) value = [value != null ? value : ""];
  if (sharedConfig2.hydrating && Array.isArray(value)) {
    for (let i = 0, len = value.length; i < len; i++) {
      const item = value[i], prev = current && current[i], t = typeof item;
      if ((t === "string" || t === "number") && prev && prev.nodeType === 3 && isHydrating(prev)) value[i] = prev;
    }
  }
  return value;
}
function tagHost(value, host) {
  if (Array.isArray(value)) {
    for (let i = 0, len = value.length; i < len; i++) tagHost(value[i], host);
  } else if (value && value.nodeType && value[$$HOST] !== host) {
    value[$$HOST] = host;
    Object.defineProperty(value, "_$host", {
      get: host,
      configurable: true
    });
  }
}
function appendNodes(parent, array, marker = null) {
  for (let i = 0, len = array.length; i < len; i++) {
    const n = array[i];
    parent.insertBefore(n, marker);
    if (marker) n[$$SLOT] = marker;
  }
}
function ownsAllChildren(parent, current) {
  if (current == null) return true;
  if (Array.isArray(current)) {
    return current.length ? parent.firstChild === current[0] && parent.lastChild === current[current.length - 1] : parent.firstChild === null;
  }
  if (current === "") return parent.firstChild === null;
  if (current.nodeType) return parent.firstChild === current && parent.lastChild === current;
  const first = parent.firstChild;
  return first !== null && first.nodeType === 3 && parent.lastChild === first;
}
function removeOwnedChildren(parent, current) {
  if (Array.isArray(current)) {
    for (let i = 0; i < current.length; i++) {
      const el = current[i];
      if (el.parentNode === parent) el.remove();
    }
  } else if (current.nodeType) {
    if (current.parentNode === parent) current.remove();
  } else {
    const first = parent.firstChild;
    if (first && first.nodeType === 3) first.remove();
  }
}
function cleanChildren(parent, current, marker, replacement) {
  if (marker === void 0) {
    if (ownsAllChildren(parent, current)) return parent.textContent = "";
    return removeOwnedChildren(parent, current);
  }
  if (current.length) {
    let inserted = false;
    for (let i = current.length - 1; i >= 0; i--) {
      const el = current[i];
      if (replacement !== el) {
        const tag = el[$$SLOT];
        const owns = el.parentNode === parent && (!tag || tag === marker);
        if (replacement && !inserted && !i) owns ? parent.replaceChild(replacement, el) : parent.insertBefore(replacement, marker);
        else if (owns) el.remove();
      } else inserted = true;
    }
  } else if (replacement) parent.insertBefore(replacement, marker);
  if (replacement && marker) replacement[$$SLOT] = marker;
}

// ../pr3886/next/App.tsx
var _tmpl$ = /* @__PURE__ */ template(`<section id=id-first><h2>Read id first</h2><button>Load item 1</button><p>ID: <output data-value=id></output></p><p>Data: <output data-value=data></output></p><p>Pending: <output data-value=pending>`);
var _tmpl$2 = /* @__PURE__ */ template(`<section id=pending-first><h2>Read pending first</h2><button>Load item 1</button><p>ID: <output data-value=id></output></p><p>Data: <output data-value=data></output></p><p>Pending: <output data-value=pending>`);
var _tmpl$3 = /* @__PURE__ */ template(`<main style=font-family:sans-serif;padding:24px><h1>isPending: read order changes publication</h1><p>Try each button separately. Each request takes three seconds. Reload to reset.</p><p>The two memos differ only in the order of id() and isPending(id).</p><div style=display:flex;gap:64px;flex-wrap:wrap><!><!>`);
async function load(id) {
  await new Promise((resolve2) => setTimeout(resolve2, 3e3));
  return id * 10;
}
function IdFirst() {
  const [id, setId] = createSignal2(0);
  const data = createMemo2(() => {
    const value = id();
    isPending(id);
    return value === 0 ? 0 : load(value);
  });
  var _el$ = _tmpl$(), _el$2 = _el$.firstChild, _el$3 = _el$2.nextSibling, _el$4 = _el$3.nextSibling, _el$5 = _el$4.firstChild, _el$6 = _el$5.nextSibling, _el$7 = _el$4.nextSibling, _el$8 = _el$7.firstChild, _el$9 = _el$8.nextSibling, _el$0 = _el$7.nextSibling, _el$1 = _el$0.firstChild, _el$10 = _el$1.nextSibling;
  _el$3._$$click = () => setId(1);
  insert(_el$6, id);
  insert(_el$9, data);
  insert(_el$10, () => String(isPending(id)));
  return _el$;
}
function PendingFirst() {
  const [id, setId] = createSignal2(0);
  const data = createMemo2(() => {
    isPending(id);
    const value = id();
    return value === 0 ? 0 : load(value);
  });
  var _el$11 = _tmpl$2(), _el$12 = _el$11.firstChild, _el$13 = _el$12.nextSibling, _el$14 = _el$13.nextSibling, _el$15 = _el$14.firstChild, _el$16 = _el$15.nextSibling, _el$17 = _el$14.nextSibling, _el$18 = _el$17.firstChild, _el$19 = _el$18.nextSibling, _el$20 = _el$17.nextSibling, _el$21 = _el$20.firstChild, _el$22 = _el$21.nextSibling;
  _el$13._$$click = () => setId(1);
  insert(_el$16, id);
  insert(_el$19, data);
  insert(_el$22, () => String(isPending(id)));
  return _el$11;
}
function App() {
  var _el$23 = _tmpl$3(), _el$24 = _el$23.firstChild, _el$25 = _el$24.nextSibling, _el$26 = _el$25.nextSibling, _el$27 = _el$26.nextSibling, _el$28 = _el$27.firstChild, _el$29 = _el$28.nextSibling;
  insert(_el$27, createComponent(IdFirst, {}), _el$28);
  insert(_el$27, createComponent(PendingFirst, {}), _el$29);
  return _el$23;
}
render(() => createComponent(App, {}), document.getElementById("root"));
delegateEvents(["click"]);
export {
  App as default
};
