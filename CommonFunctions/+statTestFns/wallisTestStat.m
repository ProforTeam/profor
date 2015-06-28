function [p, n] = wallisTestStat(PIT, k)
% wallisTestStat - 
%
% Input:
%
%   PIT       [vector]  (t x 1) where t is number of vintages (can contain
%                       nan's
%   k         [scalar]  ?
%
% Output:
%
%   p         [scalar] p-value
%   n         [scalar] number of observations used for computing n 
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

idx = isnan(PIT);
pit = PIT(idx==0);

n   = length(pit);

zo  = sort(pit,1);
kp  = 1/k;
i   = 1;

while kp <= 1;
    r2  = kp;
    z1u = find(zo <= r2);
    if i == 1 
        zz(i)   = numel(z1u);
    else
        qq      = sum(zz);
        zz(i)   = numel(z1u) - qq;
    end
    i   = i+1;
    kp  = kp + 1/k;  
end

chisq   = ( (k/n)*sum(zz.^2) ) - n;
p       = 1 - chi2cdf(chisq, (k - 1));
