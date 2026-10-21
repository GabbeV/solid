"""Generate Bend's explicit record projections/rebuilders. No runtime logic."""
from pathlib import Path
root=Path(__file__).resolve().parents[1]
schemas={
'AsyncObject': [('immediate','Bool'),('state','AsyncSettlement'),('observers','List<&2, Nat>'),('stream','Nat')],
'AsyncObserver': [('node','Nat'),('result','Nat'),('isSync','Bool'),('resolved','Bool'),('rejected','Bool'),('syncValue','Value'),('syncError','Value'),('stream','Nat')],
'Awaiter': [('expr','Expr'),('refresh','Bool'),('target','Nat'),('own','Nat'),('root','Nat'),('node','Nat'),('state','AsyncSettlement'),('until','Bool'),('confirmation','Nat'),('timer','Bool'),('onAbort','Bool'),('signal','Nat')],
'AbortInput': [('aborted','Bool'),('reason','Value')],
'StreamPlan': [('steps','List<&2, NextInput>'),('hasReturn','Bool'),('returnError','Slot'),('returnResult','Nat')],
'ExternalIterator': [('plan','Nat'),('cursor','Nat'),('returns','Nat')],
'StreamState': [('node','Nat'),('result','Nat'),('iterator','Nat'),('hadValue','Bool'),('completed','Bool'),('initialRead','Bool'),('syncValue','Value'),('close','Nat')],
'Transaction': [('nodes','List<&2, Nat>'),('renderQueue','List<&2, Nat>'),('userQueue','List<&2, QueueEntry>'),('reruns','List<&2, Nat>'),('into','Nat'),('parent','Nat'),('lane','Bool'),('verdict','Nat'),('open','Nat'),('acted','Bool'),('links','Nat'),('shown','Bool'),('held','Bool'),('marks','OptionalIds')],
'ReactionState': [('owner','Nat'),('arm','Nat'),('cleanup','Value'),('body','Expr'),('errorProgram','Nat'),('options','NodeOptions'),('scheduled','Bool'),('track','Nat')],
'ComparatorBinding': [('node','Nat'),('callback','Nat')],
'ContextKey': [('defaultValue','Value'),('description','Slot')],
'ContextEntry': [('key','Nat'),('value','Value')],
'ContextRecord': [('entries','List<&2, ContextEntry>')],
'CleanupProgram': [('actions','List<&2, CleanupAction>'),('returnsCleanup','Bool')],
'EffectSpec': [('user','Bool'),('target','Nat'),('options','NodeOptions'),('scheduled','Bool'),('deferred','Bool'),('program','Nat'),('returnedCleanup','Nat'),('errorProgram','Nat'),('body','InlineBody')],
'NodeOptions': [('equals','Bool'),('transparent','Bool'),('ownedWrite','Bool'),('lazy','Bool'),('sync','Bool'),('noSnapshot','Bool'),('extraConfig','U32'),('loading','Slot'),('unobserved','Nat'),('comparator','Nat')],
'NodeExtension': [('inFlight','Nat'),('flightTeardown','Nat'),('error','Value'),('blocked','Slot'),('pendingSources','Nat'),('unobserved','Nat'),('snapshotValue','Snapshot'),('pendingFirstChild','Nat'),('pendingDisposal','Disposal'),('transaction','Nat'),('reask','Bool'),('flushed','Slot'),('flushedAt','Stamp'),('q','Question'),('lane','Slot'),('marks','Nat'),('shownError','Value')],
'Node': [('kind','NodeKind'),('value','Value'),('pending','Slot'),('equals','Bool'),('config','U32'),('flags','U32'),('status','U32'),('time','Nat'),('notified','Stamp'),('deps','Nat'),('depsTail','Nat'),('depGen','Nat'),('subs','Nat'),('subsTail','Nat'),('height','Nat'),('nextHeap','Nat'),('prevHeap','Nat'),('parent','Nat'),('firstChild','Nat'),('nextSibling','Nat'),('prevSibling','Nat'),('expr','Expr'),('modified','Bool'),('prevValue','Value'),('target','Nat'),('loading','Bool'),('x','Nat'),('parentComputed','Nat'),('scope','Nat'),('childCount','Nat'),('disposal','Disposal'),('cleanup','Nat'),('effectProgram','Nat'),('returnedCleanup','Nat'),('errorProgram','Nat')],
'Link': [('dep','Nat'),('sub','Nat'),('nextDep','Nat'),('prevSub','Nat'),('nextSub','Nat'),('gen','Nat')],
'TreeNode': [('parent','Nat'),('children','List<&2, Nat>'),('text','Value')],
'World': [('nodes','List<&2, Node>'),('links','List<&2, Link>'),('buckets','List<&2, Nat>'),('minimum','Nat'),('maximum','Nat'),('marked','Bool'),('pendingNodes','List<&2, Nat>'),('trims','List<&2, Nat>'),('renderQueue','List<&2, Nat>'),('userQueue','List<&2, QueueEntry>'),('context','Nat'),('tracking','Bool'),('running','Bool'),('scheduled','Bool'),('clock','Nat'),('epoch','Nat'),('tree','List<&2, TreeNode>'),('events','List<&2, TraceEvent>'),('fault','Fault'),('unflushedStaged','Bool'),('promotedWrites','List<&2, Nat>'),('extensions','List<&2, NodeExtension>'),('cleanupPrograms','List<&2, CleanupProgram>'),('dormantNodes','List<&2, Nat>'),('errorSerial','Nat'),('halted','Bool'),('haltNotified','Bool'),('reports','List<&2, Report>'),('callbackEffect','Nat'),('txArena','List<&2, Transaction>'),('transactions','List<&2, Nat>'),('flushTransaction','Nat'),('passTx','Nat'),('passLane','Nat'),('judge','Nat'),('deferredZombies','List<&2, Nat>'),('question','Question'),('pendingSets','List<&2, List<&2, Nat>>'),('asyncObjects','List<&2, AsyncObject>'),('asyncObservers','List<&2, AsyncObserver>'),('hostJobs','List<&2, HostJob>'),('syncDepth','Nat'),('streamPlans','List<&2, StreamPlan>'),('iterators','List<&2, ExternalIterator>'),('streams','List<&2, StreamState>'),('iteratorEvents','List<&2, IteratorEvent>'),('awaiters','List<&2, Awaiter>'),('truthReadHook','Bool'),('truthConfirmedHook','Bool'),('questions','Question'),('abortInputs','List<&2, AbortInput>'),('contextKeys','List<&2, ContextKey>'),('contextRecords','List<&2, ContextRecord>'),('deferredReleases','Nat'),('releaseLists','List<&2, List<&2, Nat>>'),('stale','Bool'),('settledCallbacks','List<&2, Expr>'),('reactions','List<&2, ReactionState>'),('comparators','List<&2, ComparatorBinding>')]
}
header='''# Generated by tools/records.py; edit the schema, not the rebuilders.
import Base

type Value is Data:
  Undefined{}
  Null{}
  Boolean{b: Bool}
  Number{n: Nat}
  Reference{id: Nat}
  OwnerReference{id: Nat}
  RootDisposerReference{owner: Nat}
  AccessorReference{signal: Nat}
  SetterReference{signal: Nat}
  ProgramReference{callback: Nat}
  ContextFailure{identity: Nat, kind: U32}
  NotANumber{}
  StringValue{s: String}
  StatusFailure{identity: Nat, source: Nat, cause: Value, message: String}
  NotReadyFailure{identity: Nat, source: Nat}
  NotPendingToken{}
  AsyncValue{identity: Nat}
  StepResult{done: Bool, value: Value}
  StreamVerdict{stream: Nat, landed: Bool, value: Value}
  TimeoutFailure{identity: Nat}
  ExternalError{id: Nat, explicit: Bool, kind: U32, name: String, message: String, native: Bool, code: Nat}

# Typed external iterator method inputs, not engine decisions.
type Question is Data:
  QuestionZero{}
  QuestionOdd{half: Question}
  QuestionEven{half: Question}

type NextInput is Data:
  BareNext{done: Bool, value: Value}
  PromiseNext{result: Nat}
  ThrowNext{error: Value}

type IteratorEvent is Data:
  IteratorStarted{object: Nat, iterator: Nat}
  IteratorNext{iterator: Nat, index: Nat}
  IteratorReturned{iterator: Nat}

type AsyncSettlement is Data:
  Unresolved{}
  Fulfilled{value: Value}
  Rejected{error: Value}

# These are external delivery/queueMicrotask requests, not reactive decisions.
type HostJob is Data:
  FlushJob{}
  DeliveryJob{observer: Nat, rejected: Bool, value: Value}
  WatchStart{awaiter: Nat}
  WatchDelivery{awaiter: Nat, rejected: Bool, value: Value}
  PromiseOutcome{awaiter: Nat, rejected: Bool, value: Value}
  StartTimeout{awaiter: Nat, delay: Nat}
  CancelTimeout{awaiter: Nat}
  ListenAbort{awaiter: Nat, signal: Nat}
  UnlistenAbort{awaiter: Nat, signal: Nat}

type Slot is Data:
  Empty{}
  Present{value: Value}

# -1 stamps and NOT_PENDING are distinct from every valid clock/value.
type Stamp is Data:
  Unstamped{}
  Stamped{value: Nat}

type OptionalIds is Data:
  NoIds{}
  SomeIds{items: List<&2, Nat>}

type SourceSet is Data:
  NoSources{}
  Sources{items: List<&2, Nat>}

type Disposal is Data:
  NoDisposal{}
  OneDisposal{callback: Nat}
  ManyDisposals{callbacks: List<&2, Nat>}

type Snapshot is Data:
  NoSnapshotValue{}
  UndefinedSnapshot{}
  SnapshotValue{value: Value}

type QueueEntry is Data:
  NodeRun{node: Nat}
  SettledFire{callback: Nat}

type NodeKind is Data:
  Invalid{}
  Signal{}
  Memo{}
  Render{}
  User{}
  Root{}
  Tracked{}

type InlineBody is Data:
  NoInlineBody{}
  SomeInlineBody{expr: Expr, returnsCleanup: Bool}

type Expr is Data:
  Literal{value: Value}
  Read{id: Nat}
  Previous{}
  Add{left: Expr, right: Expr}
  Multiply{left: Expr, right: Expr}
  Same{left: Expr, right: Expr}
  Select{condition: Expr, yes: Expr, no: Expr}
  Untracked{body: Expr}
  FlushCallback{body: Expr}
  FlushValue{callee: Expr}
  FlushNow{}
  WithOwner{owner: Expr, body: Expr}
  CurrentOwner{}
  CurrentObserver{}
  OwnerDisposed{owner: Expr}
  SignalScope{initial: Expr, options: NodeOptions, body: Expr}
  SignalComputeScope{compute: Expr, options: NodeOptions, body: Expr}
  LocalRead{depth: Nat}
  LocalAccessor{depth: Nat}
  LocalSetter{depth: Nat}
  LocalWrite{depth: Nat, value: Expr, updater: Bool}
  WriteExpr{signal: Nat, value: Expr, updater: Bool}
  MemoRead{compute: Expr, options: NodeOptions}
  MemoAccessor{compute: Expr, options: NodeOptions}
  EffectCreate{compute: Expr, spec: EffectSpec}
  ReactionCreate{body: Expr, errorProgram: Nat, options: NodeOptions, scheduled: Bool}
  ReactionArm{callee: Expr, tracking: Expr}
  ReactionTracking{reaction: Nat, body: Expr}
  ReactionFire{reaction: Nat, node: Expr}
  OnSettled{body: Expr}
  TrackedCreate{body: Expr}
  TrackedBody{body: Expr}
  RootScope{body: Expr, transparent: Bool}
  DisposeRoot{owner: Expr}
  ContextGet{key: Nat, owner: Expr}
  ContextSet{key: Nat, value: Expr, owner: Expr}
  Raise{cause: Value}
  CallProgram{callback: Nat}
  CallWith{callback: Nat, first: Expr, second: Expr}
  Argument{index: Nat}
  Invoke{callee: Expr}
  InvokeWith{callee: Expr, value: Expr, updater: Bool}
  InvokeArguments{callee: Expr, first: Expr, second: Expr}
  OnCleanup{callee: Expr}
  WatchExpr{awaiter: Nat, expr: Expr}
  Then{first: Expr, second: Expr}

# Defunctionalized cleanup callbacks. The program identity is the callable's
# identity; Dispose/Register actions are explicit source API calls.
type CleanupAction is Data:
  CleanupEmit{code: Nat}
  CleanupDispose{owner: Nat}
  CleanupRegister{owner: Nat, callback: Nat}
  CleanupThrow{cause: Value}
  CleanupWrite{signal: Nat, value: Value}
  CleanupRegisterCurrent{callback: Nat}
  CleanupDisposeCurrent{}
  CleanupPriorEffect{}
  CleanupCloseIterator{stream: Nat}
  CleanupBoundRoot{owner: Nat}
  CleanupBoundSetter{signal: Nat}
  CleanupBoundAccessor{signal: Nat}
  CleanupBoundProgram{callback: Nat}
  ReactionTrack{reaction: Nat}
  ReactionLifecycle{reaction: Nat}
  CallbackEvaluate{expr: Expr}
  CallbackReturn{expr: Expr}
  CallbackWrite{signal: Nat, expr: Expr}
  CallbackUpdate{signal: Nat, expr: Expr}
  CallbackThrow{expr: Expr}

type Fault is Data:
  Healthy{}
  Exhausted{}
  BadId{}
  Unsupported{reason: Nat}
  TypeError{}
  CallbackThrown{cause: Value}

type Report is Data:
  RuntimeReport{kind: U32, cause: Slot}

type TraceEvent is Data:
  Constructed{created: Nat}
  SetterBound{boundSetter: Nat}
  AccessorBound{boundAccessor: Nat}
  Invoked{id: Nat}
  ReadValue{reader: Nat, source: Nat, value: Value}
  Applied{id: Nat, value: Value, previous: Value}
  Wrote{id: Nat, value: Value}
  Disposed{id: Nat}
  CleanupObserved{callback: Nat, code: Nat}

'''
out=header
for name,fields in schemas.items():
    out+=f'type {name} is Data:\n  {name}'+'{'+', '.join(f'{n}: {t}' for n,t in fields)+'}\n\n'
    args=', '.join(n for n,_ in fields)
    for n,t in fields:
        out+=f'def {name}.{n}(r: {name}) -> {t}:\n  match r:\n    case {name}'+'{'+args+'}:\n      '+n+'\n\n'
        out+=f'def {name}.with_{n}(r: {name}, v: {t}) -> {name}:\n  match r:\n    case {name}'+'{'+args+'}:\n      '+name+'{'+', '.join('v' if k==n else k for k,_ in fields)+'}\n\n'
out=out.rstrip()+'\n'
target=root/'representation/records.bend'
import sys
if '--check' in sys.argv:
    if target.read_text()!=out: raise SystemExit('Generated record helpers are stale')
else:
    target.write_text(out)
