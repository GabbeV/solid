// Restricted external generator protocol. The port executes the methods in its
// shared evaluator; the reference supplies these methods to the actual action().
// Arbitrary JS generators/closures and protocol getters are not encoded here.
export function requireActionProtocol(plan){
  if(!plan||!Array.isArray(plan.steps))throw new TypeError('An action needs a typed generator steps array');
  for(const step of plan.steps){
    if(!step||!Object.hasOwn(step,'next'))throw new TypeError('Each action method needs its next expression');
  }
}
