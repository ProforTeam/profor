function result = evaluateModel(modelPath, modelName, period, actual, ...
    forecastDates, varNames, transf, brierScoreSettings, densityScoreSettings)
% evaluateModel -
%
% Input:
%   modelPath       [str]       
%   modelName       [str]
%   period          [str]YYYY.DD_D
%   actual          [double]
%   forecastDates   [double]YYYY.DD
%   varNames        [str]
%   transf          [double]
%
% Output:
%   result          [cell]
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

mti         = Model.loado([modelPath '/' modelName '/results/' period '/m']);

% Change the transformation fo the forecasts if transf input is different from 
% the transformation using in the mti object. 
nVariables  = numel(varNames);
for i = 1 : nVariables
    
    e                           = findobj(mti.forecast.predictionsY,...
                                                'mnemonic', varNames{i});
    if ~strcmpi(e.transfState,transf{i})
        e.dataSettings.doTransfTo   = transf{i};
        e.transformData;
    end  
    
end

% Then evaluate the forecasts
result      = forecastFns.evaluateForecast(mti, forecastDates, actual, varNames, ...
    brierScoreSettings, densityScoreSettings);


% Post a warning if something went "wrong" with evaluation of log score
if isfield( result, 'logScoreWarning')
    
    [nfor, nvary]   = size( result.logScoreWarning );
    errorstr        = '';
    for h = 1 : nfor
        for k = 1 : nvary
            if ~isempty( result.logScoreWarning{h,k} )
                cstr        = result.logScoreWarning{h, k};
                errorstr    = sprintf('%s\nThe following warning was placed model %s; period %s;horizon %d; variable %d:\n%s\n', ...
                    errorstr, modelName, period, h, k, cstr{2});
            end
        end
    end
    
    if ~isempty( errorstr )
        warning([mfilename ':logscorecomp'],errorstr)
    end
end
