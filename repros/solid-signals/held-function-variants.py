"""Generate isolated setter experiment sources from Solid's immutable pin.

Usage: python3 held-function-variants.py SOLID_CHECKOUT OUTPUT_DIRECTORY
Does not modify the checkout. Discarded variants are diagnostic experiments;
only the selected private-common-value-function received full validation.
"""
import subprocess,pathlib,sys
if len(sys.argv)!=3:
    raise SystemExit(__doc__)
root=pathlib.Path(sys.argv[1]).resolve()
out=pathlib.Path(sys.argv[2]).resolve()
out.mkdir(parents=True,exist_ok=True)
base=subprocess.check_output(['git','show','d2ad8b288886a5c7171e6746ccc019ad1d08d8ab:packages/signals/src/core/core.ts'],cwd=root,text=True)
start=base.index('export function setSignal<T>')
end=base.index('\n/**\n * User-facing setter',start)
old=base[start:end]
held='  if (held && typeof v === "function") v = (v as (prev: T) => T)(el._value);\n  const result = setSignal(el, v);'
assert held in base
# Third parameter on public setSignal: measure, but cannot ship because public bound setters forward extra arguments.
flag=base.replace('v: T | ((prev: T) => T)): T {\n  if (writeHook', 'v: T | ((prev: T) => T), resolved?: boolean | number): T {\n  if (writeHook',1)
flag=flag.replace('if (typeof v === "function") v = (v as (prev: T) => T)(currentValue);','if (!resolved && typeof v === "function") v = (v as (prev: T) => T)(currentValue);',1)
flag=flag.replace('const result = setSignal(el, v);','const result = setSignal(el, v, held);',1)
(out/'flag-public.ts').write_text(flag)
# Preserve setSignal's two-argument boundary, private shared writer carries resolved marker.
private=flag.replace('export function setSignal<T>', 'function writeSignal<T>',1)
private=private.replace('const result = setSignal(el, v, held);','const result = writeSignal(el, v, held);',1)
private=private[:start]+'export function setSignal<T>(el: Signal<T> | Computed<T>, v: T | ((prev: T) => T)): T {\n  return writeSignal(el, v);\n}\n\n'+private[start:]
(out/'flag-private.ts').write_text(private)
# Split prepare (hooks/current frame), resolve, and value-only staging. Share the latter two boundaries.
normalize='  if (typeof v === "function") v = (v as (prev: T) => T)(currentValue);\n'
pre,post=old.split(normalize)
pre=pre.replace('export function setSignal<T>(el: Signal<T> | Computed<T>, v: T | ((prev: T) => T)): T {','function prepareSignalWrite<T>(el: Signal<T> | Computed<T>): T {',1)
pre+='  return currentValue;\n}\n'
write='function writeSignal<T>(el: Signal<T> | Computed<T>, v: T, currentValue: T): T {'+post
wrapper='export function setSignal<T>(el: Signal<T> | Computed<T>, v: T | ((prev: T) => T)): T {\n  const currentValue = prepareSignalWrite(el);\n'+normalize+'  return writeSignal(el, v as T, currentValue);\n}\n\n'
split=base[:start]+wrapper+pre+'\n'+write+base[end:]
split=split.replace(held, '  if (held && typeof v === "function") v = (v as (prev: T) => T)(el._value);\n  const result = held\n    ? writeSignal(el, v as T, prepareSignalWrite(el))\n    : setSignal(el, v);')
(out/'split-write.ts').write_text(split)
# Same split, but explicitly normalize non-held memo updates here to remove the setter delegation/branch.
split2=base[:start]+wrapper+pre+'\n'+write+base[end:]
split2=split2.replace(held, '  if (held && typeof v === "function") v = (v as (prev: T) => T)(el._value);\n  const currentValue = prepareSignalWrite(el);\n  if (!held && typeof v === "function") v = (v as (prev: T) => T)(currentValue);\n  const result = writeSignal(el, v as T, currentValue);')
(out/'split-normalize.ts').write_text(split2)
(out/'base.ts').write_text(base)
wrapped=base.replace(held, '  if (held && typeof v === "function") {\n    const value = (v as (prev: T) => T)(el._value);\n    v = () => value;\n  }\n  v = setSignal(el, v);',1)
wrapped_at=wrapped.index('export function setMemo<T>')
wrapped=wrapped[:wrapped_at]+wrapped[wrapped_at:].replace('return result;','return v;',1)
(out/'wrapper.ts').write_text(wrapped)
flag_default=flag.replace('resolved?: boolean | number','resolved: boolean | number = false',1)
(out/'flag-default.ts').write_text(flag_default)
# Explicit public wrapper and fixed-arity shared writer; invert marker to default-to-resolve.
private3=private.replace('return writeSignal(el, v);','return writeSignal(el, v, false);',1).replace('resolved?: boolean | number','resolved: boolean | number',1)
(out/'flag-private-fixed.ts').write_text(private3)
# One common resolved-value writer can replace raw-value protection wrappers at internal sites.
# Measured separately later; baseline setSignal remains the normalizer.
for name,variant in [('flag-reuse',flag),('flag-default-reuse',flag_default),('flag-private-reuse',private)]:
 variant=variant.replace('const result = writeSignal(el, v, held);','v = writeSignal(el, v, held);',1).replace('const result = setSignal(el, v, held);','v = setSignal(el, v, held);',1)
 pos=variant.index('export function setMemo<T>')
 variant=variant[:pos]+variant[pos:].replace('return result;','return v;',1)
 (out/(name+'.ts')).write_text(variant)
reuse=(out/'flag-default-reuse.ts').read_text()
(out/'flag-type-first.ts').write_text(reuse.replace('!resolved && typeof v === "function"','typeof v === "function" && !resolved',1))
resolve=reuse.replace('resolved: boolean | number = false','resolve = true',1).replace('!resolved && typeof v === "function"','typeof v === "function" && resolve',1).replace('setSignal(el, v, held)','setSignal(el, v, !held)',1)
(out/'flag-resolve.ts').write_text(resolve)
# Share updater classification as well as storage. Held updaters still run before hook.
shared=base.replace('v: T | ((prev: T) => T)): T {\n  if (writeHook', 'v: T | ((prev: T) => T), held: boolean | number = false): T {\n  let update = typeof v === "function";\n  if (held && update) {\n    v = (v as (prev: T) => T)(el._value);\n    update = false;\n  }\n  if (writeHook',1)
shared=shared.replace('if (typeof v === "function") v = (v as (prev: T) => T)(currentValue);','if (update) v = (v as (prev: T) => T)(currentValue);',1)
shared=shared.replace(held,'  v = setSignal(el, v, held);',1)
pos=shared.index('export function setMemo<T>');shared=shared[:pos]+shared[pos:].replace('return result;','return v;',1)
(out/'shared-normalize.ts').write_text(shared)
fn=shared.replace('let update = typeof v === "function";','let update = typeof v === "function" ? v as (prev: T) => T : undefined;',1).replace('v = (v as (prev: T) => T)(el._value);\n    update = false;','v = update(el._value);\n    update = undefined;',1).replace('if (update) v = (v as (prev: T) => T)(currentValue);','if (update) v = update(currentValue);',1)
(out/'shared-updater.ts').write_text(fn)
for name,variant in [('flag-undefined',(out/'flag-default-reuse.ts').read_text()),('flag-undefined-type-first',(out/'flag-type-first.ts').read_text())]:
 (out/(name+'.ts')).write_text(variant.replace('resolved: boolean | number = false','resolved: boolean | number | undefined = undefined',1))
signals=subprocess.check_output(['git','show','d2ad8b288886a5c7171e6746ccc019ad1d08d8ab:packages/signals/src/signals.ts'],cwd=root,text=True)
for name,variant in [('shared-arrow',shared),('shared-arrow-optional',shared.replace('held: boolean | number = false','held?: boolean | number',1)),('resolved-arrow',(out/'flag-default-reuse.ts').read_text())]:
 (out/(name+'.ts')).write_text(variant)
 # The setter already allocates once per signal; use that entry to fix the mode.
 replacement='((value: T | ((prev: T) => T)) => setSignal(node, value, false)) as Setter<T | undefined>'
 if name=='resolved-arrow':replacement='((value: T | ((prev: T) => T)) => setSignal(node, value, false)) as Setter<T | undefined>'
 (out/(name+'-signals.ts')).write_text(signals.replace('setSignal.bind(null, node as any) as Setter<T | undefined>',replacement,1))
(out/'base-signals.ts').write_text(signals)
constant=shared.replace('let update = typeof v === "function";','const update = typeof v === "function";',1).replace('    update = false;\n','',1).replace('if (update) v = (v as (prev: T) => T)(currentValue);','if (!held && update) v = (v as (prev: T) => T)(currentValue);',1)
constant=constant.replace('held: boolean | number = false','held?: boolean | number',1)
(out/'shared-constant.ts').write_text(constant)
private_const=constant.replace('export function setSignal<T>','function writeSignal<T>',1).replace('v = setSignal(el, v, held);','v = writeSignal(el, v, held);',1)
arrow='export const setSignal = <T>(el: Signal<T> | Computed<T>, v: T | ((prev: T) => T)): T => writeSignal(el, v);\n\n'
(out/'private-constant-arrow.ts').write_text(private_const[:start]+arrow+private_const[start:])
fnwrapper='export function setSignal<T>(el: Signal<T> | Computed<T>, v: T | ((prev: T) => T)): T {\n  return writeSignal(el, v);\n}\n\n'
(out/'private-constant-function.ts').write_text(private_const[:start]+fnwrapper+private_const[start:])
private_var=shared.replace('export function setSignal<T>','function writeSignal<T>',1).replace('v = setSignal(el, v, held);','v = writeSignal(el, v, held);',1).replace('held: boolean | number = false','held?: boolean | number',1)
(out/'private-shared-arrow.ts').write_text(private_var[:start]+arrow+private_var[start:])
# Global binding adds no allocation to either setters or individual signal construction.
bind_variant=private_const.replace('function writeSignal<T>(el: Signal<T> | Computed<T>, v: T | ((prev: T) => T), held?: boolean | number): T {','function writeSignal<T>(held: boolean | number, el: Signal<T> | Computed<T>, v: T | ((prev: T) => T)): T {',1).replace('writeSignal(el, v, held)','writeSignal(held, el, v)',1)
bind='export const setSignal = /*@__PURE__*/ writeSignal.bind(null, false) as <T>(el: Signal<T> | Computed<T>, v: T | ((prev: T) => T)) => T;\n\n'
(out/'private-constant-bound.ts').write_text(bind_variant[:start]+bind+bind_variant[start:])
# Share the identical accessor/bound-setter return without changing construction order.
a=signals.index('  if (typeof first === "function") {', signals.index('export function createSignal<T>(\n  first?'))
b=signals.index('\n}\n',a)
common='''  const derived = typeof first === "function";
  const node = derived
    ? computed<T>(first as any, second as any)
    : signal<T>(first as any, second as SignalOptions<T>);
  if (derived) node._config &= ~CONFIG_AUTO_DISPOSE;
  else if (__OBSERVE__) registerGraph(node, getOwner());
  return [
    accessor<T | undefined>(node),
    (derived ? setMemo : setSignal).bind(null, node as any) as Setter<T | undefined>
  ];'''
new_signals=signals[:a]+common+signals[b:]
for name,core in [('private-common',(out/'private-constant-arrow.ts').read_text()),('split-common',(out/'split-write.ts').read_text())]:
 (out/(name+'.ts')).write_text(core)
 (out/(name+'-signals.ts')).write_text(new_signals)
# Isolate constructor consolidation on unfixed baseline as a benchmark control.
(out/'base-common.ts').write_text(base)
(out/'base-common-signals.ts').write_text(new_signals)
prefix='  const update = typeof v === "function";\n  if (held && update) {\n    v = (v as (prev: T) => T)(el._value);\n  }'
value_core=(out/'private-common.ts').read_text()
assert prefix in value_core
value_core=value_core.replace(prefix,'  const update = typeof v === "function";\n  let value = (held && update ? (v as (prev: T) => T)(el._value) : v) as T;',1)
value_core=value_core.replace('if (!held && update) v = (v as (prev: T) => T)(currentValue);','if (!held && update) value = (v as (prev: T) => T)(currentValue);',1)
import re
start_body=value_core.index('  // Lanes: a write landing', value_core.index('function writeSignal<T>'))
end_body=value_core.index('\n/**\n * User-facing setter',start_body)
value_core=value_core[:start_body]+re.sub(r'\bv\b','value',value_core[start_body:end_body])+value_core[end_body:]
(out/'private-common-value.ts').write_text(value_core)
(out/'private-common-value-signals.ts').write_text(new_signals)
(out/'private-value.ts').write_text(value_core)
function_value=value_core.replace(arrow,fnwrapper,1)
assert function_value!=value_core
(out/'private-common-value-function.ts').write_text(function_value)
(out/'private-common-value-function-signals.ts').write_text(new_signals)
late=(out/'private-common.ts').read_text()
late_start=late.index('  // Lanes: a write landing',late.index('function writeSignal<T>'))
late_end=late.index('\n/**\n * User-facing setter',late_start)
late=late[:late_start]+'  const value = v as T;\n\n'+re.sub(r'\bv\b','value',late[late_start:late_end])+late[late_end:]
(out/'private-common-late-value.ts').write_text(late)
(out/'private-common-late-value-signals.ts').write_text(new_signals)
late_var=late.replace('  const update = typeof v === "function";','  let update = typeof v === "function";',1).replace('    v = (v as (prev: T) => T)(el._value);\n  }','    v = (v as (prev: T) => T)(el._value);\n    update = false;\n  }',1).replace('if (!held && update) v = (v as (prev: T) => T)(currentValue);','if (update) v = (v as (prev: T) => T)(currentValue);',1)
(out/'private-common-late-update.ts').write_text(late_var)
(out/'private-common-late-update-signals.ts').write_text(new_signals)
# Normalize the existing parameter with a conditional cast: no retained original
# updater after the held prefix, and no extra resolved-value alias in emitted JS.
ternary=(out/'private-shared-arrow.ts').read_text().replace('if (update) v = (v as (prev: T) => T)(currentValue);','v = (update ? (v as (prev: T) => T)(currentValue) : v) as T;',1)
(out/'private-common-normalize.ts').write_text(ternary)
(out/'private-common-normalize-signals.ts').write_text(new_signals)
# Preserve setMemo's original pre-evaluation and the hoisted public entry.
# Constructor consolidation pays for a private already-resolved flag.
flag_common=(out/'flag-private-reuse.ts').read_text()
flag_common=flag_common.replace('if (!resolved && typeof v === "function") v = (v as (prev: T) => T)(currentValue);','v = (!resolved && typeof v === "function" ? (v as (prev: T) => T)(currentValue) : v) as T;',1)
(out/'private-common-resolved.ts').write_text(flag_common)
(out/'private-common-resolved-signals.ts').write_text(new_signals)
