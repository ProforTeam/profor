function outTable = returnResultTables(obj, nHorizon, variableName, scoreMethod, ...
    eventThreshold)
% returnResultTables    Holder fn that extracts data to be inserted into table
%                       for weights and scores.
%   Allows for different scoring methods apart from the default contained in
%   scoreMethod.
%
% Input:
%   obj             [Estimationcombination]
%   nHorizon        [int]                       Number of forecast horizons,
%                                               must run from 1 : nHorizon.
%   variableName    [str]
%   scoreMethod     [cell]                      e.g. logScoreD, crpsD etc.
%   eventThreshold      [double]                
%       Requested threshold when needed to select from map object of optiions.
%       Only thresholds specified in
%       Profor.brierScoreProperties.eventThresholdValues will be available. 
%
% Output:
%   outTable    [Table]
%       Vintage
%       Periods
%       Variable        [str][categorical]
%       Horizon         [int][categorical]
%       ModelName       [str][categorical]
%       Method          [str][categorical]
%       Weights         [numeric]w
%       Scores          [numeric]
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

%% Validate inputs.

% Check that sufficient input arguments supplied.
narginchk(3, 5);

noScoreMethodSupplied = nargin < 4;
if noScoreMethodSupplied
    % Set default scoreMethod.
    scoreMethod     = obj.densityScoreSettings.scoringMethods.x;
end

% Initialise isEventThresholdUsed and set as true if an input arg.
isEventThresholdUsed    = false;
if nargin == 5
    isEventThresholdUsed = true;
end    

%% Extract table info

% Set up the common information between scoring methods.
nScoreMethod            = numel(scoreMethod);
modelNames              = obj.namesA.x;
periods                 = obj.periods;
originalScoreMethod     = obj.densityScoreSettings.scoringMethods.x;
nModels                 = numel(modelNames);
vintages                = periods(end);

% Replace the funny _1 dating convention by replacing any _ followed by anything
% with nothing using regexprep.
vintages                = regexprep( vintages, '_(.)', '');
periods                 = regexprep( periods, '_(.)', '');

% Convert the periods to a numeric array as indexing later is a lot easier - can
% also use categorical.
periods                 = str2num( cell2mat( periods ) );

%%

% Set up the common table input settings.
tableInfo   = {...,
    TableSettings('Vintage',    true, ['The real time vintage the ', ...
    'table entries are computed for.'],                         true), ...
    TableSettings('Periods',    false, ['The time period the table entries ',...
    'are computed for.']), ...
    TableSettings('Variable',       true, '',                       true), ...
    TableSettings('Horizon',        true, 'Forecasting horizon',    true), ...
    TableSettings('ModelName',      true, '',                       true), ...
    TableSettings('Method',         true, '',                       true), ...
    TableSettings('Weights',        false, ''), ...
    TableSettings('Scores',         false, ''), ...
    TableSettings('PITs',           false, 'Probability Integral Transforms'), ...
    TableSettings('PointForecast',  false, 'Point Forecast'),...
    TableSettings('SimForecast',    false, 'Simulated Forecast') ...    
    };

%% Populate table

% Initialise output table.
outTable    = table();

% Loop over the requested score methods.
for jj = 1 : nScoreMethod
    
    % Extract the method specific information: Scores and Weights.
    if strcmpi( scoreMethod{jj}, originalScoreMethod ) && ~isEventThresholdUsed
        
        % Extract weights, scroes and store method.
        weightTables    = obj.weightsAndScores.weights;
        scoreTables     = obj.weightsAndScores.scores;
        nameScoreMethod = scoreMethod(jj);
        
    else
        % Update the weights and scores using requested method in scoreMethod.
        if isEventThresholdUsed
            weightsAndScores = updateWeightAndScores(obj, scoreMethod{jj}, ...
                false, false, eventThreshold);
            
            % The name to be stored as method, replace decimal pt with underscore. 
            nameScoreMethod = strcat(scoreMethod(jj), '_', num2str(eventThreshold));            
            nameScoreMethod = strrep(nameScoreMethod, '.', '_');
            
        else
            weightsAndScores = updateWeightAndScores(obj, scoreMethod{jj}, ...
                false, false);
            
            nameScoreMethod = scoreMethod(jj);
        end
        % Store these new weights, scroes and store method.
        weightTables    = weightsAndScores.weights;
        scoreTables     = weightsAndScores.scores;
    end
    
    
    % Populate the table for the given scoring method for each model and
    % horizon.
    for ii = 1 : nModels
        for kk = 1 : nHorizon
            horizon         = kk;
            
            % Select the data
            inWeight        = weightTables(:, ii, horizon);
            inScore         = scoreTables(:,  ii, horizon);
            
            % Validate the weights - check that it exists and fill in with equal 
            % weights if not. The timing convention on the weights is that they
            % are stored in line with the evaluationPeriod that they are used.
            % e.g. for a (Vintage, evaluationPeriod) pair (00.02, 00.01) and
            % (00.02, 00.02), the first pair would have equal weights as no
            % information is avialble at evluationPeriod 00.01 to construct the
            % weights but you would have the first outturn and so can construct
            % the score.
            % At (00.02, 00.02), no outturn is available to construct the score
            % but the weights are stored based upon the scores calculated in the
            % previous period.
            % validateTableData reorganises the input weights to respect this
            % timining convention.
            inWeight        = validateTableData(obj, inWeight, horizon, 'weights');            
                        
            % Evaluate the PITs at each period for the given vintage.            
            [inPit, inPointForecast, inSimForecast]    = ...
                combinationFns.returnPitFromEstimationCombination( obj, ii, kk );
                                    
            % Populate table.
            tableRow        = returnTable( tableInfo, vintages, periods, ...
                variableName, horizon, modelNames(ii), nameScoreMethod, ...
                inWeight, inScore, inPit, inPointForecast, inSimForecast);
            
            % Add new data rows to outTable.
            outTable               = [outTable; tableRow];
        end
    end
    
    
end
end
