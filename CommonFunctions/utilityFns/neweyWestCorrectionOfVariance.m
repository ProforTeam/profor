function nwerr = neweyWestCorrectionOfVariance(resid, x, varargin)
% neweyWestCorrectionOfVariance - Perform Newey-West correction. 
%                                 Adjusted code from Lesaage package
%
% Input: 
%
% resid = vector (tx1) of residuals. 
%
% x = variable vetor (txm). 
%
% varargin =  optional. ('nlag',number), where 'nlag' is a string, and
% number is the number of lags to be considered. The default is 
% nlag=round((0.75*(nobs^(1/3)))). 
%
% Ouput:
%
% nwerr = Newey-West adjusted variance. 
%
% Note: The number of lags to consider will be desided by a default which
% is a rounded number equaling, 0.75T^1/3. See Stock and Watson 2004
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

nobs = size(resid, 1);
nvar = size(x,2);

nlag = round((0.75*(nobs^(1/3))));

defaults = {'nlag', nlag, @isnumeric};    
options = validateInput(defaults, varargin(1:nargin-2));


emat = [];
for i = 1 : nvar;
    emat = cat(1, emat, resid');
end
hhat = emat.*x';
G = zeros(1); w = zeros(2*options.nlag + 1, 1);
a = 0;

while a ~= options.nlag + 1;
    ga = zeros(1);
    w(options.nlag + 1 + a, 1) = (options.nlag + 1 - a)/(options.nlag + 1);
    za = hhat(:, (a + 1) : nobs)*hhat(:, 1 : nobs - a)';
    if a == 0;
    ga = ga + za;
    else
    ga = ga + za + za';
    end
    G = G + w(nlag + 1 + a, 1)*ga;
    a = a + 1;
end 

xx      = (x'*x);
V       = (xx\G)/xx;
nwerr   = sqrt(diag(V))';

