# A complete concrete public-API cleanup lifecycle, using the executable Bend
# consumer itself: commit an initial answer, start a replacement, reject it.
# This closes one program; arbitrary payload/graph/history domains remain open.
import Base
import ../examples/async-cleanup.bend as Example
import ../representation/records.bend as R

def replacement_error_releases_displayed_frame() ->
  {Example.main() == Example.CleanupTiming{0n, 0n, 1n, R.Healthy{}} : Example.CleanupTiming}:
  {==}
