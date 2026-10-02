# Week 7 index (instructor copy)

## L7a — SIM Portfolios and a Risk-Free Asset

October 6 continues the material begun in L6b. The lecture starts with a review
of minimum-variance portfolios with SIM inputs and the risky-assets example.
The main development adds a risk-free asset, the capital allocation line, the
tangent portfolio, and lending or borrowing.

- [Lecture notebook](../week-7/L7a/CHEME-5660-L7a-Lecture-SIM-Portfolio-RF-Fall-2026.ipynb)
- [Companion slides](../week-7/L7a/slides/CHEME-5660-L7a-Slides-Fall-2026.pdf)
- [Example 1: Compare data-driven and SIM portfolios](../week-7/L7a/CHEME-5660-L7a-Example-SIM-MinVar-RA-Fall-2026.ipynb)
- [Example 2: Tangent portfolio and capital allocation line](../week-7/L7a/CHEME-5660-L7a-Example-SIM-MinVar-RRFA-Fall-2026.ipynb)
- [Derivation and optional estimation-risk example](../week-7/L7a/advanced/README.md)

The company profile is BlackRock. The lecture connects portfolio construction
and risk analysis with the choice of a risky fund and a risk-free fraction.

### Carrying the L6b client choices forward

The client interview stays in L6b. After running it, copy `my-tickers.csv` and
`my-client.toml` from L6b's `data` folder into `L7a/data`. From the repository root:

```sh
cp lectures/week-6/L6b/data/my-tickers.csv lectures/week-7/L7a/data/
cp lectures/week-6/L6b/data/my-client.toml lectures/week-7/L7a/data/
```

Run these commands after the interview has created the files. Both examples
read the local ticker list. Example 2 also reads the client's risk-free fraction
and labels that complete portfolio in its wealth plot and table. Without these
files, the examples use the thirteen hardcoded firms and the standard risk-free
fractions. The client files are ignored by Git. The notebooks' stored outputs
show the default firms.

## L7b — Utility-Based Portfolio Allocation

October 8. L7b is being revised; this list matches its folder on October 2.

- [Lecture notebook](../week-7/L7b/CHEME-5660-L7b-Lecture-Utility-Allocation-Fall-2026.ipynb)
- [Companion slides](../week-7/L7b/slides/CHEME-5660-L7b-Slides-Fall-2026.pdf)
- [Optimal point on the capital allocation line](../week-7/L7b/CHEME-5660-L7b-Example-CAL-Optimal-Allocation-Fall-2026.ipynb)
- [Utility allocator](../week-7/L7b/CHEME-5660-L7b-Example-Utility-Allocator-Fall-2026.ipynb)
- [Optional material](../week-7/L7b/advanced/README.md)

The CAL example reads the same two client files from `L7b/data`. Copy them
there too, or it uses the thirteen default firms and a client who keeps a
quarter in T-bills:

```sh
cp lectures/week-6/L6b/data/my-tickers.csv lectures/week-7/L7b/data/
cp lectures/week-6/L6b/data/my-client.toml lectures/week-7/L7b/data/
```

Online SIM estimation and scenario ensembles are in the
[dated archive](../archive/week-7-before-pivot-2026-10-01/README.md).
