function generateVARdata

%% Settings for generating data and data generation
beta=[0.0471    0.2509   -0.0273    0.6542    0.1309   -0.0926    0.3355   -0.2902   -0.0888    0.2085   -0.0401    0.1863    0.1141   -0.2274   -0.2548    0.1540    0.0452;
    0.0006    0.0048    0.8805    0.2238    0.0121    0.0248   -0.2808    0.1710   -0.2115   -0.0481    0.4103   -0.5540   -0.0084   -0.0209   -0.2436    0.3344   -0.0660;
   -0.0000   -0.0214    0.0601    0.3216    0.0264   -0.0119   -0.2538    0.3209   -0.1156   -0.0494    0.1416   -0.1669    0.0601   -0.0367   -0.0463   -0.1513    0.0174;
    0.0258    0.0348    0.2872    0.3039    0.1369   -0.0026   -0.2208    0.7716   -0.4773   -0.1467    0.1194    0.1592    0.1813   -0.1048    0.0831   -0.8275    0.0525];

sigma=[0.9030    0.1174    0.0390    0.0041;
    0.1174    0.2149    0.1017    0.1236;
    0.0390    0.1017    0.1050    0.1118;
    0.0041    0.1236    0.1118    0.8231];

nlag=4;
nvar=4;
T=100;

emat=(chol(sigma,'lower')*randn(nvar,T))';

% generate Y series
import resamplingFns.*
import varUtilitiesFns.*

[betaC,alfaC]=varGetCompForm(beta(:,2:end),beta(:,1),nlag,nvar);
[alfab,betab,Y]=varSimulation(alfaC,betaC,emat,nvar,nlag,T);

dates=csttt(1980,1,T,4);
% generate Tsdata object 
d=[];
for i=1:4

    data=Y(:,i);
    mnemonic=['y' num2str(i)];
    freq='q';    
    
    d=cat(2,d,Tsdata(dates,data,freq,mnemonic));
    d(end).number=i;        
end;

% Save the data 
save(fullfile(proforStartup.pfRootHelpData,'varData.mat'),'beta','sigma','nlag','nvar','d')