# Economic Factors and Sector Pairs: Five Linear-Algebra Steps

Instructor working note, 2026-11-20. This note is not part of the lecture.

The whole model comes from two linear-algebra tools: least squares, which solves the normal equations, and the Cholesky factorization. Steps 1 to 3 are least-squares solves. Step 4 is a Cholesky factorization. Step 5 multiplies the results. I checked the identities of the five steps on random data (12 stocks, 3 sectors, 2 economic factors, 2,000 days), and each one holds to within $10^{-11}$. The joint-fit result under Step 1 is shown by algebra only.

## The recipe

__Initialize:__ Set up the data matrices. $\mathbf{G}$ ($T\times n$) holds the daily growth rates of the $n$ stocks. $\mathbf{X}$ ($T\times(K+2)$) holds the columns $\mathbf{1}$, $g_{m}$, and $h_{1},\dots,h_{K}$. $\mathbf{B}$ ($n\times 11$) holds the sector membership, with $B_{is}=1$ if stock $i$ is in sector $s$ and $0$ otherwise.

1. __Market and economic loadings:__ For each stock $i$, solve $\mathbf{X}^{\top}\mathbf{X}\,\boldsymbol{\theta}_{i}=\mathbf{X}^{\top}\mathbf{g}_{i}$ for $\boldsymbol{\theta}_{i}=(\alpha_{i},\beta_{i},\gamma_{i1},\dots,\gamma_{iK})$. All at once, $\boldsymbol{\Theta}=(\mathbf{X}^{\top}\mathbf{X})^{-1}\mathbf{X}^{\top}\mathbf{G}$. Form the residuals $\mathbf{E}=\mathbf{G}-\mathbf{X}\boldsymbol{\Theta}$.
2. __Sector factors:__ For each day $t$, solve $\mathbf{B}^{\top}\mathbf{B}\,\mathbf{f}(t)=\mathbf{B}^{\top}\boldsymbol{\varepsilon}(t)$, where $\boldsymbol{\varepsilon}(t)$ is row $t$ of $\mathbf{E}$. Because $\mathbf{B}^{\top}\mathbf{B}=\operatorname{diag}(n_{1},\dots,n_{11})$, the solution is the average residual of each sector. All days at once, $\mathbf{F}=\mathbf{E}\mathbf{B}(\mathbf{B}^{\top}\mathbf{B})^{-1}$.
3. __Sector loadings:__ For each stock $i$, solve $\mathbf{F}^{\top}\mathbf{F}\,\boldsymbol{\delta}_{i}=\mathbf{F}^{\top}\boldsymbol{\varepsilon}_{i}$, where $\boldsymbol{\varepsilon}_{i}$ is column $i$ of $\mathbf{E}$. All at once, $\boldsymbol{\Delta}=(\mathbf{F}^{\top}\mathbf{F})^{-1}\mathbf{F}^{\top}\mathbf{E}$. For the lecture's own-sector version, use only the column of the stock's sector: $\delta_{i}=\mathbf{f}_{s}^{\top}\boldsymbol{\varepsilon}_{i}/\mathbf{f}_{s}^{\top}\mathbf{f}_{s}$. Form the stock-specific residuals $\mathbf{U}=\mathbf{E}-\mathbf{F}\boldsymbol{\Delta}$.
4. __Unmix the factors:__ The simulation draws each series independently, but the real factors are correlated, so we first convert them into uncorrelated series. Stack $\boldsymbol{\Phi}=\begin{bmatrix}\mathbf{g}_{m} & \mathbf{H} & \mathbf{F}\end{bmatrix}$ ($T\times p$, with $p=1+K+11$). Compute the column averages $\boldsymbol{\mu}$ and the covariance matrix $\mathbf{\Sigma}_{\Phi}$, and factor $\mathbf{\Sigma}_{\Phi}=\mathbf{A}\mathbf{A}^{\top}$ (Cholesky). The unmixed factors $\mathbf{Z}=(\boldsymbol{\Phi}-\mathbf{1}\boldsymbol{\mu}^{\top})\mathbf{A}^{-\top}$ have unit variance and zero correlation, and $\mathbf{1}\boldsymbol{\mu}^{\top}+\mathbf{Z}\mathbf{A}^{\top}$ rebuilds $\boldsymbol{\Phi}$ exactly. This is the multiple-asset GBM mixing run backwards: we start from the correlated data and recover the independent pieces.
5. __Train the jump hidden Markov models:__ Fit one single-asset model to each column of $\mathbf{Z}$ ($p$ models) and to each column of $\mathbf{U}$ ($n$ models). Steps 1 to 4 match only the means, variances, and covariances. The models supply the fat tails, volatility clustering, and jump episodes. We train on $\mathbf{Z}$ rather than $\boldsymbol{\Phi}$, because uncorrelated columns can be drawn independently without losing any covariance. With $g_{m}$ in the first column, the first column of $\mathbf{Z}$ is the market shifted and scaled, so its model plays the role of the `SPY` model.
6. __Sample:__ Draw every column of $\mathbf{Z}$ and $\mathbf{U}$ independently for $T_{\mathrm{sim}}$ days. Mix the factors back with $\boldsymbol{\Phi}^{\mathrm{sim}}=\mathbf{1}\boldsymbol{\mu}^{\top}+\mathbf{Z}^{\mathrm{draw}}\mathbf{A}^{\top}$. Compose the growth rates with $\mathbf{G}^{\mathrm{sim}}=\mathbf{1}\boldsymbol{\alpha}^{\top}+\boldsymbol{\Phi}^{\mathrm{sim}}\boldsymbol{\Lambda}+\mathbf{U}^{\mathrm{draw}}$, where $\boldsymbol{\Lambda}$ ($p\times n$) stacks the $\beta$'s, the $\gamma$'s, and $\boldsymbol{\Delta}$. Compound each price with $S_{i}(t)=S_{i}(t-1)\exp\left(g_{i}(t)\,\Delta t\right)$.

__Output:__ The simulated factor paths $\boldsymbol{\Phi}^{\mathrm{sim}}$, the growth rates $\mathbf{G}^{\mathrm{sim}}$, and the prices of every stock.

__Check:__ The covariance of $\mathbf{G}^{\mathrm{sim}}$ should be close to $\boldsymbol{\Lambda}^{\top}\mathbf{\Sigma}_{\Phi}\boldsymbol{\Lambda}+\operatorname{diag}(\operatorname{Var}(u_{i}))$. This matches the covariance of $\mathbf{G}$ except for the stock-to-stock covariance that no factor explains.

Steps 1 to 4 of the recipe are derived in Steps 1 to 4 below. Recipe steps 5 and 6 are derived in Step 5 and in the section on the jump hidden Markov models.

## The model

For stock $i$ on day $t$:

$$
g_{i}(t) = \underbrace{\alpha_{i}}_{\text{baseline}} + \underbrace{\beta_{i}\,g_{m}(t)}_{\text{market}} + \underbrace{\sum_{k=1}^{K}\gamma_{ik}\,h_{k}(t)}_{\text{economic factors}} + \underbrace{\sum_{s=1}^{11}\delta_{is}\,f_{s}(t)}_{\text{sector factors}} + \underbrace{u_{i}(t)}_{\text{stock-specific}}
$$

The economic factors $h_{k}(t)$ must be daily series, for example the daily change in the 10-year Treasury yield or in the 10-year breakeven inflation rate. Unemployment, the CPI, and the trade balance are published monthly, so they need a daily market proxy. The lecture's version keeps only the stock's own sector, so $\delta_{is}=0$ for every sector except the sector of stock $i$.

## The matrices

| Matrix | Size | Contents |
|---|---|---|
| $\mathbf{G}$ | $T\times n$ | Growth rates. Column $i$ is stock $i$, row $t$ is day $t$. |
| $\mathbf{X}$ | $T\times(K+2)$ | Columns: $\mathbf{1}$, $g_{m}$, $h_{1},\dots,h_{K}$ |
| $\boldsymbol{\Theta}$ | $(K+2)\times n$ | Column $i$: $\alpha_{i}$, $\beta_{i}$, $\gamma_{i1},\dots,\gamma_{iK}$ |
| $\mathbf{E}$ | $T\times n$ | Residuals after Step 1 |
| $\mathbf{B}$ | $n\times 11$ | Sector membership: $B_{js}=1$ if stock $j$ is in sector $s$, else $0$ |
| $\mathbf{F}$ | $T\times 11$ | Sector factors. Column $s$ is $f_{s}$. |
| $\boldsymbol{\Delta}$ | $11\times n$ | Sector loadings. Entry $(s,i)$ is $\delta_{is}$. |
| $\mathbf{U}$ | $T\times n$ | Stock-specific residuals |
| $\boldsymbol{\Phi}$ | $T\times p$ | All the drawn factors: $g_{m}$, $h_{1},\dots,h_{K}$, $f_{1},\dots,f_{11}$, with $p=1+K+11$ |
| $\boldsymbol{\Lambda}$ | $p\times n$ | All the loadings, in the same order: the $\beta$'s, the $\gamma$'s, then $\boldsymbol{\Delta}$ |
| $\mathbf{\Sigma}_{\Phi}$ | $p\times p$ | Covariance matrix of the factors |
| $\mathbf{A}$ | $p\times p$ | Cholesky factor of $\mathbf{\Sigma}_{\Phi}$ |
| $\mathbf{Z}$ | $T\times p$ | Unmixed factors |

In matrix form, the model is:

$$
\mathbf{G} = \mathbf{1}\,\boldsymbol{\alpha}^{\top} + \boldsymbol{\Phi}\,\boldsymbol{\Lambda} + \mathbf{U}
$$

___

## Tool 1: Least squares and the normal equations

Fit $\mathbf{y}\approx\mathbf{X}\mathbf{b}$, where $\mathbf{y}$ has $T$ entries and $\mathbf{X}$ is $T\times m$. Least squares chooses $\mathbf{b}$ to minimize the squared length of the residual $\mathbf{e}=\mathbf{y}-\mathbf{X}\mathbf{b}$:

$$
\begin{align*}
\lVert\mathbf{y}-\mathbf{X}\mathbf{b}\rVert^{2} &= \left(\mathbf{y}-\mathbf{X}\mathbf{b}\right)^{\top}\left(\mathbf{y}-\mathbf{X}\mathbf{b}\right) && \text{squared length}\\
&= \mathbf{y}^{\top}\mathbf{y}-\mathbf{y}^{\top}\mathbf{X}\mathbf{b}-\mathbf{b}^{\top}\mathbf{X}^{\top}\mathbf{y}+\mathbf{b}^{\top}\mathbf{X}^{\top}\mathbf{X}\mathbf{b} && \text{multiply out}\\
&= \mathbf{y}^{\top}\mathbf{y}-2\,\mathbf{b}^{\top}\mathbf{X}^{\top}\mathbf{y}+\mathbf{b}^{\top}\mathbf{X}^{\top}\mathbf{X}\mathbf{b} && \mathbf{y}^{\top}\mathbf{X}\mathbf{b} \text{ is a number, equal to its transpose}
\end{align*}
$$

Take the gradient with respect to $\mathbf{b}$, using $\nabla_{\mathbf{b}}(\mathbf{b}^{\top}\mathbf{c})=\mathbf{c}$ and $\nabla_{\mathbf{b}}(\mathbf{b}^{\top}\mathbf{M}\mathbf{b})=2\mathbf{M}\mathbf{b}$ for a symmetric $\mathbf{M}$:

$$
\begin{align*}
\nabla_{\mathbf{b}}\lVert\mathbf{y}-\mathbf{X}\mathbf{b}\rVert^{2} &= -2\,\mathbf{X}^{\top}\mathbf{y}+2\,\mathbf{X}^{\top}\mathbf{X}\mathbf{b} && \text{the two gradient rules}\\
\mathbf{0} &= -2\,\mathbf{X}^{\top}\mathbf{y}+2\,\mathbf{X}^{\top}\mathbf{X}\mathbf{b} && \text{set to zero at the minimum}\\
\mathbf{X}^{\top}\mathbf{X}\,\mathbf{b} &= \mathbf{X}^{\top}\mathbf{y} && \text{the normal equations}
\end{align*}
$$

This is a system of $m$ equations in $m$ unknowns. In Julia, `b = X \ y` solves it.

__The residual is orthogonal to every column of $\mathbf{X}$:__

$$
\begin{align*}
\mathbf{X}^{\top}\mathbf{e} &= \mathbf{X}^{\top}\left(\mathbf{y}-\mathbf{X}\mathbf{b}\right) && \text{definition of } \mathbf{e}\\
&= \mathbf{X}^{\top}\mathbf{y}-\mathbf{X}^{\top}\mathbf{X}\mathbf{b} && \text{multiply out}\\
&= \mathbf{0} && \text{the normal equations}
\end{align*}
$$

Row $a$ of $\mathbf{X}^{\top}\mathbf{e}=\mathbf{0}$ reads $\sum_{t}X_{ta}\,e(t)=0$. If $\mathbf{X}$ has a column of ones, that row says $\sum_{t}e(t)=0$. For any other column $\mathbf{x}$, the residual then has zero covariance with it:

$$
(T-1)\operatorname{Cov}(\mathbf{x},\mathbf{e}) = \sum_{t}\left(x(t)-\bar{x}\right)e(t) = \sum_{t}x(t)\,e(t)-\bar{x}\sum_{t}e(t) = 0-\bar{x}\cdot 0 = 0
$$

__Many right-hand sides:__ For $\mathbf{Y}\approx\mathbf{X}\mathbf{C}$, each column of $\mathbf{Y}$ is a separate fit with the same matrix $\mathbf{X}^{\top}\mathbf{X}$. Stacking the columns gives $\mathbf{X}^{\top}\mathbf{X}\,\mathbf{C}=\mathbf{X}^{\top}\mathbf{Y}$, and $\mathbf{X}^{\top}(\mathbf{Y}-\mathbf{X}\mathbf{C})=\mathbf{0}$.

## Tool 2: The covariance of a mixed vector

Let $\mathbf{x}(t)$ be a random vector with covariance matrix $\mathbf{\Sigma}_{x}$, and let $\mathbf{M}$ be a fixed matrix. Entry $(s,r)$ of the covariance matrix of $\mathbf{y}=\mathbf{M}\mathbf{x}$ is:

$$
\begin{align*}
\operatorname{Cov}\left(\sum_{q}M_{sq}\,x_{q},\;\sum_{q'}M_{rq'}\,x_{q'}\right) &= \sum_{q}\sum_{q'}M_{sq}\,M_{rq'}\operatorname{Cov}(x_{q},x_{q'}) && \text{covariance of two sums}\\
&= \left(\mathbf{M}\,\mathbf{\Sigma}_{x}\,\mathbf{M}^{\top}\right)_{sr} && \text{matrix product}
\end{align*}
$$

So $\operatorname{Cov}(\mathbf{M}\mathbf{x})=\mathbf{M}\,\mathbf{\Sigma}_{x}\,\mathbf{M}^{\top}$.

___

## Step 1. Fit every stock on the market and the economic factors

$$
\mathbf{G}\approx\mathbf{X}\,\boldsymbol{\Theta},
\qquad
\mathbf{X}^{\top}\mathbf{X}\,\boldsymbol{\Theta}=\mathbf{X}^{\top}\mathbf{G},
\qquad
\mathbf{E}=\mathbf{G}-\mathbf{X}\,\boldsymbol{\Theta}
$$

__Written out for one economic factor ($K=1$) and one stock $i$:__

$$
\underbrace{\begin{bmatrix}
T & \sum_{t}g_{m} & \sum_{t}h_{1}\\
\sum_{t}g_{m} & \sum_{t}g_{m}^{2} & \sum_{t}g_{m}h_{1}\\
\sum_{t}h_{1} & \sum_{t}g_{m}h_{1} & \sum_{t}h_{1}^{2}
\end{bmatrix}}_{\mathbf{X}^{\top}\mathbf{X}}
\begin{bmatrix}\alpha_{i}\\ \beta_{i}\\ \gamma_{i1}\end{bmatrix}
=
\underbrace{\begin{bmatrix}
\sum_{t}g_{i}\\ \sum_{t}g_{m}\,g_{i}\\ \sum_{t}h_{1}\,g_{i}
\end{bmatrix}}_{\mathbf{X}^{\top}\mathbf{g}_{i}}
$$

This is three equations in three unknowns, and every stock uses the same $3\times 3$ matrix. The off-diagonal sums couple the unknowns. If those sums were zero, each equation would contain one unknown, and each loading would be a one-factor slope. The companion note made them zero by cleaning the economic factors first. Here, the solve handles the coupling, so the economic factors need no cleaning.

__What the residuals inherit:__ By Tool 1, $\mathbf{X}^{\top}\mathbf{E}=\mathbf{0}$. Every column of $\mathbf{E}$ sums to zero and has zero covariance with $g_{m}$ and with every $h_{k}$.

### Why Step 1 can leave out the sector factors

Step 1 does not assume that the sector factors contribute nothing. Their contribution stays in the residuals $\mathbf{E}$, and Steps 2 and 3 take it back out. Leaving the sector factors out of Step 1 changes no coefficient, because of how Step 2 builds them.

__The sector factors are orthogonal to $\mathbf{X}$:__ Step 2 builds the sector factors from the residuals of Step 1, $\mathbf{F}=\mathbf{E}\,\mathbf{B}\left(\mathbf{B}^{\top}\mathbf{B}\right)^{-1}$. Then:

$$
\mathbf{X}^{\top}\mathbf{F}=\underbrace{\mathbf{X}^{\top}\mathbf{E}}_{=\,\mathbf{0}}\,\mathbf{B}\left(\mathbf{B}^{\top}\mathbf{B}\right)^{-1}=\mathbf{0}
$$

__The joint fit splits in two:__ Fit all the factors at once, $\mathbf{G}\approx\begin{bmatrix}\mathbf{X} & \mathbf{F}\end{bmatrix}\begin{bmatrix}\boldsymbol{\Theta}'\\ \boldsymbol{\Delta}'\end{bmatrix}$. The normal equations of Tool 1 are:

$$
\begin{bmatrix}
\mathbf{X}^{\top}\mathbf{X} & \mathbf{X}^{\top}\mathbf{F}\\
\mathbf{F}^{\top}\mathbf{X} & \mathbf{F}^{\top}\mathbf{F}
\end{bmatrix}
\begin{bmatrix}\boldsymbol{\Theta}'\\ \boldsymbol{\Delta}'\end{bmatrix}
=
\begin{bmatrix}\mathbf{X}^{\top}\mathbf{G}\\ \mathbf{F}^{\top}\mathbf{G}\end{bmatrix}
$$

With $\mathbf{X}^{\top}\mathbf{F}=\mathbf{0}$, the off-diagonal blocks are zero, and the two block rows separate:

$$
\begin{align*}
\mathbf{X}^{\top}\mathbf{X}\,\boldsymbol{\Theta}' &= \mathbf{X}^{\top}\mathbf{G} && \text{first block row: the system of Step 1, so } \boldsymbol{\Theta}'=\boldsymbol{\Theta}\\
\mathbf{F}^{\top}\mathbf{F}\,\boldsymbol{\Delta}' &= \mathbf{F}^{\top}\mathbf{G} && \text{second block row}\\
&= \mathbf{F}^{\top}\left(\mathbf{X}\,\boldsymbol{\Theta}+\mathbf{E}\right) && \mathbf{G}=\mathbf{X}\,\boldsymbol{\Theta}+\mathbf{E}\\
&= \left(\mathbf{X}^{\top}\mathbf{F}\right)^{\top}\boldsymbol{\Theta}+\mathbf{F}^{\top}\mathbf{E} && \text{multiply out}\\
&= \mathbf{F}^{\top}\mathbf{E} && \mathbf{X}^{\top}\mathbf{F}=\mathbf{0}\text{: the system of Step 3, so } \boldsymbol{\Delta}'=\boldsymbol{\Delta}
\end{align*}
$$

Steps 1 and 3 together give exactly the joint fit. The general result is the Frisch–Waugh–Lovell theorem.

__The catch: the zero holds by construction.__ The sector factor here is the part of the sector's movement that the market and the economic factors do not explain. A raw sector series $\mathbf{S}$, such as the sector's average growth rate or a sector ETF, moves with the market, so $\mathbf{X}^{\top}\mathbf{S}\neq\mathbf{0}$. If the data follow $\mathbf{G}=\mathbf{X}\,\boldsymbol{\Theta}+\mathbf{S}\,\boldsymbol{\Delta}+\mathbf{U}$ with $\mathbf{X}^{\top}\mathbf{U}=\mathbf{0}$, Step 1 gives:

$$
\begin{align*}
\hat{\boldsymbol{\Theta}} &= \left(\mathbf{X}^{\top}\mathbf{X}\right)^{-1}\mathbf{X}^{\top}\mathbf{G} && \text{Step 1}\\
&= \left(\mathbf{X}^{\top}\mathbf{X}\right)^{-1}\mathbf{X}^{\top}\left(\mathbf{X}\,\boldsymbol{\Theta}+\mathbf{S}\,\boldsymbol{\Delta}+\mathbf{U}\right) && \text{substitute } \mathbf{G}\\
&= \boldsymbol{\Theta}+\left(\mathbf{X}^{\top}\mathbf{X}\right)^{-1}\mathbf{X}^{\top}\mathbf{S}\,\boldsymbol{\Delta}+\left(\mathbf{X}^{\top}\mathbf{X}\right)^{-1}\mathbf{X}^{\top}\mathbf{U} && \text{multiply out; } \left(\mathbf{X}^{\top}\mathbf{X}\right)^{-1}\mathbf{X}^{\top}\mathbf{X}=\mathbf{I}\\
&= \boldsymbol{\Theta}+\underbrace{\left(\mathbf{X}^{\top}\mathbf{X}\right)^{-1}\mathbf{X}^{\top}\mathbf{S}\,\boldsymbol{\Delta}}_{\text{bias}} && \mathbf{X}^{\top}\mathbf{U}=\mathbf{0}
\end{align*}
$$

Leaving out a raw sector series would bias the $\beta$'s and the $\gamma$'s. The bias term is zero when $\mathbf{X}^{\top}\mathbf{S}=\mathbf{0}$, and the sector factors of Step 2 satisfy that condition.

__The modeling choice:__ The market goes first. It gets credit for everything it can explain, including the market-like part of each sector's move. The lecture's result $f_{s}=\bar{g}_{s}-\bar{\alpha}_{s}-\bar{\beta}_{s}\,g_{m}$ says the same thing: the sector factor is what is left of the sector average after the market takes its share. A joint fit with a raw sector series would split the credit differently. The steps give every overlap to the market and the economic factors.

___

## Step 2. Build the sector factors: one system per day

On day $t$, the vector of the $n$ residuals is $\boldsymbol{\varepsilon}(t)$, which is row $t$ of $\mathbf{E}$ written as a column. Fit it with the 11 sector factors:

$$
\boldsymbol{\varepsilon}(t)\approx\mathbf{B}\,\mathbf{f}(t),
\qquad
\mathbf{B}^{\top}\mathbf{B}\,\mathbf{f}(t)=\mathbf{B}^{\top}\boldsymbol{\varepsilon}(t)
$$

__Written out for five stocks in two sectors:__ Stocks 1 to 3 are in sector 1, and stocks 4 and 5 are in sector 2:

$$
\mathbf{B}=\begin{bmatrix}1&0\\1&0\\1&0\\0&1\\0&1\end{bmatrix},
\qquad
\mathbf{B}^{\top}\mathbf{B}=\begin{bmatrix}3&0\\0&2\end{bmatrix},
\qquad
\mathbf{B}^{\top}\boldsymbol{\varepsilon}(t)=\begin{bmatrix}\varepsilon_{1}+\varepsilon_{2}+\varepsilon_{3}\\ \varepsilon_{4}+\varepsilon_{5}\end{bmatrix}
$$

The normal equations are:

$$
\begin{bmatrix}3&0\\0&2\end{bmatrix}\begin{bmatrix}f_{1}(t)\\ f_{2}(t)\end{bmatrix}=\begin{bmatrix}\varepsilon_{1}+\varepsilon_{2}+\varepsilon_{3}\\ \varepsilon_{4}+\varepsilon_{5}\end{bmatrix}
\quad\Longrightarrow\quad
f_{1}(t)=\frac{\varepsilon_{1}+\varepsilon_{2}+\varepsilon_{3}}{3},
\qquad
f_{2}(t)=\frac{\varepsilon_{4}+\varepsilon_{5}}{2}
$$

__Any number of stocks and sectors:__ Each row of $\mathbf{B}$ has one $1$, because each stock is in one sector. Then:

$$
\left(\mathbf{B}^{\top}\mathbf{B}\right)_{sr}=\sum_{j}B_{js}\,B_{jr}=\begin{cases}n_{s} & r=s\\ 0 & r\neq s\end{cases}
\qquad
\left(\mathbf{B}^{\top}\boldsymbol{\varepsilon}(t)\right)_{s}=\sum_{j\in s}\varepsilon_{j}(t)
$$

The matrix $\mathbf{B}^{\top}\mathbf{B}$ is diagonal with the sector counts $n_{s}$ on the diagonal, so the solution is the sector average: $f_{s}(t)=\frac{1}{n_{s}}\sum_{j\in s}\varepsilon_{j}(t)$.

__All days at once:__ Transposing $\mathbf{f}(t)=(\mathbf{B}^{\top}\mathbf{B})^{-1}\mathbf{B}^{\top}\boldsymbol{\varepsilon}(t)$ gives row $t$ of $\mathbf{F}$. Stacking the rows gives:

$$
\mathbf{F}=\mathbf{E}\,\mathbf{B}\left(\mathbf{B}^{\top}\mathbf{B}\right)^{-1}
$$

__What the sector factors inherit:__

$$
\mathbf{X}^{\top}\mathbf{F}=\underbrace{\mathbf{X}^{\top}\mathbf{E}}_{=\,\mathbf{0}\text{ (Step 1)}}\mathbf{B}\left(\mathbf{B}^{\top}\mathbf{B}\right)^{-1}=\mathbf{0}
$$

Every sector factor sums to zero and has zero covariance with $g_{m}$ and with every $h_{k}$.

### Why Step 2 can solve for $\mathbf{f}(t)=\left(\mathbf{B}^{\top}\mathbf{B}\right)^{-1}\mathbf{B}^{\top}\boldsymbol{\varepsilon}(t)$

__Step 2 is a least-squares fit, one per day:__ On day $t$, there are $n$ equations, one per stock, and 11 unknowns, the sector factor values. Row $j$ of $\mathbf{B}$ picks out the factor of the sector $s(j)$ of stock $j$, so equation $j$ reads $\varepsilon_{j}(t)\approx f_{s(j)}(t)$. With $n$ much larger than 11, no $\mathbf{f}(t)$ satisfies every equation. Least squares chooses the $\mathbf{f}(t)$ that comes closest to all $n$ residuals:

$$
\min_{\mathbf{f}(t)}\;\lVert\boldsymbol{\varepsilon}(t)-\mathbf{B}\,\mathbf{f}(t)\rVert^{2}
$$

This is Tool 1 with $\mathbf{X}\to\mathbf{B}$, $\mathbf{y}\to\boldsymbol{\varepsilon}(t)$, and $\mathbf{b}\to\mathbf{f}(t)$. The normal equations are therefore $\mathbf{B}^{\top}\mathbf{B}\,\mathbf{f}(t)=\mathbf{B}^{\top}\boldsymbol{\varepsilon}(t)$. Step 2 has the same structure as Step 1, with the roles of days and stocks swapped:

| | Step 1 | Step 2 |
|---|---|---|
| Rows of the system | $T$ days | $n$ stocks |
| Unknowns | $K+2$ per stock | 11 per day |
| Number of fits | $n$, one per stock | $T$, one per day |
| Matrix shared by every fit | $\mathbf{X}^{\top}\mathbf{X}$ | $\mathbf{B}^{\top}\mathbf{B}$ |

__Why $\mathbf{B}^{\top}\mathbf{B}$ has an inverse:__ Column $s$ of $\mathbf{B}$ marks the stocks of sector $s$. Each stock is in exactly one sector, so no two columns have a $1$ in the same row. Columns like these are linearly independent as long as none of them is all zeros. The general formula above shows this directly: $\mathbf{B}^{\top}\mathbf{B}=\operatorname{diag}(n_{1},\dots,n_{11})$, with the inverse $\operatorname{diag}(1/n_{1},\dots,1/n_{11})$. The only requirement is that every sector has at least one stock. The lecture's leave-one-out loading needs at least two.

__Multiply both sides by the inverse:__

$$
\begin{align*}
\mathbf{B}^{\top}\mathbf{B}\,\mathbf{f}(t) &= \mathbf{B}^{\top}\boldsymbol{\varepsilon}(t) && \text{normal equations}\\
\mathbf{f}(t) &= \left(\mathbf{B}^{\top}\mathbf{B}\right)^{-1}\mathbf{B}^{\top}\boldsymbol{\varepsilon}(t) && \text{multiply on the left by } \left(\mathbf{B}^{\top}\mathbf{B}\right)^{-1}\\
f_{s}(t) &= \frac{1}{n_{s}}\sum_{j\in s}\varepsilon_{j}(t) && \text{entry } s\text{: the inverse divides the sector sum by } n_{s}
\end{align*}
$$

For this $\mathbf{B}$, the inverse formula and the sector average are the same thing. Neither one is a shortcut or an approximation. In Julia, `F = E * B / (B' * B)` computes the same $\mathbf{F}$ for all days at once. The slash solves the system without forming the inverse, which affects only the rounding, not the answer.

___

## Step 3. Fit each stock's residual on the sector factors

__All sectors:__ Each stock loads on all 11 sector factors:

$$
\mathbf{E}\approx\mathbf{F}\,\boldsymbol{\Delta},
\qquad
\mathbf{F}^{\top}\mathbf{F}\,\boldsymbol{\Delta}=\mathbf{F}^{\top}\mathbf{E},
\qquad
\mathbf{U}=\mathbf{E}-\mathbf{F}\,\boldsymbol{\Delta}
$$

The $11\times 11$ matrix $\mathbf{F}^{\top}\mathbf{F}$ has the entries $\sum_{t}f_{s}(t)\,f_{r}(t)$. It is not diagonal, because the sector factors are correlated.

__Own sector only (the lecture):__ For stock $i$ in sector $s$, the fit uses the single column $\mathbf{f}_{s}$. The system is $1\times 1$:

$$
\left(\mathbf{f}_{s}^{\top}\mathbf{f}_{s}\right)\delta_{i}=\mathbf{f}_{s}^{\top}\boldsymbol{\varepsilon}_{i}
\quad\Longrightarrow\quad
\delta_{i}=\frac{\sum_{t}f_{s}(t)\,\varepsilon_{i}(t)}{\sum_{t}f_{s}(t)^{2}}
$$

Column $i$ of $\boldsymbol{\Delta}$ then has $\delta_{i}$ in row $s$ and zeros elsewhere.

__What the stock-specific residuals inherit:__ In the all-sectors fit, Tool 1 gives $\mathbf{F}^{\top}\mathbf{U}=\mathbf{0}$, and:

$$
\mathbf{X}^{\top}\mathbf{U}=\mathbf{X}^{\top}\mathbf{E}-\mathbf{X}^{\top}\mathbf{F}\,\boldsymbol{\Delta}=\mathbf{0}-\mathbf{0}\,\boldsymbol{\Delta}=\mathbf{0}
$$

In the own-sector fit, $\mathbf{f}_{s}^{\top}\mathbf{u}_{i}=0$ and $\mathbf{X}^{\top}\mathbf{u}_{i}=\mathbf{0}$ for each stock.

__The lecture's leave-one-out loading:__ The lecture fits $\delta_{i}$ on the sector factor computed without stock $i$, so that the stock's own residual is not on both sides of the fit. It then rescales the slopes by $c_{s}$. This loading is not the solution of the system above, so $\mathbf{f}_{s}^{\top}\mathbf{u}_{i}\neq 0$. Step 5 shows what that changes.

___

## Step 4. Keep every factor correlation: the Cholesky factorization

Stack all the drawn factors and compute their averages and covariance matrix:

$$
\boldsymbol{\Phi}=\begin{bmatrix}\mathbf{g}_{m} & \mathbf{h}_{1} & \cdots & \mathbf{h}_{K} & \mathbf{f}_{1} & \cdots & \mathbf{f}_{11}\end{bmatrix},
\qquad
\mathbf{\Sigma}_{\Phi}=\frac{1}{T-1}\left(\boldsymbol{\Phi}-\mathbf{1}\boldsymbol{\mu}^{\top}\right)^{\top}\left(\boldsymbol{\Phi}-\mathbf{1}\boldsymbol{\mu}^{\top}\right)
$$

Here $\boldsymbol{\mu}$ holds the average of each column of $\boldsymbol{\Phi}$.

__The covariance matrix has two blocks:__ Step 2 showed that every sector factor has zero covariance with $g_{m}$ and with every $h_{k}$. The corner blocks are therefore zero:

$$
\mathbf{\Sigma}_{\Phi}=\begin{bmatrix}\mathbf{\Sigma}_{X} & \mathbf{0}\\ \mathbf{0} & \mathbf{\Sigma}_{f}\end{bmatrix}
$$

The block $\mathbf{\Sigma}_{X}$ holds the covariances of $g_{m}$ and the $h_{k}$, and $\mathbf{\Sigma}_{f}$ holds the covariances of the 11 sector factors.

__The Cholesky factorization is a system of equations:__ We need a lower-triangular $\mathbf{A}$ with $\mathbf{A}\mathbf{A}^{\top}=\mathbf{\Sigma}_{\Phi}$. Written out for a $2\times 2$ block:

$$
\begin{bmatrix}a_{11}&0\\a_{21}&a_{22}\end{bmatrix}
\begin{bmatrix}a_{11}&a_{21}\\0&a_{22}\end{bmatrix}
=
\begin{bmatrix}a_{11}^{2} & a_{11}a_{21}\\ a_{11}a_{21} & a_{21}^{2}+a_{22}^{2}\end{bmatrix}
=
\begin{bmatrix}\sigma_{11}&\sigma_{12}\\ \sigma_{12}&\sigma_{22}\end{bmatrix}
$$

This gives three equations in three unknowns, and they solve from the top down:

$$
\begin{align*}
a_{11}^{2} &= \sigma_{11} && \Longrightarrow\quad a_{11}=\sqrt{\sigma_{11}}\\
a_{11}\,a_{21} &= \sigma_{12} && \Longrightarrow\quad a_{21}=\sigma_{12}/a_{11}\\
a_{21}^{2}+a_{22}^{2} &= \sigma_{22} && \Longrightarrow\quad a_{22}=\sqrt{\sigma_{22}-a_{21}^{2}}
\end{align*}
$$

For a $p\times p$ matrix, there are $p(p+1)/2$ equations and $p(p+1)/2$ unknowns. Because $\mathbf{A}$ is triangular, each new equation adds one new unknown, so the system solves one row at a time. In Julia, `A = cholesky(Σ).L` solves it. A block-diagonal $\mathbf{\Sigma}_{\Phi}$ gives a block-diagonal $\mathbf{A}$: the market and the economic factors mix only with each other, and the 11 sector factors mix only with each other.

__Unmix the data:__

$$
\mathbf{Z}=\left(\boldsymbol{\Phi}-\mathbf{1}\boldsymbol{\mu}^{\top}\right)\mathbf{A}^{-\top}
\qquad\text{row by row:}\qquad
\mathbf{z}(t)=\mathbf{A}^{-1}\left(\boldsymbol{\phi}(t)-\boldsymbol{\mu}\right)
$$

$$
\begin{align*}
\operatorname{Cov}(\mathbf{z}) &= \mathbf{A}^{-1}\,\mathbf{\Sigma}_{\Phi}\,\mathbf{A}^{-\top} && \text{Tool 2 with } \mathbf{M}=\mathbf{A}^{-1}\\
&= \mathbf{A}^{-1}\,\mathbf{A}\,\mathbf{A}^{\top}\,\mathbf{A}^{-\top} && \mathbf{\Sigma}_{\Phi}=\mathbf{A}\mathbf{A}^{\top}\\
&= \mathbf{I} && \mathbf{A}^{-1}\mathbf{A}=\mathbf{I},\ \mathbf{A}^{\top}\mathbf{A}^{-\top}=\mathbf{I}
\end{align*}
$$

In the data, the $p$ unmixed series have unit variance and are uncorrelated. Mixing them back recovers the data exactly: $\boldsymbol{\Phi}=\mathbf{1}\boldsymbol{\mu}^{\top}+\mathbf{Z}\mathbf{A}^{\top}$. With $g_{m}$ in the first column, row 1 of $\mathbf{A}$ has only $a_{11}$, so $g_{m}(t)=\mu_{1}+a_{11}\,z_{1}(t)$. The market's unmixed series is the market itself, shifted and scaled.

___

## Step 5. Compose the growth rates and get the covariance

__The data, rebuilt from Steps 1 to 3:__

$$
\begin{align*}
\mathbf{G} &= \mathbf{X}\,\boldsymbol{\Theta}+\mathbf{E} && \text{Step 1}\\
&= \mathbf{X}\,\boldsymbol{\Theta}+\mathbf{F}\,\boldsymbol{\Delta}+\mathbf{U} && \text{Step 3}\\
&= \mathbf{1}\,\boldsymbol{\alpha}^{\top}+\begin{bmatrix}\mathbf{g}_{m} & \mathbf{h}_{1} & \cdots & \mathbf{h}_{K}\end{bmatrix}\boldsymbol{\Theta}_{2:\mathrm{end}}+\mathbf{F}\,\boldsymbol{\Delta}+\mathbf{U} && \text{split off the column of ones; } \boldsymbol{\alpha}^{\top} \text{ is row 1 of } \boldsymbol{\Theta}\\
&= \mathbf{1}\,\boldsymbol{\alpha}^{\top}+\boldsymbol{\Phi}\,\boldsymbol{\Lambda}+\mathbf{U} && \boldsymbol{\Lambda}=\begin{bmatrix}\boldsymbol{\Theta}_{2:\mathrm{end}}\\ \boldsymbol{\Delta}\end{bmatrix}\text{, block multiplication}
\end{align*}
$$

__The simulation:__ Fit one jump hidden Markov model to each column of $\mathbf{Z}$ and each column of $\mathbf{U}$. Draw every column independently, then mix and compose:

$$
\boldsymbol{\Phi}^{\mathrm{sim}}=\mathbf{1}\boldsymbol{\mu}^{\top}+\mathbf{Z}^{\mathrm{draw}}\mathbf{A}^{\top},
\qquad
\mathbf{G}^{\mathrm{sim}}=\mathbf{1}\,\boldsymbol{\alpha}^{\top}+\boldsymbol{\Phi}^{\mathrm{sim}}\boldsymbol{\Lambda}+\mathbf{U}^{\mathrm{draw}}\operatorname{diag}(\boldsymbol{\psi})
$$

__Simulated covariance:__ Row $t$ reads $\mathbf{g}(t)=\boldsymbol{\alpha}+\boldsymbol{\Lambda}^{\top}\boldsymbol{\phi}(t)+\operatorname{diag}(\boldsymbol{\psi})\,\mathbf{u}(t)$. The draws are independent, and each model matches the variance of its column, so $\operatorname{Cov}(\mathbf{z}^{\mathrm{draw}})=\mathbf{I}$ and $\operatorname{Cov}(\mathbf{u}^{\mathrm{draw}})=\operatorname{diag}(\operatorname{Var}(u_{i}))$:

$$
\begin{align*}
\operatorname{Cov}(\mathbf{g}^{\mathrm{sim}}) &= \boldsymbol{\Lambda}^{\top}\operatorname{Cov}(\boldsymbol{\phi}^{\mathrm{sim}})\,\boldsymbol{\Lambda}+\operatorname{diag}(\boldsymbol{\psi})\operatorname{Cov}(\mathbf{u}^{\mathrm{draw}})\operatorname{diag}(\boldsymbol{\psi}) && \text{Tool 2; independent draws, no cross terms}\\
&= \boldsymbol{\Lambda}^{\top}\mathbf{A}\,\mathbf{I}\,\mathbf{A}^{\top}\boldsymbol{\Lambda}+\operatorname{diag}\left(\psi_{i}^{2}\operatorname{Var}(u_{i})\right) && \text{Tool 2 for } \boldsymbol{\phi}^{\mathrm{sim}}=\boldsymbol{\mu}+\mathbf{A}\,\mathbf{z}^{\mathrm{draw}}\\
&= \boldsymbol{\Lambda}^{\top}\mathbf{\Sigma}_{\Phi}\,\boldsymbol{\Lambda}+\operatorname{diag}\left(\psi_{i}^{2}\operatorname{Var}(u_{i})\right) && \mathbf{A}\mathbf{A}^{\top}=\mathbf{\Sigma}_{\Phi}
\end{align*}
$$

__Data covariance (all-sectors fit):__ Steps 1 and 3 give $\mathbf{X}^{\top}\mathbf{U}=\mathbf{0}$ and $\mathbf{F}^{\top}\mathbf{U}=\mathbf{0}$. By Tool 1, every factor then has zero covariance with every $u_{i}$, and the cross terms drop out:

$$
\begin{align*}
\operatorname{Cov}(\mathbf{g}) &= \boldsymbol{\Lambda}^{\top}\mathbf{\Sigma}_{\Phi}\,\boldsymbol{\Lambda}+\boldsymbol{\Lambda}^{\top}\underbrace{\operatorname{Cov}(\boldsymbol{\phi},\mathbf{u})}_{=\,\mathbf{0}}+\underbrace{\operatorname{Cov}(\mathbf{u},\boldsymbol{\phi})}_{=\,\mathbf{0}}\boldsymbol{\Lambda}+\mathbf{\Sigma}_{u} && \text{covariance of } \boldsymbol{\Lambda}^{\top}\boldsymbol{\phi}+\mathbf{u}\\
&= \boldsymbol{\Lambda}^{\top}\mathbf{\Sigma}_{\Phi}\,\boldsymbol{\Lambda}+\mathbf{\Sigma}_{u} && \text{drop the zero terms}
\end{align*}
$$

__Comparing the two:__ The diagonals agree with $\psi_{i}=1$. The simulation drops only the off-diagonal entries of $\mathbf{\Sigma}_{u}$, the stock-to-stock covariance that no factor explains.

* __Own-sector fit:__ Column $i$ of $\boldsymbol{\Lambda}$ is nonzero only on $g_{m}$, the $h_{k}$, and the stock's own $f_{s}$, and $u_{i}$ is orthogonal to all of these. The diagonals again agree with $\psi_{i}=1$.
* __The lecture's leave-one-out loading:__ This loading leaves $\operatorname{Cov}(f_{s},u_{i})\neq 0$, so the diagonal gains the term $2\,\delta_{i}\operatorname{Cov}(f_{s},u_{i})$. The residual scale puts this term back: $\psi_{i}^{2}=1+2\,\delta_{i}\operatorname{Cov}(f_{s},u_{i})/\operatorname{Var}(u_{i})$.

__One entry of $\boldsymbol{\Lambda}^{\top}\mathbf{\Sigma}_{\Phi}\,\boldsymbol{\Lambda}$:__ Take stock $i$ in sector $s$ and stock $j$ in sector $r$, with the own-sector fit and one economic factor ($K=1$). The block structure of Step 4 gives:

$$
\begin{align*}
\left(\boldsymbol{\Lambda}^{\top}\mathbf{\Sigma}_{\Phi}\,\boldsymbol{\Lambda}\right)_{ij}
&= \begin{bmatrix}\beta_{i}&\gamma_{i1}\end{bmatrix}\mathbf{\Sigma}_{X}\begin{bmatrix}\beta_{j}\\ \gamma_{j1}\end{bmatrix}+\delta_{i}\,\delta_{j}\left(\mathbf{\Sigma}_{f}\right)_{sr} && \text{the two blocks}\\
&= \underbrace{\beta_{i}\beta_{j}\operatorname{Var}(g_{m})}_{\text{market}}+\underbrace{\left(\beta_{i}\gamma_{j1}+\gamma_{i1}\beta_{j}\right)\operatorname{Cov}(g_{m},h_{1})+\gamma_{i1}\gamma_{j1}\operatorname{Var}(h_{1})}_{\text{economic factor}}+\underbrace{\delta_{i}\,\delta_{j}\operatorname{Cov}(f_{s},f_{r})}_{\text{sector pair}} && \text{multiply out}
\end{align*}
$$

The sector-pair term is the covariance of the two sector factors in the data, for example Utilities and Real Estate. The middle term includes $\operatorname{Cov}(g_{m},h_{1})$, because Step 1 did not clean the economic factor.

___

## Where the jump hidden Markov models come in

Steps 1 to 5 run once on the historical data. They give fixed matrices: $\boldsymbol{\Theta}$, $\boldsymbol{\Delta}$, $\mathbf{A}$, and $\boldsymbol{\psi}$. The jump hidden Markov models enter in one place: the columns of $\mathbf{Z}$ and $\mathbf{U}$.

| Columns | Number of models |
|---|---|
| $\mathbf{Z}$: the unmixed market, economic factors, and sector factors | $p=1+K+11$ |
| $\mathbf{U}$: the stock-specific residuals | $n$ |

Each model gives its column the fat tails, volatility clustering, and jump episodes of the data. If every model were replaced by Normal draws with the same variance, $\operatorname{Cov}(\mathbf{g}^{\mathrm{sim}})$ would not change, but every path would lose its tails and its clustering.

* __The cost of mixing:__ Each simulated sector factor is a mix of several columns of $\mathbf{Z}^{\mathrm{draw}}$. Its variance and covariances match the data exactly, but its tails and clustering are a blend of the mixed columns, not its own.
* __Stormy periods:__ Each model's jump episodes fall on its own days. Two factors that mix the same column of $\mathbf{Z}$ share that column's stormy periods. Factors with no column in common do not, even when they had stormy periods on the same days in the data, as in March 2020.

___

## The five steps in Julia

```julia
using LinearAlgebra, Statistics

# Step 1: fit every stock on [1, g_m, h_1, ..., h_K]
X = hcat(ones(T), g_m, H);              # T × (K+2)
Θ = X \ G;                              # (K+2) × n: rows α, β, γ_1, ..., γ_K
E = G - X * Θ;                          # T × n residuals

# Step 2: sector factors, one least-squares solve per day, all days at once
F = E * B / (B' * B);                   # T × 11, column s is the average residual of sector s

# Step 3: sector loadings (all sectors; for the own-sector fit, solve with F[:, s] per stock)
Δ = F \ E;                              # 11 × n
U = E - F * Δ;                          # T × n stock-specific residuals

# Step 4: Cholesky factorization of the factor covariance, then unmix
Φ = hcat(g_m, H, F);                    # T × p, p = 1 + K + 11
μ = mean(Φ, dims = 1);
A = cholesky(Symmetric(cov(Φ))).L;      # p × p, A * A' = cov(Φ)
Z = (Φ .- μ) / A';                      # T × p, cov(Z) = I

# fit one jump hidden Markov model to each column of Z and of U, draw them independently

# Step 5: mix and compose
Φsim = μ .+ Zdraw * A';
Λ = vcat(Θ[2:end, :], Δ);               # p × n
Gsim = Θ[1:1, :] .+ Φsim * Λ .+ Udraw;  # ψ = 1 for the least-squares loadings
```
