// The owner/core suspension boundary is still unfinished. Keep that domain
// out of teardown inputs before any node allocation or callback side effects.
// This is harness validation, not an implementation of a Solid callback.
export function requireTeardownProgram(programs,name){
  if(name===undefined)return;
  const actions=programs.get(name);
  if(!actions)throw new TypeError('Unknown callback program: '+name);
  if(actions.some(([op,,value])=>op==='set'&&(programs.isAccessor?.(value)||(value&&typeof value==='object'&&(typeof value.accessor==='string'||typeof value.setter==='string'||typeof value.callback==='string')))))
    throw new TypeError('Accessor updater reads in teardown callbacks are not yet translated');
  if(actions.some(([op])=>op==='previousCleanup'))throw new TypeError('Error-arm helper is unavailable in teardown callbacks');
  if(actions.some(([op])=>['eval','return','setExpr','updateExpr','throwExpr'].includes(op)))
    throw new TypeError('Expression statements in teardown callbacks are not yet translated');
}

// The error-arm helper is supplied only by that callback entry. A public
// function value binds it to undefined; helper-dependent programs are outside
// the function-value ABI, including helper use through a named call.
export function requireFunctionProgram(programs,name,seen=new Set()){
  if(seen.has(name))return;
  seen.add(name);
  const actions=programs.get(name);
  if(!actions)throw new TypeError('Unknown callback function: '+name);
  if(actions.some(([op])=>op==='previousCleanup'))throw new TypeError('Error-arm helper is unavailable in callback function values');
  const visit=value=>{
    if(!value||typeof value!=='object'||Object.hasOwn(value,'lit'))return;
    if(typeof value.call==='string')requireFunctionProgram(programs,value.call,seen);
    for(const entry of Object.values(value))visit(entry);
  };
  for(const [op,...args] of actions)if(['eval','return','setExpr','updateExpr','throwExpr'].includes(op))visit(args[op==='setExpr'||op==='updateExpr'?1:0]);
}
