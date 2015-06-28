function res = bvar(obj)
% PURPOSE: Estimate and simulate BVAR(p) model
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

y               = obj.y(st:en,:);
nvary           = size(y,2);
nlag            = obj.nlag;
nobs            = (en - (st + nlag) + 1);

% Hard coded for now
constant        = true;
Tres            = ones(nvary,nvary*nlag+1);

% For the Gibbs
nsave           = obj.simulationSettings.nsave;                
ntot            = obj.simulationSettings.ntot;                
nburn           = obj.simulationSettings.nburn;                                                               
nstep           = obj.simulationSettings.nstep;
showProgress    = obj.simulationSettings.showProgress;


% Priors
if obj.priorSettings.doMinnesota
    
    [Vprior, Tprior, vprior, Qprior] = estimateFns.getMinnesotaPrior(y, nlag,...
                            constant, obj.priorSettings.minnesotaSettings);        
                        
else
    
    Vprior          = obj.priorSettings.tr.V;
    Tprior          = vec(obj.priorSettings.tr.T');
    vprior          = obj.priorSettings.tr.v;
    Qprior          = obj.priorSettings.tr.Q;
    
end

% Get SUR form of VAR
[ys, zs, ks] = varUtilitiesFns.getYZ(y,nlag,constant,Tres);

% Empty output variables                
TS = zeros(nlag*nvary, nlag*nvary, nsave*nstep);
QS = zeros(nvary, nvary, nsave*nstep);
CS = zeros(nlag*nvary, 1, nsave*nstep);
yS = zeros(nobs, nvary, nsave*nstep);
uS = zeros(nobs, nvary, nsave*nstep);

%% Do Gibbs

% Initial Q draw
Qi = diag(abs(randn(nvary,1)));
if showProgress
    
    % The fprintf must come before parfor_prgress!
    fprintf('Starting gibbs sampler\n');         
    fprintf('Total number of iterations is: %1.0f. Every %1.0f iteration is used. Burninn is: %1.0f\n', ntot, nstep, nburn)
    
    parfor_progress(ntot);
end;          
for irep = 1:ntot  
        
    [Qi,Ti,Ci,ui,yhati] = estimateFns.transitionSimBayes(nobs, nlag, constant, ...
    ks, ys, zs, Qi, Vprior, Tprior, vprior, Qprior, Tres);

    % After burinn (taking into account that only every "step" is stored)
    if irep > nburn*nstep                                                                                                
        TS(:,:, irep - nburn*nstep) = Ti;                        
        QS(:,:, irep - nburn*nstep) = Qi;                                        
        CS(:,:, irep - nburn*nstep) = Ci;                                        
        
        yS(:,:, irep - nburn*nstep) = yhati;                        
        uS(:,:, irep - nburn*nstep) = ui;
        
    end;            
    if showProgress
        parfor_progress;
    end;
end;
if showProgress
    parfor_progress(0);
end;

%% Post process the final output and put it into the needed state space form

res.TS  = reshape(TS(:,:, 1:nstep:end), [size(TS,1) size(TS,2) 1 nsave]);
res.QS  = reshape(QS(:,:, 1:nstep:end), [size(QS,1) size(QS,2) 1 nsave]);
res.CS  = reshape(CS(:,:, 1:nstep:end), [size(CS,1) 1 1 nsave]);
res.uS  = uS(:,:, 1:nstep:end);
res.yS  = yS(:,:, 1:nstep:end);

% Let the point estimates be the median
res.T   = median(res.TS, 4);
res.Q   = median(res.QS, 4);
res.C   = median(res.CS, 4);
res.u   = median(res.uS, 3);        

% Set observation equation stuff
res.Z   = [eye(nvary) zeros(nvary, nvary*(nlag-1))];
res.ZS  = repmat(res.Z,[1 1 1 nsave]); 

res.estimationDates = obj.dates(st+obj.nlag:en);

% Done
