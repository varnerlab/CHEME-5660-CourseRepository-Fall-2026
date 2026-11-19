# growth_rate_density

Defined in `src/Helper.jl` and used in Task 1 of the [one-minute notebook](../CHEME-5660-L13b-Advanced-JumpHMM-SPY-OneMinute-Fall-2026.ipynb).

Estimates the probability density of the growth rate from a histogram. The function counts the growth rates in each
bin between two neighboring edges, and divides each count by the number of growth rates times the bin width. Growth
rates outside the first and last edge count toward the total but fall in no bin.

```julia
growth_rate_density(growth_rates::Array{Float64,1}, edges::AbstractRange{Float64}) -> Array{Float64,1}
```

| Argument | Meaning and units |
| --- | --- |
| `growth_rates` | The growth rates, for example one simulated path of minutes, 1/yr. |
| `edges` | The evenly spaced bin edges, from the lowest to the highest, 1/yr. |

## Returned value

The probability density in each bin, an `Array{Float64,1}` with one entry per bin (units: yr).
