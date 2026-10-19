# core/context.ts production createContext/getContext/setContext.
# Fresh key IDs represent Symbol identity; immutable record IDs represent the
# spread-created objects. Existing children keep their inherited record ID.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B


def undefined(value: R.Value) -> Bool:
  match value:
    case R.Undefined{}:
      True{}
    case _:
      False{}

def key(w: R.World, id: Nat) -> R.ContextKey:
  B.get(R.ContextKey, R.World.contextKeys(w), id, R.ContextKey{R.Undefined{}, R.Empty{}})

def record(w: R.World, id: Nat) -> R.ContextRecord:
  B.get(R.ContextRecord, R.World.contextRecords(w), id, R.ContextRecord{[]})

def lookup(entries: List<&2, R.ContextEntry>, +id: Nat) -> R.Value:
  match entries:
    case Nil{}:
      R.Undefined{}
    case +entry <> rest:
      B.choose(~R.Value, Nat.is_eq(R.ContextEntry.key(entry), id),
        _ => R.ContextEntry.value(entry), _ => lookup(rest, id))

# Spread copies each own symbol-keyed entry; replacement retains key order.
def copyWith(entries: List<&2, R.ContextEntry>, +id: Nat, +value: R.Value) -> List<&2, R.ContextEntry>:
  match entries:
    case Nil{}:
      [R.ContextEntry{id, value}]
    case +entry <> +rest:
      B.choose(~List<&2, R.ContextEntry>, Nat.is_eq(R.ContextEntry.key(entry), id),
        _ => R.ContextEntry{id, value} <> rest,
        _ => entry <> copyWith(rest, id, value))


def createContext(+w: R.World, defaultValue: R.Value, description: R.Slot) -> R.World:
  R.World.with_contextKeys(w, B.append(R.ContextKey, R.World.contextKeys(w), [R.ContextKey{defaultValue, description}]))

# error.ts NoOwnerError / ContextNotFoundError production constructors. Both
# have Error's default name and the empty message; each throw is a fresh Error.
def failure(+w: R.World, kind: U32) -> R.World:
  +serial = Nat.add(1n, R.World.errorSerial(w))
  R.World.with_fault(R.World.with_errorSerial(w, serial), R.CallbackThrown{R.ContextFailure{serial, kind}})


def getContext(+w: R.World, +id: Nat, +owner: Nat) -> B.Bundle<R.World, R.Value>:
  B.choose(~B.Bundle<R.World, R.Value>, Nat.is_eq(owner, 0n),
    _ => B.Bundle{failure(w, 0), R.Undefined{}},
    _ =>
      +value = lookup(R.ContextRecord.entries(record(w, R.Node.scope(B.node(w, owner)))), id)
      +value = B.choose(~R.Value, undefined(value), _ => R.ContextKey.defaultValue(key(w, id)), _ => value)
      B.choose(~B.Bundle<R.World, R.Value>, undefined(value),
        _ => B.Bundle{failure(w, 1), R.Undefined{}}, _ => B.Bundle{w, value}))


def setContext(+w: R.World, +id: Nat, +value: R.Value, +owner: Nat) -> R.World:
  B.choose(~R.World, Nat.is_eq(owner, 0n), _ => failure(w, 0),
    _ =>
      +entries = R.ContextRecord.entries(record(w, R.Node.scope(B.node(w, owner))))
      +value = B.choose(~R.Value, undefined(value), _ => R.ContextKey.defaultValue(key(w, id)), _ => value)
      +next = B.length(R.ContextRecord, R.World.contextRecords(w))
      +w = R.World.with_contextRecords(w, B.append(R.ContextRecord, R.World.contextRecords(w), [R.ContextRecord{copyWith(entries, id, value)}]))
      B.store_node(w, owner, R.Node.with_scope(B.node(w, owner), next)))
