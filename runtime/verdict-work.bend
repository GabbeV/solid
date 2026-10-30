# core/verdict.ts:holdWork. Isolated to keep the source core/async/verdict cycle
# a leaf dependency in Bend. Both engines are installed in this public profile.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./constants.bend as K

def holdWork(+w: R.World,+node: Nat,source: Nat) -> Bool:
  Bool.and(B.has(R.Node.config(B.node(w,node)),K.CONFIG_ASYNC()),
    Bool.or(Bool.not(B.has(R.Node.status(B.node(w,node)),K.STATUS_PENDING())),
      Bool.or(R.Transaction.lane(B.transaction(w,R.NodeExtension.transaction(B.extension(w,node)))),B.has(R.Node.flags(B.node(w,source)),K.REACTIVE_REASK()))))
