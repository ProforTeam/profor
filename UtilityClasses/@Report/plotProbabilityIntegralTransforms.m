function plotProbabilityIntegralTransforms(obj, vblNames, modelNames, ...
    forecastHorizon, scoreMethod, eventThreshold)
% plotTotalEconomicLoss - Plots Probability Integral Transforms (PITs)
%
% Input:
%   obj                 [Report]
%   vblNames            [str]               e.g. 'gdp'
%   eventThreshold      [double]            e.g. 1.5
%   modelNames          [cell][str]         e.g. {'M1', 'M2'}
%   forecastHorizon     [double]            e.g. 1
%
%
% Output:
%   figure              [figure]
%
%
% Usage:
%   reportObj.plotProbabilityIntegralTransforms(obj, vblNames, modelNames, ...
%       forecastHorizon, realTimeTableExtractionType, scoreMethod,...
%       eventThreshold)
%
% Can also be used with not input argument (program uses Report defaults),
% i.e: 
%           reportObj.plotProbabilityIntegralTransforms
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

%% Refactor
realTimeTableExtractionType = 'last';

%% Validation

if isempty(obj.proforObj)
    
    disp([mfilename ': You can not use the plotProbabilityIntegralTransforms method for a Report that does not contain a Profor class'])
    return    
        
else

    % Warning / Error identifiers.
    errType = ['Report:', mfilename];

    % inputNamesNeeded is used in the script argumentPassingScript
    inputNamesNeeded    = {'vblNames', 'modelNames', 'forecastHorizon', 'realTimeTableExtractionType', 'scoreMethod', 'eventThreshold'};               
    numberOfInputArgs   = nargin;

    if numberOfInputArgs == 7 && ~isempty(eventThreshold)
        isThresholdSupplied = true;
    else
        isThresholdSupplied = false;
    end
    
    
    argumentPassingScript(obj, inputNamesNeeded, numberOfInputArgs); 

end

if ischar(vblNames)
    vblNames = {vblNames};
end
if ischar(modelNames)
    modelNames = {modelNames};
end

% The score method should be a cellstr
if ischar( scoreMethod )
    scoreMethod = cellstr( scoreMethod );
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
for hh = 1 : nVariableNames
    for ii = 1 : nHorizons
        %
        outTable{ii, hh} = getFieldFromRealTimeTable(obj.resultTable, vblNames{hh}, ...
            forecastHorizon(ii), requestedScoreMethod, realTimeTableExtractionType, ...
            'pits');
    end
end

if numel(outTable) < 1
    warning(errType, 'Requested score method %s not in result tables', ...
        requestedScoreMethod)
    return
end


%% After the extraction of the data, plot histograms of the PITs:

for hh = 1 : nVariableNames
    
    % Setup graph
    legendString    = {};
    legendToPlot    = [];

    % Find the requested series and plot them.
    count       = 0;
    for ii = 1 : nHorizons
        for jj = 1 : nModels
            count       = count + 1;

            % Select the model and forecast horizon for the data to plot,
            idxPits     = outTable{ii, hh}.modelName == modelNames(jj) & ...
                ~isnan( outTable{ii, hh}.PITs ) & ...
                outTable{ii, hh}.ForecastHorizon == num2str( forecastHorizon(ii) );

            if all( idxPits == 0)
                continue
            else
                outStats(ii, hh).GoodnessOfFit = getDensityTestGoodnessOfFit( ...
                    outTable{ii, hh}(idxPits, :).PITs, forecastHorizon(ii) );

                % Create index that loops of the max number of linestyles and markers.
                idx             = mod(count, numel(obj.plotOptions.linestyles));

                % Generate a historgram of the data with equally spaced bins between [9,
                % 1]. 
                nBins           = 10;
                binIncrement    = 1 / 10;
                firstElement    = binIncrement / 2;
                lastElement     = 1 - firstElement;

                % Return the location of the bin centre and a count of the data within
                % that bin. 
                [binCount, binCentre]   = hist( outTable{ii, hh}(idxPits, :).PITs, ...
                    [firstElement: binIncrement : lastElement]);

                % Plot this histogram.
                figure('name',vblNames{hh});
                legendToPlot(end+1)     = bar( binCentre, binCount );

                % Store the legend.
                legendString{end + 1}   = [modelNames{jj} ', Hor: ' ...
                    num2str(forecastHorizon(ii)) ];

                % Convert the date names in YYYY.NN_1 to YYYY.NN format.
                dates   = unique( outTable{ii, hh}.ForecastEvaluationPeriod );
                dates   = ifCategoricalConvertToString( dates );

                % Find and remove the trailing _1.
                dates   = regexprep( dates, '_(.)', '');

                %% Format and store the graph as requested.

                % Plot title
                if obj.plotOptions.plotTitle
                    graph_title     = sprintf(['PITs: ' modelNames{jj} ', ' vblNames{hh} ...
                        ': ' dates{1} ' - ' dates{end} ]);
                    title(graph_title, 'FontSize', obj.plotOptions.titleFontSize)
                end

                % Set x-axis to [0, 1]
                set(gca,'XLim',[0 1])

                % Turn the box off around the figure.
                set(gca, 'box', 'off');
            end

        end
    end
    
    
end



end


