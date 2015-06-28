function handle = makeForcFigD(dates, historyDates, ynames, simulationSmpl, ...
    forecast, history, modelPath, opt)
% makeForcFigD - 
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

% Generate the save path.
savePath    = fullfile( modelPath, ['Variable' ynames 'Forecast']);

% Turn off visible figures
if opt.plotOptions.figureVisible == false
    figure('visible', 'off')
end

simulationSmpl    = squeeze( simulationSmpl );

if size(simulationSmpl, 2) ~= numel( forecast )
    simulationSmpl    = simulationSmpl';
end

handle = figureFns.fanChartFigure( ...
    simulationSmpl,  dates, opt, ...
    'historyAndDates',      [historyDates(:) history(:)], ...
    'forecast',             forecast(:), ...
    'figure',               false, ...
    'savePath',             savePath, ...
    'quantiles',            opt.plotOptions.quantiles, ...
    'color',                opt.plotOptions.densityColor.x{:}, ...
    'titleFontSize',        opt.plotOptions.titleFontSize, ...
    'ynames',               ynames, ...
    'titleNames',            opt.defaultProperties.modelNames...
    );


end