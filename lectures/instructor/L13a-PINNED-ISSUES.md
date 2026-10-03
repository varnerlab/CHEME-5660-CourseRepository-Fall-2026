# L13a pinned issues — October 3, 2026

On October 3 the instructor paused work on L13a: "this is too far away, we may not
be doing this material there." Do not edit week-13 files until he reopens it. This
note records what was changed and what is still open.

## Changed on October 3 (uncommitted, in the working tree)

Approved from rendered previews in `build/notebook-previews/cobb-douglas-2026-10-02/`
(`p2.png`, `p3.png`):

- **L13a lecture, cell 5.** Two sentences under the κ definition: the shares come
  from the closed form, and κ applies only to the utility value. An asset with
  γ < 0 at a floor ε < 1 contributes ε^γ > 1.
- **Advanced bandit notebook (`advanced/bandits/...-Bandit-MWA-PortfolioManagers-...`),
  cell 4.** An August 3 commit (`04ae0fc`) had removed the floors and κ and replaced
  the tanh SIM preference model with an always-positive softplus model. The 2025
  L14a text is restored, with the κ reason, the β_i > 0 assumption that L7b states,
  and its clause semicolons removed.

To undo the advanced-notebook change, run `git checkout HEAD -- <path>`. The lecture
notebook also carries an uncommitted October 2 link edit (the CES-companion link),
so restore only cell 5 there, not the whole file.

## Open

1. **κ inside the optimization.** The advanced notebook's boxed problem reads
   "maximize κ(γ)∏ n_i^γ_i", as in 2025 and the paper. Read literally, κ = −1 flips
   the optimization. The instructor's code applies κ only to the reward. Decide
   whether to move κ into the reward definition.
2. **Wording of the new κ sentences (proposed, not applied).** "Would earn a higher
   utility" overstates the effect, because paying for the floor also shrinks the
   other holdings. The proposed splits are in `round2.png`: "Without κ = −1, holding
   it can inflate a basket's utility" (lecture) and "…the bandit could favor
   baskets…" (advanced).
3. **Assets with γ_i = 0.** The 2025 sets use S₊ = {γ > 0} and S₋ = {γ < 0}, so an
   asset with exactly zero is in neither. The 2025 `world` function gives it zero
   shares, below the floor. L7b puts γ = 0 in 𝒜⁻.
4. **Selected set.** In the advanced notebook, S₊ and S₋ are not intersected with
   the bandit's selected set S, and holdings outside S are not specified.
5. **Preferred floors can bind.** This is the same condition as the open L7b item:
   the closed form assumes every preferred share count stays above ε.
6. **Notation.** L13a uses the eCornell symbols (B, P_i, ε, λ_t). L7b uses W_P(t),
   S_i(t), n_min, and ξ_t. Align them if the material stays in L13a.
7. **Duplicate sentence.** "Let's now look at an example of a combinatorial bandit
   problem…" appears twice in advanced cell 4. This predates October 3.
8. **Phrase flagged by Codex.** The lecture's cell 5 says "proportional to its
   exponent γ_i directly (not raised to a power)". It may be a denial nobody
   proposed, or a fair contrast with CES.
9. **Notebook validation.** The lecture notebook fails nbformat validation because
   of cell `id` fields at `nbformat_minor` 4. This predates October 3.
10. **Stale reference (from the October 2 trim).** `docs/Notes.tex` links the old L7b
    filename and says that L7b introduces the rebalancing engine.
