using JLD2, CodecZlib, DataFrames, Statistics
import JumpHMM
import VLQuantitativeFinancePackage.MPCPortfolio as MPC
f = JLD2.load("lectures/week-15/L15a/data/L15a-Strategies-Real-2025-2026.jld2")
df = f["summary"]; spy = f["spy"]; gf = f["g_f"]
W = 100000.0 .* spy ./ spy[1]
s = MPC.growth_scorecard(W, spy, gf)
println("SPY sharpe $(s.sharpe) dd $(s.max_drawdown) terminal $(s.terminal)")
println("cor(sharpe, dd) = ", cor(df.sharpe, df.max_drawdown))
println("sharpe>SPY: ", count(df.sharpe .> s.sharpe), "  dd<SPY: ", count(df.max_drawdown .< s.max_drawdown),
  "  both: ", count((df.sharpe .> s.sharpe) .& (df.max_drawdown .< s.max_drawdown)), "  terminal>SPY: ", count(df.terminal .> s.terminal))
both = df[(df.sharpe .> s.sharpe) .& (df.max_drawdown .< s.max_drawdown), :]
println(combine(groupby(both, :picking), nrow => :n))
println(combine(groupby(both, :weighting), nrow => :n))
println("market turn counts: ", sort(unique(df.n_market_turn)), " ", combine(groupby(df, :n_market_turn), nrow=>:n))
println("median decisions: ", median(df.n_decisions), " range ", extrema(df.n_decisions))
for c in [:n_market_turn, :n_beta_over_cap, :n_band_exit, :n_drawdown]
  println(c, " median ", median(df[!, c]), " share of decisions ", round(sum(df[!, c]) / sum(df.n_decisions), digits=3))
end
println("by estimates: ", combine(groupby(df, :estimates), :n_decisions => median, :n_band_exit => median, :n_drawdown => median))
# pairs
u = df[df.estimates .== "updated", :]; fz = df[df.estimates .== "fixed", :]
key(r) = (r.picking, r.weighting, r.hedge, r.seed)
fd = Dict(key(r) => r for r in eachrow(fz))
n = 0; nw = 0; ndd = 0; ns = 0
for r in eachrow(u)
  q = fd[key(r)]; global n += 1
  global nw += r.terminal > q.terminal; global ndd += r.max_drawdown < q.max_drawdown; global ns += r.sharpe > q.sharpe
end
println("pairs $n: updated more wealth $nw, smaller dd $ndd, higher sharpe $ns")
println(combine(groupby(df, :estimates), :terminal => median, :sharpe => median, :max_drawdown => median))
println(combine(groupby(df, :hedge), :terminal => median, :sharpe => median, :max_drawdown => median))
