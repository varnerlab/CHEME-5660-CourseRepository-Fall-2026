# Every configurable setting of the screened-utility panel study, and the loader for config/study.toml.

"""
    MyStudySettings

Every configurable setting of the study. Dates are calendar dates; windows, lags and horizons are
in trading days; `D_max`, `w_max`, `s_max`, `turnover_frac`, `ls_*` are fractions of wealth;
`basket_K`, `liquidity_shortlist` are counts of names; `liquidity_window`, `corr_window` are in trading days;
`corr_max` is a correlation (dimensionless); `w_max_scale` is the pick-cap numerator (a pick's cap is
`max(w_max, w_max_scale/K)`, fraction of wealth); `fixed_tickers` is the pre-chosen list of the `:fixed` screen
(chosen in advance, without 2025 data). `vol_cap_annual` is an annualized volatility in yr⁻¹ᐟ² (the growth-rate cap is
`vol_cap_annual/√Δt` in yr⁻¹); `lambda` is the shrinkage of the residual covariance toward its diagonal
(dimensionless, in [0, 1], `NaN` = calibrated); `s_max` is the sector weight cap; `beta_min` is the floor of β_max;
`xi_short`, `xi_long` are the EMA spans of SPY closes behind ξ; `drawdown_reset` (flag) sets the drawdown peak
back to the current wealth at each `:drawdown` decision, so the trigger fires once per fresh `D_max` loss rather
than on every day below the peak (user, 2026-10-25; `false` keeps the trial's never-reset peak);
`borrow_rate` is per year; `half_spread_bps` is in basis points; `W0` is in dollars. `NaN` for
`vol_cap_annual` means the SPY volatility over the calibration window. The zero-argument constructor
fills the defaults. `turnover_frac` sets each decision's spread-cost budget, c̄·Σ|Δnᵢ| ≤ `turnover_frac`·W with c̄ the half-spread cost per share at the basket's mean price. It is kept from the trial; at 5 bps, for a long-only book, it can bind only when a basket's mean share price is more than 100 times its cheapest name's.
Field names are ASCII so TOML keys equal field names **(plan decision)**.
"""
mutable struct MyStudySettings
    start::Date; stop::Date; train_start::Date; train_stop::Date
    W0::Float64
    xi_short::Int; xi_long::Int; xi_quantile::Float64; gtilde_window::Int; beta_floor::Float64
    ewls_half_life::Float64; ewls_prior_weight::Float64
    omega_window::Int; lambda::Float64
    T::Int; z::Float64; D_max::Float64; drawdown_reset::Bool; cash_revisit::Int; n_paths::Int
    N_per_sector::Int; repick_interval::Int; repick_on_band_exit::Bool
    bandit_lookback::Int; bandit_horizon::Int; bandit_eps_floor::Float64
    bandit_iters_per_arm::Int; bandit_min_iters::Int; bandit_max_iters::Int
    w_max::Float64; vol_cap_annual::Float64; s_max::Float64; turnover_frac::Float64
    ces_eta::Float64; sg_baseline::Float64; ls_long::Float64; ls_short::Float64; ls_net::Float64
    borrow_rate::Float64
    half_spread_bps::Float64; impact_kappa::Float64
    hedge::Bool; beta_ref::Float64; kappa_beta::Float64; beta_min::Float64; pool_H::Int; downday_lookback::Int
    basket_K::Int; liquidity_shortlist::Int; liquidity_window::Int; corr_max::Float64; corr_window::Int
    w_max_scale::Float64; fixed_tickers::Vector{String}
    function MyStudySettings()
        return new(Date(2025, 1, 2), Date(2026, 9, 4), Date(2014, 1, 3), Date(2024, 12, 31),
            100_000.0,
            21, 63, 0.99, 252, 0.1,
            63.0, 63.0,
            126, NaN,
            21, 1.96, 0.08, true, 21, 1000,
            3, 21, true,
            252, 21, 0.05, 50, 500, 5000,
            0.10, NaN, 1.0, 0.10,
            0.5, 0.01, 1.30, 0.30, 1.00, 0.0075,
            5.0, 0.001,
            true, 1.0, 1.0, 0.0, 5, 252,
            13, 100, 63, 0.7, 252,
            1.5, ["AAPL", "MSFT", "INTC", "MU", "AMD", "NVDA", "GS", "BAC", "WFC", "C", "F", "GM", "JNJ"])
    end
end

function _validate_settings(s::MyStudySettings)
    for f in fieldnames(MyStudySettings)
        getfield(s, f) isa Int && getfield(s, f) < 1 &&
            throw(ArgumentError("MyStudySettings: $(f) must be ≥ 1, got $(getfield(s, f))"))
    end
    s.xi_short < s.xi_long || throw(ArgumentError("MyStudySettings: xi_short must be < xi_long"))
    0 < s.xi_quantile < 1 || throw(ArgumentError("MyStudySettings: xi_quantile must be in (0, 1)"))
    s.beta_min ≥ 0 || throw(ArgumentError("MyStudySettings: beta_min must be ≥ 0"))
    0 < s.w_max ≤ 1 || throw(ArgumentError("MyStudySettings: w_max must be in (0, 1]"))
    0 < s.corr_max ≤ 1 || throw(ArgumentError("MyStudySettings: corr_max must be in (0, 1]"))
    s.w_max_scale > 0 || throw(ArgumentError("MyStudySettings: w_max_scale must be > 0"))
    (!isempty(s.fixed_tickers) && allunique(s.fixed_tickers)) ||
        throw(ArgumentError("MyStudySettings: fixed_tickers must be non-empty and unique"))
    s.ces_eta > 0 || throw(ArgumentError("MyStudySettings: ces_eta must be > 0"))
    s.train_stop < s.start ≤ s.stop ||
        throw(ArgumentError("MyStudySettings: need train_stop < start ≤ stop"))
    return s
end

"""
    build(::Type{MyStudySettings}, data::NamedTuple)::MyStudySettings

Start from the defaults and override the fields in `data` (each converted to its field type).
Throws `ArgumentError` on an unknown field, an unconvertible value, or a failed validation:
windows and counts ≥ 1, `xi_short < xi_long`, `0 < xi_quantile < 1`, `beta_min ≥ 0`,
`0 < w_max ≤ 1`, `ces_eta > 0`, `0 < corr_max ≤ 1`, `w_max_scale > 0`, `fixed_tickers` non-empty and unique, `train_stop < start ≤ stop`.
"""
function build(::Type{MyStudySettings}, data::NamedTuple)::MyStudySettings
    s = MyStudySettings()
    for (k, v) in pairs(data)
        k in fieldnames(MyStudySettings) || throw(ArgumentError("MyStudySettings: unknown field $(k)"))
        T = fieldtype(MyStudySettings, k)
        val = try
            convert(T, v)
        catch
            throw(ArgumentError("MyStudySettings: cannot convert $(k) = $(repr(v)) to $(T)"))
        end
        setfield!(s, k, val isa Vector ? copy(val) : val)      # no aliasing of vector fields
    end
    return _validate_settings(s)
end

"""
    with_settings(s::MyStudySettings; kw...)::MyStudySettings

A validated copy of `s` with the keyword fields replaced; `s` is unchanged. Units as in `MyStudySettings`.
"""
function with_settings(s::MyStudySettings; kw...)::MyStudySettings
    base = NamedTuple{fieldnames(MyStudySettings)}(Tuple(getfield(s, f) for f in fieldnames(MyStudySettings)))
    return build(MyStudySettings, merge(base, NamedTuple(kw)))
end

"""
    load_study(path::AbstractString)::NamedTuple{(:settings, :grid)}

Read `config/study.toml`. Every table except `[grid]` is flattened into settings keys (a key that
repeats across tables or is not a settings field throws `ArgumentError`); `"calibrated"` for
`lambda` or `vol_cap_annual` becomes `NaN`. `grid` is `(n_seeds, base_seed, allocators, screens, hedge, K, universe_screens, fixed_lists, eta, eta_limits, eta_ces_drop, limits_list)`, with
`fixed_lists` the `[grid.fixed_lists]` table as `name => tickers` pairs sorted by name, `eta` and `eta_limits` the CES
elasticities (dimensionless, each finite and > 0) of the η sweep and the clean-limits runs, `eta_ces_drop` the elasticities (a subset of `eta`) at which share-count `"CES"` is left out of the η sweep, and `limits_list` the name of the
fixed list of the clean-limits runs. Throws `ArgumentError` for a missing key, a bad η or an unknown `limits_list`.
"""
function load_study(path::AbstractString)
    raw = TOML.parsefile(path)
    flat = Dict{Symbol,Any}()
    for (tbl, body) in raw
        tbl == "grid" && continue
        body isa AbstractDict || throw(ArgumentError("load_study: top-level key $(tbl) must be a table"))
        for (k, v) in body
            key = Symbol(k)
            haskey(flat, key) && throw(ArgumentError("load_study: key $(k) repeated across tables"))
            key in fieldnames(MyStudySettings) || throw(ArgumentError("load_study: unknown key $(k) in [$(tbl)]"))
            flat[key] = (key in (:lambda, :vol_cap_annual) && v == "calibrated") ? NaN : v
        end
    end
    settings = build(MyStudySettings, NamedTuple(flat))
    g = get(raw, "grid", Dict{String,Any}())
    for k in ("n_seeds", "base_seed", "allocators", "screens", "hedge", "K", "universe_screens", "fixed_lists",
        "eta", "eta_limits", "eta_ces_drop", "limits_list")
        haskey(g, k) || throw(ArgumentError("load_study: [grid] is missing $(k)"))
    end
    grid = (n_seeds = Int(g["n_seeds"]), base_seed = Int(g["base_seed"]),
        allocators = String.(g["allocators"]), screens = Symbol.(g["screens"]), hedge = Bool.(g["hedge"]),
        K = Int.(g["K"]), universe_screens = Symbol.(g["universe_screens"]),
        fixed_lists = sort!([String(n) => String.(v) for (n, v) in g["fixed_lists"]]; by=first),
        eta = Float64.(g["eta"]), eta_limits = Float64.(g["eta_limits"]),
        eta_ces_drop = Float64.(g["eta_ces_drop"]), limits_list = String(g["limits_list"]))
    for η in vcat(grid.eta, grid.eta_limits)
        (isfinite(η) && η > 0) || throw(ArgumentError("load_study: every eta must be finite and > 0, got $(η)"))
    end
    for η in grid.eta_ces_drop
        η in grid.eta || throw(ArgumentError("load_study: every eta_ces_drop must be in eta, got $(η)"))
    end
    grid.limits_list in first.(grid.fixed_lists) ||
        throw(ArgumentError("load_study: limits_list $(grid.limits_list) names no [grid.fixed_lists] entry"))
    return (settings = settings, grid = grid)
end

"""
    context_key(s::MyStudySettings)::NamedTuple

The settings that `build_context` depends on (dates, EWLS half-life and prior weight in trading days,
ξ and g̃ windows, β floor, pool size, down-day lookback, bandit horizon). Two settings with equal keys
can share one context.
"""
function context_key(s::MyStudySettings)::NamedTuple
    return (start = s.start, stop = s.stop, train_start = s.train_start, train_stop = s.train_stop,
        ewls_half_life = s.ewls_half_life, ewls_prior_weight = s.ewls_prior_weight,
        xi_short = s.xi_short, xi_long = s.xi_long, xi_quantile = s.xi_quantile,
        gtilde_window = s.gtilde_window, beta_floor = s.beta_floor, pool_H = s.pool_H,
        downday_lookback = s.downday_lookback, bandit_horizon = s.bandit_horizon)
end
