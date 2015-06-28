function plotTotalEconomicLoss(obj, vblNames, eventThreshold, modelNames, ...
    defaultModelName, forecastHorizon, eventType)
% plotTotalEconomicLoss - Plots Total Economic Loss (TEL)
%   Forecasts are real-time and outturns are the last available vintage.
%   TEL defined as TEL = L * contingency(2, 1) + C * (Warning True). The cdf for
%   the prob(X < z) is for the score method: logScoreD.
% N.B. The prob(X < z) is taken for concurrent date / evaluation periods, i.e.
% (OO.01, 00.01).
% The contingency table is defined for an Event and Test as:
%   Event = Prob( X < z )
%   Test  = Prob( X < z) > R = (C/L).
%
%              Event
%   Test      Y     N
%         Y  (1,1)  (1,2)
%         N  (2,1)  (2,2)
% Where:
%   (1,1) - True  Positive
%   (1,2) - False Positive
%   (2,1) - False Negative
%   (2,2) - True  Negative
%
% And Warning true = (1,1) + (1,2).
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
%   figure              [figure]
%
% Can also be used with not input argument (program uses Report defaults),
% i.e:
%           reportObj.plotTotalEconomicLoss
%
%
% Reference:
%
% Murphy, A.H. and Winkler, R.L. (1987), "A general framework for forecast
%   verification", Monthly Weather Review, 115, 1330-1338.
%
% Usage:
%   plotTotalEconomicLoss(obj, vblNames, eventThreshold, modelNames, ...
%       defaultModelName, forecastHorizon)
% e.g.
%   Report.plotTotalEconomicLoss('gdp', 1.5, {'M1', 'M2', 'M3'}, ...
%       'M1', 1)
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


if isempty(obj.proforObj)
    
    disp([mfilename ': You can not use the plotTotalEconomicLoss method for a Report that does not contain a Profor class'])
    return
    
else
    
    % Warning / Error identifiers.
    errType = ['Report:', mfilename];
    
    % inputNamesNeeded is used in the script argumentPassingScript
    inputNamesNeeded    = {'vblNames', 'eventThreshold', 'modelNames', ...
        'defaultModelName', 'forecastHorizon', 'eventType'};
    numberOfInputArgs   = nargin;
    
    argumentPassingScript(obj, inputNamesNeeded, numberOfInputArgs);
    
end

vblNames    = ifStringConvertToCellstr( vblNames );
modelNames  = ifStringConvertToCellstr( modelNames );

if iscellstr(defaultModelName)
    defaultModelName = defaultModelName{1};
end

%% Extract parameters from input args
nModels         = numel( modelNames );
nHorizons       = numel( forecastHorizon );
nVariableNames  = numel( vblNames );


%% 2. Get cdf Threshold tables, prob( X < eventThreshold).
% Name of scoring method to access CDFs of event thresholds.
cdfScoreMethod     = {'cdfEventThresholdMap'};

% The requested score method is stored with its decimal pt replaced with an
% underscore.
requestedScoreMethod    = strcat(cdfScoreMethod(1), '_', num2str(eventThreshold));
requestedScoreMethod    = strrep(requestedScoreMethod, '.', '_');

% Fn to check results table and populate if data not there.
obj.populateResultTable( cdfScoreMethod, eventThreshold )

%% 3. Check if raw data stored in Report object, if not populate.
rawDataTable = obj.rawDataTable;

%% 5. Evaluate the point forecast tests.

% Set parameters for extraction of the CDF of the threshold event and the choice
% of data vintage to be used in the TEL, usually checked against the most recent
% vintage denoted by 'last'.
telDataEvaluationVintage    = 'last';

% Populate the TEL stats for the requested forecast horizons.
for hh = 1 : nVariableNames
    for ii = 1 : nHorizons
        
        % Extract the latest available real time values for CDF threshold event.
        outCdfTable    = getFieldFromRealTimeTable(obj.resultTable, vblNames{hh}, ...
            forecastHorizon(ii), requestedScoreMethod, 'last', ...
            'Scores');
        
        % Check that the defaultModelName requested is available for the given 
        % variable & horizon combination
        availableModels = unique( outCdfTable.modelName )';
        availableModels = ifCategoricalConvertToString( availableModels );
        isDefaultModelAvailable = sum( strcmpi( availableModels, defaultModelName ) ) > 0;
        
        if ~isDefaultModelAvailable
            msg = ['The default model "%s" does not include the variable "%s", ', ...
                'the requested models and default model must all contain variable "%s".'];
            error( errType, msg, defaultModelName, vblNames{hh}, vblNames{hh})
        end
            
        
        % If you wan to plot the opposite of the event type stored, just flip as
        % probabilities of the two events sum to one.
        if ~strcmpi( eventType, obj.defaultProperties.eventType)
            outCdfTable.Scores = 1 - outCdfTable.Scores;
        end
        
        outStats(ii, hh).TotalEconomicLoss = getTotalEconomicLoss( outCdfTable, ...
            rawDataTable, forecastHorizon(ii), defaultModelName, ...
            telDataEvaluationVintage, vblNames{hh}, eventThreshold, eventType);
    end
end

%% After the extraction of the data, plot the TEL:

for hh = 1 : nVariableNames
    % Setup graph
    handle          = figure('name',vblNames{hh});
    hold on;
    legendString    = {};
    legendToPlot    = [];
    
    % Find the requested series and plot them.
    count       = 0;
    for ii = 1 : nHorizons
        % Define the default TEL to normalise models by.
        defaultTEL  = outStats(ii, hh).TotalEconomicLoss.( defaultModelName ...
            ).totalEconomicLoss;
        
        for jj = 1 : nModels
            count       = count + 1;
            
            % Normalise the TEL by the default model.
            normalisedTEL = ...
                outStats(ii, hh).TotalEconomicLoss.( modelNames{jj} ).totalEconomicLoss...
                ./ defaultTEL;
            
            % Create index that loops of the max number of linestyles and markers.
            idx             = mod(count, numel(obj.plotOptions.linestyles));
            
            % Plot the data.
            legendToPlot(end+1)     = plot( outStats(ii, hh).TotalEconomicLoss.( ...
                modelNames{jj} ).relativeCost, normalisedTEL, ...
                [obj.plotOptions.linestyles{idx} obj.plotOptions.markers(idx)] );
            
            % Store the legend.
            legendString{end + 1}   = [modelNames{jj} ', Hor: ' ...
                num2str(forecastHorizon(ii)) ];
            
        end
    end
    
    % Squeeze the axis if asked for.
    if obj.plotOptions.axisTight
        axis tight
    end
    
    % Plot legend
    if obj.plotOptions.plotLegend
        legend(legendToPlot, legendString, 'FontSize', obj.plotOptions.legendFontSize);
    end
    
    if obj.plotOptions.plotTitle
        if strcmpi( eventType, 'leftHandSide')
            eventTypeMath = ' < ';
            
        else
            eventTypeMath = ' > ';
        end
        
        graph_title     = sprintf(['Total Economic Loss (TEL), ' vblNames{hh}  ...
            eventTypeMath num2str(eventThreshold) ' event.']);
        title(graph_title, 'FontSize', obj.plotOptions.titleFontSize);
    end
    
    % Label axis
    xlabel('Relative Cost, R = C/L', 'FontSize', obj.plotOptions.axisFontSize);
    
    % Turn the box off around the figure.
    set(gca, 'box', 'off');
end

end


