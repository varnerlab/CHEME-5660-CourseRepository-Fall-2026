# Course-facing helpers: rule_table, rule_switch_config, run_rule_switch, rule_switch_summary.

@testset "rule_table" begin
    @test WM.rule_table(19280) == [2, 0, 0, 0, 1, 1, 2, 2, 2]
    @test WM.rule_table(19286) == [2, 2, 0, 0, 1, 1, 2, 2, 2]
    # the two rules differ only at index 2 (neighbor sum 1)
    @test findall(WM.rule_table(19280) .!= WM.rule_table(19286)) == [2]
    @test_throws ArgumentError WM.rule_table(-1)
    @test_throws ArgumentError WM.rule_table(3^9)
end

@testset "run_rule_switch shares history and summarizes" begin
    pair = WM.run_rule_switch(L = 16, f = 0.25, h = 100.0, seed = 1, boundary_mode = :hold, t_pre = 20, t_post = 40)
    @test pair.t_pre == 20
    @test pair.switched.frames[20] == pair.control.frames[20]
    @test haskey(pair.switched.frames, 60) && haskey(pair.control.frames, 60)
    s = WM.rule_switch_summary(pair)
    for v in (s.final_sell_mean, s.max_drawdown, s.control_final_sell_mean, s.control_max_drawdown)
        @test isfinite(v)
    end
    @test (s.onset == 0) == !s.transitioned

    cfg = WM.rule_switch_config(L = 16, f = 0.25, h = 100.0, seed = 1, t_pre = 20, t_post = 40)
    @test cfg.steps == 60
    @test cfg.market_maker_capacity == 100.0

    # extra keywords reach both arms, with the same edge seed
    rp = WM.run_rule_switch(L = 16, f = 0.25, h = 100.0, seed = 1, boundary_mode = :random, t_pre = 20, t_post = 40,
        random_edge_probabilities = (0.3, 0.4, 0.3), random_edge_seed = 5)
    @test rp.switched.frames[20] == rp.control.frames[20]
end

@testset "rule_switch_summary reproduces the paper row (L=32, seed=14, f=0.25, h=100, endogenous)" begin
    pair = WM.run_rule_switch(L = 32, f = 0.25, h = 100.0, seed = 14, boundary_mode = :endogenous, f_control = 0.25)
    s = WM.rule_switch_summary(pair)
    @test s.final_sell_mean ≈ 0.8276600000000001 atol = 1e-12
    @test s.max_drawdown ≈ 0.24713623760264702 atol = 1e-12
    @test s.onset == 884
    @test s.transitioned
end
