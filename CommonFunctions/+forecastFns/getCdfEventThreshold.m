function cdfEventThreshold = getCdfEventThreshold(empiricalForecastPdf, empiricalForecastDomain, ...
    eventThreshold)
% getBrierScore - Evaluated for the event outturn < eventThreshold.
%
% N.B. Only set up to work on scalars.
%
% Input:
%   empiricalForecastPdf                Empirical Pdf
%   empiricalForecastDomain             Domain for the empirical pdf
%   eventThreshold
%
% Output:
%   cdfEventThreshold
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

errType             = [mfilename, ': '];

%% Calculate CDF of empirical forecast at the event threshold.

% First, extract options in the same format so can use helper fn in
% combinationFns.nonparametricPIT to calculate the probability of the event
% occuring using the empirical pdf and evaluating the CDF at the event threshold.
options.xIncrement      = abs(empiricalForecastDomain(end) - ...
    empiricalForecastDomain(end - 1));
options.pdfOfxDomain    = empiricalForecastPdf;
options.xDomain         = empiricalForecastDomain;

% Actual / outturn here is the eventThreshold.
options.actual          = eventThreshold;

% Number of outturns / actual is 1 as fn set up.
nOutturns               = 1;

% Evaluate the empirical CDF at the event threshold.
cdfEventThreshold       = combinationFns.nonparametricPIT( options, nOutturns);

end
