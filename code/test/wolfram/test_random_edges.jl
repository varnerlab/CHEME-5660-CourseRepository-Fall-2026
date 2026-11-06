# Tests of the course-addition boundary_mode = :random (edge states drawn from their own RNG stream).

# short-run configuration; T_PRE, STEPS and _paper_config come from test_parity.jl
function _edge_shares(r)
    return sum(r.final_books.shares[rc...] for rc in r.edge_coordinates)
end

function _random_run(L, f, h, seed, activation; steps = nothing, probs = (1/3, 1/3, 1/3),
                     edge_seed = nothing, snaps = [T_PRE, STEPS])
    cfg = _paper_config(L, f, h, seed)
    isnothing(steps) || (cfg.steps = steps)   # the configuration is mutable
    return WM.simulate_checked(cfg; snapshot_steps = snaps, minority_population = :interior,
        rule_activation_step = activation, boundary_mode = :random,
        random_edge_probabilities = probs, random_edge_seed = edge_seed, verbose = false)
end

@testset "random edge mode" begin
    L, f, h, seed = 16, 0.25, 1.0, 3
    steps = 60

    @testset "(a) sell-only edges place and complete Sell orders" begin
        r = _random_run(L, f, h, seed, steps + 1; steps = steps, probs = (0.0, 0.0, 1.0), snaps = [steps])
        n_edge = length(r.edge_coordinates)
        @test all(==(n_edge), r.edge_sell_count)
        @test all(==(0), r.edge_buy_count)
        hold = WM.simulate_checked(r.config; minority_population = :interior,
            rule_activation_step = steps + 1, boundary_mode = :hold, verbose = false)
        @test _edge_shares(hold) == 10 * n_edge   # hold edges never trade
        @test _edge_shares(r) < _edge_shares(hold)
        @test sum(r.executed_sells) > sum(hold.executed_sells)
    end

    @testset "(b) buy-only edges place and complete Buy orders" begin
        r = _random_run(L, f, h, seed, steps + 1; steps = steps, probs = (1.0, 0.0, 0.0), snaps = [steps])
        n_edge = length(r.edge_coordinates)
        @test all(==(n_edge), r.edge_buy_count)
        @test all(==(0), r.edge_sell_count)
        hold = WM.simulate_checked(r.config; minority_population = :interior,
            rule_activation_step = steps + 1, boundary_mode = :hold, verbose = false)
        @test _edge_shares(r) > _edge_shares(hold)
        @test sum(r.executed_buys) > sum(hold.executed_buys)
    end

    @testset "timing: a draw at step t places its order at step t+1" begin
        for probs in ((0.0, 0.0, 1.0), (1.0, 0.0, 0.0))
            r1 = _random_run(L, f, h, seed, 2; steps = 1, probs = probs, snaps = [1])
            r2 = _random_run(L, f, h, seed, 3; steps = 2, probs = probs, snaps = [2])
            n_edge = length(r1.edge_coordinates)
            cash(r) = sum(r.final_books.cash[rc...] for rc in r.edge_coordinates)
            # step 1 trades with the initial Hold edges: holdings untouched even though the draw is already made
            @test _edge_shares(r1) == 10 * n_edge
            @test cash(r1) == 1000.0 * n_edge
            @test (probs[3] == 1.0 ? r1.edge_sell_count[1] : r1.edge_buy_count[1]) == n_edge
            # step 2 executes the orders drawn at step 1
            @test probs[3] == 1.0 ? _edge_shares(r2) < 10 * n_edge : _edge_shares(r2) > 10 * n_edge
        end
    end

    @testset "main RNG untouched by the edge stream" begin
        a = _random_run(L, f, h, seed, steps + 1; steps = steps, edge_seed = 1, snaps = [0, steps])
        b = _random_run(L, f, h, seed, steps + 1; steps = steps, edge_seed = 2, snaps = [0, steps])
        hold = WM.simulate_checked(a.config; minority_population = :interior,
            rule_activation_step = steps + 1, boundary_mode = :hold, verbose = false)
        @test a.frames[0] == b.frames[0] == hold.frames[0]
        @test a.edge_coordinates == b.edge_coordinates == hold.edge_coordinates
        @test a.edge_k == b.edge_k == hold.edge_k
        @test a.frames[steps] != b.frames[steps]   # the edge stream itself does matter
    end

    @testset "(c) uniform probabilities give equal shares" begin
        r = _random_run(32, 0.25, 1.0, 5, 4001; steps = 4000, snaps = [4000])
        total = r.edge_buy_count .+ r.edge_hold_count .+ r.edge_sell_count
        @test all(==(length(r.edge_coordinates)), total)
        for c in (r.edge_buy_count, r.edge_hold_count, r.edge_sell_count)
            @test abs(sum(c) / sum(total) - 1/3) < 0.03
        end
    end

    @testset "(d) switched and control arms share the pre-switch path" begin
        snaps = [100, 400, T_PRE]
        sw = _random_run(32, 0.25, 1.0, 7, T_PRE + 1; steps = 1500, snaps = vcat(snaps, [1500]))
        ct = _random_run(32, 0.25, 1.0, 7, 1501; steps = 1500, snaps = vcat(snaps, [1500]))
        for s in snaps
            @test sw.frames[s] == ct.frames[s]
        end
        @test sw.prices[1:(T_PRE + 1)] == ct.prices[1:(T_PRE + 1)]
        # a different edge seed changes the path
        other = _random_run(32, 0.25, 1.0, 7, 1501; steps = 1500, edge_seed = 12, snaps = [T_PRE])
        @test other.frames[T_PRE] != ct.frames[T_PRE]
    end

    @testset "(e) invalid probabilities throw" begin
        cfg = _paper_config(16, 0.25, 1.0, 1)
        for p in ((-0.1, 0.6, 0.5), (0.5, 0.5, 0.5), (0.2, 0.2, 0.2), (1.0, 0.0, 1e-9))
            @test_throws ArgumentError WM.simulate(cfg; boundary_mode = :random, random_edge_probabilities = p)
        end
        @test_throws ArgumentError WM.simulate(cfg; boundary_mode = :bogus)
    end
end
