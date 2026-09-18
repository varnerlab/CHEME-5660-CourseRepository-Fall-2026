# Run from any directory with julia --project=<course-root> scripts/check-week5-adaptive.jl.
using Test, Dates, DataFrames, Distributions, Statistics, Random
const example_root = joinpath(@__DIR__, "..", "lectures", "week-5", "L5a");
include(joinpath(example_root, "src", "AdaptiveGBM.jl"));
include(joinpath(example_root, "src", "TradeOutcomes.jl"));

@testset "Centered EMA, independent weighted moments and timing" begin
    dt = 1/252;
    growth = 0.08;
    volatility = 0.2;
    lambda = 2.0^(-1/21);
    observed_growth = [5.04, -2.52, 7.56, -10.08, 1.26, 2.52, -5.04]; # year⁻¹
    prices = 100 .* exp.([0.0; cumsum(observed_growth) .* dt]);
    states = ema_gbm_parameters(prices, growth, volatility);
    for t in 0:length(observed_growth)
        # Independent sums include the initial distribution's first and second moments.
        weights = [(1-lambda)*lambda^(t-j) for j in 1:t];
        expected_mean = lambda^t*growth + sum(weights .* observed_growth[1:t]);
        second_moment = lambda^t*(volatility^2/dt+growth^2) + sum(weights .* observed_growth[1:t].^2);
        @test states.mu_g[t+1] ≈ expected_mean atol=1e-12;
        @test states.variance_growth[t+1] ≈ second_moment-expected_mean^2 atol=1e-11;
        @test states.sigma[t+1]^2 ≈ states.variance_growth[t+1]*dt;
        @test states.mu[t+1] ≈ states.mu_g[t+1]+states.sigma[t+1]^2/2;
    end
    # Changing the observation duration changes growth units, not the price ratios.
    weekly_dt = 1/52;
    weekly = ema_gbm_parameters(prices, growth*dt/weekly_dt, volatility*sqrt(dt/weekly_dt); dt=weekly_dt);
    @test weekly.mu_g .* weekly_dt ≈ states.mu_g .* dt;
    @test weekly.variance_growth .* weekly_dt^2 ≈ states.variance_growth .* dt^2;
    @test weekly.sigma .* sqrt(weekly_dt) ≈ states.sigma .* sqrt(dt);
    @test ema_gbm_parameters(prices[1:5], growth, volatility) == states[1:5, :];
    changed = copy(prices);
    changed[6:end] .*= 1.3;
    @test ema_gbm_parameters(changed, growth, volatility)[1:5, :] == states[1:5, :];
    frozen = ema_gbm_parameters(prices, growth, volatility; decay=1);
    @test all(frozen.mu_g .≈ growth);
    @test all(frozen.sigma .≈ volatility);
    @test_throws ArgumentError ema_gbm_parameters([100., 0.], growth, volatility);
    @test_throws ArgumentError ema_gbm_parameters(prices, growth, volatility; half_life=0);

    dates = collect(Date(2025,1,1):Day(1):Date(2025,1,length(prices)));
    for start in (1,3), horizon in (1,3)
        f = rolling_trade_forecasts(prices, dates, growth, volatility; start_index=start, holding_days=horizon);
        @test nrow(f) == 3*(length(prices)-horizon-start+1);
        @test all(f.sale_index .== f.origin_index .+ horizon);
        @test all(f.total_time .≈ (f.sale_index .- start).*dt);
        @test all(f.entry_price .== prices[start]);
        @test length(unique(f.probability[1:3])) == 1;
        @test f.sigma[f.method .== "EMA volatility"] == f.sigma[f.method .== "EMA mean + volatility"];
        scored = score_trade_forecasts(f, prices);
        expected_npv = (prices[f.sale_index]./prices[start]).*exp.(-0.05.*(f.sale_index.-start).*dt).-1;
        @test scored.scaled_npv ≈ expected_npv atol=1e-15;
        @test scored.brier_loss ≈ (f.probability .- (expected_npv .> 0)).^2;
        # Growth-band limits recover the same GBM price quantiles at every origin.
        z = quantile(Normal(), 0.975);
        @test f.growth_lower ≈ f.mu_g .- z .* f.sigma ./ sqrt.(f.horizon);
        observed = log.(prices[f.sale_index] ./ f.current_price) ./ f.horizon;
        @test scored.covered_95 == ((f.growth_lower .<= observed) .& (observed .<= f.growth_upper));
        @test scored.interval_score ≈ (f.growth_upper .- f.growth_lower) .+
            40 .* (max.(f.growth_lower .- observed, 0) .+ max.(observed .- f.growth_upper, 0));
        @test maximum(f.sale_index) == length(prices);
    end
    early = rolling_trade_forecasts(prices[1:5], dates[1:5], growth, volatility; holding_days=1);
    full = rolling_trade_forecasts(changed, dates, growth, volatility; holding_days=1);
    @test early == full[full.origin_index .<= 4, :];
    @test_throws ArgumentError rolling_trade_forecasts(prices, dates, growth, volatility; holding_days=0);
    @test_throws ArgumentError rolling_trade_forecasts(prices, dates, growth, volatility; start_index=8, holding_days=1);
end

@testset "Trade probabilities, numerical check and scores" begin
    h = 21/252;
    target = expm1((0.08-0.05)*h);
    f = gbm_trade_forecast(100.,100.,0.08,0.2; horizon=h,total_time=h,target);
    @test f.probability ≈ 0.5 atol=1e-13;
    @test gbm_trade_forecast(100.,100.,0.,0.; horizon=0.,total_time=0.,benchmark=0.).probability == 0.;
    @test gbm_trade_forecast(101.,100.,0.,0.; horizon=0.,total_time=0.,benchmark=0.).probability == 1.;
    p_low = gbm_trade_forecast(100.,100.,0.08,0.2; horizon=h,total_time=h,benchmark=0.).probability;
    p_high = gbm_trade_forecast(100.,100.,0.08,0.2; horizon=h,total_time=h,benchmark=0.2).probability;
    @test p_low > p_high;
    @test_throws ArgumentError gbm_trade_forecast(100.,100.,0.08,-0.2; horizon=h,total_time=h);
    @test_throws ArgumentError gbm_trade_forecast(100.,100.,0.08,0.2; horizon=h,total_time=h,target=-1.);
    @test interval_score(-1.,1.,0.) == 2.;
    @test interval_score(-1.,1.,2.) == 42.;
    rng = MersenneTwister(5660);
    draws = 100 .* exp.(0.08h .+ 0.2sqrt(h).*randn(rng,10000));
    p_mc = mean(draws .> f.threshold);
    @test abs(p_mc-f.probability) <= 4sqrt(f.probability*(1-f.probability)/length(draws));
end
