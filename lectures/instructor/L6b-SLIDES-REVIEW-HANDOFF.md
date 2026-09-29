# L6b slides — sync with the lecture objectives, examples, and takeaways

**Status, September 28, 2026: marked reviewed by the instructor.** The deck was
synced to a same-day pass over the L6b lecture's learning objectives, example
descriptions, optional-advanced descriptions, and key takeaways. The instructor
approved the lecture text "as shown", asked for the deck sync with the bullets
tightened to fit, and then asked to mark the slides reviewed. No proposals remain
pending. Do not restart approved slides unless the instructor asks for another
round.

**Not yet committed.** The instructor deferred the commit until the four L6b
example notebooks have been reviewed (see `../week-6/L6b/tmp/L6b-EXAMPLES-REVIEW-HANDOFF.md`).
The lecture and deck edits sit in the working tree on top of `9ccb147`, together
with the instructor's own earlier hand edits to the lecture objectives.

## Snapshot

- Lecture: `../week-6/L6b/CHEME-5660-L6b-Lecture-SIM-Portfolio-RF-Fall-2026.ipynb`
  SHA-256: `9ce81850aed0855102648e426d44c53617198cd50decb05f8bd6d264e7a33359`.
- Slide source: `../week-6/L6b/slides/CHEME-5660-L6b-Slides-Fall-2026.tex`
  SHA-256: `8ff3877aefa60439f251ac04112133eb3b567b9a69adc3a4afdc2d516271a02c`.
- PDF: 27 pages, zero overfull boxes; SHA-256:
  `cb5e05f5cea62d306a96cf8af930511b64b0eebb4d4e7de62c6e6e78c35475ac`.

## Lecture pass (approved as shown)

- **Objectives:** the instructor's hand edits were kept. LO1 became two sentences
  and no longer calls the residual a parameter. LO3 says "the allocation problem"
  rather than "the model", with a clean verb series. LO2 is unchanged.
- **Examples list:** each description is now a question plus two sentences, the
  approved L6a shape. The risk-free example's old question ("How much should we
  put in the risky portfolio?") was replaced, because the example does not answer
  it; it now asks whether every growth target selects the same risky portfolio.
- **Callout and pointer in the risk-free section:** the callout names the
  rescaling that gives the tangent portfolio; the estimation-risk pointer says
  "GMV and tangent allocations", because that notebook uses sample inputs.
- **Optional Advanced Material:** each bullet is a question plus two sentences,
  checked against its notebook. The portfolio-uncertainty bullet names the
  unconstrained (shorts-allowed) GMV portfolio it holds fixed.
- **Key takeaways:** one per lecture section. KT1 adds the systematic and
  idiosyncratic split. KT2 adds the diversification result and names the SIM and
  data-driven portfolios, keeping "mainly" because the diagonals differ by the
  degrees-of-freedom factor. KT3 states two-fund separation as the lecture does:
  investors with the same inputs hold the same fund, and risk preferences set how
  much they lend or borrow.
- Word counts rose deliberately to the L6a norm: Examples 144 to 277, Advanced
  148 to 332, Key Takeaways 178 to 232. Codex checked every changed sentence
  against the lecture and the nine linked notebooks, twice.

## Deck sync

Five frames changed: Objectives (p. 3), Lectures and Examples (p. 4), The
Solutions Lie on a Ray (p. 24, estimation-risk pointer), Optional Advanced
Material (p. 25), and Summary (p. 26). Examples and advanced notebooks keep one
line each. Codex compared the deck text with the notebook and caught two
compression errors, both fixed: a fixed GMV portfolio's weights do not move (the
optimal weights do), and two-fund separation needs "with the same inputs".

After marking the deck reviewed, the instructor found the Summary slide too
long ("either trim some of the KTs or remove the bottom text line"). Both were
done: the L7 closing line was removed (the transition frame after it says what
comes next), and each takeaway was cut to three or four lines with wider item
spacing. The slide versions therefore differ from the notebook on purpose: KT1
drops "introduced factor models" and the CAPM/Fama–French mention; KT2 drops the
diversification sentence (the "Portfolio Risk under a SIM" slide carries it) and
shortens the mean-equality clause to "The means match"; KT3 says "lend or borrow
to set their risk" and "Financing limits can change the fund". The instructor
accepted the trimmed slide ("Agree."). Do not restore the notebook's full
takeaway text on this slide.

## Open items outside this review

- The estimation-risk advanced notebook links twice to `../frontier-geometry/`,
  which exists only under `L6a/advanced/`. Per the cross-week rule, refer to it in
  words.
