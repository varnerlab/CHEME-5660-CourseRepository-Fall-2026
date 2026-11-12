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

# Options (L9a/L9b survey, October 27, 2026): one pricing rule, lattices, BSM, and implied volatility.
D1=math.exp(-.04);q=(math.exp(.04)-.9)/(1.2-.9)
check('One-step risk-neutral probability',q,.4694,.00005)
check('One-step call premium under Q',D1*20*q,9.02,.005)
check('Most a p=.7 buyer would pay',D1*20*.7,13.45,.005)
check('Most a p=.4 buyer would pay',D1*20*.4,7.69,.005)
check('Most a p=.5 buyer would pay',D1*20*.5,9.61,.005)
check('Share expected NPV under Q is zero',-100+D1*(q*120+(1-q)*90),0)
check('Share expected NPV at p=.7',-100+D1*(.7*120+.3*90),6.65,.005)
check('Share expected NPV at p=.5',-100+D1*(.5*120+.5*90),.88,.005)
check('Expected NPV of the Q premium at p=.7',D1*20*.7-D1*20*q,4.43,.005)
# Hull's two-step put, computed with the exact q rather than the rounded table entries.
q=(math.exp(.05)-.8)/.4;D1=math.exp(-.05);K=52
check('Hull risk-neutral probability',q,.6282,.00005)
Hu=D1*(q*0+(1-q)*4);Hd=D1*(q*4+(1-q)*20)
check('Hull up-node continuation value',Hu,1.41,.005)
check('Hull down-node continuation value',Hd,9.46,.005)
american=D1*(q*max(0,Hu)+(1-q)*max(12,Hd));european=D1*(q*Hu+(1-q)*Hd)
check('Hull American put premium',american,5.0896324742,1e-9)
check('Hull European put premium',european,4.1926542806,1e-9)
check('Hull early-exercise premium',american-european,.90,.005)
check('Hull root extrinsic value',american-2,3.09,.005)
check('Down-node continuation equals discounted strike minus share price',Hd,K*D1-40)
check('Interest on the strike at the down node',K*(1-D1),2.54,.005)
check('Exercise minus hold equals the interest on the strike',12-Hd,K*(1-D1))
check('Up-node put equals forward put plus one-step call',Hu,K*D1-60+D1*q*(72-K))
check('Down node is indifferent when the rate is zero',.5*4+.5*20,12)
# CRR factors and the dropped mean-growth term.
dt=1/365
check('Dropped-term ratio, daily step',(.10/.30)**2*dt,.0003,.00005)
check('Change in a, daily step',math.sqrt(1+(.10/.30)**2*dt)-1,.00015,.000005)
check('Dropped-term ratio, one-year step',(.10/.30)**2,.11,.005)
check('Change in a, one-year step',math.sqrt(1+(.10/.30)**2)-1,.054,.0005)
u=math.exp(.30*math.sqrt(dt));d=1/u;q=(math.exp(.04*dt)-d)/(u-d)
check('Daily CRR factors',[u,d],[1.01583,.98442],.000005)
check('Daily real-world probability',.5*(1+.10/.30*math.sqrt(dt)),.5087,.00005)
check('Daily risk-neutral probability',q,.4996,.00005)
check('Small-step expansion of q',.5+(.04-.045)/.6*math.sqrt(dt),q,.000001)
check('Volatility floor for daily steps',.04*math.sqrt(dt),.0021,.00005)
check('Daily up factor at half the volatility',math.exp(.15/math.sqrt(365)),1.00788,.000005)
check('Dropped-term ratio at half the volatility',(.10/.15)**2*dt,.0012,.00005)
check('Change in a at half the volatility',math.sqrt(1+(.10/.15)**2*dt)-1,.0006,.00005)
# BSM call, put, parity, the probability of exercise, and the lattice limit.
def bsm(sigma,S=100,K=105,T=.25,g=.04):
    dp=(math.log(S/K)+(g+sigma**2/2)*T)/(sigma*math.sqrt(T));dm=dp-sigma*math.sqrt(T)
    return S*norm.cdf(dp)-K*math.exp(-g*T)*norm.cdf(dm),K*math.exp(-g*T)*norm.cdf(-dm)-S*norm.cdf(-dp),dp,dm
call,put,dp,dm=bsm(.30)
check('BSM d+ and d-',[dp,dm],[-.1836,-.3336],.00005)
check('BSM N(d+) and N(d-)',norm.cdf([dp,dm]),[.42716,.36934],.000005)
check('Discounted strike',105*math.exp(-.01),103.955,.0005)
check('BSM call terms',[100*norm.cdf(dp),105*math.exp(-.01)*norm.cdf(dm)],[42.716,38.395],.0005)
check('BSM call from the displayed terms',42.716-38.395,4.32,.005)
check('BSM call and put',[call,put],[4.32,8.28],.005)
check('Put-call parity',call-put,100-105*math.exp(-.01))
check('Probability of exercise from the GBM event',norm.sf(-dm),norm.cdf(dm))
def crr_european_call(h,S=100,K=105,T=.25,g=.04,sigma=.30):
    dt=T/h;u=math.exp(sigma*math.sqrt(dt));d=1/u;q=(math.exp(g*dt)-d)/(u-d)
    V=[max(S*u**k*d**(h-k)-K,0) for k in range(h+1)]
    for t in range(h-1,-1,-1):
        V=[math.exp(-g*dt)*(q*V[k+1]+(1-q)*V[k]) for k in range(t+1)]
    return V[0]
check('CRR European call with 91 steps',crr_european_call(91),4.31,.005)
call100,_,_,dm100=bsm(.30,K=100)
check('Probability of exercise at K=100',[dm100,norm.cdf(dm100)],[-.0083,.4967],.00005)
check('BSM call at K=100',call100,6.46,.005)
# Bisection for the implied volatility of a 6.00 quote.
check('Initial bracket premiums',[bsm(.05)[0],bsm(1.0)[0]],[.07,18.21],.005)
lo,hi,steps=.05,1.0,[]
while hi-lo>1e-4:
    mid=(lo+hi)/2;premium=bsm(mid)[0];steps.append((lo,hi,mid,premium))
    if premium<6.00: lo=mid
    else: hi=mid
check('First five bisection steps',np.round(steps[:5],4),[[.05,1,.525,8.7865],[.05,.525,.2875,4.0766],[.2875,.525,.4062,6.4214],[.2875,.4062,.3469,5.2446],[.3469,.4062,.3766,5.8322]],.0001)
check('Bisection steps to a 1e-4 bracket',len(steps),14)
iv=(lo+hi)/2
check('Implied volatility',iv,.385,.0005)
check('One-standard-deviation range',[100*(1-.385*.5),100*(1+.385*.5)],[80.75,119.25],.005)
lo,hi=.05,1.0
while hi-lo>1e-4:
    mid=(lo+hi)/2
    if bsm(mid)[0]<bsm(.30)[0]: lo=mid
    else: hi=mid
check('Bisection recovers sigma from its own premium',(lo+hi)/2,.30,.0001)
# Equation chains written with rounded inputs must still give the written results.
check('Rounded one-step risk-neutral probability chain',(1.04081-.9)/(1.2-.9),.4694,.00005)
check('Rounded one-step premium chain',.9608*20*.4694,9.02,.005)
check('Hull share prices',[50*1.2,50*.8,50*1.2**2,50*1.2*.8,50*.8**2],[60,40,72,48,32])
check('Rounded put-call parity chain',[4.32-8.28,100-103.96],[-3.96,-3.96])
check('Daily CRR step for a three-month call',.25/91*365,1.0027,.00005)
check('Third bisection midpoint, rounded half up',float(Decimal('0.40625').quantize(Decimal('0.0001'),rounding='ROUND_HALF_UP')),.4063)
check('Rounded p=.7 chains',[.9608*20*.7,-100+.9608*(.7*120+.3*90)],[13.45,6.65],.005)
check('Rounded Hull table',[.9512*(.6282*0+.3718*4),.9512*(.6282*4+.3718*20),.9512*(.6282*1.41+.3718*12),
    .9512*(.6282*1.41+.3718*9.46)],[1.41,9.46,5.09,4.19],.005)
check('Rounded down-node chains',[52*.9512-40,52*(1-.9512)],[9.46,2.54],.005)
check('Rounded early-exercise and extrinsic differences',[5.09-4.19,5.09-2],[.90,3.09])

# Options and strategies (L10a/L10b, L11a, L11b surveys, November 12, 2026).
def gbm_cdf(x,S,T,mu,sigma):
    return norm.cdf((math.log(x/S)-(mu-sigma**2/2)*T)/(sigma*math.sqrt(T)))
# Delta as a probability of exercise on a two-step tree.
S0,K,T,g,sig,h=100,95,.5,.04,.30,2
dt=T/h;u=math.exp(sig*math.sqrt(dt));d=1/u;q=(math.exp(g*dt)-d)/(u-d);qs=q*u*math.exp(-g*dt)
check('Two-step tree factors and probabilities',[u,d,q,qs],[1.1618,.8607,.4959,.5705],.00005)
check('Down-step weight equals one minus q*',(1-q)*d*math.exp(-g*dt),1-qs)
check('Two-step terminal prices',[S0*u**2,S0*u*d,S0*d**2],[134.99,100.00,74.08],.005)
itm=[k for k in range(h+1) if S0*u**k*d**(h-k)>K]
check('Two-step in-the-money nodes',itm,[1,2])
poe=sum(math.comb(h,k)*q**k*(1-q)**(h-k) for k in itm);delta=sum(math.comb(h,k)*qs**k*(1-qs)**(h-k) for k in itm)
check('Two-step POE and Delta',[poe,delta],[.7459,.8155],.00005)
check('Two-step POE and Delta from the written chains',[1-.5041**2,1-.4295**2],[.7459,.8155],.00005)
def tree_call(S):
    return math.exp(-g*T)*sum(math.comb(h,k)*q**k*(1-q)**(h-k)*max(S*u**k*d**(h-k)-K,0) for k in range(h+1))
check('Two-step Delta by central difference',(tree_call(100.01)-tree_call(99.99))/.02,.8155,.00005)
check('Growth-weighted Delta equals the q* sum',math.exp(-g*T)*sum(math.comb(h,k)*q**k*(1-q)**(h-k)*u**k*d**(h-k) for k in itm),delta)
check('Top and bottom node weights under q and q*',[q**2,qs**2,(1-q)**2,(1-qs)**2],[.2460,.3254,.2541,.1845],.00005)
for T_,s_,row in [(30/365,.30,[.086,.532,.498,.034]),(1.0,.50,[.500,.629,.433,.197])]:
    _,_,dp_,dm_=bsm(s_,S=100,K=100,T=T_,g=.04)
    check(f'Delta and POE gap, T={T_:.3f}, sigma={s_}',[s_*math.sqrt(T_),norm.cdf(dp_),norm.cdf(dm_),norm.cdf(dp_)-norm.cdf(dm_)],row,.0005)
# Delta, the risk-neutral POE, and our forecast: the L10a NVDA call and the L11a AMD put credit spread.
S0,K,P,T,g,iv,mu,sh=230.57,235,9.88,.1178,.0413,.3543,.5788,.3886
Sb=K+math.exp(g*T)*P
check('NVDA premium grown to expiration and breakeven',[math.exp(g*T)*P,Sb],[9.93,244.93],.005)
qpoe=1-gbm_cdf(K+.01,S0,T,g,iv);ppoe=1-gbm_cdf(K+.01,S0,T,mu,sh)
qpop=gbm_cdf(Sb,S0,T,g,iv);ppop=gbm_cdf(Sb,S0,T,mu,sh)
check('NVDA POE under Q and P',[qpoe,ppoe],[.4295,.6185],.00005)
check('NVDA seller POP under Q and P',[qpop,ppop],[.6976,.5034],.00005)
check('NVDA exercised but profitable under Q',qpop-(1-qpoe),.1271,.00005)
check('NVDA POP decomposition chain',[1-.4295,.5705+.1271],[.5705,.6976])
check('NVDA seller profit at 240 and 250',[9.93-(240-235),9.93-(250-235)],[4.93,-5.07])
S0,K1,K2,P1,P2,T,g=531.26,500,520,29.35,38.10,53/365,.0413
Sb=K2-math.exp(g*T)*(P2-P1)
check('AMD spread breakeven',Sb,511.20,.005)
check('AMD POP under Q and P',[1-gbm_cdf(Sb,S0,T,g,.5617),1-gbm_cdf(Sb,S0,T,.5521,.4743)],[.540,.714],.0005)
check('AMD POP at lower growth rates',[1-gbm_cdf(Sb,S0,T,mg+.4743**2/2,.4743) for mg in (.4397,.20,0)],[.714,.646,.584],.0005)
check('AMD short put POE under Q',gbm_cdf(K2-.01,S0,T,g,.5617),.492,.0005)
check('AMD risk-neutral mean growth rate',g-.5617**2/2,-.12,.005)
check('Drift standard error with ten years (L4b regression slope)',math.sqrt(6/5)*.47/math.sqrt(10),.16,.005)
Sb_amd=Sb;pop=lambda mg,s:1-gbm_cdf(Sb_amd,S0,T,mg+s**2/2,s)
check('AMD gap at zero growth: growth effect and volatility effect',[pop(0,.4743)-pop(g-.5617**2/2,.4743),pop(0,.4743)-pop(0,.5617)],[.037,.013],.0005)
# Longstaff-Schwartz on the paper's eight paths.
paths=np.array([[1.00,1.09,1.08,1.34],[1.00,1.16,1.26,1.54],[1.00,1.22,1.07,1.03],[1.00,0.93,0.97,0.92],
                [1.00,1.11,1.56,1.52],[1.00,0.76,0.77,0.90],[1.00,0.92,0.84,1.01],[1.00,0.88,1.22,1.34]])
def lsm(fitted=False):
    D=math.exp(-.06);V=lambda s:np.maximum(1.10-s,0);Y=V(paths[:,3]);out={}
    for t in (2,1):
        Y=D*Y;X=paths[:,t];itm=V(X)>0
        beta=np.linalg.lstsq(np.vstack([np.ones(itm.sum()),X[itm],X[itm]**2]).T,Y[itm],rcond=None)[0]
        H=beta[0]+beta[1]*X+beta[2]*X**2;ex=itm&(V(X)>H);out[t]=(beta,H,Y.copy(),ex)
        Y=np.where(itm,np.maximum(V(X),H),Y) if fitted else np.where(ex,V(X),Y)
    return max(.10,D*Y.mean()),out
american,steps=lsm();beta,H,Y2,ex=steps[2];rows=[0,2,3,5,6]
check('LSM t=2 coefficients, as reported by Longstaff and Schwartz',beta,[-1.070,2.983,-1.813],.001)
check('LSM t=2 realized holds',Y2[rows],[0,.066,.170,.188,.085],.0005)
check('LSM t=2 fitted holds',H[rows],[.037,.046,.118,.152,.156],.0005)
check('LSM t=2 fitted holds from rounded coefficients',[-1.070+2.983*x-1.813*x*x for x in paths[rows,2]],[.037,.046,.118,.152,.156],.0005)
check('LSM t=2 exercise decisions',list(np.where(ex)[0]+1),[4,6,7])
check('LSM American, fitted-value, and European premiums',[american,lsm(True)[0],math.exp(-.18)*np.maximum(1.10-paths[:,3],0).mean()],[.1144,.1178,.0564],.00005)
check('LSM early-exercise premium',american-math.exp(-.18)*np.maximum(1.10-paths[:,3],0).mean(),.058,.0005)
check('LSM fitted hold at 0.90',[beta[0]+beta[1]*.9+beta[2]*.81,-1.070+2.983*.9-1.813*.81],[.146,.146],.0005)
# Iron condor from BSM quotes at sigma=0.30, then the rounded quotes as written.
T,g=30/365,.04;D=math.exp(g*T)
quotes=[bsm(.30,K=85,T=T)[1],bsm(.30,K=90,T=T)[1],bsm(.30,K=110,T=T)[0],bsm(.30,K=115,T=T)[0]]
check('Iron condor quotes',quotes,[.08,.40,.66,.22],.005)
PC=.08-.40-.66+.22;cg=-PC*D
check('Iron condor composite premium, accumulation factor, and grown credit',[PC,D,cg,.76*1.0033],[-.76,1.0033,.7625,.7625],.00005)
def condor(x): return max(85-x,0)-max(90-x,0)-max(x-110,0)+max(x-115,0)+cg
check('Iron condor profit on each interval',[condor(80),condor(87.5),condor(100),condor(112.5),condor(120)],[-4.2375,.7625-2.5,.7625,.7625-2.5,-4.2375],.00005)
check('Iron condor breakevens',[90-cg,110+cg],[89.2375,110.7625],.00005)
check('Iron condor as two spreads at 80',(.32*D-5)+.44*D,condor(80))
check('Iron condor POP and short-leg POEs under Q',[gbm_cdf(110+cg,100,T,g,.30)-gbm_cdf(90-cg,100,T,g,.30),gbm_cdf(89.99,100,T,g,.30),1-gbm_cdf(110.01,100,T,g,.30)],[.790,.111,.133],.0005)
check('Short legs alone understate the POP',1-.111-.133,.756)
check('Protected strangle credit and lower breakeven',[(.84)*D,90-.84*D],[.8428,89.1572],.00005)
# The L11a short strangle on the CRR tree (American legs).
def crr_american(S,K,T,g,sigma,kind,h=2000):
    if T<=0: return max(S-K,0) if kind=='c' else max(K-S,0)
    dt=T/h;u=math.exp(sigma*math.sqrt(dt));d=1/u;q=(math.exp(g*dt)-d)/(u-d);disc=math.exp(-g*dt)
    pay=(lambda x:np.maximum(x-K,0)) if kind=='c' else (lambda x:np.maximum(K-x,0))
    k=np.arange(h+1);V=pay(S*u**k*d**(h-k))
    for t in range(h-1,-1,-1):
        k=np.arange(t+1);V=np.maximum(disc*(q*V[1:]+(1-q)*V[:-1]),pay(S*u**k*d**(t-k)))
    return V[0]
put0=crr_american(100,90,30/365,.04,.40,'p');call0=crr_american(100,110,30/365,.04,.40,'c');credit=put0+call0
check('Strangle legs and credit at entry',[put0,call0,credit],[1.00,1.44,2.44],.005)
for days,S,cost,close in [(30,100,2.44,0.00),(20,100,1.38,1.06),(10,100,.39,2.06),(10,108,2.04,.40)]:
    c_=crr_american(S,90,days/365,.04,.40,'p')+crr_american(S,110,days/365,.04,.40,'c')
    check(f'Strangle close at {days} days, S={S}',[c_,credit*math.exp(.04*(30-days)/365)-c_],[cost,close],.005)
check('Strangle profit at expiration and upper breakeven',[credit*math.exp(.04*30/365),110+2.45],[2.45,112.45],.005)
check('Fraction of the credit kept at 20 days',1.06/2.44,.43,.005)
# Collars and net Delta: BSM quotes at sigma=0.25, three months, then the rounded quotes as written.
T,g,sig=.25,.04,.25;D=math.exp(g*T)
check('Collar quotes',[bsm(sig,K=95,T=T)[1],bsm(sig,K=90,T=T)[1],bsm(sig,K=105,T=T)[0],bsm(sig,K=110,T=T)[0]],[2.43,1.13,3.35,1.92],.005)
check('Collar accumulation factor',D,1.0101,.00005)
for K1,K2,P1,P2,row in [(95,105,2.43,3.35,[-.92,5.08,4.92,100.08,.495]),(95,110,2.43,1.92,[.51,6.52,8.48,101.52,.541]),(90,110,1.13,1.92,[-.79,10.21,9.79,100.21,.500])]:
    C=D*(100+P1-P2)
    check(f'Collar {K1}/{K2}',[P1-P2,C-K1,K2-C,C,gbm_cdf(C,100,T,g,sig)],row,.005)
check('Shares alone breakeven and probability of a loss',[D*100,gbm_cdf(D*100,100,T,g,sig)],[101.01,.525],.005)
check('Zero-cost call strike for the 95 put',__import__('scipy.optimize',fromlist=['brentq']).brentq(lambda k:bsm(sig,K=k,T=T)[0]-bsm(sig,K=95,T=T)[1],100,130),108,.5)
check('Debit collar trails the shares above',95-D*(2.43-1.92),94.48,.005)
check('Collar 95/110 and shares at 80 and 120',[95-D*(100+.51),110-D*(100+.51),80-D*100,120-D*100],[-6.52,8.48,-21.01,18.99],.005)
def net_delta(S,tl):
    dc=bsm(sig,S=S,K=110,T=tl)[2];dc=norm.cdf(dc)
    dp=norm.cdf(bsm(sig,S=S,K=95,T=tl)[2])-1
    return dc,dp,100*(1-dc),100*(1+dp-dc)
dc,dp,cc,col=net_delta(100,.25)
check('Collar Deltas at entry',[dc,dp],[.268,-.290],.0005)
check('Net Delta at entry, written chains',[100*(1-.268),100*(1-.290-.268)],[73.2,44.2],.05)
check('Gain for a 2 USD/share rise',[2*73.2,2*44.2],[146,88],.5)
for tl,ccs,cols in [(.25,[97.3,84.9,73.2,59.1,44.3,20.1],[20.0,40.5,44.2,41.8,34.9,17.9]),(5/365,[100.0,100.0,99.9,94.0,48.7,.1],[0.0,51.3,96.2,94.0,48.7,.1])]:
    vals=[net_delta(S,tl) for S in (85,95,100,105,110,120)]
    check(f'Net Delta table, {tl:.4f} years left',[[v[2] for v in vals],[v[3] for v in vals]],[ccs,cols],.05)
check('Call Delta at 105 with 5 days left',net_delta(105,5/365)[0],.06,.005)

assert all(c['status']=='passed' for c in checks), 'Correct the reported discrepancies before publishing.'
report={'status':'passed','checks':len(checks),'results':checks}
(ROOT/'qa').mkdir(exist_ok=True)
(ROOT/'qa/math-verification.json').write_text(json.dumps(report,indent=2)+'\n')
print(f'Passed {len(checks)} independent numerical and matrix-identity checks.')
