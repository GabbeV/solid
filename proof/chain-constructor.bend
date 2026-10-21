# Closed constructor boundary; numeric proposal becomes symbolic only later.
import Base
import ../proof/chain.bend as Chain
import ../representation/records.bend as R
import ./chain-states.bend as M

def constructed() -> {Chain.initial() == M.origin() : R.World}:
  {==}
