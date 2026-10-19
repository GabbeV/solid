// Identity/property codec only, not reactive error handling. Explicit test input
// tokens and native allocations have separate namespaces; neither is a source ID.
const classes=[Error,TypeError,RangeError,SyntaxError,ReferenceError,EvalError,URIError,DOMException];
const names=['Error','TypeError','RangeError','SyntaxError','ReferenceError','EvalError','URIError','DOMException'];
export const errorKind=shape=>names.indexOf(shape.kind);
const key=shape=>`${shape.explicit?'input':'native'}:${shape.error}`;
const equal=(a,b)=>a.kind===b.kind&&a.name===b.name&&a.message===b.message&&a.native===b.native&&a.code===b.code;
function create(kind,name,message){
  const object=kind==='DOMException'?new DOMException(message,name):new classes[names.indexOf(kind)](message);
  if(kind!=='DOMException'&&object.name!==name)object.name=name;
  return object;
}
export class HostErrors {
  objects=new Map();ids=new WeakMap();shapes=new Map();next=1;seen=new WeakMap();seenCount=0;
  allocate(){while(this.objects.has(`native:${this.next}`))this.next++;return this.next++;}
  describe(value){
    if(value===null||typeof value!=='object')return value;
    if(!(value instanceof Error)&&!(value instanceof DOMException)&&Object.hasOwn(value,'error')){
      const {error:id,kind='Error',message='',name=kind==='DOMException'?'Error':kind}=value;
      if(!Number.isSafeInteger(id)||id<1||id>2**48-1||!names.includes(kind)||typeof message!=='string'||typeof name!=='string')throw new TypeError('Invalid immutable error input');
      const address=`input:${id}`;
      if(this.objects.has(address)){
        const known=this.shapes.get(address);
        if(known.kind!==kind||known.name!==name||known.message!==message)throw new TypeError('Error identity reused with different properties');
        return known;
      }
      const object=create(kind,name,message);
      return this.bind({error:id,explicit:true,kind,name,message,native:object instanceof Error,code:object instanceof DOMException?object.code:0},object);
    }
    if(!(value instanceof Error)&&!(value instanceof DOMException))return value;
    const kind=classes.findIndex(C=>Object.getPrototypeOf(value)===C.prototype);
    if(kind<0)throw new TypeError('Custom error subclasses are outside the host input grammar');
    if('then'in value||Symbol.asyncIterator in value)throw new TypeError('Protocol-bearing errors are outside the host input grammar');
    for(const property of ['name','message'])if(Object.getOwnPropertyDescriptor(value,property)?.get)throw new TypeError('Error property getters are outside the host input grammar');
    if(typeof value.name!=='string'||typeof value.message!=='string')throw new TypeError('Error name/message must be strings');
    const address=this.ids.get(value),known=address===undefined?undefined:this.shapes.get(address);
    const shape={error:known?.error??this.allocate(),explicit:known?.explicit??false,kind:names[kind],name:value.name,message:value.message,native:value instanceof Error,code:value instanceof DOMException?value.code:0};
    if(known){if(!equal(known,shape))throw new TypeError('Mutable error properties are outside the host input grammar');return known;}
    return this.bind(shape,value);
  }
  bind(shape,object){const address=key(shape);this.objects.set(address,object);this.ids.set(object,address);this.shapes.set(address,shape);return shape;}
  materialize(shape){return this.objects.get(key(shape));}
  decode(id,explicit,type,name,message,native,code){
    const shape={error:id,explicit,kind:names[type],name,message,native,code},address=key(shape);
    if(!this.objects.has(address)){
      const object=create(shape.kind,name,message);
      if((object instanceof Error)!==native||(object instanceof DOMException?object.code:0)!==code)throw new TypeError('External error properties do not match this host');
      this.bind(shape,object);
    }
    if(!equal(this.shapes.get(address),shape))throw new TypeError('External error representation disagrees with its host identity');
    return this.objects.get(address);
  }
  observe(value){
    const address=value!==null&&(typeof value==='object'||typeof value==='function')?this.ids.get(value):undefined;
    if(address===undefined)return value;
    // Allocation order in a host input compiler is not a reactive observation.
    // Compare identities in first-observation order and assert native aliases
    // separately; this observer never changes the value held by the runtime.
    if(!this.seen.has(value))this.seen.set(value,++this.seenCount);
    const shape=this.shapes.get(address);
    return {externalError:this.seen.get(value),kind:shape.kind,name:shape.name,message:shape.message,native:shape.native,code:shape.code};
  }
}
