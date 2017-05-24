import damocleslib as model
import emcee
import corner
import scipy.optimize as op
import numpy as np

def lnlike(theta):
    #v_min, v_max, rho_indx = theta
    v_max, rho_indx  = theta
    lhood = model.run_damocles_wrap(v_max, rho_indx)
    print v_max,rho_indx,-np.log(lhood)
    return -np.log(lhood)

def lnprior(theta):
    #v_min, v_max, rho_indx = theta
    v_max, rho_indx = theta
    #if 0.005 < v_min < 0.5 and 1.3 < v_max < 1.7 and 0.0 < rho_indx < 3.0:
    if 1.1 < v_max < 2.0 and 0.5 < rho_indx < 3.5:
        return 0.0
    return -np.inf

def lnprob(theta):
    lp = lnprior(theta)
    if not np.isfinite(lp):
        return -np.inf
    return lp + lnlike(theta)

result = op.minimize(lnlike,x0=[1.6,2],method="L-BFGS-B",bounds=((1.1,2.0),(0.5,3.5)),tol=1e-10,callback=callable,options={'disp': True, 'eps' : 0.01, 'maxiter': 100})
v_max_ml = result["x"]

ndim, nwalkers = 2, 100
pos = [result["x"] + 1e-4*np.random.randn(ndim) for i in range(nwalkers)]
sampler = emcee.EnsembleSampler(nwalkers, ndim, lnprob)
sampler.run_mcmc(pos, 500)