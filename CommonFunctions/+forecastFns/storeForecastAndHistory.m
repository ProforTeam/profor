function [predictionsA, predictionsY] = storeForecastAndHistory(forcs, dates, ...
    forecastSample, dataLevel, estimation, isStoreDataLevel)
% storeForecastAndHistory   Stores forecast as Tsdataforecast object along with
%                           history if requested.
%
% Input:
%   forcs               [numeric]       Forecasts (nForcHorizon, nVbls, draws).
%   dates               [numeric]       YYYY.NN (nForcHorizon, 1)
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
    forecast    = permute(forcs(:,i,:), [1 3 2]);
    
    % note: using the median here
    forecast0       = median(forecast, 2);
    
    history         = [];
    historyLevel    = [];
    historySample   = [];
    
    realisedForecastSample  = getSample(dates(:, i));    
    freq                    = estimation.yInfo.freq{i};
    
    % A test to check that the realised combination dates match the requested
    % forecast sample.
    % Can only include history if forecasts for models starts at forecast
    % horizon 1, which is the same horizon as in combination (see above)
    if strcmpi( realisedForecastSample( isspace(realisedForecastSample) == 0), ...
            forecastSample(  isspace(forecastSample)  == 0))
        
        [st, en]                = mapDatesAndSample(estimation.estimationSample, ...
            estimation.dates, estimation.freq);
        history                 = estimation.y(st:en,i);    
        historySample           = estimation.estimationSample;

        historyLevel            = [];                                
        
        if isStoreDataLevel
            % Add level information to the Tsdataforecast objects add the
            % history to make the forecast transformable to other transformations
            e = findobj(dataLevel, 'mnemonic', estimation.namesY.x{i});
            
            % Check if e is non empty and then check that e has the correct
            % frequency and transformation
            if ~isempty(e)
                
                [historyLevel, ~, ~, ~] = selectData(e, {e.mnemonic}, e.freq, ...
                    estimation.estimationSample);
                                
            end
        end

        fd = TsdataForecast(estimation.namesY.x{i},...
            forecast0, forecast, sample2ttt(realisedForecastSample,freq),...
            estimation.yInfo.transf{i}, history, sample2ttt(historySample,freq), ...
            freq, historyLevel);                                    
        
    else        
        
        % Should fix this to either: 
        % 1) TsdataForecast supporting no history input
        % 2) Add nans to the history, and update TsdataForecast to handle
        % this
        %error([mfilename ':sampleMatch'],'The forecast sample in combination does not match the one in the individual model')
        
        % IMPORTANT: By saving like this we will loose the option of
        % transforming the forecasts etc. at a later stage - NO history is
        % present. Consider changing such that the combination object
        % accepts nowcasts etc. See issues!
        fd = TsdataForecast(estimation.namesY.x{i},...
            forecast0, forecast, sample2ttt(realisedForecastSample,freq),...
            estimation.yInfo.transf{i}, [], [], ...
            freq, []);                                            
        
    end

    predictionsA    = cat(2, predictionsA, fd);
    
end

predictionsY = predictionsA;

end