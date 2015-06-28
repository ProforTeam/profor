function plotWeightsOrScores(obj, dataType, modelNames, forecastHorizon)
% plotWeightsOrScores - Plots either the weights or scores over evaluation
%                       periods.
%   Not finished, but should take arbitrary dataType, modelNames and forecast
%   horizon and plot and label graph accordingly by generating a table for the
%   given data type, currently only weights and scores.
%
% Input:
%   obj                 [Report]
%   dataType            [cell](1xn)[str]     Data type to plot.
%   modelNames          [cell](1xn)[str]     Strings for the models to include.
%   forecastHorizon     [numeric](1xn)       Forecast horizons to plot.
%
% USAGE: plotWeightsOrScores(obj, dataType, modelNames, forecastHorizon)
%   e.g. plotWeightsOrScores({'weights'}, {'M1', 'M2'}, [1])
%
% Can also be used with not input argument (program uses Report defaults),
% i.e: 
%           reportObj.plotWeightsOrScores
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

if ~isempty(obj.proforObj)
    
    disp([mfilename ': You can not use the plotWeightsOrScores method for a Report of Profor class'])
    return
else

    % Warning / Error identifiers.
    errType = ['Report:', mfilename];

    estimationClassType = class(obj.modelProperties.estimation);
    if ~isa(obj.modelProperties.estimation, 'Estimationcombination')
        msg         = ['Model must be a combination type in order for weights or',...
            ' scores to exist. The current estimation type is %s. 12'];   
        error(errType, msg, estimationClassType)
    end    
    
    
    % inputNamesNeeded is used in the script argumentPassingScript
    inputNamesNeeded    = {'dataType', 'modelNames', 'forecastHorizon'};               
    numberOfInputArgs   = nargin;
    
    argumentPassingScript(obj, inputNamesNeeded, numberOfInputArgs); 

end

% Allow for cell input for dataType.
if iscell(dataType)
    dataType    = dataType{1};
end
if ischar(modelNames)
    modelNames = {modelNames};
end;

%% Generate table for given dataType:

inTable     = obj.createWeightAndScoreTable(dataType);


%% Plot graphs.

nModels         = numel(modelNames);
nHorizons       = numel(forecastHorizon);

% Setup graph
handle          = figure();
hold on;
legendString    = {};
legendToPlot    = [];

% Find the requested series and plot them.
count       = 0;
for ii = 1 : nHorizons
    for jj = 1 : nModels
        count       = count + 1;
        % Find the appropriate data from the table.
        plotDataIdx     = inTable.forecastHorizon == num2str(forecastHorizon(ii))...
            & inTable.modelName == modelNames{jj};
        
        % Get the data with the index
        plotData        = inTable(plotDataIdx, :);
        
        % Create index that loops of the max number of linestyles and markers.
        idx             = mod(count, numel(obj.plotOptions.linestyles));
        
        % Plot the data.
        legendToPlot(end+1)     = plot(plotData.Data, [obj.plotOptions.linestyles{idx} obj.plotOptions.markers(idx)]);
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

% Plot title
if obj.plotOptions.plotTitle    
    vintageStr      = cellstr(unique(plotData.Vintage));
    graph_title     = sprintf(['Vintage: ' vintageStr{:} ', ' dataType]);    
    title(graph_title, 'FontSize', obj.plotOptions.titleFontSize)
end

% Set axis.
[~, ~]      = setXtickAndLabel(plotData.evaluationDate, 'handle', gca);
% set(gca, 'fontsize', opt.fontSize);
set(gca, 'box', 'off');

end


