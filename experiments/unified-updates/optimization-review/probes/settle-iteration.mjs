// Collection-semantics fixture only; not a runtime behavior/performance test.
function fixture(twoPass, mutation) {
  const dirty = new Set(['A']);
  const watching = new Set(['B']);
  const seen = [];
  let mutated = false;
  function sample(record) {
    seen.push(record);
    if (record === 'B' && !mutated) {
      mutated = true;
      if (mutation === 'new') dirty.add('C');
      else { dirty.delete('A'); dirty.add('A'); }
    }
  }
  if (twoPass) {
    for (const record of dirty) sample(record);
    for (const record of watching) if (!dirty.has(record)) sample(record);
  } else {
    for (const record of watching) dirty.add(record);
    for (const record of dirty) sample(record);
  }
  return seen.join(',');
}
for (const mutation of ['new', 'readd']) {
  console.log(`${mutation}: original=${fixture(false, mutation)} two-pass=${fixture(true, mutation)}`);
}
