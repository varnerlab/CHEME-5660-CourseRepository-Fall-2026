"""
    growth_scorecard(equity, spy_close, g_f; Δt=1/252) -> NamedTuple

Headline performance metrics from aligned daily series (one entry per trading day):
`equity` (USD), `spy_close` (USD), `g_f` (risk-free growth rate, yr⁻¹). Every rate is a
continuously compounded growth rate `g = log(S_k/S_{k-1})/Δt` (yr⁻¹), `Δt` in yr.

- `g_W[k] = log(W_k/W_{k-1})/Δt` for the day ending at `k`, paired with `g_f[k]`; `g_f[1]` is unused.
- `sharpe = mean(g_W - g_f)/(√Δt·std(g_W - g_f))` (dimensionless, annualized; std with N-1), equal to
  CHEME-5660's `realized_scorecard` Sharpe. `NaN` if the excess growth has (numerically) zero variance.
- `max_drawdown = max_k (1 - W_k / max_{s≤k} W_s)` (fraction, in [0,1)).
- `alpha`, `beta`: OLS of `(g_W - g_f)` on `(g_SPY - g_f)` with intercept; `alpha` (yr⁻¹) is the
  intercept, `beta` (dimensionless) the slope; `alpha_t` (dimensionless) is intercept over its classical
  homoskedastic SE `sqrt(s²·(1/n + x̄²/Sxx))`, `s² = SSR/(n-2)`.
- `realized_growth = log(W_end/W_1)/((N-1)Δt)` (yr⁻¹); `terminal = W_end` (USD);
  `vol = std(g_W)·√Δt` (yr⁻¹ᐟ², volatility of the daily log growth scaled to a year).

Throws `ArgumentError` if lengths differ, fewer than 4 points are given, `Δt ≤ 0`, or any
equity/SPY value is ≤ 0. If the SPY growth has zero variance, `beta`, `alpha`, `alpha_t` are `NaN`;
if the regression fits (numerically) perfectly, `alpha_t = NaN`.
"""
function growth_scorecard(equity::Vector{Float64}, spy_close::Vector{Float64}, g_f::Vector{Float64};
        Δt::Real=1 / 252)
    N = length(equity)
    (length(spy_close) == N && length(g_f) == N) ||
        throw(ArgumentError("equity, spy_close, g_f must have equal length; got $N, $(length(spy_close)), $(length(g_f))"))
    N >= 4 || throw(ArgumentError("need at least 4 points (3 daily growth rates), got $N"))
    (all(>(0), equity) && all(>(0), spy_close)) || throw(ArgumentError("equity and spy_close must be > 0"))
    Δt > 0 || throw(ArgumentError("Δt must be > 0"))
    gW = log.(equity[2:end] ./ equity[1:end-1]) ./ Δt
    gS = log.(spy_close[2:end] ./ spy_close[1:end-1]) ./ Δt
    gf = g_f[2:end]
    n = N - 1
    y = gW .- gf
    x = gS .- gf

    sy = std(y)
    sharpe = sy * Δt <= 1e-12 ? NaN : mean(y) / (sqrt(Δt) * sy)

    peak = accumulate(max, equity)
    max_drawdown = maximum(1 .- equity ./ peak)

    x̄, ȳ = mean(x), mean(y)
    Sxx = sum(abs2, x .- x̄)
    if Sxx * Δt^2 <= 1e-24
        beta = alpha = alpha_t = NaN
    else
        beta = sum((x .- x̄) .* (y .- ȳ)) / Sxx
        alpha = ȳ - beta * x̄
        ssr = sum(abs2, y .- alpha .- beta .* x)
        Syy = sum(abs2, y .- ȳ)
        alpha_t = ssr <= 1e-20 * Syy ? NaN : alpha / sqrt(ssr / (n - 2) * (1 / n + x̄^2 / Sxx))
    end

    realized_growth = log(equity[end] / equity[1]) / (n * Δt)
    vol = std(gW) * sqrt(Δt)
    return (sharpe=sharpe, max_drawdown=max_drawdown, alpha=alpha, alpha_t=alpha_t, beta=beta,
        realized_growth=realized_growth, terminal=equity[end], vol=vol)
end
