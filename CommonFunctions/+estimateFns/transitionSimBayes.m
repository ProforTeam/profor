function [Q,T,C,u,yS]=transitionSimBayes(nobs, nlag, constant, ...
    ks, ys, zs, Q, Vprior, Tprior, vprior, Qprior, Tres)
% transitionSimBayes   -  Draw parameters from  state equation using
%                          Bayesian methods
%
% Input:
%
% Output:
%
% Usage:
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

maxNumberOfRhs  = max(ks);
nvary           = numel(ks);

stabilityCondition = 1;
while stabilityCondition == 1
    
    % Compute some usefull parameters
    h           = kron(inv(Q), eye(nobs));
    xhx         = zs'*h*zs;
    xhy         = zs'*h*ys;
    capv0inv    = inv(Vprior);
    
    %draw from beta conditional on H
    capv1inv    = capv0inv + xhx;
    capv1       = inv(capv1inv);
    b1          = capv1*(capv0inv*Tprior + xhy);
    beta        = b1 + norm_rnd(capv1);    

    %draw from H conditional on beta       
    % Posterior of SIGMA|ALPHA,Data ~ iW(inv(S_post),v_post)
    v           = nobs + vprior;
    u           = reshape(ys - zs*beta,[nobs nvary]);            
    H           = inv(vprior*Qprior + u'*u);    
    Q           = inv(wish_rnd(H, v));        
        
    % Transform ALPHA into form that can be used in other utils below and
    % stored as output
    betan = zeros(nvary, maxNumberOfRhs);
    cnt = 0;
    for i = 1:nvary
        betan(i, Tres(i,:) == 1) = beta(1 + cnt:ks(i) + cnt);
        cnt = cnt + ks(i);
    end;
    
    % get comp form to check stability
    if constant
        [T,C] = varUtilitiesFns.varGetCompForm(betan(:,2:end,:),betan(:,1,:), nlag, nvary);
    else
        [T,C] = varUtilitiesFns.varGetCompForm(betan, [], nlag, nvary);
    end;
    
    if any(abs(eig(T)) >= 1)
        stabilityCondition  = 1;
    else
        % To brake out of while statement if stability
        % ensured
        stabilityCondition  = 0;
        yS                  = reshape(zs*beta,[nobs nvary]) + (chol(Q)*randn(nvary,nobs))';
    end
end