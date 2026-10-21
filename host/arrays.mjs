// Array identity/materialization only. Slots and mutation live in Bend's arena;
// this cache does not reconcile rows, select values or schedule reactive work.
export class RuntimeArrays {
  constructor(slots,decode){this.slots=slots;this.decode=decode;this.values=new Map();this.ids=new WeakMap();this.busy=new Set();this.snapshots=new Map();}
  identity(value){const id=this.ids.get(value);if(id!==undefined)this.validate(id);return id;}
  validate(id){
    const value=this.values.get(id),before=this.snapshots.get(id);
    if(!before)return;
    const keys=Reflect.ownKeys(value);
    if(keys.length!==before.keys.length||keys.some((key,i)=>key!==before.keys[i])||value.length!==before.length||before.keys.some(key=>key!=='length'&&!Object.is(value[key],before.entries.get(key))))throw new TypeError('External array mutation is outside the admitted host grammar');
  }
  get(id){
    if(this.busy.has(id))return this.values.get(id);
    this.validate(id);
    if(!this.values.has(id)){const value=[];this.values.set(id,value);this.ids.set(value,id);}
    const value=this.values.get(id),slots=this.slots(id);this.busy.add(id);
    try{
      value.length=slots.length;
      for(let i=0;i<slots.length;i++){
        if(Object.hasOwn(slots[i],'value'))value[i]=this.decode(slots[i].value);
        else delete value[i];
      }
      const keys=Reflect.ownKeys(value);this.snapshots.set(id,{keys,length:value.length,entries:new Map(keys.map(key=>[key,value[key]]))});
      return value;
    }finally{this.busy.delete(id);}
  }
  sync(){for(const id of this.values.keys())this.get(id);}
}
