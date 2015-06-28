function outTable = getDensityForecastScoreTable(obj, vblNames, ...
    modelNames, forecastHorizon, scoreMethod, requestedVintage, startPeriod, ...
    endPeriod, defaultModelName, eventThreshold)
% getDensityForecastScoreTable  - Returns the average score table for a given
%                                 period and evaluation vintage.
%
% Input:
%   obj                 [Report]
%   vblNames             [str]
%   modelNames          [cellstr]
%   forecastHorizon     [double]
%   scoreMethod         [str]
%   requestedVintage    [double]            YYYY.NN
%   startPeriod         [double]            YYYY.NN
%   endPeriod           [double]            YYYY.NN
%   defaultModelName    [str]
%   eventThreshold      [double]
%
% Output:
%
% Usage:
%
%   outTable = getDensityForecastScoreTable(obj, vblNames, ...
%     modelNames, forecastHorizon, scoreMethod, requestedVintage, startPeriod, ...
%     endPeriod, defaultModelName, eventThreshold)
%
% Can also be used with not input argument (program uses Report defaults),
% i.e: 
%
%   outTable = reportObj.getDensityForecastScoreTable
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

outTable = [];

if isempty(obj.proforObj)
    
    disp([mfilename ': You can not use the getDensityForecastScoreTable method for a Report that does not contain a Profor class'])
    return    
        
else

    % Warning / Error identifiers.
    errType = ['Report:', mfilename];

    % inputNamesNeeded is used in the script argumentPassingScript
    inputNamesNeeded    = {'vblNames', 'modelNames', 'forecastHorizon', 'requestedVintage', 'startPeriod', 'endPeriod', 'scoreMethod', 'defaultModelName', 'eventThreshold'};               
    numberOfInputArgs   = nargin;

    if numberOfInputArgs == 10 && ~isempty(eventThreshold)
        isThresholdSupplied = true;
    else
        isThresholdSupplied = false;
    end
        
    argumentPassingScript(obj, inputNamesNeeded, numberOfInputArgs); 

end

scoreMethod     = ifStringConvertToCellstr( scoreMethod );
vblNames        = ifStringConvertToCellstr( vblNames );
modelNames      = ifStringConvertToCellstr( modelNames );

% Hard coded
dataType        = 'scores';


% Convert requested vintage into the same format as stored in table.
requestedVintage    = strrep(  num2str( requestedVintage ), '.', 'Q');
requestedVintage    = strcat('V', requestedVintage);

%% Extract parameters from input args
nModels         = numel( modelNames );
nHorizons       = numel( forecastHorizon );
nVbls           = numel( vblNames );

%%
% Fn to check results table and populate if data not there, either with or
% without event threshold.
if isThresholdSupplied
    requestedScoreMethod    = strcat(scoreMethod(1), '_', num2str(eventThreshold));
    requestedScoreMethod    = strrep(requestedScoreMethod, '.', '_');
    obj.populateResultTable( scoreMethod, eventThreshold )
    
else
    requestedScoreMethod    = scoreMethod;
    obj.populateResultTable( scoreMethod )
end

%%

[meanScores, nObservations]  = deal(zeros( nModels, nVbls, nHorizons));
hasVariableName              = false( nModels, nVbls, nHorizons);


for ii = 1 : nHorizons
    for jj = 1 : nVbls
        
        % Return the entire matrix of real time weights or scores.
        realTimeTable   = getRealTimeTable(obj.resultTable, vblNames{jj}, forecastHorizon(ii), ...
            requestedScoreMethod, dataType);
        
        for kk = 1 : nModels
            % Restrict to the given model, vintage and start and end dates
            % requested.
            
            % Restrict to the given model and date range.
            idx     = realTimeTable.Model == modelNames(kk) & ...
                realTimeTable.Periods >= startPeriod & ...
                realTimeTable.Periods <= endPeriod;
            
            if sum(idx) == 0
                warning(errType, 'Data for the model %s and variable name %s, start period %6.2f and end period %6.2f was not found.', ...
                    modelNames{kk}, vblNames{jj}, startPeriod, endPeriod)
                
                meanScores(kk, jj, ii)      = NaN;
                nObservations(kk, jj, ii)   = 0;
                
            else
                % Get the data for the selected vintage and date range.
                values = realTimeTable(idx, :).( requestedVintage );
                                
                nObservations(kk, jj, ii)   = sum(~isnan(values));                
                meanScores(kk, jj, ii)      = nanmean( values );                    
                % Note the use a nanmean!!! Need this to because the
                % realTimeTable contains nans at the end of each vintage,
                % and the periods might cover this!!!
                hasVariableName(kk, jj, ii) = true;
                
            end

        end
    end
end

%% Generate an output table with the requested data.

% Set up the common table input settings.
tableInfo   = {...,
    TableSettings('ModelNames',         false, '', true), ...
    TableSettings('StartPeriod',        true,  'Start Period'), ...
    TableSettings('EndPeriod',          true,  'End Period'), ...
    TableSettings('ForecastHorizon',    true,  'Forecast Horizon'), ...
    TableSettings('VariableName',       true,  'Variable Name'), ...
    TableSettings('AverageScores',      false, 'Requested Data'), ...
    TableSettings('nObservations',      false, 'Number of observations'), ...        
    TableSettings('HasVariableName',    false, 'Indicator', true) ...    
    };

% Initialise output table
outTable            = table();

% Populate the output table
for ii = 1 : nHorizons
    for jj = 1 : nVbls
        
        % Populate table for the given horizon and variable.
        tableRow        = returnTable( tableInfo, modelNames, startPeriod, ...
            endPeriod, forecastHorizon(ii), vblNames{jj}, meanScores(:, jj, ii),...
            nObservations(:, jj, ii), hasVariableName(:, jj, ii));
        
        outTable    = [outTable; tableRow];
        
    end
end

end


