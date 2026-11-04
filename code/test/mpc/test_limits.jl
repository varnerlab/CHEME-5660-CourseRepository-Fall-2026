using Test, Dates, DataFrames
include("helpers.jl")

@testset "limits day: the row rule" begin
    γ = [0.1 -0.1 -0.1 -0.1 -0.1 -0.1;    # row 1: one name > 0
         0.1  0.1  0.1 -0.1 -0.1 -0.1;    # row 2: three
         0.1  0.1  0.1  0.1 -0.1 -0.1;    # row 3: four, the most
         0.1  0.1  0.1  0.1 -0.1 -0.1]    # row 4: four again, later
    @test limits_row(γ, 1:6) == 3
    @test limits_row(γ, 1:6; min_names=1) == 1
    @test limits_row(γ, [5, 6]) == 1                                  # every row ties at 0: the first
end

@testset "limits day: solver weights match the closed forms and the run's first decision" begin
    md, ctx = study_ctx(; hedge=false, w_max=1.0, vol_cap_annual=Inf, fixed_tickers=md_tickers_13(), basket_K=13)
    runs = [build(MyStudyRun, (settings=with_settings(ctx.settings; ces_eta=η), allocator=a, screen=:fixed,
        seed=5660, label="$(a)|$(η)")) for (a, η) in (("CD", 0.5), ("CES", 0.05), ("CES", 20.0), ("CESw", 0.05),
        ("CESw", 20.0), ("CES", 0.5))]
    day = limits_day(ctx, runs, 1)
    @test nrow(day) == 13 * length(runs) && all(day.date .== md.dates[first(ctx.rows)])
    @test maximum(abs.(day.weight .- day.closed_form)) ≤ 1e-4                     # the real-data gate is 1e-3
    @test all(day.eta[day.allocator .== "CD"] .== 1.0)
    @test "solver" in names(day) && all(in((:clarabel, :clarabel_almost, :scs, :failed)), day.solver)
    @test all(==(:optimal), day.status) && all(!=(:failed), day.solver)           # an optimal decision was not a failed solve
    r = runs[end]; res = run_study(ctx, r); w = day[day.label .== r.label, :]
    @test all(isapprox(w.weight[k], res.targets[res.dates[1]][w.ticker[k]]; atol=1e-12) for k in 1:nrow(w))
    @test_throws ArgumentError limits_day(ctx, [study_run(ctx, "SG", :fixed)], 1)
end

@testset "limits day: the gate flags NaN, non-optimal and large gaps" begin
    day = DataFrame(label=fill("x", 5), ticker=string.(1:5), weight=[0.5, NaN, 0.5, 0.52, Inf],
        closed_form=[0.5, 0.5, 0.5, 0.5, 0.5], status=[:optimal, :optimal, :infeasible, :optimal, :optimal])
    @test limits_failures(day).ticker == ["2", "3", "4", "5"]
    @test isempty(limits_failures(day[1:1, :]))
end
