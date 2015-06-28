function [predictionsA, predictionsY] = storeForecastAndHistoryNotCombination(forcs, ...
    forecastSample, dataLevel, estimation, isStoreDataLevel)
% storeForecastAndHistory - Stores forecast as Tsdataforecast object along with
%                           history if requested.
%
% Input:
%   forcs               [numeric]       Forecasts (nForcHorizon, nVbls, draws).
%   forecastSample      [numeric]       (YYYY.NN - YYYY.NN)
%   dataLevel           [Tsdata]
%   estimation          [Estimation Class]
%   isStoreDataLevel    [logical]
%
% Output:
%   predictionsA        [Tsdataforecast]
%   predictionsY        [Tsdataforecast]
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nvary   = estimation.namesY.numc;

predictionsA            = [];
for i = 1 : nvary
    forecast            = permute(forcs(i,:,:), [2 3 1]);
    
    % note: using the median here
    forecast0           = median(forecast, 2);

    [st, en]                = mapDatesAndSample(estimation.estimationSample, ...
        estimation.dates, estimation.freq);
    history                 = estimation.y(st:en,i);    
    historySample           = estimation.estimationSample;
        
    historyLevel            = [];
    if isStoreDataLevel
        % Add level information to the Tsdataforecast objects
        % add the history to make the forecast transformable to other
        % transformations
        e = findobj(dataLevel, 'mnemonic', estimation.namesY.x{i});
        
        % Check if e is non empty and then check that e has the correct
        % frequency and transformation
        if ~ isempty(e)                        
            [historyLevel, ~, ~, ~] = selectData(e, {e.mnemonic}, ...
                e.freq, estimation.estimationSample);                        
        end
    end
    
    freq = estimation.yInfo.freq{i};
    
    fd                  = TsdataForecast(estimation.namesY.x{i},...
            forecast0, forecast, sample2ttt(forecastSample,freq),...
            estimation.yInfo.transf{i}, history, sample2ttt(historySample,freq), ...
            freq, historyLevel);            
    
    predictionsA        = cat(2, predictionsA, fd);
    
end

predictionsY            = predictionsA;

end