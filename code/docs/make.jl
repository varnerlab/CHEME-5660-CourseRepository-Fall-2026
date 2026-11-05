using Documenter, VLQuantitativeFinancePackage

makedocs(
    sitename = "CHEME 5660 Quantitative Finance Package",
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    modules = [VLQuantitativeFinancePackage, VLQuantitativeFinancePackage.MPCPortfolio],
    checkdocs = :exports,
    warnonly = false,
    pages = [
        "Home" => "index.md",
        "Course questions" => "learning.md",

        "Data" => "data.md",
        "Market microstructure" => "microstructure.md",

        "Instruments" => [
            "Treasury securities" => "fixed.md",
            "Equity securities" => "equity.md",
            "Derivative securities" => "derivatives.md",
        ],
        "Portfolio management" => [
            "Classical portfolios" => "portfolio.md",
            "Adaptive portfolios" => "adaptive.md",
            "Model-predictive portfolios" => "mpc.md",
            "MPC: data and settings" => "mpc-data.md",
            "MPC: allocation" => "mpc-allocation.md",
            "MPC: trading" => "mpc-trading.md",
            "MPC: synthetic markets" => "mpc-synthetic.md",
        ],
        "Decisions" => [
            "Markov models" => "markov.md",
            "Bandits" => "bandits.md",
            "Reinforcement learning" => "RL.md",
            "Agent-based markets" => "abm.md",
        ],
    ]
)

deploydocs(
    repo = "github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026.git",
    branch = "gh-pages",
    target = "build",
    push_preview = false,
)
