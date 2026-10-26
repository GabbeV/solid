# signals.ts:onFlush, production branch. The host outbox is queueMicrotask;
# registration schedules first and does not capture a reactive owner.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B


def register(+w: R.World,body: R.Expr) -> R.World:
  +w = B.schedule(w)
  R.World.with_hostJobs(w,B.append(R.HostJob,R.World.hostJobs(w),[R.MicrotaskCallback{body}]))
