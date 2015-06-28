function [CS, TS, yS, QS, uS] = transitionSim(C, T, u, nlag, draws, bootStrapMethod, showProgress, Tres)
% transitionSim   -  Simulate transition equation using bootstrap
% 
% Input: TODO...
%
% Output: TODO...
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

[nobs, nvary] = size(u);
if nargin == 8
    [CS, TS, yS, QS, uS] = resamplingFns.varSimulation(C, T, u, nvary, nlag, nobs, 'draws', draws,...
        'bootStrapMethod', bootStrapMethod, 'tPlus', nlag, 'sur', true, 'betaRestrictions', Tres, 'showProgress', showProgress);                                        
else    
    [CS, TS, yS, QS, uS] = resamplingFns.varSimulation(C, T, u, nvary, nlag, nobs, 'draws', draws,...
        'bootStrapMethod', bootStrapMethod, 'tPlus', nlag, 'showProgress', showProgress);                                                                                
end;
