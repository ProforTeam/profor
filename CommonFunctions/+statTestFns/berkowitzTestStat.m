function [p, n] = berkowitzTestStat(PIT, hor)
% berkowitzTest - Berkowitz test of PIT.
%
% Input:
%   PIT       [vector](tx1)     where t is number of vintages (can contain NaNs)
%   hor       [scalar]          indicates which forecating horizon the test
%                               statistic is computed for.
% Output:
%   p         [scalar] p-value
%   n         [scalar] number of observations used for computing n
%
% Reference:
%   Berkowitz, J. (2001). Testing density forecasts, with applications to  risk
%   management. Journal of Business & Economic Statistics 19(4), 465?474.
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

errType = ['statTestFns:', mfilename];

idx     = isnan( PIT );
pit     = PIT( idx == 0 );

n       = length(pit);

% Ensure that all elements < 1.0
z       = norminv( min(pit, ones(n, 1) - 0.00001 ), 0, 1);

if hor == 1
    b       = [ones(n - 1, 1), z(1 : end - 1, 1)] \ z(2 : end, 1);
    z_lm    = b(1)/(1 - b(2));
    z_std   = std( z(2 : end, 1) - [ones(n - 1, 1) z(1 : end - 1, 1)] * b, 1);
    p_0     = statTestFns.autoregressive_normloglikelihood(z, 0, 0, 1);
    p_1     = statTestFns.autoregressive_normloglikelihood(z, z_lm, b(2), z_std);
    
else
    z_lm    = mean(z);
    z_std   = std(z);
    p_0     = - normlike([0 1],z);
    p_1     = - normlike([z_lm z_std], z);    
end;

if ~isreal(p_1)
    warning( errType, ...
        'The Berkowitz test stats are giving imaginary numbers for the evaluation of the normal log-likelhood')
    
    % Return p as NaN
    p = NaN;
    
else
    p       = 1 - chi2cdf(-2 * (p_0 - p_1), 3);
end
end
