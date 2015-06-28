function [predictionsA, predictionsY] = var(estimation, dataLevel)
% var	Forecast VAR(p) model
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

    Z           = estimation.Z;
    D           = estimation.D;
    H           = estimation.H;
    T           = estimation.T;
    C           = estimation.C;
    R           = estimation.R;
    Q           = estimation.Q;

    a0tmp       = latMlag(y, nlag);
    a0          = a0tmp(end-nfor,:)';
    p0          = zeros(estimation.nlag*nvary);

    aForecast   = nan(nvary, nfor, draws);
    for d = 1 : draws
        % Note: Conditioning on the same a0 every draw 
        aForecast(:, :, d)  = kalmanFilterForecast( y', Z(d,1), D(d,1), H(d,1), ...
                                T(d,1), C(d,1), R(d,1), Q(d,1), a0, p0, nfor);        
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

function yForecast = kalmanFilterForecast(y, Z, D, H, T, C, R, Q, a0, p0, nfor)
% kalmanFilterForecast  Use Acov from KF to make conditional forecasts
%   i.e., no shock uncertainty added to pbserved values - only to unobserved 
%   states. Note, y and A are the same, unless missing values in y.


nvara       = size(y,1);
[A, Acov]   = kalmanFilterFns.KalmanFilterOrigFastNTV( ...
                            y(:,end-nfor:end), Z, D, H, T, C, R, Q, a0, p0);

yForecast   = nan(nvara, nfor);
ee          = eye( nvara );

for f = 1 : nfor        
    % Forecast state
    unbalidx    = isnan(y(:,end-nfor+f));    
    
    if all(unbalidx==0)
        futureShocks    = zeros(nvara,1);
        eef             = ee;
        
    else
        eef             = ee(:,unbalidx>0);
        if isempty( eef )
            eef         = ee;
        end
        futureShocks    = chol( eef' * Acov(1:nvara, 1:nvara, f+1) * eef, ...
            'lower') * randn(size(eef, 2), 1);
    end
    yForecast(:, f)     = A(1 : nvara, 1, f + 1) + eef * futureShocks;                                
end
end