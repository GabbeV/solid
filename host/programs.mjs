// The owner/core suspension boundary is still unfinished. Keep that domain
// out of teardown inputs before any node allocation or callback side effects.
// This is harness validation, not an implementation of a Solid callback.
export function requireTeardownProgram(programs,name){
  if(name===undefined)return;
  const actions=programs.get(name);
  if(!actions)throw new TypeError('Unknown callback program: '+name);
  if(actions.some(([op,,value])=>op==='set'&&(programs.isAccessor?.(value)||(value&&typeof value==='object'&&(typeof value.accessor==='string'||typeof value.setter==='string')))))
    throw new TypeError('Accessor updater reads in teardown callbacks are not yet translated');
  if(actions.some(([op])=>['eval','return','setExpr','updateExpr','throwExpr'].includes(op)))
    throw new TypeError('Expression statements in teardown callbacks are not yet translated');
}
