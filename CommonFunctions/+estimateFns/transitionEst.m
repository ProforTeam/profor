function [T, Q, C, u] = transitionEst(a, nlag, constant, Tres)
% PURPOSE: Estimate transition equation
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

alag            = latMlag(a, nlag);
[nobs,nvary]    = size(a);

if nargin == 4
    [yy, xx]        = varUtilitiesFns.var2SUR(a(1+nlag:end,:), alag(1+nlag:end,:), 'restrictions', Tres);    
    surResults      = varUtilitiesFns.latSur(nvary, yy, xx, 1);
    % transforms sur output to lat var putput
    [alfa, beta, u] = sur2VAR(surResults, Tres, 'constant', constant);            
    [T, C]          = varUtilitiesFns.varGetCompForm(beta, alfa, nlag, nvary);
else    
    if constant    
        c       = ones(size(a,1), 1);        
        t       = ([alag(1+nlag:end,:) c(1+nlag:end)] \ a(1+nlag:end,:))';  
        [T,C]   = varUtilitiesFns.varGetCompForm(t(:,1:end-1), t(:,end), nlag, nvary);        
    else    
        c       = zeros(size(a,1), 1);   
        t       = (alag(1+nlag:end,:) \ a(1+nlag:end,:))';
        [T,C]   = varUtilitiesFns.varGetCompForm(t(:,1:end-1), [], nlag, nvary);        
    end;
    u = a(1+nlag:end,:) - [alag(1+nlag:end, : ) c(1+nlag:end, 1) ] * t';
end;
Q = (u'*u) / ( (nobs-nlag) - (nvary*nlag+constant) );