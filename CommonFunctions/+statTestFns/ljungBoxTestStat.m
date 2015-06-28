function [pValue, n] = ljungBoxTestStat(data, maxLagLength, pitMoment, hor)
% ljungBoxTestStat - Ljung-Box (LB) test for autocorrelation of the sample 
%               autocorrelation function (rho) 
%   LB is P(P+2) Sum( rho(l)^2 / (P - l) ) and is distributed chi^2(l).   
%
% References:
%   Ljung, G. M. and G. E. Box (1978). On a measure of lack of fit in time 
%   series models. Biometrika 65(2), 297?303.
%
%   http://www.mathworks.co.uk/help/econ/ljung-box-q-test.html
%
% Input:
%
%   data            [vector]    (t x 1) where t is number of vintages (can contain
%                               nan's
%   maxLagLength    [int]    	The maximum lag length.
%   pitMoment       [int]       The moment of the LB test to compute.
%   hor             [scalar]    indicates which forecating horizon the test
%                               statistic is computed for.
%
% Output:
%
%   pValue      [double] 
%   n           [int]               number of observations used for computing n
%
% Usage:
%   [pValue, n] = ljungBoxTest(data, maxLagLength, pitMoment, hor)
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%     Copyright (C) 2014  PROFOR Team
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Validation
% Ensure max lag length is available.
if size( data, 1) < maxLagLength
    maxLagLength    = size(data, 1);
end

%%
% Remove missing data from input data.
idx             = isnan( data );
data            = data(  idx == 0 );
n               = length( data );
h               = hor - 1;

% Detrend the data around its mean and raise to the requred power.
data            = ( data - mean(data) ) .^ pitMoment;       %
dataVariance    = var(data, 1);
dataMean        = mean(data);

% for h>1 data is longer than data when (n = lenght(data) - h + 1). We want to discard
% the first observation(s)and keep the last. Probably unnecessary, data already
% normalized around zero
data(1 : n, 1)  = data(1 : n, 1) - ones(n, 1) * dataMean;
lagData         = getLaggedMatrixIncludingSelfToMaxLagLength(n, maxLagLength, h, data);

% Auxilliary matrix, maxLagLength + 1 identical columns of normalized pits
dataMatrix      = repmat(data, 1, maxLagLength + h + 1);

% Calculate the autocorrelation coefficient rho up to maxLagLength by
% multiplying the original data by the lagged data and averaging across the n
% observations. As the original data is included as the first column there are
% in fact (maxLagLength + 1) columns.
rho             = ( sum( dataMatrix .* lagData, 1) / n)';

% Normalise the autocorrelation coefficient by the variance.
rho             = rho ./ dataVariance;

% A sequence from (n-1) to (n-1-maxLagLength)
pMinusL              = n - 1  : -1 : n - maxLagLength - h;

if hor == 1
    % Squared rho from 2nd to (maxLagLength+1)th element. Firts element is
    % variance, and we only want covariances. Covariances divided by the 
    % sequence pMinusL, according to how many covariances there are for each 
    % maxLagLength
    rho     = ( rho(2 : maxLagLength + 1) .^2 ) ./ pMinusL';
    
    % Calculate the LB test stat and evaluate the p-value of Chi^2( maxLagLength
    % ).
    ljungBoxTestStat    = sum(rho) * n*(n+2);   
    pValue              = 1 - chi2cdf(ljungBoxTestStat, maxLagLength); 
    
else
    % If h > 1 calculate differently. TODO.
    
    rho2    = rho;
    % Squared rho from 2nd to (maxLagLength+1)th element. Firts element is
    % variance, and we only want covariances. Covariances
    % divided by the sequence pMinusL, according to how many covariances there 
    % are for each maxLagLength.
    rho     = (rho(2 + h - 1 : maxLagLength + h + 1) .^2 ) ./ ...
        pMinusL(h : h + maxLagLength)';
    sumRho  = sum(rho); % Finally, the autocorrelation coefficients are summed
    prestat = (n + 2)*sumRho;
    denom   = (rho2(2:hor)).^2;%Normalize with rho at lag=h
    denom   = (1 + 2*sum(denom))/n;
    
    pValue       = 1-chi2cdf(prestat/denom, maxLagLength + 1); % Calculate pValue-value
    
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lagData = getLaggedMatrixIncludingSelfToMaxLagLength(n, maxLagLength, h, data)

% Creates an n data (maxLagLength + 1) matrix. First column is 1,2,...,n. Next column is:
% n, 1, 2, ... , n-1, etc.

lagData        = repmat( (1 : n)', 2 * (maxLagLength + h + 1), 1);
lagData        = lagData( 1 : (2 * n - 1) * (maxLagLength + h + 1) );
lagData        = reshape(lagData, 2 * n - 1, maxLagLength + h + 1);
lagData        = lagData(1 : n, 1 : maxLagLength + h + 1);

% We fill lagData with normalized pits, according to the numbering
lagData        = data( lagData );

% Replace elements with 0 to avoid correlations between, say, observation 1 and
% observation 37.

for qi = 1 : maxLagLength + h + 1;
    for qj = (qi + 1) : maxLagLength + h + 1;
        lagData(qi, qj) = 0;
    end
end

