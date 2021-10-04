function ret = proxL1(u,tau)


ret = u;

case1 = u > tau;
case2 = u < -tau;
case3 = u < tau & u > -tau;

ret(case1) = ret(case1) - tau;
ret(case2) = ret(case2) + tau;
ret(case3) = 0;