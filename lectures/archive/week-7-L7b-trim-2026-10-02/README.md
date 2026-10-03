# L7b before the October 2 trim

On October 2, 2026 the instructor trimmed L7b (October 8) to utility-based
allocation with two examples, because class time covers two, at most three,
examples. This snapshot preserves the L7b material as it stood before the trim.
It was uncommitted work from the October 1 Week 7 pivot, so `SHA256SUMS` records
the files rather than a source commit.

| File | Status after the trim |
| --- | --- |
| `CHEME-5660-L7b-Example-Portfolio-Drift-Fall-2026.ipynb` | Removed from L7b. |
| `CHEME-5660-L7b-Example-Adaptive-Rebalancing-Scorecard-Fall-2026.ipynb` | Removed from L7b. |
| `figs/` rebalancing-engine figure and its build files | Removed from L7b. |
| `CHEME-5660-L7b-Lecture-Utility-Allocation-Rebalancing-Fall-2026.ipynb` | Pre-trim lecture. The live lecture dropped drift, the rebalancing engine, the elasticity rule, and the realized-path scorecard, and added mean-variance utility on the capital allocation line. |
| `CHEME-5660-L7b-Example-Utility-Allocator-Fall-2026.ipynb` | Pre-trim allocator. The live copy has three tasks and no engine references. |
| `advanced/` CES companion and index | Pre-trim companion. The live copy dropped the elasticity-rule section. |
| `Include.jl` | Setup file the archived examples load. |
| `slides/` | The 24-page pre-trim deck (source, PDF, Makefile). The live deck was rebuilt to match the trimmed lecture. |

The instructor asked that cut material not be moved into a later week, because
later weeks may change. Relative links in these notebooks assume their original
location. To reuse one, restore it to `lectures/week-7/L7b/` rather than editing
it here. Do not rewrite this archival payload.
