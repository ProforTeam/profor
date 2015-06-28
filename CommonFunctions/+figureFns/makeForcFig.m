function handle = makeForcFig(dates, historyDates, ynames, pointForecast, ...
    history, modelPath, opt)
% makeForcFig - Plots a forecasting graph.
% 
% INPUT:
%   dates
%   historyDates
%   ynames
%   pointForecast
%   history
%   modelPath
%   opt         [Report]    Report obj that contains many plotting options.

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

errType         = ['figureFns: ', mfilename];

% Generate the save path. 
savePath    = fullfile( modelPath, ['Variable' ynames 'pointForecast']);

% Validation that a point forecast is supplied
if numel(dates) ~= numel(pointForecast)
    msg = ['The number of elements in the point forecast is ', ...
        'different than the number of elements in the forecast dates'];
    error(errType, msg)
end

% Turn off visible figures 
if opt.plotOptions.figureVisible == false
	figure('visible', 'off')
end

nfor            = size(pointForecast, 1);
T               = size(history, 1); 

% Setup data sources for the estimation ?ata, forecast data and the dates of the
% two series toegether.
estimationData  = [history(:); nan(nfor, 1)];
forecastData    = [nan(T - 1, 1); history(end); pointForecast(:)];
dates           = [historyDates; dates];

handle          = figure();
% Plot the estimation and historical data on the same graph. 
handle          = plot( forecastData,     'r', 'linewidth', opt.plotOptions.lineWidth);
hold on
handle          = plot( estimationData,   'b', 'linewidth', opt.plotOptions.lineWidth);

% Plot title
if ~isempty(ynames) && ~isempty( opt.defaultProperties.modelNames{1} )
    % Extract the title using the model names and variable name.
    titleName = [ynames, ' : ', ...
        strjoin([opt.defaultProperties.modelNames], ', ')];    
    title(titleName, 'interpreter', 'none', 'fontsize', opt.plotOptions.titleFontSize);
end


% Format the graph and set the x-axis with the dates.
legend(ynames)
legend('boxoff')
[~, ~]  = setXtickAndLabel(dates, 'handle', gca);
set(gca, 'fontsize', opt.plotOptions.fontSize);
set(gca, 'box', 'off');

% Save if requested
if opt.plotOptions.saveFigures == true
	saveEconToolboxFigures(savePath, obj);
    close
end

end