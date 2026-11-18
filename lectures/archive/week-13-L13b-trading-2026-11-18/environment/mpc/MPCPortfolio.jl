"""
`VLQuantitativeFinancePackage.MPCPortfolio`: the screened-utility, model-predictive portfolio method of
the INFORMS Annual Meeting 2026 study (J. D. Varner, "Interpretable Allocation and Model-Predictive
Rebalancing of Equity Portfolios, Tested on Real and Synthetic Markets", arXiv:2611.03022).

What to hold (the γ score and the pickers), how to weight it (maximum-utility allocation under trading
limits, solved with Clarabel and SCS as the fallback), when to trade (a 21-day horizon, a GBM forecast
band, and a drawdown stop), the β-cap hedge, and the study loop that replays a run day by day. The code
is ported from the study's repository (`varnerlab/INFORMS-Annual-Meeting-2026-Varnerlab`, commit
2fc998c); synthetic markets come from `JumpHMM.jl`.

It is a submodule because the course package already defines different `MySIMParameterEstimate`,
`MyEWLSState`, `estimate_sim`, `ewls_init`, and `ewls_update!` (the adaptive portfolio of L7b). Use it
qualified: `import VLQuantitativeFinancePackage.MPCPortfolio as MPC`. Its `build` methods extend the
course package's `build`.

Threaded runs: SCS needs `OMP_NUM_THREADS=1` and `KMP_GTID_MODE=2` set before Julia starts.
"""
module MPCPortfolio

    # the course package's build: the constructors below add methods to it
    import ..VLQuantitativeFinancePackage: build

    # external dependencies -
    using Dates
    using Statistics
    using LinearAlgebra
    using Random
    using TOML
    using DataFrames
    using CSV
    using JLD2
    using JuMP
    using Clarabel
    using SCS
    import JumpHMM

    # the engine, in the study's include order -
    include(joinpath(@__DIR__, "Types.jl"))
    include(joinpath(@__DIR__, "Factory.jl"))
    include(joinpath(@__DIR__, "Data.jl"))
    include(joinpath(@__DIR__, "SIM.jl"))
    include(joinpath(@__DIR__, "Covariance.jl"))
    include(joinpath(@__DIR__, "Allocators.jl"))
    include(joinpath(@__DIR__, "AllocatorsMeanVariance.jl"))
    include(joinpath(@__DIR__, "AllocatorsLongShort.jl"))
    include(joinpath(@__DIR__, "Projection.jl"))
    include(joinpath(@__DIR__, "Costs.jl"))
    include(joinpath(@__DIR__, "Triggers.jl"))
    include(joinpath(@__DIR__, "Metrics.jl"))
    include(joinpath(@__DIR__, "Backtest.jl"))
    include(joinpath(@__DIR__, "Bandit.jl"))
    include(joinpath(@__DIR__, "MarketInputs.jl"))
    include(joinpath(@__DIR__, "Calibration.jl"))
    include(joinpath(@__DIR__, "OnlineSIM.jl"))
    include(joinpath(@__DIR__, "HedgePool.jl"))
    include(joinpath(@__DIR__, "Screens.jl"))
    include(joinpath(@__DIR__, "StudySettings.jl"))
    include(joinpath(@__DIR__, "Context.jl"))
    include(joinpath(@__DIR__, "GrowthScorecard.jl"))
    include(joinpath(@__DIR__, "StudyBacktest.jl"))
    include(joinpath(@__DIR__, "Limits.jl"))

    # course additions: default settings, universe selection, synthetic markets -
    include(joinpath(@__DIR__, "Course.jl"))
    include(joinpath(@__DIR__, "Synthetic.jl"))

    # exports (the study's names for the ported files, plus the course additions) -
    export MyMarketData, load_market_data, growth_rates, index_of, DATA_FILES,
        boundary_split_factor, split_adjustments, MySIMParameterEstimate, MyEWLSState, MyEWVarState,
        estimate_sim, fit_base_sim, ewls_init, ewls_update!, ewvar_init, ewvar_update!,
        market_state, preference_weights, AbstractCovarianceModel, MySIMCovariance,
        MyShrunkResidualCovariance, growth_covariance, residual_matrix, shrinkage_loss,
        choose_shrinkage, AbstractPortfolioRule, MyCobbDouglasRule, MyCESRule, MyCESWeightRule,
        MyStoneGearyRule, MyConstraintSet, MyAllocationProblem, MyAllocationResult, allocate,
        add_shared_constraints!, budget_only_weights, MyMinVarRule, MyTangentRule,
        MyLongShortCDRule, max_investable, expected_growth, MyProjection, project_gbm, trade_cost,
        borrow_fee, MyMPCSpec, MyTriggerState, check_trigger, scorecard, MyRunConfig,
        MyBacktestResult, run_backtest, assign_quotas, beat_spy_reward, train_sector_bandit,
        quarter_starts, bandit_basket_schedule, random_sector_basket, random_matched_schedule,
        xi_gain, xi_series, gtilde_series, gamma_weights, MyCalibration, calibrate,
        save_calibration, load_calibration, calibration_summary, MyOnlineSIM, online_sim,
        down_day_beta, hedge_pool, beta_cap, AbstractScreen, MyBanditScreen, MyGammaScreen,
        MyRandomScreen, excess_growth_windows, train_ticker_bandit, rank_arms, pick,
        short_candidates, MyGlobalGammaScreen, MyLiquidGammaScreen, MyCorrGammaScreen,
        MyGlobalRandomScreen, MyLiquidRandomScreen, MyFixedScreen, liquid_shortlist,
        MyStudySettings, load_study, with_settings, context_key, MyStudyContext, build_context,
        growth_scorecard, MyStudyRun, MyStudyResult, make_rule, make_screen, run_study, limits_row,
        limits_day, limits_failures
    export default_study_path, select_universe, subset_universe
    export SYNTH_HMM, SYNTH_TRAIN, SYNTH_ALPHA_WINDOWS, growth_window, fit_name_model, model_sd_ratio,
        ewls_beta_path, beta_path_stats, real_drift_targets, fit_beta_drift, fit_alpha_pull, fit_generator,
        NonFiniteCloseError, market_data_from_growth, synthetic_market_data, market_path_stats, path_sets, run_synthetic_path
end
