import Base
import ../runtime/api.bend as A
import ../representation/records.bend as R

def main() -> R.Value:
  w = A.createWorld()
  w = A.createSignal(w, R.Number{0n}, True{})
  w = A.createMemo(256n, w, R.Multiply{R.Add{R.Read{2n}, R.Literal{R.Number{1n}}}, R.Literal{R.Number{2n}}}, True{}, False{}, 1n)
  w = A.attach(w, 1n, 2n)
  w = A.createEffect(256n, w, R.Read{3n}, False{}, 2n, False{}, False{}, 1n)
  w = A.setSignal(w, 2n, R.Number{6n})
  w = A.flush(256n, w)
  A.displayed(w, 2n)
