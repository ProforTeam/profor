function handle = plotLine2dMatrix(dates, y, ynames, path, opt)
% makeForcFig   -    Plots a forecasting graph.
%
% INPUT:
%   dates
%   y           [numeric] (NxMxP)         Data containing series to be plotted.
%   ynames
%   path
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

errType         = 'plotLine2dMatrix:';

% Validation that a data (y) is of the same dimension as the dates.
if numel(dates) ~= size(y, 1)    
    msg = ['The number of elements in the data is ', ...
        'different than the number of elements in the dates'];
    error(errType, msg)
end

% Turn off visible figures
if opt.plotOptions.figureVisible == false
    figure('visible', 'off')
end

handle          = figure();
% Plot the estimation and historical data on the same graph.
handle          = plot( y(:, 1, 2),     'r', 'linewidth', opt.lineWidth);
hold on
handle          = plot( y(:, 2, 2),   'b', 'linewidth', opt.lineWidth);

% Format the graph and set the x-axis with the dates.
legend(ynames)
legend('boxoff')
[~, ~]  = setXtickAndLabel(dates, 'handle', gca);
set(gca, 'fontsize', opt.fontSize);
set(gca, 'box', 'off');

% Save if requested
if opt.plotOptions.saveFigures == true
    saveEconToolboxFigures([path '\Variable'  ynames 'pointForecast'],obj);
    close
end

end