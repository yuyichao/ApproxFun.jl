using ApproxFun, Base.Test
import ApproxFun.Multiplication

f=Fun(exp)
d=domain(f)
D=diff(d)
Q=integrate(d)

@test norm((Q+I)*f-(integrate(f)+f)) < 2eps()
@test norm((Q)*f-(integrate(f))) < eps()

x=Fun(identity)
X=Multiplication(x,space(x))

A=Conversion(Chebyshev(d),Ultraspherical{2}(d))
@test norm(A\Fun(x.*f,rangespace(A))-(x.*f)) < 100eps()

@test norm((Conversion(Chebyshev(d),Ultraspherical{2}(d))\(D^2*f))-diff(diff(f))) < 100eps()

@test norm(X*f-(x.*f)) < 100eps()

A=Conversion(Chebyshev(d),Ultraspherical{2}(d))*X
@test norm(A*f.coefficients-coefficients(x.*f,rangespace(A))) < 100eps()


## Special functions

x=Fun(identity)
@test norm(cos(x)-Fun(cos))<10eps()
@test norm(sin(x)-Fun(sin))<10eps()
@test norm(exp(x)-Fun(exp))<10eps()
@test norm(sin(x)./x-Fun(x->sinc(x/π)))<100eps()



## Periodic


d=PeriodicInterval(0.,2π)
a=Fun(t-> 1+sin(cos(10t)),d)
D=diff(d)
L=D+a
f=Fun(t->exp(sin(t)),d)
u=L\f

@test norm(L*u-f) < 10eps()

d=PeriodicInterval(0.,2π)
a1=Fun(t->sin(cos(t/2)^2),d)
a0=Fun(t->cos(12sin(t)),d)
D=diff(d)
L=D^2+a1*D+a0
f=Fun(t->exp(cos(2t)),d)
u=L\f

@test norm(L*u-f) < 100eps()



## Check mixed

d=Interval()
D=diff(d)
x=Fun(identity,d)
A=D*(x*D)
B=D+x*D^2
C=x*D^2+D
@test norm((A-B)[1:10,1:10]|>full)<eps()
@test norm((B-A)[1:10,1:10]|>full)<eps()
@test norm((A-C)[1:10,1:10]|>full)<eps()
@test norm((C-A)[1:10,1:10]|>full)<eps()
@test norm((C-B)[1:10,1:10]|>full)<eps()
@test norm((B-C)[1:10,1:10]|>full)<eps()


