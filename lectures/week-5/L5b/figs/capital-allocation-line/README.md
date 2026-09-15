# Capital allocation line

Editable TikZ companion to the approved minimum-variance frontier, with the same
149 × 95 mm canvas, 10 pt labels, 9 pt annotations, shared course palette, and
pale gray plotting region. Build `cal.pdf` and `cal.svg` with `make`; this requires
XeLaTeX, `pdf2svg`, and Python 3. The PDF embeds fonts; SVG text is outlined.

The blue line passes through the risk-free asset and is tangent to the red
efficient frontier at portfolio T. Lending and borrowing are labeled with the
risk-free weight `w_f`. The schematic assumes short positions are allowed,
positive definite growth-rate covariance, distinct mean growth rates, and a
single lending and borrowing rate below the GMV portfolio's expected growth.
Axis units are inverse years; risk is growth-rate standard deviation.

The curve is `sigma(t) = sqrt(s0^2 + k*t^2)`, `g(t) = g0 + h*t`.
Given a positive tangent parameter `t_T`, the source sets
`g_f = g0 - h*s0^2/(k*t_T)`. This makes the CAL slope
`(g(t_T) - g_f)/sigma(t_T)` equal to the frontier slope
`h*sigma(t_T)/(k*t_T)` exactly. The parameters set drawing geometry and are not
estimates from data.

Use the native width or larger for print and 760 px for a notebook preview.
This version is prepared for figure review; the lecture and slide references
can be switched to these vector exports after that review.
