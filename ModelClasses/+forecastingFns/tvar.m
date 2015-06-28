function [predictionsA, predictionsY] = tvar(estimation, dataLevel)
% tvar	- Forecast TVAR(p) model
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

st                  = max( estimation.yInfo.minPanel );
en                  = min( estimation.yInfo.maxPanel );            
y                   = estimation.y(st : en, :);
nfor                = estimation.nfor;
nvary               = size(y,2);

if nfor == 0 
    predictionsA = [];
    predictionsY = [];    
else
    nlag                    = estimation.nlag;
    draws                   = estimation.simulationSettings.nsave;
    bootStrapMethod         = estimation.simulationSettings.bootStrapMethod.x{:};
    thresholdVariableIndex  = estimation.thresholdVariableIndex;
    
    cOpt                    = estimation.modelSpecificOutput.thresholdValue;
    decayOpt                = estimation.modelSpecificOutput.optimalDecay;
    result                  = estimation.modelSpecificOutput.result;
    sd                      = estimation.modelSpecificOutput.sd;
    
    idx         = sd <= cOpt;   
    T           = estimation.T.simulation(:,:,idx,:);
    T1          = T(:,:,end,:);
    T           = estimation.T.simulation(:,:,idx == 0,:);
    T2          = T(:,:,end,:);
    T           = cat(3,T1,T2);
    
    C           = estimation.C.simulation(:,:,idx,:);
    C1          = C(:,:,end,:);
    C           = estimation.C.simulation(:,:,idx == 0,:);
    C2          = C(:,:,end,:);
    C           = cat(3,C1,C2);
         
    aForecast   = nan(nvary, nfor, draws);
    for d = 1 : draws
        
        aForecast(:,:, d) = varUtilitiesFns.tvarForecast(y, nlag, nfor,...
                                        C(:,:,:,d), T(:,:,:,d),...
                                        thresholdVariableIndex,...
                                        decayOpt,...
                                        cOpt,...
                                        result,...
                                        'bootStrapMethod', bootStrapMethod);
                                    
    end    
        
    % Put into time series object for forecasts               
    [~, ~, forecastSample]  = adjSample( estimation.estimationSample,  ...
                                        estimation.freq, 'nfor', nfor);                                                                       

    % Indicator of whether to store the forecast or not.
    if nargin == 2
        isStoreDataLevel = true;    
    else
        isStoreDataLevel = false;
        dataLevel        = [];
    end;
    % Return the forecast predictions and history if provided.
    [predictionsA, predictionsY] = ...
        forecastFns.storeForecastAndHistoryNotCombination(aForecast, forecastSample, ...
        dataLevel, estimation, isStoreDataLevel);                                
end
end
