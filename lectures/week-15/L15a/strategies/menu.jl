import VLQuantitativeFinancePackage.MPCPortfolio as MPC # the course backtest engine

"""
    picking_menu(settings::MPC.MyStudySettings)::Vector{NamedTuple}

The picking rules of the strategy menu, in menu order, with the basket settings in `settings`. Each entry holds
the rule's `name`, its `screen` (the type the engine calls), and `random`, which is `true` for a rule that draws its
basket at random. The hand-picked rule appears once for each list in the study configuration.
"""
function picking_menu(settings::MPC.MyStudySettings)::Vector{NamedTuple}
    K = settings.basket_K # stocks in a basket that is not picked by sector (count)
    lists = MPC.load_study(MPC.default_study_path()).grid.fixed_lists # the hand-picked lists

    # the rules that pick by preference weight, then the hand-picked lists, then the random rules -
    menu = NamedTuple[]
    push!(menu, (name="gamma by sector", screen=MyL15aGammaSectorScreen(), random=false))
    push!(menu, (name="global gamma", screen=MyL15aGlobalGammaScreen(K), random=false))
    push!(menu, (name="correlation gamma", screen=MyL15aCorrelationGammaScreen(K, settings.corr_max,
        settings.corr_window), random=false))
    push!(menu, (name="liquid gamma", screen=MyL15aLiquidGammaScreen(K, settings.liquidity_shortlist,
        settings.liquidity_window), random=false))
    for (list_name, tickers) in lists
        push!(menu, (name="hand-picked " * list_name, screen=MyL15aHandPickedScreen(tickers), random=false))
    end
    push!(menu, (name="random by sector", screen=MyL15aRandomSectorScreen(), random=true))
    push!(menu, (name="random liquid", screen=MyL15aRandomLiquidScreen(K, settings.liquidity_shortlist,
        settings.liquidity_window), random=true))
    push!(menu, (name="random global", screen=MyL15aRandomGlobalScreen(K), random=true))
    return menu
end

"""
    weighting_menu(settings::MPC.MyStudySettings)::Vector{NamedTuple}

The nine weighting rules of the strategy menu, in menu order, with the rule settings in `settings`. Each entry
holds the rule's `name` and its `rule` (the type the engine calls).
"""
function weighting_menu(settings::MPC.MyStudySettings)::Vector{NamedTuple}
    menu = NamedTuple[]
    push!(menu, (name="Cobb-Douglas", rule=MyL15aCobbDouglasRule()))
    push!(menu, (name="CES on shares", rule=MyL15aCESSharesRule(settings.ces_eta)))
    push!(menu, (name="CES on weights", rule=MyL15aCESWeightsRule(settings.ces_eta)))
    push!(menu, (name="Stone-Geary", rule=MyL15aStoneGearyRule(settings.sg_baseline)))
    push!(menu, (name="minimum variance", rule=MyL15aMinimumVarianceRule()))
    push!(menu, (name="maximum Sharpe", rule=MyL15aMaximumSharpeRule()))
    push!(menu, (name="130/30 long-short", rule=MyL15aLongShortRule(settings.ls_long, settings.ls_short,
        settings.ls_net)))
    push!(menu, (name="equal weight", rule=MyL15aEqualWeightRule()))
    push!(menu, (name="BAB", rule=MyL15aBABRule(settings.ls_long, settings.ls_short, settings.beta_floor)))
    return menu
end

"""
    find_rule(menu::Vector{NamedTuple}, name::String)::NamedTuple

The entry of `menu` with the name `name`. Throws an `ArgumentError` that lists the names on the menu when no entry
has that name.
"""
function find_rule(menu::Vector{NamedTuple}, name::String)::NamedTuple
    names = String[]
    for entry in menu
        if entry.name == name
            return entry
        end
        push!(names, entry.name)
    end
    throw(ArgumentError("no rule named \"$(name)\" on the menu; the names are: " * join(names, ", ")))
end
