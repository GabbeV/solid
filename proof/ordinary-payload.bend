# Proof-only classification of ordinary data already represented by R.Value.
# No runtime representation or evaluator is introduced. Functions, asynchronous
# protocols, internal sentinels and arena-dependent handles are separate domains.
import Base
import ../representation/records.bend as R

type Ordinary is Data:
  DataUndefined{}
  DataNull{}
  DataBoolean{value: Bool}
  DataNatural{value: Nat}
  DataNegativeZero{}
  DataNaN{}
  DataString{value: String}
  DataReference{identity: Nat}

def value(payload: Ordinary) -> R.Value:
  match payload:
    case DataUndefined{}: R.Undefined{}
    case DataNull{}: R.Null{}
    case DataBoolean{value}: R.Boolean{value}
    case DataNatural{value}: R.Number{value}
    case DataNegativeZero{}: R.NegativeZero{}
    case DataNaN{}: R.NotANumber{}
    case DataString{value}: R.StringValue{value}
    case DataReference{identity}: R.Reference{identity}
