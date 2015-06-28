function inData = validateTableData(obj, inData, horizon, dataType)
% validateTableData     Replaces NaNs with equal weights.
%   Was previously doing a convulted index fudge - better to let the data lead.
%
% Input:
%   obj         [Estimationcombination]
%   inData      [numeric](nPeriods x 1)
%       Weights or Scores for a given model and forecast horizon over nPeriods.
%   horizon     [int]                       Forecast horizon.
%   dataType    [str]                       'weights' or 'scores'.
%
% Output:
%   inData      [numeric]                   Adjusted for data points where
%                                           forecast cannot be evaluated.
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


errType             = [mfilename ':'];

% Extract the number of dates upon which the forecast is evaluated.
nEvaluationDates    = size(inData, 1);

% Switch case to lower just in case have upper case anywhere.
dataType    = lower(dataType);

% Choose fill in types, as equal weights or NaN for the scores.
% When Evaluating the likelihood in the first period you do not have the outturn
% and hence cannot calculate the score even at 1-step ahead. Hence, the default
% is to set equal weights or represent that the score cannot be evaluated with
% NaN.

switch dataType
    case 'weights'
        % Set equal weights if no data available to evaluate forecast.
        fillIns     = 1 / obj.namesA.numc;
        
    otherwise
        error(errType, 'Unrecognised method %s, try scores or weights', dataType)
end

%%
% Replace Weights that are not available with equal weighting. 
idx = isnan(inData);
inData(idx) = fillIns;

end