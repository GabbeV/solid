# Native Promise allocation/settlement used by from's iterator closures.
# Callbacks remain queued host jobs; this boundary makes no reactive decisions.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B

def allocate(+w: R.World, state: R.AsyncSettlement) -> B.Bundle<R.World, Nat>:
  +id = B.length(R.AsyncObject, R.World.asyncObjects(w))
  B.Bundle{R.World.with_asyncObjects(w, B.append(R.AsyncObject, R.World.asyncObjects(w), [R.AsyncObject{False{}, state, [], 0n}])), id}

def deliveries(observers: List<&2, Nat>, +w: R.World, +rejected: Bool, +value: R.Value) -> R.World:
  match observers:
    case Nil{}: w
    case observer <> tail:
      deliveries(tail, R.World.with_hostJobs(w, B.append(R.HostJob, R.World.hostJobs(w), [R.DeliveryJob{observer, rejected, value}])), rejected, value)

def settleState(+w: R.World, +id: Nat, +rejected: Bool, +value: R.Value, +object: R.AsyncObject, state: R.AsyncSettlement) -> R.World:
  match state:
    case R.Unresolved{}:
      +w = B.store_asyncObject(w, id, R.AsyncObject.with_state(object, B.choose(~R.AsyncSettlement, rejected, _ => R.Rejected{value}, _ => R.Fulfilled{value})))
      deliveries(R.AsyncObject.observers(object), w, rejected, value)
    case _: w

def settle(+w: R.World, +id: Nat, rejected: Bool, value: R.Value) -> R.World:
  +object = B.asyncObject(w, id)
  settleState(w, id, rejected, value, object, R.AsyncObject.state(object))
