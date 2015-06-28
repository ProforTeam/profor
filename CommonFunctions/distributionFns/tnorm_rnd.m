%Procedure for drawing from truncated multivariate normal based on
%Geweke's code. i.e draws from
%     xdraw is N(amu,sigma) subject to a < d*x < b
%     where N(.,) in the n-variate Normal, a and b are nx1
%Note that d is restricted to being a nonsingular nxn matrix
%la and lb are nx1 vectors set to one if no upper/lower bounds
%kstep=order of Gibbs within the constraint rows

function xdraw = tnorm_rnd(n,amu,sigma,a,b,la,lb,d,kstep);
niter=10;
%transform to work in terms of z=d*x
z=zeros(n,1);
dinv=inv(d);
anu=d*amu;

tau=d*sigma*d';
tauinv=inv(tau);
a1=a-anu;
b1=b-anu;
c=zeros(n,n);
h=zeros(n,1);
for i=1:n
aa=tauinv(i,i);
h(i,1)=1/sqrt(aa);
for j=1:n
c(i,j)=-tauinv(i,j)/aa;
end
end

for initer=1:niter
for i1=1:n
i=kstep(i1,1);
aa=0;
for j=1:n
if (i ~= j);
aa=aa+c(i,j)*z(j,1);
end
end

if la(i,1)==1
    t1=normrt_rnd(0,1,(b1(i,1)-aa)/h(i,1));
elseif lb(i,1)==1
    t1=normlt_rnd(0,1,(a1(i,1)-aa)/h(i,1));
else
t1=normt_rnd(0,1,(a1(i,1)-aa)/h(i,1),(b1(i,1)-aa)/h(i,1));
end
z(i,1)=aa+h(i,1)*t1  ;
end
end

%Transform back to x
xdraw=dinv*z;
for i=1:n
xdraw(i,1)=xdraw(i,1)+amu(i,1);
end


