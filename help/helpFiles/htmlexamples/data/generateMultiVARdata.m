function generateMultiVARdata
% PURPOSE: Generates long sample which is based on three different VARs

T1=100;
T2=100;
T3=100;

%1) Settings for generating data and data generation
beta1=[0.0471    0.2509   -0.0273    0.6542    0.1309   -0.0926    0.3355   -0.2902   -0.0888    0.2085   -0.0401    0.1863    0.1141   -0.2274   -0.2548    0.1540    0.0452;
    0.0006    0.0048    0.8805    0.2238    0.0121    0.0248   -0.2808    0.1710   -0.2115   -0.0481    0.4103   -0.5540   -0.0084   -0.0209   -0.2436    0.3344   -0.0660;
    -0.0000   -0.0214    0.0601    0.3216    0.0264   -0.0119   -0.2538    0.3209   -0.1156   -0.0494    0.1416   -0.1669    0.0601   -0.0367   -0.0463   -0.1513    0.0174;
    0.0258    0.0348    0.2872    0.3039    0.1369   -0.0026   -0.2208    0.7716   -0.4773   -0.1467    0.1194    0.1592    0.1813   -0.1048    0.0831   -0.8275    0.0525];

sigma1=[0.9030    0.1174    0.0390    0.0041;
    0.1174    0.2149    0.1017    0.1236;
    0.0390    0.1017    0.1050    0.1118;
    0.0041    0.1236    0.1118    0.8231];
nlag1=4;
nvar=4;
Y1=generateData(nlag1,nvar,T1,beta1,sigma1);

%2) Settings for generating data and data generation
beta2=[2    0.2509   -0.0273    0.6542    0.1309;
    0.5    0.0048    0.8805    0.2238    0.0121;
    0   -0.0214    0.0601    0.3216    0.0264;
    1    0.0348    0.2872    0.3039    0.1369];

sigma2=[0.9030    0    0    0;
    0    0.1017 0    0;
    0    0    0.1050    0;
    0    0    0    0.8231];
nlag2=1;
nvar=4;
Y2=generateData(nlag2,nvar,T2,beta2,sigma2);

%3) Settings for generating data and data generation
beta3=[0    0.8   0    0    0;
    0    0    0.3    0    0;
    0  0    0    0.5  0;
    0    0    0    0    0.5];

sigma3=[0.7    0    0    0;
    0    0.5   0   0;
    0    0    0.6    0;
    0    0    0    0.2];
nlag3=1;
nvar=4;
Y3=generateData(nlag3,nvar,T3,beta3,sigma3);

dates=csttt(1950,1,T1+T2+T3,4);
% generate Tsdata object
Y=[Y1;Y2;Y3];
d=[];
for i=1:4
    
    data=Y(:,i);
    mnemonic=['y' num2str(i)];
    freq='q';
    
    d=cat(2,d,Tsdata(dates,data,freq,mnemonic));
    d(end).number=i;
    
end;

% Save the data
save(fullfile(proforStartup.pfRootHelpData,'multiVarData.mat'),'beta1','sigma1','nlag1','beta2','sigma2','nlag2','beta3','sigma3','nlag3','nvar','d')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Y = generateData(nlag, nvar, T, beta, sigma)

emat=(chol(sigma,'lower')*randn(nvar,T))';

% generate Y series
import resamplingFns.*
import varUtilitiesFns.*

[betaC,alfaC]=varGetCompForm(beta(:,2:end),beta(:,1),nlag,nvar);
[alfab,betab,Y]=varSimulation(alfaC,betaC,emat,nvar,nlag,T);

