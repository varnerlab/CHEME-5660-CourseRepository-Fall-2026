#!/usr/bin/env julia

# Rebuild the two numerical course-preview figures used by the L1a deck.
# The inputs are packaged course datasets; no network access is required.

using Pkg

const REPO_ROOT = normpath(joinpath(@__DIR__, "../../../.."))
Pkg.activate(REPO_ROOT)

using VLQuantitativeFinancePackage
using DataFrames
using Distributions
using LinearAlgebra
using MathOptInterface
using Plots
using Printf
using Random
using Statistics

const INK = colorant"#333333"
const BODY = colorant"#5E5E5E"
const CORAL = colorant"#FF644E"
const BLUE = colorant"#579ACA"
const RULE = colorant"#AEB4BA"
const PANEL = colorant"#F8F9FA"

gr()
default(
    fontfamily = "Helvetica",
    foreground_color = INK,
    background_color = :white,
    background_color_subplot = PANEL,
    gridcolor = RULE,
    gridalpha = 0.20,
    guidefontcolor = BODY,
    tickfontcolor = BODY,
    legendfontcolor = BODY,
    framestyle = :box,
)

function growth_statistics(dataset::Dict{String,DataFrame}, tickers::Vector{String})
    dates = dataset[first(tickers)].timestamp
    @assert all(dataset[t].timestamp == dates for t in tickers)
    prices = hcat([dataset[t][!, :volume_weighted_average_price] for t in tickers]...)
    growth = diff(log.(prices), dims = 1) ./ (1 / 252)
    vec(mean(growth, dims = 1)), cov(growth, dims = 1)
end

function build_portfolio_preview(output_path::String)
    raw = MyTrainingMarketDataSet()["dataset"]
    maximum_days = maximum(nrow(frame) for frame in values(raw))
    dataset = Dict(t => frame for (t, frame) in raw if nrow(frame) == maximum_days)
    tickers = ["AAPL", "JNJ", "XOM", "JPM", "NVDA"]
    @assert all(haskey(dataset, t) for t in tickers)

    g_mean, covariance = growth_statistics(dataset, tickers)
    number_of_samples = 5_000
    Random.seed!(5660)
    weights = rand(Dirichlet(ones(length(tickers))), number_of_samples)
    cloud_growth = [dot(weights[:, k], g_mean) for k in 1:number_of_samples]
    cloud_risk = [sqrt(dot(weights[:, k], covariance * weights[:, k])) for k in 1:number_of_samples]

    asset_count = length(tickers)
    bounds = zeros(asset_count, 2)
    bounds[:, 2] .= 1.0
    problem = build(MyMarkowitzRiskyAssetOnlyPortfolioChoiceProblem, (
        Σ = covariance,
        μ = g_mean,
        bounds = bounds,
        initial = fill(1 / asset_count, asset_count),
        R = minimum(g_mean),
    ))
    gmv_solution = solve(problem)
    @assert gmv_solution["status"] == MathOptInterface.LOCALLY_SOLVED
    gmv_weights = gmv_solution["argmax"]
    gmv_growth = dot(g_mean, gmv_weights)
    gmv_risk = sqrt(dot(gmv_weights, covariance * gmv_weights))

    frontier_growth = Float64[]
    frontier_risk = Float64[]
    targets = range(gmv_growth, stop = maximum(g_mean) - 1e-4, length = 81)
    for target in targets
        problem.R = target
        try
            solution = solve(problem)
            if solution["status"] == MathOptInterface.LOCALLY_SOLVED
                w = solution["argmax"]
                push!(frontier_growth, dot(g_mean, w))
                push!(frontier_risk, sqrt(dot(w, covariance * w)))
            end
        catch err
            err isa AssertionError || rethrow()
        end
    end
    @assert length(frontier_growth) > 60

    # Keep the course convention on both axes. Here g is the continuously
    # compounded growth rate and the return over one interval is r = g*Delta t.
    # Thus both the mean and standard deviation below have units of 1/year.
    single_risk = sqrt.(diag(covariance))

    p = scatter(
        cloud_risk,
        cloud_growth;
        size = (1800, 670),
        margin = 5Plots.mm,
        markersize = 7.0,
        markerstrokewidth = 0,
        markeralpha = 0.16,
        color = BLUE,
        label = "5,000 portfolio mixes",
        xlabel = "Growth-rate risk (standard deviation, 1/year)",
        ylabel = "Expected growth rate (1/year)",
        left_margin = 11Plots.mm,
        bottom_margin = 14Plots.mm,
        xformatter = x -> @sprintf("%.1f", x),
        yformatter = y -> @sprintf("%.2f", y),
        guidefontsize = 24,
        tickfontsize = 19,
        legendfontsize = 20,
        legend = :topleft,
        xlims = (minimum(cloud_risk) - 0.25, maximum(single_risk) + 0.55),
        ylims = (minimum(g_mean) - 0.06, maximum(g_mean) + 0.07),
    )
    plot!(p, frontier_risk, frontier_growth; color = CORAL, linewidth = 5.5, label = "efficient frontier")
    scatter!(
        p,
        single_risk,
        g_mean;
        color = INK,
        markersize = 15,
        markerstrokecolor = :white,
        markerstrokewidth = 2,
        label = "single-stock portfolios",
    )
    scatter!(
        p,
        [gmv_risk],
        [gmv_growth];
        color = :white,
        markersize = 17,
        marker = :circle,
        markerstrokecolor = CORAL,
        markerstrokewidth = 4,
        label = "minimum-variance portfolio",
    )
    label_offsets = Dict(
        "AAPL" => (0.13, 0.023),
        "JNJ" => (0.13, -0.026),
        "XOM" => (0.13, -0.028),
        "JPM" => (0.13, -0.025),
        "NVDA" => (-0.12, 0.018),
    )
    for i in eachindex(tickers)
        dx, dy = label_offsets[tickers[i]]
        horizontal_alignment = tickers[i] == "NVDA" ? :right : :left
        annotate!(
            p,
            single_risk[i] + dx,
            g_mean[i] + dy,
            text("100% $(tickers[i])", 22, INK, horizontal_alignment),
        )
    end
    savefig(p, output_path)
    println("Portfolio preview: $(number_of_samples) samples, $(length(frontier_growth)) solved frontier targets")
end

function comma_integer(x::Real)
    n = abs(round(Int, x))
    digits = string(n)
    groups = String[]
    while length(digits) > 3
        pushfirst!(groups, digits[end-2:end])
        digits = digits[1:end-3]
    end
    pushfirst!(groups, digits)
    (x < 0 ? "-" : "") * join(groups, ",")
end

dollars(x::Real) = "\$" * comma_integer(x)

function mid_quote(options::DataFrame, strike::Float64, contract_type::String)
    rows = filter([:Strike, :Type] => (k, t) -> k == strike && t == contract_type, options)
    @assert nrow(rows) == 1
    Float64(rows[1, :Mid])
end

function profit_panel!(p, terminal_price, profit; breakeven, title)
    positive = ifelse.(profit .>= 0, profit, NaN)
    negative = ifelse.(profit .< 0, profit, NaN)
    plot!(p, terminal_price, profit; color = INK, linewidth = 2, label = "")
    plot!(p, terminal_price, positive; color = BLUE, linewidth = 7, label = "Gain")
    plot!(p, terminal_price, negative; color = CORAL, linewidth = 7, label = "Loss")
    hline!(
        p,
        [0.0];
        color = BODY,
        linewidth = 2,
        linestyle = :dash,
        label = @sprintf("Breakeven \$%.2f", breakeven),
    )
    scatter!(
        p,
        [breakeven],
        [0.0];
        color = :white,
        markersize = 11,
        markerstrokecolor = INK,
        markerstrokewidth = 2,
        label = "",
    )
    plot!(
        p;
        title = title,
        titlefontsize = 20,
        xlabel = "AMD price at expiration (USD/share)",
        ylabel = "P/L at expiration (USD/share)",
        left_margin = 10Plots.mm,
        bottom_margin = 10Plots.mm,
        guidefontsize = 18,
        tickfontsize = 15,
        legendfontsize = 15,
        background_color_legend = :transparent,
        foreground_color_legend = :transparent,
        yformatter = y -> string(round(Int, y)),
    )
end

function build_payoff_preview(output_path::String)
    options_dataset = MyOptionsChainDataSet(ticker = "amd")
    metadata = options_dataset.metadata
    options = options_dataset.data
    spot = parse(Float64, metadata["underlying_share_price_mid"])
    dte = parse(Int, metadata["DTE"])
    lower_strike = 210.0
    upper_strike = 240.0
    lower_call = mid_quote(options, lower_strike, "Call")
    upper_call = mid_quote(options, upper_strike, "Call")
    debit = lower_call - upper_call
    @assert 0 < debit < upper_strike - lower_strike

    terminal_price = collect(range(175.0, stop = 275.0, length = 801))
    stock_profit = terminal_price .- spot
    spread_profit = (
        max.(terminal_price .- lower_strike, 0.0) .-
        max.(terminal_price .- upper_strike, 0.0) .-
        debit
    )
    spread_breakeven = lower_strike + debit
    maximum_loss = 100 * debit
    maximum_gain = 100 * (upper_strike - lower_strike - debit)
    stock_downside_profit = lower_strike - spot
    stock_upside_profit = upper_strike - spot

    left = plot(; legend = :topleft, ylims = (-55, 55))
    profit_panel!(
        left,
        terminal_price,
        stock_profit;
        breakeven = spot,
        title = "100 AMD shares  |  upfront " * dollars(100 * spot),
    )
    scatter!(left, [lower_strike], [stock_downside_profit]; color = CORAL, markersize = 11, markerstrokecolor = INK, markerstrokewidth = 1.5, label = "Stop \$210")
    scatter!(left, [upper_strike], [stock_upside_profit]; color = BLUE, markersize = 11, markerstrokecolor = INK, markerstrokewidth = 1.5, label = "Exit \$240")
    annotate!(left, 230, -27, text("Asset: 100 AMD shares", 16, BODY, :left))
    annotate!(left, 230, -34, text("Lifetime: unlimited", 16, BODY, :left))
    annotate!(left, 230, -41, text("Max gain: unlimited", 16, BLUE, :left))
    annotate!(left, 230, -48, text("Max loss: " * dollars(100 * spot), 16, CORAL, :left))

    right = plot(; legend = :topleft, ylims = (-18, 18))
    profit_panel!(
        right,
        terminal_price,
        spread_profit;
        breakeven = spread_breakeven,
        title = "210 / 240 call spread  |  upfront " * dollars(maximum_loss),
    )
    scatter!(right, [lower_strike], [-debit]; color = CORAL, markersize = 11, markerstrokecolor = INK, markerstrokewidth = 1.5, label = "Lower strike \$210")
    scatter!(right, [upper_strike], [upper_strike - lower_strike - debit]; color = BLUE, markersize = 11, markerstrokecolor = INK, markerstrokewidth = 1.5, label = "Upper strike \$240")
    # The spread panel has a much tighter y-scale than the stock panel, so use
    # compact data-coordinate spacing to produce normal single-line leading.
    annotate!(right, 235, -8.8, text("Asset: 0 AMD shares", 16, BODY, :left))
    annotate!(right, 235, -10.8, text("Lifetime: $(dte) days", 16, BODY, :left))
    annotate!(right, 235, -12.8, text("Max gain: " * dollars(maximum_gain), 16, BLUE, :left))
    annotate!(right, 235, -14.8, text("Max loss: " * dollars(maximum_loss), 16, CORAL, :left))

    combined = plot(
        left,
        right;
        layout = (1, 2),
        size = (1800, 690),
        margin = 5Plots.mm,
        link = :x,
        plot_title = "AMD  |  $(dte) days to expiration",
        plot_titlefontsize = 18,
    )
    savefig(combined, output_path)
    println(@sprintf(
        "Payoff preview: spot %.2f, 210-call %.2f, 240-call %.2f, debit %.2f, max gain %.2f",
        spot,
        lower_call,
        upper_call,
        debit,
        maximum_gain,
    ))
end

requested_figures = isempty(ARGS) ? Set(["portfolio", "payoff"]) : Set(lowercase.(ARGS))
@assert isempty(setdiff(requested_figures, Set(["portfolio", "payoff"]))) "valid figure names are portfolio and payoff"

if "portfolio" in requested_figures
    build_portfolio_preview(joinpath(@__DIR__, "Fig-L1a-PortfolioPreview.pdf"))
end
if "payoff" in requested_figures
    build_payoff_preview(joinpath(@__DIR__, "Fig-L1a-PayoffPreview.pdf"))
end
