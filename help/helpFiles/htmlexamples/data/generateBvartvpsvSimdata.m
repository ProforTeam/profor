function generateBvartvpsvSimdata()
% generateBvartvpsvSimdata	Generate data for time varying paramter VAR with 
%                           stochastic voliatilty.

N   = 2;
T   = 500 + 1;


phi             = nan(N, N, T);
phi(:, :, 1)    = [ 0.5  0.2;
                    -0.1 0.3];


a               = nan(1, T);
a(1, 1)         = 0;

A               = repmat(eye(N), [1 1 T]);

y               = nan(N, T);
y(:, 1)         = randn(N, 1);

sigma2          = nan(2, T);
sigma2(:, 1)    = 1;

% random errors for covariance processes
c               = randn(1, T) .* 1/10;
u               = randn(2, T) .* 1/100;
e               = randn(N, T);
s               = randn(N, N, T) ./ 10;

Q               = zeros(N, N, T);
for t = 2 : T
    
    a(:, t)     = a(:, t-1) + c(:, t);
    
    A(2, 1, t)  = a(1, t);
    Ainv        = inv(A(:, :, t));
    
    isStab = false;
    while ~isStab
        %phi(:,:,t) = phi(:,:,t-1) + s(:,:,t);
        phi(:, :, t)    = phi(:, :, t-1) + randn(N, N) ./ 10;
        if all( abs(eig( phi(:, :, t) )) < 1)
            isStab = true;
        end
    end
    
    % note that this is log(sigma^2), i.e. log of variance
    sigma2(:, t)    = sigma2(:, t-1) + u(:, t);
    % convert log of variance to std
    y(:, t)         = phi(:, :, t) * y(:, t-1) + Ainv * diag(( ...
        exp( 0.5 * sigma2(:, t) ))) * e(:,t);
    
    Hsd             = diag( exp( 0.5*sigma2(:,t)) );
    Q(:, :, t)      = Ainv * Hsd * Hsd' * Ainv';
    
    
end

%%
figure
subplot(3,1,1)
plot(y')
subplot(3,1,2)
plot(exp(sigma2'))
subplot(3,1,3)
plot(a')


%%
dataSet=[y' a' sigma2'];
dates=csttt(1990,1,T,4);
d=[];
for i=1:(N+1+2)%(10+1+1+1)
    
    
    data=dataSet(:,i);
    mnemonic=num2str(i);
    freq='q';
    
    d=cat(2,d,Tsdata(dates,data,freq,mnemonic));
    d(end).number=i;
    
end
dataSetNames=cellstr((num2str((1:N)')));
dataSetNames=strtrim(dataSetNames);

% Save the data
save(fullfile(proforStartup.pfRootHelpData,'bvartvpsvSimData.mat'),'dataSetNames','d','a','phi','sigma2','Q')
