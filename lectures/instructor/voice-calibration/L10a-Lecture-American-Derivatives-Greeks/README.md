# L10a lecture, before the instructor's hand edits

- Source: `lectures/week-10/L10a/CHEME-5660-L10a-Lecture-American-Derivatives-Greeks-Fall-2026.ipynb`
- Copied from commit `ec10c27` on October 16, 2026, after L9b's intrinsic and
  extrinsic value section moved here. The first copy was `43e9c8c` (October 12).
  Between the two copies, `9eda452` changed only example and advanced link
  sentences, and the instructor had not edited the lecture.
- State: the lecture rebuilt from the 2025 L11a text and approved by the
  instructor on October 12, with the company profile's connection paragraph
  shortened at his request. The decisions and the list of new sentences are in
  `lectures/instructor/L10a-REBUILD-HANDOFF.md`.

When the round is done, the edited notebook is compared with `before.ipynb`.

New with the move (ec10c27): the section is his L9b text, word for word, and
replaces the Concept Review. The L9b objective "Decompose option premiums into
components" and the takeaway "Intrinsic and extrinsic value tell different
stories" come with it. The new takeaway also has his L9b sentence on time, volatility, and
moneyness. The merged label "Interpret Delta and compute the probabilities of
exercise and profit", its last sentence, the POP sentence in the Delta
takeaway, and the Summary opener's "splits the premium of an American option
into intrinsic and extrinsic value" are new.

October 20, 2026, Claude's (his "Agree" to moving Longstaff–Schwartz here from
L9b): the new cell `l10a-lsm` (his approved L9b section, with "risk-neutral
measure" changed to "risk-neutral pricing rule"), the Longstaff–Schwartz example
entry, the merged first objective and first takeaway, the title's "Monte Carlo
Pricing and", the Summary opener's "prices American options by Monte Carlo
simulation,", and the lecture-number fixes in the opener and three body
sentences. Exclude them from the diff.

Same day, Claude's, after a scoring round and at his request: the opener ("Previously,
we priced American options on a CRR tree, and duration and convexity measured how a
bond's price moves with its yield. Can simulation price them, and how much ..."),
the first takeaway label "Estimating and decomposing the American premium", "We
compute the American premium" in the Greeks section, and the extrinsic-value example
moved to "review on your own". Exclude them from the diff.
Round 2 (same day, Claude's): the opener split into two questions ("Previously, we
priced American options on a CRR tree. Can simulation price them? Duration and
convexity measured ...") and "Let's look at some option contracts in the market ..."
moved below the review-on-your-own box. Exclude them from the diff.
