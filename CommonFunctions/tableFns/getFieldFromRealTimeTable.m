function outTable = getFieldFromRealTimeTable( inTable , vblName, forecastHorizon, ...
    scoringMethod, realTimeTableExtractType, extractionField)
% getFieldFromRealTimeTable - Returns requested field from real time table.
%
% Input:
%   inTable                     [Table] Output from Profor.returnResultTables.
%   vblName                     [str]
%   forecastHorizon             [int]
%   scoringMethod               [str]
%   realTimeTableExtractType   [str]    Method to extract data from real time table.      
%       {'lastRealTime', 'last'}
%   extractionField             [str]
%       {'pits', 'pointForecast'}
%
% Output:
%   outTable            [Table]     Real time matrix of requested outType.
%
% Usage: outTable = getFieldFromRealTimeTable( inTable , vblName, forecastHorizon, ...
%    scoringMethod, realTimeTableExtractType)
%   e.g. T = getFieldFromRealTimeTable( inTable , 'gdp', 1, 'logScoreD', 
%               'latestAvailableRealTime')
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

errType     = ['tableFns:', mfilename];

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

if numel(inTable) < 1
    warning(errType, 'Requested data not in result tables')
    outTable            = table();
    return
end

% Extract info from this subset of data.
dates           = unique( inTable.Vintage );
modelNames      = unique( inTable.ModelName );
nModels         = numel( modelNames );
nDates          = numel( dates );

%% Extract the real time data.


% Ensure field to extract from tables chooses the correct field name (case
% sensitive)
switch lower( extractionField )
    case lower( 'pits' )
        outType     = 'PITs';        
        
    case lower( 'pointForecast' )
        outType     = 'PointForecast';

    case 'scores' 
        outType     = 'Scores';
        
    otherwise
        error(errType, 'Requested field %s not recognised in result tables', ...
            extractionField)
end

% Choose the extract type from the real time input table.
switch lower( realTimeTableExtractType )
    case lower( 'lastRealTime' )
        % Returns last evaluated Pit forecastHorizon periods before current period.
        returnLastValue   = @(y)returnLastAvailableRealTime( y, forecastHorizon );        
        
    case lower( 'last' )
        % Helper fn that returns last element from input arg.
        returnLastValue   = @(y)returnLastElement( y );
        
    otherwise
        error(errType, 'Requested extraction type from the real time tables %s not recognised', ...
            realTimeTableExtractType)
end

% Set up the common table input settings.
tableInfo   = {...,
    TableSettings('ForecastEvaluationPeriod',   false ), ...
    TableSettings('modelName',                  true, ''), ...
    TableSettings('ForecastHorizon',            true, '',   true), ...
    TableSettings('realTimeTableExtractType',             true, 'Method used to extract field'),...
    TableSettings(outType,                      false, outType)
    };

% Initialise output table
outTable            = table();

for ii = 1 : nModels
    % Creat idx to select only the given model
    idx = inTable.ModelName == modelNames( ii ) ;        
      
    % Grouping by vintage, therefore will return nVintage results, and will 
    % return elements according to the fn returnLastValue, either the last
    % element or ...
    outPit              = rowfun(returnLastValue, inTable(idx, :), ...
        'GroupingVariable',     {'Vintage'},...
        'InputVariables',       outType, ...
        'OutputFormat',         'cell');
    
    % Populate table.
    tableRow        = returnTable( tableInfo, dates, modelNames(ii), ...
        forecastHorizon, realTimeTableExtractType, cell2mat(outPit) );
    
    % Add new data rows to outTable.
    outTable               = [outTable; tableRow];
        
    
end

end




