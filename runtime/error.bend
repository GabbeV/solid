# core/error.ts constructors and unwrapStatusError, for the admitted payload ABI.
# Native host Error/DOMException inputs retain identity and immutable property
# snapshots. Their instanceof Error result is an explicit host property input.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B

def errorString(+name: String, +message: String) -> String:
  B.choose(~String, String.is_empty(name), _ => message,
    _ => B.choose(~String, String.is_empty(message), _ => name,
      _ => String.append(name, String.append(": ", message))))

# ECMAScript String for the non-Error subset reaching StatusError's false arm.
# User coercion/getters/symbols and arbitrary objects are unfinished domains.
def stringify(value: R.Value) -> String:
  match value:
    case R.Undefined{}:
      "undefined"
    case R.Null{}:
      "null"
    case R.Boolean{b}:
      B.choose(~String, b, _ => "true", _ => "false")
    case R.Number{n}:
      Nat.show(n)
    case R.NotANumber{}:
      "NaN"
    case R.StringValue{s}:
      s
    case R.ContextFailure{identity, kind}:
      "Error"
    case R.RootDisposerReference{owner}:
      "function () { [native code] }"
    case R.AccessorReference{signal}:
      "function () { [native code] }"
    case R.SetterReference{signal}:
      "function () { [native code] }"
    case R.ExternalError{id, explicit, kind, name, message, native, code}:
      errorString(name, message)
    case _:
      "[object Object]"

# Source: original instanceof Error ? original.message : String(original).
# Capture now, before a wrapper is published or later decoded by the host.
def errorMessage(+original: R.Value) -> String:
  match original:
    case R.StatusFailure{identity, source, cause, message}:
      message
    case R.NotReadyFailure{identity, source}:
      ""
    case R.ContextFailure{identity, kind}:
      ""
    case R.TimeoutFailure{identity}:
      "Timed out waiting for condition"
    case R.ExternalError{id, explicit, kind, name, message, native, code}:
      B.choose(~String, native, _ => message, _ => errorString(name, message))
    case other:
      stringify(other)

def statusError(+w: R.World, source: Nat, +original: R.Value) -> B.Bundle<R.World, R.Value>:
  +serial = Nat.add(1n, R.World.errorSerial(w))
  +message = errorMessage(original)
  B.Bundle{R.World.with_errorSerial(w, serial), R.StatusFailure{serial, source, original, message}}

def unwrapStatusError(error: R.Value) -> R.Value:
  match error:
    case R.StatusFailure{identity, source, cause, message}:
      cause
    case other:
      other
