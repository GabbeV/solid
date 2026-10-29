# Actual extension/list/holdNode preserve committed values, tree and trace.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/extension.bend as E
import ../runtime/transaction.bend as X
import ../runtime/constants.bend as K
import ../proof/committed-storage-frame.bend as Frame
import ../proof/pending-source-committed-frame.bend as Extension

def list(+w: R.World,+id: Nat,+tx: Nat) -> {Frame.observe(X.list(w,id,tx)) == Frame.observe(w) : Frame.View}:
  +next = E.ext(w,id)
  +x = R.NodeExtension.with_transaction(B.extension(next,id),tx)
  +captured = B.store_extension(next,id,x)
  +record = R.Transaction.with_nodes(B.transaction(captured,tx),B.append(Nat,R.Transaction.nodes(B.transaction(captured,tx)),[id]))
  +stored = B.store_transaction(captured,tx,record)
  +branch = Frame.choice(Nat.is_eq(R.NodeExtension.transaction(B.extension(next,id)),tx),next,next,stored,{==},Frame.compose(next,captured,stored,Frame.storeTransaction(captured,tx,record),Frame.storeExtension(next,id,x)))
  Frame.compose(w,next,X.list(w,id,tx),branch,Extension.ext(w,id))

def node(+w: R.World,+id: Nat,+tx: Nat) -> {Frame.observe(X.holdNode(w,id,tx)) == Frame.observe(w) : Frame.View}:
  +bits = B.set(R.Node.config(B.node(w,id)),K.CONFIG_HELD())
  +next = B.store_node(w,id,R.Node.with_config(B.node(w,id),bits))
  Frame.compose(w,next,X.holdNode(w,id,tx),list(next,id,tx),Frame.config(w,id,bits))
