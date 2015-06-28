function outTable = getRealTimeTableDiagonal( inTable , vblName, forecastHorizon, ...
    scoringMethod, outType)
% getRealTimeTableDiagonal - Contructs a set of prepared tables based on the
%                            results from a Profor experiment
%
% Input:
%   inTable             [Table]
%   vblName             [str]
%   forecastHorizon     [int]
%   scoringMethod       [str]
%   outType             [str]       (weights, scores)
%
% Output:
%   outTable            [Table]
%       Date            [YYYY.NN_1]
%       Horizon         [int]
%       ModleNames - 1  [numeric]
%       ...
%       ModleNames - N  [numeric]
%
% Usage: outTable = getRealTimeTableDiagonal( inTable , vblName, forecastHorizon, ...
%    scoringMethod, outType)
%   e.g. T = getRealTimeTableDiagonal( inTable , 'gdp', 1, 'logScoreD', 'weights')
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

% Create an index for the given horizon, variable and scoring method.
if strcmpi( class( inTable.Horizon ), 'categorical' )
    idxOutTable     = (inTable.Horizon == num2str(forecastHorizon) ...
        & inTable.Variable == vblName & inTable.Method == scoringMethod);
    
else
    % Horizon is numeric.
    idxOutTable     = (inTable.Horizon == forecastHorizon ...
        & inTable.Variable == vblName);
end

% Restrict the table to this subsection of data,
inTable   = inTable(idxOutTable, :);

% Extract some info from this subset of data.
dates           = unique( inTable.Vintage );
modelNames      = unique(inTable.ModelName);
nModels         = numel(modelNames);
nDates          = numel(dates);

% Initialise output matrix
realTimeMatrix  = zeros(nDates, nModels);

%% Extract the real time data.

% A helper function that returns the last element for an input argument.
extractLastElem = @returnRealTimeVintageResultFromTable;

% Loop over the models and extract the last element for each.
for ii = 1 : nModels
    
    % Creat idx to select only the given model
    idx = inTable.ModelName == modelNames(ii);
    
    % Extract the real time vintage for each model by grouping on vintage and
    % returning the last element within that group
    realTimeTable   = rowfun(extractLastElem, inTable(idx, :),...
        'GroupingVariable',     {'Vintage'}, ...
        'ExtractCellContents',  true, ...
        'OutputVariableNames',  inTable.Properties.VariableNames(2:end));
    
    % Store the real time vintage for each model by weights / scores.
    switch lower(outType)
        case 'weights'
            realTimeMatrix(:, ii) = realTimeTable.Weights;
            
        case 'scores'
            realTimeMatrix(:, ii) = realTimeTable.Scores;
            
        case 'pits'
            realTimeMatrix(:, ii) = realTimeTable.PITs;
                        
        otherwise
            error(errType, 'Requested real time output type %s not recognised', ...
                outType)
    end
    
end

% Generate an ouput table with the realtime matrix.
tableInfo   = {...,
    TableSettings('Date',       false ), ...
    TableSettings('Horizon',    true ) ...
    };

% Table with dates and forecastHorizon.
tableRow    = returnTable( tableInfo, dates, forecastHorizon);

% Generate the output table with the results in realTimeMatrix.
outTable    = [tableRow, array2table(realTimeMatrix, 'VariableNames', ...
    cellstr(modelNames))];

% Label the table.
outTable.Properties.Description = 'Real time weights / score matrix.';


end




