function plotDensityForecast(obj, vblNames, maxHistoryPeriods)
% plotPointForecast - Plots the forecast density.
%
% Input:
%   obj                 [Report]
%   vblNames   [cell](1xn)     Containing variable mnemonics to plot.
%   maxHistoryPeriods   [int]               e.g. 1.
%
% USAGE: plotDensityForecast(obj, vblNames)
%   e.g. reportObj.plotDensityForecast( {'gdp', 'cpi'})
%
% Can also be used with not input argument (program uses Report defaults),
% i.e: 
%           reportObj.plotDensityForecast
%
%
% Also, see usage in the reporting <a href="matlab: opentoline(./help/helpFiles/htmlexamples/makingReportsExample.m,1)">example file</a>
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

if ~isempty(obj.proforObj)
    
    disp([mfilename ': You can not use the plotDensityForecast method for a Report of Profor class'])
    return
else

    % inputNamesNeeded is used in the script argumentPassingScript
    inputNamesNeeded    = {'vblNames', 'maxHistoryPeriods'};               
    numberOfInputArgs   = nargin;
    
    argumentPassingScript(obj, inputNamesNeeded, numberOfInputArgs); 

end

% Warning / Error identifiers.
warnType = ['Report:', mfilename];

% If vblNames entered as a string convert to a cell.
if ischar(vblNames)
    vblNames = {vblNames};
end

nPlotVariables  = numel(vblNames);

% Find the requested series and plot them.
for ii = 1 : nPlotVariables
    
    % Extract the Tsdataforecast object for the requested variable.
    plotObj   = findobj( obj.modelProperties.forecast.predictionsY, ...
        'mnemonic', vblNames{ii}...
        );
    
    % Plot the graphs if you find them
    if numel(plotObj) > 0
        % Extract required properties from the Report object.
        
        % The forecast and estimation dates, and the variable names.
        forecastDates       = plotObj.getForecastDates;
        historyDates        = plotObj.getHistoryDates;
        yname               = plotObj.mnemonic;
        simulationSmpl      = plotObj.getForecastSimulations;
        pointForecast       = plotObj.getForecast;
        history             = plotObj.getHistory;
        modelPath           = obj.savePath;
        
        
        % Get the number of periods for the historical data.
        nPeriodsHistory     = numel(historyDates);
        
        % If the the max length for the historical data / dates is empty set it to a
        % default, or the max length if shorter.            
        maxHistoryPeriodsii = min(maxHistoryPeriods, nPeriodsHistory);
        
        % If the history is shorter than the number requested, truncate to the
        % maximum number of historical periods possible.
        if nPeriodsHistory < maxHistoryPeriods
            maxHistoryPeriods = nPeriodsHistory;
        end
        
        % Find the start index according to this truncation of history.
        idx     = nPeriodsHistory - maxHistoryPeriodsii + 1;
        
        % Truncate the historical data and dates accordingly.
        historyDates        = historyDates(idx : end, 1);
        history             = history(idx : end, 1);
        
        % Call the plot density forecast fn
        figureFns.makeForcFigD(forecastDates, historyDates, yname, simulationSmpl, ...
            pointForecast, history, modelPath, obj);
        
    else
        warning(warnType, 'The series "%s" not recogonised, try one from the available list "%s".', ...
            vblNames{ii}, strjoin( obj.allowableProperties.vblNames, ', '))
        
    end
end

end


