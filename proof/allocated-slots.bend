# Generic allocated record slots. Layout certificates supply real membership;
# blank fallbacks/out-of-range stores are not treated as allocations.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./arena.bend as Arena
import ./extension-laws.bend as Extensions

def transaction(+w: R.World, +before: List<&2, R.Transaction>, +record: R.Transaction, +after: List<&2, R.Transaction>,
  storage: {R.World.txArena(w) == B.append(R.Transaction, before, record <> after) : List<&2, R.Transaction>}) ->
  {B.transaction(w, B.length(R.Transaction, before)) == record : R.Transaction}:
  Equal.trans(R.Transaction, B.transaction(w, B.length(R.Transaction, before)), B.get(R.Transaction, B.append(R.Transaction, before, record <> after), B.length(R.Transaction, before), B.blank_transaction()), record,
    Equal.cong(List<&2, R.Transaction>, R.Transaction, values => B.get(R.Transaction, values, B.length(R.Transaction, before), B.blank_transaction()), R.World.txArena(w), B.append(R.Transaction, before, record <> after), storage), Arena.getPrefix(R.Transaction, before, record, after, B.blank_transaction()))

def putTransaction(+w: R.World, +before: List<&2, R.Transaction>, +record: R.Transaction, +after: List<&2, R.Transaction>, +next: R.Transaction,
  storage: {R.World.txArena(w) == B.append(R.Transaction, before, record <> after) : List<&2, R.Transaction>}) ->
  {B.store_transaction(w, B.length(R.Transaction, before), next) == R.World.with_txArena(w, B.append(R.Transaction, before, next <> after)) : R.World}:
  Equal.cong(List<&2, R.Transaction>, R.World, values => R.World.with_txArena(w, values), List.set(&2, R.Transaction, R.World.txArena(w), B.length(R.Transaction, before), next), B.append(R.Transaction, before, next <> after),
    Equal.trans(List<&2, R.Transaction>, List.set(&2, R.Transaction, R.World.txArena(w), B.length(R.Transaction, before), next), List.set(&2, R.Transaction, B.append(R.Transaction, before, record <> after), B.length(R.Transaction, before), next), B.append(R.Transaction, before, next <> after),
      Equal.cong(List<&2, R.Transaction>, List<&2, R.Transaction>, values => List.set(&2, R.Transaction, values, B.length(R.Transaction, before), next), R.World.txArena(w), B.append(R.Transaction, before, record <> after), storage), Arena.setPrefix(R.Transaction, before, record, after, next)))

def extension(+w: R.World, +id: Nat, +before: List<&2, R.NodeExtension>, +record: R.NodeExtension, +after: List<&2, R.NodeExtension>,
  index: {R.Node.x(B.node(w, id)) == B.length(R.NodeExtension, before) : Nat},
  storage: {R.World.extensions(w) == B.append(R.NodeExtension, before, record <> after) : List<&2, R.NodeExtension>}) ->
  {B.extension(w, id) == record : R.NodeExtension}:
  Equal.trans(R.NodeExtension, B.extension(w, id), B.get(R.NodeExtension, B.append(R.NodeExtension, before, record <> after), B.length(R.NodeExtension, before), B.blank_extension()), record,
    Extensions.readKnown(w, id, B.length(R.NodeExtension, before), B.append(R.NodeExtension, before, record <> after), index, storage), Arena.getPrefix(R.NodeExtension, before, record, after, B.blank_extension()))

def putExtension(+w: R.World, +id: Nat, +before: List<&2, R.NodeExtension>, +record: R.NodeExtension, +after: List<&2, R.NodeExtension>, +next: R.NodeExtension,
  index: {R.Node.x(B.node(w, id)) == B.length(R.NodeExtension, before) : Nat},
  storage: {R.World.extensions(w) == B.append(R.NodeExtension, before, record <> after) : List<&2, R.NodeExtension>}) ->
  {B.store_extension(w, id, next) == R.World.with_extensions(w, B.append(R.NodeExtension, before, next <> after)) : R.World}:
  Equal.trans(R.World, B.store_extension(w, id, next), R.World.with_extensions(w, List.set(&2, R.NodeExtension, R.World.extensions(w), B.length(R.NodeExtension, before), next)), R.World.with_extensions(w, B.append(R.NodeExtension, before, next <> after)),
    Equal.cong(Nat, R.World, slot => R.World.with_extensions(w, List.set(&2, R.NodeExtension, R.World.extensions(w), slot, next)), R.Node.x(B.node(w, id)), B.length(R.NodeExtension, before), index),
    Equal.cong(List<&2, R.NodeExtension>, R.World, values => R.World.with_extensions(w, values), List.set(&2, R.NodeExtension, R.World.extensions(w), B.length(R.NodeExtension, before), next), B.append(R.NodeExtension, before, next <> after),
      Equal.trans(List<&2, R.NodeExtension>, List.set(&2, R.NodeExtension, R.World.extensions(w), B.length(R.NodeExtension, before), next), List.set(&2, R.NodeExtension, B.append(R.NodeExtension, before, record <> after), B.length(R.NodeExtension, before), next), B.append(R.NodeExtension, before, next <> after),
        Equal.cong(List<&2, R.NodeExtension>, List<&2, R.NodeExtension>, values => List.set(&2, R.NodeExtension, values, B.length(R.NodeExtension, before), next), R.World.extensions(w), B.append(R.NodeExtension, before, record <> after), storage), Arena.setPrefix(R.NodeExtension, before, record, after, next))))
