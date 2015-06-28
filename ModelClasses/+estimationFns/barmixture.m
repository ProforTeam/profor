function res = barmixture(obj)
% PURPOSE: Estimate and simulate Bayesian AR mixture models
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

mixtureNormalOnly = obj.mixtureNormalOnly; 

if mixtureNormalOnly
    y           = obj.y(st:en,:);
    nobs        = (en - (st) + 1);        
    
    x           = [];
    nvarx       = 1;    
else
    y           = obj.y(st + nlag : en,:);
    nobs        = (en - (st + nlag) + 1);    
    
    x           = latMlag(obj.y, nlag);    
    x           = [ones(nobs, 1) x(st + nlag:en, :)];        
    nvarx       = size(x, 2);    
    
end
nvary           = size(y, 2);


% For the Gibbs
nsave           = obj.simulationSettings.nsave;                
ntot            = obj.simulationSettings.ntot;                
nburn           = obj.simulationSettings.nburn;                                                               
nstep           = obj.simulationSettings.nstep;
showProgress    = obj.simulationSettings.showProgress;

% Priors    
Vprior          = obj.priorSettings.tr.V;
Tprior          = vec(obj.priorSettings.tr.T');
vprior          = obj.priorSettings.tr.v;
Qprior          = obj.priorSettings.tr.Q;

aprior          = obj.priorSettings.mix.a;
Vaprior         = obj.priorSettings.mix.V;    
pprior          = obj.priorSettings.mix.p;
    
% Specify some constant stuff used within the recursion in the gibbs below
nComponents = size(aprior,1);

% These are used for drawing from the truncated Normal for adraw belwo
a       = zeros(nComponents,1);
b       = zeros(nComponents,1);
la      = zeros(nComponents,1);
lb      = 1*ones(nComponents,1);
la(1,1) = 1;
d       = eye(nComponents);
if nComponents > 1
    for i = 2 : nComponents
        d(i, i - 1) = -1;
    end
end
kstep   = cumsum(ones(nComponents, 1));

% Empty output variables                
TS = zeros(nvary, 1 + nlag*nvary, nsave*nstep);
QS = zeros(nComponents, nsave*nstep);
yS = zeros(nobs, nvary, nsave*nstep);
uS = zeros(nobs, nvary, nsave*nstep);

% For this specific model
aS = zeros(nComponents, nsave*nstep);
pS = zeros(nComponents, nsave*nstep);
eS = zeros(nobs, nComponents, nsave*nstep);

%% Do Gibbs

% Initial draws (starting values)
pdraw = (1/nComponents)*ones(nComponents, 1);
edraw = zeros(nobs, nComponents);
%Randomly draw a set of starting values for e
for i = 1 : nobs
    unif = rand;
    psum = 0;
    for j = 1 : nComponents
        psum = psum + pdraw(j, 1);
        if unif < psum
            edraw(i, j) = 1;
            break
        end
    end
end
% starting value for h and a 
hdraw = (1/(std(y)^2))*ones(nComponents, 1);
adraw = linspace(0, 1, nComponents)';

if showProgress
    
    % The fprintf must come before parfor_prgress!
    fprintf('Starting gibbs sampler\n');         
    fprintf('Total number of iterations is: %1.0f. Every %1.0f iteration is used. Burninn is: %1.0f\n', ntot, nstep, nburn)
    
    parfor_progress(ntot);
end

for irep = 1:ntot  
    
    
    % draw T conditional on other parameters    
    bdraw = drawB(nComponents, nobs, nvarx, y, x, edraw, hdraw, adraw,...
            Vprior, Tprior);    
    
    %draw from h conditional on other parameters
    [hdraw, qdraw] = drawH(nComponents, nobs, y, x, bdraw, edraw, adraw,...
            vprior, Qprior);           
                
    %draw from alpha conditional on other parameters
    adraw = drawA(nComponents, nobs, y, x, bdraw, edraw, hdraw,...
        a, b, la, lb, d, kstep, aprior, Vaprior);    
        
    %draw from p conditional on other parameters
    pdraw = drawP(edraw, pprior); 
          
    %Draw component indicators
    edraw = drawE(nComponents, nobs, y, x, bdraw, adraw, qdraw, pdraw);    

    % After burinn (taking into account that only every "step" is stored)
    if irep > nburn*nstep             
        if ~mixtureNormalOnly                                    
            TS(:,:, irep - nburn*nstep) = bdraw';                                                                                       
                            
            yS(:,:, irep - nburn*nstep) = x*bdraw;                        
            uS(:,:, irep - nburn*nstep) = y - x*bdraw;        
        end
        QS(:, irep - nburn*nstep) = qdraw;                                               
        
        aS(:, irep - nburn*nstep)       = adraw;
        pS(:, irep - nburn*nstep)       = pdraw;
        eS(:, :, irep - nburn*nstep)    = edraw;
        
    end
    
    if showProgress
        parfor_progress;
    end
    
end
   
if showProgress
    parfor_progress(0);
end;

%% Post process the final output and put it into the needed state space form

% Get companion form
[TS, CS] = varUtilitiesFns.varGetCompForm(TS(:,2:end,:), TS(:,1,:), nlag, nvary);            

res.TS  = reshape(TS(:,:, 1:nstep:end), [size(TS,1) size(TS,2) 1 nsave]);
%res.QS  = reshape(QS(:,:, 1:nstep:end), [size(QS,1) size(QS,2) 1 nsave]);
res.CS  = reshape(CS(:,:, 1:nstep:end), [size(CS,1) 1 1 nsave]);
res.uS  = uS(:,:, 1:nstep:end);
res.yS  = yS(:,:, 1:nstep:end);

% Let the point estimates be the median
res.T   = median(res.TS, 4);
%res.Q   = median(res.QS, 4);
res.C   = median(res.CS, 4);
res.u   = median(res.uS, 3);        

% Set observation equation stuff
res.Z   = [eye(nvary) zeros(nvary, nvary*(nlag-1))];
res.ZS  = repmat(res.Z,[1 1 1 nsave]); 

res.modelSpecificOutput.QS = QS(:, 1:nstep:end);
res.modelSpecificOutput.aS = aS(:, 1:nstep:end);
res.modelSpecificOutput.pS = pS(:, 1:nstep:end);
res.modelSpecificOutput.eS = eS(:,:, 1:nstep:end);

if mixtureNormalOnly
    res.estimationDates = obj.dates(st:en);    
else
    res.estimationDates = obj.dates(st+obj.nlag:en);
end

% Done

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function adraw = drawA(nComponents, n, y, x, bdraw, edraw, hdraw,...
    a, b, la, lb, d, kstep, aprior, Vaprior)

if isempty(x)
   x = zeros(n, numel(bdraw, 1)); 
end

esquare = zeros(nComponents, nComponents);
ey      = zeros(nComponents, 1);
for i = 1 : n
    eterm1 = 0;
    for j = 1 : nComponents
        eterm1 = eterm1 + edraw(i,j)*hdraw(j,1);
    end
   esquare  = esquare + eterm1*edraw(i,:)'*edraw(i,:); 
   ey       = ey + eterm1*edraw(i,:)'*(y(i,1) - x(i,:)*bdraw);
 end

va1inv  = inv(Vaprior) + esquare;
va1     = inv(va1inv);
alpha1  = va1*(inv(Vaprior)*aprior + ey);
%Now draw alpha with labelling restriction imposed using truncated Normal
adraw   = tnorm_rnd(nComponents, alpha1, va1, a, b, la, lb, d, kstep);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hdraw, qdraw] = drawH(nComponents, n, y, x, bdraw, edraw, adraw,...
        vprior, Qprior)
    
[hdraw, qdraw] = deal(zeros(nComponents, 1));    
    
if isempty(x)
   x = zeros(n, numel(bdraw, 1)); 
end

v1 = sum(edraw) + vprior;
for j = 1 : nComponents
    sse = 0;    
    for i = 1 : n
       sse = sse + edraw(i, j)*(y(i, 1) - adraw(j, 1) - x(i,:)*bdraw)^2;
    end
    s12             = (sse + vprior*Qprior)/v1(1, j);
    hdraw(j,1)      = gamm_rnd(1, 1, .5*v1(1, j), .5*v1(1, j)*s12);
    qdraw(j,1)      = 1/hdraw(j,1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pdraw = drawP(edraw, pprior)
 
p1      = sum(edraw)';
p1      = p1 + pprior;
pdraw   = dirich_rnd(p1);

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bdraw = drawB(nComponents, n, k, y, x, edraw, hdraw, adraw,...
        Vprior, Tprior)
    
if isempty(x)
    bdraw = zeros(k, 1);    
else    
    esquare1 = zeros(k, k);
    esquare2 = zeros(k, 1);
    for i = 1 : n
        eterm1 = zeros(k, k);
        eterm2 = zeros(k, 1);
        for j = 1 : nComponents        
            eterm1 = eterm1 + edraw(i, j)*hdraw(j, 1)*(x(i, :)'*x(i, :));
            eterm2 = eterm2 + edraw(i, j)*hdraw(j, 1)*x(i, :)'*(y(i) - adraw(j, 1));
        end
        esquare1 = esquare1 + eterm1;
        esquare2 = esquare2 + eterm2;
    end
    v1      = inv(Vprior) +  esquare1;
    v1inv   = inv(v1);
    b1      = v1inv*( inv(Vprior)*Tprior + esquare2 );

    bdraw   = b1 + norm_rnd(v1inv); 
end

    
    
    
    