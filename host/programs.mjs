// Teardown uses the same core callback/read driver as ordinary callbacks.
// Only the error-arm-specific helper remains outside this function ABI.
export function requireTeardownProgram(programs,name){
  if(name===undefined)return;
  const actions=programs.get(name);
  if(!actions)throw new TypeError('Unknown callback program: '+name);
  if(actions.some(([op])=>op==='previousCleanup'))throw new TypeError('Error-arm helper is unavailable in teardown callbacks');
  requireFunctionProgram(programs,name);
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
