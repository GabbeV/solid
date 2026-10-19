import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/error.bend as E

def original(kind: U32, n: Nat, text: String, message: String, native: Bool) -> R.Value:
  match kind:
    case 0:
      R.Undefined{}
    case 1:
      R.Null{}
    case 2:
      R.Boolean{Nat.is_ne(n, 0n)}
    case 3:
      R.Number{n}
    case 4:
      R.NotANumber{}
    case 5:
      R.StringValue{text}
    case 6:
      R.Reference{1n}
    case 7:
      R.AsyncValue{1n}
    case 8:
      R.StatusFailure{1n, 7n, R.Number{99n}, message}
    case 9:
      R.NotReadyFailure{1n, 7n}
    case 10:
      R.TimeoutFailure{1n}
    case _:
      R.ExternalError{1n, True{}, 0, text, message, native, 0n}

def wrap(+kind: U32, n: Nat, text: String, message: String, native: Bool) -> R.Value:
  +w = R.World.with_errorSerial(B.empty(), 1n)
  B.second(R.World, R.Value, E.statusError(w, 3n, original(kind, n, text, message, native)))

def unwrapped(kind: U32, n: Nat, text: String, message: String, native: Bool) -> R.Value:
  E.unwrapStatusError(original(kind, n, text, message, native))
