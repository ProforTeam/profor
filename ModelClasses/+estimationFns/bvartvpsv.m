function res = bvartvpsv(obj)
% PURPOSE: Estimate and simulate BVAR(p) model with time varying paramters
% and stochastic volatilty
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

% Prelim
st              = max(obj.yInfo.minPanel);
en              = min(obj.yInfo.maxPanel);            

nlag            = obj.nlag;
nobs            = (en - (st + nlag) + 1);

y               = obj.y(st:en,:);
yl              = latMlag(y,nlag);
nvary           = size(y,2);
nstates         = nlag*nvary;

% Hard coded for now
constant        = true;
Tres            = ones(nvary,nvary*nlag+1);

% For the Gibbs
nsave           = obj.simulationSettings.nsave;                
ntot            = obj.simulationSettings.ntot;                
nburn           = obj.simulationSettings.nburn;                                                               
nstep           = obj.simulationSettings.nstep;
showProgress    = obj.simulationSettings.showProgress;

% Get priors
T0_mean         = obj.priorSettings.tg.a0;
T0_cov          = obj.priorSettings.tg.p0;
vprior_g        = obj.priorSettings.tg.v;
Sprior_g        = obj.priorSettings.tg.S;

A00_mean        = obj.priorSettings.a0s.a0;    
A00_cov         = obj.priorSettings.a0s.p0;
vprior_s        = obj.priorSettings.a0s.v;
Sprior_s        = obj.priorSettings.a0s.S;

Sigma0_mean     = obj.priorSettings.sigmab.a0;
Sigma0_cov      = obj.priorSettings.sigmab.p0;
vprior_sigma    = obj.priorSettings.sigmab.v;
Sprior_sigma    = obj.priorSettings.sigmab.S;

% Empty output variables                
TS = zeros(nstates, nstates, nobs, nsave*nstep);
QS = zeros(nvary, nvary, nobs, nsave*nstep);
CS = zeros(nstates, 1, nobs, nsave*nstep);
yS = zeros(nobs, nvary, nsave*nstep);
uS = zeros(nobs, nvary, nsave*nstep);

SS = zeros(nvary*(nvary-1)/2, nvary*(nvary-1)/2, 1, nsave*nstep);  
BS = zeros(nvary, nvary, 1, nsave*nstep);
GS = zeros((nstates+1)*nvary, (nstates+1)*nvary, 1, nsave*nstep);

%% Do Gibbs

% Do OLS on VAR to get initial draws
[Gi, Qi, Sigmai, Bi, Si] = getInitialVARestimates(obj, nobs, nvary);

if showProgress    
    % The fprintf must come before parfor_prgress!
    fprintf('Starting gibbs sampler\n');         
    fprintf('Total number of iterations is: %1.0f. Every %1.0f iteration is used. Burninn is: %1.0f\n', ntot, nstep, nburn)
    
    parfor_progress(ntot);
end;          

for irep = 1:ntot  
        
    % 1) Draw the time varying paramters             
    [Ti, Gi] = resamplingFns.drawTTVP(y(nlag+1:end,:), [ones(nobs,1) yl(nlag+1:end,:)],...
                                    Qi, Gi,T0_mean, T0_cov, vprior_g, Sprior_g);
    
    % 2) Draw the time varying covariances (A0 matrix)
    Sigma2i=nan(nvary, nvary, nobs);                
    for i=1:nobs
        Sigma2i(:,:,i)=diag( Sigmai(i,:).^2);                    
    end;                             
    [A0i, Si, yhats] = resamplingFns.drawA0TVP(y(nlag+1:end,:), [ones(nobs,1) yl(nlag+1:end,:)],...
                    Ti, Sigma2i, Si, A00_mean, A00_cov, vprior_s, Sprior_s);    


    % 3) Draw the time varying volatilities
    % Generate ystar   
    ys = zeros(nvary, nobs);     
    for i = 1:nobs                       
        ys(:,i) = A0i(:,:,i)*yhats(:,i);
    end;                    
    [Sigmai, Bi, ~] = resamplingFns.drawSigmaTVP(ys', Sigmai, Bi,...
                            Sigma0_mean, Sigma0_cov, vprior_sigma, Sprior_sigma);

    % Create the VAR covariance matrix Omega(t). It holds that:
    % A(t) x Omega(t) x A(t)' = SIGMA(t) x SIGMA(t) '    
    Qi = zeros(nvary, nvary, nobs);    
    for i = 1:nobs                
        A0invSigma  = A0i(:,:,i)\diag(Sigmai(i,:));
        Qi(:,:,i)   = A0invSigma*A0invSigma';        
    end;        

    % After burinn (taking into account that only every "step" is stored)
    if irep > nburn*nstep             
        ui                          = yhats';
        yhati                       = y(nlag + 1:end,:) - ui;       
        
        yS(:,:, irep - nburn*nstep) = yhati;                        
        uS(:,:, irep - nburn*nstep) = ui;
        
        [Ti, Ci] = varUtilitiesFns.varGetCompForm(Ti(:,2:end,:), Ti(:,1,:), nlag, nvary);
        TS(:,:, :, irep - nburn*nstep) = Ti;                        
        CS(:,:, :, irep - nburn*nstep) = Ci;                                                 
        QS(:,:, :, irep - nburn*nstep) = Qi;  
        
        SS(:,:, 1, irep - nburn*nstep) = Si;
        BS(:,:, 1, irep - nburn*nstep) = Bi;
        GS(:,:, 1, irep - nburn*nstep) = Gi;
        
    end;            
    
    if showProgress
        parfor_progress;
    end;
end;
if showProgress
    parfor_progress(0);
end;

%% Post process the final output and put it into the needed state space form
res.TS  = TS(:,:,:, 1:nstep:end);
res.QS  = QS(:,:,:, 1:nstep:end);
res.CS  = CS(:,:,:, 1:nstep:end);
res.uS  = uS(:,:, 1:nstep:end);
res.yS  = yS(:,:, 1:nstep:end);

res.SS  = SS(:,:, 1, 1:nstep:end);
res.BS  = BS(:,:, 1, 1:nstep:end);
res.GS  = GS(:,:, 1, 1:nstep:end);

% Let the point estimates be the median
res.T   = median(res.TS, 4);
res.Q   = median(res.QS, 4);
res.C   = median(res.CS, 4);
res.u   = median(res.uS, 3);        

res.S   = median(res.SS, 4);        
res.B   = median(res.BS, 4);        
res.G   = median(res.GS, 4);        

% Set observation equation stuff
res.Z   = repmat([eye(nvary) zeros(nvary, nvary*(nlag-1))],[1 1 nobs]);
res.ZS  = repmat(res.Z,[1 1 1 nsave]); 

res.estimationDates = obj.dates(st+obj.nlag:en);

% Done

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Gi, Qi, Sigmai, Bi, Si] = getInitialVARestimates(obj, nobs, nvary)
%% PURPOSE: % Do OLS on VAR to get 
%
% Initial draws
%Gi      = % Initial draw of covaraince of coefficients qdraw=b0_cov;
%Qi      = % initial time varying covaraince matrix of VAR omegadraw=repmat(Q_ols,[1 1 T-nlag]);
%Sigmai  = % Initial draw of state covaraince matrix (ns x ns x t)
%Bi      = % Initial covaraince of disturbances to varaince processes wdraw=eye(N)./1000;
%Si      = % Initial draw of covaraince of distrurbance covariance sdraw=eye(N+1)./100; 


res = estimationFns.var( obj );

% Estract needed stuff
Q_ols           = median(res.Q,4);
[Sigma_ols, ~] = resamplingFns.getSigmaAndA0( Q_ols ); 
T               = cat(2,res.CS,res.TS);

% Initial draws
Gi      = diag(vec(var(T(1:nvary,:,:,:),[],4)'))*(nvary+1);
Qi      = repmat(Q_ols,[1 1 nobs]);
Sigmai  = ones(nobs, nvary);
for i = 1:nobs
    Sigmai(i,:) = diag(Sigma_ols);
end;
Bi      = eye(nvary)./1000;
Si      = eye( nvary*(nvary-1)/2 )./100; 