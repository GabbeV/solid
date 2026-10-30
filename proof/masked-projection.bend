# General projection transport across a proved state footprint. The two mask
# observations are pure identities; no desired post-state value is assumed.
import Base
import ../representation/records.bend as R

def transport(~A: Data,~view: R.World -> A,~mask: R.World -> R.World,+before: R.World,+after: R.World,same: {mask(after) == mask(before) : R.World},old: {view(mask(before)) == view(before) : A},next: {view(mask(after)) == view(after) : A}) -> {view(after) == view(before) : A}:
  Equal.trans(A,view(after),view(mask(after)),view(before),Equal.sym(A,view(mask(after)),view(after),next),Equal.trans(A,view(mask(after)),view(mask(before)),view(before),Equal.cong(R.World,A,w=>view(w),mask(after),mask(before),same),old))

# A run-time footprint index is passed separately from the closed template.
def transportAt(~A: Data,~Index: Data,~view: R.World -> A,~mask: R.World -> Index -> R.World,+index: Index,+before: R.World,+after: R.World,same: {mask(after,index) == mask(before,index) : R.World},old: {view(mask(before,index)) == view(before) : A},next: {view(mask(after,index)) == view(after) : A}) -> {view(after) == view(before) : A}:
  Equal.trans(A,view(after),view(mask(after,index)),view(before),Equal.sym(A,view(mask(after,index)),view(after),next),Equal.trans(A,view(mask(after,index)),view(mask(before,index)),view(before),Equal.cong(R.World,A,w=>view(w),mask(after,index),mask(before,index),same),old))
