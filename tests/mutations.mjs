import fs from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
const root=fileURLToPath(new URL('../',import.meta.url));
const mutations=[
  ['returned cleanup assignment is discarded','runtime/core.bend','installReturned(w, rest, stack, id)','Machine{w, rest, stack}','tests/returned-cleanup.mjs'],
  ['returned setter cleanup binds wrong target','runtime/core.bend','+pair = J.encodeSetter(w, signal)','+pair = J.encodeSetter(w, id)','tests/returned-cleanup.mjs'],
  ['setter cleanup uses the ambient owner as its target','runtime/owner.bend','Machine{clearSetter(w, signal), rest}','Machine{clearSetter(w, R.World.context(w)), rest}','tests/setter-cleanup.mjs'],
  ['setter cleanup receives a value instead of no arguments','runtime/owner.bend','W.setSignal(w, signal, R.Undefined{})','W.setSignal(w, signal, R.Number{99n})','tests/setter-cleanup.mjs'],
  ['setter cleanup loses its returned function identity','runtime/core.bend','Machine{J.cleanupSetter(w, R.World.context(w), signal), rest, R.SetterReference{signal} <> tail}','Machine{J.cleanupSetter(w, R.World.context(w), signal), rest, R.Undefined{} <> tail}','tests/setter-cleanup.mjs'],
  ['same setter cleanup receives distinct callback identities','runtime/callable.bend','+old = findSetter(R.World.cleanupPrograms(w), signal, 0n)','+old = {0n : Nat}','tests/setter-cleanup.mjs'],
  ['writable initializer fails to shadow its body binding','runtime/lexical.bend','R.SignalComputeScope{bind(compute, depth, signal), options, bind(body, 1n+depth, signal)}','R.SignalComputeScope{bind(compute, depth, signal), options, bind(body, depth, signal)}','tests/writable-signals.mjs'],
  ['writable initializer retains auto-dispose','runtime/core.bend','B.clear(R.Node.config(B.node(w, signal)), K.CONFIG_AUTO_DISPOSE())','R.Node.config(B.node(w, signal))','tests/writable-signals.mjs'],
  ['held writable updater sees staging instead of its committed frame','runtime/core.bend','Evaluate{expr, R.Node.value(B.node(w, id))} <> SetMemoForward','Evaluate{expr, B.current(B.node(w, id))} <> SetMemoForward','tests/writable-signals.mjs'],
  ['unregistered held-function result workaround','runtime/core.bend','Machine{w, SetSignalArgument{signal} <> SetMemoAfter{signal, held} <> rest, stack}','Machine{w, SetSignalResolved{signal, B.current(B.node(w, signal))} <> SetMemoAfter{signal, held} <> rest, stack}','tests/writable-signals.mjs'],
  ['memo write drops its manual proposal flag','runtime/memo-write.bend','B.set(R.Node.flags(B.node(w, id)), K.REACTIVE_MANUAL_WRITE())','R.Node.flags(B.node(w, id))','tests/writable-signals.mjs'],
  ['held memo write omits rederivation heap insertion','runtime/memo-write.bend','B.schedule(H.insertIntoHeap(w, id))','B.schedule(w)','tests/writable-signals.mjs'],
  ['setter comparator reloads a reentrant slot','runtime/write.bend','B.equal(currentValue, value)','B.equal(B.current(n), value)','tests/setters.mjs'],
  ['escaped setter binds the wrong node','runtime/callable.bend','R.SetterReference{node}','R.SetterReference{1n}','tests/setters.mjs'],
  ['writable-memo setter selects plain setter policy','runtime/core.bend','_ => SetMemoArgument{id}, _ => SetSignalArgument{id}','_ => SetSignalArgument{id}, _ => SetSignalArgument{id}','tests/writable-signals.mjs'],
  ['setter raw argument discards its effects','runtime/core.bend','Evaluate{value, previous} <> InvokeApplied{callee}','Evaluate{R.Literal{R.Undefined{}}, previous} <> InvokeApplied{callee}','tests/setters.mjs'],
  ['computed accessor disables lazy creation','runtime/core.bend','memoExpression(w, rest, stack, compute, options, False{})','memoExpression(w, rest, stack, compute, R.NodeOptions.with_lazy(options, False{}), False{})','tests/computed-accessors.mjs'],
  ['computed accessor drops captured parameters','runtime/callback.bend','R.MemoAccessor{bind(compute, first, second), options}','R.MemoAccessor{compute, options}','tests/computed-accessors.mjs'],
  ['escaped accessor binds outer signal incorrectly','runtime/lexical.bend','_ => R.Literal{Callable.accessor(signal)}, _ => R.LocalAccessor{index}','_ => R.Literal{R.AccessorReference{1n}}, _ => R.LocalAccessor{index}','tests/locals.mjs'],
  ['escaped accessor invocation drops tracking','runtime/core.bend','Machine{w, ReadNode{id} <> rest, tail}','Machine{R.World.with_tracking(w, False{}), ReadNode{id} <> rest, tail}','tests/locals.mjs'],
  ['accessor updater result is invoked again','runtime/core.bend','Machine{W.setResolved(w, signal, current, value), rest, value <> tail}','match value:\n            case R.AccessorReference{id}:\n              Machine{w, ReadNode{id} <> SetSignalResolved{signal, current} <> rest, tail}\n            case other:\n              Machine{W.setResolved(w, signal, current, other), rest, other <> tail}','tests/locals.mjs'],
  ['raw accessor updater stored without invocation','runtime/core.bend','Machine{w, ReadNode{id} <> SetSignalResolved{signal, current} <> rest, tail}','Machine{w, SetSignalResolved{signal, current} <> rest, R.AccessorReference{id} <> tail}','tests/locals.mjs'],

  ['local reads bind the wrong signal','runtime/lexical.bend','_ => R.Read{signal}, _ => R.LocalRead{index}','_ => R.Read{1n}, _ => R.LocalRead{index}','tests/locals.mjs'],
  ['inner signal scope fails to shadow','runtime/lexical.bend','R.SignalScope{bind(initial, depth, signal), options, bind(body, 1n+depth, signal)}','R.SignalScope{bind(initial, depth, signal), options, bind(body, depth, signal)}','tests/locals.mjs'],
  ['inline body drops captured local','runtime/lexical.bend','R.SomeInlineBody{bind(expr, depth, signal), returnsCleanup}','R.SomeInlineBody{expr, returnsCleanup}','tests/locals.mjs'],
  ['local updater sees committed instead of staged slot','runtime/core.bend','+current = B.current(B.node(w, signal))','+current = R.Node.value(B.node(w, signal))','tests/locals.mjs'],
  ['local updater result function is invoked again','runtime/core.bend','Evaluate{value, current} <> SetSignalResolved{signal, current} <> rest','Evaluate{value, current} <> SetSignalArgument{signal} <> rest','tests/locals.mjs'],
  ['nested effect loses owner','runtime/core.bend','R.EffectSpec.options(spec), R.World.context(w), B.second(R.World, Nat, pair)','R.EffectSpec.options(spec), 0n, B.second(R.World, Nat, pair)','tests/nested.mjs'],
  ['nested effect loses captured arguments','runtime/callback.bend','R.EffectCreate{bind(compute, first, second), spec}','R.EffectCreate{compute, spec}','tests/nested.mjs'],
  ['nested effect untracks its caller','runtime/core.bend','case R.EffectCreate{compute, +spec}:','case R.EffectCreate{compute, +spec}:\n      +w = R.World.with_tracking(w, False{})','tests/nested.mjs'],
  ['initial effect ignores staged first value','runtime/core.bend','Bool.or(deferred, Bool.or(B.present(R.Node.pending(B.node(w, id))),','Bool.or(deferred, Bool.or(False{},','tests/nested.mjs'],
  ['nested memo loses owner','runtime/core.bend','N.computed(w, compute, options, R.World.context(w))','N.computed(w, compute, options, 0n)','tests/nested.mjs'],
  ['nested memo loses captured arguments','runtime/callback.bend','R.MemoRead{bind(compute, first, second), options}','R.MemoRead{compute, options}','tests/nested.mjs'],
  ['nested eager initial pass omitted','runtime/core.bend','_ => Recompute{id, True{}} <> ending)','_ => ending)','tests/nested.mjs'],
  ['onCleanup loses return identity','runtime/core.bend','rest, R.RootDisposerReference{root} <> tail}','rest, R.Undefined{} <> tail}','tests/cleanup-values.mjs'],
  ['same bound cleanup receives fresh callable IDs','runtime/callable.bend','+old = find(R.World.cleanupPrograms(w), root, 0n)','+old = {0n : Nat}','tests/cleanup-values.mjs'],
  ['bound cleanup disposes ambient receiver','runtime/owner.bend','case R.CleanupBoundRoot{owner}:\n      Machine{w, Enter{owner, True{}, False{}} <> rest}','case R.CleanupBoundRoot{owner}:\n      Machine{w, Enter{R.World.context(w), True{}, False{}} <> rest}','tests/cleanup-values.mjs'],
  ['context null treated as absent','runtime/context.bend','+value = B.choose(~R.Value, undefined(value),','+value = B.choose(~R.Value, B.nullish(value),','tests/contexts.mjs'],
  ['context record mutated in place','runtime/context.bend','+next = B.length(R.ContextRecord, R.World.contextRecords(w))\n      +w = R.World.with_contextRecords(w, B.append(R.ContextRecord, R.World.contextRecords(w), [R.ContextRecord{copyWith(entries, id, value)}]))','+next = R.Node.scope(B.node(w, owner))\n      +w = R.World.with_contextRecords(w, List.set(&2, R.ContextRecord, R.World.contextRecords(w), next, R.ContextRecord{copyWith(entries, id, value)}))','tests/contexts.mjs'],
  ['new root drops inherited context','runtime/owner-state.bend','R.Node.scope(B.node(w, parent))','0n','tests/contexts.mjs'],
  ['context read without owner returns default','runtime/context.bend','Nat.is_eq(owner, 0n),\n    _ => B.Bundle{failure(w, 0), R.Undefined{}}','False{},\n    _ => B.Bundle{failure(w, 0), R.Undefined{}}','tests/contexts.mjs'],
  ['nested root captures outer disposer argument','runtime/callback.bend','case R.RootScope{body, transparent}:\n      R.RootScope{body, transparent}','case R.RootScope{body, transparent}:\n      R.RootScope{bind(body, first, second), transparent}','tests/arguments.mjs'],
  ['function updater result is invoked again','runtime/api.bend','R.WriteExpr{id, expr, True{}}','R.WriteExpr{id, expr, False{}}','tests/arguments.mjs'],
  ['bound disposer uses ambient owner','runtime/core.bend','case R.RootDisposerReference{id}:\n      Machine{O.disposeChildren(w, id, True{}, False{}), rest, R.Undefined{} <> tail}','case R.RootDisposerReference{id}:\n      Machine{O.disposeChildren(w, R.World.context(w), True{}, False{}), rest, R.Undefined{} <> tail}','tests/arguments.mjs'],
  ['effect callback arguments reversed','runtime/core.bend','R.CallWith{callback, R.Literal{R.Node.value(B.node(w, id))}, R.Literal{R.Node.prevValue(B.node(w, id))}}','R.CallWith{callback, R.Literal{R.Node.prevValue(B.node(w, id))}, R.Literal{R.Node.value(B.node(w, id))}}','tests/arguments.mjs'],
  ['runWithOwner fails to restore tracking','runtime/ambient.bend','R.World.with_tracking(R.World.with_context(w, owner), tracking)','R.World.with_tracking(R.World.with_context(w, owner), False{})','tests/ownership.mjs'],
  ['getObserver ignores untrack','runtime/ambient.bend','B.choose(~Nat, R.World.tracking(w), _ => R.World.context(w), _ => 0n)','R.World.context(w)','tests/ownership.mjs'],
  ['inline root detaches from its actual parent','runtime/core.bend','D.createOwner(w, R.World.context(w), transparent)','D.createOwner(w, 0n, transparent)','tests/ownership.mjs'],
  ['callback return falls through','runtime/core.bend','Machine{w, Evaluate{Z.bind(expr, first, second), R.Undefined{}} <> rest, stack}','Machine{w, Evaluate{Z.bind(expr, first, second), R.Undefined{}} <> Discard{} <> Callback{id, tail, first, second} <> rest, stack}','tests/callbacks.mjs'],
  ['callback read loses tracking','runtime/core.bend','Machine{w, Evaluate{Z.bind(expr, first, second), R.Undefined{}} <> Discard{} <> Callback{id, tail, first, second} <> rest, stack}','Machine{R.World.with_tracking(w, False{}), Evaluate{Z.bind(expr, first, second), R.Undefined{}} <> Discard{} <> Callback{id, tail, first, second} <> rest, stack}','tests/callbacks.mjs'],
  ['StatusError prefixes a native Error message','runtime/error.bend','B.choose(~String, native, _ => message, _ => errorString(name, message))','errorString(name, message)','tests/host-errors.mjs'],
  ['explicit/native error identities alias','representation/base.bend','Bool.and(Nat.is_eq(x, y), Bool.xor(Bool.xor(explicitA, explicitB), True{}))','Nat.is_eq(x, y)','tests/host-errors.mjs'],
  ['until timer is never cancelled','runtime/signals.bend','R.Awaiter.timer(a)','False{}','tests/until-options.mjs'],
  ['until ignores a pre-aborted signal','runtime/signals.bend','Bool.and(Nat.is_ne(signal, 0n), R.AbortInput.aborted(input))','False{}','tests/until-options.mjs'],
  ['until resolves a falsy value','runtime/signals.bend','Bool.and(R.Awaiter.until(B.awaiter(w, id)), Bool.and(Bool.not(rejected), Bool.not(B.truth(value))))','False{}','tests/until.mjs'],
  ['unregistered staged-error recovery workaround','runtime/core.bend','+w = B.choose(~R.World, Bool.or(U32.is_ne(R.Node.status(B.node(w, id)), 0), Nat.is_ne(R.Node.x(B.node(w, id)), 0n)),','+w = B.store_node(w, id, R.Node.with_config(B.node(w, id), B.clear(R.Node.config(B.node(w, id)), K.CONFIG_STAGED_ERROR())))\n      +w = B.choose(~R.World, Bool.or(U32.is_ne(R.Node.status(B.node(w, id)), 0), Nat.is_ne(R.Node.x(B.node(w, id)), 0n)),','tests/held-recovery.mjs'],
  ['refresh waiter runs eagerly','runtime/signals.bend','_ => R.World.with_hostJobs(w, B.append(R.HostJob, R.World.hostJobs(w), [R.WatchStart{id}]))','_ => makeWatch(256n, w, id)','tests/waiters.mjs'],
  ['watch promise resolves in the pass','runtime/watch-state.bend','[R.WatchDelivery{id, failed, value}]','[R.PromiseOutcome{id, failed, value}]','tests/waiters.mjs'],
  ['post-gap synchronous yield is lost','runtime/core.bend','Bool.and(R.AsyncObserver.isSync(o), R.StreamState.initialRead(s))','R.AsyncObserver.isSync(o)','tests/iterators.mjs'],
  ['iterator return omitted','runtime/iterator-state.bend','R.StreamPlan.hasReturn(plan)','False{}','tests/iterators.mjs'],
  ['stale flight writes','runtime/flight.bend','Bool.or(Nat.is_ne(R.NodeExtension.inFlight(B.extension(w, id)), result), B.has','Bool.or(False{}, B.has','tests/async.mjs'],
  ['unresolved promise commits','runtime/flight.bend','Bool.not(R.AsyncObserver.resolved(o))','False{}','tests/async.mjs'],
  ['lost subscriber wake','runtime/write.bend','B.schedule(insertSubs(w, id))','B.schedule(w)'],
  ['leaked staging','runtime/core.bend','          value = B.choose(~R.Value, committed, _ => R.Node.value(n), _ => B.current(n))','          value = B.current(n)'],
  ['untrack subscribes','runtime/core.bend','Machine{R.World.with_tracking(w, False{}), Evaluate{body, prev}','Machine{R.World.with_tracking(w, True{}), Evaluate{body, prev}'],
  ['wrong render result','runtime/core.bend','T.setText(w, R.Node.target(B.node(w, id)), R.Node.value(B.node(w, id)))','T.setText(w, R.Node.target(B.node(w, id)), R.Undefined{})'],
];
let caught=0;
for(const [name,file,before,after,test='tests/differential.mjs'] of mutations) {
  const dir=await fs.mkdtemp(path.join(os.tmpdir(),'bend-signals-mutation-'));
  try {
    for(const d of ['runtime','representation','observation'])await fs.cp(path.join(root,d),path.join(dir,d),{recursive:true});
    const p=path.join(dir,file),text=await fs.readFile(p,'utf8');
    if(!text.includes(before))throw new Error('Stale mutation '+name);
    await fs.writeFile(p,text.replace(before,after));
    const emit=path.join(dir,'runtime.mjs');
    const compile=spawnSync(path.join(root,'node_modules/.bin/bun'),[path.join(root,'upstream/bend/bend2/main.ts'),path.join(dir,'runtime/api.bend'),'-o',emit],{encoding:'utf8'});
    if(compile.status!==0)throw new Error('Mutation did not compile: '+name+'\n'+compile.stderr.slice(-3000));
    const run=spawnSync(process.execPath,[test],{cwd:root,env:{...process.env,BEND_EMIT_FILE:emit},encoding:'utf8',maxBuffer:1024*1024});
    if(run.status===0)throw new Error('Test oracle accepted mutation: '+name);
    if(!run.stderr.includes('AssertionError'))throw new Error('Mutation failed for an unrelated reason: '+name+'\n'+run.stderr.slice(-3000));
    caught++;console.log('Rejected mutation: '+name);
  } finally {await fs.rm(dir,{recursive:true,force:true});}
}
console.log(`${caught} source-changing variants rejected by differential assertions.`);
