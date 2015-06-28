function outStats = getDensityTestIndependence( inPits, forecastHorizon )
% getDensityTestGoodnessOfFit - Returns tests on goodness of fit for PITs.
%
% Input:
%   inPits              [numeric]
%
% Output:
%   outStats            [struct]
%       ljungBox
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

errType     = [mfilename, ': '];

%% Refactor. TODO.
maxLagLength    = 4;
ljungBoxMoment  = 1;


%%
% Return the various test statistics.
outStats.ljungBox ...
            = statTestFns.ljungBoxTestStat(inPits, maxLagLength, ...
            ljungBoxMoment, forecastHorizon);

end

