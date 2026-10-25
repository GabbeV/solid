// A real emitted constructor supplies the encoder's tags. Invalid handwritten
// tags must fail at the adapter boundary instead of becoming an empty decode.
import assert from 'node:assert/strict';
import {ABI,encodeList,list} from '../host/bend.mjs';
const values=[ABI.vNumber(17),ABI.vText('caller'),ABI.vUndefined()];
const encoded=encodeList(values),native=ABI.bareNext(false,ABI.vUndefined(),ABI.emptyNexts());
assert.equal(encoded.$,native.$);
assert.deepEqual(list(encoded),values);
assert.deepEqual(ABI.firstValue(encoded),values[0]);
assert.deepEqual(list(encodeList([])),[]);
for(const malformed of [{$:'lookalike-'+native.$,head:values[0],tail:ABI.emptyNexts()},{$:native.$,head:values[0]},{$:native.$,head:values[0],tail:{$:'invalid-tail'}},null]){
 assert.throws(()=>list(malformed),/Malformed Bend list ABI/);
}
if(native.$!=='Cons')assert.throws(()=>list({$:'Cons',head:values[0],tail:ABI.emptyNexts()}),/Malformed Bend list ABI/);
console.log('Emitted list ABI round-trip and malformed-tag controls pass.');
