# IEEE signed-zero distinctions in the admitted scalar payload representation.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/error.bend as E

def strictZero(+n: Nat) ->
  {B.equal(R.NegativeZero{}, R.Number{n}) == Nat.is_eq(0n, n) : Bool}:
  {==}

def reverseStrictZero(+n: Nat) ->
  {B.equal(R.Number{n}, R.NegativeZero{}) == Nat.is_eq(n, 0n) : Bool}:
  {==}

def falseyZero() -> {B.truth(R.NegativeZero{}) == False{} : Bool}:
  {==}

def objectZero(+n: Nat) -> {B.objectIs(R.NegativeZero{}, R.Number{n}) == False{} : Bool}:
  {==}

def objectNaN() -> {B.objectIs(R.NotANumber{}, R.NotANumber{}) == True{} : Bool}:
  {==}

def addition(+n: Nat) -> {C.arithmetic(0, R.NegativeZero{}, R.Number{n}) == R.Number{n} : R.Value}:
  {==}

def multiplication(+n: Nat) -> {C.arithmetic(1, R.NegativeZero{}, R.Number{n}) == R.NegativeZero{} : R.Value}:
  {==}

def zeroMessage() -> {E.stringify(R.NegativeZero{}) == "0" : String}:
  {==}
