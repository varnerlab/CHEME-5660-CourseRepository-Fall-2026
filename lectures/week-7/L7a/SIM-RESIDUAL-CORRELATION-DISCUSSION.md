# SIM residual correlation discussion

Saved October 6, 2026, from Jeffrey Varner's conversation with Codex while
reviewing the [L7a lecture](CHEME-5660-L7a-Lecture-SIM-Portfolio-RF-Fall-2026.ipynb).
This record preserves the two substantive questions and answers, with light
formatting and spelling corrections, the references, and possible follow-up
questions. The proposed lecture clarification and model extensions remain
discussion items.

## Question 1 Dependence across time

**Jeffrey:** For the single index model

$$
g_i=\alpha_i+\beta_i g_M+\varepsilon_i,
$$

this is for a single point in time for firm $i$. Is the residual correlated in
time? Are the residuals at $t$ and $t+\Delta t$ related, or are they independent?
This is more of a literature question, but also check the lecture.

**Codex:** In the usual elementary time-series version of the SIM, the errors
are assumed independent across time. But that is an additional assumption—the
equation alone does not establish it.

Writing the time index explicitly helps:

$$
g_{i,t}=\alpha_i+\beta_i g_{M,t}+\varepsilon_{i,t}.
$$

Here, $g_{i,t}$ describes growth over an observation interval, such as one
trading day. Your question concerns the relationship between
$\varepsilon_{i,t}$ and $\varepsilon_{i,t+\Delta t}$.

There are three distinct assumptions:

| Relationship | Mathematical statement |
| --- | --- |
| Residual and market in the same period | $\operatorname{Cov}(\varepsilon_{i,t},g_{M,t})=0$ |
| Different firms in the same period | $\operatorname{Cov}(\varepsilon_{i,t},\varepsilon_{j,t})=0,\quad i\ne j$ |
| Same firm in different periods | $\operatorname{Cov}(\varepsilon_{i,t},\varepsilon_{i,s})=0,\quad t\ne s$ |

The first two do not imply the third. Temporal independence is stronger still:
zero correlation generally does not imply independence.

For example, Eric Zivot's University of Washington treatment explicitly assumes

$$
\varepsilon_{i,t}\overset{\mathrm{iid}}{\sim}
\mathcal N\!\left(0,\sigma^2_{\varepsilon,i}\right).
$$

Under that specification, today's error and tomorrow's error are independent
draws with the same distribution. This gives a precise example of the standard
simplifying assumption. See [Zivot, Single Index Model, assumptions on PDF
page 3](https://faculty.washington.edu/ezivot/econ424/singleindexslides.pdf).

In applications, that assumption needs checking. Dependence can also appear
through the size of the errors: large shocks can cluster even when the signed
errors have zero autocorrelation. ARCH/GARCH models accommodate this distinction
by allowing conditional variance to depend on past information. Time-varying
variances and covariances have a long history in financial modeling. See
[Bollerslev, Engle, and Wooldridge, 1988](https://public.econ.duke.edu/~boller/Published_Papers/jpe_88.pdf).

In the L7a lecture notebook, the Concept Review states zero mean, no correlation
with the market, and no correlation across assets. It leaves temporal dependence
unspecified. That is sufficient for the displayed single-period covariance
decomposition:

$$
\Sigma_g=\sigma^2_{g,M}\boldsymbol{\beta}\boldsymbol{\beta}^{\top}+D_g.
$$

The later Sharpe-ratio annualization note separately invokes independent
increments.

A useful clarification beside the SIM equation would be:

> These assumptions describe relationships within one trading day. Independence
> of a firm's residuals across trading days is an additional assumption,
> commonly imposed when modeling the SIM over time.

## Question 2 Dependence across firms

**Jeffrey:** How would we model
$\operatorname{Cov}(\varepsilon_i,\varepsilon_j)\ne0$? Is the zero-covariance
case actually true, and if not, what can we do?

**Codex:** Zero residual covariance is a simplifying assumption, and it can be
a poor approximation for related firms. Two banks, for example, can share
banking-sector shocks that the broad market index does not fully explain.

Here we are comparing different firms during the same period:

$$
\operatorname{Cov}(\varepsilon_{i,t},\varepsilon_{j,t}),\qquad i\ne j.
$$

The [L7a risky-assets example](CHEME-5660-L7a-Example-SIM-MinVar-RA-Fall-2026.ipynb)
already illustrates this. Its saved results report residual correlations of
**0.736 for BAC–C** and **0.617 for F–GM**. Those are sample estimates, but they
show why setting every residual covariance to zero can discard substantial
structure.

The direct extension is to retain the residual covariance matrix. Keep the
assumption that each residual is uncorrelated with the market. Then:

$$
\boxed{
\operatorname{Cov}(g_i,g_j)
=\beta_i\beta_j\sigma^2_{g,M}
+\operatorname{Cov}(\varepsilon_i,\varepsilon_j)
}
$$

In matrix form,

$$
\boxed{
\Sigma_g
=\underbrace{\sigma^2_{g,M}\boldsymbol{\beta}\boldsymbol{\beta}^{\top}}_{\text{market}}
+\underbrace{\Omega_\varepsilon}_{\text{residual covariance}}
}
$$

The lecture's diagonal matrix $D_g$ is the special case where
$\Omega_\varepsilon$ has zero off-diagonal entries. Allowing residual dependence
is well established in the factor-model literature. See
[Fan, Liao, and Mincheva, 2013](https://pmc.ncbi.nlm.nih.gov/articles/PMC3859166/).

This changes portfolio variance to

$$
\operatorname{Var}(g_p)
=\beta_p^2\sigma^2_{g,M}
+\sum_i w_i^2\sigma^2_{g,\varepsilon,i}
+\underbrace{2\sum_{i<j}w_iw_j
\operatorname{Cov}(\varepsilon_i,\varepsilon_j)}_{\text{term omitted by the SIM}}.
$$

For two positive holdings, positive residual covariance adds risk and reduces
the diversification benefit.

There are three useful ways to handle this.

### Estimate the full residual covariance

Fit each firm's regression, collect its residual series, and calculate their
sample covariance matrix. The example already does this in `Ω̂_ε`. With ordinary
least squares on the same observations and consistent covariance denominators,
adding this full matrix to the market term reconstructs the ordinary sample
covariance of growth rates. We recover the omitted relationships, but also
recover the large number of quantities that the SIM helped us avoid estimating.

### Shrink the estimated residual covariances toward zero

A simple construction is

$$
\widehat{\Omega}_{\varepsilon,\lambda}
=(1-\lambda)\widehat{\Omega}_\varepsilon
+\lambda\,\operatorname{diag}(\widehat{\Omega}_\varepsilon),
\qquad 0\leq\lambda\leq1.
$$

Here, $\operatorname{diag}(\widehat{\Omega}_\varepsilon)$ means the diagonal
matrix retaining the estimated residual variances. The choice $\lambda=0$
retains every estimated covariance, while $\lambda=1$ gives the diagonal
restriction. Intermediate values retain some dependence while reducing
estimation noise. Ledoit and Wolf specifically studied shrinking the full
sample covariance toward a single-index covariance estimate for portfolio
selection. See [Ledoit and Wolf, 2003](https://www.ledoit.net/Improved_JEF2003.pdf).

### Add factors that explain the shared residual movement

For example,

$$
g_{i,t}=\alpha_i+\beta_i g_{M,t}
+\gamma_i f_{\mathrm{sector},t}+u_{i,t}.
$$

A banking-sector factor could capture movement previously left in both banks'
residuals. This becomes a multiple-factor model. Remaining residual correlations
can still be estimated or regularized; adding factors does not guarantee that
they disappear. See
[Fan, Liao, and Mincheva, 2013](https://pmc.ncbi.nlm.nih.gov/articles/PMC3859166/).

For the lecture, I would describe the zero-covariance assumption as a deliberate
reduction in the number of parameters. The practical question is whether its
estimation advantage outweighs the dependence it omits. The minimum-variance
optimization itself stays the same—we supply it with a different covariance
estimate.

## Questions to explore later

- How much temporal dependence remains in the fitted residuals, and how does
  that compare with dependence in their squared values? The L6b advanced
  residual-diagnostics material is a starting point for the temporal question.
- Which residual correlations across firms persist in held-out data, and which
  are unstable estimates?
- How do the diagonal SIM, full sample covariance, and residual-shrinkage
  estimates change portfolio weights and realized risk? Choose any shrinkage
  parameter using training or validation data while reserving the final test
  period for evaluation.
- Does a sector factor explain the strong banking and automotive residual
  correlations more economically than estimating each pair separately?

## References

- Eric Zivot. *Single Index Model*. University of Washington, August 19, 2014.
  [Lecture notes](https://faculty.washington.edu/ezivot/econ424/singleindexslides.pdf).
- Tim Bollerslev, Robert F. Engle, and Jeffrey M. Wooldridge. 1988. *A Capital
  Asset Pricing Model with Time-Varying Covariances*. Journal of Political
  Economy 96(1), 116–131.
  [Author-hosted paper](https://public.econ.duke.edu/~boller/Published_Papers/jpe_88.pdf).
- Olivier Ledoit and Michael Wolf. 2003. *Improved Estimation of the Covariance
  Matrix of Stock Returns with an Application to Portfolio Selection*. Journal
  of Empirical Finance 10(5), 603–621.
  [Author-hosted paper](https://www.ledoit.net/Improved_JEF2003.pdf).
- Jianqing Fan, Yuan Liao, and Martina Mincheva. 2013. *Large Covariance
  Estimation by Thresholding Principal Orthogonal Complements*. Journal of the
  Royal Statistical Society Series B 75(4), 603–680.
  [Full text](https://pmc.ncbi.nlm.nih.gov/articles/PMC3859166/).
