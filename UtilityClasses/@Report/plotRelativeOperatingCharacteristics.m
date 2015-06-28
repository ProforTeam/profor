function plotRelativeOperatingCharacteristics(obj, vblNames, eventThreshold, modelNames, ...
    defaultModelName, forecastHorizon, eventType)
% plotRelativeOperatingCharacteristics - Plots Relative Operating Characteristics.
%   Forecasts are real-time and outturns are the last available vintage.
%   Defined as True positives (hits) rate vs false positives (false alarms) rate.
%
% The contingency table is defined on an Event for two cases and Test as:
%   eventType = 'leftHandSide':
%       Event = Prob( X < z ) 
%   eventType = 'rightHandSide':
%       Event = Prob( X > z ) 
%
%   Test  = Event > R = (C/L).
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
% NB,   True positive rate  = True Positive  / Event Positive.
%       False positive rate = False Positive / Event Negative.
%
% Input:
%   obj                 [Report]
%   vblNames            [str]               e.g. 'gdp'
%   eventThreshold      [double]            e.g. 1.5    
%   modelNames          [cell][str]         e.g. {'M1', 'M2'}
%   defaultModelName    [str]               e.g. 'M1'
%   forecastHorizon     [double]            e.g. 1
%   eventType           [str]               e.g. 'leftHandSide'
%
% Output:
%   figure              [figure]
%
% Can also be used with no input argument (program uses Report defaults),
% i.e: 
%           reportObj.plotRelativeOperatingCharacteristics
%
% References:
% % Zhou, Xiao-Hua; Obuchowski, Nancy A.; McClish, Donna K. (2002). "Statistical 
%   Methods in Diagnostic Medicine". New York, NY: Wiley & Sons.
%
% For econ literature on resolution and calibration see also
% Galbraith, J.W. and S. van Norden (2011) "Kernel-based calibration 
% diagnostics for recession and inflation probability forecasts", 
% International Journal of Forecasting
% Galbraith, J.W. and S. van Norden (2012) "Assessing Gross Domestic 
% Product and inflation probability forecasts derived from 
% Bank of England fan charts", Journal of the Royal Statistical 
% Society Series A  - Statistics in Society
%
%
% Usage:
%   plotRelativeOperatingCharacteristics(obj, vblNames, eventThreshold, modelNames, ...
%       forecastHorizon, eventType)
% e.g.
%   Report.plotRelativeOperatingCharacteristics('gdp', 1.5, {'M1', 'M2', 'M3'}, ...
%       1, 'leftHandSide')
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
    
    disp([mfilename ': You can not use the plotRelativeOperatingCharacteristics method for a Report that does not contain a Profor class'])
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

% Certain variables expected as cellstr.
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
scoreMethod     = {'cdfEventThresholdMap'};

% The requested score method is stored with its decimal pt replaced with an
% underscore.
requestedScoreMethod    = strcat(scoreMethod(1), '_', num2str(eventThreshold));
requestedScoreMethod    = strrep(requestedScoreMethod, '.', '_');

% Fn to check results table and populate if data not there.
obj.populateResultTable( scoreMethod, eventThreshold )

%% 3. Check if raw data stored in Report object, if not populate.

isRawDataPopulated = numel( obj.rawDataTable.Properties.VariableNames ) > 0;

if ~isRawDataPopulated
    obj.rawDataTable    = obj.proforObj.returnRawDataTables;
end

%% 5. Evaluate the point forecast tests.

% Set parameters for extraction of the CDF of the threshold event and the choice
% of data vintage to be used in the TEL, usually checked against the most recent
% vintage denoted by 'last'.
telDataEvaluationVintage    = 'last';

% Populate the TEL stats for the requested forecast horizons.
for hh = 1 : nVariableNames
    for ii = 1 : nHorizons

        % Extract the last available real time values for CDF threshold event.
        outCdfTable    = getFieldFromRealTimeTable(obj.resultTable, vblNames{hh}, ...
            forecastHorizon(ii), requestedScoreMethod, 'last', ...
            'scores');
        
        % If you wan to plot the opposite of the event type stored, just flip as
        % probabilities of the two events sum to one.
        if ~strcmpi( eventType, obj.defaultProperties.eventType)
            outCdfTable.Scores = 1 - outCdfTable.Scores;
        end

        outStats(ii, hh).TotalEconomicLoss = getTotalEconomicLoss( outCdfTable, ...
            obj.rawDataTable, forecastHorizon(ii), defaultModelName, ...
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
        for jj = 1 : nModels
            count       = count + 1;

            % Not all models forecast the same variable. Qucik and dirty
            % solution
            try
                nGridC = numel( outStats(ii, hh).TotalEconomicLoss.( modelNames{jj} ...
                    ).ContingencyTable );
            catch
               continue 
            end

            % Need to loop over the grid as have double indexing - could do away
            % with by using horizon and storing the outStats flat.

            truePositiveRate    = zeros( nGridC, 1);
            falsePositiveRate   = zeros( nGridC, 1);

            for kk = 1 : nGridC
                % Total number of true and false events.
                trueEvent   = sum( outStats(ii, hh).TotalEconomicLoss.( modelNames{jj} ...
                    ).ContingencyTable(kk,  1).matrix(:, 1) );

                falseEvent   = sum( outStats(ii, hh).TotalEconomicLoss.( modelNames{jj} ...
                    ).ContingencyTable(kk, 1).matrix(:, 2) );

                % True Positive Rate.
                truePositiveRate(kk, 1) = ...
                    outStats(ii, hh).TotalEconomicLoss.( modelNames{jj} ...
                    ).ContingencyTable(kk, 1).matrix(1, 1)    ....
                    / trueEvent;

                % False Alarm rate.
                falsePositiveRate(kk, 1) = ...
                    outStats(ii, hh).TotalEconomicLoss.( modelNames{jj} ...
                    ).ContingencyTable(kk, 1).matrix(1, 2)    ....
                    / falseEvent;                        

            end

            % Create index that loops of the max number of linestyles and markers.
            idx             = mod(count, numel(obj.plotOptions.linestyles));

            % Plot the data.
            legendToPlot(end+1)     = plot( falsePositiveRate, truePositiveRate, ...
                [obj.plotOptions.linestyles{idx} obj.plotOptions.markers(idx)] );

            % Store the legend.
            legendString{end + 1}   = [modelNames{jj} ', Hor: ' ...
                num2str(forecastHorizon(ii)) ];

        end
    end

    % Plot 45 degree line.        
    fplot(@(x)(x),[0,1], obj.plotOptions.linestyles{idx+1}, '-r');
    
    % Squeeze the axis if asked for.
    if obj.plotOptions.axisTight
        axis tight
    end

    % Plot legend
    if obj.plotOptions.plotLegend
        legend(legendToPlot, legendString, 'FontSize', obj.plotOptions.legendFontSize);
    end

    % Plot title
    if obj.plotOptions.plotTitle
        if strcmpi( eventType, 'leftHandSide')
            eventTypeMath = ' < ';
            
        else
            eventTypeMath = ' > ';
        end                

        graph_title     = sprintf(['Receiver Operating Characteristics, Pr( ' ...
            vblNames{hh} eventTypeMath ...
            num2str(eventThreshold) ' ) event.']);
        title(graph_title, 'FontSize', obj.plotOptions.titleFontSize)
    end

    % Label axis
    xlabel('False Positive Rate, FPR = FP/N', 'FontSize', obj.plotOptions.axisFontSize);
    ylabel('True Positive Rate, TPR = TP/P', 'FontSize', obj.plotOptions.axisFontSize);

    % Turn the box off around the figure.
    set(gca, 'box', 'off');
    
end

end


