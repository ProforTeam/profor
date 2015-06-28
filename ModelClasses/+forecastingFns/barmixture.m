function [predictionsA, predictionsY] = barmixture(estimation, dataLevel)
% barmixture	Forecast Bayesian AR mixture models
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

en          = min(estimation.yInfo.maxPanel);            

% Extract from object to make less overhead when doing parfor
[Tt, nvary] = size(estimation.y);
y           = estimation.y;
nfor        = (Tt - en);

if nfor == 0 
    predictionsA = [];
    predictionsY = [];        
else

    nlag        = estimation.nlag;
    draws       = estimation.simulationSettings.nsave;

    T           = estimation.T;
    C           = estimation.C;    
    
    qdraw = estimation.modelSpecificOutput.QS;   % m x d
    adraw = estimation.modelSpecificOutput.aS;   % m x d
    pdraw = estimation.modelSpecificOutput.pS;   % m x d    
    edraw = estimation.modelSpecificOutput.eS;   % nobs x m x d      
    
    mixtureNormalOnly = estimation.mixtureNormalOnly;     
    trailingZeros     = zeros(nlag - 1, 1);    
    nComponents       = size(qdraw, 1);
    
    % get the state vector at time t, i.e., the conditioning information
    a0tmp       = latMlag(y, nlag);
    a0          = [y(end-nfor);
                    a0tmp(end-nfor,:)'];    

    aForecast   = nan(nvary, nfor, draws);
    for d = 1 : draws
                        
        aForecasth = a0;
        bdraw      = [C(d,1) T(d,1)];                
           
        for h = 1 : nfor

            % For the first horizon, just sample from the last
            % observation of edraw from the porterior. For h > 1, draw
            % a new edraw based on the posterior estimates
            if h == 1
                edrawd = edraw(end, :, d);
            else
                if ~mixtureNormalOnly                                
                    edrawd = drawE(nComponents, 1, aForecasth(1), [1 aForecasth(2:end)'], bdraw(1, :)', adraw(:, d), qdraw(:, d), pdraw(:, d));    
                else
                    % This will tilt the forecasts towards the latest edraw
                    %edrawd = drawE(nComponents, 1, aForecasth(1), [], bdraw(1, :)', adraw(:, d), qdraw(:, d), pdraw(:, d));    
                    % This will not
                    edrawd = drawE(nComponents, 1, a0(1), [], bdraw(1, :)', adraw(:, d), qdraw(:, d), pdraw(:, d));    
                    % .. not sure what is correct here, but quess the
                    % latter? 
                    
                    % Alternatively we can just draw from edraw, like for 
                    % h == 1, but then we do not use the conditional
                    % information, i.e., that we stand in period T and want
                    % to forecast going forward, right? 
                end
            end

            % Find the index of the component the error draw is from
            eidx    = find(edrawd == 1);                
            % sample a forecast error
            edrawf  = adraw(eidx, d) + sqrt(qdraw(eidx, d))*randn(1, 1);

            % make a forecast. Note, here we use the companion form.
            % Why? Such that we can use aForecasth recusively above
            % when simulating edrawd
            aForecasth = [bdraw(:, 1)  + bdraw(:, 2 : end)*aForecasth(1 : nlag) + [edrawf;trailingZeros];
                         aForecasth(nlag)];      
            % we add the last element here so that we can use it when
            % updating edraw above
                     
            % save it to the output variable
            aForecast(1, h, d) = aForecasth(1);                                                                                

        end    
                          
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edraw = drawE(nComponents, n, y, x, bdraw, adraw, qdraw, pdraw)

if isempty(x)
   x = zeros(n, numel(bdraw, 1)); 
end

edraw = zeros(n, nComponents);
for i = 1 : n
    
    pterm = zeros(nComponents, 1);
    for j = 1 : nComponents
        pterm(j, 1) = norm_pdf(y(i, 1), adraw(j, 1) + x(i, :)*bdraw, qdraw(j, 1));
        pterm(j, 1) = pdraw(j, 1)*pterm(j, 1);
    end

    probs       = pterm./sum(pterm);
    multiterm   = multi_rnd(probs);
    edraw(i, :) = multiterm';
    
end
