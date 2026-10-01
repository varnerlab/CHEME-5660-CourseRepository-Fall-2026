"""Independently recompute the FAQ's worked numbers and matrix identities.

Run with Python, NumPy and SciPy. This checks the October 1 examples; the
answer-by-answer prose and assumption review is recorded in ANSWER-AUDIT.md.
"""
from pathlib import Path
from decimal import Decimal
from itertools import product
import json
import math
import numpy as np
from scipy.stats import norm
from scipy.optimize import minimize

ROOT = Path(__file__).resolve().parent
checks = []

def check(name, actual, expected, atol=1e-10):
    passed = bool(np.allclose(actual, expected, atol=atol, rtol=0))
    checks.append({'check':name, 'value':np.asarray(actual).tolist(), 'status':'passed' if passed else 'failed'})
    if not passed:
        print(f'FAILED: {name}: computed {actual}; written value {expected}; rounding tolerance {atol}')

# Cash-flow valuation, coupon dates, and the day-count convention.
check('NPV of 110 after one year at 5%', -100+110/1.05, 4.76, .005)
check('NPV including the sale-date fee', -100+108/1.05, 2.86, .005)
check('NPV at the 10% benchmark', -100+110/1.10, 0)
bill = 100*(1-.04*90/360)
check('Bill purchase price', bill, 99)
check('Bill continuous growth on a 365-day basis', math.log(100/bill)/(90/365), .04076, .000005)
bond = lambda y: 2/(1+y/2)+102/(1+y/2)**2
check('Coupon bond at 6%', bond(.06), 98.09, .005)
check('Coupon bond at 4%', bond(.04), 100)
dmac = (.5*2/1.02+102/1.02**2)/bond(.04)
check('Macaulay duration', dmac, .9902, .00005)
h=1e-5
check('Modified duration against a numerical price derivative', -(bond(.04+h)-bond(.04-h))/(2*h*bond(.04)), dmac/1.02, 1e-9)
check('Duration-convexity upward yield shock', -5*.01+.5*30*.01**2, -.0485)
check('Duration-convexity downward yield shock', 5*.01+.5*30*.01**2, .0515)
check('Spot-curve bond price', 2*.98+102*.95, 98.86)
coupon=5/(.98+.95)
check('Par coupon amount', coupon, 2.5907, .00005)
check('Par coupon rate', 2*coupon/100, .05181, .000005)
check('Par coupon reprices to par', coupon*.98+(100+coupon)*.95, 100)

# Growth units, GBM distributions, and specified terminal events.
check('One-day 1% price move expressed as growth', 252*math.log(1.01), 2.507, .0005)
check('Daily growth-rate standard deviation', .20*math.sqrt(252), 3.1749, .00005)
check('Daily log-return standard deviation', .20/math.sqrt(252), .012599, .0000005)
check('GBM drift/mean-growth conversion', .08-.20**2/2, .06)
check('GBM expected price', 100*math.exp(.08), 108.33, .005)
check('GBM median price', 100*math.exp(.06), 106.18, .005)
check('Zero mean growth at higher volatility', .08-.40**2/2, 0)
check('Scheduled-sale benchmark price', 100*math.exp(.02), 102.02, .005)
check('Normal terminal target probability', norm.sf((.02-.06)/.20), .5793, .00005)
check('5% scaled-NPV price threshold', 105*math.exp(.02), 107.12, .005)
check('5% scaled-NPV probability', norm.sf((math.log(1.05)-.04)/.20), .482, .0005)
check('Six-month fitted price', 100*math.exp(.03), 103.05, .005)
check('Log-price residual', math.log(104/100)-.03, .00922, .000005)
check('Six-month expected price', 100*math.exp(.08*.5), 104.08, .005)
check('Normal pointwise coverage', norm.cdf([1,1.96,2.576])-norm.cdf([-1,-1.96,-2.576]), [.682689,.950004,.990005], .000002)

# A tree's real-world probabilities differ from replicating prices.
check('Forecast expected price at p=.65', .65*120+.35*90, 109.50)
q=(1.02-.9)/(1.2-.9)
check('Risk-neutral weight', q, .4)
check('Replicating portfolio state payoffs', np.array([120,90])*2/3-60, [20,0])
check('Replicating cost equals discounted payoff', 100*2/3-60/1.02, q*20/1.02)
check('Claim price rounded', q*20/1.02, 7.84, .005)
check('Forecast expected price at p=.50', .5*120+.5*90, 105)
check('Calibrated lattice terminal prices', 100*np.array([1.03**2,1.03*.985,.985**2]), [106.09,101.455,97.0225])
for target, expected in [('0.05',.8775),('0.08',.4225)]:
    probability=0.0
    # Decimal arithmetic keeps exact equality at the 108 price node.
    for path in product([0,1],repeat=2):
        k=sum(path)
        price_ratio=Decimal('1.2')**k*Decimal('.9')**(2-k)
        if price_ratio > 1+Decimal(target):
            probability += .65**k*.35**(2-k)
    check('Strict lattice target '+target, probability, expected)
check('Lattice up-count threshold', math.log(1.05/.9**2)/math.log(1.2/.9), .902, .0005)

# Correlated shocks and time scaling use a covariance rate, not growth covariance.
A=np.array([[.2,0],[.15,math.sqrt(.0675)]])
C=np.array([[.04,.03],[.03,.09]])
check('Loading matrix reproduces covariance rate', A@A.T, C)
check('Shock correlation', C[0,1]/math.sqrt(C[0,0]*C[1,1]), .5)
noise=A@np.array([1,-1])
check('Shared-shock numerical draw', noise, [.2,-.109808], .0000005)
check('Correlated one-day prices', 100*np.exp(.06/252+noise/math.sqrt(252)), [101.29,99.33], .005)
G=np.array([[1,2],[2,1],[3,3]])
Sigma=np.cov(G,rowvar=False)
check('Sample covariance from three aligned observations', Sigma, [[1,.5],[.5,1]])
check('Covariance unchanged by an additive constant', np.cov(G+[5,0],rowvar=False), Sigma)
check('Log-return covariance scaling', np.cov(G/252,rowvar=False), (Sigma/252)/252)
X=np.array([-1,0,1])
check('Uncorrelated but dependent example', np.mean(X*(X**2))-np.mean(X)*np.mean(X**2), 0)

# EMA is recentered about the new mean; it is not an unbiased sample variance.
check('EMA 21-observation decay', 2**(-1/21), .9675, .00005)
for observation, mean, variance in [(1.1,.2,3.69),(3.1,.4,4.41)]:
    updated=.9*.1+.1*observation
    # Recompute directly as a mixture of old and new centered moments.
    mixed=.9*(4+(.1-updated)**2)+.1*(observation-updated)**2
    check('EMA mean at g='+str(observation),updated,mean)
    check('EMA variance at g='+str(observation),mixed,variance)
check('EMA volatility conversion', math.sqrt(3.69/252), .1210, .00005)

# Distinguish the spread of outcomes from precision of Monte Carlo estimates.
check('Wealth outcome-band half-width', 1.96*150,294)
check('Monte Carlo mean SE',150/math.sqrt(2000),3.35,.005)
check('Monte Carlo mean interval half-width',1.96*150/math.sqrt(2000),6.57,.005)
se=math.sqrt(.68*.32/2000)
check('Monte Carlo target probability SE',se,.0104,.00005)
check('Monte Carlo probability interval half-width',1.96*se,.0204,.00005)
check('Quadrupling independent paths halves SE',math.sqrt(2000/8000),.5)

# Allocation arithmetic and the gap between the proxy and actual wealth.
check('Buy-and-hold wealth factor',.5*1.2+.5*.9,1.05)
check('Drifting first-asset weight',.6/1.05,.5714,.00005)
check('Exact portfolio log return',math.log(1.05),.04879,.000005)
check('Weighted asset log returns',.5*(math.log(1.2)+math.log(.9)),.03848,.000005)
S=np.array([[4,2],[2,16]]);w=np.array([.75,.25])
check('Portfolio mean',w@np.array([.06,.12]),.075)
check('Portfolio variance with cross terms',w@S@w,4)
check('Portfolio diffusion scale',math.sqrt(4/252),.126,.0005)
check('Portfolio variance at zero correlation',w@np.diag([4,16])@w,3.25)
check('Portfolio SD at zero correlation',math.sqrt(3.25),1.803,.0005)
S=np.diag([1,4]);means=np.array([.04,.14]);ones=np.ones(2)
v=np.linalg.solve(S,ones);gmv=v/v.sum()
check('GMV weights',gmv,[.8,.2]);check('GMV variance',gmv@S@gmv,.8)
check('GMV mean',gmv@means,.06)
for target,expected,variance in [(.05,[.9,.1],.85),(.09,[.5,.5],1.25)]:
    allocation=np.linalg.solve(np.vstack([ones,means]),[1,target])
    check('Exact target weights '+str(target),allocation,expected)
    check('Exact target variance '+str(target),allocation@S@allocation,variance)
# Validate the general frontier expression against a direct KKT solve.
S=np.array([[2,.3,.2],[.3,3,.1],[.2,.1,1.]])
means=np.array([.03,.07,.12]);ones=np.ones(3)
v=np.linalg.solve(S,ones);u=np.linalg.solve(S,means)
a=ones@v;b=ones@u;c=means@u;d=a*c-b*b
B=np.vstack([ones,means]);target=.085
kkt=np.block([[S,B.T],[B,np.zeros((2,2))]])
direct=np.linalg.solve(kkt,np.r_[np.zeros(3),1,target])[:3]
formula=((c-b*target)*v+(a*target-b)*u)/d
check('Frontier weights versus KKT solution',formula,direct)
check('Frontier variance decomposition',direct@S@direct,1/a+a/d*(target-b/a)**2)
check('Shares from dollars',1000*np.array([.6,.4])/np.array([100,50]),[6,8])
wealth=np.array([6,8])@np.array([110,45])
check('Terminal wealth',wealth,1020)
check('Scaled portfolio NPV',wealth/1000*math.exp(-.03)-1,-.01015,.000005)
check('Benchmark wealth threshold',1000*math.exp(.03),1030.45,.005)
check('Daily leveraged compounding',100*1.2*(1-2/11),98.18,.005)

# Least-squares identities use a common design with an intercept.
rng=np.random.default_rng(5660);market=rng.normal(0,2,80)
design=np.column_stack([np.ones(len(market)),market])
observed=design@np.array([[.02,-.01],[1.2,.7]])+rng.normal(size=(80,2))
theta=np.linalg.lstsq(design,observed,rcond=None)[0];residual=observed-design@theta
empirical=np.cov(observed,rowvar=False);market_var=np.var(market,ddof=1)
decomposition=market_var*np.outer(theta[1],theta[1])+np.cov(residual,rowvar=False)
check('SIM exact sample covariance decomposition',decomposition,empirical)
check('SIM fitted means equal sample means',theta[0]+theta[1]*market.mean(),observed.mean(axis=0))
r_squared=1-np.sum(residual**2,axis=0)/np.sum((observed-observed.mean(axis=0))**2,axis=0)
check('R squared equals squared correlation',r_squared,[np.corrcoef(market,observed[:,i])[0,1]**2 for i in range(2)])
check('Residual degrees-of-freedom adjustment',np.sum(residual**2,axis=0)/78,np.diag(np.cov(residual,rowvar=False))*79/78)
check('Beta from correlation and scales',.6*2,1.2)
check('Fitted SIM observation',.02+1.2*.10,.14)
check('Fitted SIM residual',-.06-.14,-.20)
check('Alpha interval',[.02-1.96*.03,.02+1.96*.03],[-.0388,.0788])
check('Beta interval',[1.2-1.96*.05,1.2+1.96*.05],[1.102,1.298])
betas=np.array([1,1.5]);S=4*np.outer(betas,betas)+np.diag([1,4]);w=np.array([.5,.5])
check('SIM covariance example',S,[[5,6],[6,13]])
check('SIM equal-weight variance',w@S@w,7.5)
check('Positive omitted residual covariance',w@(S+[[0,1],[1,0]])@w,8)
check('Negative omitted residual covariance',w@(S+[[0,-1],[-1,0]])@w,7)
for wf,mean,sd in [(.5,.05,1.5),(-.5,.11,4.5),(.25,.065,2.25)]:
    check('CAL mean at risk-free weight '+str(wf),.02+(1-wf)*(.08-.02),mean)
    check('CAL SD at risk-free weight '+str(wf),abs(1-wf)*3,sd)
check('Annualized growth Sharpe ratio',math.sqrt(252)*.06/3,.3175,.00005)
check('Normalized risky weights',np.array([.30,.45])/.75,[.4,.6])
check('Leveraged complete-portfolio wealth',1000*(-.5*math.exp(.02)+1.5*1.10),1139.90,.005)
# Check both the signed tangency formula and the common long-only direction.
S=np.array([[2,.2],[.2,1.]]);e=np.array([.04,.08]);direction=np.linalg.solve(S,e)
tangent=direction/direction.sum();sr=e@tangent/math.sqrt(tangent@S@tangent)
check('Tangency attains the covariance-metric upper bound',sr,math.sqrt(e@direction))
for excess in [.01,.02]:
    optimum=minimize(lambda z:z@S@z,[.1,.1],jac=lambda z:2*S@z,bounds=[(0,1),(0,1)],
                     constraints=[{'type':'ineq','fun':lambda z:e@z-excess,'jac':lambda z:e}],
                     method='SLSQP',options={'ftol':1e-13,'maxiter':100})
    assert optimum.success,optimum.message
    check('Long-only tangent direction at excess '+str(excess),optimum.x/optimum.x.sum(),tangent,1e-6)

assert all(c['status']=='passed' for c in checks), 'Correct the reported discrepancies before publishing.'
report={'status':'passed','checks':len(checks),'results':checks}
(ROOT/'qa').mkdir(exist_ok=True)
(ROOT/'qa/math-verification.json').write_text(json.dumps(report,indent=2)+'\n')
print(f'Passed {len(checks)} independent numerical and matrix-identity checks.')
