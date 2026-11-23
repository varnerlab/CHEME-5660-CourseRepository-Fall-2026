# Two Factors per Sector: The Derivation, Every Step

Instructor working note, 2026-11-20. This note is not part of the lecture.

## The model

For stock $i$ in sector $s$ on day $t$:

$$
g_{i}(t) = \underbrace{\alpha_{i}}_{\text{baseline}} + \underbrace{\beta_{i}\,g_{m}(t)}_{\text{market}} + \overbrace{\underbrace{\delta_{i}\,f_{s}(t)}_{\text{sector factor 1}} + \underbrace{\gamma_{i}\,h_{s}(t)}_{\text{sector factor 2}} + \underbrace{u_{i}(t)}_{\text{stock-specific}}}^{\text{single index residual }\varepsilon_{i}(t)}
$$

The draft wrote $h_{i}(t)$. A factor indexed by $i$ belongs to stock $i$ alone, so it would be part of $u_{i}(t)$. This note uses $h_{s}(t)$, a second factor shared by the stocks of sector $s$. Section 0 shows why the index is $s$.

__Sums:__ $\sum_{j\in s}$ runs over the $n_{s}$ stocks in sector $s$, and $\sum_{t}$ runs over the $T$ days of the data.

__Variance and covariance:__ Both are sample values over the $T$ days, where $\bar{x}$ is the average of $x(t)$ over the days:

$$
\operatorname{Cov}(x,y) = \frac{1}{T-1}\sum_{t}\left(x(t)-\bar{x}\right)\left(y(t)-\bar{y}\right),
\qquad
\operatorname{Var}(x) = \operatorname{Cov}(x,x)
$$

__Rule Z (zero mean):__ If $\sum_{t}x(t)=0$, then $(T-1)\operatorname{Cov}(x,y)=\sum_{t}x(t)\,y(t)$ for any series $y$. We use this rule many times:

$$
\begin{align*}
(T-1)\operatorname{Cov}(x,y) &= \sum_{t}\left(x(t)-\bar{x}\right)\left(y(t)-\bar{y}\right) && \text{definition}\\
&= \sum_{t}x(t)\left(y(t)-\bar{y}\right) && \bar{x}=0\\
&= \sum_{t}x(t)\,y(t)-\bar{y}\sum_{t}x(t) && \text{split the sum}\\
&= \sum_{t}x(t)\,y(t) && \textstyle\sum_{t}x(t)=0
\end{align*}
$$

___

## 0. Why the sector term is not $\sum_{r}\delta_{ir}f_{r}$

The general factor model lets stock $i$ load on all 11 sector factors. The sector factor model sets the loading to zero for every sector except the stock's own sector $s$:

$$
\begin{align*}
\sum_{r=1}^{11}\delta_{ir}\,f_{r}(t) &= \delta_{i1}\,f_{1}(t)+\dots+\delta_{is}\,f_{s}(t)+\dots+\delta_{i,11}\,f_{11}(t) && \text{write out the sum}\\
&= 0\cdot f_{1}(t)+\dots+\delta_{is}\,f_{s}(t)+\dots+0\cdot f_{11}(t) && \delta_{ir}=0 \text{ for every } r\neq s\\
&= \delta_{is}\,f_{s}(t) && \text{one term is left}\\
&= \delta_{i}\,f_{s}(t) && \text{drop the second subscript}
\end{align*}
$$

The same steps turn $\sum_{r}\gamma_{ir}h_{r}(t)$ into $\gamma_{i}\,h_{s}(t)$.

__Why we set the other loadings to zero:__ GICS assigns each stock to exactly one sector, and Section 3 builds each sector's factors from the stocks of that sector only. Each stock then needs one loading per factor instead of 11.

__What the zero loadings cost:__ The simulation draws the sector factors independently, so $\operatorname{Cov}(f_{q},f_{q'})=0$ for $q\neq q'$. In the general form, two stocks $i$ and $j$ covary through the sector factors as:

$$
\begin{align*}
\operatorname{Cov}\left(\sum_{q}\delta_{iq}f_{q},\;\sum_{q'}\delta_{jq'}f_{q'}\right) &= \sum_{q}\sum_{q'}\delta_{iq}\delta_{jq'}\operatorname{Cov}(f_{q},f_{q'}) && \text{covariance of two sums}\\
&= \sum_{q}\delta_{iq}\delta_{jq}\operatorname{Var}(f_{q}) && \text{independent draws: only } q'=q \text{ is left}
\end{align*}
$$

With the zero loadings, $\delta_{iq}$ is nonzero only for $q=s$, and $\delta_{jq}$ is nonzero only for the sector $r$ of stock $j$. If $r\neq s$, every product $\delta_{iq}\delta_{jq}$ has a zero factor, so the sum is zero. Stocks in different sectors then covary only through the market.

___

## 1. The single index fit

The single index residual of stock $i$ is:

$$
\varepsilon_{i}(t) = g_{i}(t)-\alpha_{i}-\beta_{i}\,g_{m}(t)
$$

The fit chooses $\alpha_{i}$ and $\beta_{i}$ to minimize the sum of squared residuals:

$$
\text{SSE}_{i} = \sum_{t}\left(g_{i}(t)-\alpha_{i}-\beta_{i}\,g_{m}(t)\right)^{2}
$$

__Derivative with respect to $\alpha_{i}$:__

$$
\begin{align*}
\frac{\partial\,\text{SSE}_{i}}{\partial\alpha_{i}} &= \sum_{t}2\left(g_{i}(t)-\alpha_{i}-\beta_{i}\,g_{m}(t)\right)(-1) && \text{chain rule on each squared term}\\
&= -2\sum_{t}\varepsilon_{i}(t) && \text{the bracket is } \varepsilon_{i}(t)
\end{align*}
$$

Setting the derivative to zero and dividing by $-2$ gives condition (A):

$$
\sum_{t}\varepsilon_{i}(t) = 0 \qquad \text{(A)}
$$

__Derivative with respect to $\beta_{i}$:__

$$
\begin{align*}
\frac{\partial\,\text{SSE}_{i}}{\partial\beta_{i}} &= \sum_{t}2\left(g_{i}(t)-\alpha_{i}-\beta_{i}\,g_{m}(t)\right)\left(-g_{m}(t)\right) && \text{chain rule on each squared term}\\
&= -2\sum_{t}g_{m}(t)\,\varepsilon_{i}(t) && \text{the bracket is } \varepsilon_{i}(t)
\end{align*}
$$

Setting the derivative to zero and dividing by $-2$ gives condition (B):

$$
\sum_{t}g_{m}(t)\,\varepsilon_{i}(t) = 0 \qquad \text{(B)}
$$

Condition (A) says that $\varepsilon_{i}$ averages zero. With Rule Z, condition (B) then says $\operatorname{Cov}(g_{m},\varepsilon_{i})=0$.

___

## 2. Choose the exposures to the second factor

The model fixes every stock's exposure to $f_{s}$ at $1$. The second factor needs a second exposure that differs across the stocks of the sector. We choose a raw exposure $z_{j}$ for each stock $j$ in sector $s$, for example $z_{j}=1$ for the stocks of one GICS industry in the sector and $z_{j}=0$ for the rest. We then shift the raw exposures so that they sum to zero:

$$
x_{j} = z_{j}-\bar{z}_{s}, \qquad \bar{z}_{s} = \frac{1}{n_{s}}\sum_{j\in s}z_{j}
$$

$$
\begin{align*}
\sum_{j\in s}x_{j} &= \sum_{j\in s}\left(z_{j}-\bar{z}_{s}\right) && \text{definition of } x_{j}\\
&= \sum_{j\in s}z_{j}-n_{s}\,\bar{z}_{s} && \bar{z}_{s} \text{ is the same in all } n_{s} \text{ terms}\\
&= \sum_{j\in s}z_{j}-\sum_{j\in s}z_{j} && n_{s}\,\bar{z}_{s}=\textstyle\sum_{j\in s}z_{j}\\
&= 0
\end{align*}
$$

Section 3 shows why the shift matters: it keeps $f_{s}$ equal to the lecture's sector factor.

___

## 3. The day-by-day fit for $f_{s}(t)$ and $\hat{h}_{s}(t)$

On day $t$, the model gives each stock $j$ in sector $s$ an exposure of $1$ to $f_{s}(t)$ and an exposure of $x_{j}$ to $\hat{h}_{s}(t)$. The hat marks a raw series, which Section 5 cleans. The term $e_{j}(t)$ is the error of this one-day fit. We write out the case of three stocks and drop the $(t)$, because every term is on day $t$:

$$
\begin{align*}
\varepsilon_{1} &= f_{s}+x_{1}\,\hat{h}_{s}+e_{1}\\
\varepsilon_{2} &= f_{s}+x_{2}\,\hat{h}_{s}+e_{2}\\
\varepsilon_{3} &= f_{s}+x_{3}\,\hat{h}_{s}+e_{3}
\end{align*}
$$

The two unknowns are $f_{s}$ and $\hat{h}_{s}$. The exposures satisfy $x_{1}+x_{2}+x_{3}=0$. The fit minimizes the sum of squared errors:

$$
\text{SSE} = \left(\varepsilon_{1}-f_{s}-x_{1}\hat{h}_{s}\right)^{2}+\left(\varepsilon_{2}-f_{s}-x_{2}\hat{h}_{s}\right)^{2}+\left(\varepsilon_{3}-f_{s}-x_{3}\hat{h}_{s}\right)^{2}
$$

__Derivative with respect to $f_{s}$:__

$$
\begin{align*}
\frac{\partial\,\text{SSE}}{\partial f_{s}} &= 2\left(\varepsilon_{1}-f_{s}-x_{1}\hat{h}_{s}\right)(-1)+2\left(\varepsilon_{2}-f_{s}-x_{2}\hat{h}_{s}\right)(-1)+2\left(\varepsilon_{3}-f_{s}-x_{3}\hat{h}_{s}\right)(-1) && \text{chain rule on each squared term}\\
0 &= \left(\varepsilon_{1}-f_{s}-x_{1}\hat{h}_{s}\right)+\left(\varepsilon_{2}-f_{s}-x_{2}\hat{h}_{s}\right)+\left(\varepsilon_{3}-f_{s}-x_{3}\hat{h}_{s}\right) && \text{set to zero, divide by } -2\\
&= \left(\varepsilon_{1}+\varepsilon_{2}+\varepsilon_{3}\right)-\left(f_{s}+f_{s}+f_{s}\right)-\left(x_{1}+x_{2}+x_{3}\right)\hat{h}_{s} && \text{regroup}\\
&= \left(\varepsilon_{1}+\varepsilon_{2}+\varepsilon_{3}\right)-3\,f_{s}-0\cdot\hat{h}_{s} && f_{s} \text{ appears once per stock; the } x\text{'s sum to zero}\\
f_{s} &= \frac{1}{3}\left(\varepsilon_{1}+\varepsilon_{2}+\varepsilon_{3}\right) && \text{solve for } f_{s}
\end{align*}
$$

The $3$ in the last line is the number of stocks $n_{s}$.

__Derivative with respect to $\hat{h}_{s}$:__

$$
\begin{align*}
\frac{\partial\,\text{SSE}}{\partial\hat{h}_{s}} &= 2\left(\varepsilon_{1}-f_{s}-x_{1}\hat{h}_{s}\right)(-x_{1})+2\left(\varepsilon_{2}-f_{s}-x_{2}\hat{h}_{s}\right)(-x_{2})+2\left(\varepsilon_{3}-f_{s}-x_{3}\hat{h}_{s}\right)(-x_{3}) && \text{chain rule on each squared term}\\
0 &= x_{1}\left(\varepsilon_{1}-f_{s}-x_{1}\hat{h}_{s}\right)+x_{2}\left(\varepsilon_{2}-f_{s}-x_{2}\hat{h}_{s}\right)+x_{3}\left(\varepsilon_{3}-f_{s}-x_{3}\hat{h}_{s}\right) && \text{set to zero, divide by } -2\\
&= \left(x_{1}\varepsilon_{1}+x_{2}\varepsilon_{2}+x_{3}\varepsilon_{3}\right)-\left(x_{1}+x_{2}+x_{3}\right)f_{s}-\left(x_{1}^{2}+x_{2}^{2}+x_{3}^{2}\right)\hat{h}_{s} && \text{multiply out, regroup}\\
&= \left(x_{1}\varepsilon_{1}+x_{2}\varepsilon_{2}+x_{3}\varepsilon_{3}\right)-0\cdot f_{s}-\left(x_{1}^{2}+x_{2}^{2}+x_{3}^{2}\right)\hat{h}_{s} && \text{the } x\text{'s sum to zero}\\
\hat{h}_{s} &= \frac{x_{1}\varepsilon_{1}+x_{2}\varepsilon_{2}+x_{3}\varepsilon_{3}}{x_{1}^{2}+x_{2}^{2}+x_{3}^{2}} && \text{solve for } \hat{h}_{s}
\end{align*}
$$

__Any number of stocks:__ Replace $3$ with $n_{s}$ and each written-out sum with $\sum_{j\in s}$:

$$
\boxed{
f_{s}(t) = \frac{1}{n_{s}}\sum_{j\in s}\varepsilon_{j}(t),
\qquad
\hat{h}_{s}(t) = \frac{\sum_{j\in s}x_{j}\,\varepsilon_{j}(t)}{\sum_{j\in s}x_{j}^{2}}
}
$$

The first factor is the lecture's sector factor. The second factor is the slope of the day's residuals on the exposures, the $\beta$ formula run across stocks instead of across days. Without the shift in Section 2, the first equation would keep a term in $\hat{h}_{s}$, and $f_{s}$ would no longer be the plain average. With only two stocks, the two unknowns fit the two residuals exactly, so the fit needs at least three stocks.

In this fit, every stock has the same exposure $1$ to $f_{s}$. Section 6 replaces the exposures with loadings $\delta_{i}$ and $\gamma_{i}$ fitted for each stock.

___

## 4. What $f_{s}$ and $\hat{h}_{s}$ inherit from the single index fit

Both factors are sums of the residuals with weights that do not change from day to day:

$$
f_{s}(t) = \sum_{j\in s}a_{j}\,\varepsilon_{j}(t),\quad a_{j}=\frac{1}{n_{s}};
\qquad
\hat{h}_{s}(t) = \sum_{j\in s}w_{j}\,\varepsilon_{j}(t),\quad w_{j}=\frac{x_{j}}{\sum_{k\in s}x_{k}^{2}}
$$

Take any such sum with fixed weights $c_{j}$, written out for three stocks: $F(t)=c_{1}\varepsilon_{1}(t)+c_{2}\varepsilon_{2}(t)+c_{3}\varepsilon_{3}(t)$.

__The sum over days is zero:__

$$
\begin{align*}
\sum_{t}F(t) &= \sum_{t}\left(c_{1}\varepsilon_{1}(t)+c_{2}\varepsilon_{2}(t)+c_{3}\varepsilon_{3}(t)\right) && \text{definition of } F\\
&= c_{1}\sum_{t}\varepsilon_{1}(t)+c_{2}\sum_{t}\varepsilon_{2}(t)+c_{3}\sum_{t}\varepsilon_{3}(t) && \text{split the sum; the } c\text{'s do not depend on } t\\
&= c_{1}\cdot 0+c_{2}\cdot 0+c_{3}\cdot 0 = 0 && \text{(A) for each stock}
\end{align*}
$$

__The covariance with the market is zero:__

$$
\begin{align*}
\sum_{t}g_{m}(t)\,F(t) &= c_{1}\sum_{t}g_{m}(t)\,\varepsilon_{1}(t)+c_{2}\sum_{t}g_{m}(t)\,\varepsilon_{2}(t)+c_{3}\sum_{t}g_{m}(t)\,\varepsilon_{3}(t) && \text{same split}\\
&= c_{1}\cdot 0+c_{2}\cdot 0+c_{3}\cdot 0 = 0 && \text{(B) for each stock}
\end{align*}
$$

With Rule Z, the second result gives $\operatorname{Cov}(g_{m},F)=0$. So $f_{s}$ and $\hat{h}_{s}$ both average zero, and both are uncorrelated with the market.

__The two factors are not uncorrelated with each other:__

$$
\begin{align*}
(T-1)\operatorname{Cov}(f_{s},\hat{h}_{s}) &= \sum_{t}f_{s}(t)\,\hat{h}_{s}(t) && \text{Rule Z}\\
&= \sum_{t}\left(\sum_{j\in s}a_{j}\,\varepsilon_{j}(t)\right)\left(\sum_{k\in s}w_{k}\,\varepsilon_{k}(t)\right) && \text{substitute both factors}\\
&= \sum_{j\in s}\sum_{k\in s}a_{j}\,w_{k}\sum_{t}\varepsilon_{j}(t)\,\varepsilon_{k}(t) && \text{multiply out, move the sum over } t \text{ inside}\\
&= (T-1)\sum_{j\in s}\sum_{k\in s}a_{j}\,w_{k}\operatorname{Cov}(\varepsilon_{j},\varepsilon_{k}) && \text{Rule Z on each pair}
\end{align*}
$$

The last line is a weighted sum of the residual covariances in the sector, and nothing forces this sum to zero.

___

## 5. Remove $f_{s}$ from $\hat{h}_{s}$

We fit $\hat{h}_{s}$ on $f_{s}$ across days and keep the leftover $h_{s}$. Both series average zero, so the fit needs no intercept:

$$
\hat{h}_{s}(t) = \theta_{s}\,f_{s}(t)+h_{s}(t),
\qquad
\text{SSE} = \sum_{t}\left(\hat{h}_{s}(t)-\theta_{s}\,f_{s}(t)\right)^{2}
$$

$$
\begin{align*}
\frac{\partial\,\text{SSE}}{\partial\theta_{s}} &= \sum_{t}2\left(\hat{h}_{s}(t)-\theta_{s}\,f_{s}(t)\right)\left(-f_{s}(t)\right) && \text{chain rule on each squared term}\\
&= -2\sum_{t}f_{s}(t)\,h_{s}(t) && \text{the bracket is } h_{s}(t)
\end{align*}
$$

Setting the derivative to zero gives condition (C):

$$
\sum_{t}f_{s}(t)\,h_{s}(t) = 0 \qquad \text{(C)}
$$

Solving (C) for $\theta_{s}$:

$$
\begin{align*}
0 &= \sum_{t}f_{s}(t)\left(\hat{h}_{s}(t)-\theta_{s}\,f_{s}(t)\right) && h_{s}=\hat{h}_{s}-\theta_{s}\,f_{s}\\
&= \sum_{t}f_{s}(t)\,\hat{h}_{s}(t)-\theta_{s}\sum_{t}f_{s}(t)^{2} && \text{split the sum}\\
\theta_{s} &= \frac{\sum_{t}f_{s}(t)\,\hat{h}_{s}(t)}{\sum_{t}f_{s}(t)^{2}} && \text{solve for } \theta_{s}
\end{align*}
$$

__What $h_{s}$ keeps:__

$$
\begin{align*}
\sum_{t}h_{s}(t) &= \sum_{t}\hat{h}_{s}(t)-\theta_{s}\sum_{t}f_{s}(t) = 0-\theta_{s}\cdot 0 = 0 && \text{Section 4}\\
\sum_{t}g_{m}(t)\,h_{s}(t) &= \sum_{t}g_{m}(t)\,\hat{h}_{s}(t)-\theta_{s}\sum_{t}g_{m}(t)\,f_{s}(t) = 0-\theta_{s}\cdot 0 = 0 && \text{Section 4}
\end{align*}
$$

With Rule Z, $h_{s}$ averages zero, $\operatorname{Cov}(g_{m},h_{s})=0$, and by (C), $\operatorname{Cov}(f_{s},h_{s})=0$.

The switch from $\hat{h}_{s}$ to $h_{s}$ changes no fitted growth rate. The term $\gamma_{i}\,\hat{h}_{s}=\gamma_{i}\,h_{s}+\gamma_{i}\theta_{s}\,f_{s}$, and the second piece joins the $f_{s}$ term.

___

## 6. The loadings $\delta_{i}$ and $\gamma_{i}$

For each stock $i$, we fit its residual on the two factors across days:

$$
\varepsilon_{i}(t) = \delta_{i}\,f_{s}(t)+\gamma_{i}\,h_{s}(t)+u_{i}(t),
\qquad
\text{SSE}_{i} = \sum_{t}\left(\varepsilon_{i}(t)-\delta_{i}\,f_{s}(t)-\gamma_{i}\,h_{s}(t)\right)^{2}
$$

The fit needs no intercept, because $\varepsilon_{i}$, $f_{s}$, and $h_{s}$ all average zero.

__Derivative with respect to $\delta_{i}$:__

$$
\begin{align*}
\frac{\partial\,\text{SSE}_{i}}{\partial\delta_{i}} &= \sum_{t}2\,u_{i}(t)\left(-f_{s}(t)\right) && \text{chain rule; the bracket is } u_{i}(t)\\
0 &= \sum_{t}f_{s}(t)\,u_{i}(t) && \text{set to zero, divide by } -2 \quad \text{(D)}\\
&= \sum_{t}f_{s}\,\varepsilon_{i}-\delta_{i}\sum_{t}f_{s}^{2}-\gamma_{i}\sum_{t}f_{s}\,h_{s} && \text{substitute } u_{i}\text{, split the sum}
\end{align*}
$$

__Derivative with respect to $\gamma_{i}$:__

$$
\begin{align*}
\frac{\partial\,\text{SSE}_{i}}{\partial\gamma_{i}} &= \sum_{t}2\,u_{i}(t)\left(-h_{s}(t)\right) && \text{chain rule; the bracket is } u_{i}(t)\\
0 &= \sum_{t}h_{s}(t)\,u_{i}(t) && \text{set to zero, divide by } -2 \quad \text{(E)}\\
&= \sum_{t}h_{s}\,\varepsilon_{i}-\delta_{i}\sum_{t}f_{s}\,h_{s}-\gamma_{i}\sum_{t}h_{s}^{2} && \text{substitute } u_{i}\text{, split the sum}
\end{align*}
$$

__The 2×2 system:__

$$
\begin{bmatrix}
\sum_{t}f_{s}^{2} & \sum_{t}f_{s}\,h_{s}\\
\sum_{t}f_{s}\,h_{s} & \sum_{t}h_{s}^{2}
\end{bmatrix}
\begin{bmatrix}\delta_{i}\\ \gamma_{i}\end{bmatrix}
=
\begin{bmatrix}\sum_{t}f_{s}\,\varepsilon_{i}\\ \sum_{t}h_{s}\,\varepsilon_{i}\end{bmatrix}
$$

By (C), the off-diagonal entries are zero, so the two equations separate. Rule Z turns each sum into a covariance:

$$
\boxed{
\delta_{i} = \frac{\sum_{t}f_{s}\,\varepsilon_{i}}{\sum_{t}f_{s}^{2}} = \frac{\operatorname{Cov}(f_{s},\varepsilon_{i})}{\operatorname{Var}(f_{s})},
\qquad
\gamma_{i} = \frac{\sum_{t}h_{s}\,\varepsilon_{i}}{\sum_{t}h_{s}^{2}} = \frac{\operatorname{Cov}(h_{s},\varepsilon_{i})}{\operatorname{Var}(h_{s})}
}
$$

Each loading is a one-factor slope, like $\beta_{i}$.

__The lecture's sector loading:__ The lecture fits $\delta_{i}$ on the sector factor computed without stock $i$, then rescales the slopes by $c_{s}$. With that $\delta_{i}$ held fixed, (E) alone sets $\gamma_{i}$. Its middle term $\delta_{i}\sum_{t}f_{s}\,h_{s}$ is zero by (C), so $\gamma_{i}$ has the same formula. Condition (D) no longer holds, which matters in Section 7.

___

## 7. The stock-specific residual $u_{i}$ and the residual scale $\psi_{i}$

$$
u_{i}(t) = \varepsilon_{i}(t)-\delta_{i}\,f_{s}(t)-\gamma_{i}\,h_{s}(t)
$$

__The stock-specific residual averages zero:__ $\sum_{t}u_{i}=\sum_{t}\varepsilon_{i}-\delta_{i}\sum_{t}f_{s}-\gamma_{i}\sum_{t}h_{s}=0-0-0=0$.

__Variance in the data:__

$$
\begin{align*}
\operatorname{Var}(\varepsilon_{i}) &= \operatorname{Var}\left(\delta_{i}\,f_{s}+\gamma_{i}\,h_{s}+u_{i}\right) && \text{definition of } u_{i}\\
&= \delta_{i}^{2}\operatorname{Var}(f_{s})+\gamma_{i}^{2}\operatorname{Var}(h_{s})+\operatorname{Var}(u_{i})\\
&\quad+2\,\delta_{i}\gamma_{i}\underbrace{\operatorname{Cov}(f_{s},h_{s})}_{=0\text{ by (C)}}+2\,\delta_{i}\operatorname{Cov}(f_{s},u_{i})+2\,\gamma_{i}\underbrace{\operatorname{Cov}(h_{s},u_{i})}_{=0\text{ by (E)}} && \text{variance of a sum of three terms}\\
&= \delta_{i}^{2}\operatorname{Var}(f_{s})+\gamma_{i}^{2}\operatorname{Var}(h_{s})+\operatorname{Var}(u_{i})+2\,\delta_{i}\operatorname{Cov}(f_{s},u_{i}) && \text{drop the zero terms}
\end{align*}
$$

The last covariance is zero for the plain slope of Section 6, by (D). For the lecture's leave-one-out loading, it is not zero.

__Variance in the simulation:__ The simulation draws $f_{s}$, $h_{s}$, and $u_{i}$ from separate models, independently:

$$
\begin{align*}
\operatorname{Var}\left(\delta_{i}\,f_{s}^{\mathrm{draw}}+\gamma_{i}\,h_{s}^{\mathrm{draw}}+\psi_{i}\,u_{i}^{\mathrm{draw}}\right) &= \delta_{i}^{2}\operatorname{Var}(f_{s}^{\mathrm{draw}})+\gamma_{i}^{2}\operatorname{Var}(h_{s}^{\mathrm{draw}})+\psi_{i}^{2}\operatorname{Var}(u_{i}^{\mathrm{draw}}) && \text{independent draws: every covariance is zero}\\
&\approx \delta_{i}^{2}\operatorname{Var}(f_{s})+\gamma_{i}^{2}\operatorname{Var}(h_{s})+\psi_{i}^{2}\operatorname{Var}(u_{i}) && \text{each fitted model matches the variance of its data}
\end{align*}
$$

__Match the two variances and solve for $\psi_{i}^{2}$:__

$$
\begin{align*}
\delta_{i}^{2}\operatorname{Var}(f_{s})+\gamma_{i}^{2}\operatorname{Var}(h_{s})+\psi_{i}^{2}\operatorname{Var}(u_{i}) &= \operatorname{Var}(\varepsilon_{i}) && \text{match the data}\\
\psi_{i}^{2} &= \frac{\operatorname{Var}(\varepsilon_{i})-\delta_{i}^{2}\operatorname{Var}(f_{s})-\gamma_{i}^{2}\operatorname{Var}(h_{s})}{\operatorname{Var}(u_{i})} && \text{solve for } \psi_{i}^{2}\\
&= \frac{\delta_{i}^{2}\operatorname{Var}(f_{s})+\gamma_{i}^{2}\operatorname{Var}(h_{s})+\operatorname{Var}(u_{i})+2\,\delta_{i}\operatorname{Cov}(f_{s},u_{i})-\delta_{i}^{2}\operatorname{Var}(f_{s})-\gamma_{i}^{2}\operatorname{Var}(h_{s})}{\operatorname{Var}(u_{i})} && \text{substitute the data variance}\\
&= \frac{\operatorname{Var}(u_{i})+2\,\delta_{i}\operatorname{Cov}(f_{s},u_{i})}{\operatorname{Var}(u_{i})} && \text{cancel}\\
&= 1+\frac{2\,\delta_{i}\operatorname{Cov}(f_{s},u_{i})}{\operatorname{Var}(u_{i})} && \text{split the fraction}
\end{align*}
$$

This is the lecture's formula. The second factor adds no term, because (E) makes $h_{s}$ uncorrelated with $u_{i}$.

___

## 8. The covariance of two stocks

The simulated growth rate is $g_{i}=\alpha_{i}+\beta_{i}\,g_{m}+\delta_{i}\,f_{s}+\gamma_{i}\,h_{s}+\psi_{i}\,u_{i}$. Every series on the right comes from its own model, drawn independently. Take stock $i$ in sector $s$ and a different stock $j$ in sector $r$:

$$
\begin{align*}
\operatorname{Cov}(g_{i},g_{j}) &= \operatorname{Cov}\left(\alpha_{i}+\beta_{i}\,g_{m}+\delta_{i}\,f_{s}+\gamma_{i}\,h_{s}+\psi_{i}\,u_{i},\;\alpha_{j}+\beta_{j}\,g_{m}+\delta_{j}\,f_{r}+\gamma_{j}\,h_{r}+\psi_{j}\,u_{j}\right) && \text{substitute both}\\
&= \operatorname{Cov}\left(\beta_{i}\,g_{m}+\delta_{i}\,f_{s}+\gamma_{i}\,h_{s}+\psi_{i}\,u_{i},\;\beta_{j}\,g_{m}+\delta_{j}\,f_{r}+\gamma_{j}\,h_{r}+\psi_{j}\,u_{j}\right) && \text{constants do not covary}
\end{align*}
$$

Each side has four terms, so the covariance splits into 16 pieces. Every piece that pairs two different models is zero, because the draws are independent:

| | $\beta_{j}\,g_{m}$ | $\delta_{j}\,f_{r}$ | $\gamma_{j}\,h_{r}$ | $\psi_{j}\,u_{j}$ |
|---|---|---|---|---|
| $\beta_{i}\,g_{m}$ | $\beta_{i}\beta_{j}\operatorname{Var}(g_{m})$ | $0$ | $0$ | $0$ |
| $\delta_{i}\,f_{s}$ | $0$ | $\delta_{i}\delta_{j}\operatorname{Cov}(f_{s},f_{r})$ | $0$ | $0$ |
| $\gamma_{i}\,h_{s}$ | $0$ | $0$ | $\gamma_{i}\gamma_{j}\operatorname{Cov}(h_{s},h_{r})$ | $0$ |
| $\psi_{i}\,u_{i}$ | $0$ | $0$ | $0$ | $0$ |

The covariance $\operatorname{Cov}(f_{s},f_{r})$ is $\operatorname{Var}(f_{s})$ when $r=s$ and $0$ otherwise, and the same holds for $h$. The simulation also sets $\operatorname{Cov}(f_{s},h_{s})=0$. Section 5 made this covariance zero in the data, so the independent draws lose nothing. Adding up the table:

$$
\operatorname{Cov}(g_{i},g_{j}) =
\begin{cases}
\beta_{i}\beta_{j}\operatorname{Var}(g_{m})+\delta_{i}\delta_{j}\operatorname{Var}(f_{s})+\gamma_{i}\gamma_{j}\operatorname{Var}(h_{s}) & \text{same sector, } r=s\\
\beta_{i}\beta_{j}\operatorname{Var}(g_{m}) & \text{different sectors, } r\neq s
\end{cases}
$$

On the diagonal, Section 7 gives $\delta_{i}^{2}\operatorname{Var}(f_{s})+\gamma_{i}^{2}\operatorname{Var}(h_{s})+\psi_{i}^{2}\operatorname{Var}(u_{i})=\operatorname{Var}(\varepsilon_{i})$, so $\operatorname{Var}(g_{i})=\beta_{i}^{2}\operatorname{Var}(g_{m})+\operatorname{Var}(\varepsilon_{i})$, as in the single index model.

__The matrix:__ The vector $\boldsymbol{\gamma}_{s}$ holds $\gamma_{i}$ for each stock in sector $s$ and zeros for the other stocks, like $\boldsymbol{\delta}_{s}$:

$$
\mathbf{\Sigma}_{g} = \underbrace{\operatorname{Var}(g_{m})\,\boldsymbol{\beta}\boldsymbol{\beta}^{\top}}_{\text{market}}
+\underbrace{\sum_{s}\left(\operatorname{Var}(f_{s})\,\boldsymbol{\delta}_{s}\boldsymbol{\delta}_{s}^{\top}+\operatorname{Var}(h_{s})\,\boldsymbol{\gamma}_{s}\boldsymbol{\gamma}_{s}^{\top}\right)}_{\text{two terms per sector}}
+\underbrace{\operatorname{diag}\left(\psi_{1}^{2}\operatorname{Var}(u_{1}),\dotsc,\psi_{n}^{2}\operatorname{Var}(u_{n})\right)}_{\text{stock-specific}}
$$

___

## 9. The order of the steps

1. Fit the single index model of each stock and compute $\varepsilon_{i}(t)$ (Section 1).
2. Choose the raw exposures $z_{j}$ and shift them to sum to zero within each sector (Section 2).
3. On each day, compute $f_{s}(t)$ and $\hat{h}_{s}(t)$ for each sector (Section 3).
4. Remove $f_{s}$ from $\hat{h}_{s}$ to get $h_{s}$ (Section 5).
5. Fit $\delta_{i}$ and $\gamma_{i}$ for each stock, then compute $u_{i}(t)$ and $\psi_{i}$ (Sections 6 and 7).
6. Fit a jump hidden Markov model to each daily series: $g_{m}$, every $f_{s}$, every $h_{s}$, and every $u_{i}$. Draw each one independently and compose $g_{i}=\alpha_{i}+\beta_{i}\,g_{m}+\delta_{i}\,f_{s}+\gamma_{i}\,h_{s}+\psi_{i}\,u_{i}$.
