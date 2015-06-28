function plotProbabilityEventThreshold(obj, vblNames, eventThreshold, modelNames, ...
    forecastHorizon, eventType)
% plotProbabilityEventThreshold Plots Prob( vblNames < eventThreshold ) vs dates.
%   % N.B. The prob(X < z) is taken for concurrent date / evaluation periods,
%   i.e. (OO.01, 00.01).
%
% Input:
%   obj                 [Report]
%   vblNames             [str]               e.g. 'gdp'
%   eventThreshold      [double]            e.g. 1.5
%   modelNames          [cell][str]         e.g. {'M1', 'M2'}
%   forecastHorizon     [double]            e.g. 1
%
% Output:
%   figure              [figure]
%
% Usage:
%   plotProbabilityEventThreshold(obj, vblNames, eventThreshold, modelNames, ...
%       forecastHorizon)
% e.g.
%   Report.plotProbabilityEventThreshold(obj, 'gdp', 1.5, {'M1', 'M2', 'M3'}, 1)
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
    
    disp([mfilename ': You can not use the plotProbabilityEventThreshold method for a Report that does not contain a Profor class'])
    return
    
else
    
    % Warning / Error identifiers.
    errType = ['Report:', mfilename];
    
    % inputNamesNeeded is used in the script argumentPassingScript
    inputNamesNeeded    = {'vblNames', 'eventThreshold', 'modelNames','forecastHorizon', 'eventType'};
    numberOfInputArgs   = nargin;
    
    argumentPassingScript(obj, inputNamesNeeded, numberOfInputArgs);
    
end

eventType   = ifStringConvertToCellstr( eventType );

if ischar(modelNames)
    modelNames = {modelNames};
end
if ischar(vblNames)
    vblNames = {vblNames};
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

%% Extract the CDF from the result tables (stored in scores field).

% Populate the TEL stats for the requested forecast horizons.
for hh = 1 : nVariableNames
    for ii = 1 : nHorizons
        % Extract the latest available real time values for CDF threshold event.
        outCdfTable{ii,hh} = getFieldFromRealTimeTable(obj.resultTable, vblNames{hh}, ...
            forecastHorizon(ii), requestedScoreMethod, 'last', ...
            'scores');
        
        % If you wan to plot the opposite of the event type stored, just flip as
        % probabilities of the two events sum to one.
        if ~strcmpi( eventType, obj.defaultProperties.eventType)
            outCdfTable{ii,hh}.Scores = 1 - outCdfTable{ii,hh}.Scores;
        end
        
        
    end
end

%% After the extraction of the data, plot the Prob( vblNames < eventThreshold ):
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
            
            
            % Find the appropriate data from the table.
            plotDataIdx     = outCdfTable{ii,hh}.ForecastHorizon == num2str(forecastHorizon(ii))...
                & outCdfTable{ii,hh}.modelName == modelNames{jj};
            
            % Get the data with the index
            plotData        = outCdfTable{ii,hh}(plotDataIdx, :);
            
            if isempty(plotData)
                continue
            else
                
                % Create index that loops of the max number of linestyles and markers.
                idx             = mod(count, numel(obj.plotOptions.linestyles));
                
                % Plot the data.
                legendToPlot(end+1)     = plot( plotData.Scores, ...
                    [obj.plotOptions.linestyles{idx} obj.plotOptions.markers(idx)] );
                
                % Store the legend.
                legendString{end + 1}   = [modelNames{jj} ', Hor: ' ...
                    num2str(forecastHorizon(ii)) ];
                
            end
            
        end
    end
    
    % Squeeze the axis if asked for.
    if obj.plotOptions.axisTight
        axis tight
    end
    
    % Plot legend
    if obj.plotOptions.plotLegend
        legend(legendToPlot, legendString, 'FontSize', obj.plotOptions.legendFontSize)
    end
    
    % Plot title
    if obj.plotOptions.plotTitle
        if strcmpi( eventType, 'leftHandSide')
            eventTypeMath = ' < ';
            
        else
            eventTypeMath = ' > ';
        end
        
        graph_title     = sprintf(['Pr( ' vblNames{hh} eventTypeMath ...
            num2str(eventThreshold) ' ) event.']);
        title(graph_title, 'FontSize', obj.plotOptions.titleFontSize);
    end
    
    % Convert the date names in YYYY.NN_1 to YYYY.NN format.
    dates   = unique( plotData.ForecastEvaluationPeriod );
    dates   = ifCategoricalConvertToString( dates );
    
    % Find and remove the trailing _1.
    dates   = regexprep( dates, '_(.)', '');
    
    % Set dates for x-axis and Label
    [~, ~]  = setXtickAndLabel(dates, 'handle', gca);
    
    % Set y-axis to [0, 1]
    set(gca,'YLim',[0 1])
    
    % Turn the box off around the figure.
    set(gca, 'box', 'off');
    
end

end


