function generateBvartvpsvdata

% Load Korobilis (2008) quarterly data
load(fullfile(proforStartup.pfRootHelpData,'ydata.dat'));
load(fullfile(proforStartup.pfRootHelpData,'yearlab.dat'));

% And put into Tsdata array
dates=latttt(1953,2006,1,3);
d=[];
for i=1:3
    data=ydata(:,i);
    mnemonic=num2str(i);
    freq='q';    
    
    d=cat(2,d,Tsdata(dates,data,freq,mnemonic));                
    d(end).number=i;
    
end;    
    
% Save the data 
save(fullfile(proforStartup.pfRootHelpData,'bvartvpsvData.mat'),'d')