using Documenter, VLQuantitativeFinancePackage

makedocs(
    sitename = "CHEME 5660 Quantitative Finance Package",
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    modules = [VLQuantitativeFinancePackage],
    checkdocs = :exports,
    warnonly = false,
    pages = [
        "Home" => "index.md",

        "Data" => "data.md",

        "Instruments" => [
            "Treasury securities" => "fixed.md",
            "Equity securities" => "equity.md",
            "Derivative securities" => "derivatives.md",
        ],
        "Portfolio management" => "portfolio.md",
        "Decisions" => [
            "Markov models" => "markov.md",
            "Bandits" => "bandits.md",
            "Reinforcement learning" => "RL.md",
        ],
    ]
)

deploydocs(
    repo = "github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026.git",
    branch = "gh-pages",
    target = "build",
    push_preview = false,
)
