# Checked input certificate at the first controller boundary. Concrete raw
# construction is a separate factory; no assumptions/axioms inhabit this type.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./held-controller-data.bend as Data
import ./held-write-profile.bend as P
import ./held-preparation-source.bend as Source

type Ready<-w: R.World,-id: Nat,-methods: R.Expr> is Data:
  Constructed{arena: {R.World.txArena(w) == [B.blank_transaction(),Data.group(id)] : List<&2,R.Transaction>},actions: {R.World.actions(w) == [Data.first(methods)] : List<&2,R.ActionState>},profile: P.Profile<Source.flush(w,1n),id,0n>,cached: {R.NodeExtension.transaction(B.extension(w,id)) == 1n : Nat},empty: {R.World.flushTransaction(w) == 0n : Nat}}

def arena(-w: R.World,-id: Nat,-methods: R.Expr,ready: Ready<w,id,methods>) -> {R.World.txArena(w) == [B.blank_transaction(),Data.group(id)] : List<&2,R.Transaction>}:
  match ready:
    case Constructed{arena,actions,profile,cached,empty}: arena

def actions(-w: R.World,-id: Nat,-methods: R.Expr,ready: Ready<w,id,methods>) -> {R.World.actions(w) == [Data.first(methods)] : List<&2,R.ActionState>}:
  match ready:
    case Constructed{arena,actions,profile,cached,empty}: actions

def profile(-w: R.World,-id: Nat,-methods: R.Expr,ready: Ready<w,id,methods>) -> P.Profile<Source.flush(w,1n),id,0n>:
  match ready:
    case Constructed{arena,actions,profile,cached,empty}: profile

def cached(-w: R.World,-id: Nat,-methods: R.Expr,ready: Ready<w,id,methods>) -> {R.NodeExtension.transaction(B.extension(w,id)) == 1n : Nat}:
  match ready:
    case Constructed{arena,actions,profile,cached,empty}: cached

def empty(-w: R.World,-id: Nat,-methods: R.Expr,ready: Ready<w,id,methods>) -> {R.World.flushTransaction(w) == 0n : Nat}:
  match ready:
    case Constructed{arena,actions,profile,cached,empty}: empty
