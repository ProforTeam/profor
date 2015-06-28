function obj = forecast(obj, modelObj)
% forecast
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

obj.forecastingState = false;
    
tStart              = tic;
estimation          = modelObj.estimation;

% 0) Get directly from input
obj.dataSettings    = estimation.dataSettings;
obj.method          = estimation.method;
func                = str2func(['@forecastingFns.' obj.method]);

% load level informtation data if saved earlier. That is, if
% ~batch.dataSettings.default
if ~obj.dataSettings.default
    dataLevel       = load(fullfile(proforStartup.pfRoot,'temp',estimation.links.tag,'historyDataForForecasting.mat'), 'E');
    % 1) Forecast model    
    [obj.predictionsA, obj.predictionsY] ...
        = func(estimation, dataLevel.E);        
else
    % 1) Forecast model
    [obj.predictionsA, obj.predictionsY] = func(estimation);
end

% Done
obj.tElapsed            = toc(tStart);

obj.forecastingState    = true;

end
