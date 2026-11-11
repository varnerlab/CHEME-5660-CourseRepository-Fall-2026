# L12b rule-switch cache

`Compute-L12b-RuleSwitch-Cache.jl` runs the rule-switch experiment for the rules `BASELINE_RULE` and `SWITCH_RULE` set at
the top of the script and writes
`lectures/week-12/L12b/data/Cache-base-<BASELINE_RULE>-switch-<SWITCH_RULE>-L<L>.jld2`. Each pair of
rules and each grid size gets its own file. Since November 11 the RuleSwitch example runs every task live and no longer
loads these files. The script activates the
repo-root course environment itself and resolves its output path from its own location, so it can be run from any
directory.

## Full run (Jeff, big machine)

```
julia -t auto lectures/week-12/L12b/scripts/Compute-L12b-RuleSwitch-Cache.jl
```

Run it from the repo root. Defaults are the course settings (the paper's model with fewer seeds and the course's f grid): L = 64, seeds 1:20, f from 0.01 to 0.30 in steps of 0.005 (59 fractions),
three conditions (h = 100 hold, h = 100 endogenous, h = 1 endogenous), t_pre = 1000, t_post = 3000, a time step of one minute
(`DT = 1/(252*390)` years), and dealer noise with annualized volatility `SIGMA_S = 0.20`. Each pair is run by
`run_noisy_rule_switch` in `src/Helper.jl`; `SIGMA_S = 0.0` gives the paper's market with no noise. To change the rules, edit
`BASELINE_RULE` and `SWITCH_RULE` at the top of the script. To raise L, edit `L_FULL`. The output file has `settings.provisional == false`.

## Flags

- `--provisional`: L = 32, seeds 1:5, written to the `-L32` file name with `provisional = true`. The notebook shows this flag.
- `--smoke`: L = 24, seeds 1:2, t_pre = 50, t_post = 150, written to `Cache-base-<BASELINE_RULE>-switch-<SWITCH_RULE>-L24-smoke.jld2` (never overwrites the
  full file; do not commit it).

## Runtime

Measured on the 10-thread development machine (`julia -t 10`), excluding package load:

| Run | Work | Wall time |
|---|---|---|
| `--smoke` | 6 items, L = 24, 200 steps | 1.0 s |
| `--provisional` | 15 items, L = 32, 4000 steps | 4.4 s |

Cost scales as L^2 x (number of seeds) x steps. Relative to the provisional run, the full run (L = 64, 20 seeds) is about
4 x 4 = 16 times the work, roughly 1.5 minutes on 10 threads; L = 128 with 20 seeds is about 64 times the provisional work,
roughly 5 minutes. These are estimates scaled from the provisional timing, not measured. The full run took 35 seconds on 24
threads (November 10). `run_noisy_rule_switch` re-runs the
control arm for every f (same seed, same control), so the control is computed 6 times per (condition, seed); this is
accepted rather than cached. Work is spread over (condition, seed) items, so more threads than 3 x 20 = 60 gives no
further speedup.

## Output keys

- `settings`: NamedTuple with L, t_pre, t_post, Δt, σ_S, seeds, f_values, f_control, conditions, paper settings, Julia version,
  package git hash, threads, wall_seconds, and `provisional::Bool`.
- `pairs`: headline switched/control pairs (f in {0.10, 0.25}, seed 1, each condition); each carries `sell_fraction`,
  `buy_fraction`, `prices`, and `frames` (`pre` at t_pre, `final`) per arm.
- `sweep`: DataFrame with one row per (condition, f, seed): L, condition, h, boundary_mode, f, seed, transitioned, onset,
  final_sell_mean, max_drawdown, control_transitioned, control_max_drawdown. Sweep rows carry no frames.

The notebook narrates numbers only from the non-provisional file.
