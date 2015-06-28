function res = var( obj )
% var   Estimate and simulate VAR(p) model
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

[res.T, res.Q, ...
    res.C, res.u]   = estimateFns.transitionEst(y, obj.nlag, constant);

if obj.simulationSettings.nsave > 1           
    [res.CS, res.TS, res.yS, res.QS, res.uS] = ...
        estimateFns.transitionSim(res.C, res.T, res.u, obj.nlag, draws, ...        
        obj.simulationSettings.bootStrapMethod.x{:}, ...
        obj.simulationSettings.showProgress);            
    
    res.CS = reshape(res.CS, [size(res.CS, 1) 1               1 draws]);
    res.TS = reshape(res.TS, [size(res.TS, 1) size(res.TS, 2) 1 draws]);        
    res.QS = reshape(res.QS, [size(res.QS, 1) size(res.QS, 2) 1 draws]);        
    
end

% Set observation equation stuff
res.Z               = [eye(obj.namesA.numc) zeros(obj.namesA.numc, ...
                        obj.namesA.numc*(obj.nlag - 1))];
res.ZS              = repmat(res.Z, [1 1 1 draws]); 

res.estimationDates = obj.dates(st + obj.nlag:en);





