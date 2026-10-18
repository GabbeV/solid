# async.ts node-owned pending-source Set and error-object helpers. State-only
# leaf so status propagation and settlement share the source operations.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./extension.bend as E
import ./constants.bend as K

def items(sources: R.SourceSet) -> List<&2, Nat>:
  match sources:
    case R.NoSources{}:
      []
    case R.Sources{xs}:
      xs

def hasSource(+w: R.World, id: Nat, source: Nat) -> Bool:
  B.contains(items(R.NodeExtension.pendingSources(B.extension(w, id))), source)

def addPendingSource(+w: R.World, +id: Nat, +source: Nat) -> B.Bundle<R.World, Bool>:
  B.choose(~B.Bundle<R.World, Bool>, hasSource(w, id, source), _ => B.Bundle{w, False{}},
    _ =>
      +w = E.ext(w, id)
      xs = B.append(Nat, items(R.NodeExtension.pendingSources(B.extension(w, id))), [source])
      B.Bundle{B.store_extension(w, id, R.NodeExtension.with_pendingSources(B.extension(w, id), R.Sources{xs})), True{}})

def remove(xs: List<&2, Nat>, +source: Nat) -> List<&2, Nat>:
  match xs:
    case Nil{}:
      []
    case +id <> +rest:
      B.choose(~List<&2, Nat>, Nat.is_eq(id, source), _ => rest, _ => id <> remove(rest, source))

def removePendingSource(+w: R.World, +id: Nat, +source: Nat) -> B.Bundle<R.World, Bool>:
  B.choose(~B.Bundle<R.World, Bool>, hasSource(w, id, source),
    _ =>
      +xs = remove(items(R.NodeExtension.pendingSources(B.extension(w, id))), source)
      sources = B.choose(~R.SourceSet, List.is_empty(&2, Nat, xs), _ => R.NoSources{}, _ => R.Sources{xs})
      B.Bundle{B.store_extension(w, id, R.NodeExtension.with_pendingSources(B.extension(w, id), sources)), True{}},
    _ => B.Bundle{w, False{}})

def clearPendingSources(+w: R.World, +id: Nat) -> R.World:
  B.choose(~R.World, Nat.is_ne(R.Node.x(B.node(w, id)), 0n),
    _ => B.store_extension(w, id, R.NodeExtension.with_pendingSources(B.extension(w, id), R.NoSources{})), _ => w)

def notReadySource(error: R.Value) -> Nat:
  match error:
    case R.NotReadyFailure{identity, source}:
      source
    case _:
      0n

def isNotReady(error: R.Value) -> Bool:
  match error:
    case R.NotReadyFailure{identity, source}:
      True{}
    case _:
      False{}

def notReadyError(+w: R.World, source: Nat) -> B.Bundle<R.World, R.Value>:
  +serial = Nat.add(1n, R.World.errorSerial(w))
  B.Bundle{R.World.with_errorSerial(w, serial), R.NotReadyFailure{serial, source}}

def preserveOrCreate(+w: R.World, +id: Nat, +source: Nat, +current: R.Value) -> R.World:
  B.choose(~R.World, Bool.and(isNotReady(current), Nat.is_eq(notReadySource(current), source)), _ => w,
    _ =>
      +pair = notReadyError(w, source)
      +w = E.ext(B.first(R.World, R.Value, pair), id)
      B.store_extension(w, id, R.NodeExtension.with_error(B.extension(w, id), B.second(R.World, R.Value, pair))))

def setPendingError(+w: R.World, +id: Nat, +source: Nat, +error: R.Value) -> R.World:
  B.choose(~R.World, Nat.is_eq(source, 0n),
    _ => B.choose(~R.World, Nat.is_ne(R.Node.x(B.node(w, id)), 0n),
      _ => B.store_extension(w, id, R.NodeExtension.with_error(B.extension(w, id), R.Null{})), _ => w),
    _ => B.choose(~R.World, Bool.and(isNotReady(error), Nat.is_eq(notReadySource(error), source)),
      _ =>
        +w = E.ext(w, id)
        B.store_extension(w, id, R.NodeExtension.with_error(B.extension(w, id), error)),
      _ => preserveOrCreate(w, id, source, R.NodeExtension.error(B.extension(w, id)))))

# Loading-window park deliberately takes no status/propagation branch.
def parkLoadingWindow(+w: R.World, +id: Nat, +error: R.Value) -> R.World:
  +w = E.ext(w, id)
  +w = B.store_extension(w, id, R.NodeExtension.with_blocked(B.extension(w, id), R.Present{R.Boolean{True{}}}))
  +source = notReadySource(error)
  +w = B.choose(~R.World, Nat.is_ne(source, 0n), _ => B.first(R.World, Bool, addPendingSource(w, id, source)), _ => w)
  B.choose(~R.World, B.has(R.Node.status(B.node(w, id)), K.STATUS_ERROR()), _ => w,
    _ => setPendingError(w, id, source, error))

# async.ts:retryReaches scans the FULL retained dependency list.
def retryLoop(fuel: Nat, +w: R.World, +edge: Nat, +source: Nat) -> B.Bundle<R.World, Bool>:
  match fuel:
    case 0n:
      B.Bundle{B.choose(~R.World, Nat.is_eq(edge, 0n), _ => w, _ => R.World.with_fault(w, R.Exhausted{})), False{}}
    case 1n+p:
      B.choose(~B.Bundle<R.World, Bool>, Nat.is_eq(edge, 0n), _ => B.Bundle{w, False{}},
        _ =>
          +dep = R.Link.dep(B.link(w, edge))
          B.choose(~B.Bundle<R.World, Bool>, Bool.or(Nat.is_eq(dep, source), hasSource(w, dep, source)),
            _ => B.Bundle{w, True{}}, _ => retryLoop(p, w, R.Link.nextDep(B.link(w, edge)), source)))

def retryReaches(+w: R.World, +id: Nat, source: Nat) -> B.Bundle<R.World, Bool>:
  retryLoop(B.budget(w), w, R.Node.deps(B.node(w, id)), source)
