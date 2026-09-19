# Week 5 natural-language pass — September 19, 2026

The instructor requested a review of all active Week 5 materials for small
wording changes that improve the natural tone. This followed his preference
for “We estimate the volatility parameter…” and his objection to omitted words
that made tightened prose less natural.

This was an authorized wording pass, not another scored notebook-polish round.
Existing reviews remain closed. Their scores and hashes describe the snapshots
saved in those records; this record describes the subsequent wording changes.

## Scope and changes

Reviewed all 40 active `.ipynb`, `.tex`, `.md`, and `.jl` files under
`lectures/week-5`: 12 notebooks, two companion slide sources, the indexes and
helper references, and Julia comments/docstrings. Archived Week 5 material was
outside the scope.

Applied 63 localized replacements in 19 source files: 12 notebooks, two slide
sources, two helper references, and three Julia docstrings. Rebuilt both slide
PDFs. Changes restore articles and verbs, identify quantities in tables, and
make units descriptions read as complete sentences. For example:

- “column 2 its exceedance probability” became “column 2 contains the
  probability of exceeding it.”
- “We estimate volatility…” became “We estimate the volatility parameter…”
  where the sentence introduces the parameter estimate.
- “changes from frozen” became “changes relative to the frozen model.”
- “`dt` is years per interval” became “`dt` is measured in years per interval.”

The L5b lecture repeated the older risk explanation that the instructor found
confusing in L5a. It now uses the exact approved L5a bullet: estimate the
volatility parameter from the observed growth-rate standard deviation adjusted
for the time step, followed by the units of both quantities.

The short EMA Task 2 remains short. No numerical timeline, deleted forecasting
paragraph, or rejected score interpretation was restored. Ordinary headings,
table labels, and concise code comments were preserved. The notebook Markdown
grew by 123 whitespace-delimited words, from 28,530 to 28,653 (about 0.4%).

## Verification

- All 12 notebooks validate against nbformat. Every code cell, saved output,
  execution count, cell ID, and metadata field is unchanged. Headings, horizontal
  rules, and link targets are preserved. Each notebook retains three learning
  objectives and three key takeaways.
- All 129 displayed equations are unchanged and render with the installed
  VS Code notebook math renderer. Inline mathematics is also unchanged except
  for the approved L5a risk explanation copied into L5b, including its units.
  A second Markdown renderer gives the same results before and after this pass;
  its existing display-delimiter findings in older cells were not introduced by
  these edits. Neither renderer reports a KaTeX error.
- Fourteen notebook sections were captured in an isolated local browser.
  Representative wording and mathematical context were inspected visually,
  including EMA Tasks 2–3 and L5b's parameter panel. The captures have no
  horizontal overflow or math errors.
- Julia source differences are confined to docstrings; removing docstrings
  leaves byte-identical source. No numerical rerun was needed for these edits.
- Both companion decks rebuild at their existing lengths: L5a has 18 pages
  and L5b has 37. Equations and frame structure are preserved. All nine pages
  with changed text were rendered and visually checked. Neither build reports
  an overfull or underfull box. Existing font/package warnings remain.
- `git diff --check` passes. Pre-existing work was preserved. No commit, push,
  release, or student-bundle rebuild was performed.

The local evidence is in
`build/notebook-previews/week-5-natural-language-2026-09-19/`: baseline copies,
the exact before/after replacements, preservation and render reports, notebook
captures, and slide comparisons.

## Separate observations

The active L5a advanced index still contains copied L4b navigation and descriptions,
including local paths for the lattice-limit and first-passage notebooks that
do not exist under L5a. The copied drift-uncertainty notebook also retains L4b
prerequisite paths relative to its former location. The L5b advanced index's
rolling-correlation description still says “the whole universe,” while the
reviewed notebook uses a fixed subset. These pre-existing navigation/description
issues were noted during the reading; they were not part of this wording pass.

## Current notebook hashes

The table below identifies the snapshots after this pass.

| Notebook | SHA-256 |
| --- | --- |
| [CHEME-5660-L5a-Example-EMA-SAGBM-Fall-2026.ipynb](../week-5/L5a/CHEME-5660-L5a-Example-EMA-SAGBM-Fall-2026.ipynb) | `ccf029f72f7456a56e0fd0c653e02ae5ffeb621e5a46a25e6a3c7015857effa5` |
| [CHEME-5660-L5a-Example-GBM-NPV-TradeRule-Fall-2026.ipynb](../week-5/L5a/CHEME-5660-L5a-Example-GBM-NPV-TradeRule-Fall-2026.ipynb) | `60a147e1f9306d1e30d78ac6d986b6948ccb75269593a4aa093bedf363c77953` |
| [CHEME-5660-L5a-Example-OOS-SAGBM-Fall-2026.ipynb](../week-5/L5a/CHEME-5660-L5a-Example-OOS-SAGBM-Fall-2026.ipynb) | `ea724be9aa624611479214de04b8beac3ce04b36c8b48d153ddb8daaca701720` |
| [CHEME-5660-L5a-Lecture-SAGBM-NPV-Fall-2026.ipynb](../week-5/L5a/CHEME-5660-L5a-Lecture-SAGBM-NPV-Fall-2026.ipynb) | `5e04a16f4bfb4c0896edb755fa248dbbd5e15c60bfc0a42cc8db072fc490c3b2` |
| [CHEME-5660-L4b-Advanced-DriftUncertainty-Fall-2026.ipynb](../week-5/L5a/advanced/drift-uncertainty/CHEME-5660-L4b-Advanced-DriftUncertainty-Fall-2026.ipynb) | `fa6615d21566168c70bb8665eb8c94708eb605c168e98bd11a69166f7a1e58a3` |
| [CHEME-5660-L5a-Derivation-EMA-SAGBM-Fall-2026.ipynb](../week-5/L5a/advanced/ema-derivation/CHEME-5660-L5a-Derivation-EMA-SAGBM-Fall-2026.ipynb) | `05fb62aac15384665295a6081c1cf3612bf452c5c13f52274bd3d753a265a994` |
| [CHEME-5660-L4b-Advanced-MonteCarlo-TargetProbability-Fall-2026.ipynb](../week-5/L5a/advanced/monte-carlo/CHEME-5660-L4b-Advanced-MonteCarlo-TargetProbability-Fall-2026.ipynb) | `81668fc6a5d3a51086b8c5acae70ac6f25f999fe6c2fc434906928abba64d8f0` |
| [CHEME-5660-L5b-Example-CovarianceMatrix-Fall-2026.ipynb](../week-5/L5b/CHEME-5660-L5b-Example-CovarianceMatrix-Fall-2026.ipynb) | `3924410afc26128d5111060884409c351cbe5c5b8dbb6def72b9739c214ae851` |
| [CHEME-5660-L5b-Example-Dirichlet-PortfolioWeights-Fall-2026.ipynb](../week-5/L5b/CHEME-5660-L5b-Example-Dirichlet-PortfolioWeights-Fall-2026.ipynb) | `16832d432bdfae1cc77f1624bb4956486f1d1cd3ab8dd810547a062ba705bfa4` |
| [CHEME-5660-L5b-Lecture-MultipleAsset-GBM-Fall-2026.ipynb](../week-5/L5b/CHEME-5660-L5b-Lecture-MultipleAsset-GBM-Fall-2026.ipynb) | `7bc42e57f47909ce28e4599884748a56eddea4950b44031343d04115cf5d86d9` |
| [CHEME-5660-L5b-Advanced-CovarianceEstimation-Fall-2026.ipynb](../week-5/L5b/advanced/covariance-estimation/CHEME-5660-L5b-Advanced-CovarianceEstimation-Fall-2026.ipynb) | `29676c26b95c89c245886d6226957e7e319297ff06580f6c7fbd77016a55e08f` |
| [CHEME-5660-L5b-Advanced-RollingCorrelation-Fall-2026.ipynb](../week-5/L5b/advanced/rolling-correlation/CHEME-5660-L5b-Advanced-RollingCorrelation-Fall-2026.ipynb) | `c9417f0f122162db6541a4cccb2d23e888b6bd1d546d006543aac7604f9f2bbb` |
