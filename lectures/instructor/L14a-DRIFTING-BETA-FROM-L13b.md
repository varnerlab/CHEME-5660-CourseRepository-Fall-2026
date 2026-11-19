# Drifting β: moved out of L13b for L14a

On November 19, 2026, Jeff cut the drifting β option from the L13b lecture ("we don't really need this today") to move it to L14a.
The L13b SectorFactor example still has Task 3 ("An Option: a Drifting β"), which computes k_i from the online β and saves the generator with the drift on.

## Lecture section (L13b cell 4, as cut)

### An option: a drifting β
Holding $\beta_{i}$ fixed assumes that stock $i$'s sensitivity to the market growth rate stays the same over a synthetic path. Instead, we can let the sensitivity change over time around its single index estimate $\hat{\beta}_{i}$. Each day, we update it with:

$$
\beta_{i}(t) = \hat{\beta}_{i}
+ \underbrace{(1-a)\left(\beta_{i}(t-1)-\hat{\beta}_{i}\right)}_{\text{retained deviation}}
+ \underbrace{a\,k_{i}\,z_{i}(t)}_{\text{new shock}}.
$$

Here $0<a<1$ is the exponential moving average weight. A small $a$ keeps most of the previous day's deviation from $\hat{\beta}_{i}$. The shocks $z_{i}(t)$ are independent standard normal draws, and $k_{i}\geq 0$ sets their size.

In the example, we choose $k_{i}$ from how much daily β estimates vary in the real data. These estimates also contain sampling noise. The market part is now $\beta_{i}(t)\,g_{m}(t)$.

## Note under the sampling algorithm (as cut)

__Note:__ With the drifting β option below, $\beta_{i}$ becomes $\beta_{i}(t)$ in step 3. We also reduce $\psi_{i}$ to keep each stock's variance unchanged.

## Lines elsewhere in the L13b lecture (as cut)

- LO 3 ended: "…Draw one synthetic path of every stock, holding each stock's market sensitivity fixed or letting it drift."
- Core concepts: "A drifting $\beta_{i}$ lets the stock's market sensitivity change over time."
- For understanding: "…and the drifting $\beta$ option."
- Summary takeaway 3 title "Residual scale and a drifting market sensitivity" and its last sentence: "As an option, we let each stock's market sensitivity drift around its single index estimate."

## Deck frame (L13b slide 22)

```latex
\begin{frame}{An Option: A Drifting $\beta$}
  Holding $\beta_i$ fixed assumes that the stock's sensitivity to the market growth rate stays
  the same over a synthetic path. Instead, we let the sensitivity change over
  time around its single index estimate $\hat{\beta}_i$:
  \begin{equation*}
    \beta_i(t)=\hat{\beta}_i+(1-a)\bigl(\beta_i(t-1)-\hat{\beta}_i\bigr)+a k_i z_i(t).
  \end{equation*}
  Here $0<a<1$ is the exponential moving average weight. The independent standard
  normal shocks $z_i(t)$ are scaled by $k_i\geq0$.

  \vspace{0.5em}
  In the example, we choose $k_i$ from how much daily $\beta$ estimates vary in the real data.
  These estimates also contain sampling noise. The market part is now
  $\beta_i(t)g_m(t)$.
  \slidenote{Example:}{\href{\repo/CHEME-5660-L13b-Example-JumpHMM-SectorFactor-Fall-2026.ipynb}{\dimmed{CHEME-5660-L13b-Example-JumpHMM-SectorFactor-Fall-2026.ipynb}}}
\end{frame}
```
