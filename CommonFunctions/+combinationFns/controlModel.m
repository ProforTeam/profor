function controlModel(modelPath, modelName, period, forecastDates, varNames, ...
    freq, nfor, transf, draws, scoringMethod)
% controlModel - 
%
% Note: The models are just loaded and checked. We do not store them in
% working memory because this will take up alot of space.
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

errorStr = [];

try
    mti = Model.loado([modelPath '/' modelName '/results/' period '/m']);
    isFound     = true;
    
catch Me
    errorStr    = sprintf('%s\n%s',errorStr,Me.message);
    isFound     = false;
end

if isFound
    if nfor > 1 && mti.estimation.nfor == 0
        str         =sprintf(['Number of nfor is 0 in model: %s, your batch settings for nfor are larger than 0.\n',...
            'You can not do forecast evaluation etc.'], modelName);
        errorStr    = sprintf('%s\n%s', errorStr, str);
    end
    
    if draws > 1 && mti.estimation.simulationSettings.nsave == 1
        str         = sprintf(['Number of draws are 1 in model: %s, your batch settings for draws are larger than 1.\n',...
            'You can not do density evaluation etc.'], modelName);
        errorStr    = sprintf('%s\n%s', errorStr, str);
    end
    
    if mti.estimation.simulationSettings.nsave == 1 && any(strcmpi(scoringMethod,{'logScore','crpsD','logScoreD','mvnLogScore'}))
        str         = sprintf(['Number of draws in model: %s, is 1, and you want to do density evaluation.\n',...
            'You can not do density evaluation etc.'], modelName);
        errorStr    = sprintf('%s\n%s', errorStr, str);
    end
    
    if strcmpi(scoringMethod,'mvnLogScore') && any(strcmpi(mti.method,{'favar','bdfm'}))
        str         = sprintf('The model: %s, is a FAVAR or DBFM. You are using mvnLogScore as a scoringMethod. This does not work', modelName);
        errorStr    = sprintf('%s\n%s', errorStr, str);
    end
    
    for i = 1:numel(varNames)
        % check varName
        e = findobj(mti.forecast.predictionsY,'mnemonic',varNames{i});
        if isempty(e)
            str         = sprintf('All varNames could no be found in model: %s', modelName);
            errorStr    = sprintf('%s\n%s', errorStr, str);
        end
        
        % check frequency
        if ~strcmpi(e.freq, freq)
            str         = sprintf('freq in model: %s, does not match freq in in your batch setting', modelName);
            errorStr    = sprintf('%s\n%s', errorStr, str);
        end
        
        % check dates
        dates = intersect(e.getForecastDates, forecastDates);
        if ~all(ismember(dates, forecastDates))
            str         = sprintf('forecastDates in model: %s, does not match forecastDates', modelName);
            errorStr    = sprintf('%s\n%s', errorStr, str);
        end
        
        % Check that transformation is equal to the transformation used on
        % actual (should make the program able to change the transformation of
        % the forecasts..., and possibly also the frequency)
        if ~strcmpi(e.transfState,transf{i})
            % If history level is emty we can not change the transformation
            % of the forecast and have to produce an error (historyLevel should not be empty)
            if isempty(e.getHistoryLevel)
                str         = sprintf('transformation of forecast in model: %s, does not correspond to transformation used in actual and no historyLevel set in forecast object', modelName);
                errorStr    = sprintf('%s\n%s', errorStr, str);
            end
        end
        
    end
end

if ~isempty(errorStr)
    error([mfilename ':errors'],'Program found the following errors in model: %s, time period: %s\n%s', modelName, period, errorStr)
end
