function outTable = getProbabilityIntegralTransformsTests(obj, vblNames, ...
    scoreMethod, modelNames, defaultModelName, forecastHorizon, eventThreshold)
% getProbabilityIntegralTransformsTests - 
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
%   outTable            {table}             
%
% Usage:
%   getProbabilityIntegralTransformsTests(obj, vblNames, ...
%     scoreMethod, modelNames, defaultModelName, forecastHorizon, eventThreshold)
%
% Can also be used with not input argument (program uses Report defaults),
% i.e: 
%           reportObj.getProbabilityIntegralTransformsTests
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
    
    disp([mfilename ': You can not use the getProbabilityIntegralTransformsTests method for a Report that does not contain a Profor class'])
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

% Extract the data from the real time tables.

for hh = 1 : nVariableNames
    for ii = 1 : nHorizons
        dataTable{ii, hh}    = getFieldFromRealTimeTable(obj.resultTable, vblNames{hh}, ...
            forecastHorizon(ii), requestedScoreMethod, 'lastRealTime', ...
            'pits');
        
        scoreTable{ii, hh}   = getFieldFromRealTimeTable(obj.resultTable, vblNames{hh}, ...
            forecastHorizon(ii), requestedScoreMethod, 'lastRealTime', ...
            'scores');

    end
end

%% After the extraction of the data, calculate tests on PITs.

outTable = []; 

for hh = 1 : nVariableNames    

    % Initialise output table
    outTablehh            = table();

    % Find the requested series and plot them.
    count       = 0;
    for ii = 1 : nHorizons
        for jj = 1 : nModels
            count       = count + 1;

            % Select the model and forecast horizon for the data to plot,
            idxPits     = dataTable{ii, hh}.modelName == modelNames(jj) & ...
                ~isnan( dataTable{ii, hh}.PITs ) & ...
                dataTable{ii, hh}.ForecastHorizon == num2str( forecastHorizon(ii) );
            
            % and for scores.
            idxScores   = scoreTable{ii, hh}.modelName == modelNames(jj) & ...
                ~isnan( scoreTable{ii, hh}.Scores ) & ...
                scoreTable{ii, hh}.ForecastHorizon == num2str( forecastHorizon(ii) );


            if all( idxPits == 0) && all( idxScores == 0)
                continue
            else
            
                outStats(ii, 1).GoodnessOfFit   = getDensityTestGoodnessOfFit( ...
                    dataTable{ii, hh}(idxPits, :).PITs, forecastHorizon(ii) );

                outStats(ii, 1).Independence    = getDensityTestIndependence( ...
                    dataTable{ii, hh}(idxPits, :).PITs, forecastHorizon(ii) );

                outStats(ii, 1).Scores    = mean( scoreTable{ii, hh}(idxScores, :).Scores );

                %% Format and output table.

                % Set up the common table input settings.
                tableInfo   = {...,
                    TableSettings('modelName',                  false, ''), ...
                    TableSettings('variableName',               false, ''), ...
                    TableSettings('ForecastHorizon',            false, ''), ...
                    TableSettings('LR',                         false, ''),...
                    TableSettings('AD',                         false, ''),...
                    TableSettings('ChiSquared',                 false, ''),...
                    TableSettings('LB',                         false, ''),...
                    TableSettings(scoreMethod{1},               false, '')...
                    };

                % Populate table.
                tableRow        = returnTable( tableInfo, ...
                    modelNames{jj}, ...
                    vblNames{hh}, ...
                    forecastHorizon(ii), ...
                    outStats(ii, 1).GoodnessOfFit.likelihoodRatio_berkowitz, ...
                    outStats(ii, 1).GoodnessOfFit.andersonDarling, ...
                    outStats(ii, 1).GoodnessOfFit.chiSquared, ...
                    outStats(ii, 1).Independence.ljungBox, ...
                    outStats(ii, 1).Scores);

                % Add new data rows to outTablehh.
                outTablehh               = [outTablehh; tableRow];
                
            end

        end
    end
    
    outTable = [outTable; outTablehh];

end

end


