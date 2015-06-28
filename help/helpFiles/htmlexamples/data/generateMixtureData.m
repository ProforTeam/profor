function generateMixtureData()
%Simulate artificial data set for third empirical illustration in Chapter 10
%Mixtures of Normals models. Taken from Koop 2003...

n = 100;

%one component mixture
alpha1 = 1;
sigma1 = .5;
for i = 1 : n
    y(i,1)= alpha1 + sigma1*randn;
end
y1.d = y;
y1.alpha1 = alpha1;
y1.sigma1 = sigma1;


%two component mixture
alpha1  = 1;
alpha2  = -1;
sigma1  = .5;
sigma2  = .25;
p1      = .25;
p2      = .75;

for i = 1 : n
    if rand < p1
        y(i, 1) = alpha1 + sigma1*randn;
    else
        y(i, 1) = alpha2 + sigma2*randn;
    end
end
y2.d = y;
y2.alpha1 = alpha1;
y2.alpha2 = alpha2;
y2.sigma1 = sigma1;
y2.sigma2 = sigma2;
y2.p1     = p1;
y2.p2     = p2;

%three component mixture
alpha1  = 1;
alpha2  = 0;
alpha3  = -1;
sigma1  = .25;
sigma2  = .25;
sigma3  = .5;
p1      = .25;
p2      = .5;
p3      = 1 - p1 - p2;
for i = 1 : n
    unif = rand;
    if unif < p1
        y(i, 1) = alpha1 + sigma1*randn;
    elseif unif < (p1 + p2)
        y(i, 1)= alpha2 + sigma2*randn;
    else
        y(i, 1) = alpha3 + sigma3*randn;
    end
end
y3.d = y;
y3.alpha1 = alpha1;
y3.alpha2 = alpha2;
y3.alpha3 = alpha3;
y3.sigma1 = sigma1;
y3.sigma2 = sigma2;
y3.sigma3 = sigma3;
y3.p1     = p1;
y3.p2     = p2;
y3.p3     = p3;

%% Save data to Tsdata object and save to file
Y       = [y1.d y2.d y3.d];
dates   = csttt(1980, 1, n, 4);
% generate Tsdata object 
d = [];
for i = 1 : 3

    data        = Y(:, i);
    mnemonic    = ['y' num2str(i)];
    freq        = 'q';    
    
    d               = cat(2, d, Tsdata(dates, data, freq, mnemonic));
    d(end).number   = i;        
end

% Save the data 
save(fullfile(proforStartup.pfRootHelpData,'mixtureData.mat'),'y1','y2','y3','d')
