function [p, n] = lillieforsTestStat(PIT)    
% lillieforsTestStat - Lilliefors test, see matlab documentation
%
% Input:
%
%   PIT       [vector]  (t x 1) where t is number of vintages (can contain
%                       nan's
%
% Output:
%
%   p         [scalar] p-value
%   n         [scalar] number of observations used for computing n 
%
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
    
% null hypothesis=nPitTrans normal; alternative nPitTrans not normal.
% The result h is 1 if the null hypothesis can be rejected at the significance level.
% The result h is 0 if the null hypothesis cannot be rejected at the
% significance level
nPitTrans   = norminv(pit, 0, 1);
[~, p]      = lillietest(nPitTrans);
    
    