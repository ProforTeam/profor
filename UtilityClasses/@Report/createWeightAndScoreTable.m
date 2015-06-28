function outTable = createWeightAndScoreTable(obj, dataType)
% createWeightAndScoreTable - Generates table with score or weight data.
%
% Input:
%   obj         [Report]
%   dataType    [str]           Must be in allowDataTypes: Currently Score or
%                               weights.
%
% Output:
%   outTable    [Table]
%       evaluationDate          [YYYY.NN]
%       Data                    [numeric]
%       Vintage                 [VYYYYQNN_H]
%       forecastHorizon         [int]
%       dataType                [str]           Weights or Scores
%       modelName               [str]
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

%% Refactor:
errType = ['Report:', mfilename];
% Extract estimation from modelProperties for convenience.
Estimation = obj.modelProperties.estimation;

% Allowable data types
allowDataTypes = {'weights', 'scores'};

if nargin < 2    
    error(errType, 'Requires a data type to be specified e.g. %s', ...
        allowDataTypes{1})
end

isValidDataType = sum(strcmp(dataType, allowDataTypes)) < 1;
if  isValidDataType    
    error(errType, 'Data type "%s" is not recognised', ...
        dataType)
end

%% Start extraction of dates, data and vintage.

dates               = Estimation.estimationDates;
yNames              = Estimation.namesY.xNonEmpty;
nSeries             = Estimation.namesY.numc;
nForecastHorizon    = size(Estimation.weightsAndScores.weights, 3);
modelNames          = Estimation.namesA.x;
nModels             = numel(modelNames);

% Back out the dates from periods:
periods             = Estimation.periods;
nEvaluationDates    = numel(periods);
nEstimationDates    = numel(dates);

% Select only the evaluation dates.
evaluationDates     = dates(end - nEvaluationDates + 1: end, 1);

% Create the vintage name: Convert periods date from YYYY.NN, to VYYYYQNN.
vintageName     = strrep(periods(end),'.','Q');
vintageName     = strcat('V', vintageName);

% Generate vintage name of same dimensions as the evaluation dates / data.
vintageName     = repmat(vintageName, [numel(evaluationDates) 1]);
vintageName     = categorical(vintageName);

% Extract appropriate data source.
switch dataType
    case allowDataTypes{1}
        inData  = Estimation.weightsAndScores.weights;
        
    case allowDataTypes{2}
        inData  = Estimation.weightsAndScores.scores;
end

%% Generate tables.
% Set table input settings.
tableInfo = {...,
    TableSettings('evaluationDate',     false, ''), ...
    TableSettings('Data',               false, ''), ...
    TableSettings('Vintage',            false, ''), ...
    TableSettings('forecastHorizon',    true,  '',  true), ...
    TableSettings('dataType',           true,  '',  true), ...
    TableSettings('modelName',          true,  '',  true) ...
    };

% Generate tables.
outTable = table();
for jj = 1 : nForecastHorizon    
    for kk = 1 : numel(modelNames)                        
        
        w   = returnTable(tableInfo, evaluationDates, inData(:, kk, jj), ...
            vintageName, jj, dataType, modelNames{kk});
        
        % Add rows to the out table.
        outTable = [outTable; w];
        
    end
end

end











