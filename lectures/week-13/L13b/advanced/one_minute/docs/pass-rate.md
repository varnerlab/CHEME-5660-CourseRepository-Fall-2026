# pass_rate

Defined in `src/Helper.jl` and used in Tasks 2 and 3 of the [one-minute notebook](../CHEME-5660-L13b-Advanced-JumpHMM-SPY-OneMinute-Fall-2026.ipynb).

Scores one trading day against a fitted hidden Markov model. The function simulates paths from the model, each as
long as the day, and compares each path with the real growth rates of the day by the two-sample Kolmogorov–Smirnov
test. It returns the share of paths that pass.

```julia
pass_rate(model::JumpHMM.MyJumpHiddenMarkovModel, growth_rates::Array{Float64,1};
    number_of_paths::Int64, α::Float64, seed::Int64) -> Float64
```

The three keyword arguments are required.

| Argument | Meaning and units |
| --- | --- |
| `model` | The fitted hidden Markov model that we score. |
| `growth_rates` | The one-minute growth rates of one trading day, 1/yr. |
| `number_of_paths` | The number of simulated days we compare with the real day, at least 1. |
| `α` | The significance level of the test, between 0 and 1. A path passes when its p-value is above `α`. |
| `seed` | The seed of the random numbers, so the same day gets the same simulated paths in every run. |

## Returned value

The share of the simulated paths that pass the test, a `Float64` between 0 and 1.
