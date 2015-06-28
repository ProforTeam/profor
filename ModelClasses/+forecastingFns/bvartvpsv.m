function [predictionsA, predictionsY] = bvartvpsv(estimation, dataLevel)
% bvartvpsv - Forecast Bvartvpsv model. Like bvar and var, the observed data
% can have ragged edge. Function also forecasts the tvp and sv part of the
% model, and condition the foreasts on the future paths of these. 
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
    nstates     = nlag*nvary;

    Z           = estimation.Z;
    D           = estimation.D;
    H           = estimation.H;
    T           = estimation.T;
    C           = estimation.C;
    R           = estimation.R;
    Q           = estimation.Q;

    S           = estimation.S;
    B           = estimation.B;
    G           = estimation.G;


    a0tmp       = latMlag(y, nlag);
    a0          = a0tmp(end-nfor,:)';
    p0          = zeros(estimation.nlag*nvary);

    aForecast   = nan(nvary, nfor, draws);
    for d = 1 : draws

        % 1) Forecast T and C forward (T and C follow RW, with error cov.mat G)
        tmp         = cat(2,C(d,C.t),T(d,C.t));
        tmp         = tmp(1:nvary,:);    
        Tt          = vec(tmp');
        Gt          = G(d,G.t); % Not time varying                   
        % TtF: numParameters x (nfor + 1)
        TtF_tmp     = RWForecast(Tt,Gt,nfor);
        % Adjust size to get needed KF input
        TtF         = nan(nstates, nvary*nlag, nfor + 1);
        CtF         = nan(nstates, 1, nfor + 1);
        for f = 1:(nfor + 1)
            tmp                         = reshape(TtF_tmp(:,f),[nvary*nlag+1 nvary])';
            [TtF(:,:,f), CtF(:,:,f)]    = varUtilitiesFns.varGetCompForm(...
                                            tmp(:,2:end,:), tmp(:,1,:), nlag, nvary);
        end;

        % 2) Forecast Sigma and A0 forward and construct Q forecasts
        [Sigmat,A0t] = resamplingFns.getSigmaAndA0( Q(d,Q.t) );     
        % 2.1) Forecast Sigma 
        Bt          = B(d,B.t); % Not time varying                   
        % Transform: Sigmat = exp(0.5.*SigmaSim), where SigmaSim is the process
        % that follows RW and to which Bt is associated        
        % SigmatF: nvary x (nfor + 1)
        SigmatF     = exp( 0.5.* RWForecast(2*log(diag(Sigmat)),Bt,nfor));                
        % 2.2) Forecast A0 forward 
        St          = S(d,S.t); % Not time varying                   
        A0tF        = repmat(eye(nvary),[1 1 (nfor + 1)]);
        for i = 2:nvary
            % A0tF: nvary x nvary x nfor+1
            A0tF(i,1:i-1,:)   = RWForecast(A0t(i,1:i-1)',St(1:i-1,1:i-1),nfor);        
        end;    
        % 2.3) Construct forecasts of Q    
        QtF         = zeros(nvary,nvary, nfor + 1);
        for f = 1: (nfor + 1)                
            A0invSigma  = A0tF(:,:,f)\diag(SigmatF(:,f));
            QtF(:,:,f)  = A0invSigma*A0invSigma';        
        end;        

        % 3) Construct forecasts of y
        % Note: Conditioning on the same a0 every draw 
        ZtF = repmat(Z(d,Z.t),[1 1 (nfor + 1)]);
        DtF = repmat(D(d,D.t),[1 1 (nfor + 1)]);
        HtF = repmat(H(d,H.t),[1 1 (nfor + 1)]);
        RtF = repmat(R(d,R.t),[1 1 (nfor + 1)]);

        aForecast(:, :, d)  = kalmanFilterForecast( y', ZtF, DtF, HtF, ...
                                TtF, CtF,...
                                RtF, QtF,...
                                a0, p0,...
                                nfor);        
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function yForecast = kalmanFilterForecast(y, Z, D, H, T, C, R, Q, a0, p0, nfor)
% kalmanFilterForecast  Use Acov from KF to make conditional forecasts
%   i.e., no shock uncertainty added to pbserved values - only to unobserved 
%   states. Note, y and A are the same, unless missing values in y.


nvara       = size(y,1);
[A, Acov]   = kalmanFilterFns.KalmanFilterOrigFastTVP( ...
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function yForecast = RWForecast(y,Q,nfor)

nvary           = size(y,1);
% Note that the fist forecast is an observable. Need this for the KF
% routine for y forecasts later (ragged edge thing)
yForecast       = nan(nvary, nfor + 1);
yForecast(:,1)  = y;

futureShocks    = chol(Q)'*randn(nvary, nfor);

for f = 2:nfor+1    
    yForecast(:,f) = yForecast(:,f - 1) + futureShocks(:,f-1);    
end;


end