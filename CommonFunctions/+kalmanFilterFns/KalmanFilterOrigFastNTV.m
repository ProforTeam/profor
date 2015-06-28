function [state,varCov]=KalmanFilterOrigFastNTV(y,Z,d,H,T,c,R,Q,a0,P0)
% KalmanFilterOrigFastNTV Apply Kalman Filter to time-varying state space
%                         as Harvey (1989). 
%   Faster version of KalmanFilterOrig, i.e no time variation allowed, no error 
%   checking, and no analytic derivation option for derivatives. See 
%   KalmanFilterOrig for input desc. 
%
% Usage: 
%
% [state,varCov]=KalmanFilterOrigFastNTV(y,Z,d,H,T,c,R,Q,a0,P0)
%
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

% 1. Initialisation
%[num_observables,num_observations]=size(y);
num_observations=size(y,2);
num_states=size(a0,1);
% Pre-allocate space for state and covariance of state
a=NaN(num_states,1,num_observations);
P=NaN(num_states,num_states,num_observations);

% 2. The first observation    
apt=T * a0 + c;
Ppt=T * P0 * T' + R * Q * R';

mask=~isnan(y(:,1));
W=diag(mask);
Wt=W(mask,:);
    
Ft=Wt * (Z * Ppt * Z' + H) * Wt';% Zt*Pt*Zt'+Ht==Ft
Ft_inverse=inv(Ft);
y(~mask,1)=0;
vt = Wt * (y(:,1) - Z * apt - d);
    
a(:,1,1)=apt + Ppt * Z' * Wt' * Ft_inverse * vt;
P(:,:,1)=Ppt - Ppt * Z' * Wt' * Ft_inverse * Wt * Z * Ppt;
                         
% 3. Subsequent observations
for t=2:1:num_observations;
    
    apt=T*a(:,t-1)+c;
    Ppt=T*P(:,:,t-1)*T'+R*Q*R';     
    
    mask = ~isnan(y(:,t));
    W = diag(mask);
    Wt = W(mask,:);
    
    if ~isempty(Wt); % we have some current data 
        Ft = Wt * (Z * Ppt * Z' + H) * Wt';    % Variance of observables
        
        Ft_inverse = inv(Ft);
        y(~mask,t) = 0; %replaces nan's with zeros
        vt = Wt * ( y(:,t) - Z * apt-d);%(:,:,1)); %- d(:,:,t));
      
        a(:,1,t)=apt+Ppt*Z'*Wt'*Ft_inverse*vt;               
        P(:,:,t)=(Ppt-Ppt*Z'*Wt'*Ft_inverse*Wt*Z*Ppt);    
        
        % add likelihood here if needed
        %LL(:,t)=-0.5 * ((sum(mask))'*log(2*pi) + log(det(Ft)) + vt' * Ft_inverse * vt);                    
        
    else % we have no data for the current period (so our expectations are unchanged)      
        a(:,:,t) = apt;
        P(:,:,t) = Ppt;
    end;
end;
% Final output   
state=a;
varCov=P;



