# Stone–Geary utility: an idea for the share-floor problem

Saved October 3, 2026, at the instructor's request ("very interesting!"). Codex
raised it while we compared ways to state the L7b Cobb–Douglas share floor. L7b
uses the instructor's model with pin-and-solve (Option 2). This note records the
alternative for a future lecture, example, or advanced notebook.

## The problem it solves

The L7b model maximizes ∏ n_i^γ_i over every asset, subject to the budget and a
share floor n_i ≥ n_min. Its closed form assumes every preferred share count
stays above the floor. When one falls below (a barely preferred, expensive asset,
or most preferred assets in CES at high η), we pin it at the floor and solve
again. Dropping the floor on preferred assets (Option 3) keeps the closed form
exact, but then a preferred asset can end with fewer shares than a non-preferred
one. The instructor rejected that as strange.

## The idea

Stone–Geary utility (Geary 1950; Stone 1954, the linear expenditure system) values
consumption above a baseline, the "subsistence" quantity. Here, the baseline is
the share floor. Every asset first receives b_i shares. Non-preferred assets stay
there, and utility is defined over the preferred assets' excess holdings:

    U = ∏_{i∈A+} (n_i − b_i)^γ_i,    subject to Σ_i n_i S_i = W

With R = W − Σ_i b_i S_i > 0, the budget left after every baseline, the
maximizer is:

    Cobb–Douglas:  n_i = b_i + (γ_i / Σ_{A+} γ_j) · R / S_i
    CES:           n_i = b_i + R (γ_i/S_i)^η / Σ_{A+} S_j (γ_j/S_j)^η

## Properties

- The closed form is exact for every input. There is no floor check and no
  pin-and-solve, and the CES limits hold as stated (η → ∞ sends all of R to the
  largest γ_i/S_i).
- With a common share baseline b_i = n_min, a preferred asset always holds at
  least as many shares as a non-preferred one.
- A common dollar baseline b_i = d_min/S_i protects dollars instead. A non-preferred
  asset can then hold more shares, but never more dollars.
- It reads well in class: every asset gets the floor, and the preferences split
  what is left.
- It is a different utility, not the instructor's ∏ n_i^γ_i with constraints added.
  The allocation differs slightly on every day, because every preferred asset also
  gets b_i, and R subtracts the floors of all assets. Adopting it would mean
  changing the lecture model, the course package, and the examples.

## Related checks (October 3, 2026)

- Pin-and-solve is the exact optimum of the floor-on-every-asset problem for
  Cobb–Douglas and for CES at any η. The solution is
  n_i* = max{n_min, (γ_i/(λ S_i))^η}. Codex checked it against an independent
  solver on 1,000 random instances, η from 0.01 to 1000, with agreement within
  6 × 10⁻¹³.
- A share floor orders share counts only. Under any of these options, a
  non-preferred asset can hold more dollars than a weakly preferred cheap one.
