function outTable = evaluatePointForecast(obj, vblNames, ...
    scoreMethod, modelNames, defaultModelName, forecastHorizon, eventThreshold)
% evaluatePointForecast - Robust DM test statistic 
%   Produces a table with a robust DM test statistic (small sample
%   corrected), with the default model (deafultModelName) as a benchmark:
%   Forecasts are real-time and outturns are the last available vintage.
%
% Input:
%   obj                 [Report]
%   vblNames             [str]               e.g. 'gdp'
%   eventThreshold      [double]            e.g. 1.5
%   modelNames          [cell][str]         e.g. {'M1', 'M2'}
%   defaultModelName    [str]               e.g. 'M1'
%   forecastHorizon     [double]            e.g. 1
%
% Output:
%   outTable            [table]
%
% Usage:
%   evaluatePointForecast(obj, vblNames, modelNames, defaultModelName, 
%                         forecastHorizon, eventThreshold)
% 
% e.g.
%   Report.evaluatePointForecast('gdp', {'M1', 'M2', 'M3'}, ...
%       'M1', 1, [])
%
% Can also be used with not input argument (program uses Report defaults),
% i.e: 
%           reportObj.evaluatePointForecast
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

%% Validation

outTable = {};

if isempty(obj.proforObj)
    
    disp([mfilename ': You can not use the evaluatePointForecast method for a Report that does not contain a Profor class'])
    return    
        
else

    % Warning / Error identifiers.
    errType = ['Report:', mfilename];

    % inputNamesNeeded is used in the script argumentPassingScript
    inputNamesNeeded    = {'vblNames', 'modelNames', 'forecastHorizon', 'defaultModelName', 'scoreMethod', 'eventThreshold'};               
    numberOfInputArgs   = nargin;

    if numberOfInputArgs == 7 && ~isempty(eventThreshold)
        isThresholdSupplied = true;
    else
        isThresholdSupplied = false;
    end
        
    argumentPassingScript(obj, inputNamesNeeded, numberOfInputArgs); 

end

scoreMethod     = ifStringConvertToCellstr( scoreMethod );
vblNames        = ifStringConvertToCellstr( vblNames );
modelNames      = ifStringConvertToCellstr( modelNames );
if iscellstr(defaultModelName) 
   defaultModelName = defaultModelName{1}; 
end

%% Extract parameters from input args
nModels         = numel( modelNames );
nHorizons       = numel( forecastHorizon );
nVariableNames  = numel( vblNames );

%% 2. Get cdf Threshold tables, prob( X < eventThreshold).
% Name of scoring method to access CDFs of event thresholds.

% Fn to check results table and populate if data not there.
if isThresholdSupplied
    requestedScoreMethod    = strcat(scoreMethod(1), '_', num2str(eventThreshold));
    requestedScoreMethod    = strrep(requestedScoreMethod, '.', '_');    
    obj.populateResultTable( scoreMethod, eventThreshold )
    
else
    requestedScoreMethod    = scoreMethod;    
    obj.populateResultTable( scoreMethod )
end

%% Chose the data to extract from the results table.

% Extract the point forecasts from the real time tables.
for hh = 1 : nVariableNames
    for ii = 1 : nHorizons
        dataTable{ii, hh}    = getFieldFromRealTimeTable(obj.resultTable, vblNames{hh}, ...
            forecastHorizon(ii), requestedScoreMethod, 'last', ...
            'pointForecast');

    end
end

%% After the extraction of the data, evaluate Point forecast:

outTable = []; 

for hh = 1 : nVariableNames

    %
    evaluationVintage = 'last';

    % Initialise output table
    outTablehh            = table();


    for ii = 1 : nHorizons

        % Select the model and forecast horizon for the data to plot,
        idxPits     = dataTable{ii, hh}.ForecastHorizon == num2str( forecastHorizon(ii) );

        % Model might be missing for this variables. Qucik and dirty
        outStats            = getPointForecastTestStats( dataTable{ii, hh}(idxPits, :), ...
                obj.rawDataTable, forecastHorizon(ii), defaultModelName, evaluationVintage, vblNames{hh} );

        %% Format and output table.

        % Set up the common table input settings.
        tableInfo   = {...,
            TableSettings('modelName',                  false, ''), ...
            TableSettings('DefaultModel',               true, ''), ...
            TableSettings('ForecastHorizon',            false, ''), ...
            TableSettings('DieboldMariano',             false, '')
            };


        for jj = 1 : nModels
            if ~strcmpi( defaultModelName, modelNames(jj) )

                % Populate table.
                tableRow        = returnTable( tableInfo, ...
                    modelNames{jj}, ...
                    defaultModelName, ...
                    forecastHorizon(ii), ...
                    outStats.( modelNames{jj} )...
                    );

                % Add new data rows to outTable.
                outTablehh               = [outTablehh; tableRow];


            end
        end

    end
    
    outTable = cat(2,outTable,{outTablehh});

    
end

end


