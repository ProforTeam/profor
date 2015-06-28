function [dataPoint, dataDates, dataHistoryLevel, dataHistoryDates,...
    forecastSimulations, forecastStartIdx] = extractNeededInformation(obj)
% extractNeededInformation -
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

dataPoint           = obj.getData;    
dataDates           = obj.getDates;    
dataHistoryLevel    = obj.getHistoryLevel;
dataHistoryDates    = obj.getHistoryDates;
forecastSimulations = obj.getForecastSimulations;
forecastStartIdx    = obj.forecastStartIdx;
draws               = obj.getDraws;
                        
forecastSimulations = [repmat(dataPoint(1 : forecastStartIdx-1,1), [1 draws]);forecastSimulations];