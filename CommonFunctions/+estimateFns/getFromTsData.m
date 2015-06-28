function [y, yInfo, ydates, x, xInfo] = getFromTsData(obj, data)
% getFromTsData     Extracts information from Tsdata object 
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

if ~obj.dataSettings.default
    % Transform data on the go based on the settings in dataSettings
    E       = prepareData(data, obj.dataSettings, obj.namesY.x);
    
    %% Adjust data all at once.
    E.sesAdjData;
    E.convertData;
    
    % save data to temp folder for this model run. To be used when we need level 
    % information when constructing the forecasting objects
    save(fullfile(proforStartup.pfRoot,'temp',obj.links.tag,'historyDataForForecasting.mat'), 'E', '-v7.3');
    
    % Apply extra transformation to the data
    E.transformData;
    E.trendAdjData;
    
end
% This should also be done for namesX variables, but have not implemented this 
% yet

variableIdx         = 'namesY';
[y, yInfo, ydates]  = estimateFns.getVariableMatrix(obj, data, variableIdx);

if nargout > 3
    variableIdx         = 'namesX';
    [x, xInfo]          = estimateFns.getVariableMatrix(obj, data, variableIdx);
end

end
