function generateTrueData
% This script generates a .csv file with mnemonic trueData. This data can
% be used to check if all mappings etc are ok when running profor. Let for
% example one of the models in the Profor experminet be externalEmpiric,
% and let this model use the true data. 


draws       = 1000;
nfor        = 4;
nPeriods    = 60;
nVintages   = 30;

dates           =  csttt(1990, 1, nPeriods, 4);
datesFormated   =  maTimeVec(1990, floor(dates(end)), 1, 4, 'format', 'yyyy-mm-dd');

% Generate the data AR(1)
phi             = 0.5;
Sigma2          = 1;
alpha           = 1;

trueData_mean       = zeros(nPeriods,1);
trueData_mean(1)    = alpha/(1 - phi);

[trueData, trueDataWrong] = deal(zeros(nPeriods, draws));
trueData(1,:)   = alpha/(1 - phi) + randn(draws,1).*sqrt( (Sigma2/(1 - phi^2)) );

for t = 2 : nPeriods
    
        trueData_mean(t)        = alpha + phi*trueData_mean(t-1) + randn*sqrt(Sigma2);
        trueData(t,:)           = alpha/(1 - phi) + randn(draws,1).*sqrt( (Sigma2/(1 - phi^2)) );    
        trueDataWrong(t,:)      = randn(draws,1).*sqrt( (Sigma2/(1 - phi^2)) );        
end

trueDataHeader  = ['observation_date,trueData_' num2str(getVintage(dates(end),4))];

% Generate the forecasts
[trueData_empiric, trueDataWrong_empiric] = deal(nan(draws,nVintages*nfor));
trueData_empiricHeaderOne   = 'Vintage';
trueData_empiricHeaderTwo   = 'ForecastHorizon';

cnt = 1;
for v = 1:nVintages  
    
    cntv = nPeriods - nVintages  - nfor + v;            
    for n = 1:nfor
        trueData_empiricHeaderOne = [trueData_empiricHeaderOne ','  num2str(floor(dates(cntv))) 'Q' num2str(rem(dates(cntv),1)*100)];        
        trueData_empiricHeaderTwo = [trueData_empiricHeaderTwo ','  num2str(floor(dates(cntv + n))) 'Q' num2str(rem(dates(cntv + n),1)*100)];
        
        trueData_empiric(:, cnt)        = trueData(cntv + n,:)';
        trueDataWrong_empiric(:, cnt)   = trueDataWrong(cntv + n,:)';
        
        cnt = cnt + 1;
    end    
end

%% Save data to .csv file names trueData.csv and trueData_empiric. Here
% trueData.csv contains the true time series vector, and trueData_empiric
% contains the forecasts (where the mean of the distribution is equal to
% the true number)
dataIn = [];
for i = 1:nPeriods
    dataIn = strvcat(dataIn,[datesFormated(i,:) ',' num2str(trueData_mean(i),'%f')]);
end
% heading
dlmwrite(fullfile(proforStartup.pfRootHelpData,'trueData.csv'),trueDataHeader,'')
dlmwrite(fullfile(proforStartup.pfRootHelpData,'trueDataWrong','trueData.csv'),trueDataHeader,'')
% numbers 
dlmwrite(fullfile(proforStartup.pfRootHelpData,'trueData.csv'),dataIn,'-append','delimiter','')
dlmwrite(fullfile(proforStartup.pfRootHelpData,'trueDataWrong','trueData.csv'),dataIn,'-append','delimiter','')

% Also save Tsdata file with true data
d = Tsdata(dates,trueData_mean,'q','trueData'); 
save(fullfile(proforStartup.pfRootHelpData,'trueData.mat'),'d');

%% True and wrong forecast simulations
% heading
dlmwrite(fullfile(proforStartup.pfRootHelpData,'trueData_empiric.csv'),trueData_empiricHeaderOne,'')
dlmwrite(fullfile(proforStartup.pfRootHelpData,'trueData_empiric.csv'),trueData_empiricHeaderTwo,'-append','delimiter','')

dlmwrite(fullfile(proforStartup.pfRootHelpData,'trueDataWrong','trueData_empiric.csv'),trueData_empiricHeaderOne,'')
dlmwrite(fullfile(proforStartup.pfRootHelpData,'trueDataWrong','trueData_empiric.csv'),trueData_empiricHeaderTwo,'-append','delimiter','')
% numbers 
for d = 1 : draws
    if d == 1
        dataIn      = 'Data';    
        dataInWrong = 'Data';    
    else
        dataIn      = [];
        dataInWrong = [];            
    end    
    for i = 1:nVintages*nfor
        dataIn      = [dataIn ',' num2str(trueData_empiric(d,i))];    
        dataInWrong = [dataInWrong ',' num2str(trueDataWrong_empiric(d,i))];    
    end
    dlmwrite(fullfile(proforStartup.pfRootHelpData,'trueData_empiric.csv'),dataIn,'-append','delimiter','')
    dlmwrite(fullfile(proforStartup.pfRootHelpData, 'trueDataWrong','trueData_empiric.csv'),dataInWrong,'-append','delimiter','')
end

           
