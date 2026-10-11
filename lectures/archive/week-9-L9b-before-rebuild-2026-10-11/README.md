# L9b before the October 2026 rebuild

The August–September 2026 L9b drafts were rated about 5/10 on October 11, 2026. The
lecture had kept 2 of its 71 prose sentences from the instructor's Fall-2025 L10a and
L10b lectures. L9b was rebuilt from that 2025 text. The design is in
`lectures/instructor/L9b-REBUILD-SPEC.md`. This snapshot holds the files the rebuild
replaced, and `SHA256SUMS` records them.

| File | Status |
| --- | --- |
| `week-9/L9b/CHEME-5660-L9b-Lecture-American-Derivatives-Intrinsic-Extrinsic-Value-Fall-2026.ipynb` | Retired. The rebuilt lecture keeps this file name. Its "Three Value Differences" and "When Is the American Premium Strictly Higher?" sections were not taken (decision 4, Option A). |
| `week-9/L9b/slides/CHEME-5660-L9b-Slides-Fall-2026.tex` | The deck that mirrored the retired lecture. |
| `week-9/L9b/advanced/crr_factors/CHEME-5660-L9b-Advanced-CRR-Factors-Fall-2026.ipynb` | Retired. The rebuilt notebook keeps the instructor's 2025 origin-story derivation. |

The examples were edited in place, so their earlier versions are in git history. The
instructor asked that cut material not move into a later week. To reuse a file, move it
out with `git mv` rather than editing it here.
