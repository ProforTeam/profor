function convertData(obj)
% converData    - Converts data frequency (only high to low freq).
%
% See also DATASETTING, TSDATA.CONVERTDATA
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

nObj = numel(obj);
for j = 1 : nObj
    
    % If fromFreq and toFreq are equal, or no
    % conversion specified  jump out of program 
    if strcmpi(obj(j).freq, obj(j).dataSettings.doConversionTo) || strcmpi(obj(j).dataSettings.doConversionTo,'n')
        continue
    end
    
    % get some preliminaries for computation and output    
    [dataPoint, dataDates, dataHistoryLevel, dataHistoryDates,...
        forecastSimulations, forecastStartIdx] = extractNeededInformation(obj(j));
        
    toFreq      = obj(j).dataSettings.doConversionTo;
    fromFreq    = obj(j).freq;
    
    % Convert point forecast
    [convertedDates, convertedData] = conversionFnc(dataDates, dataPoint,...
                                    fromFreq, toFreq,...
                                    obj(j).dataSettings.conversionMethod.x{:});
                                            
    % Convert simulations
    [~, convertedSimulations]    = conversionFnc(dataDates, forecastSimulations,...
                                    fromFreq, toFreq,...
                                    obj(j).dataSettings.conversionMethod.x{:});                                
    
    % Convert historyLevel and get forecastDates and new number of
    % forecasts
    if obj(j).isHistoryLevel
        [historyDates, convertedHistoryLevel]   = conversionFnc(dataHistoryDates,...
                                        dataHistoryLevel,...
                                        fromFreq, toFreq,...
                                        obj(j).dataSettings.conversionMethod.x{:});                                                                                                                                                          
    end;
    
    %% Create ts map object with new stuff
    
    forecastDates           = convertDatesFreq(dataDates(forecastStartIdx : end), fromFreq, toFreq);                                        
    numberOfForecast        = size(forecastDates, 1);                        
                                                               
    % Extract correct information
    forecastSimulations     = convertedSimulations(end - numberOfForecast + 1:end,:);                    
                                            
    % Update some fields: dates must be done first!!!
    obj(j).freq             = toFreq;        
    obj(j).forecastStartIdx = size(convertedData, 1) -  numberOfForecast + 1;   
    
    obj(j).ts               = TsdataForecast.setTs(convertedDates, convertedData);                    
    obj(j).tsSimulations    = TsdataForecast.setTs(forecastDates, forecastSimulations);                                
    
    if obj(j).isHistoryLevel
        obj(j).tsHistoryLevel   = TsdataForecast.setTs(historyDates, convertedHistoryLevel);                            
    end;
        
    % Notify change
    notify(obj(j), 'usedMethod', TsdataEventData('convertData'));        
    
end

end