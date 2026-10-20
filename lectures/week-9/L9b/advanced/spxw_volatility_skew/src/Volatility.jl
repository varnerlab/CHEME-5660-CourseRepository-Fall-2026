"""
    realized_volatility(close::Vector{Float64}, window::Int64;
        Δt::Float64 = 1/252) -> Float64

Annualized realized (historical) volatility over the last `window` daily growth rates,
`σ_ann = √Δt * σ_g`, where `σ_g` is the standard deviation of the growth rates
`g_k = (1/Δt)*ln(S_k/S_{k-1})` of the closing prices `S_k`.

### Arguments
- `close::Vector{Float64}`: closing prices in date order (USD/share). Needs at least
  `window + 1` prices.
- `window::Int64`: number of most recent growth rates to use (trading days).
- `Δt::Float64`: time between closing prices (years). The default is one trading day.

### Returns
- `Float64`: the annualized realized volatility (units: yr^-1/2).
"""
function realized_volatility(close::Vector{Float64}, window::Int64;
    Δt::Float64 = 1/252)::Float64

    # daily growth rates (1/yr), then the last window of them -
    g = (1/Δt) .* log.(close[2:end] ./ close[1:end-1]);
    σ_g = std(g[(end - window + 1):end]); # standard deviation of the growth rates (1/yr)

    # return -
    return sqrt(Δt)*σ_g;
end
