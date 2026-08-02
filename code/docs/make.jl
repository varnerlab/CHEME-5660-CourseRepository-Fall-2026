using Documenter, VLQuantitativeFinancePackage

push!(LOAD_PATH,"../src/")

makedocs(
    sitename="VLQuantitativeFinancePackage",
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    modules = [VLQuantitativeFinancePackage],
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
    repo = "github.com/varnerlab/VLQuantitativeFinancePackage.jl.git", branch = "gh-pages", target = "build"
)