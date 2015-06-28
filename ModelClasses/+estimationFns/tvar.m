function res = tvar( obj )
% tvar   Estimate and simulate TVAR(p) model
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


% TODO: Hard coded for now
constant            = true;
st                  = max( obj.yInfo.minPanel );
en                  = min( obj.yInfo.maxPanel );            
y                   = obj.y(st : en, :);
draws               = obj.simulationSettings.nsave;

nvar                    = size(y, 2);
nlag                    = obj.nlag;
maxDecay                = obj.maxDecay;
thresholdVariableIndex  = obj.thresholdVariableIndex;
thresholdQuantile       = obj.thresholdQuantile;

nstates                 = nvar*nlag;
nobs                    = size(y,1) - nlag;

[cOpt, decayOpt, result, sd] = varUtilitiesFns.tvarEstOptim(y, nlag, ...
    thresholdVariableIndex, 'maxDecay', maxDecay, 'quantile', thresholdQuantile); 


% Extract stuff from result and put into output matrices
idx = sd <= cOpt;

res.T = zeros(nstates, nstates, nobs);
res.Q = zeros(nvar, nvar, nobs);
res.C = zeros(nstates, 1, nobs);
res.u = zeros(nobs, nvar);

[T0_1, C0_1]    = varUtilitiesFns.varGetCompForm(result(1).beta, result(1).alfa, nlag, nvar);
[T0_2, C0_2]    = varUtilitiesFns.varGetCompForm(result(2).beta, result(2).alfa, nlag, nvar);

res.T(:,:,idx)      = repmat(T0_1, [1 1 sum(idx)]);
res.T(:,:,idx == 0) = repmat(T0_2, [1 1 sum(idx == 0)]);
res.C(:,:,idx)      = repmat(C0_1, [1 1 sum(idx)]);
res.C(:,:,idx == 0) = repmat(C0_2, [1 1 sum(idx == 0)]);
res.Q(:,:,idx)      = repmat(result(1).Q, [1 1 sum(idx)]);
res.Q(:,:,idx == 0) = repmat(result(2).Q, [1 1 sum(idx == 0)]);
res.u(idx,:)        = result(1).emat;
res.u(idx == 0,:)   = result(2).emat;

if draws > 1         
    
    [CS, TS, yS, QS, uS] = resamplingFns.tvarSimulation(...
               nvar, nlag, nobs, thresholdVariableIndex,...
               cOpt, decayOpt, result,...
               'draws', draws,...
               'bootStrapMethod',obj.simulationSettings.bootStrapMethod.x{:},...
               'tPlus', nlag,... 
               'showProgress',obj.simulationSettings.showProgress,...
               'startingValues',vec(y(nlag : - 1 : 1, :)'));    
  
    res.TS = zeros(nstates, nstates, nobs, draws);
    res.QS = zeros(nvar, nvar, nobs, draws);
    res.CS = zeros(nstates, 1, nobs, draws);
    res.uS = zeros(nobs, nvar, draws);            
    res.yS = zeros(nobs, nvar, draws);            
            
    res.TS(:,:,idx,:)       = repmat(TS(:,:,1,:),[1 1 sum(idx) 1]);
    res.TS(:,:,idx == 0,:)  = repmat(TS(:,:,2,:),[1 1 sum(idx == 0) 1]);
    res.CS(:,:,idx,:)       = repmat(CS(:,:,1,:),[1 1 sum(idx) 1]);
    res.CS(:,:,idx == 0,:)  = repmat(CS(:,:,2,:),[1 1 sum(idx == 0) 1]);
    res.QS(:,:,idx,:)       = repmat(QS(:,:,1,:),[1 1 sum(idx) 1]);
    res.QS(:,:,idx == 0,:)  = repmat(QS(:,:,2,:),[1 1 sum(idx == 0) 1]);
    res.yS                  = yS;
    res.uS                  = uS;        
        
end

% Set observation equation stuff
res.Z   = repmat([eye(nvar) zeros(nvar, nvar*(nlag-1))],[1 1 nobs]);
res.ZS  = repmat(res.Z,[1 1 1 draws]); 

% Other stuff
res.estimationDates                     = obj.dates(st + obj.nlag:en);

res.modelSpecificOutput.thresholdValue  = cOpt;
res.modelSpecificOutput.optimalDecay    = decayOpt;
res.modelSpecificOutput.result          = result;
res.modelSpecificOutput.sd              = sd;




