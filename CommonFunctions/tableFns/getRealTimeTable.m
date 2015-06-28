function outTable = getRealTimeTable( inTable , vblName, forecastHorizon, ...
    scoringMethod, outType)
% getRealTimeTable - Returns the standard 'real time matrix' of weights / scores.
%   
%
% Input:
%   inTable             [Table]
%   vblName             [str]
%   forecastHorizon     [int]
%   scoringMethod       [str]
%   outType             [str]       (weights, scores)
%
% Output:
%   outTable            [Table]     Real time matrix of requested outType.
%
% Usage: outTable = getRealTimeTable( inTable , vblName, forecastHorizon, ...
%    scoringMethod, outType)
%   e.g. T = getRealTimeTable( inTable , 'gdp', 1, 'logScoreD', 'weights')
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

errType    = ['tableFns:', mfilename];

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
modelNames      = unique( inTable.ModelName );
nModels         = numel( modelNames );
nDates          = numel( dates ); 

%% Extract the real time data.

% A helper function that returns row with leading zeros if no data available.
returnPaddedData = @(y)returnHitoricalResultFromTable(y, nDates);

% Convert periods date from YYYY.NN, to VYYYYQNN.
variableNames   = strrep( cellstr(dates), '.', 'Q');
variableNames   = strcat('V', variableNames);

% Replace the funny _1 dating convention. 
variableNames   = regexprep( variableNames, '_(.)', '');

% Initialise output table
outTable            = table();

% Loop over the models and extract the last element for each.
for ii = 1 : nModels
    
    % Creat idx to select only the given model
    idx = inTable.ModelName == modelNames(ii);
    
    % Select weights or scores to extract, tables case sensitive so just a quick
    % check to ensure they have the correct case.
    switch lower(outType)
        case 'weights'
            outType     = 'Weights';
            
        case 'scores'
            outType     = 'Scores';
            
        case 'pits'
            outType     = 'PITs';
            
        otherwise
            error(errType, 'Requested real time output type %s not recognised', ...
                outType)
    end
            
    % For each model, for each period return the values at each vintage.
    C           = rowfun(returnPaddedData, inTable(idx, :), ...
        'GroupingVariable',     {'Periods'},...
        'InputVariables',       outType,...
        'OutputVariableNames',  variableNames);
    
    % Remove the row names from the table abd GroupCount.
    C.Properties.RowNames   = {};
    C.GroupCount            = [];
    
    % Create a model name column in a table.
    C1                      = table( repmat(modelNames(ii), [height(C) 1]), ...
        'VariableNames', {'Model'});
    
    % Append model name column to the table Ç.
    C                       = [C1 C];
    
    % Add a description.
    C.Properties.Description = ['Real time vintages along the x-axis.',...
        ' Time periods along the y-axis.'];
    
    % Store for all the models.
    outTable    = [outTable; C];
    
end


end




