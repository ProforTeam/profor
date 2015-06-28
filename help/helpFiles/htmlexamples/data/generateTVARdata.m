function generateTVARdata

T = 202;

omega1 = [0.5 0.2;0.2 1];
e1 = (chol(omega1)'*randn(2,T))';

omega2 = [2 0.2;0.2 1];
e2 = (chol(omega2)'*randn(2,T))';


c       = 0; % treshold
d       = 1; % delay
nlag    = 2; 
nvar    = 2; 

y = deal(zeros(T,2)');

a1 = [4;0];
b1 = [0.5 -0.1 0.3 0;0 0.9 0.01 -0.1];
a2 = [-4;0];
b2 = [-0.5 -0.1 0 0;0 0.9 0 0];

%% Generate stationary thresold
y(1,1:2) = 4;

for t = 3:T    
   if t-d > 0 
       if y(2,t-d) < c
            y(:,t) = a1 + b1(:,1:2)*y(:,t-1) + b1(:,3:4)*y(:,t-2) + e1(t,:)';       
       else
            y(:,t) = a2 + b2(:,1:2)*y(:,t-1) + b2(:,3:4)*y(:,t-2) + e2(t,:)';                     
       end
   else
       y(:,t) = a1 + b1(:,1:2)*y(:,t-1) + b1(:,3:4)*y(:,t-2) + e1(t,:)';
   end;
end

y = y';

%%
figure
plot(y(:,1),'r')
hold on
plot(y(:,2),'k--')
plot(repmat(c,[T 1]),'k')

%% Generate Tsdata object 
dates   = csttt(1980,1,T,4);
d       = [];
for i = 1:2

    data        = y(:,i);
    mnemonic    = ['y' num2str(i)];
    freq        = 'q';    
    
    d           = cat(2, d, Tsdata(dates, data, freq, mnemonic));
    d(end).number = i;        
end;

% Save the data 
save(fullfile(proforStartup.pfRootHelpData,'tvarData.mat'),'b1','b2','a1','a2','omega1','omega2','nlag','nvar','d')