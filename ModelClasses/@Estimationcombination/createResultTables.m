function [W, S] = createResultTables(obj, horizon)
% createResultTables
%
% Input:
%   obj         [Estimationcombination]
%   horizon     [int]                       Forecast horizon.
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

periods         = obj.periods;
modelNames      = obj.namesA.x;
method          = obj.densityScoreSettings.scoringMethods.x{:};

% Extract weights and scroes for the given vintage denoted in periods.
weightTables    = obj.weightsAndScores.weights;
scoreTables     = obj.weightsAndScores.scores;

% construct the output
fillIns         = repmat(1/obj.namesA.numc, [horizon obj.namesA.numc]);
W               = obj.createTable( modelNames, periods, weightTables, method,...
    horizon, fillIns);

fillIns         = nan(horizon, obj.namesA.numc);
S               = obj.createTable( modelNames, periods, scoreTables, method, ...
    horizon, fillIns);

end
