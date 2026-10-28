# From body return through queued output work

The prior delivery theorem ended at returned-body output handling with an exact
source/control frame. This extension classifies the actual output Machine: the
caller task list and saved values remain exact, with either no task prefix or one
non-immediate `DeliverObservers` prefix. Fulfillment, rejection, already-settled
results and typed thenable adoption are covered for every represented `R.Value`.
Adoption leaves its host request pending while retaining the caller continuation.
It does not wait for that Promise before reaching the action slice end.

The actual non-immediate observer loop appends host delivery requests in source
registration order; it does not execute those callbacks inline. An arbitrary
finite observer list supplies the exact `1 + length` core-step bound. A checked
queue certificate derives that bound and drains the actual output prefix to the
original caller tasks/values. Its full World frame masks only host jobs, retaining
source values, action waits, transaction counts and async-result state.

`held-delivery-output-entry` composes actual ordinary first lookup/mark, captured
alias preparation, real supported setter body, return and output classification.
The initial source/capture/route/method/count/lookup facts derive the body result's
health and successful prefix drain; no healthy result or continuation shape is
assumed afterward. The resulting task starts with the actual `ActionSliceEnd`,
with the caller's saved question still queued for restoration.

Two slice contracts execute the actual core branches. A positive nested action
depth restores the saved question in two steps. A healthy outer slice with initial
zero depth, false running/halted flags and true scheduled flag queues the real
`Round` before question restoration, leaving the World and value stack unchanged
at that boundary. These scalar premises belong to this local slice contract;
the general constructor-to-Round composition is still being developed.

Five roots extend713 to718. The independent queue book checks in5.46s, body/output
entry and drain in12.42s and slice branches in5.09s, with unchanged400M checker
fuel,90s compact deadline and4GiB RSS. Final credit requires the full composed
verdict and exact tracked seal. The336 output-state controls include reversed
registration order,520 actual observer-prefix steps and8 pending adoptions.
There are24 slice-guard controls and1008 actual constructed body-to-queued-Round
checks; the preceding8064 duplicate controls are retained. Four source-changing
runtime faults compile and are rejected after mandatory unchanged kernel baselines.

Round execution, later host callbacks, full public invocation/parking and global
flight/publication accounting remain open. In particular, scheduling a Round is
not a proof that all pending work eventually renders.
