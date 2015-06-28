function standardizeData(obj)
% standardizeData -
%
% Usage:
%
%   d.standardizeData
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

nObj    = numel(obj);
for j = 1 : nObj
            
    % get some preliminaries for computation and output    
    [dataPoint, dataDates, ~, ~,...
        forecastSimulations, ~] = extractNeededInformation(obj(j));    
    
    numberOfForecast    = obj(j).getNfor;
    t                    = size(dataPoint, 1);
    
    % Standardise the data by de-meaning and normalising by its standard
    % deviation.
    meand = mean(dataPoint, 1);
    stdd  = std(dataPoint,[], 1);    
    x           = ( dataPoint - meand )...
                        ./ repmat( stdd, t);
                    
    meand = mean(forecastSimulations, 1);
    stdd  = std(forecastSimulations,[], 1);                        
    xS          = (forecastSimulations - repmat(meand, [t 1]) )...
                        ./ repmat( stdd, [t 1]);

    forecastSimulations     = xS(end - numberOfForecast + 1:end,:);                    
    forecastDates           = dataDates(end - numberOfForecast + 1:end,:);                                                                          

    obj(j).ts               = TsdataForecast.setTs(dataDates, x);                
    obj(j).tsSimulations    = TsdataForecast.setTs(forecastDates, forecastSimulations);                                
                    
    % Trigger event notification for the method standardizeData. 
    notify(obj(j), 'usedMethod', TsdataEventData('standardizeData'));

end
end