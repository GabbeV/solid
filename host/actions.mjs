// Restricted external generator protocol. The port executes the methods in its
// shared evaluator; the reference supplies these methods to the actual action().
// Arbitrary JS generators/closures and protocol getters are not encoded here.
export function requireActionProtocol(plan){
  if(!plan||!Array.isArray(plan.steps))throw new TypeError('An action needs a typed generator steps array');
  for(const step of plan.steps){
    if(!step||!Object.hasOwn(step,'next'))throw new TypeError('Each action method needs its next expression');
  }
}

// User-code argument capture only. Literal payloads keep their exact identity;
// nested action functions introduce a fresh parameter binder. No expression is
// evaluated or reactive decision made during this substitution.
export function bindActionArguments(plan,args){
  const bind=(value,depth)=>{
    if(!value||typeof value!=='object'||Object.hasOwn(value,'lit'))return value;
    if(Object.hasOwn(value,'actionArgument')){
      const arg=value.actionArgument,index=typeof arg==='number'?arg:arg.index??0,level=typeof arg==='number'?0:arg.depth??0;
      return level===depth?{lit:args[index]}:value;
    }
    if(Array.isArray(value))return value.map(item=>bind(item,depth));
    return Object.fromEntries(Object.entries(value).map(([key,item])=>[key,bind(item,depth+(key==='actionCreate'?1:0))]));
  };
  return bind(plan,0);
}
