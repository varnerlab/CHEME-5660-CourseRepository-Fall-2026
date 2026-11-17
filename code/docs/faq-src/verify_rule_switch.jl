# Reproduce the rule-switch sweep in the FAQ answer "Why can a one-entry rule switch produce a Sell
# majority, and how many traders must switch?" (rule-switch-spread, November 17, 2026).
#
# The sweep uses run_noisy_rule_switch(...) from the L12b examples with the settings of the rule-switch
# example: a deep dealer (h = 100), active edge traders, 1,000 steps before the switch and 3,000 after,
# one-minute steps, and dealer noise σ_S = 0.40. A market has a Sell majority if its Sell fraction reaches
# one half after the switch. Run from the repository root (about two minutes):
#
#   julia code/docs/faq-src/verify_rule_switch.jl
include(joinpath(@__DIR__, "..", "..", "..", "lectures", "week-12", "L12b", "Include.jl"));
using Printf

const Δt_step = 1/(252*390); # one minute of a 390-minute trading day (years)
const t_pre_steps = 1000;
const t_post_steps = 3000;

function sweep(; baseline_rule, switch_rule, L, f, seeds, boundary_mode = :endogenous)
    majority = 0; control_majority = 0; final_price = Float64[];
    for s ∈ seeds
        pair = run_noisy_rule_switch(; baseline_rule = baseline_rule, switch_rule = switch_rule, L = L, f = f, h = 100.0, seed = s,
            boundary_mode = boundary_mode, σ_S = 0.40, Δt = Δt_step, t_pre = t_pre_steps, t_post = t_post_steps);
        after = (t_pre_steps + 2):(t_pre_steps + t_post_steps + 1); # the steps after the switch
        majority += maximum(pair.switched.sell_fraction[after]) >= 0.5;
        control_majority += maximum(pair.control.sell_fraction[after]) >= 0.5;
        push!(final_price, 100*pair.switched.prices[end]/pair.control.prices[end]);
    end
    return (majority = majority, control_majority = control_majority, median_price = median(final_price));
end

failures = 0;
function expect(label, result, majority, median_price = nothing)
    ok = result.majority == majority && result.control_majority == 0 &&
        (isnothing(median_price) || abs(result.median_price - median_price) <= 0.05);
    @printf("%-48s majority %2d, control majority %d, median final price %.1f%% of control  %s\n",
        label, result.majority, result.control_majority, result.median_price, ok ? "ok" : "FAILED");
    ok || (global failures += 1);
end

# the table in the answer: Rule 19280 to Rule 19286 on the 32 × 32 grid, 20 starting markets -
for (f, majority, price) ∈ [(0.10, 0, 98.4), (0.15, 0, 97.4), (0.20, 7, 95.6), (0.25, 20, 75.0), (0.30, 20, 74.7), (0.50, 20, 73.4)]
    expect("19280 → 19286, 32 × 32, f = $(f)", sweep(baseline_rule = 19280, switch_rule = 19286, L = 32, f = f, seeds = 1:20), majority, price);
end

# the checks of the setup in the text -
expect("19280 → 19286, 64 × 64, f = 0.15", sweep(baseline_rule = 19280, switch_rule = 19286, L = 64, f = 0.15, seeds = 1:10), 0);
expect("19280 → 19286, 64 × 64, f = 0.2", sweep(baseline_rule = 19280, switch_rule = 19286, L = 64, f = 0.20, seeds = 1:10), 10);
expect("19280 → 19286, held edges, f = 0.2", sweep(baseline_rule = 19280, switch_rule = 19286, L = 32, f = 0.20, seeds = 1:20, boundary_mode = :hold), 2);
expect("19280 → 19286, held edges, f = 0.25", sweep(baseline_rule = 19280, switch_rule = 19286, L = 32, f = 0.25, seeds = 1:20, boundary_mode = :hold), 19);
expect("19289 → 19298, 32 × 32, f = 0.05", sweep(baseline_rule = 19289, switch_rule = 19298, L = 32, f = 0.05, seeds = 1:20), 17);
expect("19289 → 19298, 32 × 32, f = 0.1", sweep(baseline_rule = 19289, switch_rule = 19298, L = 32, f = 0.10, seeds = 1:20), 20);

failures == 0 || error("$(failures) rule-switch results differ from the FAQ answer");
println("The rule-switch sweep matches the FAQ answer.");
