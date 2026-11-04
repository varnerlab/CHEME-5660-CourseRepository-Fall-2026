"""
    scorecard(equity, spy_close, g_f) -> NamedTuple

Headline performance metrics from aligned daily series (one entry per trading day):
`equity` (USD), `spy_close` (USD), `g_f` (risk-free growth rate, yr⁻¹).

Conventions (Δt = 1/252 yr):
- Daily simple returns `r_t = V_t/V_{t-1} - 1` (dimensionless), `n_days = length(equity) - 1`.
- Daily risk-free `r_f,t = exp(g_f[t]·Δt) - 1`, using `g_f` at day `t`, i.e. the rate in force
  over the day ending at `t`. `g_f[1]` is unused.
- `sharpe = √252·mean(r - r_f)/std(r - r_f)` (std with N-1); `NaN` if the excess returns have
  zero variance (Sharpe is undefined, not infinite).
- `max_drawdown = max_t (1 - V_t / max_{s≤t} V_s)` (fraction, in [0,1)).
- Jensen's alpha: OLS of `(r - r_f)` on `(r_SPY - r_f)` with intercept. `alpha_ann = 252·intercept`
  (yr⁻¹, simple-return scale), `alpha_t = intercept / SE(intercept)` with the classical
  homoskedastic SE `sqrt(s²·(1/n + x̄²/Sxx))`, `s² = SSR/(n-2)`; `beta` is the slope.
- `ann_return = (V_end/V_start)^(252/n_days) - 1` (geometric, yr⁻¹); `ann_vol = √252·std(r)` (yr⁻¹ᐟ²).

Throws `ArgumentError` if lengths differ, fewer than 4 points are given (the regression needs at
least 3 returns so that n-2 ≥ 1 residual degrees of freedom), or any equity/SPY value is ≤ 0.
If SPY returns have zero variance, `beta`, `alpha_ann`, `alpha_t` are `NaN`. If the regression
fits (numerically) perfectly, i.e. SSR ≤ 1e-20·Syy (e.g. equity identical to SPY), the standard
error is degenerate and `alpha_t = NaN`.
"""
function scorecard(equity::Vector{Float64}, spy_close::Vector{Float64}, g_f::Vector{Float64})
    N = length(equity)
    (length(spy_close) == N && length(g_f) == N) ||
        throw(ArgumentError("equity, spy_close, g_f must have equal length; got $N, $(length(spy_close)), $(length(g_f))"))
    N >= 4 || throw(ArgumentError("need at least 4 points (3 returns), got $N"))
    (all(>(0), equity) && all(>(0), spy_close)) || throw(ArgumentError("equity and spy_close must be > 0"))
    Δt = 1 / 252
    r = equity[2:end] ./ equity[1:end-1] .- 1
    rs = spy_close[2:end] ./ spy_close[1:end-1] .- 1
    rf = exp.(g_f[2:end] .* Δt) .- 1
    n = N - 1
    y = r .- rf
    x = rs .- rf

    sy = std(y)
    sharpe = sy <= 1e-12 ? NaN : sqrt(252) * mean(y) / sy

    peak = accumulate(max, equity)
    max_drawdown = maximum(1 .- equity ./ peak)

    x̄, ȳ = mean(x), mean(y)
    Sxx = sum(abs2, x .- x̄)
    if Sxx <= 1e-24
        beta = alpha_ann = alpha_t = NaN
    else
        beta = sum((x .- x̄) .* (y .- ȳ)) / Sxx
        a = ȳ - beta * x̄
        ssr = sum(abs2, y .- a .- beta .* x)
        Syy = sum(abs2, y .- ȳ)
        alpha_ann = 252 * a
        if ssr <= 1e-20 * Syy
            alpha_t = NaN
        else
            alpha_t = a / sqrt(ssr / (n - 2) * (1 / n + x̄^2 / Sxx))
        end
    end

    ann_return = (equity[end] / equity[1])^(252 / n) - 1
    ann_vol = sqrt(252) * std(r)
    return (sharpe=sharpe, max_drawdown=max_drawdown, alpha_ann=alpha_ann, alpha_t=alpha_t,
        beta=beta, ann_return=ann_return, ann_vol=ann_vol)
end
